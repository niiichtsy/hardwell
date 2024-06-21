module clk_stabilizer (
    input clk_select,
    input prog_clk,
    input stable_clk,
    output wire out_clk

);

  assign out_clk = out_clk_s;
  assign prog_clk_s = prog_clk;
  assign stable_clk_s = stable_clk;
  assign clock_select_s = clk_select;

  BUFGMUX_CTRL i_clock_mux (
      .S (clock_select_s),
      .I0(prog_clk_s),
      .I1(stable_clk_s),
      .O (out_clk_s)
  );

  // Simulate waves
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars(1, clk_stabilizer);
  // end

endmodule
