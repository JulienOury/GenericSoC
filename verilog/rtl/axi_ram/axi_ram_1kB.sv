////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2023 , Julien OURY                       
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
//
////////////////////////////////////////////////////////////////////////////

module axi_ram_1kB#(
  parameter int unsigned ID_WIDTH   = 32'd0, // AXI4+ATOP ID width
  parameter int unsigned USER_WIDTH = 32'd0  // AXI4+ATOP user width
)(

`ifdef USE_POWER_PINS
  inout  wire            vccd1             , // User area 1 1.8V supply
  inout  wire            vssd1             , // User area 1 digital ground
`endif                                     
                                           
  input  logic           clk_i             , // Clock input
  input  logic           rst_ni            , // Asynchronous reset, active low
                                           
  //AXI slave interface                    
  AXI_BUS.Slave          slv                 // AXI4+ATOP slave interface port
);


////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////

  localparam int unsigned ADDR_WIDTH     =  32'd8; // Address width, has to be less or equal than the width off the AXI address field. Determines the width of `mem_addr_o`. Has to be wide enough to emit the memory region which should be accessible.
  localparam int unsigned DATA_WIDTH     = 32'd32; // AXI4+ATOP data width.
  localparam int unsigned NUM_BANKS      =  32'd1; // Number of banks at output, must evenly divide `DATA_WIDTH`.
  localparam int unsigned BUF_DEPTH      =  32'd1; // Depth of memory response buffer. This should be equal to the memory response latency.
  localparam bit          HIDE_STRB      =   1'b0; // Hide write requests if the strb == '0
  localparam int unsigned OUT_FIFO_DEPTH =  32'd1; // Depth of output fifo/fall_through_register. Increase for asymmetric backpressure (contention) o
																					  
  localparam type         ADDR_T         =  logic [ADDR_WIDTH-1:0]            ; // Dependent parameter, do not override. Memory address type.
  localparam type         MEM_DATA_T     =  logic [DATA_WIDTH/NUM_BANKS-1:0]  ; // Dependent parameter, do not override. Memory data type.
  localparam type         MEM_STRB_T     =  logic [DATA_WIDTH/NUM_BANKS/8-1:0]; // Dependent parameter, do not override. Memory write strobe type.


////////////////////////////////////////////////////////////////////////////
// Signals declaration
////////////////////////////////////////////////////////////////////////////
  
  // Memory stream master
  logic           [NUM_BANKS-1:0]  mem_req       ; // request is valid for this bank.
  logic           [NUM_BANKS-1:0]  mem_gnt       ; // request can be granted by this bank.
  ADDR_T          [NUM_BANKS-1:0]  mem_addr      ; // byte address of the request.
  MEM_DATA_T      [NUM_BANKS-1:0]  mem_wdata     ; // write data for this bank. Valid when `mem_req_o`.
  MEM_STRB_T      [NUM_BANKS-1:0]  mem_strb      ; // byte-wise strobe (byte enable).
  axi_pkg::atop_t [NUM_BANKS-1:0]  mem_atop      ; // `axi_pkg::atop_t` signal associated with this request.
  logic           [NUM_BANKS-1:0]  mem_we        ; // write enable. Then asserted store of `mem_w_data` is requested.
  logic           [NUM_BANKS-1:0]  mem_rvalid    ; // response is valid. This module expects always a response valid for a request regardless if the request was a write or a read.
  MEM_DATA_T      [NUM_BANKS-1:0]  mem_rdata     ; // read response data.
  
  // Memory primitive
  logic           [NUM_BANKS-1:0]  mem_csb       ; // Chip select (active low)
  logic           [NUM_BANKS-1:0]  mem_web       ; // Write enable (active low)

  // Dummy bits
  logic                            dummy_busy    ;
  MEM_DATA_T      [NUM_BANKS-1:0]  dummy_mem_dout;


////////////////////////////////////////////////////////////////////////////
// AXI to MEMORY bridge
////////////////////////////////////////////////////////////////////////////
  
  axi_to_mem_intf #(
    .ADDR_WIDTH     (ADDR_WIDTH     ), // Address width, has to be less or equal than the width off the AXI address field. Determines the width of `mem_addr_o`. Has to be wide enough to emit the memory region which should be accessible.
    .DATA_WIDTH     (DATA_WIDTH     ), // AXI4+ATOP data width.
    .ID_WIDTH       (ID_WIDTH       ), // AXI4+ATOP ID width.
    .USER_WIDTH     (USER_WIDTH     ), // AXI4+ATOP USER width.
    .NUM_BANKS      (NUM_BANKS      ), // Number of banks at output, must evenly divide `DATA_WIDTH`.
    .BUF_DEPTH      (BUF_DEPTH      ), // Depth of memory response buffer. This should be equal to the memory response latency.
    .HIDE_STRB      (HIDE_STRB      ), // Hide write requests if the strb == '0
    .OUT_FIFO_DEPTH (OUT_FIFO_DEPTH ), // Depth of output fifo/fall_through_register. Increase for asymmetric backpressure (contention) on banks.
    .addr_t         (ADDR_T         ), // Dependent parameter, do not override. Memory address type.
    .mem_data_t     (MEM_DATA_T     ), // Dependent parameter, do not override. Memory data type.
    .mem_strb_t     (MEM_STRB_T     )// Dependent parameter, do not override. Memory write strobe type.
  ) inst_axi_to_mem (               
    .clk_i          (clk_i          ), // Clock input.
    .rst_ni         (rst_ni         ), // Asynchronous reset, active low.
    .busy_o         (dummy_busy     ), // The unit is busy handling an AXI4+ATOP request.
    .slv            (slv            ), // AXI4+ATOP slave interface port.
    .mem_req_o      (mem_req        ), // Memory stream master, request is valid for this bank.
    .mem_gnt_i      (mem_gnt        ), // Memory stream master, request can be granted by this bank.
    .mem_addr_o     (mem_addr       ), // Memory stream master, byte address of the request.
    .mem_wdata_o    (mem_wdata      ), // Memory stream master, write data for this bank. Valid when `mem_req_o`.
    .mem_strb_o     (mem_strb       ), // Memory stream master, byte-wise strobe (byte enable).
    .mem_atop_o     (mem_atop       ), // Memory stream master, `axi_pkg::atop_t` signal associated with this request.
    .mem_we_o       (mem_we         ), // Memory stream master, write enable. Then asserted store of `mem_w_data` is requested.
    .mem_rvalid_i   (mem_rvalid     ), // Memory stream master, response is valid. This module expects always a response valid for a request regardless if the request was a write or a read.
    .mem_rdata_i    (mem_rdata      )  // Memory stream master, read response data.
  );
  

////////////////////////////////////////////////////////////////////////////
// MEMORY
////////////////////////////////////////////////////////////////////////////
  
  //Generate response
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      mem_rvalid <= '0;
    end else begin
      mem_rvalid <= mem_req;
    end
  end
  
	for (genvar i = 0; i < NUM_BANKS; i++) begin : gen_banks
    assign mem_csb[i] = !mem_req[i];
    assign mem_web[i] = !mem_we[i] ;
		assign mem_gnt[i] = 1'b1       ;
	end
  
  sky130_sram_1kbyte_1rw1r_32x256_8 inst_mem (
  `ifdef USE_POWER_PINS
    .vccd1 (vccd1            ),
    .vssd1 (vssd1            ),
  `endif
    // Port 0: RW
    .clk0  (clk_i            ),
    .csb0  (mem_csb[0]       ),
    .web0  (mem_web[0]       ),
    .wmask0(mem_strb[0]      ),
    .addr0 (mem_addr[0]      ),
    .din0  (mem_wdata[0]     ),
    .dout0 (mem_rdata[0]     ),
    // Port 1: R (not used)
    .clk1  (1'b0             ),
    .csb1  (1'b1             ),
    .addr1 (8'b0             ),
    .dout1 (dummy_mem_dout[0])
  );

endmodule
