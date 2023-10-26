# This file is public domain, it can be freely copied without restrictions.
import os
import sys
from pathlib import Path

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock


async def setup_clocks(dut):
    clk = Clock(dut.clk_in, 8, units="ns")
    cocotb.start_soon(clk.start())


async def reset_dut(dut):
    dut.resetn.value = 1
    await Timer(10, units="ns")
    dut.resetn.value = 0
    await Timer(10, units="ns")
    dut.resetn.value = 1
    await Timer(10, units="ns")


@cocotb.test()
async def clk_divider_test(dut):
    await setup_clocks(dut)
    await RisingEdge(dut.clk_in)
    await reset_dut(dut)
    await Timer(200, units="ns")


def clk_divider_test_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent
    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "model"))

    verilog_sources = [proj_path / "src" / "clk_divider.v"]

    # equivalent to setting the PYTHONPATH environment variable
    sys.path.append(str(proj_path / "tests"))

    runner = get_runner(sim)
    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel="clk_divider",
        always=True,
    )
    runner.test(
        hdl_toplevel="clk_divider",
        test_module="clk_divider_test",
    )


if __name__ == "__main__":
    clk_divider_test_runner()
