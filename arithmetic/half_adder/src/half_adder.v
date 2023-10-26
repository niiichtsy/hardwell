module half_adder (
    input first_term,
    input second_term,
    output reg sum,
    output reg carry
);

  always @(first_term or second_term) begin
    carry = first_term & second_term;
    sum   = first_term ^ second_term;
  end


endmodule
