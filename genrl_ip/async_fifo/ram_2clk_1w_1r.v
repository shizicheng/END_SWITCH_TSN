
`timescale  1ns/1ps
module ram_2clk_1w_1r #(
		parameter C_RAM_WIDTH = 32,
		parameter C_RAM_DEPTH = 1024
	) 
	(
		input 	wire 		CLKA,
		input	wire		CLKB,
		input 	wire 		WEA,
		input 	wire 		REA,
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
		rRAM[ADDRA] <=  DINA;
	end
end

always @(posedge CLKB) begin 
	if(REA)
	rDout <=  rRAM[ADDRB] ;
end

assign DOUTB = rDout;

endmodule