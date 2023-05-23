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

module axi_system_manager #(
  parameter int unsigned ID_WIDTH   = 32'd0, // AXI4+ATOP ID width
  parameter int unsigned USER_WIDTH = 32'd0  // AXI4+ATOP user width
)(

`ifdef USE_POWER_PINS
  inout  wire            vccd1             , // User area 1 1.8V supply
  inout  wire            vssd1             , // User area 1 digital ground
`endif                                     
                                           
  input  logic           clk_i             , // Clock input
  input  logic           rst_ni            , // Asynchronous reset, active low
	
  output logic           proc_rst_n        , // Processor reset
                                           
  //AXI slave interface                    
  AXI_BUS.Slave          slv                 // AXI4+ATOP slave interface port
);


////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////

  localparam int unsigned ADDR_WIDTH     =  32'd8; // Address width, has to be less or equal than the width off the AXI address field. Determines the width of `mem_addr_o`. Has to be wide enough to emit the memory region which should be accessible.
  localparam int unsigned DATA_WIDTH     = 32'd32; // AXI4+ATOP data width.
  localparam int unsigned BUF_DEPTH      =  32'd1; // Depth of memory response buffer. This should be equal to the memory response latency.
  localparam bit          HIDE_STRB      =   1'b0; // Hide write requests if the strb == '0
  localparam int unsigned OUT_FIFO_DEPTH =  32'd1; // Depth of output fifo/fall_through_register. Increase for asymmetric backpressure (contention) o
																					  
  localparam type         ADDR_T         =  logic [ADDR_WIDTH-1:0]  ; // Dependent parameter, do not override. Memory address type.
  localparam type         MEM_DATA_T     =  logic [DATA_WIDTH-1:0]  ; // Dependent parameter, do not override. Memory data type.
  localparam type         MEM_STRB_T     =  logic [DATA_WIDTH/8-1:0]; // Dependent parameter, do not override. Memory write strobe type.

  localparam logic [23:0] PASSWORD       =  24'h1A2B3C;

////////////////////////////////////////////////////////////////////////////
// Signals declaration
////////////////////////////////////////////////////////////////////////////
  
  // Memory stream master
  logic           mem_req       ; // request is valid for this bank.
  logic           mem_gnt       ; // request can be granted by this bank.
  ADDR_T          mem_addr      ; // byte address of the request.
  MEM_DATA_T      mem_wdata     ; // write data for this bank. Valid when `mem_req_o`.
  MEM_STRB_T      mem_strb      ; // byte-wise strobe (byte enable).
  axi_pkg::atop_t mem_atop      ; // `axi_pkg::atop_t` signal associated with this request.
  logic           mem_we        ; // write enable. Then asserted store of `mem_w_data` is requested.
  logic           mem_rvalid    ; // response is valid. This module expects always a response valid for a request regardless if the request was a write or a read.
  MEM_DATA_T      mem_rdata     ; // read response data.

  // Dummy bits
  logic           dummy_busy    ;
  MEM_DATA_T      dummy_mem_dout;
	
	logic           proc_clear_n  ; // Processor synchronous reset


////////////////////////////////////////////////////////////////////////////
// AXI to MEMORY bridge
////////////////////////////////////////////////////////////////////////////
  
  axi_to_mem_intf #(
    .ADDR_WIDTH     (ADDR_WIDTH     ), // Address width, has to be less or equal than the width off the AXI address field. Determines the width of `mem_addr_o`. Has to be wide enough to emit the memory region which should be accessible.
    .DATA_WIDTH     (DATA_WIDTH     ), // AXI4+ATOP data width.
    .ID_WIDTH       (ID_WIDTH       ), // AXI4+ATOP ID width.
    .USER_WIDTH     (USER_WIDTH     ), // AXI4+ATOP USER width.
    .NUM_BANKS      (32'd1          ), // Number of banks at output, must evenly divide `DATA_WIDTH`.
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

  assign mem_gnt = 1'b1;
	
	//Generate response
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      proc_clear_n <= '0;
    end else begin
		  if ((mem_req    == 1'b1   )  &&
			    (mem_gnt    == 1'b1   )  &&
					(mem_we     == 1'b1   )  &&
					(mem_strb   == 4'b1111)) begin // Quad write operation
      
        if ((mem_addr[ADDR_WIDTH-1:0] == 8'h00)  &&
				    (mem_wdata[31:8] == PASSWORD            )) begin
			    proc_clear_n <= mem_wdata[0];
			  end
			
			end

    end
  end
	
	assign mem_rdata[   0] = proc_clear_n ;
	assign mem_rdata[31:1] = 31'd0        ;
	
	assign proc_rst_n = proc_clear_n && rst_ni;


endmodule
