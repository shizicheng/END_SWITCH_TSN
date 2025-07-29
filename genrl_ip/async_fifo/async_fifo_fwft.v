// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : async_fifo_fwft.v
// Create : 2023-08-20 17:41:28
// Revise : 2023-08-20 18:45:28
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps
module async_fifo_fwft #(
	parameter C_WIDTH         = 32   , // Data bus width
	parameter C_DEPTH         = 1024 , // Depth of the FIFO
	// Local parameters
	parameter C_REAL_DEPTH    = 2**clog2(C_DEPTH)   ,
	parameter C_DEPTH_BITS    = clog2(C_REAL_DEPTH) ,
	parameter C_DEPTH_P1_BITS = clog2(C_REAL_DEPTH+1)
	) (
	input  					RD_CLK             , // Read clock
	input  					RD_RST             , // Read synchronous reset
	input  					WR_CLK             , // Write clock
	input  					WR_RST             , // Write synchronous reset
	input  [C_WIDTH-1:0] 	WR_DATA            , // Write data input (WR_CLK)
	input  					WR_EN              , // Write enable, high active (WR_CLK)
	output [C_WIDTH-1:0] 	RD_DATA            , // Read data output (RD_CLK)
	input  					RD_EN              , // Read enable, high active (RD_CLK)
	output 					WR_FULL            , // Full condition (WR_CLK)
	output 					RD_EMPTY             // Empty condition (RD_CLK)
);

`include "functions.vh"
wire [C_WIDTH-1:0]		wData;
wire 					wRen;
wire 					wEmpty;
reg 	[1:0]			rCount;
reg 					rFifoDataValid;
reg 	[C_WIDTH-1:0]	rData;
reg 					rDataValid;
reg 	[C_WIDTH-1:0]	rCache;
reg 					rCacheVlaid;

assign RD_DATA =rData;

assign RD_EMPTY = ~rDataValid;

assign wRen = ((rCount <2 ) | RD_EN)& (~wEmpty);//(rCount <2 & (~wEmpty)) | RD_EN;


always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCount <='d0;
	end
	else begin 
		rCount <= #1 rCount + (wRen&(~wEmpty)) -((~RD_EMPTY)&RD_EN);
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rFifoDataValid <= 1'b0;
	end
	else begin 
		rFifoDataValid <= #1 wRen;
	end
end


always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rDataValid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rDataValid <= #1 1'b1;
	end
	else if (RD_EN == 1'b1 || RD_EMPTY == 1'b1) begin
		rDataValid <= #1 rCacheVlaid;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rData <= 'd0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rData <= #1 wData;
	end
	else if (RD_EN == 1'b1 || RD_EMPTY == 1'b1) begin
		rData <= #1 rCache;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCacheVlaid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rCacheVlaid <= #1 1'b0;
	end
	else if (RD_EN == 1'b1 || RD_EMPTY == 1'b1) begin
		rCacheVlaid <= #1 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EN == 1'b0 || RD_EMPTY == 1'b0)) begin
		rCacheVlaid <= #1 1'b1;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCache <= 'd0;
	end
	else if (rFifoDataValid == 1'b1) begin
		rCache <= #1 wData;
	end
end

async_fifo #(
		.C_WIDTH(C_WIDTH),
		.C_DEPTH(C_DEPTH),
		.C_REAL_DEPTH(C_REAL_DEPTH),
		.C_DEPTH_BITS(C_DEPTH_BITS),
		.C_DEPTH_P1_BITS(C_DEPTH_P1_BITS)
	) inst_async_fifo (
		.RD_CLK   (RD_CLK),
		.RD_RST   (RD_RST),
		.WR_CLK   (WR_CLK),
		.WR_RST   (WR_RST),
		.WR_DATA  (WR_DATA),
		.WR_EN    (WR_EN),
		.RD_DATA  (wData),
		.RD_EN    (wRen),
		.WR_FULL  (WR_FULL),
		.RD_EMPTY (wEmpty)
	);
endmodule

// async_fifo_fwft #(
// 	.C_WIDTH 	(32   		),
// 	.C_DEPTH 	(1024 		)
// ) u_async_fifo_fwft (
// 	.RD_CLK   	(RD_CLK   	),
// 	.RD_RST   	(RD_RST   	),
// 	.WR_CLK   	(WR_CLK   	),
// 	.WR_RST   	(WR_RST   	),
// 	.WR_DATA  	(WR_DATA  	),
// 	.WR_EN    	(WR_EN    	),
// 	.RD_DATA  	(RD_DATA  	),
// 	.RD_EN    	(RD_EN    	),
// 	.WR_FULL  	(WR_FULL  	),
// 	.RD_EMPTY 	(RD_EMPTY 	)
// );
