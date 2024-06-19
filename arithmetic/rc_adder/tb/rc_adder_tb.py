# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0

import os
from pathlib import Path

import pytest

import cocotb
from cocotb.runner import get_runner
from cocotb.triggers import Timer


pytestmark = pytest.mark.simulator_required
CLK_PERIOD_NS = 10


async def init_dut(dut):
    dut.first_term = 0
    dut.second_term = 0
    dut.carry_in = 0


@cocotb.test()
async def rc_adder_test(dut):
    """Ripple carry adder test"""

    # await setup_dut_clk(dut)
    await init_dut(dut)

    # await reset_dut(dut, CLK_PERIOD_NS * 3)
    await Timer(CLK_PERIOD_NS * 20, units="ns")
    dut.first_term = 0x77
    dut.second_term = 0x88
    dut.carry_in = 0x0

    await Timer(CLK_PERIOD_NS * 20, units="ns")
    dut.first_term = 0xFF
    dut.second_term = 0xFF
    dut.carry_in = 0x1

    await Timer(CLK_PERIOD_NS * 20, units="ns")
    dut.first_term = 0xFF
    dut.second_term = 0xFF
    dut.carry_in = 0x0

    await Timer(CLK_PERIOD_NS * 20, units="ns")


def test_rc_adder_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent

    verilog_sources = []

    verilog_sources = [proj_path / "rc_adder.v"]

    runner = get_runner(sim)()
    runner.build(verilog_sources=verilog_sources, hdl_toplevel="rc_adder")

    runner.test(hdl_toplevel="rc_adder", test_module="test_rc_adder")


if __name__ == "__main__":
    test_rc_adder_runner()
