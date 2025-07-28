// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : async_fifo.v
// Create : 2023-08-20 16:03:01
// Revise : 2023-08-20 16:03:28
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps

module async_fifo #(
	parameter C_WIDTH = 32,	// Data bus width
	parameter C_DEPTH = 1024,	// Depth of the FIFO
	// Local parameters
	parameter C_REAL_DEPTH = 2**clog2(C_DEPTH),
	parameter C_DEPTH_BITS = clog2(C_REAL_DEPTH),
	parameter C_DEPTH_P1_BITS = clog2(C_REAL_DEPTH+1)
)
(
	input RD_CLK,							// Read clock
	input RD_RST,							// Read synchronous reset
	input WR_CLK,						 	// Write clock
	input WR_RST,							// Write synchronous reset
	input [C_WIDTH-1:0] WR_DATA, 			// Write data input (WR_CLK)
	input WR_EN, 							// Write enable, high active (WR_CLK)
	output [C_WIDTH-1:0] RD_DATA, 			// Read data output (RD_CLK)
	input RD_EN,							// Read enable, high active (RD_CLK)
	output WR_FULL, 						// Full condition (WR_CLK)
	output RD_EMPTY 						// Empty condition (RD_CLK)
);

`include "functions.vh"

wire						wCmpEmpty;
wire						wCmpFull;
wire	[C_DEPTH_BITS-1:0]	wWrPtr;
wire	[C_DEPTH_BITS-1:0]	wRdPtr;
wire	[C_DEPTH_BITS-1:0]	wWrPtrP1;
wire	[C_DEPTH_BITS-1:0]	wRdPtrP1;


// Memory block (synthesis attributes applied to this module will
// determine the memory option).
ram_2clk_1w_1r #(.C_RAM_WIDTH(C_WIDTH), .C_RAM_DEPTH(C_REAL_DEPTH)) mem (
	.CLKA(WR_CLK),
	.ADDRA(wWrPtr),
	.WEA(WR_EN & !WR_FULL),
	.DINA(WR_DATA),
	.CLKB(RD_CLK),
	.ADDRB(wRdPtr),
	.DOUTB(RD_DATA)
);


// Compare the pointers.
async_cmp #(.C_DEPTH_BITS(C_DEPTH_BITS)) asyncCompare (
	.WR_RST(WR_RST),
	.WR_CLK(WR_CLK),
	.RD_RST(RD_RST),
	.RD_CLK(RD_CLK),
	.RD_VALID(RD_EN & !RD_EMPTY),
	.WR_VALID(WR_EN & !WR_FULL),
	.EMPTY(wCmpEmpty), 
	.FULL(wCmpFull),
	.WR_PTR(wWrPtr), 
	.WR_PTR_P1(wWrPtrP1), 
	.RD_PTR(wRdPtr), 
	.RD_PTR_P1(wRdPtrP1)
);


// Calculate empty
rd_ptr_empty #(.C_DEPTH_BITS(C_DEPTH_BITS)) rdPtrEmpty (
	.RD_EMPTY(RD_EMPTY), 
	.RD_PTR(wRdPtr),
	.RD_PTR_P1(wRdPtrP1),
	.CMP_EMPTY(wCmpEmpty), 
	.RD_EN(RD_EN),
	.RD_CLK(RD_CLK), 
	.RD_RST(RD_RST)
);


// Calculate full
wr_ptr_full #(.C_DEPTH_BITS(C_DEPTH_BITS)) wrPtrFull (
	.WR_CLK(WR_CLK), 
	.WR_RST(WR_RST),
	.WR_EN(WR_EN),
	.WR_FULL(WR_FULL), 
	.WR_PTR(wWrPtr),
	.WR_PTR_P1(wWrPtrP1),
	.CMP_FULL(wCmpFull)
);
 
endmodule