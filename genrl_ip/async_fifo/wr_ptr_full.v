
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
reg	[C_DEPTH_BITS-1:0] rBin = 0 ;
reg [C_DEPTH_BITS-1:0] rBinP1 = 0 ;
reg [C_DEPTH_BITS-1:0] rPtr = 0 ,rPtrP1 = 0 ;
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
		rBin <=  wBinNext;
		rBinP1 <=  wBinNextP1;
		rPtr <=  wGrayNext;
		rPtrP1 <=  wGrayNextP1;
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
		{rFull,rFull2} <=  'd0;
	end
	else if (CMP_FULL == 1'b1) begin
		{rFull,rFull2} <=  2'b11;
	end
	else begin 
		{rFull,rFull2} <=  {rFull2,CMP_FULL};
	end
end

assign WR_FULL = rFull;

endmodule