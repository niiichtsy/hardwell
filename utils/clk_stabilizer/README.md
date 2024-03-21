# clk_stabilizer

Verilog module that allows glitchless transitions between a stable and unstable clock via the clock_select input port. Typical use case is:
- Switch from the unstable, programmable clock to the stable clock writing a 1 to the clock_select.
- Program the unstable clock.
- Signal that clock reconfiguration is done by writing a 0 to the clock_select port, thus switching to the programmable clock.

This module uses the Xilinx BUFGMUX_CTRL primitive.
