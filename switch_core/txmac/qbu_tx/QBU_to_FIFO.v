`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/05 21:56:26
// Design Name: 
// Module Name: fifo_to_qbu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_to_qbu#(
    parameter   AXIS_DATA_WIDTH = 'd8      
)(
    input       	wire                         		clk_125                     ,//125M内部时钟
    input       	wire                         		gmii_rx_clk                 ,//GMII接收时钟
    input       	wire                         		gmii_tx_clk                 ,//GMII发送时钟
    input       	wire                         		i_rst                       ,

    //需要gmi发送的数据
	output 			reg 								o_gmii_tx_en  				, //GMII发送数据使能信号
	output 			reg 	[AXIS_DATA_WIDTH-1:0]		o_gmii_txd    				, //GMII发送数据       

	//gmi接收到的数据
	input 			wire  								i_gmii_rx_dv  				, //GMII接收数据有效信号
	input 			wire 	[AXIS_DATA_WIDTH - 1:0] 	i_gmii_rxd    				, //GMII接收数据
				
	//发送到qbu的数据
	output 			reg  	[AXIS_DATA_WIDTH - 1:0]		o_qbu_din 				  	,//GMII接收的数据，经过时钟转换后输出到qbu
	output 			reg 	 							o_qbu_dvld 				  	,
	//qbu发送过来的数据
	input 			wire 	[AXIS_DATA_WIDTH - 1:0]		i_qbu_data  				,//qbu需要发送的数据
	input 			wire 								i_qbu_valid 				
      );


/***************parameter*************/

//fifo参数
localparam           DATAWIDTH = 'd8;//写位宽
localparam           DEPT_W = 'd64;//写深度
localparam           AL_FUL =  DEPT_W - 10;//满信号
localparam           AL_EMP =  10;  //空信号    
localparam           READ_MODE = "fwft";
localparam           FIFO_READ_LATENCY = 'd0 ;           

/***************port******************/             


/***************reg*******************/

/***************wire******************/
wire 	 			tx_empty;
wire 	 			rx_empty;

wire 		[7:0]	r_o_gmii_txd;
wire 		[7:0]	r_o_qbu_din;

wire				tx_fifo_rd_en;
wire				rx_fifo_rd_en;

reg 		[7:0]	cnt_tx; 
reg 		[7:0]	cnt_rx; 

/***************component*************/

//tx信号FIFO，进行时钟转换
    my_xpm_fifo_async #(
            .DATAWIDTH(DATAWIDTH),
            .DEPT_W(DEPT_W),
            .AL_FUL(AL_FUL),
            .AL_EMP(AL_EMP),
            .READ_MODE(READ_MODE),
            .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
        ) inst_tx_xpm_fifo_async (
            .wr_clk 				(clk_125 			),			
			.din					(i_qbu_data			),			
			.wr_en 					(i_qbu_valid 		),			
			.rd_clk 				(gmii_tx_clk 		),			
			.dout 					(r_o_gmii_txd 		),			
			.data_valid 			(			 		),			 
			.rd_en 					(tx_fifo_rd_en 		),		
			.i_rst	  				(i_rst	  			),
			.empty					(tx_empty			),		
			.full					( 					),		
			.rd_data_count			( 					),				 
			.wr_data_count			( 					),			
			.almost_empty			( 					),			
			.almost_full			( 					)				
                                 
        );


always @(posedge gmii_tx_clk) begin
	if (i_rst) begin
		o_gmii_txd<='d0;
	end
	else  begin
		o_gmii_txd<=r_o_gmii_txd;
	end
end

always @(posedge gmii_tx_clk) begin
	if (i_rst) begin
		o_gmii_tx_en<='d0;
	end
	else  begin
		o_gmii_tx_en<=tx_fifo_rd_en;
	end
end

//发送fifo先写10个数据进去再开始读
assign tx_fifo_rd_en = (~tx_empty)&&cnt_tx>'d7;

always @(posedge gmii_tx_clk) begin
	if (i_rst) begin
		cnt_tx<='d0;
	end
	else if(i_qbu_valid=='d0&&tx_empty) begin
		cnt_tx<= 'd0;
	end	
	else if(i_qbu_valid&&(cnt_tx<'d10)) begin
		cnt_tx<= cnt_tx + 'd1;
	end
end

always @(posedge clk_125) begin
	if (i_rst) begin
		o_qbu_din<='d0;
	end
	else  begin
		o_qbu_din<=r_o_qbu_din;
	end
end

always @(posedge clk_125) begin
	if (i_rst) begin
		o_qbu_dvld<='d0;
	end
	else  begin
		o_qbu_dvld<=rx_fifo_rd_en;
	end
end

//接受fifo先写10个数据进去再开始读
assign rx_fifo_rd_en = (~rx_empty)&&cnt_rx>'d7;

always @(posedge clk_125) begin
	if (i_rst) begin
		cnt_rx<='d0;
	end
	else if(i_gmii_rx_dv=='d0&&rx_empty) begin//读空了且没有输入的时候置零
		cnt_rx<= 'd0;
	end	
	else if(i_gmii_rx_dv&&(cnt_rx<'d10)) begin
		cnt_rx<= cnt_rx + 'd1;
	end
end


//rx信号FIFO，进行时钟转换
    my_xpm_fifo_async #(
            .DATAWIDTH(DATAWIDTH),
            .DEPT_W(DEPT_W),
            .AL_FUL(AL_FUL),
            .AL_EMP(AL_EMP),
            .READ_MODE(READ_MODE),
            .FIFO_READ_LATENCY(FIFO_READ_LATENCY)
        ) inst_rx_xpm_fifo_async (
            .wr_clk 				(gmii_rx_clk 		),			
			.din					(i_gmii_rxd			),			
			.wr_en 					(i_gmii_rx_dv 		),			
			.rd_clk 				(clk_125 			),			
			.dout 					(r_o_qbu_din 		),			
			.data_valid 			(			 		),			 
			.rd_en 					(rx_fifo_rd_en 		),		
			.i_rst	  				(i_rst	  			),
			.empty					(rx_empty			),		
			.full					(					),		
			.rd_data_count			(					),				 
			.wr_data_count			(					),			
			.almost_empty			(					),			
			.almost_full			(					)				
                                 
        );

/***************assign****************/
//assign o_gmii_tx_en = ~tx_empty 	;

//assign o_qbu_dvld 	= ~rx_empty 	;
/***************always****************/
/*
ila_0 instance_ila_0 (
  .clk(gmii_tx_clk), // input wire clk


  .probe0(i_gmii_rx_dv), // input wire [0:0]  probe0  
  .probe1(i_gmii_rxd  ) // input wire [7:0]  probe1
);


ila_0 instance_ila_1 (
  .clk(clk_125), // input wire clk


  .probe0(o_qbu_dvld), // input wire [0:0]  probe0  
  .probe1(o_qbu_din  ) // input wire [7:0]  probe1
);*/
endmodule
