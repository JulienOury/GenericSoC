###from   cgitb import handler
import random

import cocotb
from   cocotb.triggers import Timer
from   cocotb.triggers import NextTimeStep
from   cocotb.triggers import FallingEdge,RisingEdge,ClockCycles
from   cocotb.triggers import with_timeout
from   cocotb.log      import SimTimeContextFilter
from   cocotb.log      import SimLogFormatter
from   cocotb.result   import TestSuccess

import logging
import inspect
import os


import interfaces.board
from   interfaces.board import Board

import interfaces.hex_file_manager
from   interfaces.hex_file_manager import HexFileManager

###import interfaces.caravel
###from   interfaces.logic_analyzer import LA
###from   interfaces.caravel import GPIO_MODE, Caravel_env
###import interfaces.common as common
###from   interfaces.cpu import RiskV
###from   interfaces.defsParser import Regs

###from   cocotb.clock import Clock
###import cocotb.log
###import cocotb.simulator
###from   cocotb_coverage.coverage import *
###from   cocotb.binary import BinaryValue
###from   wb_models.housekeepingWB.housekeepingWB import HK_whiteBox
###from   tests.common_functions.Timeout import Timeout

# tests
###from tests.bitbang.bitbang_tests import *

SOFT_DIR = '../../../soft/'
BOOTLOADER_PATH   = f'{SOFT_DIR}caravel_bootloader/caravel_bootloader.hex'
HELLO_TEST_PATH   = f'{SOFT_DIR}hello_test/hello_test.hex'
FOC_TEST_PATH   = f'{SOFT_DIR}foc_test/foc_test.hex'

FLASH_PROG_PATH   = 'caravel_th.hex'
FLASH_PROG_OFFSET = 0x00800000 #8MB


# archive tests
@cocotb.test()
async def test_boot(dut):
  error = 0
  TestName = inspect.stack()[0][3]
  if not os.path.exists(f'sim/{TestName}'):
    os.mkdir(f'sim/{TestName}') # create test folder
  cocotb.log.setLevel(logging.INFO)
  
  # log file
  handler = logging.FileHandler(f"sim/{TestName}/{TestName}.log",mode='w')
  handler.addFilter(SimTimeContextFilter())
  handler.setFormatter(SimLogFormatter())
  cocotb.log.addHandler(handler)
  
  caravel_board = Board(dut)
  
  await Timer(1, units='ms')  # Attendre pendant 1 ms
  
  # Generate test program
  cocotb.log.info(f"Generate test program")
  hex_file_mng = HexFileManager(FLASH_PROG_PATH)
  hex_file_mng.generate_program_with_bootloader(BOOTLOADER_PATH, FOC_TEST_PATH, FLASH_PROG_OFFSET)
  
  # Load program file
  cocotb.log.info(f"Load program file")
  dut.reload_file.value = 0
  await NextTimeStep()
  dut.reload_file.value = 1
  await NextTimeStep()
  dut.reload_file.value = 0
  await NextTimeStep()
  
  # Start program (release caravel reset)
  cocotb.log.info(f"Start program (release caravel reset)")
  await caravel_board.start_up();
  
  #try:
  await with_timeout(RisingEdge(dut.gpio), 1, 'sec')
  #except cocotb.triggers.TimeoutError:
  #except cocotb.result.SimTimeoutError:
  #  error += 1
  
  await Timer(10, units='ms')  # Attendre pendant 10 ms
  #await Timer(1, units='sec')  # Attendre pendant 10 secondes
  
  if (error == 0): 
    raise TestSuccess(f" TEST {TestName} passed")
  else:
    raise TestFail(f" TEST {TestName} fail")
  
  coverage_db.export_to_yaml(filename="coverage.yalm")
  


###  caravelEnv = caravel.Caravel_env(dut)
###  Timeout(caravelEnv.clk,1000000,0.1)
###  la = LA(dut)
###  clock = Clock(caravelEnv.clk, 12.5, units="ns")  # Create a 10ns period clock on port clk
###  cpu = RiskV(dut)
###  cpu.cpu_force_reset()
###
###  cocotb.start_soon(clock.start())  # Start the clock
###  
###  await caravelEnv.start_up()
###  hk = HK_whiteBox(dut)
###
###  reg = Regs()
###  time_out_count =0
###
###  await ClockCycles(caravelEnv.clk, 100)
###  address = reg.get_addr('reg_wb_enable')
###  await cpu.drive_data2address(address,1)
###  address = reg.get_addr('reg_debug_2')
###  await cpu.drive_data2address(address,0xdFF0)
###  await ClockCycles(caravelEnv.clk, 10)
###  cpu.cpu_release_reset()
###  await ClockCycles(caravelEnv.clk, 10)
###   cocotb.log.info(f"[TEST][cpu_drive] debug reg1 = 0xFFF0")
###   await ClockCycles(caravelEnv.clk, 10)
###   address = reg.get_addr('reg_debug_2')
###   await cpu.drive_data2address(address,0xdFF0)
###   await ClockCycles(caravelEnv.clk, 50)
###   # address = reg.get_addr('reg_mprj_io_0')
###   # await cpu.drive_data2address(address,0x0c03)
###   cocotb.log.info(f"[TEST][cpu_drive] wait debug reg1 = 0xddd0")
###   while True: 
###     await ClockCycles(caravelEnv.clk, 1)
###     if (cpu.read_debug_reg1() == 0xddd0): 
###       break
###   cocotb.log.info(f"[TEST][cpu_drive] debug reg1 = 0xddd0")
###   
###   await ClockCycles(caravelEnv.clk, 10)
###
###   caravelEnv.print_gpios_HW_val()




