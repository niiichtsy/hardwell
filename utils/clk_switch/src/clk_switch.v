module clk_switch (
    input clk_select,
    input clk_in0,
    input clk_in1,
    output wire clk_out
);

  BUFGMUX_CTRL i_clock_mux (
      .S (clk_select),
      .I0(clk_in0),
      .I1(clk_in1),
      .O (clk_out)
  );

  // Simulate waves
  // initial begin
  //   $dumpfile("dump.vcd");
  //   $dumpvars(1, clk_switch);
  // end

endmodule
