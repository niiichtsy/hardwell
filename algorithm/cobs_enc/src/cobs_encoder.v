module cobs_encoder #(
  MAX_IN_BYTES = 256
) (
    // AXI-Stream Slave
    input s_axis_tlast,
    input [7:0] s_axis_tdata,
    input s_axis_tvalid,
    output s_axis_tready,

    // AXI-Stream Master
    output m_axis_tlast,
    output [7:0] m_axis_tdata,
    output m_axis_tvalid,
    input m_axis_tready,

    input clk,
    input [7:0] data_in,
    output reg [7:0] data_out,
    input resetn
);

  reg [MAX_IN_BYTES*8-1:0] packet;
  reg packet_active;
  reg data;
  reg [MAX_IN_BYTES-1:0] pad_counter;

  always @(posedge clk) begin
    if (!resetn) begin
      packet <= 'h00;
      pad_counter <= 'h00;
      packet_active <= 'h0;
      data <= 'h00;
      data_out <= 'h00;
    end else begin

    end
  end

endmodule
