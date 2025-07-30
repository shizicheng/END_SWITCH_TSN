// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : async_cmp.v
// Create : 2023-08-16 16:06:52
// Revise : 2023-08-16 16:35:16
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps
module async_cmp  #(
	parameter C_DEPTH_BITS = 10,
	parameter N = C_DEPTH_BITS-1
	) (
	input 	wire 			WR_RST,
	input 	wire 			WR_CLK,
	input 	wire			RD_RST,
	input 	wire			RD_CLK,
	input 	wire 			RD_VALID,
	input 	wire			WR_VALID,
	output 	wire 			FULL,
	output 	wire			EMPTY,
	input 	wire [C_DEPTH_BITS-1:0]			WR_PTR,
	input 	wire [C_DEPTH_BITS-1:0]			WR_PTR_P1,	
	input 	wire [C_DEPTH_BITS-1:0]			RD_PTR,
	input 	wire [C_DEPTH_BITS-1:0]			RD_PTR_P1	
);

wire 		wDirSet,wDirClr;
reg 		rDir=0;
wire 		wATBEmpty;
reg 		rRdValid =0;
wire 		wEmpty;
reg 		rEmpty=1;

wire 		wATBFull;
reg 		rWrVlaid=0;
wire 		wFull;
reg 		rFull=0;

//empty
assign  wDirSet = (WR_PTR[N]^RD_PTR[N-1]) & (~(WR_PTR[N-1]^RD_PTR[N]));
assign  wDirClr =  (WR_PTR[N-1]^RD_PTR[N]) & (~(WR_PTR[N]^RD_PTR[N-1]));
//PIP
always @(posedge wDirSet or posedge wDirClr) begin 
	if (wDirClr == 1'b1) begin
		rDir <= 1'b0;
	end
	else begin 
		rDir <= 1'b1;
	end
end

assign wATBEmpty = (WR_PTR == RD_PTR_P1) &&(RD_VALID|rRdValid);


always @(posedge RD_CLK) begin 
	rRdValid <= (RD_RST)?1'b0:RD_VALID;
end

assign wEmpty = (WR_PTR == RD_PTR) &&(!rDir);

always @(posedge RD_CLK) begin 
	rEmpty <= (RD_RST)? 1'b1:wEmpty;
end

assign EMPTY = wATBEmpty |	rEmpty;

//full

assign wATBFull = (WR_PTR_P1 == RD_PTR) && (WR_VALID|rWrVlaid);

always @(posedge WR_CLK) begin 
	rWrVlaid <= (WR_RST)?1'b0:WR_VALID;
end

assign wFull = (RD_PTR == WR_PTR)&&(rDir);

always @(posedge WR_CLK) begin 
	rFull <= WR_RST?1'b0:wFull;
end

assign FULL = wATBFull | rFull;

endmodule