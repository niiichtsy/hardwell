module full_adder (
    input first_term,
    input second_term,
    input carry_in,
    output reg sum_out,
    output reg carry_out
);

  always @(first_term or second_term or carry_in) begin
    sum_out   = first_term ^ second_term ^ carry_in;
    carry_out = (first_term & second_term) | (carry_in & (first_term ^ second_term));
  end

  // Simulate waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, full_adder);
  end

endmodule
