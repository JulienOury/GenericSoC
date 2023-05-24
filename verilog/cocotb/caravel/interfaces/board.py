import random

import cocotb
import cocotb.log
from   cocotb.triggers import FallingEdge,RisingEdge,ClockCycles,Timer
from   cocotb.handle   import SimHandleBase
 
import interfaces.common as common
from   interfaces.common import GPIO_MODE
from   interfaces.common import MASK_GPIO_CTRL
from   interfaces.common import Macros

class Board:
    def __init__(self,dut:SimHandleBase):
        self.dut         = dut

    """start carvel by insert power then reset"""
    async def start_up(self):
        await self.start_clock()
        await self.power_up()
        await self.reset()
        await self.disable_bins()
        common.fill_macros(self.dut.macros) # get macros value

    async def disable_bins(self):
        for i in range(38):
            if i in [3,4]: #CSB and SCK
                continue
            common.drive_hdl(self.dut._id(f"bin{i}_en",False),(0,0),0) 

    """"reset caravel"""
    async def reset(self):
        cocotb.log.info(f' [caravel] start resetting')
        self.dut.rst_n.value = 0
        await ClockCycles(self.dut.clk, 20)
        self.dut.rst_n.value = 1
        await ClockCycles(self.dut.clk, 1)
        cocotb.log.info(f' [caravel] finish resetting')

    """"start clock"""
    async def start_clock(self):
        cocotb.log.info(f' [caravel] start clock')
        self.dut.clk_en.value = 1

    """"stop clock"""
    async def stop_clock(self):
        cocotb.log.info(f' [caravel] stop clock')
        self.dut.clk_en.value = 0
        
    """setup the vdd and vcc power bins"""
    async def power_up(self):
        cocotb.log.info(f' [caravel] start powering up')
        self.set_vdd(0)
        self.set_vcc(0)
        await ClockCycles(self.dut.clk, 10)
        cocotb.log.info(f' [caravel] power up -> connect vdd' )
        self.set_vdd(1)
        # await ClockCycles(self.dut.clk, 10)
        cocotb.log.info(f' [caravel] power up -> connect vcc' )
        self.set_vcc(1)
        await ClockCycles(self.dut.clk, 10)

    def set_vdd(self,value:bool):
        self.dut.vddio.value   = value
        self.dut.vssio.value   = 0
        self.dut.vddio_2.value = value
        self.dut.vssio_2.value = 0
        self.dut.vdda.value    = value
        self.dut.vssa.value    = 0
        self.dut.vdda1.value   = value
        self.dut.vssa1.value   = 0
        self.dut.vdda1_2.value = value
        self.dut.vssa1_2.value = 0
        self.dut.vdda2.value   = value
        self.dut.vssa2.value   = 0

    def set_vcc(self , value:bool):
        self.dut.vccd.value    = value
        self.dut.vssd.value    = 0
        self.dut.vccd1.value   = value
        self.dut.vssd1.value   = 0
        self.dut.vccd2.value   = value
        self.dut.vssd2.value   = 0

    """return the value of mprj in bits used tp monitor the output gpios value"""
    def monitor_gpio(self,bits:tuple):
        mprj = self.dut.rst_n.value
        size = mprj.n_bits -1 #size of bins array
        mprj_out= self.dut.mprj_io.value[size - bits[0]:size - bits[1]]
        if(mprj_out.is_resolvable):
            cocotb.log.debug(f' [caravel] Monitor : mprj[{bits[0]}:{bits[1]}] = {hex(mprj_out)}')
        else:
            cocotb.log.debug(f' [caravel] Monitor : mprj[{bits[0]}:{bits[1]}] = {mprj_out}')
        return mprj_out



