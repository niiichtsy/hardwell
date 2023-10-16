module clk_divider #(
  parameter DIV_VALUE = 125000000,
  parameter DIV_WIDTH = 32
) (
    output reg clk_out,
    input clk_in,
    input resetn
);
  reg [DIV_WIDTH-1:0] div_counter;

  always @(posedge clk_in) begin
    if (!resetn) begin
      div_counter <= 'h00;
      clk_out <= 1'b0;
    end else begin

      if (div_counter == DIV_VALUE) begin
        div_counter <= 'h00;
        clk_out <= ~clk_out;
      end else div_counter <= div_counter + 1'b1;

    end
  end

  // Testbench waves
  initial begin
    $dumpvars(0, clk_divider);
    $dumpfile("dump.vcd");
  end

endmodule
