`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/08/04 19:21:49
// Design Name: 
// Module Name: flow_driver
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


module flow_driver#(
    parameter                                       SIM_MODE            = "TRUE"                ,//仿真加�?//"TRUE":降低计数位宽 与过滤流量Byte , "FALSE":关闭仿真加�? 正常运行
    parameter                                       REG_DATA_WIDTH      = 32                    ,
    parameter                                       PORT_MNG_DATA_WIDTH = 128                   ,
    parameter                                       CLOCK_PERIOD        = 100_000_000       
)                                       
(                                       
    input                                           i_sys_clk                                   ,
    input                                           i_sys_rst                                   ,

    input                                           i_pluse_clk                                 ,
    input                                           i_pluse_rst                                 ,

    input   [REG_DATA_WIDTH -1:0]                   i_port_rate                                 ,//00-100M 01-1000M  10-2500M  10-10G
    input   [REG_DATA_WIDTH -1:0]                   i_flow_ctrl_select                          ,//0:100 1:50 2:25  

    output  [31:0]                                  o_recive_package                            ,//接收数据包数 
    output  [31:0]                                  o_recive_package_multi                      ,//接收数据包数  乘数
    output  [31:0]                                  o_send_package                              ,//发送数据包数量
    output  [31:0]                                  o_send_package_multi                        ,//发送数据包数量 乘数

    input  [PORT_MNG_DATA_WIDTH - 1:0]              i_flow_data                                 ,//端口数据 
    input  [(PORT_MNG_DATA_WIDTH/8) - 1:0]          i_flow_data_keep                            ,//端口数据掩码信号
    input                                           i_flow_valid                                ,//端口数据有效
    output                                          o_flow_ready                                ,//端口数据就绪信号,表示当前模块准备好接收数 
    input                                           i_flow_last                                 ,// 数据流结束标     

    output  [PORT_MNG_DATA_WIDTH - 1:0]             o_flow_data                                 ,//端口数据 
    output  [(PORT_MNG_DATA_WIDTH/8) - 1:0]         o_flow_data_keep                            ,//端口数据掩码信号
    output                                          o_flow_valid                                ,//端口数据有效
    input                                           i_flow_ready                                ,//端口数据就绪信号,表示当前模块准备好接收数 
    output                                          o_flow_last                                 // 数据流结束标    

);
    wire                                            w_pps_pluse                                 ;
    wire                                            w_pps_last                                  ;
    wire                                            w_pps_pluse_sysclk_sync                     ;
 pluse_per_second#(
        .CLOCK_PERIOD                               (CLOCK_PERIOD                               ),
        .SIM_MODE                                   (SIM_MODE                                   )
    )pluse_per_second_u0(                                                  
        .i_pluse_clk                                (i_pluse_clk                                ),//脉冲时钟
        .i_pluse_rst                                (i_pluse_rst                                ),//脉冲复位

        .i_pluse_valid                              (i_flow_valid                               ),//输入首帧 数据�?
        .o_pluse_last                               (w_pps_last                                 ),
        .o_pluse                                    (w_pps_pluse                                ) //输出脉冲信号
    );   
                   
    xpm_cdc_async_rst #(            
        .DEST_SYNC_FF                               (1                                          ),     
        .INIT_SYNC_FF                               (0                                          ),     
        .RST_ACTIVE_HIGH                            (1                                          )   
    ) pluse                                         (           
        .dest_arst                                  (w_pps_pluse_sysclk_sync                    ), 
        .dest_clk                                   (i_sys_clk                                  ),    
        .src_arst                                   (w_pps_pluse                                )     
    );

    
    flow_ctrl#(
    .SIM_MODE                                       (SIM_MODE                                   ),//仿真加�?//"TRUE":降低计数位宽 与过滤流量Byte , "FALSE":关闭仿真加�? 正常运行
    .REG_DATA_WIDTH                                 (REG_DATA_WIDTH                             ),
    .PORT_MNG_DATA_WIDTH                            (PORT_MNG_DATA_WIDTH                        )
    )flow_ctrl                                      (                                                         
    .i_sys_clk                                      (i_sys_clk                                  ),
    .i_sys_rst                                      (i_sys_rst                                  ),

    .i_pluse_clk                                    (i_pluse_clk                                ),
    .i_pluse_rst                                    (i_pluse_rst                                ),
    .i_second_pluse                                 (w_pps_pluse_sysclk_sync                    ),
    .i_second_last                                  (w_pps_last                                 ),//δͬ��
    .i_port_rate                                    (i_port_rate                                ),//00-100M 01-1000M  10-2500M  10-10G
    .i_flow_ctrl_select                             (i_flow_ctrl_select                         ),//0:100 1:50 2:25  

    .o_recive_package                               (o_recive_package                           ),//接收数据包数 
    .o_recive_package_multi                         (o_recive_package_multi                     ),//接收数据包数  乘数
    .o_send_package                                 (o_send_package                             ),//发送数据包数量
    .o_send_package_multi                           (o_send_package_multi                       ),//发送数据包数量 乘数

    .i_flow_data                                    (i_flow_data                                ),//端口数据 
    .i_flow_data_keep                               (i_flow_data_keep                           ),//端口数据掩码信号
    .i_flow_valid                                   (i_flow_valid                               ),//端口数据有效
    .o_flow_ready                                   (o_flow_ready                               ),//端口数据就绪信号,表示当前模块准备好接收数 
    .i_flow_last                                    (i_flow_last                                ),// 数据流结束标     

    .o_flow_data                                    (o_flow_data                                ),//端口数据 
    .o_flow_data_keep                               (o_flow_data_keep                           ),//端口数据掩码信号
    .o_flow_valid                                   (o_flow_valid                               ),//端口数据有效
    .i_flow_ready                                   (i_flow_ready                               ),//端口数据就绪信号,表示当前模块准备好接收数 
    .o_flow_last                                    (o_flow_last                                )// 数据流结束标    
);
endmodule
