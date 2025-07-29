module rx_byte_stream_ctrl #(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 限流配置的寄存器接口 -------------------------------------------*/
    input               wire   [15:0]                           i_port_flowctrl_cfg_regs           , // 限流管理配置
    /*---------------------------------------- 统计寄存器输出 -------------------------------------------*/
    output              wire   [15:0]                           o_port_rx_byte_cnt                 , // 端口接收字节个数计数器值 
    output              wire   [15:0]                           o_port_rx_frame_cnt                , // 接收帧个数计数器值
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
    input               wire                                    i_mac_cross_port_link              , // 端口的连接状态
    input               wire   [1:0]                            i_mac_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input               wire   [CROSS_DATA_WIDTH:0]             i_mac_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac_cross_axi_data_valid         , // 端口数据有效
    output              wire                                    o_mac_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    input               wire                                    i_mac_cross_axi_data_last          , // 数据流结束标识 
    /*---------------------------------------- 限流后的数据流输出 -------------------------------------------*/
    output              wire                                    o_stream_port_link                 , // 端口的连接状态
    output              wire   [1:0]                            o_stream_port_speed                , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_stream_port_axi_data             , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_stream_axi_data_keep             , // 端口数据流掩码，有效字节指示
    output              wire                                    o_stream_axi_data_valid            ,  // 端口数据有效 
    output              wire                                    o_stream_axi_data_last                           
);


endmodule