`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/07/22 22:30:39
// Design Name: 
// Module Name: flow_ctrl
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
// 后级模块 ready 信号情况可能还需要考虑
//////////////////////////////////////////////////////////////////////////////////
module flow_ctrl#(
    parameter                                       SIM_MODE            = "TRUE"                    ,//仿真加速： "TRUE"  正常运行 �? "FALSE" 
    parameter                                       REG_DATA_WIDTH      = 32                        ,
    parameter                                       PORT_MNG_DATA_WIDTH = 128                       ,
    parameter                                       CLOCK_PERIOD        = 100_000_000           
)                                           
(                                           
    input                                           i_sys_clk                                       ,
    input                                           i_sys_rst                                       ,

    input                                           i_pluse_clk                                     ,//50 100 200 250 
    input                                           i_pluse_rst                                     ,

    input                                           i_second_pluse                                  ,
    input                                           i_second_last                                   ,

    input   [REG_DATA_WIDTH -1:0]                   i_port_rate                                     ,//00-100M 01-1000M  10-2500M  10-10G
    input   [REG_DATA_WIDTH -1:0]                   i_flow_ctrl_select                              ,//0:100 1:50 2:25  

    output  [31:0]                                  o_recive_package                                ,//接收数据包数 
    output  [31:0]                                  o_recive_package_multi                          ,//接收数据包数  乘数
    output  [31:0]                                  o_send_package                                  ,//发送数据包数量
    output  [31:0]                                  o_send_package_multi                            ,//发送数据包数量 乘数

    input  [PORT_MNG_DATA_WIDTH - 1:0]              i_flow_data                                     ,//端口数据 
    input  [(PORT_MNG_DATA_WIDTH/8) - 1:0]          i_flow_data_keep                                ,//端口数据掩码信号
    input                                           i_flow_valid                                    ,//端口数据有效
    output                                          o_flow_ready                                    ,//端口数据就绪信号,表示当前模块准备好接收数 
    input                                           i_flow_last                                     ,// 数据流结束标     

    output  [PORT_MNG_DATA_WIDTH - 1:0]             o_flow_data                                     ,//端口数据 
    output  [(PORT_MNG_DATA_WIDTH/8) - 1:0]         o_flow_data_keep                                ,//端口数据掩码信号
    output                                          o_flow_valid                                    ,//端口数据有效
    input                                           i_flow_ready                                    ,//端口数据就绪信号,表示当前模块准备好接收数 
    output                                          o_flow_last                                     // 数据流结束标    

);
    localparam   CNT_WIDTH       = (SIM_MODE == "TRUE") ?              2        :  32               ;
    localparam   SPEED_100M      = (SIM_MODE == "TRUE") ?              4000     :  12_500_000       ; 
    localparam   SPEED_1G        = (SIM_MODE == "TRUE") ?              8000     :  125_000_000      ; 
    localparam   SPEED_2_5G      = (SIM_MODE == "TRUE") ?              16000    :  312_500_000      ; 
    localparam   SPEED_10G       = (SIM_MODE == "TRUE") ?              32000    :  1250_000_000     ; 
    

    reg [PORT_MNG_DATA_WIDTH - 1:0]                     ri_flow_data                                ;  
    reg [(PORT_MNG_DATA_WIDTH/8) - 1:0]                 ri_flow_data_keep                           ;
    reg                                                 ri_flow_valid                               ;   
    reg                                                 ri_flow_last                                ;
    reg                                                 ri_second_pluse                             ;
    reg                                                 r_pluse_run                                 ;
    reg     [2:0]                                       r_power_up                                  ;
    reg     [2:0]                                       r_flow_ctrl_select                          ;

    reg     [31:0]                                      r_speed_byte                                ;//对应速率 Byte 
    reg     [31:0]                                      r_flow_ctrl_num                             ;//流控  Byte 
    reg     [31:0]                                      r_recive_byte                               ;//已经接收字节
    reg                                                 r_send_data_stop                            ;//停止发送数 
    reg                                                 r_send_data_stop_valid                      ;
    reg                                                 r_send_data_stop_valid_1d                   ;
    reg                                                 r_data_run                                  ;

    reg     [CNT_WIDTH -1:0]                            ro_recive_package                           ;//接收包数
    reg     [CNT_WIDTH -1:0]                            ro_recive_package_multi                     ;//接收包数 乘积
    reg     [CNT_WIDTH -1:0]                            ro_send_package                             ;//发送包
    reg     [CNT_WIDTH -1:0]                            ro_send_package_multi                       ;//发送包  乘积
    reg     [PORT_MNG_DATA_WIDTH - 1:0]                 ro_flow_data                                ;    
    reg     [(PORT_MNG_DATA_WIDTH/8) - 1:0]             ro_flow_data_keep                           ;  
    reg                                                 ro_flow_valid                               ;   
    reg                                                 ro_flow_last                                ;  

    wire                                                w_flow_run                                  ;
    wire    [2 :0]                                      w_flow_ctrl_select                          ;
    wire                                                w_flow_ctrl_select_update                   ;
    wire                                                w_data_sned_run                             ;
    wire                                                w_pluse_neg                                 ;
    wire                                                w_valid_pos                                 ;
    assign o_flow_ready                 =               1'b1                                        ;
    assign o_recive_package             =               ro_recive_package                           ;                  
    assign o_recive_package_multi       =               ro_recive_package_multi                     ;                  
    assign o_send_package               =               ro_send_package                             ;                  
    assign o_send_package_multi         =               ro_send_package_multi                       ;                  
    assign o_flow_data                  =               ro_flow_data                                ;                  
    assign o_flow_data_keep             =               ro_flow_data_keep                           ;                  
    assign o_flow_valid                 =               ro_flow_valid                               ;                  
    assign o_flow_last                  =               ro_flow_last                                ;                  


    assign w_pluse_neg                  =               !i_second_pluse & ri_second_pluse           ;
    assign w_valid_pos                  =               i_flow_valid & !ri_flow_valid               ;
    assign w_flow_run                   =               i_flow_ctrl_select[12]                      ;
    assign w_flow_ctrl_select           =               i_flow_ctrl_select[2:0]                     ;
    assign w_flow_ctrl_select_update    =               w_flow_ctrl_select != r_flow_ctrl_select    ;
    assign w_data_sned_run              =               !i_second_pluse                              ;
    localparam  SPEED_100M_num          =               2'b00                                       ;//12.5M字节
    localparam  SPEED_1G_num            =               2'b01                                       ;//125M字节
    localparam  SPEED_2_5G_num          =               2'b10                                       ;//312.5M字节
    localparam  SPEED_10G_num           =               2'b11                                       ;//1250M字节
    localparam  AXI_BYTE                =               PORT_MNG_DATA_WIDTH / 8                     ;

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)begin 
            ri_second_pluse   <= 'd0;
            ri_flow_valid     <= 'd0;
            ri_flow_data      <= 'd0;
            ri_flow_data_keep <= 'd0;
            ri_flow_valid     <= 'd0;
            ri_flow_last      <= 'd0;
        end else begin
            ri_second_pluse   <= i_second_pluse  ;
            ri_flow_valid     <= i_flow_valid    ;
            ri_flow_data      <= i_flow_data     ;
            ri_flow_data_keep <= i_flow_data_keep;
            ri_flow_valid     <= i_flow_valid    ;
            ri_flow_last      <= i_flow_last     ;
        end 
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_data_run <= 'd0;
        else if(i_flow_valid & !ri_flow_valid )
            r_data_run <= 'd0;
        else if(!w_data_sned_run & i_flow_valid)
            r_data_run <= 'd1;
        else 
            r_data_run <= r_data_run;
        end 

    //得到对应速率的字节数
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_speed_byte <= 'd0;
        else case(i_port_rate[1:0])
            SPEED_100M_num : r_speed_byte <= SPEED_100M;
            SPEED_1G_num   : r_speed_byte <= SPEED_1G  ;
            SPEED_2_5G_num : r_speed_byte <= SPEED_2_5G;
            SPEED_10G_num  : r_speed_byte <= SPEED_10G ;
            default        : r_speed_byte <= SPEED_100M;
        endcase 
    end
    //用于判断 是否修改流控等级
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_flow_ctrl_select <= 'd0;
        else 
            r_flow_ctrl_select <= w_flow_ctrl_select;
    end 
    //流控 后的  最大通过字节
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_flow_ctrl_num <= 'd0;
        else if(r_power_up == 3'b011 || w_flow_ctrl_select_update)
            r_flow_ctrl_num <= r_speed_byte >> w_flow_ctrl_select;
        else 
            r_flow_ctrl_num <= r_flow_ctrl_num;
    end 
    //复位结束 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_power_up <= 'd0;
        else 
            r_power_up <= {r_power_up[1:0],1'b1};
    end 
    // 接收字节计数 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_recive_byte <= 'd0;
        else if(!w_data_sned_run | r_send_data_stop_valid | r_data_run)//#### #### #### #### #### #### #### #### 
            r_recive_byte <= 'd0; 
        else if(r_recive_byte > r_flow_ctrl_num)
            r_recive_byte <= 'd0;
        else if(i_flow_valid & (|i_flow_data_keep) & i_flow_ready)
            r_recive_byte <= r_recive_byte + AXI_BYTE ;
        else 
            r_recive_byte <= r_recive_byte; 
    end 
    //  发送已达到流控阈�? 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop <= 'd0;
        else if(!w_data_sned_run)
            r_send_data_stop <= 'd0;
        else if(r_recive_byte > r_flow_ctrl_num)
            r_send_data_stop <= 'd1;
        else 
            r_send_data_stop <= r_send_data_stop;
    end 

    // 流控停止信号 有效信号 (防止 数据传输时被截断 )
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop_valid <= 'd0;
        else if(!w_data_sned_run)
            r_send_data_stop_valid <= 'd0;
        else if(r_send_data_stop && !i_flow_valid )
            r_send_data_stop_valid <= 'd1;
        else 
            r_send_data_stop_valid <= r_send_data_stop_valid;
    end 
    
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            r_send_data_stop_valid_1d <= 'd0;
        else 
            r_send_data_stop_valid_1d <= r_send_data_stop_valid;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_data <= 'd0;
        else 
            ro_flow_data <= ri_flow_data;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst) 
            ro_flow_data_keep <= 'd0;
        else if(!r_send_data_stop_valid & i_flow_ready  )
            ro_flow_data_keep <= ri_flow_data_keep;
        else 
            ro_flow_data_keep <= 'd0;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_valid <= 'd0;   
        else if(!r_send_data_stop_valid & i_flow_ready  & !r_data_run)
            ro_flow_valid <= ri_flow_valid;
        else 
            ro_flow_valid <= 'd0;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_flow_last <= 'd0;
        else if(ro_flow_valid)
            ro_flow_last <= ri_flow_last;
        else 
            ro_flow_last <= 'd0;
    end 


    //32bit 计数
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_recive_package <= 'd0;
        else if((&ro_recive_package) & i_flow_last)
            ro_recive_package <= 'd0;
        else if(i_flow_last)
            ro_recive_package <= ro_recive_package + 'd1;
        else 
            ro_recive_package <= ro_recive_package;
    end   

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_recive_package_multi <= 'd0;
        else if(&ro_recive_package_multi & (&ro_recive_package) & i_flow_last)
            ro_recive_package_multi <= 'd0;
        else if((&ro_recive_package) & i_flow_last)
            ro_recive_package_multi <= ro_recive_package_multi + 'd1;
        else 
            ro_recive_package_multi <= ro_recive_package_multi;
    end 

    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_send_package <= 'd0;
        else if(&(ro_send_package) & o_flow_last)
            ro_send_package <= 'd0;
        else if(o_flow_last)
            ro_send_package <= ro_send_package + 'd1;
        else 
            ro_send_package <= ro_send_package;
    end 
 
    always @(posedge i_sys_clk) begin
        if(i_sys_rst)
            ro_send_package_multi <= 'd0;
        else if(&ro_send_package_multi & (&ro_send_package) & o_flow_last)
            ro_send_package_multi <= 'd0;
        else if((&ro_send_package) & o_flow_last)
            ro_send_package_multi <= ro_send_package_multi + 'd1;
        else 
            ro_send_package_multi <= ro_send_package_multi;
    end 

endmodule 