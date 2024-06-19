module rc_adder #(
    parameter WIDTH = 8
) (
    input [WIDTH-1:0] first_term,
    input [WIDTH-1:0] second_term,
    input carry_in,
    output reg [WIDTH-1:0] sum_out,
    output reg carry_out
);

  genvar i;
  wire [WIDTH-1:0] carry_signal;

  assign carry_signal[0] = carry_in;

  generate
    for (i = 0; i < WIDTH; i = i + 1) begin : generate_adder
      if (i != (WIDTH - 1)) begin
        full_adder fa (
            .first_term(first_term[i]),
            .second_term(second_term[i]),
            .carry_in(carry_signal[i]),
            .sum_out(sum_out[i]),
            .carry_out(carry_signal[i+1])
        );
      end else begin
        full_adder fa_out (
            .first_term(first_term[i]),
            .second_term(second_term[i]),
            .carry_in(carry_signal[i]),
            .sum_out(sum_out[i]),
            .carry_out(carry_out)
        );
      end
    end
  endgenerate

  // Simulate waves
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, rc_adder);
  end

endmodule
