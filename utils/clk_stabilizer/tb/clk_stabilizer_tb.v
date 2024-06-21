`timescale 1 ps / 1 ps
// `include "clk_stabilizer.v"

module clk_stabilizer_tb ();
  reg sim_prog_clk, sim_stable_clk;
  reg  sim_clk_select = 0;
  wire sim_out_clk;

  initial begin
    sim_prog_clk = 1'b0;
    forever sim_prog_clk = #100 ~sim_prog_clk;
  end

  initial begin
    sim_stable_clk = 1'b0;
    forever sim_stable_clk = #300 ~sim_stable_clk;
  end

  integer i = 0;

  initial begin
    for (i = 0; i < 50; i = i + 1) begin
      #4500;
      sim_clk_select <= ~sim_clk_select;
    end
  end

  clk_stabilizer stab (
      .clk_select(sim_clk_select),
      .prog_clk(sim_prog_clk),
      .stable_clk(sim_stable_clk),
      .out_clk(sim_out_clk)
  );




endmodule
