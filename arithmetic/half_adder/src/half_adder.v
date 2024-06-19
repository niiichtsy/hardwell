module half_adder (
    input first_term,
    input second_term,
    output reg sum_out,
    output reg carry_out
);

  always @(first_term or second_term) begin
    sum_out   = first_term ^ second_term;
    carry_out = first_term & second_term;
  end


endmodule
