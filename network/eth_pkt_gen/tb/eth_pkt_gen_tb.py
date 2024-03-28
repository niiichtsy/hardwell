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
async def eth_pkt_gen_tb(dut):
    """Test ethernet packet generator"""

    dut.m_axis_tready = 1
    dut.user_data = 0x4A
    dut.vlan_tag = 0x003C
    dut.pkt_length = 68
    dut.source = 0x112233445566
    dut.destination = 0x998877665544

    await setup_dut_clk(dut)
    await reset_dut(dut, CLK_PERIOD_NS * 5)
    await Timer(CLK_PERIOD_NS * 5, units="ns")
    await RisingEdge(dut.clk)
    await Timer(CLK_PERIOD_NS * 1000, units="ns")


def test_eth_pkt_gen_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent
    verilog_sources = [proj_path / "eth_pkt_gen.sv"]

    runner = get_runner(sim)()
    runner.build(
        verilog_sources=verilog_sources,
        toplevel="eth_pkt_gen_tb",
    )

    runner.test(toplevel="eth_pkt_gen", py_module="eth_pkt_gen_tb")


if __name__ == "__main__":
    test_eth_pkt_gen_runner()
