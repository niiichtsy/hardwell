module eth_pkt_gen #(
  parameter        INCLUDE_PREAMBLE = 0,
  parameter        DATA_SOURCE      = 0,
  parameter [15:0] ETHERTYPE        = 'h8100
) (
    // AXI-Stream interface
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tlast,
    output reg m_axis_tvalid,
    input m_axis_tready,

    // Eth interface controls
    input [ 7:0] user_data,
    input [15:0] vlan_tag,    // Currently, this is not just the vlan tag (VID), which is 12 bits, but the entire TCI (PCP + DEI + VID)
    input [11:0] pkt_length,
    input [47:0] source,
    input [47:0] destination,

    input clk,
    input resetn
);

  // Data source parameters
  parameter [0:0] LFSR = 0;
  parameter [0:0] USER = 1;

  // Ethertype parameters
  parameter [15:0] ETHERNET = 'h0800;
  parameter [15:0] VLAN = 'h8100;

  // States
  parameter ADD_PREAMBLE = 0;
  parameter SET_DESTINATION = 1;
  parameter SET_SOURCE = 2;
  parameter SET_ETHERTYPE = 3;
  parameter SET_DATA = 4;
  parameter INTERPACKET_GAP = 5;
  parameter IDLE = 6;

  // Regs
  reg  [ 4:0] state;
  reg  [11:0] state_counter;

  // Wires
  wire [ 7:0] lfsr_byte_s;

  always @(posedge clk) begin
    if (!resetn) begin
      m_axis_tdata <= 'h00;
      m_axis_tlast <= 'h0;
      m_axis_tvalid <= 'h0;
      state <= IDLE;
      state_counter <= 'h00;
    end else begin

      case (state)

        IDLE: begin
          if (INCLUDE_PREAMBLE == 1'b1) state <= ADD_PREAMBLE;
          else state <= SET_DESTINATION;
        end

        // State used to add the ethernet preamble, only if set in the IP
        // parameters
        ADD_PREAMBLE: begin
          m_axis_tvalid <= 1'b1;
          m_axis_tdata  <= 'h55;
          if (m_axis_tready && m_axis_tvalid) begin
            if (state_counter < 'h6) begin
              m_axis_tdata <= 'h55;
              state <= ADD_PREAMBLE;
              state_counter <= state_counter + 1'b1;
            end else begin
              m_axis_tdata <= 'hD5;
              state <= SET_DESTINATION;
              state_counter <= 'h00;
            end
          end else begin
            state <= state;
          end
        end

        // Send destination data
        SET_DESTINATION: begin
          m_axis_tvalid <= 1'b1;
          m_axis_tdata  <= destination[47:40];  // This needs to be set in the same cycle as tvalid
          if (m_axis_tready && m_axis_tvalid) begin
            state <= SET_DESTINATION;
            state_counter <= state_counter + 1'b1;
            case (state_counter)
              0: m_axis_tdata <= destination[39:32];
              1: m_axis_tdata <= destination[31:24];
              2: m_axis_tdata <= destination[23:16];
              3: m_axis_tdata <= destination[15:8];
              4: begin
                m_axis_tdata <= destination[7:0];
                state <= SET_SOURCE;
                state_counter <= 'h00;
              end
            endcase
          end else begin
            state <= state;
          end
        end

        // Send source data
        SET_SOURCE: begin
          m_axis_tvalid <= 1'b1;
          if (m_axis_tready && m_axis_tvalid) begin
            state <= SET_SOURCE;
            state_counter <= state_counter + 1'b1;
            case (state_counter)
              0: m_axis_tdata <= source[47:40];
              1: m_axis_tdata <= source[39:32];
              2: m_axis_tdata <= source[31:24];
              3: m_axis_tdata <= source[23:16];
              4: m_axis_tdata <= source[15:8];
              5: begin
                m_axis_tdata <= source[7:0];
                state <= SET_ETHERTYPE;
                state_counter <= 'h00;
              end
            endcase
          end else begin
            state <= state;
          end
        end

        SET_ETHERTYPE: begin
          m_axis_tvalid <= 1'b1;
          if (m_axis_tready && m_axis_tvalid) begin
            state <= SET_ETHERTYPE;
            state_counter <= state_counter + 1'b1;
            if (ETHERTYPE == ETHERNET) begin
              case (state_counter)
                0: m_axis_tdata <= ETHERTYPE[15:8];
                1: begin
                  m_axis_tdata <= ETHERTYPE[7:0];
                  state <= SET_DATA;
                  state_counter <= 'h00;
                end
              endcase
            end else if (ETHERTYPE == VLAN) begin
              case (state_counter)
                0: m_axis_tdata <= ETHERTYPE[15:8];
                1: m_axis_tdata <= ETHERTYPE[7:0];
                2: m_axis_tdata <= vlan_tag[15:8];
                3: m_axis_tdata <= vlan_tag[7:0];
                4: m_axis_tdata <= ETHERTYPE[15:8];
                5: begin
                  m_axis_tdata <= ETHERTYPE[7:0];
                  state <= SET_DATA;
                  state_counter <= 'h00;
                end
              endcase
            end
          end else begin
            state <= state;
          end
        end

        SET_DATA: begin
          m_axis_tvalid <= 1'b1;
          if (m_axis_tready && m_axis_tvalid) begin
            if (state_counter < pkt_length) begin
              if (DATA_SOURCE == USER) begin
                m_axis_tdata <= user_data;
                state <= SET_DATA;
                state_counter <= state_counter + 1'b1;
              end else if (DATA_SOURCE == LFSR) begin
                m_axis_tdata <= lfsr_byte_s;
                state <= SET_DATA;
                state_counter <= state_counter + 1'b1;
              end
              if (state_counter == pkt_length - 1) m_axis_tlast <= 1'b1;
            end else begin
              m_axis_tlast <= 1'b0;
              m_axis_tvalid <= 1'b0;
              state <= INTERPACKET_GAP;
              state_counter <= 'h00;
            end
          end else begin
            state <= state;
          end
        end

        // The interpacket gap is measured from the end of the FCS of one
        // frame to the start of the preamble for the next one.
        // Traditionally, this is 96 bit times, so for Gigabit Ethernet,
        // the IPG is 96 ns, which is 12 clock cycles @ 125 MHz.
        // This does not take into account the cycles needed to progress
        // from IDLE to SET_DESTINATION/INCLUDE_PREAMBLE, and then begin the transmit of
        // destination/preamble,
        INTERPACKET_GAP: begin
          m_axis_tvalid <= 1'b0;
          state <= INTERPACKET_GAP;
          state_counter <= state_counter + 1'b1;
          if (state_counter >= 'd12 - 1) begin
            state <= IDLE;
            state_counter <= 'h00;
          end
        end

      endcase
    end
  end

  lfsr i_lfsr (
      .clk(clk),
      .resetn(resetn),
      .data_out(lfsr_byte_s)
  );

  //Simulate waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, eth_pkt_gen);
  end

endmodule
