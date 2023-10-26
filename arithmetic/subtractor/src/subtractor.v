module subtractor #(
    parameter N = 32
) (
    input [N-1:0] first_term,
    input [N-1:0] second_term,
    input borrow_in,
    output reg [N-1:0] difference,
    output reg borrow_out
);

  always @(first_term or second_term or borrow_in) begin
    difference = first_term ^ second_term ^ borrow_in;
    borrow_out = first_term < (second_term + borrow_in);
  end


endmodule
