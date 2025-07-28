`timescale 1ns / 1ps


module top_fifo(
		input 		wire		clkw,
		input		wire 		clkr,
		input 		wire 		rst
    );


reg		[31:0]			wdata;
wire 	[31:0]			rdata;
wire 					wr_en;
reg 					rd_en;
wire 					full;
wire 					Empty;

reg 					wr_flag;
reg 	[15:0]			wr_cnt;
reg [15:0]				rd_cnt;



assign wr_en = wr_flag;

always @(posedge clkw) begin
	if (rst) begin
		wdata <= 0;
	end
	else if (wr_en==1) begin
		wdata <= wdata + 1;
	end
end

always @(posedge clkw) begin
	if (rst) begin
		wr_flag <= 0;
	end
	else if (wr_flag==1 && wr_cnt=='d257) begin
		wr_flag <= 0;
	end
	else if (Empty==1) begin
		wr_flag <= 1;
	end
end

always @(posedge clkw) begin
	if (rst) begin
		wr_cnt <= 0;
	end
	else if (wr_flag==1 && wr_cnt=='d257) begin
		wr_cnt <= 0;
	end
	else if (wr_flag==1) begin
		wr_cnt <= wr_cnt + 1;
	end
end

always @(posedge clkr) begin
	if (rst) begin
		rd_en <= 0;
	end
	else if (full==1) begin
		rd_en <= 1;
	end
	else if(rd_cnt == 257) begin
		rd_en <= 0;
	end
end

always @(posedge clkr) begin 
	if (rst == 1'b1) begin
		rd_cnt <='d0;
	end
	else if (rd_en == 1'b1) begin
		rd_cnt <= rd_cnt + 1'b1;
	end
	else begin 
		rd_cnt <='d0;
	end
end




async_fifo_fwft #(.C_WIDTH(32),	.C_DEPTH(256)) fifo_inst (
	.RD_CLK(clkr),			
	.RD_RST(rst),			
	.WR_CLK(clkw),			
	.WR_RST(rst),			
	.WR_DATA(wdata), 		
	.WR_EN(wr_en), 			
	.RD_DATA(rdata), 		
	.RD_EN(rd_en&(~Empty)),			
	.WR_FULL(full), 			
	.RD_EMPTY(Empty) 		
);




endmodule
