
`timescale  1ns/1ps
module rd_ptr_empty #(
		parameter C_DEPTH_BITS = 10
	)
	(
		input 	wire 			RD_CLK,
		input 	wire 			RD_RST,
		input 	wire 			RD_EN,
		output 	wire 			RD_EMPTY,
		output 	wire [C_DEPTH_BITS-1:0]			RD_PTR,
		output 	wire [C_DEPTH_BITS-1:0]			RD_PTR_P1,
		input 	wire 			CMP_EMPTY
);



reg 					rEmpty=1;
reg 					rEmpty2=1;
reg	[C_DEPTH_BITS-1:0] rBin =0 ;
reg [C_DEPTH_BITS-1:0] rBinP1 = 0;
reg [C_DEPTH_BITS-1:0] rPtr = 0,rPtrP1 = 0;
wire [C_DEPTH_BITS-1:0]	wBinNext;
wire [C_DEPTH_BITS-1:0]	wBinNextP1;
wire [C_DEPTH_BITS-1:0]	wGrayNext,wGrayNextP1;

always @(posedge RD_CLK or posedge RD_RST) begin 
	if (RD_RST == 1'b1) begin
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

assign wBinNext = (!rEmpty)?rBin + RD_EN : rBin;
assign wBinNextP1 = (!rEmpty)?rBinP1 + RD_EN : rBinP1;

assign wGrayNext = ((wBinNext>>1)^wBinNext);
assign wGrayNextP1 = ((wBinNextP1>>1)^wBinNextP1);

assign RD_PTR = rPtr; //wGrayNext;
assign RD_PTR_P1 =rPtrP1; //wGrayNextP1;

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		{rEmpty,rEmpty2} <=  2'b11;
	end
	else if (CMP_EMPTY == 1'b1) begin
		{rEmpty,rEmpty2} <=  2'b11;
	end
	else begin 
		{rEmpty,rEmpty2} <=  {rEmpty2,CMP_EMPTY};
	end
end

assign RD_EMPTY = rEmpty;
endmodule