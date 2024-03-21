module eth_pkt_gen #(
    parameter [0:0] INCLUDE_PREAMBLE = 0,
    parameter [0:0] DATA_SOURCE = LFSR,
    parameter [15:0] ETHERTYPE = ETHERNET
) (
    // AXI-Stream interface
    output reg [7:0] m_axis_tdata,
    output reg m_axis_tlast,
    output reg m_axis_tvalid,
    input m_axis_tready,

    // Eth interface controls
    input [ 7:0] user_data,
    input [31:0] vlan_tag,    // Currently, this is not just the Vlan tag, which is two bytes, but also the TCI (Tag control information)
    input [11:0] length,
    input [47:0] source,
    input [47:0] destination,

    input clk,
    input resetn
);

  // Data source parameters
  parameter [0:0] LFSR = 0;
  parameter [0:0] USER = 1;

  //Ethertype parameters
  parameter [15:0] ETHERNET = 'h0800;
  parameter [15:0] VLAN = 'h8100;

  // States
  parameter ADD_PREAMBLE = 0;
  parameter SET_DESTINATION = 1;
  parameter SET_SOURCE = 2;
  parameter SET_ETHERTYPE = 3;
  parameter SET_DATA = 4;

  reg [ 3:0] state;
  reg [11:0] state_counter;

  always @(posedge clk) begin
    if (!resetn) begin
      m_axis_tdata  <= 'h00;
      m_axis_tlast  <= 'h0;
      m_axis_tvalid <= 'h0;
      if (INCLUDE_PREAMBLE) state <= ADD_PREAMBLE;
      else state <= SET_DESTINATION;
      state_counter <= 'h00;
    end else begin

      case (state)

        ADD_PREAMBLE: begin
          if (m_axis_tready) begin
            if (state_counter < 'h7) begin
              state_counter <= state_counter + 1'b1;
              m_axis_tvalid <= 1'b1;
              m_axis_tdata <= 'b10101010;
              state <= ADD_PREAMBLE;
            end else begin
              state_counter <= 'h00;
              m_axis_tvalid <= 1'b1;
              m_axis_tdata <= 'b10101011;
              state <= SET_DESTINATION;
            end
          end else begin
            m_axis_tvalid <= 1'b0;
            state <= state;
          end
        end

        SET_DESTINATION: begin
          if (m_axis_tready) begin
            m_axis_tvalid <= 1'b1;
            case (state_counter)
              0: m_axis_tdata <= destination[47:40];
              1: m_axis_tdata <= destination[39:32];
              2: m_axis_tdata <= destination[31:24];
              3: m_axis_tdata <= destination[23:16];
              4: m_axis_tdata <= destination[15:8];
              5: begin
                m_axis_tdata <= destination[7:0];
                state <= SET_SOURCE;
              end
            endcase
            state_counter <= state_counter + 1'b1;
          end else begin
            m_axis_tvalid <= 1'b0;
            state <= state;
          end
        end

        SET_SOURCE: begin
          if (m_axis_tready) begin
            m_axis_tvalid <= 1'b1;
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
            state_counter <= state_counter + 1'b1;
          end else begin
            m_axis_tvalid <= 1'b0;
            state <= state;
          end

          SET_ETHERTYPE : begin
            if (m_axis_tready) begin
              m_axis_tvalid <= 1'b1;
              if (ETHERTYPE == ETHERNET) begin
                case (state_counter)
                  0: m_axis_tdata <= ETHERTYPE[15:8];
                  1: begin
                    m_axis_tdata <= ETHERTYPE[7:0];
                    state <= SET_DATA;
                  end
                endcase
              end else if (ETHERTYPE == ETHERNET) begin
                case (state_counter)
                  0: m_axis_tdata <= ETHERTYPE[15:8];
                  1: m_axis_tdata <= ETHERTYPE[7:0];
                endcase
              end
            end else begin
              m_axis_tvalid <= 1'b0;
              state <= state;
            end


          end

          SET_DATA : begin
            if (m_axis_tready) begin
              m_axis_tvalid <= 1'b1;
              m_axis_tdata  <= user_data;
              state_counter <= state_counter + 1'b1;
            end else begin
              m_axis_tvalid <= 1'b0;
              state <= state;
            end
          end

        end

      endcase





    end

  end

endmodule
