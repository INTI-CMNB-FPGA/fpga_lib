import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, FallingEdge, Edge, Event, ClockCycles
from cocotb.result import TestFailure, TestError, ReturnValue, SimFailure
from cocotb.binary import BinaryValue
from random import randint

DEBUG = 1

@cocotb.test()
def test_01_sync(dut):
    """
    Test of the FIFO Sync
    """
    cocotb.fork(Clock(dut.wclk_i, 4).start())
    cocotb.fork(Clock(dut.rclk_i, 4).start())
    dut.async_i  <= 0
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.test()
def test_02_async_wr(dut):
    """
    Test of the FIFO aSync (with write faster than read)
    """
    cocotb.fork(Clock(dut.wclk_i, 4).start())
    cocotb.fork(Clock(dut.rclk_i, 6).start())
    dut.async_i  <= 1
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.test()
def test_03_async_rd(dut):
    """
    Test of the FIFO aSync (with read faster than write)
    """
    cocotb.fork(Clock(dut.wclk_i, 10).start())
    cocotb.fork(Clock(dut.rclk_i, 4).start())
    dut.async_i  <= 1
    yield reset(dut)
    yield test_signaling(dut)
    yield test_running(dut)

@cocotb.coroutine
def reset(dut):
    dut.wrst_i <= 1
    dut.wen_i  <= 0
    dut.data_i   <= 0
    dut.rrst_i <= 1
    dut.ren_i  <= 0
    yield ClockCycles(dut.wclk_i, 3)
    dut.wrst_i <= 0
    dut.rrst_i <= 0
    yield RisingEdge(dut.rclk_i)
    dut._log.info("Reset complete")

@cocotb.coroutine
def test_signaling(dut):
    dut._log.info("* Testing signaling")
    yield RisingEdge(dut.wclk_i)
    dut._log.info("Starting state")
    assert_write(dut, 0, afull=0, full=0, over=0)
    assert_read(dut, 0, valid=0, aempty=1, empty=1, under=0)
    #
    dut._log.info("Write side")
    dut.wen_i <= 1
    dut.data_i  <= 0x11
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 1, afull=0, full=0, over=0)
    dut.wen_i <= 1
    dut.data_i  <= 0x22
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 2, afull=0, full=0, over=0)
    dut.wen_i <= 1
    dut.data_i  <= 0x33
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 3, afull=1, full=0, over=0)
    dut.wen_i <= 1
    dut.data_i  <= 0x44
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 4, afull=1, full=1, over=0)
    dut.wen_i <= 0
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 5, afull=1, full=1, over=0)
    dut.wen_i <= 1
    dut.data_i  <= 0x55
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 6, afull=1, full=1, over=1)
    dut.wen_i <= 0
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 7, afull=1, full=1, over=0)
    dut.wen_i <= 1
    dut.data_i  <= 0x66
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 8, afull=1, full=1, over=1)
    dut.wen_i <= 1
    dut.data_i  <= 0x77
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 9, afull=1, full=1, over=1)
    dut.wen_i <= 0
    yield RisingEdge(dut.wclk_i)
    assert_write(dut, 10, afull=1, full=1, over=0)
    yield RisingEdge(dut.wclk_i)
    #
    dut._log.info("Read side")
    assert_read(dut, 1, valid=0, aempty=0, empty=0, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 2, valid=0, aempty=0, empty=0, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 3, valid=1, aempty=0, empty=0, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 4, valid=1, aempty=1, empty=0, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 5, valid=1, aempty=1, empty=1, under=0)
    dut.ren_i <= 0
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 6, valid=1, aempty=1, empty=1, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 7, valid=0, aempty=1, empty=1, under=1)
    dut.ren_i <= 0
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 8, valid=0, aempty=1, empty=1, under=0)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 9, valid=0, aempty=1, empty=1, under=1)
    dut.ren_i <= 1
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 10, valid=0, aempty=1, empty=1, under=1)
    dut.ren_i <= 0
    yield RisingEdge(dut.rclk_i)
    assert_read(dut, 11, valid=0, aempty=1, empty=1, under=0)
    yield RisingEdge(dut.rclk_i)

@cocotb.coroutine
def test_running(dut):
    global wr_busy
    global rd_busy
    wr_busy = 1
    rd_busy = 1
    dut._log.info("* Testing running")
    yield RisingEdge(dut.wclk_i)
    cocotb.fork(write_fifo(dut))
    cocotb.fork(read_fifo(dut))
    timeout = 1000
    while (wr_busy or rd_busy) and timeout:
       yield RisingEdge(dut.wclk_i)
       timeout = timeout - 1
    do_assert(timeout,"TimeOut")

@cocotb.coroutine
def write_fifo(dut):
    global wr_busy
    cnt = 0
    while (cnt < 256):
       do_assert(dut.overflow_o == 0, "There was a FIFO overflow writing")
       if dut.full_o == 0:
          dut.wen_i <= 1
          dut.data_i  <= cnt
          cnt = cnt + 1
       yield RisingEdge(dut.wclk_i)
       dut.wen_i <= 0
    wr_busy = 0

@cocotb.coroutine
def read_fifo(dut):
    global rd_busy
    cnt = 0
    while (cnt < 256):
       do_assert(dut.underflow_o == 0, "There was a FIFO overflow reading")
       if dut.empty_o == 0:
          dut.ren_i <= 1
       if dut.valid_o == 1:
          do_assert(dut.data_o == cnt, "DATA_O=%d when %d awaited" % (dut.data_o, cnt))
          cnt = cnt + 1
       yield RisingEdge(dut.rclk_i)
       dut.ren_i <= 0
    rd_busy = 0

def assert_write(dut, num, afull, full, over):
    dut._log.info("Op %d" % num)
    do_assert(dut.afull_o     == afull,  "AFULL=%d when %d awaited"     % (dut.afull_o, afull))
    do_assert(dut.full_o      == full,   "FULL=%d when %d awaited"      % (dut.full_o, full))
    do_assert(dut.overflow_o  == over,   "OVERFLOW=%d when %d awaited"  % (dut.overflow_o, over))

def assert_read(dut, num, valid, aempty, empty, under):
    dut._log.info("Op %d" % num)
    do_assert(dut.valid_o     == valid,  "VALID=%d when %d awaited"     % (dut.valid_o, valid))
    do_assert(dut.aempty_o    == aempty, "AEMPTY=%d when %d awaited"    % (dut.aempty_o, aempty))
    do_assert(dut.empty_o     == empty,  "EMPTY=%d when %d awaited"     % (dut.empty_o, empty))
    do_assert(dut.underflow_o == under,  "UNDERFLOW=%d when %d awaited" % (dut.underflow_o, under))

def do_assert(cond, msg):
    if not cond:
       if DEBUG:
          cocotb.log.error(msg)
       else:
          raise TestFailure(msg)
