// 出端口优先级队列内存管理

`include "synth_cmd_define.vh"

module  forward_cache_mng #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   METADATA_WIDTH          =      64       ,                   // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,                   // Mac_port_mng 数据位宽
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,                   // 支持端口优先级 FIFO 的数量
    parameter                                                   FIFO_NUM_BYTE           =      15000    ,                   // 优先级 FIFO 缓存大小(Byte)
    parameter                                                   FIFO_ADDR_WIDTH         =      14       ,                   // 优先级 FIFO 地址线位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM  // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/

    /*---------------------------------------- 特殊 IP 核接口输入 ---------------------------------------*/
`ifdef TSN_AS
    // 数据流信息 
    input               wire                                    i_as_port_link                      , // 端口的连接状态
    input               wire   [1:0]                            i_as_port_speed                     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_as_port_filter_preamble_v         , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_as_axi_data                       , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_as_axi_data_keep                  , // 端口数据流掩码，有效字节指示
    input               wire                                    i_as_axi_data_valid                 , // 端口数据有效
    input               wire   [63:0]                           i_as_axi_data_user                  , // AS 协议信息流
    output              wire                                    o_as_axi_data_ready                 , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_as_axi_data_last                  , // 数据流结束标识
`endif
`ifdef LLDP
    // 数据流信息 
    input               wire                                    i_lldp_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_lldp_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_lldp_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_lldp_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_lldp_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_lldp_axi_data_valid               , // 端口数据有效
    input               wire   [63:0]                           i_lldp_axi_data_user                , // LLDP 协议信息流
    output              wire                                    o_lldp_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_lldp_axi_data_last                , // 数据流结束标识
`endif
`ifdef TSN_CB 
    // 数据流信息 
    input               wire                                    i_cb_port_link                      , // 端口的连接状态
    input               wire   [1:0]                            i_cb_port_speed                     , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_cb_port_filter_preamble_v         , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cb_axi_data                       , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cb_axi_data_keep                  , // 端口数据流掩码，有效字节指示
    input               wire                                    i_cb_axi_data_valid                 , // 端口数据有效
    input               wire   [63:0]                           i_cb_axi_data_user                  , // CB 协议信息流
    output              wire                                    o_cb_axi_data_ready                 , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_cb_axi_data_last                  , // 数据流结束标识
`endif
    /*---------------------------------------- CROSS 数据流输入 --------------------------------------*/
    // 聚合总线输出数据流
    input               wire   [CROSS_DATA_WIDTH:0]             i_cross_rx_data                     , // 聚合总线数据流，最高位表示crcerr
    input               wire                                    i_cross_rx_data_valid               , // 聚合总线数据流有效信号
    input               wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_cross_rx_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire   [PORT_NUM - 1:0]                 o_cross_rx_data_ready               , // 下游模块反压流水线
    input               wire                                    i_mac_axi_data_last                 , // 数据流结束标识
    //聚合总线输出信息 流
    input               wire   [METADATA_WIDTH-1:0]             i_cross_metadata                    , // 聚合总线 metadata 数据
    input               wire                                    i_cross_metadata_valid              , // 聚合总线 metadata 数据有效信号
    input               wire                                    i_cross_metadata_last               , // 信息流结束标识
    output              wire                                    o_cross_metadata_ready              , // 下游模块反压流水线  
    /*---------------------------------- 端口队列管理模块的调度信息输出 ------------------------------*/
    output              wire   [PORT_FIFO_PRI_NUM-1:0]          o_tx_mac_forward_info               , // 调度相关帧信息 0:7 - 8个优先级 FIFO 的空信号
    output              wire                                    o_tx_mac_forward_info_vld           , // 调度相关帧信息使能，每发送完一个报文，触发使能信号，调度信息流走一次调度流水线 
    /*------------------------- 调度流水线的最后一级来读取特定优先级 FIFO 数据 ------------------------*/
    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_fifo_pri_rd_en                    , // 调度流水线最后一级返回读信号使能
    // 数据流信息 
    output              wire                                    o_mac_port_link                     , // 端口的连接状态
    output              wire   [1:0]                            o_mac_port_speed                    , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac_port_filter_preamble_v        , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac_axi_data                      , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac_axi_data_keep                 , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac_axi_data_valid                , // 端口数据有效
    input               wire                                    i_mac_axi_data_ready                , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac_axi_data_last                  // 数据流结束标识
);



endmodule