// -----------------------------------------------------------------------------
// Copyright (c) 2014-2023 All rights reserved
// -----------------------------------------------------------------------------
// Author : youkaiyuan v3eduyky@126.com
// Wechat : 15921999232
// File   : ram_2clk_1w_1r.v
// Create : 2023-08-14 15:21:16
// Revise : 2023-08-14 15:33:16
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------
`timescale  1ns/1ps

module ram_2clk_1w_1r #(
		parameter C_RAM_WIDTH = 32,
		parameter C_RAM_DEPTH = 1024
	) 
	(
		input 	wire 		CLKA,
		input	wire		CLKB,
		input 	wire 		WEA,
		input	wire 	[clog2s(C_RAM_DEPTH)-1:0]	ADDRA,
		input 	wire 	[clog2s(C_RAM_DEPTH)-1:0]	ADDRB,
		input 	wire 	[C_RAM_WIDTH -1:0]			DINA,
		output 	wire	[C_RAM_WIDTH -1:0] 			DOUTB
);
`include "functions.vh"

//localparam C_RAM_ADDR_BITS = clog2s(C_RAM_DEPTH);

reg [C_RAM_WIDTH-1:0] rRAM [C_RAM_DEPTH-1:0];
reg [C_RAM_WIDTH-1:0] rDout;


always @(posedge CLKA) begin 
	if (WEA == 1'b1) begin
		rRAM[ADDRA] <= #1 DINA;
	end
end

always @(posedge CLKB) begin 
	rDout <= #1 rRAM[ADDRB] ;
end

assign DOUTB = rDout;

endmodule