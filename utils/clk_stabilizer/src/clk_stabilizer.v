`timescale 1ns / 1ps

module clk_stabilizer (
    input clk_select,
    output reg out_clk,
    input stable_clk,
    input prog_clk,
    input resetn

);

  assign clk_out_s = out_clk;
  assign clk_prog_s = prog_clk;
  assign clk_stable_s = stable_clk;
  assign clock_select_s = clk_select;

  BUFGMUX_CTRL i_clock_mux (
      .S (clock_select_s),
      .I0(clk_prog_s),
      .I1(clk_stable_s),
      .O (clk_out_s)
  );

  // Simulate waves
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars(1, clk_stabilizer);
  // end

endmodule
