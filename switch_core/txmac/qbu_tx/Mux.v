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

module Mux#(
    parameter       AXIS_DATA_WIDTH     =   'd8
)(
    input                                                  i_clk                    ,
    input                                                  i_rst                    ,
    // Eth_to_MUX
    input          wire    [AXIS_DATA_WIDTH - 1:0]         i_eth_send_data          ,//数据信号  
    input          wire    [15:0]                          i_eth_send_user          ,//数据信息  
    input          wire    [(AXIS_DATA_WIDTH/8)-1:0]       i_eth_send_keep          ,//数据掩码  
    input          wire                                    i_eth_send_last          ,//数据截至信号
    input          wire                                    i_eth_send_valid         ,//数据有效信号 
    output         wire                                    o_eth_send_ready         ,//准备信号
    input          wire    [15:0]                          i_eth_send_type          ,//数据类型
    input          wire    [ 7:0]                          i_eth_smd                ,//SMD编码
    input          wire                                    i_eth_smd_val            ,//SMD编码有效信号
    //verified_to_Mux        
    input          wire    [AXIS_DATA_WIDTH - 1:0]         i_verify_send_data       ,//数据信号  
    input          wire    [15:0]                          i_verify_send_user       ,//数据信息  
    input          wire    [(AXIS_DATA_WIDTH/8)-1:0]       i_verify_send_keep       ,//数据掩码  
    input          wire                                    i_verify_send_last       ,//数据截至信号
    input          wire                                    i_verify_send_valid      ,//数据有效信号 
    output         wire                                    o_verify_send_ready      ,//准备信号
    input          wire    [ 7:0]                          i_verify_smd             ,//SMD编码
    input          wire                                    i_verify_smd_val         ,//SMD编码有效信号
    
    input          wire                                    i_verify_succ            ,//验证成功信号
    input          wire                                    i_verify_succ_val        ,//验证成功有效信号
     //PMAC_to_Mux
    output         wire                                    o_pmac_rx_ready          ,//此模块准备好了
    input          wire    [15:0]                          i_pmac_send_type         ,//数据类型
    input          wire    [AXIS_DATA_WIDTH-1 :0]          i_pmac_send_data         ,//数据
    input          wire                                    i_pmac_send_last         ,//数据截至信号
    input          wire                                    i_pmac_send_valid        ,//数据有效信号
    input          wire    [15:0]                          i_pmac_send_len          ,//数据长度
    input          wire    [ 7:0]                          i_pmac_smd               ,//SMD
    input          wire    [7:0]                           i_pmac_fra               ,//帧计数器
    input          wire                                    i_pmac_smd_vld           ,//SMD有效信号
    input          wire                                    i_pmac_fra_vld           ,//帧计数器有效信号
    input          wire                                    i_pmac_crc               ,//为1则为crc否则为mcrc。
    //EMAC_to_Mux
    output                                                 o_emac_rx_ready          ,//组帧模块准备好了信号
    input                  [15:0]                          i_emac_send_type         ,//协议类型（参照mac帧格式）
    input                  [AXIS_DATA_WIDTH-1 :0]          i_emac_send_data         ,//数据信号
    input                                                  i_emac_send_last         ,//最后一个数据信号
    input                                                  i_emac_send_valid        ,//数据有效信号
    input          wire                                    i_emac_smd_val           ,//SMD编码有效信号
    input          wire    [ 7:0]                          i_emac_smd               ,//SMD编码
    input          wire    [15:0]                          i_emac_send_len          ,//数据长度

    //user
    // input                  [15:0]                          i_user_set               ,//用户设置(暂定最高位为)
    // input                                                  i_user_set_val           ,//用户设置有效信号
    //Mux_to_Mac
    input                                                  i_mac_rx_ready           ,//此组帧准备好了
    output         reg     [15:0]                          o_mac_send_type          ,//数据类型
    output         reg     [AXIS_DATA_WIDTH-1 :0]          o_mac_send_data          ,//数据
    output         reg                                     o_mac_send_last          ,//数据截至信号
    output         reg                                     o_mac_send_valid         ,//数据有效信号
    output         reg     [15:0]                          o_mac_send_len           ,//数据长度
    output         reg     [7:0]                           o_mac_smd                ,//SMD
    output         reg     [7:0]                           o_mac_fra                ,//帧计数器
    output         reg                                     o_mac_smd_vld            ,//SMD有效信号
    output         reg                                     o_mac_fra_vld            ,//帧计数器有效信号
    output         reg                                     o_mac_crc                 //为1则为crc否则为mcrc

 
);


/***************function**************/

/***************parameter*************/

/***************port******************/             

/***************mechine***************/

/***************reg*******************/

/***************wire******************/
reg       [1:0]     r_set;//模式设置
/***************component*************/

/***************assign****************/
//输出
//assign          r_set                   =       i_user_set[15:14]    ;

assign          o_emac_rx_ready         =       i_mac_rx_ready       ;
assign          o_pmac_rx_ready         =       i_mac_rx_ready       ;
assign          o_verify_send_ready     =       i_mac_rx_ready       ;
assign          o_eth_send_ready        =       i_mac_rx_ready       ;

/***************always****************/

//根据判断当前的模式以及是否验证成功，以及上层模块是否发送数据来判断接收数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin  
        o_mac_send_type     <= 'b0 ;
        o_mac_send_data     <= 'b0 ;
        o_mac_send_last     <= 'b0 ;
        o_mac_send_valid    <= 'b0 ;
        o_mac_crc           <= 'b0 ;
        o_mac_send_len      <= 'b0 ;
    end
    
    else begin
        case (r_set) 
            2'b00,2'b01:  begin                            //去掉i_mac_rx_ready作为判断条件，此条件上层会自己进行判断。
                    if (i_verify_succ_val&&i_verify_succ&&i_emac_send_valid) begin//默认状态，且验证成功,且emac在发送数据
                            o_mac_send_type     <= i_emac_send_type  ;
                            o_mac_send_data     <= i_emac_send_data  ;
                            o_mac_send_last     <= i_emac_send_last  ;
                            o_mac_send_valid    <= i_emac_send_valid ;
                            o_mac_send_len      <= i_emac_send_len   ;    
                            o_mac_crc           <= 'b1               ;
                     end
                     else if(i_verify_succ_val&&i_verify_succ&&i_pmac_send_valid) begin//默认状态，且验证成功,且pmac在发送数据
                            o_mac_send_type     <= i_pmac_send_type  ;                         
                            o_mac_send_data     <= i_pmac_send_data  ;
                            o_mac_send_last     <= i_pmac_send_last  ;
                            o_mac_send_valid    <= i_pmac_send_valid ;
                            o_mac_send_len      <= i_pmac_send_len   ;
                            o_mac_crc           <= i_pmac_crc        ;
                     end
                     else if(i_verify_succ_val&&i_verify_succ==0&&i_eth_send_valid) begin//默认状态，且验证失败,转为普通模式
                            o_mac_send_type     <= i_eth_send_type  ;                         
                            o_mac_send_data     <= i_eth_send_data  ;
                            o_mac_send_last     <= i_eth_send_last  ;
                            o_mac_send_valid    <= i_eth_send_valid ;
                            o_mac_send_len      <= i_eth_send_user  ;
                            o_mac_crc           <= 'b1              ;
                     end
                     else if(i_verify_succ_val==0) begin//默认状态，还没有验证,就去验证
                            o_mac_send_type     <= 'b0                  ;                         
                            o_mac_send_data     <= i_verify_send_data   ;
                            o_mac_send_last     <= i_verify_send_last   ;
                            o_mac_send_valid    <= i_verify_send_valid  ;
                            o_mac_send_len      <= i_verify_send_user   ;
                            o_mac_crc           <= 'b1                  ;
                     end
                     else begin
                            o_mac_send_type     <= 'b0                  ;     //由原来的保持变成了置零                     
                            o_mac_send_data     <= 'b0                  ;
                            o_mac_send_last     <= 'b0                  ;
                            o_mac_send_valid    <= 'b0                  ;
                            o_mac_send_len      <= 'b0                  ; 
                            o_mac_crc           <= 'b0                  ;
                     end
                    end        
            2'b10:  begin
                    if (i_emac_send_valid) begin//QBU状态，emac在发送数据
                            o_mac_send_type     <= i_emac_send_type  ;
                            o_mac_send_data     <= i_emac_send_data  ;
                            o_mac_send_last     <= i_emac_send_last  ;
                            o_mac_send_valid    <= i_emac_send_valid ;
                            o_mac_send_len      <= i_emac_send_len   ;
                            o_mac_crc           <= 'b1               ;
                     end
                     else if(i_pmac_send_valid) begin//QBU状态，pmac在发送数据
                            o_mac_send_type     <= i_pmac_send_type  ;                         
                            o_mac_send_data     <= i_pmac_send_data  ;
                            o_mac_send_last     <= i_pmac_send_last  ;
                            o_mac_send_valid    <= i_pmac_send_valid ;
                            o_mac_send_len      <= i_pmac_send_len   ;
                            o_mac_crc           <= i_pmac_crc        ;
                     end
                     else begin
                            o_mac_send_type     <= 'b0              ; //由原来的保持变成了置零                         
                            o_mac_send_data     <= 'b0              ;
                            o_mac_send_last     <= 'b0              ;
                            o_mac_send_valid    <= 'b0              ;
                            o_mac_send_len      <= 'b0              ;
                            o_mac_crc           <= 'b0              ;
                     end
                
                    end
            2'b11:  begin
                    if(i_emac_send_valid) begin//普通状态
                            o_mac_send_type     <= i_emac_send_type  ;                         
                            o_mac_send_data     <= i_emac_send_data  ;
                            o_mac_send_last     <= i_emac_send_last  ;
                            o_mac_send_valid    <= i_emac_send_valid ;
                            o_mac_send_len      <= i_emac_send_len   ;
                            o_mac_crc           <= 'b1               ;
                     end
                     else begin
                            o_mac_send_type     <= 'b0              ;//由原来的保持变成了置零                         
                            o_mac_send_data     <= 'b0              ;
                            o_mac_send_last     <= 'b0              ;
                            o_mac_send_valid    <= 'b0              ;
                            o_mac_send_len      <= 'b0              ;
                            o_mac_crc           <= 'b0              ;
                     end
                    end
        default: begin
                            o_mac_send_type     <= o_mac_send_type  ;                         
                            o_mac_send_data     <= o_mac_send_data  ;
                            o_mac_send_last     <= o_mac_send_last  ;
                            o_mac_send_valid    <= o_mac_send_valid ;
                            o_mac_send_len      <= o_mac_send_len   ;
                            o_mac_crc           <= o_mac_crc        ;
                end
        endcase
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_set       <= 'b0  ;
    end
    else if (i_verify_succ & i_verify_succ_val) begin
        r_set       <= 'd0;//i_user_set[15:14];
    end
    else if (!i_verify_succ & i_verify_succ_val) begin
        r_set       <= 'b11;//i_user_set[15:14];
    end
    else begin
        r_set       <= r_set ;
    end
end


//当pmac发送数据以及帧计数器有效则传递帧计数器参数
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_mac_fra       <= 'b0  ;
        o_mac_fra_vld   <= 'b0  ;
    end
    else if (i_pmac_send_valid && i_pmac_fra_vld) begin
        o_mac_fra       <= i_pmac_fra;
        o_mac_fra_vld   <= i_pmac_fra_vld;
    end
    else begin
        o_mac_fra       <= 'b0  ;//由原来的保持变成了置零 
        o_mac_fra_vld   <= 'b0  ;
    end
end



//SMD数值以及有效信号，判断那种信号正在发，在判断SMD的有效信号。
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_mac_smd     <= 'b0;
        o_mac_smd_vld <= 'b0;
    end
    else if(i_eth_smd_val && i_eth_send_valid) begin//普通模式发送
        o_mac_smd     <= i_eth_smd;
        o_mac_smd_vld <= i_eth_smd_val;
    end
    else if(i_verify_smd_val&&i_verify_send_valid &&(r_set == 2'b00 || r_set == 2'b01) ) begin//验证
        o_mac_smd     <= i_verify_smd;
        o_mac_smd_vld <= i_verify_smd_val;
    end
    else if(i_emac_smd_val&&i_emac_send_valid) begin//emac
        o_mac_smd     <= i_emac_smd;
        o_mac_smd_vld <= i_emac_smd_val;
    end
    else if(i_pmac_smd_vld&&i_pmac_send_valid) begin//pmac
        o_mac_smd     <= i_pmac_smd;
        o_mac_smd_vld <= i_pmac_smd_vld;
    end
    else begin
        o_mac_smd     <= 'b0 ;//由原来的保持变成了置零 
        o_mac_smd_vld <= 'b0 ;
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


endmodule