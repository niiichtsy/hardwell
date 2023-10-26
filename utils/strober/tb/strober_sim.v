`timescale 1 ps / 1 ps
`include "strober.v"

module strober_sim ();

  reg  simclk;
  reg  simrst;
  reg  simenable;
  wire simact;

  strober main (
      .clk(simclk),
      .resetn(simrst),
      .signal(simenable),
      .strobe(simact)
  );

  initial begin
    simclk = 1'b0;
    forever simclk = #3333 ~simclk;
  end

  initial begin
    simrst = 1'b1;
    #9999;
    simrst = 1'b0;
    #3333;
    simrst = 1'b1;
  end

  initial begin
    #7500;
    simenable <= 1'b1;
    #3333;
    simenable <= 1'b0;
    #9999;
    simenable <= 1'b1;
    #99990;
    simenable <= 1'b0;
  end

endmodule
