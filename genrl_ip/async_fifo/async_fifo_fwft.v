
`timescale  1ns/1ps
module async_fifo_fwft #(
	parameter DATA_WIDTH = 360,	// Data bus width
	parameter FIFO_DEPTH = 1024,	// Depth of the FIFO
	// Local parameters
	parameter C_REAL_DEPTH = 2**clog2(FIFO_DEPTH),
	parameter C_DEPTH_P1_BITS = clog2(C_REAL_DEPTH+1),
    parameter RAM_STYLE       = 1  // RAM综合类型选择：
                                     // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                     // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快 
	) (
	input RD_CLK,							// Read clock
	input RD_RST,							// Read synchronous reset
	input WR_CLK,						 	// Write clock
	input WR_RST,							// Write synchronous reset
	input [DATA_WIDTH-1:0] WR_DATA, 			// Write data input (WR_CLK)
	input WR_EN, 							// Write enable, high active (WR_CLK)
	output [DATA_WIDTH-1:0] RD_DATA, 			// Read data output (RD_CLK)
	input RD_EN,							// Read enable, high active (RD_CLK)
	output WR_FULL, 						// Full condition (WR_CLK)
	output RD_EMPTY, 						// Empty condition (RD_CLK)
	output [C_DEPTH_P1_BITS-1:0] WR_CNT,	// Write count (WR_CLK)
	output [C_DEPTH_P1_BITS-1:0] RD_CNT		// Read count (RD_CLK)
);

`include "functions.vh"
wire [DATA_WIDTH-1:0]		wData;
wire 					wRen;
wire 					wEmpty;
wire [C_DEPTH_P1_BITS-1:0] wr_cnt_internal;  // 内部FIFO写计数
wire [C_DEPTH_P1_BITS-1:0] rd_cnt_internal;  // 内部FIFO读计数

reg 	[1:0]			rCount;
reg 					rFifoDataValid;
reg 	[DATA_WIDTH-1:0]	rData;
reg 					rDataValid;
reg 	[DATA_WIDTH-1:0]	rCache;
reg 					rCacheVlaid;

// FWFT模式下的计数器调整
reg [C_DEPTH_P1_BITS-1:0] rReadCount;    // 读端计数器调整
reg [C_DEPTH_P1_BITS-1:0] rWriteCount;   // 写端计数器调整

assign RD_DATA = rData;

assign RD_EMPTY = ~rDataValid;

assign wRen = ((rCount <2 ) | RD_EN)& (~wEmpty);//(rCount <2 & (~wEmpty)) | RD_EN;


always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCount <='d0;
	end
	else begin 
		rCount <= rCount + (wRen&(~wEmpty)) -((~RD_EMPTY)&RD_EN);
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rFifoDataValid <= 1'b0;
	end
	else begin 
		rFifoDataValid <= wRen;
	end
end


always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rDataValid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rDataValid <= 1'b1;
	end
	else if (RD_EN == 1'b1 || RD_EMPTY == 1'b1) begin
		rDataValid <= rCacheVlaid;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rData <= {DATA_WIDTH{1'b0}};
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rData <= wData;
	end
	else if (RD_EN == 1'b1 || RD_EMPTY == 1'b1) begin
		rData <= rCache;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCacheVlaid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EMPTY == 1'b1 || RD_EN == 1'b1)) begin
		rCacheVlaid <= 1'b0;
	end
	else if (RD_EN == 1'b1 && RD_EMPTY == 1'b0) begin  
		rCacheVlaid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (RD_EN == 1'b0 && RD_EMPTY == 1'b0)) begin   
		rCacheVlaid <= 1'b1;
	end
end

always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rCache <= {DATA_WIDTH{1'b0}};
	end
	else if (rFifoDataValid == 1'b1) begin
		rCache <= wData;
	end
end

//=============================================================================
// FWFT模式下的计数器调整逻辑
//=============================================================================

// 读端计数器调整
// FWFT模式下，用户看到的数据数量 = 内部FIFO数据数量 + 预读出的数据数量
always @(posedge RD_CLK) begin 
	if (RD_RST == 1'b1) begin
		rReadCount <= 'd0;
	end
	else begin
		// 根据rCount(预读数据数量)调整计数
		// rCount表示已经预读出但还没被用户读取的数据数量
		rReadCount <= rd_cnt_internal + rCount;
	end
end

// 写端计数器调整  
// 在写时钟域，需要同步读端的调整信息
reg [1:0] rCount_sync1, rCount_sync2;  // 跨时钟域同步
always @(posedge WR_CLK) begin 
	if (WR_RST == 1'b1) begin
		rCount_sync1 <= 2'd0;
		rCount_sync2 <= 2'd0;
		rWriteCount <= 'd0;
	end
	else begin
		// 两级同步器
		rCount_sync1 <= rCount;
		rCount_sync2 <= rCount_sync1;
		// 写端看到的数据数量 = 内部FIFO数据数量 + 预读出的数据数量
		rWriteCount <= wr_cnt_internal + rCount_sync2;
	end
end

// 输出赋值
assign RD_CNT = rReadCount;
assign WR_CNT = rWriteCount;




// async_fifo #(
// 		.DATA_WIDTH(DATA_WIDTH),
// 		.FIFO_DEPTH(FIFO_DEPTH),
// 		.C_REAL_DEPTH(C_REAL_DEPTH),
// 		.C_DEPTH_BITS(C_DEPTH_BITS),
// 		.C_DEPTH_P1_BITS(C_DEPTH_P1_BITS),
//		.RAM_STYLE(RAM_STYLE)
// 	) inst_async_fifo (
// 		.RD_CLK   (RD_CLK),
// 		.RD_RST   (RD_RST),
// 		.WR_CLK   (WR_CLK),
// 		.WR_RST   (WR_RST),
// 		.WR_DATA  (WR_DATA),
// 		.WR_EN    (WR_EN),
// 		.RD_DATA  (wData),
// 		.RD_EN    (wRen),
// 		.WR_FULL  (WR_FULL),
// 		.RD_EMPTY (wEmpty)
// 	);
async_fifo #(
    .DATA_WIDTH     (DATA_WIDTH                ),
    .FIFO_DEPTH     (FIFO_DEPTH                ),
	.RAM_STYLE		(RAM_STYLE				   ) 
) u_async_fifo (
    .WR_RST         (WR_RST                    ),
    .WR_CLK         (WR_CLK                    ),
    .WR_EN          (WR_EN                     ),
    .WR_DATA        (WR_DATA                   ),
    .WR_FULL        (WR_FULL                   ),
    .WR_CNT         (wr_cnt_internal           ),
    
    .RD_RST         (RD_RST                    ),
    .RD_CLK         (RD_CLK                    ),
    .RD_EN          (wRen                      ),
    .RD_DATA        (wData                     ),
    .RD_EMPTY       (wEmpty                    ),
    .RD_CNT         (rd_cnt_internal           )
);
endmodule