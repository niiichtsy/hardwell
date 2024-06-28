`timescale 1 ps / 1 ps
// `include "clk_switch.v"

module clk_switch_tb ();
  reg sim_clk_in0, sim_clk_in1;
  reg  sim_clk_select = 0;
  wire sim_clk_out;

  initial begin
    sim_clk_in0 = 1'b0;
    forever sim_clk_in0 = #100 ~sim_clk_in0;
  end

  initial begin
    sim_clk_in1 = 1'b0;
    forever sim_clk_in1 = #300 ~sim_clk_in1;
  end

  integer i = 0;

  initial begin
    for (i = 0; i < 50; i = i + 1) begin
      #4500;
      sim_clk_select <= ~sim_clk_select;
    end
  end

  clk_switch switch (
      .clk_select(sim_clk_select),
      .clk_in0(sim_clk_in0),
      .clk_in1(sim_clk_in1),
      .clk_out(sim_clk_out)
  );




endmodule
