// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : wr_ptr_full.v
// Create : 2023-08-14 15:54:48
// Revise : 2023-08-16 15:01:05
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps
module wr_ptr_full #(
		parameter C_DEPTH_BITS = 10
	)
	(
		input 	wire 			WR_CLK,
		input 	wire 			WR_RST,
		input 	wire 			WR_EN,
		output 	wire 			WR_FULL,
		output 	wire [C_DEPTH_BITS-1:0]			WR_PTR,
		output 	wire [C_DEPTH_BITS-1:0]			WR_PTR_P1,
		input 	wire 			CMP_FULL
);

reg 					rFull=0;
reg 					rFull2=0;
reg	[C_DEPTH_BITS-1:0] rBin ;
reg [C_DEPTH_BITS-1:0] rBinP1;
reg [C_DEPTH_BITS-1:0] rPtr,rPtrP1;
wire [C_DEPTH_BITS-1:0]	wBinNext;
wire [C_DEPTH_BITS-1:0]	wBinNextP1;
wire [C_DEPTH_BITS-1:0]	wGrayNext,wGrayNextP1;

always @(posedge WR_CLK or posedge WR_RST) begin 
	if (WR_RST == 1'b1) begin
		rBin <= 'd0;
		rBinP1 <='d1;
		rPtr <= 'd0;
		rPtrP1<='d0;
	end
	else begin 
		rBin <= #1 wBinNext;
		rBinP1 <= #1 wBinNextP1;
		rPtr <= #1 wGrayNext;
		rPtrP1 <= #1 wGrayNextP1;
	end
end

assign wBinNext = (!rFull)?rBin + WR_EN : rBin;
assign wBinNextP1 = (!rFull)?rBinP1 + WR_EN : rBinP1;

assign wGrayNext = ((wBinNext>>1)^wBinNext);
assign wGrayNextP1 = ((wBinNextP1>>1)^wBinNextP1);

assign WR_PTR = rPtr; //wGrayNext;
assign WR_PTR_P1 = rPtrP1; //wGrayNextP1;

always @(posedge WR_CLK) begin 
	if (WR_RST == 1'b1) begin
		{rFull,rFull2} <= #1 'd0;
	end
	else if (CMP_FULL == 1'b1) begin
		{rFull,rFull2} <= #1 2'b11;
	end
	else begin 
		{rFull,rFull2} <= #1 {rFull2,CMP_FULL};
	end
end

assign WR_FULL = rFull;

endmodule