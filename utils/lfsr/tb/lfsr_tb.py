import os
from pathlib import Path

import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

pytestmark = pytest.mark.simulator_required
CLK_PERIOD_NS = 10


async def reset_dut(dut, duration_ns):
    dut.resetn.value = 0
    await Timer(duration_ns, units="ns")
    dut.resetn.value = 1
    await Timer(duration_ns, units="ns")
    dut.resetn._log.debug("Reset complete")


async def setup_dut_clk(dut):
    # Create a 10ns period clock on clk ports
    clk = Clock(dut.clk, CLK_PERIOD_NS, units="ns")

    # Start the clocks
    cocotb.start_soon(clk.start())
    dut.clk._log.debug("Clocks started")


@cocotb.test()
async def lfsr_test(dut):
    """Test linear feedback shift register"""

    await setup_dut_clk(dut)
    await reset_dut(dut, CLK_PERIOD_NS * 5)
    await Timer(CLK_PERIOD_NS * 5, units="ns")
    await RisingEdge(dut.clk)
    await Timer(CLK_PERIOD_NS * 300, units="ns")


def test_lfsr_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent
    verilog_sources = [proj_path / "lfsr.sv"]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources,
        toplevel="lfsr",
    )

    runner.test(toplevel="lfsr", py_module="test_lfsr")


if __name__ == "__main__":
    test_lfsr_runner()
