//////////////////////////////////////////////////////////////////////////////////
// Company:         xxx
// Engineer:        yuqi
// 
// Create Date:     2023/07/01
// Design Name:     xxx
// Module Name:     xxx
// Project Name:    xxx
// Target Devices:  xxx
// Tool Versions:   VIVADO2017.4
// Description:     xxx
// 
// Dependencies:    xxx
// 
// Revision:     v0.1
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module verified#(
    parameter       AXIS_DATA_WIDTH     =   'd8
)(
    input           wire                                    i_clk                  ,
    input           wire                                    i_rst                  ,

    input           wire                                	i_qbu_verify_valid     ,
    input           wire                                	i_qbu_response_valid   ,

    // //verified_to_MUX
    output          wire    [AXIS_DATA_WIDTH - 1:0]     	o_qbu_verify_data      ,//数据信号  
    output          wire    [15:0]                      	o_qbu_verify_user      ,//数据信息  
    output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   	o_qbu_verify_keep      ,//数据掩码  
    output          wire                                	o_qbu_verify_last      ,//数据截至信
    output          wire                                	o_qbu_verify_valid     ,//数据有效信 
    input           wire                                	i_qbu_verify_ready     ,//准备信号
    output          wire    [7:0]                       	o_qbu_verify_smd 	   ,//SMD编码
    output          wire                                    o_qbu_verify_smd_valid ,//SMD编码

    input           wire                                    i_verify_enabled       ,
    input           wire                                    i_start_verify         ,
    input           wire                                    i_clear_verify         ,
    output 			wire 									o_verify_succ 		   ,//验证成功信号
    output 			wire 									o_verify_succ_val 	   ,//验证成功有效信号
    input           wire    [15:0]                          i_verify_timer		   ,//控制验证请求之间的等待时间
    input  			wire                                    i_verify_timer_vld     ,
    output          wire    [15:0]                          o_err_verify_cnt       ,
    output          wire                                    o_preempt_enable        //qbu功能激活成功
);



/***************function**************/

/***************parameter*************/

localparam 						CLK_TIME		=		'd125;//125M时钟

//状态机	
localparam 						IDLE 			= 	 	6'b0000_01		;	//初始状态
localparam 						SEND_VER 		= 	 	6'b0000_10		;	//发送验证帧
localparam 						WAIT 			= 	 	6'b0001_00		;	//等待回复状态
localparam 						SEND_RES 		= 	 	6'b0010_00		;	//发送回复帧
localparam 						SUCCESS 		= 	 	6'b0100_00		;	//验证成功
localparam 						FAIL 			= 	 	6'b1000_00		;	//验证失败

//SMD
localparam 						SMD_V 			=		8'h07 			;
localparam 						SMD_R 			=		8'h19 			;

/***************port******************/             

/***************mechine***************/

/***************reg*******************/
//状态机
reg  			[5:0]			state_c									;
reg  			[5:0]			state_n									;

//计数器		
reg  			[5:0]			send_0_cnt								;
reg  			[9:0]			clk_cnt 								;//时钟计数器	
reg  			[9:0]			us_cnt 									;//微秒计数器
reg  			[9:0]			ms_cnt 									;//毫秒计数器
reg  			[1:0]			s_cnt 									;//秒计数器

//状态寄存器
reg  							ver_val 								;//收到验证帧
reg  							res_val 								;//收到回复帧
reg  			[5:0]			r_state_c								;//当前状态打一拍
reg				[1:0]			verify_cnt								;

reg             [7:0]           idle_cnt                                ;
reg 			[15:0]			ri_verify_timer							;
reg                             ri_start_verify                         ;
reg                             ri_verify_enabled                       ;
reg                             ri_clear_verify                         ;
// reg             [15:0]          ri_verify_timeout                       ;
reg                             ri_verify_timer_vld                     ;
reg                             ro_preempt_enable                       ;
reg             [15:0]          ro_err_verify_cnt                       ;
/***************wire******************/
wire 							IDLE_to_SEND_VER 						;
wire 							SEND_VER_to_WAIT 						;
wire 							WAIT_to_SEND_VER						;
wire 							WAIT_to_SUCCESS			    			;
wire 							WAIT_to_SEND_RES						;
wire 							WAIT_to_FAIL    		    			;
wire 							SEND_RES_to_SUCCESS    	    			;
wire 							FAIL_to_IDLE    		    			;
wire 							SUCCESS_to_IDLE    	    				;
/***************component*************/

/***************assign****************/
//输出
assign o_R_rx_axis_ready = 'd1;
assign o_V_rx_axis_ready = 'd1;
assign o_qbu_verify_data 	 = 'd0;
assign o_qbu_verify_valid  = state_c == SEND_RES || state_c == SEND_VER ? 1 : 'b0 ;
assign o_qbu_verify_user 	 = 'd60;
assign o_qbu_verify_keep 	 = 'd1;
assign o_qbu_verify_last 	 = send_0_cnt=='d59 ? 1 : 0;
assign o_qbu_verify_smd 		 = state_c == SEND_VER ? SMD_V : state_c == SEND_RES ? SMD_R : 'b0;
assign o_qbu_verify_smd_valid     = state_c == SEND_VER || state_c == SEND_RES ;
assign o_verify_succ 	 = state_c == SUCCESS ? 1 : 0;
assign o_verify_succ_val = state_c == FAIL || state_c == SUCCESS ? 1 : 0;//此信号拉高表明验证结束了，同时也是验证结果的有效信号
assign o_preempt_enable = ro_preempt_enable;
assign o_err_verify_cnt = ro_err_verify_cnt;


// 状态机第三段：设计转移条件，命名状态机跳转为xx(现态)2xx(次态)
assign IDLE_to_SEND_VER 	 = state_c == IDLE      && ri_start_verify == 1													;
assign SEND_VER_to_WAIT 	 = state_c == SEND_VER  && send_0_cnt=='d59													;//发送60个零
// assign WAIT_to_SEND_VER		 = state_c == WAIT  	&& s_cnt == 'd3 &&	ver_val == 0 && res_val == 0 && verify_cnt <3	;//每3s去重新发送
assign WAIT_to_SEND_VER		 = state_c == WAIT  	&& ms_cnt == (ri_verify_timer - 1) &&	ver_val == 0 && res_val == 0 && verify_cnt <3	; // (test)
assign WAIT_to_SUCCESS		 = state_c == WAIT  	&& res_val == 1														;//等待的时候收到回复帧就跳
assign WAIT_to_SEND_RES		 = state_c == WAIT  	&& ver_val == 1														;//等待的时候收到验证帧就跳
// assign WAIT_to_FAIL    		 = state_c == WAIT  	&& s_cnt == 'd3 && verify_cnt ==3 && ver_val == 0 && res_val == 0	;//发送三次了没有
assign WAIT_to_FAIL    		 = state_c == WAIT  	&& ms_cnt == (ri_verify_timer - 1) && verify_cnt ==3 && ver_val == 0 && res_val == 0	; // (test)
assign SEND_RES_to_SUCCESS 	 = state_c == SEND_RES 	&& send_0_cnt =='d59						 						;//发送60个零
assign FAIL_to_IDLE    		 = state_c == FAIL  	&& ri_verify_enabled == 1 && ri_start_verify == 1                                        ;//收到重新验证信号
assign SUCCESS_to_IDLE    	 = state_c == SUCCESS   && ri_start_verify == 1                          					;//收到重新验证信号
		
assign SUCCESS_to_FAIL       = state_c == SUCCESS   && ri_clear_verify == 1                                             ;//收到验证清除信号

/***************always****************/



always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        ro_preempt_enable <= 'd0;
    end
    else if(o_verify_succ_val & o_verify_succ)begin
        ro_preempt_enable <= 1'b1;
    end
    else begin
        ro_preempt_enable <= 'd0;
    end
end

// 状态机第一段：同步时序逻辑电路，格式化描述次态寄存器搬移至现态寄存器(不需更改)
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        state_c <= ri_verify_enabled ? IDLE : FAIL;
    end
    else begin
        state_c <= state_n;
    end
end

// 状态机第二段：组合逻辑块，描述状态转移条件判断，第二段只描述状态机的架构
// 不写明状态的转移条件，方便其他人理解状态机的架构，同时也方便对状态机架构进行修改
// 使用 state_n = state_c 描述状态不变
always @(*) begin
    case(state_c)
        IDLE: begin
            if (IDLE_to_SEND_VER) begin
                state_n = SEND_VER;
            end
            else begin
                state_n = state_c;
            end
        end
        SEND_VER: begin
            if (SEND_VER_to_WAIT) begin
                state_n = WAIT;
            end
            else begin
                state_n = state_c;
            end
        end
        WAIT: begin
            if (WAIT_to_SEND_RES) begin//这个得放在第一个，因为如果同时受到验证与回复帧时，选择去输出回复帧。
                state_n = SEND_RES;
            end
            else if(WAIT_to_SUCCESS) begin
                state_n = SUCCESS;
            end
            else if(WAIT_to_FAIL) begin
                state_n = FAIL;
            end
            else if(WAIT_to_SEND_VER) begin
                state_n = SEND_VER;
            end
            else begin
                state_n = state_c;
            end
        end
        SEND_RES: begin
            if (SEND_RES_to_SUCCESS) begin
                state_n = SUCCESS;
            end
            else begin
                state_n = state_c;
            end
        end
        SUCCESS: begin
            if (SUCCESS_to_IDLE) begin
                state_n = IDLE;
            end
            else if(SUCCESS_to_FAIL) begin
                state_n = FAIL;
            end
            else begin
                state_n = state_c;
            end
        end
        FAIL: begin
            if (FAIL_to_IDLE) begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        default: begin
            state_n = IDLE;
        end
    endcase
end

//打拍

always @(posedge i_clk) begin
    ri_start_verify <= i_start_verify;
    ri_clear_verify <= i_clear_verify;
    ri_verify_timer_vld <= i_verify_timer_vld;
    ri_verify_enabled <= i_verify_enabled;
    // ri_verify_timeout <= i_verify_timeout;
end
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin 
        ri_verify_timer <= 'd10;
    end     
    else if(ri_verify_timer_vld) begin
        ri_verify_timer <= i_verify_timer;
    end
end
/*************************************
				时间计数器
*************************************/

//clk_cnt在WAIT状态下计数到1us
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        clk_cnt <= 'b0;
    end
    else if(state_c == WAIT && clk_cnt == CLK_TIME-'d1) begin
        clk_cnt <= 'b0;
    end
    else if (state_c == WAIT) begin
        clk_cnt <= clk_cnt + 1'b1;
    end
    else begin
    	clk_cnt <= 'b0;
    end
end

//us_cnt 每次计数到1us加一,到999us归零
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        us_cnt <= 'b0;
    end
    else if (state_c == WAIT && us_cnt == 'd999 && clk_cnt == CLK_TIME-'d1) begin
        us_cnt <= 'b0;
    end
    else if (state_c == WAIT && clk_cnt == CLK_TIME-'d1) begin
        us_cnt <= us_cnt + 1'b1;
    end
    else if(state_c == WAIT) begin
        us_cnt <= us_cnt;
    end
    else begin
    	us_cnt <= 'b0;
    end
end


//ms_cnt 每次计数到1ms加一,到999us归零
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ms_cnt <= 'b0;
    end
    else if (state_c == WAIT && us_cnt == 'd999 && clk_cnt == CLK_TIME-'d1 && ms_cnt == (ri_verify_timer - 1)) begin
        ms_cnt <= 'b0;
    end
    else if (state_c == WAIT && us_cnt == 'd999 && clk_cnt == CLK_TIME-'d1) begin
        ms_cnt <= ms_cnt + 1'b1;
    end
    else if (state_c == WAIT) begin
        ms_cnt <= ms_cnt;
    end
    else begin
        ms_cnt <= 'b0;
    end
end


//s_cnt 每次到1s自动加一 ，其他状态下会归零
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        s_cnt <= 'b0;
    end
    else if (state_c == WAIT && us_cnt == 'd999 && clk_cnt == CLK_TIME-'d1 && ms_cnt == 'd999) begin
        s_cnt <= s_cnt + 1'b1;
    end
    else if (state_c == WAIT) begin
        s_cnt <= s_cnt;
    end
    else begin
        s_cnt <= 'b0;
    end
end



//send_0_cnt发送数据计数器，要发送60个0，进入 SEND_RES或者SEND_VER状态开始发送
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        send_0_cnt <= 'b0;
    end
    else if (state_c==SEND_RES || state_c==SEND_VER) begin
        send_0_cnt <= send_0_cnt + 1'b1;
    end
    else if (state_c==SEND_RES || state_c==SEND_VER && send_0_cnt=='d59) begin
        send_0_cnt <= 'b0;
    end
    else begin
    	send_0_cnt <= 'b0;
    end
end

//ver_val 收到验证帧 时拉高，当重新需要验证时 在IDLE状态重新归零
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ver_val <= 'b0;
    end
    else if (state_c == IDLE) begin
        ver_val <= 'b0;
    end
    else if (i_qbu_verify_valid) begin
        ver_val <= 'b1;
    end
    else begin
    	ver_val <= ver_val;
    end
end

//res_val 收到回复帧拉高，当重新需要验证时，在IDLE状态重新归零。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        res_val <= 'b0;
    end
    else if (state_c == IDLE) begin
        res_val <= 'b0;
    end
    else if (i_qbu_response_valid) begin
        res_val <= 'b1;
    end
    else begin
    	res_val <= res_val;
    end
end

//r_state_c 当前状态打一拍
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_state_c <= 'b0;
    end
    else begin
    	r_state_c <= state_c;
    end
end

//verify_cnt 每进一次SEND_VER状态就会加一，在IDLE状态会置零
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        verify_cnt <= 'b0;
    end
    else if (state_c == IDLE) begin
        verify_cnt <= 'b0;
    end
    else if (WAIT_to_SEND_VER) begin
        verify_cnt <= verify_cnt + 1'b1;
    end
    else begin
    	verify_cnt <= verify_cnt;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_err_verify_cnt <= 'b0;
    end
    else if (WAIT_to_SEND_VER) begin
        ro_err_verify_cnt <= ro_err_verify_cnt + 1'b1;
    end
    else begin
        ro_err_verify_cnt <= ro_err_verify_cnt;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        idle_cnt <= 'b0;
    end
    else if (state_c==IDLE) begin
        idle_cnt <= idle_cnt + 1'b1;
    end
    else begin
        idle_cnt <= 'b0;
    end
end




/*
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ver_val <= 'b0;
    end
    else if () begin
        ver_val <= 'b1;
    end
    else if() begin
        ver_val <= 'b0;
    end
    else begin
    	ver_val <= 'b0;
    end
end
*/


// //ila 39 bit
// wire   [38:0]     probe0;

// assign probe0 = {
//     o_qbu_verify_data       ,
//     o_qbu_verify_user       ,
//     o_qbu_verify_keep       ,
//     o_qbu_verify_last       ,
//     o_qbu_verify_valid      ,
//     i_mux_axis_ready      ,
//     o_qbu_verify_smd             ,
//     o_qbu_verify_smd_valid         ,
//     o_verify_succ         ,
//     o_verify_succ_val      

// };

// ila_ver inst_ila_ver (
//     .i_clk(i_clk), // input wire i_clk


//     .probe0(probe0) // input wire [38:0] probe0
// );

endmodule