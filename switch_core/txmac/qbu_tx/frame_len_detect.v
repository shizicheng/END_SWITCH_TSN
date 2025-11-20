
module frame_len_detect#(
    parameter   										AXIS_DATA_WIDTH = 'd8      
)(
	input       	wire                         		i_clk                       ,
	input       	wire                         		i_rst                       ,

	input           wire    [AXIS_DATA_WIDTH - 1:0]     i_top_Emac_tx_axis_data     ,
	input           wire    [15:0]                      i_top_Emac_tx_axis_user     , //user：数据长度
	input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_top_Emac_tx_axis_keep     , //keep数据掩码
	input           wire                                i_top_Emac_tx_axis_last     ,
	input           wire                                i_top_Emac_tx_axis_valid    ,
	input           wire    [15:0]                      i_top_Emac_tx_axis_type     , //type数据类型
	output          wire                                o_top_Emac_tx_axis_ready	,

	input           wire    [AXIS_DATA_WIDTH - 1:0]     i_top_Pmac_tx_axis_data  	,
	input           wire    [15:0]                      i_top_Pmac_tx_axis_user  	,
	input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_top_Pmac_tx_axis_keep  	,
	input           wire                                i_top_Pmac_tx_axis_last  	,
	input           wire                                i_top_Pmac_tx_axis_valid 	,
	input           wire    [15:0]                      i_top_Pmac_tx_axis_type  	,
	output          wire                                o_top_Pmac_tx_axis_ready	,	

	output          wire    [AXIS_DATA_WIDTH - 1:0]     o_top_Emac_tx_axis_data     ,
	output          wire    [15:0]                      o_top_Emac_tx_axis_user     ,
	output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   o_top_Emac_tx_axis_keep     ,
	output          wire                                o_top_Emac_tx_axis_last     ,
	output          wire                                o_top_Emac_tx_axis_valid    ,
	output          wire    [15:0]                      o_top_Emac_tx_axis_type     ,
	input           wire                                i_top_Emac_tx_axis_ready	,

	output          wire    [AXIS_DATA_WIDTH - 1:0]     o_top_Pmac_tx_axis_data  	,
	output          wire    [15:0]                      o_top_Pmac_tx_axis_user  	,
	output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   o_top_Pmac_tx_axis_keep  	,
	output          wire                                o_top_Pmac_tx_axis_last  	,
	output          wire                                o_top_Pmac_tx_axis_valid 	,
	output          wire    [15:0]                      o_top_Pmac_tx_axis_type  	,
	input           wire                                i_top_Pmac_tx_axis_ready	

);

reg    						[AXIS_DATA_WIDTH - 1:0]     ri_top_Emac_tx_axis_data 	;			
reg    						[15:0]                      ri_top_Emac_tx_axis_user 	;			
reg    						[(AXIS_DATA_WIDTH/8)-1:0]   ri_top_Emac_tx_axis_keep 	;			
reg    						                            ri_top_Emac_tx_axis_last 	;			
reg    						                            ri_top_Emac_tx_axis_valid	;			
reg    						[15:0]                      ri_top_Emac_tx_axis_type 	;			
reg    						[AXIS_DATA_WIDTH - 1:0]     ri_top_Pmac_tx_axis_data 	;			
reg    						[15:0]                      ri_top_Pmac_tx_axis_user 	;			
reg    						[(AXIS_DATA_WIDTH/8)-1:0]   ri_top_Pmac_tx_axis_keep 	;			
reg    						                            ri_top_Pmac_tx_axis_last 	;			
reg    						                            ri_top_Pmac_tx_axis_valid	;			
reg    						[15:0]                      ri_top_Pmac_tx_axis_type 	;	
reg 													ri_top_Emac_tx_axis_ready	;
reg 													ri_top_Pmac_tx_axis_ready	;

reg 													r_e_pad_flag				;
reg 						[ 5:0]						r_e_pad_cnt					;
reg 													r_p_pad_flag				;
reg 						[ 5:0]						r_p_pad_cnt					;


assign 						o_top_Emac_tx_axis_data  =  r_e_pad_flag ?  (ri_top_Emac_tx_axis_valid ? ri_top_Emac_tx_axis_data  : 0) : ri_top_Emac_tx_axis_data 	;
assign 						o_top_Emac_tx_axis_user  =  r_e_pad_flag ?  'd46 : ri_top_Emac_tx_axis_user 	;
assign 						o_top_Emac_tx_axis_keep  =  r_e_pad_flag ?  (ri_top_Emac_tx_axis_valid ? ri_top_Pmac_tx_axis_keep  : 0) : ri_top_Emac_tx_axis_keep 	;
assign 						o_top_Emac_tx_axis_last  =  r_e_pad_flag ?  (r_e_pad_cnt == 'd46 - 1) : ri_top_Emac_tx_axis_last 	;
assign 						o_top_Emac_tx_axis_valid =  r_e_pad_flag ?  1'd1 : ri_top_Emac_tx_axis_valid	;
assign 						o_top_Emac_tx_axis_type  =  r_e_pad_flag ?  ri_top_Emac_tx_axis_type : ri_top_Emac_tx_axis_valid ? ri_top_Emac_tx_axis_type : 0	;
assign                      o_top_Emac_tx_axis_ready =  ri_top_Emac_tx_axis_ready  ;
assign 						o_top_Pmac_tx_axis_data  =  r_p_pad_flag ?  (ri_top_Pmac_tx_axis_valid ? ri_top_Pmac_tx_axis_data  : 0) : ri_top_Pmac_tx_axis_data 	;
assign 						o_top_Pmac_tx_axis_user  =  r_p_pad_flag ?  'd46 : ri_top_Pmac_tx_axis_user 	;
assign 						o_top_Pmac_tx_axis_keep  =  r_p_pad_flag ?  (ri_top_Pmac_tx_axis_valid ? ri_top_Pmac_tx_axis_keep  : 0) : ri_top_Pmac_tx_axis_keep 	;
assign 						o_top_Pmac_tx_axis_last  =  r_p_pad_flag ?  (r_p_pad_cnt == 'd46 - 1) : ri_top_Pmac_tx_axis_last 	;
assign 						o_top_Pmac_tx_axis_valid =  r_p_pad_flag ?  1'd1 : ri_top_Pmac_tx_axis_valid	;
assign 						o_top_Pmac_tx_axis_type  =  r_p_pad_flag ?  ri_top_Pmac_tx_axis_type : ri_top_Pmac_tx_axis_valid ? ri_top_Pmac_tx_axis_type : 0	;
assign                      o_top_Pmac_tx_axis_ready =  ri_top_Pmac_tx_axis_ready ; 

always@(posedge i_clk) begin
	ri_top_Emac_tx_axis_data 	<= i_top_Emac_tx_axis_data  ;
	ri_top_Emac_tx_axis_user 	<= i_top_Emac_tx_axis_user  ;
	ri_top_Emac_tx_axis_keep 	<= i_top_Emac_tx_axis_keep  ;
	ri_top_Emac_tx_axis_last 	<= i_top_Emac_tx_axis_last  ;
	ri_top_Emac_tx_axis_valid	<= i_top_Emac_tx_axis_valid ;
	ri_top_Emac_tx_axis_type 	<= i_top_Emac_tx_axis_type  ;
	ri_top_Pmac_tx_axis_data 	<= i_top_Pmac_tx_axis_data  ;
	ri_top_Pmac_tx_axis_user 	<= i_top_Pmac_tx_axis_user  ;
	ri_top_Pmac_tx_axis_keep 	<= i_top_Pmac_tx_axis_keep  ;
	ri_top_Pmac_tx_axis_last 	<= i_top_Pmac_tx_axis_last  ;
	ri_top_Pmac_tx_axis_valid	<= i_top_Pmac_tx_axis_valid ;
	ri_top_Pmac_tx_axis_type 	<= i_top_Pmac_tx_axis_type  ;
	ri_top_Emac_tx_axis_ready   <= i_top_Emac_tx_axis_ready ;
	ri_top_Pmac_tx_axis_ready   <= i_top_Pmac_tx_axis_ready ;
end		

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		r_e_pad_flag <= 0;
	end
	else if(r_e_pad_cnt == 'd46 - 1) begin
		r_e_pad_flag <= 0;
	end
	else if(i_top_Emac_tx_axis_user < 'd46 && i_top_Emac_tx_axis_valid == 1) begin
		r_e_pad_flag <= 1'b1;
	end
end

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		r_p_pad_flag <= 0;
	end
	else if(r_p_pad_cnt == 'd46 - 1) begin
		r_p_pad_flag <= 0;
	end
	else if(i_top_Pmac_tx_axis_user < 'd46 && i_top_Pmac_tx_axis_valid == 1) begin
		r_p_pad_flag <= 1'b1;
	end
end

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		r_e_pad_cnt <= 0;
	end
	else if(r_e_pad_cnt == 'd45) begin
		r_e_pad_cnt <= 0;
	end
	else if(r_e_pad_flag) begin
		r_e_pad_cnt <= r_e_pad_cnt + 1'b1;
	end
end

always@(posedge i_clk or posedge i_rst) begin
	if(i_rst) begin
		r_p_pad_cnt <= 0;
	end
	else if(r_p_pad_cnt == 'd45) begin
		r_p_pad_cnt <= 0;
	end
	else if(r_p_pad_flag) begin
		r_p_pad_cnt <= r_p_pad_cnt + 1'b1;
	end
end




endmodule
