import os
from pathlib import Path

import pytest

import cocotb
from cocotb.clock import Clock
from cocotb.runner import get_runner
from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

pytestmark = pytest.mark.simulator_required
CLK_PERIOD_NS = 8
NUM_PKTS = 5


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

    pkt_counter = 0

    dut.m_axis_tready.value = 0
    dut.user_data.value = 0x4A
    dut.vlan_tag.value = 0x003C
    dut.pkt_length.value = 68
    dut.source.value = 0x112233445566
    dut.destination.value = 0x998877665544

    await setup_dut_clk(dut)
    await reset_dut(dut, CLK_PERIOD_NS * 5)
    while 1:
        if dut.m_axis_tvalid.value == 1:
            dut.m_axis_tready.value = 1
        else:
            dut.m_axis_tready.value = 0
        if dut.m_axis_tlast.value == 1:
            if pkt_counter > NUM_PKTS:
                break
            else:
                pkt_counter += 1
        await RisingEdge(dut.clk)

    assert dut.m_axis_tlast.value == 1


@cocotb.test()
async def eth_pkt_gen_stagger_tb(dut):
    """Test ethernet packet generator with a stagger during destination and source setting"""

    pkt_counter = 0

    dut.m_axis_tready.value = 0
    dut.user_data.value = 0x4A
    dut.vlan_tag.value = 0x003C
    dut.pkt_length.value = 68
    dut.source.value = 0x112233445566
    dut.destination.value = 0x998877665544

    await setup_dut_clk(dut)
    await reset_dut(dut, CLK_PERIOD_NS * 5)
    while 1:
        await RisingEdge(dut.clk)
        if dut.m_axis_tvalid.value == 1:
            if dut.m_axis_tdata == 0x55:
                dut.m_axis_tready.value = 0
            else:
                dut.m_axis_tready.value = 1
        else:
            dut.m_axis_tready.value = 0
        if dut.m_axis_tlast.value == 1:
            if pkt_counter > NUM_PKTS:
                break
            else:
                pkt_counter += 1

    assert dut.m_axis_tlast.value == 1


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
