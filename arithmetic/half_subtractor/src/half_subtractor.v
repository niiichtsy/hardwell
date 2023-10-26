module half_subtractor (
    input first_term,
    input second_term,
    output reg difference,
    output reg borrow
);

  always @(first_term or second_term) begin
    difference = first_term ^ second_term;
    borrow = (~first_term & second_term);
  end


endmodule
