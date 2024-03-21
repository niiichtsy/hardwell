module lfsr #(
    parameter SEED = 'hBC
) (
    output reg [7:0] data_out,
    inout enable,
    input clk,
    input resetn
);

  reg [7:0] shift_register;

  wire xor_stage_1, xor_stage_2, xor_stage_3;

  assign xor_stage_1 = shift_register[7] ^ shift_register[4];  // x^7 xor x^4
  assign xor_stage_2 = xor_stage_1 ^ shift_register[3];  // x^7 xor x^4 xor x^3
  assign xor_stage_3 = xor_stage_2 ^ shift_register[2];  // x^7 xor x^4 xor x^3 xor x^2

  always @(posedge clk) begin
    if (!resetn) begin
      shift_register <= SEED;
    end else begin
      shift_register <= shift_register << 1;
      shift_register[0] <= xor_stage_3;
      data_out <= shift_register;
      if (shift_register == 'h00) shift_register <= SEED;  // Reset the register in case we run out of combinations
    end
  end


  // Simulate waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, lfsr);
  end

endmodule
