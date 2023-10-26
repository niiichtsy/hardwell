module adder #(
    parameter N = 32
) (
    input [N-1:0] first_term,
    input [N-1:0] second_term,
    input carry_in,
    output reg [N-1:0] sum,
    output reg carry_out
);

  always @(first_term or second_term or carry_in) begin
    {carry_out, sum} = first_term + second_term + carry_in;
  end


endmodule
