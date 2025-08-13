module rx_data_stream_cross#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 输入的 MAC 数据流 -------------------------------------------*/
    input               wire                                    i_mac_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac_axi_data_last                , // 数据流结束标识
    /*---------------------------------------- 打时间戳信号 -------------------------------------------*/
    output              wire                                    o_mac_time_irq                      , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac_frame_seq                     , // 帧序列号
    output              wire  [7:0]                             o_timestamp_addr                    , // 打时间戳存储的 RAM 地址
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
    output              wire                                    o_mac_cross_port_link              , // 端口的连接状态
    output              wire   [1:0]                            o_mac_cross_port_speed             , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output              wire   [CROSS_DATA_WIDTH:0]             o_mac_cross_port_axi_data          , // 端口数据流，最高位表示crcerr
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac_cross_axi_data_keep          , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac_cross_axi_data_valid         , // 端口数据有效
    input               wire                                    i_mac_cross_axi_data_ready         , // 交叉总线聚合架构反压流水线信号
    output              wire                                    o_mac_cross_axi_data_last            // 数据流结束标识 
);



endmodule