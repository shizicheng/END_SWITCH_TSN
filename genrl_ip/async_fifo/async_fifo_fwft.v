
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
	input i_rd_clk,							// Read clock
	input i_rd_rst,							// Read synchronous reset
	input i_wr_clk,						 	// Write clock
	input i_wr_rst,							// Write synchronous reset
	input [DATA_WIDTH-1:0] i_wr_data, 			// Write data input (i_wr_clk)
	input i_wr_en, 							// Write enable, high active (i_wr_clk)
	output [DATA_WIDTH-1:0] o_rd_data, 			// Read data output (i_rd_clk)
	input i_rd_en,							// Read enable, high active (i_rd_clk)
	output o_wr_full, 						// Full condition (i_wr_clk)
	output o_rd_empty, 						// Empty condition (i_rd_clk)
	output [C_DEPTH_P1_BITS-1:0] o_wr_cnt,	// Write count (i_wr_clk)
	output [C_DEPTH_P1_BITS-1:0] o_rd_cnt		// Read count (i_rd_clk)
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

assign o_rd_data = rData;

assign o_rd_empty = ~rDataValid;

assign wRen = ((rCount <2 ) | i_rd_en)& (~wEmpty);//(rCount <2 & (~wEmpty)) | i_rd_en;


always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
		rCount <='d0;
	end
	else begin 
		rCount <= rCount + (wRen&(~wEmpty)) -((~o_rd_empty)&i_rd_en);
	end
end

always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
		rFifoDataValid <= 1'b0;
	end
	else begin 
		rFifoDataValid <= wRen;
	end
end


always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
		rDataValid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (o_rd_empty == 1'b1 || i_rd_en == 1'b1)) begin
		rDataValid <= 1'b1;
	end
	else if (i_rd_en == 1'b1 || o_rd_empty == 1'b1) begin
		rDataValid <= rCacheVlaid;
	end
end

always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
		rData <= {DATA_WIDTH{1'b0}};
	end
	else if (rFifoDataValid == 1'b1 && (o_rd_empty == 1'b1 || i_rd_en == 1'b1)) begin
		rData <= wData;
	end
	else if (i_rd_en == 1'b1 || o_rd_empty == 1'b1) begin
		rData <= rCache;
	end
end

always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
		rCacheVlaid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (o_rd_empty == 1'b1 || i_rd_en == 1'b1)) begin
		rCacheVlaid <= 1'b0;
	end
	else if (i_rd_en == 1'b1 && o_rd_empty == 1'b0) begin  
		rCacheVlaid <= 1'b0;
	end
	else if (rFifoDataValid == 1'b1 && (i_rd_en == 1'b0 && o_rd_empty == 1'b0)) begin   
		rCacheVlaid <= 1'b1;
	end
end

always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
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
always @(posedge i_rd_clk) begin 
	if (i_rd_rst == 1'b1) begin
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
always @(posedge i_wr_clk) begin 
	if (i_wr_rst == 1'b1) begin
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
assign o_rd_cnt = rReadCount;
assign o_wr_cnt = rWriteCount;




// async_fifo #(
// 		.DATA_WIDTH(DATA_WIDTH),
// 		.FIFO_DEPTH(FIFO_DEPTH),
// 		.C_REAL_DEPTH(C_REAL_DEPTH),
// 		.C_DEPTH_BITS(C_DEPTH_BITS),
// 		.C_DEPTH_P1_BITS(C_DEPTH_P1_BITS),
//		.RAM_STYLE(RAM_STYLE)
// 	) inst_async_fifo (
// 		.i_rd_clk   (i_rd_clk),
// 		.i_rd_rst   (i_rd_rst),
// 		.i_wr_clk   (i_wr_clk),
// 		.i_wr_rst   (i_wr_rst),
// 		.i_wr_data  (i_wr_data),
// 		.i_wr_en    (i_wr_en),
// 		.o_rd_data  (wData),
// 		.i_rd_en    (wRen),
// 		.o_wr_full  (o_wr_full),
// 		.o_rd_empty (wEmpty)
// 	);
async_fifo #(
    .DATA_WIDTH     (DATA_WIDTH                ),
    .FIFO_DEPTH     (FIFO_DEPTH                ),
	.RAM_STYLE		(RAM_STYLE				   ) 
) u_async_fifo (
    .i_wr_rst         (i_wr_rst                ),
    .i_wr_clk         (i_wr_clk                ),
    .i_wr_en          (i_wr_en                 ),
    .i_wr_data        (i_wr_data               ),
    .o_wr_full        (o_wr_full               ),
    .o_wr_cnt         (wr_cnt_internal         ),
    
    .i_rd_rst         (i_rd_rst                ),
    .i_rd_clk         (i_rd_clk                ),
    .i_rd_en          (wRen                    ),
    .o_rd_data        (wData                   ),
    .o_rd_empty       (wEmpty                  ),
    .o_rd_cnt         (rd_cnt_internal         )
);
endmodule