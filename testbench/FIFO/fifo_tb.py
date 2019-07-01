import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge, Event, ClockCycles
from cocotb.result import TestFailure, TestError, ReturnValue, SimFailure
from cocotb.binary import BinaryValue
from random import randint

@cocotb.test()
def test_01_sync(dut):
    """
    Test of the FIFO Sync
    """
    cocotb.fork(Clock(dut.wr_clk_i, 4).start())
    dut.rd_clk_i <= 0
    dut.async_i  <= 0
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.test()
def test_02_async_wr(dut):
    """
    Test of the FIFO aSync (with write faster than read)
    """
    cocotb.fork(Clock(dut.wr_clk_i, 4).start())
    cocotb.fork(Clock(dut.rd_clk_i, 6).start())
    dut.async_i  <= 1
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.test()
def test_03_async_rd(dut):
    """
    Test of the FIFO aSync (with read faster than write)
    """
    cocotb.fork(Clock(dut.wr_clk_i, 10).start())
    cocotb.fork(Clock(dut.rd_clk_i, 4).start())
    dut.async_i  <= 1
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.coroutine
def reset(dut):
    dut.wr_rst_i <= 1
    dut.wr_en_i  <= 0
    dut.data_i   <= 0
    dut.rd_rst_i <= 1
    dut.rd_en_i  <= 0
    yield ClockCycles(dut.wr_clk_i, 3)
    dut.wr_rst_i <= 0
    dut.rd_rst_i <= 0
    if dut.async_i == 1:
       yield RisingEdge(dut.rd_clk_i)
    else:
       yield RisingEdge(dut.wr_clk_i)
    dut._log.info("Reset complete")

@cocotb.coroutine
def test_signaling(dut):
    dut._log.info("* Testing signaling")
    yield RisingEdge(dut.wr_clk_i)

@cocotb.coroutine
def test_running(dut):
    dut._log.info("* Testing running")
    yield RisingEdge(dut.wr_clk_i)
