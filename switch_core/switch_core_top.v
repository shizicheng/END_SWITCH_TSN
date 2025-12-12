`include "synth_cmd_define.vh"

module switch_core_top#(
    parameter                                                   PORT_NUM                =      8        ,  // 交换机的端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   REG_ADDR_OFS_WIDTH      =      9        ,  
    parameter                                                   METADATA_WIDTH          =      81       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      12       ,  // 哈希计算的值的位宽
    parameter                                                   ADDR_WIDTH              =      6        ,  // 地址表的深度     
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,  // 出端口优先级个数
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
`ifdef CPU_MAC
    // RXMAC 输入接口
    input               wire                                    i_cpu_mac0_port_link                , // 端口的连接状态
    input               wire   [1:0]                            i_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cpu_mac0_axi_data                 , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    input               wire                                    i_cpu_mac0_axi_data_valid           , // 端口数据有效
    output              wire                                    o_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_cpu_mac0_axi_data_last            , // 数据流结束标识
    output              wire                                    o_rxcpu_mac0_time_irq               , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxcpu_mac0_frame_seq              , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp0_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC 输出接口                                                                                    
    output              wire                                    o_cpu_mac0_port_link                , // 端口的连接状态
    output              wire   [1:0]                            o_cpu_mac0_port_speed               , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_cpu_mac0_port_filter_preamble_v   , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_cpu_mac0_axi_data                 , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_cpu_mac0_axi_data_keep            , // 端口数据流掩码，有效字节指示
    output              wire                                    o_cpu_mac0_axi_data_valid           , // 端口数据有效
    input               wire                                    i_cpu_mac0_axi_data_ready           , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_cpu_mac0_axi_data_last            , // 数据流结束标识
    output              wire                                    o_txcpu_mac0_time_irq               , // 打时间戳中断信号
    output              wire  [7:0]                             o_txcpu_mac0_frame_seq              , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp0_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC1                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac1_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac1_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac1_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac1_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac1_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac1_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac1_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp1_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac1_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac1_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac1_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac1_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac1_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac1_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac1_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac1_axi_data_last                , // 数据流结束标识
    
    output              wire                                    o_txmac1_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac1_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp1_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC2                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac2_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac2_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac2_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac2_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac2_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac2_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp2_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac2_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac2_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac2_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac2_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac2_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac2_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac2_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac2_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac2_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac2_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp2_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC3                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac3_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac3_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac3_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac3_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac3_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac3_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp3_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac3_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac3_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac3_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac3_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac3_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac3_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac3_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac3_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac3_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac3_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp3_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC4                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac4_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac4_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac4_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac4_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac4_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac4_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp4_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac4_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac4_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac4_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac4_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac4_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac4_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac4_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac4_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac4_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac4_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp4_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC5                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac5_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac5_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac5_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac5_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac5_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac5_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp5_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac5_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac5_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac5_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac5_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac5_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac5_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac5_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac5_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac5_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac5_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp5_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC6                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac6_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac6_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac6_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac6_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac6_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac6_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp6_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac6_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac6_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac6_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac6_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac6_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac6_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac6_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac6_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac6_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac6_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp6_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
`ifdef MAC7                                                                                           
    // RXMAC                                                                                          
    input               wire                                    i_mac7_port_link                    , // 端口的连接状态
    input               wire   [1:0]                            i_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    input               wire                                    i_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac7_axi_data                     , // 端口数据流
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input               wire                                    i_mac7_axi_data_valid               , // 端口数据有效
    output              wire                                    o_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    input               wire                                    i_mac7_axi_data_last                , // 数据流结束标识
    output              wire                                    o_rxmac7_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_rxmac7_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_rxtimestamp7_addr                 , // 打时间戳存储的 RAM 地址
    // TXMAC                                                                                          
    output              wire                                    o_mac7_port_link                    , // 端口的连接状态
    output              wire   [1:0]                            o_mac7_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac7_port_filter_preamble_v       , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac7_axi_data                     , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac7_axi_data_keep                , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac7_axi_data_valid               , // 端口数据有效
    input               wire                                    i_mac7_axi_data_ready               , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac7_axi_data_last                , // 数据流结束标识
    output              wire                                    o_txmac7_time_irq                   , // 打时间戳中断信号
    output              wire  [7:0]                             o_txmac7_frame_seq                  , // 帧序列号
    output              wire  [7:0]                             o_txtimestamp7_addr                 , // 打时间戳存储的 RAM 地址
`endif                                                                                                
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    // 寄存器控制信号                                                                                 
    input               wire                                    i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                    i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                    i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口                                                                                   
    input               wire                                    i_switch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                    i_switch_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口                                                                                    
    input               wire                                    i_switch_reg_bus_rd                 , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr            , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_rd_dout_v            // 读数据有效使能
);

/*----------------------------- wire --------------------*/
`ifdef CPU_MAC 
    // RXMAC TO CROSSBAR
    wire                                    w_mac0_cross_port_link              ; // 端口的连接状态
    wire   [1:0]                            w_mac0_cross_port_speed             ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    wire   [CROSS_DATA_WIDTH:0]             w_mac0_cross_port_axi_data          ; // 端口数据流，最高位表示crcerr
    wire   [15:0]                           w_mac0_cross_port_axi_user          ; // 端口数据流掩码，有效字节指示
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ; // 端口数据有效
    wire                                    w_mac0_cross_axi_data_valid         ; // 交叉总线聚合架构反压流水线信号
    wire                                    w_mac0_cross_axi_data_ready         ; // 数据流结束标识
    wire                                    w_mac0_cross_axi_data_last          ; 
                                                                                  // 总线 metadata 数据
    wire   [METADATA_WIDTH-1:0]             w_mac0_cross_metadata               ; // 总线 metadata 数据有效信号
    wire                                    w_mac0_cross_metadata_valid         ; // 信息流结束标识
    wire                                    w_mac0_cross_metadata_last          ; // 下游模块反压流水线 
    wire                                    w_mac0_cross_metadata_ready         ; 

	wire   [CROSS_DATA_WIDTH-1:0]           w_emac0_port_axi_data               ; 
    wire   [15:0]                           w_emac0_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac0_axi_data_keep               ; 
    wire                                    w_emac0_axi_data_valid              ; 
    wire                                    w_emac0_axi_data_ready              ; 
    wire                                    w_emac0_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac0_metadata                    ; 
    wire                                    w_emac0_metadata_valid              ; 
    wire                                    w_emac0_metadata_last               ; 
    wire                                    w_emac0_metadata_ready              ; 

    wire                                     w_tx0_req                           ;
    wire                                     w_mac0_tx0_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx0_ack_rst                  ; 
    wire                                     w_mac0_tx1_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx1_ack_rst                  ; 
    wire                                     w_mac0_tx2_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx2_ack_rst                  ; 
    wire                                     w_mac0_tx3_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx3_ack_rst                  ; 
    wire                                     w_mac0_tx4_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx4_ack_rst                  ; 
    wire                                     w_mac0_tx5_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx5_ack_rst                  ; 
    wire                                     w_mac0_tx6_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx6_ack_rst                  ; 
    wire                                     w_mac0_tx7_ack                      ; 
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac0_tx7_ack_rst                  ; 
    // CB TO CROSSBAR
    //wire                                    w_cb_mac0_cross_port_link           ;
    //wire   [1:0]                            w_cb_mac0_cross_port_speed          ;
    //wire   [CROSS_DATA_WIDTH:0]             w_cb_mac0_cross_port_axi_data       ;
    //wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac0_cross_axi_data_keep       ;
    //wire                                    w_cb_mac0_cross_axi_data_valid      ;
    //wire                                    w_cb_mac0_cross_axi_data_ready      ;
    //wire                                    w_cb_mac0_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    //pmac通道数据
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac0_tx_axis_data            ; 
    wire    [15:0]                              w_pmac0_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac0_tx_axis_keep            ; 
    wire                                        w_pmac0_tx_axis_last            ; 
    wire                                        w_pmac0_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac0_ethertype               ; 
    wire                                        w_pmac0_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac0_tx_axis_data            ;
    wire    [15:0]                              w_emac0_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac0_tx_axis_keep            ;
    wire                                        w_emac0_tx_axis_last            ;
    wire                                        w_emac0_tx_axis_valid           ;
    wire    [15:0]                              w_emac0_ethertype               ;
    wire                                        w_emac0_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac0_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac0_scheduing_rst            ;
    wire                                        w_mac0_scheduing_rst_vld        ; 
`endif
`ifdef MAC1 
    // RXMAC TO CROSSBAR
    wire                                    w_mac1_cross_port_link              ; 
    wire   [1:0]                            w_mac1_cross_port_speed             ;  
    wire   [CROSS_DATA_WIDTH:0]             w_mac1_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac1_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ; 
    wire                                    w_mac1_cross_axi_data_valid         ; 
    wire                                    w_mac1_cross_axi_data_ready         ; 
    wire                                    w_mac1_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac1_cross_metadata               ; 
    wire                                    w_mac1_cross_metadata_valid         ; 
    wire                                    w_mac1_cross_metadata_last          ; 
    wire                                    w_mac1_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac1_port_axi_data               ; 
    wire   [15:0]                           w_emac1_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac1_axi_data_keep               ; 
    wire                                    w_emac1_axi_data_valid              ; 
    wire                                    w_emac1_axi_data_ready              ; 
    wire                                    w_emac1_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac1_metadata                    ; 
    wire                                    w_emac1_metadata_valid              ; 
    wire                                    w_emac1_metadata_last               ; 
    wire                                    w_emac1_metadata_ready              ; 

    wire                                     w_tx1_req                           ;
    wire                                     w_mac1_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx0_ack_rst                  ;
    wire                                     w_mac1_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx1_ack_rst                  ;
    wire                                     w_mac1_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx2_ack_rst                  ;
    wire                                     w_mac1_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx3_ack_rst                  ;
    wire                                     w_mac1_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx4_ack_rst                  ;
    wire                                     w_mac1_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx5_ack_rst                  ;
    wire                                     w_mac1_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx6_ack_rst                  ;
    wire                                     w_mac1_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac1_tx7_ack_rst                  ;

    // CB TO CROSSBAR
    //wire                                    w_cb_mac1_cross_port_link           ;
    //wire   [1:0]                            w_cb_mac1_cross_port_speed          ;
    //wire   [CROSS_DATA_WIDTH:0]             w_cb_mac1_cross_port_axi_data       ;
    //wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac1_cross_axi_data_keep       ;
    //wire                                    w_cb_mac1_cross_axi_data_valid      ;
    //wire                                    w_cb_mac1_cross_axi_data_ready      ;
    //wire                                    w_cb_mac1_cross_axi_data_last       ;

    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac1_tx_axis_data            ; 
    wire    [15:0]                              w_pmac1_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac1_tx_axis_keep            ; 
    wire                                        w_pmac1_tx_axis_last            ; 
    wire                                        w_pmac1_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac1_ethertype               ; 
    wire                                        w_pmac1_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac1_tx_axis_data            ;
    wire    [15:0]                              w_emac1_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac1_tx_axis_keep            ;
    wire                                        w_emac1_tx_axis_last            ;
    wire                                        w_emac1_tx_axis_valid           ;
    wire    [15:0]                              w_emac1_ethertype               ;
    wire                                        w_emac1_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac1_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac1_scheduing_rst            ;
    wire                                        w_mac1_scheduing_rst_vld        ; 
`endif
`ifdef MAC2 
    wire                                    w_mac2_cross_port_link              ; 
    wire   [1:0]                            w_mac2_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac2_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac2_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ; 
    wire                                    w_mac2_cross_axi_data_valid         ; 
    wire                                    w_mac2_cross_axi_data_ready         ; 
    wire                                    w_mac2_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac2_cross_metadata               ; 
    wire                                    w_mac2_cross_metadata_valid         ; 
    wire                                    w_mac2_cross_metadata_last          ; 
    wire                                    w_mac2_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac2_port_axi_data               ; 
    wire   [15:0]                           w_emac2_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac2_axi_data_keep               ; 
    wire                                    w_emac2_axi_data_valid              ; 
    wire                                    w_emac2_axi_data_ready              ; 
    wire                                    w_emac2_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac2_metadata                    ; 
    wire                                    w_emac2_metadata_valid              ; 
    wire                                    w_emac2_metadata_last               ; 
    wire                                    w_emac2_metadata_ready              ; 
 
    wire                                     w_tx2_req                           ;
    wire                                     w_mac2_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx0_ack_rst                  ;
    wire                                     w_mac2_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx1_ack_rst                  ;
    wire                                     w_mac2_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx2_ack_rst                  ;
    wire                                     w_mac2_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx3_ack_rst                  ;
    wire                                     w_mac2_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx4_ack_rst                  ;
    wire                                     w_mac2_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx5_ack_rst                  ;
    wire                                     w_mac2_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx6_ack_rst                  ;
    wire                                     w_mac2_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac2_tx7_ack_rst                  ;

    // CB TO CROSSBAR
    // wire                                    w_cb_mac2_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac2_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac2_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac2_cross_axi_data_keep       ;
    // wire                                    w_cb_mac2_cross_axi_data_valid      ;
    // wire                                    w_cb_mac2_cross_axi_data_ready      ;
    // wire                                    w_cb_mac2_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    //pmac调度数据
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac2_tx_axis_data            ; 
    wire    [15:0]                              w_pmac2_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac2_tx_axis_keep            ; 
    wire                                        w_pmac2_tx_axis_last            ; 
    wire                                        w_pmac2_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac2_ethertype               ; 
    wire                                        w_pmac2_tx_axis_ready           ;
    //emac调度数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac2_tx_axis_data            ;
    wire    [15:0]                              w_emac2_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac2_tx_axis_keep            ;
    wire                                        w_emac2_tx_axis_last            ;
    wire                                        w_emac2_tx_axis_valid           ;
    wire    [15:0]                              w_emac2_ethertype               ;
    wire                                        w_emac2_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac2_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac2_scheduing_rst            ;
    wire                                        w_mac2_scheduing_rst_vld        ; 
`endif
`ifdef MAC3 
    wire                                    w_mac3_cross_port_link              ; 
    wire   [1:0]                            w_mac3_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac3_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac3_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ; 
    wire                                    w_mac3_cross_axi_data_valid         ; 
    wire                                    w_mac3_cross_axi_data_ready         ; 
    wire                                    w_mac3_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac3_cross_metadata               ; 
    wire                                    w_mac3_cross_metadata_valid         ; 
    wire                                    w_mac3_cross_metadata_last          ; 
    wire                                    w_mac3_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac3_port_axi_data               ; 
    wire   [15:0]                           w_emac3_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac3_axi_data_keep               ; 
    wire                                    w_emac3_axi_data_valid              ; 
    wire                                    w_emac3_axi_data_ready              ; 
    wire                                    w_emac3_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac3_metadata                    ; 
    wire                                    w_emac3_metadata_valid              ; 
    wire                                    w_emac3_metadata_last               ; 
    wire                                    w_emac3_metadata_ready              ; 
    
    wire                                     w_tx3_req                           ;
    wire                                     w_mac3_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx0_ack_rst                  ;
    wire                                     w_mac3_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx1_ack_rst                  ;
    wire                                     w_mac3_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx2_ack_rst                  ;
    wire                                     w_mac3_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx3_ack_rst                  ;
    wire                                     w_mac3_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx4_ack_rst                  ;
    wire                                     w_mac3_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx5_ack_rst                  ;
    wire                                     w_mac3_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx6_ack_rst                  ;
    wire                                     w_mac3_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac3_tx7_ack_rst                  ;

    // CB TO CROSSBAR
    // wire                                    w_cb_mac3_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac3_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac3_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac3_cross_axi_data_keep       ;
    // wire                                    w_cb_mac3_cross_axi_data_valid      ;
    // wire                                    w_cb_mac3_cross_axi_data_ready      ;
    // wire                                    w_cb_mac3_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac3_tx_axis_data            ; 
    wire    [15:0]                              w_pmac3_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac3_tx_axis_keep            ; 
    wire                                        w_pmac3_tx_axis_last            ; 
    wire                                        w_pmac3_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac3_ethertype               ; 
    wire                                        w_pmac3_tx_axis_ready           ;
    //emac通道数据              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac3_tx_axis_data            ;
    wire    [15:0]                              w_emac3_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac3_tx_axis_keep            ;
    wire                                        w_emac3_tx_axis_last            ;
    wire                                        w_emac3_tx_axis_valid           ;
    wire    [15:0]                              w_emac3_ethertype               ;
    wire                                        w_emac3_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac3_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac3_scheduing_rst            ;
    wire                                        w_mac3_scheduing_rst_vld        ; 
`endif
`ifdef MAC4 
    wire                                    w_mac4_cross_port_link              ; 
    wire   [1:0]                            w_mac4_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac4_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac4_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ; 
    wire                                    w_mac4_cross_axi_data_valid         ; 
    wire                                    w_mac4_cross_axi_data_ready         ; 
    wire                                    w_mac4_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac4_cross_metadata               ; 
    wire                                    w_mac4_cross_metadata_valid         ; 
    wire                                    w_mac4_cross_metadata_last          ; 
    wire                                    w_mac4_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac4_port_axi_data               ; 
    wire   [15:0]                           w_emac4_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac4_axi_data_keep               ; 
    wire                                    w_emac4_axi_data_valid              ; 
    wire                                    w_emac4_axi_data_ready              ; 
    wire                                    w_emac4_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac4_metadata                    ; 
    wire                                    w_emac4_metadata_valid              ; 
    wire                                    w_emac4_metadata_last               ; 
    wire                                    w_emac4_metadata_ready              ; 

    
    wire                                     w_tx4_req                           ;
    wire                                     w_mac4_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx0_ack_rst                  ;
    wire                                     w_mac4_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx1_ack_rst                  ;
    wire                                     w_mac4_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx2_ack_rst                  ;
    wire                                     w_mac4_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx3_ack_rst                  ;
    wire                                     w_mac4_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx4_ack_rst                  ;
    wire                                     w_mac4_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx5_ack_rst                  ;
    wire                                     w_mac4_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx6_ack_rst                  ;
    wire                                     w_mac4_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac4_tx7_ack_rst                  ;

    // CB TO CROSSBAR
    // wire                                    w_cb_mac4_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac4_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac4_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac4_cross_axi_data_keep       ;
    // wire                                    w_cb_mac4_cross_axi_data_valid      ;
    // wire                                    w_cb_mac4_cross_axi_data_ready      ;
    // wire                                    w_cb_mac4_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac4_tx_axis_data            ; 
    wire    [15:0]                              w_pmac4_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac4_tx_axis_keep            ; 
    wire                                        w_pmac4_tx_axis_last            ; 
    wire                                        w_pmac4_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac4_ethertype               ; 
    wire                                        w_pmac4_tx_axis_ready           ;
    //emac通道数据             
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac4_tx_axis_data            ;
    wire    [15:0]                              w_emac4_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac4_tx_axis_keep            ;
    wire                                        w_emac4_tx_axis_last            ;
    wire                                        w_emac4_tx_axis_valid           ;
    wire    [15:0]                              w_emac4_ethertype               ;
    wire                                        w_emac4_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac4_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac4_scheduing_rst            ;
    wire                                        w_mac4_scheduing_rst_vld        ; 
`endif
`ifdef MAC5 
    wire                                    w_mac5_cross_port_link              ; 
    wire   [1:0]                            w_mac5_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac5_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac5_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ; 
    wire                                    w_mac5_cross_axi_data_valid         ; 
    wire                                    w_mac5_cross_axi_data_ready         ; 
    wire                                    w_mac5_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac5_cross_metadata               ; 
    wire                                    w_mac5_cross_metadata_valid         ; 
    wire                                    w_mac5_cross_metadata_last          ; 
    wire                                    w_mac5_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac5_port_axi_data               ; 
    wire   [15:0]                           w_emac5_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac5_axi_data_keep               ; 
    wire                                    w_emac5_axi_data_valid              ; 
    wire                                    w_emac5_axi_data_ready              ; 
    wire                                    w_emac5_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac5_metadata                    ; 
    wire                                    w_emac5_metadata_valid              ; 
    wire                                    w_emac5_metadata_last               ; 
    wire                                    w_emac5_metadata_ready              ; 

    
    wire                                     w_tx5_req                           ;
    wire                                     w_mac5_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx0_ack_rst                  ;
    wire                                     w_mac5_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx1_ack_rst                  ;
    wire                                     w_mac5_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx2_ack_rst                  ;
    wire                                     w_mac5_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx3_ack_rst                  ;
    wire                                     w_mac5_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx4_ack_rst                  ;
    wire                                     w_mac5_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx5_ack_rst                  ;
    wire                                     w_mac5_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx6_ack_rst                  ;
    wire                                     w_mac5_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac5_tx7_ack_rst                  ;


    // CB TO CROSSBAR
    // wire                                    w_cb_mac5_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac5_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac5_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac5_cross_axi_data_keep       ;
    // wire                                    w_cb_mac5_cross_axi_data_valid      ;
    // wire                                    w_cb_mac5_cross_axi_data_ready      ;
    // wire                                    w_cb_mac5_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac5_tx_axis_data            ; 
    wire    [15:0]                              w_pmac5_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac5_tx_axis_keep            ; 
    wire                                        w_pmac5_tx_axis_last            ; 
    wire                                        w_pmac5_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac5_ethertype               ; 
    wire                                        w_pmac5_tx_axis_ready           ;
    //emac            
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac5_tx_axis_data            ;
    wire    [15:0]                              w_emac5_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac5_tx_axis_keep            ;
    wire                                        w_emac5_tx_axis_last            ;
    wire                                        w_emac5_tx_axis_valid           ;
    wire    [15:0]                              w_emac5_ethertype               ;
    wire                                        w_emac5_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac5_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac5_scheduing_rst            ;
    wire                                        w_mac5_scheduing_rst_vld        ; 
`endif
`ifdef MAC6 
    wire                                    w_mac6_cross_port_link              ; 
    wire   [1:0]                            w_mac6_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac6_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac6_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ; 
    wire                                    w_mac6_cross_axi_data_valid         ; 
    wire                                    w_mac6_cross_axi_data_ready         ; 
    wire                                    w_mac6_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac6_cross_metadata               ; 
    wire                                    w_mac6_cross_metadata_valid         ; 
    wire                                    w_mac6_cross_metadata_last          ; 
    wire                                    w_mac6_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac6_port_axi_data               ; 
    wire   [15:0]                           w_emac6_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac6_axi_data_keep               ; 
    wire                                    w_emac6_axi_data_valid              ; 
    wire                                    w_emac6_axi_data_ready              ; 
    wire                                    w_emac6_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac6_metadata                    ; 
    wire                                    w_emac6_metadata_valid              ; 
    wire                                    w_emac6_metadata_last               ; 
    wire                                    w_emac6_metadata_ready              ; 


    wire                                     w_tx6_req                           ;
    wire                                     w_mac6_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx0_ack_rst                  ;
    wire                                     w_mac6_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx1_ack_rst                  ;
    wire                                     w_mac6_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx2_ack_rst                  ;
    wire                                     w_mac6_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx3_ack_rst                  ;
    wire                                     w_mac6_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx4_ack_rst                  ;
    wire                                     w_mac6_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx5_ack_rst                  ;
    wire                                     w_mac6_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx6_ack_rst                  ;
    wire                                     w_mac6_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac6_tx7_ack_rst                  ;


    // CB TO CROSSBAR
    // wire                                    w_cb_mac6_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac6_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac6_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac6_cross_axi_data_keep       ;
    // wire                                    w_cb_mac6_cross_axi_data_valid      ;
    // wire                                    w_cb_mac6_cross_axi_data_ready      ;
    // wire                                    w_cb_mac6_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac6_tx_axis_data            ; 
    wire    [15:0]                              w_pmac6_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac6_tx_axis_keep            ; 
    wire                                        w_pmac6_tx_axis_last            ; 
    wire                                        w_pmac6_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac6_ethertype               ; 
    wire                                        w_pmac6_tx_axis_ready           ;
    //emac              
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac6_tx_axis_data            ;
    wire    [15:0]                              w_emac6_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac6_tx_axis_keep            ;
    wire                                        w_emac6_tx_axis_last            ;
    wire                                        w_emac6_tx_axis_valid           ;
    wire    [15:0]                              w_emac6_ethertype               ;
    wire                                        w_emac6_tx_axis_ready           ;
    // 调度流水线调度信息交互
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac6_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac6_scheduing_rst            ;
    wire                                        w_mac6_scheduing_rst_vld        ; 
`endif
`ifdef MAC7 
    wire                                    w_mac7_cross_port_link              ; 
    wire   [1:0]                            w_mac7_cross_port_speed             ; 
    wire   [CROSS_DATA_WIDTH:0]             w_mac7_cross_port_axi_data          ; 
    wire   [15:0]                           w_mac7_cross_port_axi_user          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ; 
    wire                                    w_mac7_cross_axi_data_valid         ; 
    wire                                    w_mac7_cross_axi_data_ready         ; 
    wire                                    w_mac7_cross_axi_data_last          ; 
    
    wire   [METADATA_WIDTH-1:0]             w_mac7_cross_metadata               ; 
    wire                                    w_mac7_cross_metadata_valid         ; 
    wire                                    w_mac7_cross_metadata_last          ; 
    wire                                    w_mac7_cross_metadata_ready         ; 

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac7_port_axi_data               ; 
    wire   [15:0]                           w_emac7_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac7_axi_data_keep               ; 
    wire                                    w_emac7_axi_data_valid              ; 
    wire                                    w_emac7_axi_data_ready              ; 
    wire                                    w_emac7_axi_data_last               ; 
    wire   [METADATA_WIDTH-1:0]             w_emac7_metadata                    ; 
    wire                                    w_emac7_metadata_valid              ; 
    wire                                    w_emac7_metadata_last               ; 
    wire                                    w_emac7_metadata_ready              ; 

    wire                                     w_tx7_req                           ;
    wire                                     w_mac7_tx0_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx0_ack_rst                  ;
    wire                                     w_mac7_tx1_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx1_ack_rst                  ;
    wire                                     w_mac7_tx2_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx2_ack_rst                  ;
    wire                                     w_mac7_tx3_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx3_ack_rst                  ;
    wire                                     w_mac7_tx4_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx4_ack_rst                  ;
    wire                                     w_mac7_tx5_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx5_ack_rst                  ;
    wire                                     w_mac7_tx6_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx6_ack_rst                  ;
    wire                                     w_mac7_tx7_ack                      ;
    wire   [PORT_FIFO_PRI_NUM-1:0]           w_mac7_tx7_ack_rst                  ;

    // CB TO CROSSBAR
    // wire                                    w_cb_mac7_cross_port_link           ;
    // wire   [1:0]                            w_cb_mac7_cross_port_speed          ;
    // wire   [CROSS_DATA_WIDTH:0]             w_cb_mac7_cross_port_axi_data       ;
    // wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_cb_mac7_cross_axi_data_keep       ;
    // wire                                    w_cb_mac7_cross_axi_data_valid      ;
    // wire                                    w_cb_mac7_cross_axi_data_ready      ;
    // wire                                    w_cb_mac7_cross_axi_data_last       ;
    // CROSSBAR TO TXMAC
    wire    [CROSS_DATA_WIDTH - 1:0]            w_pmac7_tx_axis_data            ; 
    wire    [15:0]                              w_pmac7_tx_axis_user            ; 
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_pmac7_tx_axis_keep            ; 
    wire                                        w_pmac7_tx_axis_last            ; 
    wire                                        w_pmac7_tx_axis_valid           ; 
    wire    [15:0]                              w_pmac7_ethertype               ; 
    wire                                        w_pmac7_tx_axis_ready           ;
    //emac             
    wire    [CROSS_DATA_WIDTH - 1:0]            w_emac7_tx_axis_data            ;
    wire    [15:0]                              w_emac7_tx_axis_user            ;
    wire    [(CROSS_DATA_WIDTH/8)-1:0]          w_emac7_tx_axis_keep            ;
    wire                                        w_emac7_tx_axis_last            ;
    wire                                        w_emac7_tx_axis_valid           ;
    wire    [15:0]                              w_emac7_ethertype               ;
    wire                                        w_emac7_tx_axis_ready           ;
    // 
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac7_fifoc_empty              ;   
    wire   [PORT_FIFO_PRI_NUM-1:0]              w_mac7_scheduing_rst            ;
    wire                                        w_mac7_scheduing_rst_vld        ; 
`endif
`ifdef TSN_AS
    wire                                    w_tsn_as_cross_port_link            ; 
    wire   [1:0]                            w_tsn_as_cross_port_speed           ; 
    wire   [CROSS_DATA_WIDTH:0]             w_tsn_as_cross_port_axi_data        ; 
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_tsn_as_cross_axi_data_keep        ; 
    wire                                    w_tsn_as_cross_axi_data_valid       ; 
    wire                                    w_tsn_as_cross_axi_data_ready       ; 
    wire                                    w_tsn_as_cross_axi_data_last        ; 
    
    wire   [METADATA_WIDTH-1:0]             w_tsn_as_cross_metadata             ; 
    wire                                    w_tsn_as_cross_metadata_valid       ; 
    wire                                    w_tsn_as_cross_metadata_last        ; 
    wire                                    w_tsn_as_cross_metadata_ready       ; 
`endif
`ifdef LLDP
    wire                                     w_lldp_cross_port_link              ;
    wire   [1:0]                             w_lldp_cross_port_speed             ;
    wire   [CROSS_DATA_WIDTH:0]              w_lldp_cross_port_axi_data          ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]        w_lldp_cross_axi_data_keep          ;
    wire                                     w_lldp_cross_axi_data_valid         ;
    wire                                     w_lldp_cross_axi_data_ready         ;
    wire                                     w_lldp_cross_axi_data_last          ;
                                                                                 
    wire   [METADATA_WIDTH-1:0]              w_lldp_cross_metadata               ;
    wire                                     w_lldp_cross_metadata_valid         ;
    wire                                     w_lldp_cross_metadata_last          ;
    wire                                     w_lldp_cross_metadata_ready         ;
`endif
/*----------------------------- 交换表接口 --------------------*/
`ifdef END_POINTER_SWITCH_CORE
    `ifdef CPU_MAC 
        wire   [11:0]                           w_vlan_id_cpu                       ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_cpu_hash_key                 ; 
        wire   [47 : 0]                         w_dmac_cpu                          ; 
        wire                                    w_dmac_cpu_vld                      ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_cpu_hash_key                 ; 
        wire   [47 : 0]                         w_smac_cpu                          ; 
        wire                                    w_smac_cpu_vld                      ; 
        wire   [PORT_NUM - 1:0]                 w_tx_cpu_port                       ;
        wire   [1:0]                            w_tx_cpu_port_broadcast             ;
        wire                                    w_tx_cpu_port_vld                   ;
    `endif
    `ifdef MAC1
        wire   [11:0]                           w_vlan_id1                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac1_hash_key                    ; 
        wire   [47 : 0]                         w_dmac1                             ; 
        wire                                    w_dmac1_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac1_hash_key                    ; 
        wire   [47 : 0]                         w_smac1                             ; 
        wire                                    w_smac1_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_1_port                         ;
        wire   [1:0]                            w_tx_1_port_broadcast               ;
        wire                                    w_tx_1_port_vld                     ;
    `endif
    `ifdef MAC2
        wire   [11:0]                           w_vlan_id2                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac2_hash_key                    ; 
        wire   [47 : 0]                         w_dmac2                             ; 
        wire                                    w_dmac2_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac2_hash_key                    ; 
        wire   [47 : 0]                         w_smac2                             ; 
        wire                                    w_smac2_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_2_port                         ;
        wire   [1:0]                            w_tx_2_port_broadcast               ;
        wire                                    w_tx_2_port_vld                     ;
    `endif
    `ifdef MAC3
        wire   [11:0]                           w_vlan_id3                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac3_hash_key                    ; 
        wire   [47 : 0]                         w_dmac3                             ; 
        wire                                    w_dmac3_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac3_hash_key                    ; 
        wire   [47 : 0]                         w_smac3                             ; 
        wire                                    w_smac3_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_3_port                         ;
        wire   [1:0]                            w_tx_3_port_broadcast               ;
        wire                                    w_tx_3_port_vld                     ;
    `endif
    `ifdef MAC4
        wire   [11:0]                           w_vlan_id4                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac4_hash_key                    ; 
        wire   [47 : 0]                         w_dmac4                             ; 
        wire                                    w_dmac4_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac4_hash_key                    ; 
        wire   [47 : 0]                         w_smac4                             ; 
        wire                                    w_smac4_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_4_port                         ;
        wire   [1:0]                            w_tx_4_port_broadcast               ;
        wire                                    w_tx_4_port_vld                     ;
    `endif
    `ifdef MAC5
        wire   [11:0]                           w_vlan_id5                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac5_hash_key                    ; 
        wire   [47 : 0]                         w_dmac5                             ; 
        wire                                    w_dmac5_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac5_hash_key                    ; 
        wire   [47 : 0]                         w_smac5                             ; 
        wire                                    w_smac5_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_5_port                         ;
        wire   [1:0]                            w_tx_5_port_broadcast               ;
        wire                                    w_tx_5_port_vld                     ;
    `endif
    `ifdef MAC6
        wire   [11:0]                           w_vlan_id6                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac6_hash_key                    ; 
        wire   [47 : 0]                         w_dmac6                             ; 
        wire                                    w_dmac6_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac6_hash_key                    ; 
        wire   [47 : 0]                         w_smac6                             ; 
        wire                                    w_smac6_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_6_port                         ;
        wire   [1:0]                            w_tx_6_port_broadcast               ;
        wire                                    w_tx_6_port_vld                     ;
    `endif
    `ifdef MAC7
        wire   [11:0]                           w_vlan_id7                          ;
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac7_hash_key                    ; 
        wire   [47 : 0]                         w_dmac7                             ; 
        wire                                    w_dmac7_vld                         ; 
        wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac7_hash_key                    ; 
        wire   [47 : 0]                         w_smac7                             ; 
        wire                                    w_smac7_vld                         ; 
        wire   [PORT_NUM - 1:0]                 w_tx_7_port                         ;
        wire   [1:0]                            w_tx_7_port_broadcast               ;
        wire                                    w_tx_7_port_vld                     ;
    `endif
`endif
/*----------------------------- CB接口 --------------------*/
`ifdef CPU_MAC
    wire                                    w_mac0_rtag_flag        ;
    wire   [15:0]                           w_mac0_rtag_sequence    ;  
    wire   [7:0]                            w_mac0_stream_handle    ;    
`endif
`ifdef MAC1
    wire                                    w_mac1_rtag_flag        ;
    wire   [15:0]                           w_mac1_rtag_sequence    ;  
    wire   [7:0]                            w_mac1_stream_handle    ;    
`endif
`ifdef MAC2
    wire                                    w_mac2_rtag_flag        ;
    wire   [15:0]                           w_mac2_rtag_sequence    ;  
    wire   [7:0]                            w_mac2_stream_handle    ;    
`endif
`ifdef MAC3
    wire                                    w_mac3_rtag_flag        ;
    wire   [15:0]                           w_mac3_rtag_sequence    ;  
    wire   [7:0]                            w_mac3_stream_handle    ;    
`endif
`ifdef MAC4
    wire                                    w_mac4_rtag_flag        ;
    wire   [15:0]                           w_mac4_rtag_sequence    ;  
    wire   [7:0]                            w_mac4_stream_handle    ;    
`endif
`ifdef MAC5
    wire                                    w_mac5_rtag_flag        ;
    wire   [15:0]                           w_mac5_rtag_sequence    ;  
    wire   [7:0]                            w_mac5_stream_handle    ;    
`endif
`ifdef MAC6
    wire                                    w_mac6_rtag_flag        ;
    wire   [15:0]                           w_mac6_rtag_sequence    ;  
    wire   [7:0]                            w_mac6_stream_handle    ;    
`endif
`ifdef MAC7
    wire                                    w_mac7_rtag_flag        ;
    wire   [15:0]                           w_mac7_rtag_sequence    ;  
    wire   [7:0]                            w_mac7_stream_handle    ;    
`endif
wire [PORT_NUM-1:0] w_mac_pass_en; 
wire [PORT_NUM-1:0] w_mac_discard_en;
wire [PORT_NUM-1:0] w_mac_judge_finish; 

/*-------------------------------------- 寄存器刷新控制接口 ------------------------------------------*/
wire                                        w_refresh_list_pulse                ; 
wire                                        w_switch_err_cnt_clr                ; 
wire                                        w_switch_err_cnt_stat               ; 

/*-----------------------------------   rxmac寄存器接口  -------------------------------------------*/
wire                                        w_rxmac_reg_bus_we                  ;
wire   [REG_ADDR_OFS_WIDTH-1:0]             w_rxmac_reg_bus_we_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_rxmac_reg_bus_we_din              ;
wire                                        w_rxmac_reg_bus_we_din_v            ;
wire                                        w_rxmac_reg_bus_rd                  ;
wire   [REG_ADDR_OFS_WIDTH-1:0]             w_rxmac_reg_bus_rd_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_rxmac_reg_bus_rd_dout             ;
wire                                        w_rxmac_reg_bus_rd_dout_v           ;

/*-----------------------------------   txmac寄存器接口  -------------------------------------------*/
wire                                        w_txmac_reg_bus_we                  ;
wire   [REG_ADDR_OFS_WIDTH-1:0]             w_txmac_reg_bus_we_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_txmac_reg_bus_we_din              ;
wire                                        w_txmac_reg_bus_we_din_v            ;
wire                                        w_txmac_reg_bus_rd                  ;
wire   [REG_ADDR_OFS_WIDTH-1:0]             w_txmac_reg_bus_rd_addr             ;
wire   [REG_DATA_BUS_WIDTH-1:0]             w_txmac_reg_bus_rd_dout             ;
wire                                        w_txmac_reg_bus_rd_dout_v           ;
/*-----------------------------------   CB寄存器接口  -------------------------------------------*/
wire                                    w_cb_reg_bus_we                 ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_cb_reg_bus_we_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_cb_reg_bus_we_din             ;
wire                                    w_cb_reg_bus_we_din_v           ;
wire                                    w_cb_reg_bus_rd                 ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_cb_reg_bus_rd_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_cb_reg_bus_rd_dout            ;
wire                                    w_cb_reg_bus_rd_dout_v          ;
/*-----------------------------------   AS寄存器接口  -------------------------------------------*/
wire                                    w_as_reg_bus_we                 ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_as_reg_bus_we_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_as_reg_bus_we_din             ;
wire                                    w_as_reg_bus_we_din_v           ;
wire                                    w_as_reg_bus_rd                 ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_as_reg_bus_rd_addr            ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_as_reg_bus_rd_dout            ;
wire                                    w_as_reg_bus_rd_dout_v          ;
/*--------------------------   EtherNet Interface寄存器接口  ------------------------------------*/
wire                                    w_eth_reg_bus_we                ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_eth_reg_bus_we_addr           ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_eth_reg_bus_we_din            ;
wire                                    w_eth_reg_bus_we_din_v          ;
wire                                    w_eth_reg_bus_rd                ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_eth_reg_bus_rd_addr           ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_eth_reg_bus_rd_dout           ;
wire                                    w_eth_reg_bus_rd_dout_v         ;
/*--------------------------   MCU Interface寄存器接口  ------------------------------------*/
wire                                    w_mcu_reg_bus_we                ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_mcu_reg_bus_we_addr           ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_mcu_reg_bus_we_din            ;
wire                                    w_mcu_reg_bus_we_din_v          ;
wire                                    w_mcu_reg_bus_rd                ;
wire   [REG_ADDR_OFS_WIDTH-1:0]         w_mcu_reg_bus_rd_addr           ;
wire   [REG_DATA_BUS_WIDTH-1:0]         w_mcu_reg_bus_rd_dout           ;
wire                                    w_mcu_reg_bus_rd_dout_v         ;
/*----------------------------------   swlist寄存器接口  ------------------------------------------*/
`ifdef END_POINTER_SWITCH_CORE 
    wire                                        w_swlist_reg_bus_we                 ;
    wire   [REG_ADDR_OFS_WIDTH-1:0]             w_swlist_reg_bus_we_addr            ;
    wire   [REG_DATA_BUS_WIDTH-1:0]             w_swlist_reg_bus_we_din             ;
    wire                                        w_swlist_reg_bus_we_din_v           ;
    wire                                        w_swlist_reg_bus_rd                 ;
    wire   [REG_ADDR_OFS_WIDTH-1:0]             w_swlist_reg_bus_rd_addr            ;
    wire   [REG_DATA_BUS_WIDTH-1:0]             w_swlist_reg_bus_rd_dout            ;
    wire                                        w_swlist_reg_bus_rd_dout_v          ;
`endif
/*---------------------------- RXMAC ---------------------------*/
rx_mac_mng #(
            .PORT_NUM                (  PORT_NUM                      ) ,  // 交换机的端口数
            .REG_ADDR_BUS_WIDTH      (  REG_ADDR_OFS_WIDTH            ) ,  // 接收 MAC 层的配置寄存器地址位宽
            .REG_DATA_BUS_WIDTH      (  REG_DATA_BUS_WIDTH            ) ,  // 接收 MAC 层的配置寄存器数据位宽
            .METADATA_WIDTH          (  METADATA_WIDTH                ) ,  // 信息流（METADATA）的位宽
            .PORT_MNG_DATA_WIDTH     (  PORT_MNG_DATA_WIDTH           ) ,  // Mac_port_mng 数据位宽 
            .HASH_DATA_WIDTH         (  HASH_DATA_WIDTH               ) ,  // 哈希计算的值的位宽
            .CROSS_DATA_WIDTH        (  CROSS_DATA_WIDTH              )    // 聚合总线输出 
)rx_mac_mng_inst (
        .i_clk                               (i_clk                       ) ,   // 250MHz
        .i_rst                               (i_rst                       ) ,
    /*---------------------------------------- CPU_MAC数据流 -------------------------------------------*/
    `ifdef CPU_MAC
        // 数据流信息  
        .i_cpu_mac0_port_link                ( i_cpu_mac0_port_link                   ), // 端口的连接状态
        .i_cpu_mac0_port_speed               ( i_cpu_mac0_port_speed                  ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_cpu_mac0_port_filter_preamble_v   ( i_cpu_mac0_port_filter_preamble_v      ), // 端口是否过滤前导码信息
        .i_cpu_mac0_axi_data                 ( i_cpu_mac0_axi_data                    ), // 端口数据流
        .i_cpu_mac0_axi_data_keep            ( i_cpu_mac0_axi_data_keep               ), // 端口数据流掩码，有效字节指示
        .i_cpu_mac0_axi_data_valid           ( i_cpu_mac0_axi_data_valid              ), // 端口数据有效
        .o_cpu_mac0_axi_data_ready           ( o_cpu_mac0_axi_data_ready              ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_cpu_mac0_axi_data_last            ( i_cpu_mac0_axi_data_last               ), // 数据流结束标识
        // 报文时间打时间戳                                                                 
        .o_cpu_mac0_time_irq                 ( o_rxcpu_mac0_time_irq                  ), // 打时间戳中断信号
        .o_cpu_mac0_frame_seq                ( o_rxcpu_mac0_frame_seq                 ), // 帧序列号
        .o_timestamp0_addr                   ( o_rxtimestamp0_addr                    ), // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac0_rtag_flag                    ( w_mac0_rtag_flag                       ),
        .o_mac0_rtag_squence                 ( w_mac0_rtag_sequence                   ),
        .o_mac0_stream_handle                ( w_mac0_stream_handle                   ),
        .i_mac0_pass_en                      ( w_mac_pass_en[0]                         ),
        .i_mac0_discard_en                   ( w_mac_discard_en[0]                      ),
        .i_mac0_judge_finish                 ( w_mac_judge_finish[0]                    ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac0_cross_port_link              ( w_mac0_cross_port_link                 ), // 端口的连接状态
        .o_mac0_cross_port_speed             ( w_mac0_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac0_cross_port_axi_data          ( w_mac0_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac0_cross_port_axi_user          ( w_mac0_cross_port_axi_user             ), // 端口数据流掩码，有效字节指示
        .o_mac0_cross_axi_data_keep          ( w_mac0_cross_axi_data_keep             ), // 端口数据有效
        .o_mac0_cross_axi_data_valid         ( w_mac0_cross_axi_data_valid            ), // 交叉总线聚合架构反压流水线信号
        .i_mac0_cross_axi_data_ready         ( w_mac0_cross_axi_data_ready            ), // 数据流结束标识
        .o_mac0_cross_axi_data_last          ( w_mac0_cross_axi_data_last             ), 
                                                                                         
        .o_mac0_cross_metadata               ( w_mac0_cross_metadata                 ), // 总线 metadata 数据
        .o_mac0_cross_metadata_valid         ( w_mac0_cross_metadata_valid           ), // 总线 metadata 数据有效信号
        .o_mac0_cross_metadata_last          ( w_mac0_cross_metadata_last            ), // 信息流结束标识
        .i_mac0_cross_metadata_ready         ( w_mac0_cross_metadata_ready           ), // 下游模块反压流水线 
		
		// emac帧快速通道
		.o_emac0_port_axi_data               (w_emac0_port_axi_data  ),      
		.o_emac0_port_axi_user               (w_emac0_port_axi_user  ),      
		.o_emac0_axi_data_keep               (w_emac0_axi_data_keep  ),      
		.o_emac0_axi_data_valid              (w_emac0_axi_data_valid ),      
		.i_emac0_axi_data_ready              (w_emac0_axi_data_ready ),   
		.o_emac0_axi_data_last               (w_emac0_axi_data_last  ),        
		.o_emac0_metadata                    (w_emac0_metadata       ),        
		.o_emac0_metadata_valid              (w_emac0_metadata_valid ),        
		.o_emac0_metadata_last               (w_emac0_metadata_last  ),        
		.i_emac0_metadata_ready              (w_emac0_metadata_ready ),

        .o_tx0_req                           ( w_tx0_req                           ),   //cpu port trans req
        .i_mac0_tx0_ack                      ( w_mac0_tx0_ack                      ),   //
        .i_mac0_tx0_ack_rst                  ( w_mac0_tx0_ack_rst                  ),
        .i_mac0_tx1_ack                      ( w_mac0_tx1_ack                      ),
        .i_mac0_tx1_ack_rst                  ( w_mac0_tx1_ack_rst                  ),
        .i_mac0_tx2_ack                      ( w_mac0_tx2_ack                      ),
        .i_mac0_tx2_ack_rst                  ( w_mac0_tx2_ack_rst                  ),
        .i_mac0_tx3_ack                      ( w_mac0_tx3_ack                      ),
        .i_mac0_tx3_ack_rst                  ( w_mac0_tx3_ack_rst                  ),
        .i_mac0_tx4_ack                      ( w_mac0_tx4_ack                      ),
        .i_mac0_tx4_ack_rst                  ( w_mac0_tx4_ack_rst                  ),
        .i_mac0_tx5_ack                      ( w_mac0_tx5_ack                      ),
        .i_mac0_tx5_ack_rst                  ( w_mac0_tx5_ack_rst                  ),
        .i_mac0_tx6_ack                      ( w_mac0_tx6_ack                      ),
        .i_mac0_tx6_ack_rst                  ( w_mac0_tx6_ack_rst                  ),
        .i_mac0_tx7_ack                      ( w_mac0_tx7_ack                      ),
        .i_mac0_tx7_ack_rst                  ( w_mac0_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC1 数据流 -------------------------------------------*/
    `ifdef MAC1
        // 数据流信息 
        .i_mac1_port_link                    ( i_mac1_port_link                      ), // 端口的连接状态
        .i_mac1_port_speed                   ( i_mac1_port_speed                     ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac1_port_filter_preamble_v       ( i_mac1_port_filter_preamble_v         ), // 端口是否过滤前导码信息
        .i_mac1_axi_data                     ( i_mac1_axi_data                       ), // 端口数据流
        .i_mac1_axi_data_keep                ( i_mac1_axi_data_keep                  ), // 端口数据流掩码，有效字节指示
        .i_mac1_axi_data_valid               ( i_mac1_axi_data_valid                 ), // 端口数据有效
        .o_mac1_axi_data_ready               ( o_mac1_axi_data_ready                 ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac1_axi_data_last                ( i_mac1_axi_data_last                  ), // 数据流结束标识
        // 报文时间打时间戳                                                                
        .o_mac1_time_irq                     ( o_rxmac1_time_irq                     ), // 打时间戳中断信号
        .o_mac1_frame_seq                    ( o_rxmac1_frame_seq                    ), // 帧序列号
        .o_timestamp1_addr                   ( o_rxtimestamp1_addr                   ), // 打时间戳存储的 RAM 地址

        // CB接口
        .o_mac1_rtag_flag                    ( w_mac1_rtag_flag                       ),
        .o_mac1_rtag_squence                 ( w_mac1_rtag_sequence                   ),
        .o_mac1_stream_handle                ( w_mac1_stream_handle                   ),
        .i_mac1_pass_en                      ( w_mac_pass_en[1]                         ),
        .i_mac1_discard_en                   ( w_mac_discard_en[1]                      ),
        .i_mac1_judge_finish                 ( w_mac_judge_finish[1]                    ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac1_cross_port_link              ( w_mac1_cross_port_link                 ), // 端口的连接状态
        .o_mac1_cross_port_speed             ( w_mac1_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac1_cross_port_axi_data          ( w_mac1_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac1_cross_port_axi_user          ( w_mac1_cross_port_axi_user             ),
        .o_mac1_cross_axi_data_keep          ( w_mac1_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac1_cross_axi_data_valid         ( w_mac1_cross_axi_data_valid            ), // 端口数据有效
        .i_mac1_cross_axi_data_ready         ( w_mac1_cross_axi_data_ready            ), // 端口数据就绪信号,表示当前模块准备好接收数据
        .o_mac1_cross_axi_data_last          ( w_mac1_cross_axi_data_last             ), // 数据流结束标识
        
        .o_mac1_cross_metadata               ( w_mac1_cross_metadata                 ), // 总线 metadata 数据
        .o_mac1_cross_metadata_valid         ( w_mac1_cross_metadata_valid           ), // 总线 metadata 数据有效信号
        .o_mac1_cross_metadata_last          ( w_mac1_cross_metadata_last            ), // 信息流结束标识
        .i_mac1_cross_metadata_ready         ( w_mac1_cross_metadata_ready           ), // 下游模块反压流水线 


		// emac帧快速通道
		.o_emac1_port_axi_data               (w_emac1_port_axi_data  ),      
		.o_emac1_port_axi_user               (w_emac1_port_axi_user  ),      
		.o_emac1_axi_data_keep               (w_emac1_axi_data_keep  ),      
		.o_emac1_axi_data_valid              (w_emac1_axi_data_valid ),      
		.i_emac1_axi_data_ready              (w_emac1_axi_data_ready ),
		.o_emac1_axi_data_last               (w_emac1_axi_data_last  ),        
		.o_emac1_metadata                    (w_emac1_metadata       ),        
		.o_emac1_metadata_valid              (w_emac1_metadata_valid ),        
		.o_emac1_metadata_last               (w_emac1_metadata_last  ),        
		.i_emac1_metadata_ready              (w_emac1_metadata_ready ),

        .o_tx1_req                           ( w_tx1_req                         ),
        .i_mac1_tx0_ack                      ( w_mac1_tx0_ack                      ),
        .i_mac1_tx0_ack_rst                  ( w_mac1_tx0_ack_rst                  ),
        .i_mac1_tx1_ack                      ( w_mac1_tx1_ack                      ),
        .i_mac1_tx1_ack_rst                  ( w_mac1_tx1_ack_rst                  ),
        .i_mac1_tx2_ack                      ( w_mac1_tx2_ack                      ),
        .i_mac1_tx2_ack_rst                  ( w_mac1_tx2_ack_rst                  ),
        .i_mac1_tx3_ack                      ( w_mac1_tx3_ack                      ),
        .i_mac1_tx3_ack_rst                  ( w_mac1_tx3_ack_rst                  ),
        .i_mac1_tx4_ack                      ( w_mac1_tx4_ack                      ),
        .i_mac1_tx4_ack_rst                  ( w_mac1_tx4_ack_rst                  ),
        .i_mac1_tx5_ack                      ( w_mac1_tx5_ack                      ),
        .i_mac1_tx5_ack_rst                  ( w_mac1_tx5_ack_rst                  ),
        .i_mac1_tx6_ack                      ( w_mac1_tx6_ack                      ),
        .i_mac1_tx6_ack_rst                  ( w_mac1_tx6_ack_rst                  ),
        .i_mac1_tx7_ack                      ( w_mac1_tx7_ack                      ),
        .i_mac1_tx7_ack_rst                  ( w_mac1_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC2 数据流 -------------------------------------------*/
    `ifdef MAC2
        // 数据流信息 
        .i_mac2_port_link                   ( i_mac2_port_link                   ) , // 端口的连接状态
        .i_mac2_port_speed                  ( i_mac2_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac2_port_filter_preamble_v      ( i_mac2_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac2_axi_data                    ( i_mac2_axi_data                    ) , // 端口数据流
        .i_mac2_axi_data_keep               ( i_mac2_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac2_axi_data_valid              ( i_mac2_axi_data_valid              ) , // 端口数据有效
        .o_mac2_axi_data_ready              ( o_mac2_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac2_axi_data_last               ( i_mac2_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳 
        .o_mac2_time_irq                    ( o_rxmac2_time_irq                  ) , // 打时间戳中断信号
        .o_mac2_frame_seq                   ( o_rxmac2_frame_seq                 ) , // 帧序列号
        .o_timestamp2_addr                  ( o_rxtimestamp2_addr                ) , // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac2_rtag_flag                   ( w_mac2_rtag_flag                   ),
        .o_mac2_rtag_squence                ( w_mac2_rtag_sequence               ),
        .o_mac2_stream_handle               ( w_mac2_stream_handle               ),
        .i_mac2_pass_en                     ( w_mac_pass_en[2]                   ),
        .i_mac2_discard_en                  ( w_mac_discard_en[2]                ),
        .i_mac2_judge_finish                ( w_mac_judge_finish[2]              ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac2_cross_port_link              ( w_mac2_cross_port_link                 ), // 端口的连接状态
        .o_mac2_cross_port_speed             ( w_mac2_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac2_cross_port_axi_data          ( w_mac2_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac2_cross_port_axi_user          ( w_mac2_cross_port_axi_user             ), // 端口数据流用户信号
        .o_mac2_cross_axi_data_keep          ( w_mac2_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac2_cross_axi_data_valid         ( w_mac2_cross_axi_data_valid            ), // 端口数据有效
        .i_mac2_cross_axi_data_ready         ( w_mac2_cross_axi_data_ready            ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac2_cross_axi_data_last          ( w_mac2_cross_axi_data_last             ), // 数据流结束标识
        

        .o_mac2_cross_metadata               ( w_mac2_cross_metadata                 ), // 总线 metadata 数据
        .o_mac2_cross_metadata_valid         ( w_mac2_cross_metadata_valid           ), // 总线 metadata 数据有效信号
        .o_mac2_cross_metadata_last          ( w_mac2_cross_metadata_last            ), // 信息流结束标识
        .i_mac2_cross_metadata_ready         ( w_mac2_cross_metadata_ready           ), // 下游模块反压流水线

		// emac帧快速通道
		.o_emac2_port_axi_data               (w_emac2_port_axi_data  ),      
		.o_emac2_port_axi_user               (w_emac2_port_axi_user  ),      
		.o_emac2_axi_data_keep               (w_emac2_axi_data_keep  ),      
		.o_emac2_axi_data_valid              (w_emac2_axi_data_valid ),      
		.i_emac2_axi_data_ready              (w_emac2_axi_data_ready ),  
		.o_emac2_axi_data_last               (w_emac2_axi_data_last  ),        
		.o_emac2_metadata                    (w_emac2_metadata       ),        
		.o_emac2_metadata_valid              (w_emac2_metadata_valid ),        
		.o_emac2_metadata_last               (w_emac2_metadata_last  ),        
		.i_emac2_metadata_ready              (w_emac2_metadata_ready ), 



        .o_tx2_req                           ( w_tx2_req                         ),
        .i_mac2_tx0_ack                      ( w_mac2_tx0_ack                      ),
        .i_mac2_tx0_ack_rst                  ( w_mac2_tx0_ack_rst                  ),
        .i_mac2_tx1_ack                      ( w_mac2_tx1_ack                      ),
        .i_mac2_tx1_ack_rst                  ( w_mac2_tx1_ack_rst                  ),
        .i_mac2_tx2_ack                      ( w_mac2_tx2_ack                      ),
        .i_mac2_tx2_ack_rst                  ( w_mac2_tx2_ack_rst                  ),
        .i_mac2_tx3_ack                      ( w_mac2_tx3_ack                      ),
        .i_mac2_tx3_ack_rst                  ( w_mac2_tx3_ack_rst                  ),
        .i_mac2_tx4_ack                      ( w_mac2_tx4_ack                      ),
        .i_mac2_tx4_ack_rst                  ( w_mac2_tx4_ack_rst                  ),
        .i_mac2_tx5_ack                      ( w_mac2_tx5_ack                      ),
        .i_mac2_tx5_ack_rst                  ( w_mac2_tx5_ack_rst                  ),
        .i_mac2_tx6_ack                      ( w_mac2_tx6_ack                      ),
        .i_mac2_tx6_ack_rst                  ( w_mac2_tx6_ack_rst                  ),
        .i_mac2_tx7_ack                      ( w_mac2_tx7_ack                      ),
        .i_mac2_tx7_ack_rst                  ( w_mac2_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC3 数据流 -------------------------------------------*/
    `ifdef MAC3
        // 数据流信息 
        .i_mac3_port_link                   ( i_mac3_port_link                   ) , // 端口的连接状态
        .i_mac3_port_speed                  ( i_mac3_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac3_port_filter_preamble_v      ( i_mac3_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac3_axi_data                    ( i_mac3_axi_data                    ) , // 端口数据流
        .i_mac3_axi_data_keep               ( i_mac3_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac3_axi_data_valid              ( i_mac3_axi_data_valid              ) , // 端口数据有效
        .o_mac3_axi_data_ready              ( o_mac3_axi_data_ready              ) , // 端口数据就绪信号，表示当前模块准备好接收数据
        .i_mac3_axi_data_last               ( i_mac3_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳 
        .o_mac3_time_irq                    ( o_rxmac3_time_irq        ) , // 打时间戳中断信号
        .o_mac3_frame_seq                   ( o_rxmac3_frame_seq       ) , // 帧序列号
        .o_timestamp3_addr                  ( o_rxtimestamp3_addr      ) , // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac3_rtag_flag                    ( w_mac3_rtag_flag                         ),
        .o_mac3_rtag_squence                 ( w_mac3_rtag_sequence                     ),
        .o_mac3_stream_handle                ( w_mac3_stream_handle                     ),
        .i_mac3_pass_en                      ( w_mac_pass_en[3]                         ),
        .i_mac3_discard_en                   ( w_mac_discard_en[3]                      ),
        .i_mac3_judge_finish                 ( w_mac_judge_finish[3]                    ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac3_cross_port_link              ( w_mac3_cross_port_link                 ), // 端口的连接状态
        .o_mac3_cross_port_speed             ( w_mac3_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac3_cross_port_axi_data          ( w_mac3_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac3_cross_port_axi_user          ( w_mac3_cross_port_axi_user             ), // 端口数据流用户信号
        .o_mac3_cross_axi_data_keep          ( w_mac3_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac3_cross_axi_data_valid         ( w_mac3_cross_axi_data_valid            ), // 端口数据有效
        .i_mac3_cross_axi_data_ready         ( w_mac3_cross_axi_data_ready            ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac3_cross_axi_data_last          ( w_mac3_cross_axi_data_last             ), // 数据流结束标识
        
        .o_mac3_cross_metadata               ( w_mac3_cross_metadata                 ), // 总线 metadata 数据
        .o_mac3_cross_metadata_valid         ( w_mac3_cross_metadata_valid           ), // 总线 metadata 数据有效信号
        .o_mac3_cross_metadata_last          ( w_mac3_cross_metadata_last            ), // 信息流结束标识
        .i_mac3_cross_metadata_ready         ( w_mac3_cross_metadata_ready           ), // 下游模块反压流水线

		// emac帧快速通道
		.o_emac3_port_axi_data               (w_emac3_port_axi_data  ),      
		.o_emac3_port_axi_user               (w_emac3_port_axi_user  ),      
		.o_emac3_axi_data_keep               (w_emac3_axi_data_keep  ),      
		.o_emac3_axi_data_valid              (w_emac3_axi_data_valid ),      
		.i_emac3_axi_data_ready              (w_emac3_axi_data_ready ), 
		.o_emac3_axi_data_last               (w_emac3_axi_data_last  ),        
		.o_emac3_metadata                    (w_emac3_metadata       ),        
		.o_emac3_metadata_valid              (w_emac3_metadata_valid ),        
		.o_emac3_metadata_last               (w_emac3_metadata_last  ),        
		.i_emac3_metadata_ready              (w_emac3_metadata_ready ), 



        .o_tx3_req                           (w_tx3_req                          ),
        .i_mac3_tx0_ack                      (w_mac3_tx0_ack                      ),
        .i_mac3_tx0_ack_rst                  (w_mac3_tx0_ack_rst                  ),
        .i_mac3_tx1_ack                      (w_mac3_tx1_ack                      ),
        .i_mac3_tx1_ack_rst                  (w_mac3_tx1_ack_rst                  ),
        .i_mac3_tx2_ack                      (w_mac3_tx2_ack                      ),
        .i_mac3_tx2_ack_rst                  (w_mac3_tx2_ack_rst                  ),
        .i_mac3_tx3_ack                      (w_mac3_tx3_ack                      ),
        .i_mac3_tx3_ack_rst                  (w_mac3_tx3_ack_rst                  ),
        .i_mac3_tx4_ack                      (w_mac3_tx4_ack                      ),
        .i_mac3_tx4_ack_rst                  (w_mac3_tx4_ack_rst                  ),
        .i_mac3_tx5_ack                      (w_mac3_tx5_ack                      ),
        .i_mac3_tx5_ack_rst                  (w_mac3_tx5_ack_rst                  ),
        .i_mac3_tx6_ack                      (w_mac3_tx6_ack                      ),
        .i_mac3_tx6_ack_rst                  (w_mac3_tx6_ack_rst                  ),
        .i_mac3_tx7_ack                      (w_mac3_tx7_ack                      ),
        .i_mac3_tx7_ack_rst                  (w_mac3_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC4 数据流 -------------------------------------------*/
    `ifdef MAC4
        // 数据流信息 
        .i_mac4_port_link                   ( i_mac4_port_link                   ) , // 端口的连接状态
        .i_mac4_port_speed                  ( i_mac4_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac4_port_filter_preamble_v      ( i_mac4_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac4_axi_data                    ( i_mac4_axi_data                    ) , // 端口数据流
        .i_mac4_axi_data_keep               ( i_mac4_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac4_axi_data_valid              ( i_mac4_axi_data_valid              ) , // 端口数据有效
        .o_mac4_axi_data_ready              ( o_mac4_axi_data_ready              ) , // 端口数据就绪信号，表示当前模块准备好接收数据
        .i_mac4_axi_data_last               ( i_mac4_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳 
        .o_mac4_time_irq                    ( o_rxmac4_time_irq        ) , // 打时间戳中断信号
        .o_mac4_frame_seq                   ( o_rxmac4_frame_seq       ) , // 帧序列号
        .o_timestamp4_addr                  ( o_rxtimestamp4_addr      ) , // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac4_rtag_flag                    ( w_mac4_rtag_flag                       ),
        .o_mac4_rtag_squence                ( w_mac4_rtag_sequence                   ),
        .o_mac4_stream_handle                ( w_mac4_stream_handle                   ),
        .i_mac4_pass_en                      ( w_mac_pass_en[4]                         ),
        .i_mac4_discard_en                   ( w_mac_discard_en[4]                      ),
        .i_mac4_judge_finish                 ( w_mac_judge_finish[4]                    ), 

        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac4_cross_port_link              ( w_mac4_cross_port_link                 ), // 端口的连接状态
        .o_mac4_cross_port_speed             ( w_mac4_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac4_cross_port_axi_data          ( w_mac4_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac4_cross_port_axi_user          ( w_mac4_cross_port_axi_user             ), // 端口数据流用户信号
        .o_mac4_cross_axi_data_keep          ( w_mac4_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac4_cross_axi_data_valid         ( w_mac4_cross_axi_data_valid            ), // 端口数据有效
        .i_mac4_cross_axi_data_ready         ( w_mac4_cross_axi_data_ready            ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac4_cross_axi_data_last          ( w_mac4_cross_axi_data_last             ), // 数据流结束标识
        
        .o_mac4_cross_metadata               ( w_mac4_cross_metadata                 ),  // 总线 metadata 数据
        .o_mac4_cross_metadata_valid         ( w_mac4_cross_metadata_valid           ),  // 总线 metadata 数据有效信号
        .o_mac4_cross_metadata_last          ( w_mac4_cross_metadata_last            ),  // 信息流结束标识
        .i_mac4_cross_metadata_ready         ( w_mac4_cross_metadata_ready           ),  // 下游模块反压流水线 

		// emac帧快速通道
		.o_emac4_port_axi_data               (w_emac4_port_axi_data  ),      
		.o_emac4_port_axi_user               (w_emac4_port_axi_user  ),      
		.o_emac4_axi_data_keep               (w_emac4_axi_data_keep  ),      
		.o_emac4_axi_data_valid              (w_emac4_axi_data_valid ),      
		.i_emac4_axi_data_ready              (w_emac4_axi_data_ready),   
		.o_emac4_axi_data_last               (w_emac4_axi_data_last  ),        
		.o_emac4_metadata                    (w_emac4_metadata       ),        
		.o_emac4_metadata_valid              (w_emac4_metadata_valid ),        
		.o_emac4_metadata_last               (w_emac4_metadata_last  ),        
		.i_emac4_metadata_ready              (w_emac4_metadata_ready ),  



        .o_tx4_req                           (w_tx4_req                          ),
        .i_mac4_tx0_ack                      (w_mac4_tx0_ack                      ),
        .i_mac4_tx0_ack_rst                  (w_mac4_tx0_ack_rst                  ),
        .i_mac4_tx1_ack                      (w_mac4_tx1_ack                      ),
        .i_mac4_tx1_ack_rst                  (w_mac4_tx1_ack_rst                  ),
        .i_mac4_tx2_ack                      (w_mac4_tx2_ack                      ),
        .i_mac4_tx2_ack_rst                  (w_mac4_tx2_ack_rst                  ),
        .i_mac4_tx3_ack                      (w_mac4_tx3_ack                      ),
        .i_mac4_tx3_ack_rst                  (w_mac4_tx3_ack_rst                  ),
        .i_mac4_tx4_ack                      (w_mac4_tx4_ack                      ),
        .i_mac4_tx4_ack_rst                  (w_mac4_tx4_ack_rst                  ),
        .i_mac4_tx5_ack                      (w_mac4_tx5_ack                      ),
        .i_mac4_tx5_ack_rst                  (w_mac4_tx5_ack_rst                  ),
        .i_mac4_tx6_ack                      (w_mac4_tx6_ack                      ),
        .i_mac4_tx6_ack_rst                  (w_mac4_tx6_ack_rst                  ),
        .i_mac4_tx7_ack                      (w_mac4_tx7_ack                      ),
        .i_mac4_tx7_ack_rst                  (w_mac4_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC5 数据流 -------------------------------------------*/
    `ifdef MAC5
        // 数据流信息 
        .i_mac5_port_link                   ( i_mac5_port_link                   ) , // 端口的连接状态
        .i_mac5_port_speed                  ( i_mac5_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac5_port_filter_preamble_v      ( i_mac5_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac5_axi_data                    ( i_mac5_axi_data                    ) , // 端口数据流
        .i_mac5_axi_data_keep               ( i_mac5_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac5_axi_data_valid              ( i_mac5_axi_data_valid              ) , // 端口数据有效
        .o_mac5_axi_data_ready              ( o_mac5_axi_data_ready              ) , // 端口数据就绪信号,表示当前模块准备好接收数据
        .i_mac5_axi_data_last               ( i_mac5_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳 
        .o_mac5_time_irq                    ( o_rxmac5_time_irq                  ) , // 打时间戳中断信号
        .o_mac5_frame_seq                   ( o_rxmac5_frame_seq                 ) , // 帧序列号
        .o_timestamp5_addr                  ( o_rxtimestamp5_addr                ) , // 打时间戳存储的 RAM 地址
        // CB接口       
        .o_mac5_rtag_flag                    ( w_mac5_rtag_flag                       ),
        .o_mac5_rtag_squence                ( w_mac5_rtag_sequence                   ),
        .o_mac5_stream_handle                ( w_mac5_stream_handle                   ),
        .i_mac5_pass_en                      ( w_mac_pass_en[5]                         ),
        .i_mac5_discard_en                   ( w_mac_discard_en[5]                      ),
        .i_mac5_judge_finish                 ( w_mac_judge_finish[5]                    ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac5_cross_port_link              ( w_mac5_cross_port_link                 ), // 端口的连接状态
        .o_mac5_cross_port_speed             ( w_mac5_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac5_cross_port_axi_data          ( w_mac5_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac5_cross_port_axi_user          ( w_mac5_cross_port_axi_user             ), // 端口数据流用户信号
        .o_mac5_cross_axi_data_keep          ( w_mac5_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac5_cross_axi_data_valid         ( w_mac5_cross_axi_data_valid            ), // 端口数据有效
        .i_mac5_cross_axi_data_ready         ( w_mac5_cross_axi_data_ready            ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac5_cross_axi_data_last          ( w_mac5_cross_axi_data_last             ), // 数据流结束标识
        
        .o_mac5_cross_metadata               ( w_mac5_cross_metadata                 ), // 总线 metadata 数据
        .o_mac5_cross_metadata_valid         ( w_mac5_cross_metadata_valid           ), // 总线 metadata 数据有效信号
        .o_mac5_cross_metadata_last          ( w_mac5_cross_metadata_last            ), // 信息流结束标识
        .i_mac5_cross_metadata_ready         ( w_mac5_cross_metadata_ready           ), // 下游模块反压流水线 

		// emac帧快速通道
		.o_emac5_port_axi_data               (w_emac5_port_axi_data  ),      
		.o_emac5_port_axi_user               (w_emac5_port_axi_user  ),      
		.o_emac5_axi_data_keep               (w_emac5_axi_data_keep  ),      
		.o_emac5_axi_data_valid              (w_emac5_axi_data_valid ),      
		.i_emac5_axi_data_ready              (w_emac5_axi_data_ready ),   
		.o_emac5_axi_data_last               (w_emac5_axi_data_last  ),        
		.o_emac5_metadata                    (w_emac5_metadata       ),        
		.o_emac5_metadata_valid              (w_emac5_metadata_valid ),        
		.o_emac5_metadata_last               (w_emac5_metadata_last  ),        
		.i_emac5_metadata_ready              (w_emac5_metadata_ready ),  




        .o_tx5_req                           ( w_tx5_req                         ),
        .i_mac5_tx0_ack                      (w_mac5_tx0_ack                      ),
        .i_mac5_tx0_ack_rst                  (w_mac5_tx0_ack_rst                  ),
        .i_mac5_tx1_ack                      (w_mac5_tx1_ack                      ),
        .i_mac5_tx1_ack_rst                  (w_mac5_tx1_ack_rst                  ),
        .i_mac5_tx2_ack                      (w_mac5_tx2_ack                      ),
        .i_mac5_tx2_ack_rst                  (w_mac5_tx2_ack_rst                  ),
        .i_mac5_tx3_ack                      (w_mac5_tx3_ack                      ),
        .i_mac5_tx3_ack_rst                  (w_mac5_tx3_ack_rst                  ),
        .i_mac5_tx4_ack                      (w_mac5_tx4_ack                      ),
        .i_mac5_tx4_ack_rst                  (w_mac5_tx4_ack_rst                  ),
        .i_mac5_tx5_ack                      (w_mac5_tx5_ack                      ),
        .i_mac5_tx5_ack_rst                  (w_mac5_tx5_ack_rst                  ),
        .i_mac5_tx6_ack                      (w_mac5_tx6_ack                      ),
        .i_mac5_tx6_ack_rst                  (w_mac5_tx6_ack_rst                  ),
        .i_mac5_tx7_ack                      (w_mac5_tx7_ack                      ),
        .i_mac5_tx7_ack_rst                  (w_mac5_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC6 数据流 -------------------------------------------*/
    `ifdef MAC6
        // 数据流信息 
        .i_mac6_port_link                    ( i_mac6_port_link                   ) , // 端口的连接状态
        .i_mac6_port_speed                   ( i_mac6_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac6_port_filter_preamble_v       ( i_mac6_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac6_axi_data                     ( i_mac6_axi_data                    ) , // 端口数据流
        .i_mac6_axi_data_keep                ( i_mac6_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac6_axi_data_valid               ( i_mac6_axi_data_valid              ) , // 端口数据有效
        .o_mac6_axi_data_ready               ( o_mac6_axi_data_ready              ) , // 端口数据就绪信号，表示当前模块准备好接收数据
        .i_mac6_axi_data_last                ( i_mac6_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳 
        .o_mac6_time_irq                     ( o_rxmac6_time_irq                  ) , // 打时间戳中断信号
        .o_mac6_frame_seq                    ( o_rxmac6_frame_seq                 ) , // 帧序列号
        .o_timestamp6_addr                   ( o_rxtimestamp6_addr                ) , // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac6_rtag_flag                    ( w_mac6_rtag_flag                   ),
        .o_mac6_rtag_squence                 ( w_mac6_rtag_sequence               ),
        .o_mac6_stream_handle                ( w_mac6_stream_handle               ),
        .i_mac6_pass_en                      ( w_mac_pass_en[6]                   ),
        .i_mac6_discard_en                   ( w_mac_discard_en[6]                ),
        .i_mac6_judge_finish                 ( w_mac_judge_finish[6]              ), 
        /*---------------------------------------- 单 PORT 输出数据流 -------------------------------------------*/
        .o_mac6_cross_port_link              ( w_mac6_cross_port_link                 ), // 端口的连接状态
        .o_mac6_cross_port_speed             ( w_mac6_cross_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac6_cross_port_axi_data          ( w_mac6_cross_port_axi_data             ), // 端口数据流，最高位表示crcerr
        .o_mac6_cross_port_axi_user          ( w_mac6_cross_port_axi_user             ), // 端口数据流用户信号
        .o_mac6_cross_axi_data_keep          ( w_mac6_cross_axi_data_keep             ), // 端口数据流掩码，有效字节指示
        .o_mac6_cross_axi_data_valid         ( w_mac6_cross_axi_data_valid            ), // 端口数据有效
        .i_mac6_cross_axi_data_ready         ( w_mac6_cross_axi_data_ready            ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac6_cross_axi_data_last          ( w_mac6_cross_axi_data_last             ), // 数据流结束标识
                                                                                         
        .o_mac6_cross_metadata               ( w_mac6_cross_metadata                 ),  // 总线 metadata 数据
        .o_mac6_cross_metadata_valid         ( w_mac6_cross_metadata_valid           ),  // 总线 metadata 数据有效信号
        .o_mac6_cross_metadata_last          ( w_mac6_cross_metadata_last            ),  // 信息流结束标识
        .i_mac6_cross_metadata_ready         ( w_mac6_cross_metadata_ready           ),  // 下游模块反压流水线 

		// emac帧快速通道
		.o_emac6_port_axi_data               (w_emac6_port_axi_data  ),      
		.o_emac6_port_axi_user               (w_emac6_port_axi_user  ),      
		.o_emac6_axi_data_keep               (w_emac6_axi_data_keep  ),      
		.o_emac6_axi_data_valid              (w_emac6_axi_data_valid ),      
		.i_emac6_axi_data_ready              (w_emac6_axi_data_ready ), 
		.o_emac6_axi_data_last               (w_emac6_axi_data_last  ),        
		.o_emac6_metadata                    (w_emac6_metadata       ),        
		.o_emac6_metadata_valid              (w_emac6_metadata_valid ),        
		.o_emac6_metadata_last               (w_emac6_metadata_last  ),        
		.i_emac6_metadata_ready              (w_emac06_metadata_ready),



        .o_tx6_req                           (w_tx6_req                          ),
        .i_mac6_tx0_ack                      (w_mac6_tx0_ack                      ),
        .i_mac6_tx0_ack_rst                  (w_mac6_tx0_ack_rst                  ),
        .i_mac6_tx1_ack                      (w_mac6_tx1_ack                      ),
        .i_mac6_tx1_ack_rst                  (w_mac6_tx1_ack_rst                  ),
        .i_mac6_tx2_ack                      (w_mac6_tx2_ack                      ),
        .i_mac6_tx2_ack_rst                  (w_mac6_tx2_ack_rst                  ),
        .i_mac6_tx3_ack                      (w_mac6_tx3_ack                      ),
        .i_mac6_tx3_ack_rst                  (w_mac6_tx3_ack_rst                  ),
        .i_mac6_tx4_ack                      (w_mac6_tx4_ack                      ),
        .i_mac6_tx4_ack_rst                  (w_mac6_tx4_ack_rst                  ),
        .i_mac6_tx5_ack                      (w_mac6_tx5_ack                      ),
        .i_mac6_tx5_ack_rst                  (w_mac6_tx5_ack_rst                  ),
        .i_mac6_tx6_ack                      (w_mac6_tx6_ack                      ),
        .i_mac6_tx6_ack_rst                  (w_mac6_tx6_ack_rst                  ),
        .i_mac6_tx7_ack                      (w_mac6_tx7_ack                      ),
        .i_mac6_tx7_ack_rst                  (w_mac6_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- MAC7 数据流 -------------------------------------------*/
    `ifdef MAC7
        // 数据流信息
        .i_mac7_port_link                   ( i_mac7_port_link                   ) , // 端口的连接状态
        .i_mac7_port_speed                  ( i_mac7_port_speed                  ) , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
        .i_mac7_port_filter_preamble_v      ( i_mac7_port_filter_preamble_v      ) , // 端口是否过滤前导码信息
        .i_mac7_axi_data                    ( i_mac7_axi_data                    ) , // 端口数据流
        .i_mac7_axi_data_keep               ( i_mac7_axi_data_keep               ) , // 端口数据流掩码，有效字节指示
        .i_mac7_axi_data_valid              ( i_mac7_axi_data_valid              ) , // 端口数据有效
        .o_mac7_axi_data_ready              ( o_mac7_axi_data_ready              ) , // 端口数据就绪信号，表示当前模块准备好接收数据
        .i_mac7_axi_data_last               ( i_mac7_axi_data_last               ) , // 数据流结束标识
        // 报文时间打时间戳                                                             
        .o_mac7_time_irq                    ( o_rxmac7_time_irq                  ) , // 打时间戳中断信号
        .o_mac7_frame_seq                   ( o_rxmac7_frame_seq                 ) , // 帧序列号
        .o_timestamp7_addr                  ( o_rxtimestamp7_addr                ) , // 打时间戳存储的 RAM 地址
        // CB接口
        .o_mac7_rtag_flag                    ( w_mac7_rtag_flag                       ),
        .o_mac7_rtag_squence                ( w_mac7_rtag_sequence                   ),
        .o_mac7_stream_handle                ( w_mac7_stream_handle                   ),
        .i_mac7_pass_en                      ( w_mac_pass_en[7]                         ),
        .i_mac7_discard_en                   ( w_mac_discard_en[7]                      ),
        .i_mac7_judge_finish                 ( w_mac_judge_finish[7]                    ), 
        /*---------------------------------------- ???? PORT ??????????? -------------------------------------------*/
        .o_mac7_cross_port_link             ( w_mac7_cross_port_link            ), // 端口的连接状态
        .o_mac7_cross_port_speed            ( w_mac7_cross_port_speed           ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
        .o_mac7_cross_port_axi_data         ( w_mac7_cross_port_axi_data        ), // 端口数据流，最高位表示crcerr
        .o_mac7_cross_port_axi_user         ( w_mac7_cross_port_axi_user        ), // 端口数据流用户信号
        .o_mac7_cross_axi_data_keep         ( w_mac7_cross_axi_data_keep        ), // 端口数据流掩码，有效字节指示
        .o_mac7_cross_axi_data_valid        ( w_mac7_cross_axi_data_valid       ), // 端口数据有效
        .i_mac7_cross_axi_data_ready        ( w_mac7_cross_axi_data_ready       ), // 端口数据就绪信号，表示当前模块准备好接收数据
        .o_mac7_cross_axi_data_last         ( w_mac7_cross_axi_data_last        ), // 数据流结束标识
                                                                                   
        .o_mac7_cross_metadata              ( w_mac7_cross_metadata             ), // 总线 metadata 数据
        .o_mac7_cross_metadata_valid        ( w_mac7_cross_metadata_valid       ), // 总线 metadata 数据有效信号
        .o_mac7_cross_metadata_last         ( w_mac7_cross_metadata_last        ), // 信息流结束标识
        .i_mac7_cross_metadata_ready        ( w_mac7_cross_metadata_ready       ), // 下游模块反压流水线 


		// emac帧快速通道
		.o_emac7_port_axi_data               (w_emac7_port_axi_data  ),      
		.o_emac7_port_axi_user               (w_emac7_port_axi_user  ),      
		.o_emac7_axi_data_keep               (w_emac7_axi_data_keep  ),      
		.o_emac7_axi_data_valid              (w_emac7_axi_data_valid ),      
		.i_emac7_axi_data_ready              (w_emac7_axi_data_ready ), 
		.o_emac7_axi_data_last               (w_emac7_axi_data_last  ),        
		.o_emac7_metadata                    (w_emac7_metadata       ),        
		.o_emac7_metadata_valid              (w_emac7_metadata_valid ),        
		.o_emac7_metadata_last               (w_emac7_metadata_last  ),        
		.i_emac7_metadata_ready              (w_emac7_metadata_ready ),


        .o_tx7_req                          (w_tx7_req                          ),
        .i_mac7_tx0_ack                     (w_mac7_tx0_ack                      ),
        .i_mac7_tx0_ack_rst                 (w_mac7_tx0_ack_rst                  ),
        .i_mac7_tx1_ack                     (w_mac7_tx1_ack                      ),
        .i_mac7_tx1_ack_rst                 (w_mac7_tx1_ack_rst                  ),
        .i_mac7_tx2_ack                     (w_mac7_tx2_ack                      ),
        .i_mac7_tx2_ack_rst                 (w_mac7_tx2_ack_rst                  ),
        .i_mac7_tx3_ack                     (w_mac7_tx3_ack                      ),
        .i_mac7_tx3_ack_rst                 (w_mac7_tx3_ack_rst                  ),
        .i_mac7_tx4_ack                     (w_mac7_tx4_ack                      ),
        .i_mac7_tx4_ack_rst                 (w_mac7_tx4_ack_rst                  ),
        .i_mac7_tx5_ack                     (w_mac7_tx5_ack                      ),
        .i_mac7_tx5_ack_rst                 (w_mac7_tx5_ack_rst                  ),
        .i_mac7_tx6_ack                     (w_mac7_tx6_ack                      ),
        .i_mac7_tx6_ack_rst                 (w_mac7_tx6_ack_rst                  ),
        .i_mac7_tx7_ack                     (w_mac7_tx7_ack                      ),
        .i_mac7_tx7_ack_rst                 (w_mac7_tx7_ack_rst                  ),
    `endif
    /*---------------------------------------- 交换查找/学习的接口信息 -------------------------------------------*/
    `ifdef END_POINTER_SWITCH_CORE
        `ifdef CPU_MAC
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            // 交换表接口
            // to swlist 
            .o_vlan_id_cpu                       ( w_vlan_id_cpu                          ),
            .o_dmac_cpu_hash_key                 ( w_dmac_cpu_hash_key                    ), // 目的 mac 的哈希值
            .o_dmac_cpu                          ( w_dmac_cpu                             ), // 目的 mac 的值
            .o_dmac_cpu_vld                      ( w_dmac_cpu_vld                         ), // dmac_vld
            .o_smac_cpu_hash_key                 ( w_smac_cpu_hash_key                    ), // 源 mac 的值有效标识
            .o_smac_cpu                          ( w_smac_cpu                             ), // 源 mac 的值
            .o_smac_cpu_vld                      ( w_smac_cpu_vld                         ), // smac_vld
            // from swlist                                                                              
            .i_tx_cpu_port                       ( w_tx_cpu_port                          ), // 交换表模块返回的查表端口信息
            .i_tx_cpu_port_broadcast             ( w_tx_cpu_port_broadcast                ),
            .i_tx_cpu_port_vld                   ( w_tx_cpu_port_vld                      ),
        `endif
        `ifdef MAC1
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            // 交换表接口
            // to swlist 
            .o_vlan_id1                          ( w_vlan_id1                       ),
            .o_dmac1_hash_key                    ( w_dmac1_hash_key                 ), // 目的 mac 的哈希值
            .o_dmac1                             ( w_dmac1                          ), // 目的 mac 的值
            .o_dmac1_vld                         ( w_dmac1_vld                      ), // dmac_vld
            .o_smac1_hash_key                    ( w_smac1_hash_key                 ), // 源 mac 的值有效标识
            .o_smac1                             ( w_smac1                          ), // 源 mac 的值
            .o_smac1_vld                         ( w_smac1_vld                      ), // smac_vld
            // from swlist  
            .i_tx_1_port                         ( w_tx_1_port                      ), // 交换表模块返回的查表端口信息
            .i_tx_1_port_broadcast               ( w_tx_1_port_broadcast            ),
            .i_tx_1_port_vld                     ( w_tx_1_port_vld                  ),
        `endif
        `ifdef MAC2
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            // 交换表接口
            // to swlist 
            .o_vlan_id2                          ( w_vlan_id2                       ),
            .o_dmac2_hash_key                    ( w_dmac2_hash_key                 ), // 目的 mac 的哈希值
            .o_dmac2                             ( w_dmac2                          ), // 目的 mac 的值
            .o_dmac2_vld                         ( w_dmac2_vld                      ), // dmac_vld
            .o_smac2_hash_key                    ( w_smac2_hash_key                 ), // 源 mac 的值有效标识
            .o_smac2                             ( w_smac2                          ), // 源 mac 的值
            .o_smac2_vld                         ( w_smac2_vld                      ), // smac_vld
            // from swlist  
            .i_tx_2_port                        ( w_tx_2_port                        ) , // 交换表模块返回的查表端口信息
            .i_tx_2_port_broadcast              ( w_tx_2_port_broadcast              ) ,
            .i_tx_2_port_vld                    ( w_tx_2_port_vld                    ) ,
        `endif
        `ifdef MAC3
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            // 交换表接口
            // to swlist 
            .o_vlan_id3                         ( w_vlan_id3            ),
            .o_dmac3_hash_key                   ( w_dmac3_hash_key      ) , // 目的 mac 的哈希值
            .o_dmac3                            ( w_dmac3               ) , // 目的 mac 的值
            .o_dmac3_vld                        ( w_dmac3_vld           ) , // dmac_vld
            .o_smac3_hash_key                   ( w_smac3_hash_key      ) , // 源 mac 的值有效标识
            .o_smac3                            ( w_smac3               ) , // 源 mac 的值
            .o_smac3_vld                        ( w_smac3_vld           ) , // smac_vld
            // from swlist  
            .i_tx_3_port                        ( w_tx_3_port           ) , // 交换表模块返回的查表端口信息
            .i_tx_3_port_broadcast              ( w_tx_3_port_broadcast ) ,
            .i_tx_3_port_vld                    ( w_tx_3_port_vld       ) ,
        `endif
        `ifdef MAC4
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            .o_vlan_id4                         ( w_vlan_id4                         ),
            .o_dmac4_hash_key                   ( w_dmac4_hash_key      ) , // 目的 mac 的哈希值
            .o_dmac4                            ( w_dmac4               ) , // 目的 mac 的值
            .o_dmac4_vld                        ( w_dmac4_vld           ) , // dmac_vld
            .o_smac4_hash_key                   ( w_smac4_hash_key      ) , // 源 mac 的值有效标识
            .o_smac4                            ( w_smac4               ) , // 源 mac 的值
            .o_smac4_vld                        ( w_smac4_vld           ) , // smac_vld
        
            .i_tx_4_port                        ( w_tx_4_port           ) , // 交换表模块返回的查表端口信息
            .i_tx_4_port_broadcast              ( w_tx_4_port_broadcast     ) ,
            .i_tx_4_port_vld                    ( w_tx_4_port_vld       ) ,
        `endif
        `ifdef MAC5
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            .o_vlan_id5                         ( w_vlan_id5            ),
            .o_dmac5_hash_key                   ( w_dmac5_hash_key      ) , // 目的 mac 的哈希值
            .o_dmac5                            ( w_dmac5               ) , // 目的 mac 的值
            .o_dmac5_vld                        ( w_dmac5_vld           ) , // dmac_vld
            .o_smac5_hash_key                   ( w_smac5_hash_key      ) , // 源 mac 的值有效标识
            .o_smac5                            ( w_smac5               ) , // 源 mac 的值
            .o_smac5_vld                        ( w_smac5_vld           ) , // smac_vld

            .i_tx_5_port                        ( w_tx_5_port           ) , // 交换表模块返回的查表端口信息
            .i_tx_5_port_broadcast              ( w_tx_5_port_broadcast ) ,
            .i_tx_5_port_vld                    ( w_tx_5_port_vld       ) ,
        `endif
        `ifdef MAC6
            /*---------------------------------------- 计算的哈希值 --------------------------------------------*/
            .o_vlan_id6                          ( w_vlan_id6                         ),
            .o_dmac6_hash_key                    ( w_dmac6_hash_key                   ) , // 目的 mac 的哈希值
            .o_dmac6                             ( w_dmac6                            ) , // 目的 mac 的值
            .o_dmac6_vld                         ( w_dmac6_vld                        ) , // dmac_vld
            .o_smac6_hash_key                    ( w_smac6_hash_key                   ) , // 源 mac 的值有效标识
            .o_smac6                             ( w_smac6                            ) , // 源 mac 的值
            .o_smac6_vld                         ( w_smac6_vld                        ) , // smac_vld
        
            .i_tx_6_port                         ( w_tx_6_port                        ) , // 交换表模块返回的查表端口信息
            .i_tx_6_port_broadcast               ( w_tx_6_port_broadcast              ) ,
            .i_tx_6_port_vld                     ( w_tx_6_port_vld                    ) ,
        `endif
        `ifdef MAC7
            /*---------------------------------------- 计算的哈希值 -------------------------------------------*/
            .o_vlan_id7                         ( w_vlan_id7                        ),
            .o_dmac7_hash_key                   ( w_dmac7_hash_key                  ) , // 目的 mac 的哈希值
            .o_dmac7                            ( w_dmac7                           ) , // 目的 mac 的值
            .o_dmac7_vld                        ( w_dmac7_vld                       ) , // dmac_vld
            .o_smac7_hash_key                   ( w_smac7_hash_key                  ) , // 源 mac 的值有效标识
            .o_smac7                            ( w_smac7                           ) , // 源 mac 的值
            .o_smac7_vld                        ( w_smac7_vld                       ) , // smac_vld
                                                                                        
            .i_tx_7_port                        ( w_tx_7_port                       ) , // 交换表模块返回的查表端口信息
            .i_tx_7_port_broadcast              ( w_tx_7_port_broadcast             ) ,
            .i_tx_7_port_vld                    ( w_tx_7_port_vld                   ) ,
        `endif
    `endif
        /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
        // 寄存器控制信号                     
        .i_refresh_list_pulse                ( w_refresh_list_pulse      ), // 刷新寄存器列表（状态寄存器和控制寄存器）
        .i_switch_err_cnt_clr                ( w_switch_err_cnt_clr      ), // 刷新错误计数器
        .i_switch_err_cnt_stat               ( w_switch_err_cnt_stat     ), // 刷新错误状态寄存器
        // 寄存器写控制接口                                                    
        .i_switch_reg_bus_we                 ( w_rxmac_reg_bus_we        ), // 寄存器写使能
        .i_switch_reg_bus_we_addr            ( w_rxmac_reg_bus_we_addr   ), // 寄存器写地址
        .i_switch_reg_bus_we_din             ( w_rxmac_reg_bus_we_din    ), // 寄存器写数据
        .i_switch_reg_bus_we_din_v           ( w_rxmac_reg_bus_we_din_v  ), // 寄存器写数据使能
        // 寄存器读控制接口                                                    
        .i_switch_reg_bus_rd                 ( w_rxmac_reg_bus_rd        ), // 寄存器读使能
        .i_switch_reg_bus_rd_addr            ( w_rxmac_reg_bus_rd_addr   ), // 寄存器读地址
        .o_switch_reg_bus_rd_dout            ( w_rxmac_reg_bus_rd_dout   ), // 读出寄存器数据
        .o_switch_reg_bus_rd_dout_v          ( w_rxmac_reg_bus_rd_dout_v )  // 读数据有效使能
);

/*---------------------------- swlist ---------------------------*/
`ifdef END_POINTER_SWITCH_CORE
    swlist#(
        .PORT_NUM                   ( PORT_NUM                  ),  // 交换机的端口数
        .PORT_WIDTH                 ( PORT_NUM                  ),  // 端口宽度等于端口数
        .PORTBIT_WIDTH              ( 3                         ),  // 端口比特位宽
        .REG_ADDR_BUS_WIDTH         ( REG_ADDR_OFS_WIDTH        ),  // 接收 MAC 层的配置寄存器地址位宽
        .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH        ),  // 接收 MAC 层的配置寄存器数据位宽
        .METADATA_WIDTH             ( METADATA_WIDTH            ),  // 信息流（METADATA）的位宽
        .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH       ),  // Mac_port_mng 数据位宽 
        .HASH_DATA_WIDTH            ( HASH_DATA_WIDTH           ),  // 哈希计算的值的位宽
        .ADDR_WIDTH                 (   6                       ),  // 地址表的深度
        .VLAN_ID_WIDTH              (   12                      ),  // VLAN ID 的位宽
        .MAC_ADDR_WIDTH             (   48                      ),  // MAC 地址的位宽
        .STATIC_RAM_SIZE            (   256                     ),  // 静态 RAM 大小
        .AGE_SCAN_INTERVAL          (   5                       ),  // 老化扫描间隔
        .SIM_MODE                   (   0                       ),  // 仿真模式，0 表示非仿真
        .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH          )   // 聚合总线输出宽度
    )swlist_inst (  
            .i_clk                      ( i_clk                     ) ,   // 250MHz
            .i_rst                      ( i_rst                     ) ,   
        `ifdef CPU_MAC  
            .i_vlan_id_cpu              ( w_vlan_id_cpu              ) ,
            .i_dmac_cpu_hash_key        ( w_dmac_cpu_hash_key        ) , // 目的 MAC 地址的哈希值
            .i_dmac_cpu                 ( w_dmac_cpu                 ) , // 目的 MAC 地址
            .i_dmac_cpu_vld             ( w_dmac_cpu_vld             ) , // 目的 MAC 地址有效标志
            .i_smac_cpu_hash_key        ( w_smac_cpu_hash_key        ) , // 源 MAC 地址的哈希值
            .i_smac_cpu                 ( w_smac_cpu                 ) , // 源 MAC 地址
            .i_smac_cpu_vld             ( w_smac_cpu_vld             ) , // 源 MAC 地址有效标志
        
            .o_tx_cpu_port              ( w_tx_cpu_port              ) ,
            .o_tx_cpu_port_broadcast    ( w_tx_cpu_port_broadcast    ) ,
            .o_tx_cpu_port_vld          ( w_tx_cpu_port_vld          ) ,
        `endif      
        `ifdef MAC1 
            .i_vlan_id1                 ( w_vlan_id1                 ) ,
            .i_dmac1_hash_key           ( w_dmac1_hash_key           ) , // 目的 MAC 地址的哈希值
            .i_dmac1                    ( w_dmac1                    ) , // 目的 MAC 地址
            .i_dmac1_vld                ( w_dmac1_vld                ) , // 目的 MAC 地址有效标志
            .i_smac1_hash_key           ( w_smac1_hash_key           ) , // 源 MAC 地址的哈希值
            .i_smac1                    ( w_smac1                    ) , // 源 MAC 地址
            .i_smac1_vld                ( w_smac1_vld                ) , // 源 MAC 地址有效标志
        
            .o_tx_1_port                ( w_tx_1_port                ) ,
            .o_tx_1_port_broadcast      ( w_tx_1_port_broadcast      ) ,
            .o_tx_1_port_vld            ( w_tx_1_port_vld            ) ,
        `endif      
        `ifdef MAC2 
            .i_vlan_id2                 ( w_vlan_id2                 ) ,
            .i_dmac2_hash_key           ( w_dmac2_hash_key           ) , // 目的 MAC 地址的哈希值
            .i_dmac2                    ( w_dmac2                    ) , // 目的 MAC 地址
            .i_dmac2_vld                ( w_dmac2_vld                ) , // 目的 MAC 地址有效标志
            .i_smac2_hash_key           ( w_smac2_hash_key           ) , // 源 MAC 地址的哈希值
            .i_smac2                    ( w_smac2                    ) , // 源 MAC 地址
            .i_smac2_vld                ( w_smac2_vld                ) , // 源 MAC 地址有效标志
        
            .o_tx_2_port                ( w_tx_2_port                ) ,
            .o_tx_2_port_broadcast      ( w_tx_2_port_broadcast      ) ,
            .o_tx_2_port_vld            ( w_tx_2_port_vld            ) ,
        `endif    
        `ifdef MAC3   
            .i_vlan_id3                 ( w_vlan_id3                 ) ,
            .i_dmac3_hash_key           ( w_dmac3_hash_key           ) , // 目的 MAC 地址的哈希值
            .i_dmac3                    ( w_dmac3                    ) , // 目的 MAC 地址
            .i_dmac3_vld                ( w_dmac3_vld                ) , // 目的 MAC 地址有效标志
            .i_smac3_hash_key           ( w_smac3_hash_key           ) , // 源 MAC 地址的哈希值
            .i_smac3                    ( w_smac3                    ) , // 源 MAC 地址
            .i_smac3_vld                ( w_smac3_vld                ) , // 源 MAC 地址有效标志
        
            .o_tx_3_port                ( w_tx_3_port                ) ,
            .o_tx_3_port_broadcast      ( w_tx_3_port_broadcast      ) ,
            .o_tx_3_port_vld            ( w_tx_3_port_vld            ) ,
        `endif    
        `ifdef MAC4   
            .i_vlan_id4                 ( w_vlan_id4                 ) , // 目的 MAC 地址的哈希值
            .i_dmac4_hash_key           ( w_dmac4_hash_key           ) , // 目的 MAC 地址
            .i_dmac4                    ( w_dmac4                    ) , // 目的 MAC 地址有效标志
            .i_dmac4_vld                ( w_dmac4_vld                ) , // 源 MAC 地址的哈希值
            .i_smac4_hash_key           ( w_smac4_hash_key           ) , // 源 MAC 地址
            .i_smac4                    ( w_smac4                    ) , // 源 MAC 地址有效标志
            .i_smac4_vld                ( w_smac4_vld                ) , 
        
            .o_tx_4_port                ( w_tx_4_port                ) ,
            .o_tx_4_port_broadcast      ( w_tx_4_port_broadcast      ) ,
            .o_tx_4_port_vld            ( w_tx_4_port_vld            ) ,
        `endif  
        `ifdef MAC5 
            .i_vlan_id5                 ( w_vlan_id5                 ) ,
            .i_dmac5_hash_key           ( w_dmac5_hash_key )            , // 目的 MAC 地址的哈希值
            .i_dmac5                    ( w_dmac5          )            , // 目的 MAC 地址
            .i_dmac5_vld                ( w_dmac5_vld      )            , // 目的 MAC 地址有效标志
            .i_smac5_hash_key           ( w_smac5_hash_key )            , // 源 MAC 地址的哈希值
            .i_smac5                    ( w_smac5          )            , // 源 MAC 地址
            .i_smac5_vld                ( w_smac5_vld      )            , // 源 MAC 地址有效标志
        
            .o_tx_5_port                ( w_tx_5_port      )            ,
            .o_tx_5_port_broadcast      ( w_tx_5_port_broadcast      ) ,
            .o_tx_5_port_vld            ( w_tx_5_port_vld  )            ,
        `endif    
        `ifdef MAC6   
            .i_vlan_id6                 ( w_vlan_id6                 ) ,
            .i_dmac6_hash_key           ( w_dmac6_hash_key )            , // 目的 MAC 地址的哈希值
            .i_dmac6                    ( w_dmac6          )            , // 目的 MAC 地址
            .i_dmac6_vld                ( w_dmac6_vld      )            , // 目的 MAC 地址有效标志
            .i_smac6_hash_key           ( w_smac6_hash_key )            , // 源 MAC 地址的哈希值
            .i_smac6                    ( w_smac6          )            , // 源 MAC 地址
            .i_smac6_vld                ( w_smac6_vld      )            , // 源 MAC 地址有效标志
        
            .o_tx_6_port                ( w_tx_6_port      )            ,
            .o_tx_6_port_broadcast      ( w_tx_6_port_broadcast      ) ,
            .o_tx_6_port_vld            ( w_tx_6_port_vld  )            ,
        `endif    
        `ifdef MAC7   
            .i_vlan_id7                 ( w_vlan_id7                 ) ,
            .i_dmac7_hash_key           ( w_dmac7_hash_key )            , // 目的 MAC 地址的哈希值
            .i_dmac7                    ( w_dmac7          )            , // 目的 MAC 地址
            .i_dmac7_vld                ( w_dmac7_vld      )            , // 目的 MAC 地址有效标志
            .i_smac7_hash_key           ( w_smac7_hash_key )            , // 源 MAC 地址的哈希值
            .i_smac7                    ( w_smac7          )            , // 源 MAC 地址
            .i_smac7_vld                ( w_smac7_vld      )            , // 源 MAC 地址有效标志
        
            .o_tx_7_port                ( w_tx_7_port      )            ,
            .o_tx_7_port_broadcast      ( w_tx_7_port_broadcast      ) ,
            .o_tx_7_port_vld            ( w_tx_7_port_vld  )            ,
        `endif  
            /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
            // 寄存器控制信号                     
            .i_refresh_list_pulse                ( w_refresh_list_pulse      ), // 刷新寄存器列表（状态寄存器和控制寄存器）
            .i_switch_err_cnt_clr                ( w_switch_err_cnt_clr      ), // 刷新错误计数器
            .i_switch_err_cnt_stat               ( w_switch_err_cnt_stat     ), // 刷新错误状态寄存器
            // 寄存器写控制接口                                                    
            .i_switch_reg_bus_we                 ( w_swlist_reg_bus_we        ), // 寄存器写使能
            .i_switch_reg_bus_we_addr            ( w_swlist_reg_bus_we_addr   ), // 寄存器写地址
            .i_switch_reg_bus_we_din             ( w_swlist_reg_bus_we_din    ), // 寄存器写数据
            .i_switch_reg_bus_we_din_v           ( w_swlist_reg_bus_we_din_v  ), // 寄存器写数据使能
            // 寄存器读控制接口                                                    
            .i_switch_reg_bus_rd                 ( w_swlist_reg_bus_rd        ), // 寄存器读使能
            .i_switch_reg_bus_rd_addr            ( w_swlist_reg_bus_rd_addr   ), // 寄存器读地址
            .o_switch_reg_bus_rd_dout            ( w_swlist_reg_bus_rd_dout   ), // 读出寄存器数据
            .o_switch_reg_bus_rd_dout_v          ( w_swlist_reg_bus_rd_dout_v )  // 读数据有效使能
    );
`endif


tsn_cb_top#(
    .RECOVERY_MODE              ( 0                         ),  // 0:向量恢复算法 1：匹配恢复算法
    .PORT_NUM                   ( PORT_NUM                  ),  // 交换机的端口数
    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_OFS_WIDTH        ),  // 接收 MAC 层的配置寄存器地址位宽
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH        )   // 接收 MAC 层的配置寄存器数据位宽
)tsn_cb_top_inst ( 
        .i_clk                      ( i_clk                     ),  // 250MHz
        .i_rst                      ( i_rst                     ),
    `ifdef CPU_MAC
        .i_rtag_flag0               ( w_mac0_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence0            ( w_mac0_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle0           ( w_mac0_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC1                                                        
        .i_rtag_flag1               ( w_mac1_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence1            ( w_mac1_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle1           ( w_mac1_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC2                                                        
        .i_rtag_flag2               ( w_mac2_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence2            ( w_mac2_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle2           ( w_mac2_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC3                                                        
        .i_rtag_flag3               ( w_mac3_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence3            ( w_mac3_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle3           ( w_mac3_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC4                                                        
        .i_rtag_flag4               ( w_mac4_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence4            ( w_mac4_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle4           ( w_mac4_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC5                                                        
        .i_rtag_flag5               ( w_mac5_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence5            ( w_mac5_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle5           ( w_mac5_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC6                                                        
        .i_rtag_flag6               ( w_mac6_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence6            ( w_mac6_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle6           ( w_mac6_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
    `ifdef MAC7                                                        
        .i_rtag_flag7               ( w_mac7_rtag_flag               ), // 是否携带rtag标签
        .i_rtag_squence7            ( w_mac7_rtag_sequence           ), // rtag_squencenum
        .i_stream_handle7           ( w_mac7_stream_handle           ), // 区分流,每个流单独维护自己的 
    `endif                                                             
                                                                       
        .o_pass_en                  ( w_mac_pass_en                  ), // 判断结果,可以接收该帧
        .o_discard_en               ( w_mac_discard_en               ), // 判断结果,可以丢弃该帧
        .o_judge_finish             ( w_mac_judge_finish             ), // 判断结果,表示本次报文的判断完成
        /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
        // 寄存器控制信号                     
        .i_refresh_list_pulse                ( w_refresh_list_pulse      ), // 刷新寄存器列表（状态寄存器和控制寄存器）
        .i_switch_err_cnt_clr                ( w_switch_err_cnt_clr      ), // 刷新错误计数器
        .i_switch_err_cnt_stat               ( w_switch_err_cnt_stat     ), // 刷新错误状态寄存器
        // 寄存器写控制接口                                                    
        .i_switch_reg_bus_we                 ( w_cb_reg_bus_we        ), // 寄存器写使能
        .i_switch_reg_bus_we_addr            ( w_cb_reg_bus_we_addr   ), // 寄存器写地址
        .i_switch_reg_bus_we_din             ( w_cb_reg_bus_we_din    ), // 寄存器写数据
        .i_switch_reg_bus_we_din_v           ( w_cb_reg_bus_we_din_v  ), // 寄存器写数据使能
        // 寄存器读控制接口                                                    
        .i_switch_reg_bus_rd                 ( w_cb_reg_bus_rd        ), // 寄存器读使能
        .i_switch_reg_bus_rd_addr            ( w_cb_reg_bus_rd_addr   ), // 寄存器读地址
        .o_switch_reg_bus_rd_dout            ( w_cb_reg_bus_rd_dout   ), // 读出寄存器数据
        .o_switch_reg_bus_rd_dout_v          ( w_cb_reg_bus_rd_dout_v )  // 读数据有效使能
);


crossbar_switch_top#(
    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_BUS_WIDTH         )     ,  // ???? MAC ??????ü???????λ??
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH         )     ,  // ???? MAC ??????ü????????λ??
    .METADATA_WIDTH             ( METADATA_WIDTH             )     ,  // ???????METADATA????λ??
    .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH        )     ,
    .PORT_FIFO_PRI_NUM          ( PORT_FIFO_PRI_NUM          )     ,
    .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH           )      // ?????????? 
)crossbar_switch_top_inst (
        .i_clk                        ( i_clk                     )       ,   // 250MHz
        .i_rst                        ( i_rst                     )       , 
    /*-------------------- RXMAC ?????????? -----------------------*/
    `ifdef CPU_MAC
        //.i_mac0_cross_port_link      ( w_mac0_cross_port_link       )        , 
        //.i_mac0_cross_port_speed     ( w_mac0_cross_port_speed      )        ,  
        .i_mac0_cross_port_axi_data  ( w_mac0_cross_port_axi_data   )        , // ??????????????λ???crcerr
        .i_mac0_cross_axi_data_keep  ( w_mac0_cross_axi_data_keep   )        , // ???????????????Ч?????
        .i_mac0_cross_axi_data_user  ( w_mac0_cross_port_axi_user   )        ,
        .i_mac0_cross_axi_data_valid ( w_mac0_cross_axi_data_valid  )        , // ?????????Ч
        .o_mac0_cross_axi_data_ready ( w_mac0_cross_axi_data_ready  )        , // ???????????????????????
        .i_mac0_cross_axi_data_last  ( w_mac0_cross_axi_data_last   )        , // ?????????????
        
        .i_mac0_cross_metadata       ( w_mac0_cross_metadata     )        ,   // ???? metadata ????
        .i_mac0_cross_metadata_valid ( w_mac0_cross_metadata_valid )        , // ???? metadata ??????Ч???
        .i_mac0_cross_metadata_last  ( w_mac0_cross_metadata_last  )        , // ????????????
        .o_mac0_cross_metadata_ready ( w_mac0_cross_metadata_ready )        , // ??????鷴?????? 
        // RXMAC TO CROSSBAR
        .i_tx0_req                   (w_tx0_req  ) ,			
        .o_mac0_tx0_ack              (w_mac0_tx0_ack  ) , 			// ?????????
        .o_mac0_tx0_ack_rst          (w_mac0_tx0_ack_rst) ,         // ????????????????
        .o_mac0_tx1_ack              (w_mac0_tx1_ack) ,             // ?????????
        .o_mac0_tx1_ack_rst          (w_mac0_tx1_ack_rst) ,         // ????????????????  
        .o_mac0_tx2_ack              (w_mac0_tx2_ack) ,             // ?????????
        .o_mac0_tx2_ack_rst          (w_mac0_tx2_ack_rst) ,         // ????????????????
        .o_mac0_tx3_ack              (w_mac0_tx3_ack) ,             // ?????????
        .o_mac0_tx3_ack_rst          (w_mac0_tx3_ack_rst) ,         // ????????????????
        .o_mac0_tx4_ack              (w_mac0_tx4_ack) ,             // ?????????
        .o_mac0_tx4_ack_rst          (w_mac0_tx4_ack_rst) ,         // ????????????????
        .o_mac0_tx5_ack              (w_mac0_tx5_ack) ,             // ?????????
        .o_mac0_tx5_ack_rst          (w_mac0_tx5_ack_rst) ,         // ????????????????
        .o_mac0_tx6_ack              (w_mac0_tx6_ack) ,             // ?????????
        .o_mac0_tx6_ack_rst          (w_mac0_tx6_ack_rst) ,         // ????????????????
        .o_mac0_tx7_ack              (w_mac0_tx7_ack) ,             // ?????????
        .o_mac0_tx7_ack_rst          (w_mac0_tx7_ack_rst) ,         // ????????????????

        .i_rxmac0_qbu_axis_data      (w_emac0_port_axi_data      ) , 
        .i_rxmac0_qbu_axis_keep      (w_emac0_axi_data_keep      ) , 
        .i_rxmac0_qbu_axis_user      (w_emac0_port_axi_user      ) , 
        .i_rxmac0_qbu_axis_valid     (w_emac0_axi_data_valid     ) , 
        .o_rxmac0_qbu_axis_ready     (w_emac0_axi_data_ready	 ) ,
        .i_rxmac0_qbu_axis_last      (w_emac0_axi_data_last      ) , 
        .i_rxmac0_qbu_metadata       (w_emac0_metadata           ) , 
        .i_rxmac0_qbu_metadata_valid (w_emac0_metadata_valid     ) , 
        .i_rxmac0_qbu_metadata_last  (w_emac0_metadata_last      ) , 
        .o_rxmac0_qbu_metadata_ready (w_emac0_metadata_ready	 ) ,                           

    `endif
    `ifdef MAC1
        //.i_mac1_cross_port_link         ( w_mac1_cross_port_link        )        , 
        //.i_mac1_cross_port_speed        ( w_mac1_cross_port_speed       )        , 
        .i_mac1_cross_port_axi_data     ( w_mac1_cross_port_axi_data    )        , // ??????????????λ???crcerr
        .i_mac1_cross_axi_data_keep     ( w_mac1_cross_axi_data_keep    )        , // ???????????????Ч?????
        .i_mac1_cross_axi_data_user     ( w_mac1_cross_port_axi_user    )        ,
        .i_mac1_cross_axi_data_valid    ( w_mac1_cross_axi_data_valid   )        , // ?????????Ч
        .o_mac1_cross_axi_data_ready    ( w_mac1_cross_axi_data_ready   )        , // ???????????????????????
        .i_mac1_cross_axi_data_last     ( w_mac1_cross_axi_data_last    )        , // ?????????????
                                                                                   
        .i_mac1_cross_metadata          ( w_mac1_cross_metadata         )        , // ???? metadata ????
        .i_mac1_cross_metadata_valid    ( w_mac1_cross_metadata_valid   )        , // ???? metadata ??????Ч???
        .i_mac1_cross_metadata_last     ( w_mac1_cross_metadata_last    )        , // ????????????
        .o_mac1_cross_metadata_ready    ( w_mac1_cross_metadata_ready   )        , // ??????鷴?????? 

        .i_tx1_req                      ( w_tx1_req ) ,
        .o_mac1_tx0_ack                 ( w_mac1_tx0_ack              ) , 
        .o_mac1_tx0_ack_rst             ( w_mac1_tx0_ack_rst          ) , 
        .o_mac1_tx1_ack                 ( w_mac1_tx1_ack              ) , 
        .o_mac1_tx1_ack_rst             ( w_mac1_tx1_ack_rst          ) , 
        .o_mac1_tx2_ack                 ( w_mac1_tx2_ack              ) , 
        .o_mac1_tx2_ack_rst             ( w_mac1_tx2_ack_rst          ) , 
        .o_mac1_tx3_ack                 ( w_mac1_tx3_ack              ) , 
        .o_mac1_tx3_ack_rst             ( w_mac1_tx3_ack_rst          ) , 
        .o_mac1_tx4_ack                 ( w_mac1_tx4_ack              ) , 
        .o_mac1_tx4_ack_rst             ( w_mac1_tx4_ack_rst          ) , 
        .o_mac1_tx5_ack                 ( w_mac1_tx5_ack              ) , 
        .o_mac1_tx5_ack_rst             ( w_mac1_tx5_ack_rst          ) , 
        .o_mac1_tx6_ack                 ( w_mac1_tx6_ack              ) , 
        .o_mac1_tx6_ack_rst             ( w_mac1_tx6_ack_rst          ) , 
        .o_mac1_tx7_ack                 ( w_mac1_tx7_ack              ) , 
        .o_mac1_tx7_ack_rst             ( w_mac1_tx7_ack_rst          ) , 
        .i_rxmac1_qbu_axis_data         (w_emac1_port_axi_data      ) , 
        .i_rxmac1_qbu_axis_keep         (w_emac1_axi_data_keep      ) , 
        .i_rxmac1_qbu_axis_user         (w_emac1_port_axi_user      ) , 
        .i_rxmac1_qbu_axis_valid        (w_emac1_axi_data_valid     ) , 
        .o_rxmac1_qbu_axis_ready        (w_emac1_axi_data_ready		) ,
        .i_rxmac1_qbu_axis_last         (w_emac1_axi_data_last      ) , 
        .i_rxmac1_qbu_metadata          (w_emac1_metadata           ) , 
        .i_rxmac1_qbu_metadata_valid    (w_emac1_metadata_valid     ) , 
        .i_rxmac1_qbu_metadata_last     (w_emac1_metadata_last      ) , 
        .o_rxmac1_qbu_metadata_ready    (w_emac1_metadata_ready		) ,                           
    `endif
    `ifdef MAC2
        //.i_mac2_cross_port_link        ( w_mac2_cross_port_link         )        , 
        //.i_mac2_cross_port_speed       ( w_mac2_cross_port_speed        )        , 
        .i_mac2_cross_port_axi_data    ( w_mac2_cross_port_axi_data     )        , // ??????????????λ???crcerr
        .i_mac2_cross_axi_data_keep    ( w_mac2_cross_axi_data_keep     )        , // ???????????????Ч?????
        .i_mac2_cross_axi_data_user    ( w_mac2_cross_port_axi_user   )        ,
        .i_mac2_cross_axi_data_valid   ( w_mac2_cross_axi_data_valid    )        , // ?????????Ч
        .o_mac2_cross_axi_data_ready   ( w_mac2_cross_axi_data_ready    )        , // ???????????????????????
        .i_mac2_cross_axi_data_last    ( w_mac2_cross_axi_data_last     )        , // ?????????????
                                                                                      
        .i_mac2_cross_metadata         ( w_mac2_cross_metadata          )        , // ???? metadata ????
        .i_mac2_cross_metadata_valid   ( w_mac2_cross_metadata_valid    )        , // ???? metadata ??????Ч???
        .i_mac2_cross_metadata_last    ( w_mac2_cross_metadata_last     )        , // ????????????
        .o_mac2_cross_metadata_ready   ( w_mac2_cross_metadata_ready    )        , // ??????鷴?????? 

        .i_tx2_req                      ( w_tx2_req ) ,
        .o_mac2_tx0_ack                 ( w_mac2_tx0_ack              ) , 
        .o_mac2_tx0_ack_rst             ( w_mac2_tx0_ack_rst          ) , 
        .o_mac2_tx1_ack                 ( w_mac2_tx1_ack              ) , 
        .o_mac2_tx1_ack_rst             ( w_mac2_tx1_ack_rst          ) , 
        .o_mac2_tx2_ack                 ( w_mac2_tx2_ack              ) , 
        .o_mac2_tx2_ack_rst             ( w_mac2_tx2_ack_rst          ) , 
        .o_mac2_tx3_ack                 ( w_mac2_tx3_ack              ) , 
        .o_mac2_tx3_ack_rst             ( w_mac2_tx3_ack_rst          ) , 
        .o_mac2_tx4_ack                 ( w_mac2_tx4_ack              ) , 
        .o_mac2_tx4_ack_rst             ( w_mac2_tx4_ack_rst          ) , 
        .o_mac2_tx5_ack                 ( w_mac2_tx5_ack              ) , 
        .o_mac2_tx5_ack_rst             ( w_mac2_tx5_ack_rst          ) , 
        .o_mac2_tx6_ack                 ( w_mac2_tx6_ack              ) , 
        .o_mac2_tx6_ack_rst             ( w_mac2_tx6_ack_rst          ) , 
        .o_mac2_tx7_ack                 ( w_mac2_tx7_ack              ) , 
        .o_mac2_tx7_ack_rst             ( w_mac2_tx7_ack_rst          ) , 
        .i_rxmac2_qbu_axis_data         (w_emac2_port_axi_data      ) , 
        .i_rxmac2_qbu_axis_keep         (w_emac2_axi_data_keep      ) , 
        .i_rxmac2_qbu_axis_user         (w_emac2_port_axi_user      ) , 
        .i_rxmac2_qbu_axis_valid        (w_emac2_axi_data_valid     ) , 
        .o_rxmac2_qbu_axis_ready        (w_emac2_axi_data_ready		) ,
        .i_rxmac2_qbu_axis_last         (w_emac2_axi_data_last      ) , 
        .i_rxmac2_qbu_metadata          (w_emac2_metadata           ) , 
        .i_rxmac2_qbu_metadata_valid    (w_emac2_metadata_valid     ) , 
        .i_rxmac2_qbu_metadata_last     (w_emac2_metadata_last      ) , 
        .o_rxmac2_qbu_metadata_ready    (w_emac2_metadata_ready 	) ,                           
    `endif
    `ifdef MAC3
        //.i_mac3_cross_port_link         ( w_mac3_cross_port_link        )        , 
        //.i_mac3_cross_port_speed        ( w_mac3_cross_port_speed       )        , 
        .i_mac3_cross_port_axi_data     ( w_mac3_cross_port_axi_data    )        , // ??????????????λ???crcerr
        .i_mac3_cross_axi_data_keep     ( w_mac3_cross_axi_data_keep    )        , // ???????????????Ч?????
        .i_mac3_cross_axi_data_user     ( w_mac3_cross_port_axi_user   )        ,
        .i_mac3_cross_axi_data_valid    ( w_mac3_cross_axi_data_valid   )        , // ?????????Ч
        .o_mac3_cross_axi_data_ready    ( w_mac3_cross_axi_data_ready   )        , // ???????????????????????
        .i_mac3_cross_axi_data_last     ( w_mac3_cross_axi_data_last    )        , // ?????????????
                                                                                      
        .i_mac3_cross_metadata          ( w_mac3_cross_metadata         )        , // ???? metadata ????
        .i_mac3_cross_metadata_valid    ( w_mac3_cross_metadata_valid   )        , // ???? metadata ??????Ч???
        .i_mac3_cross_metadata_last     ( w_mac3_cross_metadata_last    )        , // ????????????
        .o_mac3_cross_metadata_ready    ( w_mac3_cross_metadata_ready   )        , // ??????鷴?????? 

        .i_tx3_req                      ( w_tx3_req ) ,
        .o_mac3_tx0_ack                 ( w_mac3_tx0_ack              ) , 
        .o_mac3_tx0_ack_rst             ( w_mac3_tx0_ack_rst          ) , 
        .o_mac3_tx1_ack                 ( w_mac3_tx1_ack              ) , 
        .o_mac3_tx1_ack_rst             ( w_mac3_tx1_ack_rst          ) , 
        .o_mac3_tx2_ack                 ( w_mac3_tx2_ack              ) , 
        .o_mac3_tx2_ack_rst             ( w_mac3_tx2_ack_rst          ) , 
        .o_mac3_tx3_ack                 ( w_mac3_tx3_ack              ) , 
        .o_mac3_tx3_ack_rst             ( w_mac3_tx3_ack_rst          ) , 
        .o_mac3_tx4_ack                 ( w_mac3_tx4_ack              ) , 
        .o_mac3_tx4_ack_rst             ( w_mac3_tx4_ack_rst          ) , 
        .o_mac3_tx5_ack                 ( w_mac3_tx5_ack              ) , 
        .o_mac3_tx5_ack_rst             ( w_mac3_tx5_ack_rst          ) , 
        .o_mac3_tx6_ack                 ( w_mac3_tx6_ack              ) , 
        .o_mac3_tx6_ack_rst             ( w_mac3_tx6_ack_rst          ) , 
        .o_mac3_tx7_ack                 ( w_mac3_tx7_ack              ) , 
        .o_mac3_tx7_ack_rst             ( w_mac3_tx7_ack_rst          ) , 
        .i_rxmac3_qbu_axis_data         (w_emac3_port_axi_data      ) , 
        .i_rxmac3_qbu_axis_keep         (w_emac3_axi_data_keep      ) , 
        .i_rxmac3_qbu_axis_user         (w_emac3_port_axi_user      ) , 
        .i_rxmac3_qbu_axis_valid        (w_emac3_axi_data_valid     ) , 
        .o_rxmac3_qbu_axis_ready        (w_emac3_axi_data_ready		) ,
        .i_rxmac3_qbu_axis_last         (w_emac3_axi_data_last      ) , 
        .i_rxmac3_qbu_metadata          (w_emac3_metadata           ) , 
        .i_rxmac3_qbu_metadata_valid    (w_emac3_metadata_valid     ) , 
        .i_rxmac3_qbu_metadata_last     (w_emac3_metadata_last      ) , 
        .o_rxmac3_qbu_metadata_ready    (w_emac3_metadata_ready 	) ,                           
    `endif
    `ifdef MAC4
        //.i_mac4_cross_port_link         ( w_mac4_cross_port_link        )        ,
        //.i_mac4_cross_port_speed        ( w_mac4_cross_port_speed       )        , 
        .i_mac4_cross_port_axi_data     ( w_mac4_cross_port_axi_data    )        , // ??????????????λ???crcerr
        .i_mac4_cross_axi_data_keep     ( w_mac4_cross_axi_data_keep    )        , // ???????????????Ч?????
        .i_mac4_cross_axi_data_user     ( w_mac4_cross_port_axi_user   )         ,
        .i_mac4_cross_axi_data_valid    ( w_mac4_cross_axi_data_valid   )        , // ?????????Ч
        .o_mac4_cross_axi_data_ready    ( w_mac4_cross_axi_data_ready   )        , // ???????????????????????
        .i_mac4_cross_axi_data_last     ( w_mac4_cross_axi_data_last    )        , // ?????????????
                                                                                      
        .i_mac4_cross_metadata          ( w_mac4_cross_metadata         )        , // ???? metadata ????
        .i_mac4_cross_metadata_valid    ( w_mac4_cross_metadata_valid   )        , // ???? metadata ??????Ч???
        .i_mac4_cross_metadata_last     ( w_mac4_cross_metadata_last    )        , // ????????????
        .o_mac4_cross_metadata_ready    ( w_mac4_cross_metadata_ready   )        , // ??????鷴?????? 

        .i_tx4_req                      ( w_tx4_req ) ,
        .o_mac4_tx0_ack                 ( w_mac4_tx0_ack              ) , 
        .o_mac4_tx0_ack_rst             ( w_mac4_tx0_ack_rst          ) , 
        .o_mac4_tx1_ack                 ( w_mac4_tx1_ack              ) , 
        .o_mac4_tx1_ack_rst             ( w_mac4_tx1_ack_rst          ) , 
        .o_mac4_tx2_ack                 ( w_mac4_tx2_ack              ) , 
        .o_mac4_tx2_ack_rst             ( w_mac4_tx2_ack_rst          ) , 
        .o_mac4_tx3_ack                 ( w_mac4_tx3_ack              ) , 
        .o_mac4_tx3_ack_rst             ( w_mac4_tx3_ack_rst          ) , 
        .o_mac4_tx4_ack                 ( w_mac4_tx4_ack              ) , 
        .o_mac4_tx4_ack_rst             ( w_mac4_tx4_ack_rst          ) , 
        .o_mac4_tx5_ack                 ( w_mac4_tx5_ack              ) , 
        .o_mac4_tx5_ack_rst             ( w_mac4_tx5_ack_rst          ) , 
        .o_mac4_tx6_ack                 ( w_mac4_tx6_ack              ) , 
        .o_mac4_tx6_ack_rst             ( w_mac4_tx6_ack_rst          ) , 
        .o_mac4_tx7_ack                 ( w_mac4_tx7_ack              ) , 
        .o_mac4_tx7_ack_rst             ( w_mac4_tx7_ack_rst          ) , 
        .i_rxmac4_qbu_axis_data         (w_emac4_port_axi_data      ) , 
        .i_rxmac4_qbu_axis_keep         (w_emac4_axi_data_keep      ) , 
        .i_rxmac4_qbu_axis_user         (w_emac4_port_axi_user      ) , 
        .i_rxmac4_qbu_axis_valid        (w_emac4_axi_data_valid     ) , 
        .o_rxmac4_qbu_axis_ready        (w_emac4_axi_data_ready		) ,
        .i_rxmac4_qbu_axis_last         (w_emac4_axi_data_last      ) , 
        .i_rxmac4_qbu_metadata          (w_emac4_metadata           ) , 
        .i_rxmac4_qbu_metadata_valid    (w_emac4_metadata_valid     ) , 
        .i_rxmac4_qbu_metadata_last     (w_emac4_metadata_last      ) , 
        .o_rxmac4_qbu_metadata_ready    (w_emac4_metadata_ready		) ,                           
    `endif
    `ifdef MAC5
        //.i_mac5_cross_port_link         ( w_mac5_cross_port_link        )        , 
        //.i_mac5_cross_port_speed        ( w_mac5_cross_port_speed       )        , 
        .i_mac5_cross_port_axi_data     ( w_mac5_cross_port_axi_data    )        , // ??????????????λ???crcerr
        .i_mac5_cross_axi_data_keep     ( w_mac5_cross_axi_data_keep    )        , // ???????????????Ч?????
        .i_mac5_cross_axi_data_user     ( w_mac5_cross_port_axi_user   )        ,
        .i_mac5_cross_axi_data_valid    ( w_mac5_cross_axi_data_valid   )        , // ?????????Ч
        .o_mac5_cross_axi_data_ready    ( w_mac5_cross_axi_data_ready   )        , // ???????????????????????
        .i_mac5_cross_axi_data_last     ( w_mac5_cross_axi_data_last    )        , // ?????????????
                                                                                      
        .i_mac5_cross_metadata          ( w_mac5_cross_metadata         )        , // ???? metadata ????
        .i_mac5_cross_metadata_valid    ( w_mac5_cross_metadata_valid   )        , // ???? metadata ??????Ч???
        .i_mac5_cross_metadata_last     ( w_mac5_cross_metadata_last    )        , // ????????????
        .o_mac5_cross_metadata_ready    ( w_mac5_cross_metadata_ready   )        , // ??????鷴??????

        .i_tx5_req                      ( w_tx5_req ) ,
        .o_mac5_tx0_ack                 ( w_mac5_tx0_ack              ) , 
        .o_mac5_tx0_ack_rst             ( w_mac5_tx0_ack_rst          ) , 
        .o_mac5_tx1_ack                 ( w_mac5_tx1_ack              ) , 
        .o_mac5_tx1_ack_rst             ( w_mac5_tx1_ack_rst          ) , 
        .o_mac5_tx2_ack                 ( w_mac5_tx2_ack              ) , 
        .o_mac5_tx2_ack_rst             ( w_mac5_tx2_ack_rst          ) , 
        .o_mac5_tx3_ack                 ( w_mac5_tx3_ack              ) , 
        .o_mac5_tx3_ack_rst             ( w_mac5_tx3_ack_rst          ) , 
        .o_mac5_tx4_ack                 ( w_mac5_tx4_ack              ) , 
        .o_mac5_tx4_ack_rst             ( w_mac5_tx4_ack_rst          ) , 
        .o_mac5_tx5_ack                 ( w_mac5_tx5_ack              ) , 
        .o_mac5_tx5_ack_rst             ( w_mac5_tx5_ack_rst          ) , 
        .o_mac5_tx6_ack                 ( w_mac5_tx6_ack              ) , 
        .o_mac5_tx6_ack_rst             ( w_mac5_tx6_ack_rst          ) , 
        .o_mac5_tx7_ack                 ( w_mac5_tx7_ack              ) , 
        .o_mac5_tx7_ack_rst             ( w_mac5_tx7_ack_rst          ) , 
        .i_rxmac5_qbu_axis_data         (w_emac5_port_axi_data      ) , 
        .i_rxmac5_qbu_axis_keep         (w_emac5_axi_data_keep      ) , 
        .i_rxmac5_qbu_axis_user         (w_emac5_port_axi_user      ) , 
        .i_rxmac5_qbu_axis_valid        (w_emac5_axi_data_valid     ) , 
        .o_rxmac5_qbu_axis_ready        (w_emac5_axi_data_ready		) ,
        .i_rxmac5_qbu_axis_last         (w_emac5_axi_data_last      ) , 
        .i_rxmac5_qbu_metadata          (w_emac5_metadata           ) , 
        .i_rxmac5_qbu_metadata_valid    (w_emac5_metadata_valid     ) , 
        .i_rxmac5_qbu_metadata_last     (w_emac5_metadata_last      ) , 
        .o_rxmac5_qbu_metadata_ready    (w_emac5_metadata_ready 	) ,                           
    `endif
    `ifdef MAC6
        //.i_mac6_cross_port_link         ( w_mac6_cross_port_link        )        , //
        //.i_mac6_cross_port_speed        ( w_mac6_cross_port_speed       )        , //
        .i_mac6_cross_port_axi_data     ( w_mac6_cross_port_axi_data    )        , // ??????????????λ???crcerr
        .i_mac6_cross_axi_data_keep     ( w_mac6_cross_axi_data_keep    )        , // ???????????????Ч?????
        .i_mac6_cross_axi_data_user     ( w_mac6_cross_port_axi_user    )        ,
        .i_mac6_cross_axi_data_valid    ( w_mac6_cross_axi_data_valid   )        , // ?????????Ч
        .o_mac6_cross_axi_data_ready    ( w_mac6_cross_axi_data_ready   )        , // ???????????????????????
        .i_mac6_cross_axi_data_last     ( w_mac6_cross_axi_data_last    )        , // ?????????????
                                                                                      
        .i_mac6_cross_metadata          ( w_mac6_cross_metadata         )        , // ???? metadata ????
        .i_mac6_cross_metadata_valid    ( w_mac6_cross_metadata_valid   )        , // ???? metadata ??????Ч???
        .i_mac6_cross_metadata_last     ( w_mac6_cross_metadata_last    )        , // ????????????
        .o_mac6_cross_metadata_ready    ( w_mac6_cross_metadata_ready   )        , // ??????鷴?????? 

        .i_tx6_req                      ( w_tx6_req ) ,
        .o_mac6_tx0_ack                 ( w_mac6_tx0_ack              ) , 
        .o_mac6_tx0_ack_rst             ( w_mac6_tx0_ack_rst          ) , 
        .o_mac6_tx1_ack                 ( w_mac6_tx1_ack              ) , 
        .o_mac6_tx1_ack_rst             ( w_mac6_tx1_ack_rst          ) , 
        .o_mac6_tx2_ack                 ( w_mac6_tx2_ack              ) , 
        .o_mac6_tx2_ack_rst             ( w_mac6_tx2_ack_rst          ) , 
        .o_mac6_tx3_ack                 ( w_mac6_tx3_ack              ) , 
        .o_mac6_tx3_ack_rst             ( w_mac6_tx3_ack_rst          ) , 
        .o_mac6_tx4_ack                 ( w_mac6_tx4_ack              ) , 
        .o_mac6_tx4_ack_rst             ( w_mac6_tx4_ack_rst          ) , 
        .o_mac6_tx5_ack                 ( w_mac6_tx5_ack              ) , 
        .o_mac6_tx5_ack_rst             ( w_mac6_tx5_ack_rst          ) , 
        .o_mac6_tx6_ack                 ( w_mac6_tx6_ack              ) , 
        .o_mac6_tx6_ack_rst             ( w_mac6_tx6_ack_rst          ) , 
        .o_mac6_tx7_ack                 ( w_mac6_tx7_ack              ) , 
        .o_mac6_tx7_ack_rst             ( w_mac6_tx7_ack_rst          ) , 
        .i_rxmac6_qbu_axis_data         (w_emac6_port_axi_data      ) , 
        .i_rxmac6_qbu_axis_keep         (w_emac6_axi_data_keep      ) , 
        .i_rxmac6_qbu_axis_user         (w_emac6_port_axi_user      ) , 
        .i_rxmac6_qbu_axis_valid        (w_emac6_axi_data_valid     ) , 
        .o_rxmac6_qbu_axis_ready        (w_emac6_axi_data_ready		) ,
        .i_rxmac6_qbu_axis_last         (w_emac6_axi_data_last      ) , 
        .i_rxmac6_qbu_metadata          (w_emac6_metadata           ) , 
        .i_rxmac6_qbu_metadata_valid    (w_emac6_metadata_valid     ) , 
        .i_rxmac6_qbu_metadata_last     (w_emac6_metadata_last      ) , 
        .o_rxmac6_qbu_metadata_ready    (w_emac6_metadata_ready 	) ,                           
    `endif
    `ifdef MAC7
        //.i_mac7_cross_port_link         ( w_mac7_cross_port_link        ) , //
        //.i_mac7_cross_port_speed        ( w_mac7_cross_port_speed       ) , //
        .i_mac7_cross_port_axi_data     ( w_mac7_cross_port_axi_data    ) , // ??????????????λ???crcerr
        .i_mac7_cross_axi_data_keep     ( w_mac7_cross_axi_data_keep    ) , // ???????????????Ч?????
        .i_mac7_cross_axi_data_user     ( w_mac7_cross_port_axi_user   )        ,
        .i_mac7_cross_axi_data_valid    ( w_mac7_cross_axi_data_valid   ) , // ?????????Ч
        .o_mac7_cross_axi_data_ready    ( w_mac7_cross_axi_data_ready   ) , // ???????????????????????
        .i_mac7_cross_axi_data_last     ( w_mac7_cross_axi_data_last    ) , // ?????????????
                                                                               
        .i_mac7_cross_metadata          ( w_mac7_cross_metadata         ) , // ???? metadata ????
        .i_mac7_cross_metadata_valid    ( w_mac7_cross_metadata_valid   ) , // ???? metadata ??????Ч???
        .i_mac7_cross_metadata_last     ( w_mac7_cross_metadata_last    ) , // ????????????
        .o_mac7_cross_metadata_ready    ( w_mac7_cross_metadata_ready   ) , // ??????鷴?????? 

        .i_tx7_req                      ( w_tx7_req ) ,
        .o_mac7_tx0_ack                 ( w_mac7_tx0_ack              ) , 
        .o_mac7_tx0_ack_rst             ( w_mac7_tx0_ack_rst          ) , 
        .o_mac7_tx1_ack                 ( w_mac7_tx1_ack              ) , 
        .o_mac7_tx1_ack_rst             ( w_mac7_tx1_ack_rst          ) , 
        .o_mac7_tx2_ack                 ( w_mac7_tx2_ack              ) , 
        .o_mac7_tx2_ack_rst             ( w_mac7_tx2_ack_rst          ) , 
        .o_mac7_tx3_ack                 ( w_mac7_tx3_ack              ) , 
        .o_mac7_tx3_ack_rst             ( w_mac7_tx3_ack_rst          ) , 
        .o_mac7_tx4_ack                 ( w_mac7_tx4_ack              ) , 
        .o_mac7_tx4_ack_rst             ( w_mac7_tx4_ack_rst          ) , 
        .o_mac7_tx5_ack                 ( w_mac7_tx5_ack              ) , 
        .o_mac7_tx5_ack_rst             ( w_mac7_tx5_ack_rst          ) , 
        .o_mac7_tx6_ack                 ( w_mac7_tx6_ack              ) , 
        .o_mac7_tx6_ack_rst             ( w_mac7_tx6_ack_rst          ) , 
        .o_mac7_tx7_ack                 ( w_mac7_tx7_ack              ) , 
        .o_mac7_tx7_ack_rst             ( w_mac7_tx7_ack_rst          ) ,  
        .i_rxmac7_qbu_axis_data         (w_emac7_port_axi_data      ) , 
        .i_rxmac7_qbu_axis_keep         (w_emac7_axi_data_keep      ) , 
        .i_rxmac7_qbu_axis_user         (w_emac7_port_axi_user      ) , 
        .i_rxmac7_qbu_axis_valid        (w_emac7_axi_data_valid     ) , 
        .o_rxmac7_qbu_axis_ready        (w_emac7_axi_data_ready		) ,
        .i_rxmac7_qbu_axis_last         (w_emac7_axi_data_last      ) , 
        .i_rxmac7_qbu_metadata          (w_emac7_metadata           ) , 
        .i_rxmac7_qbu_metadata_valid    (w_emac7_metadata_valid     ) , 
        .i_rxmac7_qbu_metadata_last     (w_emac7_metadata_last      ) , 
        .o_rxmac7_qbu_metadata_ready    (w_emac7_metadata_ready 	) ,                           
    `endif
    `ifdef TSN_AS
        /*---------------------------------------- ?? PORT ????????? -------------------------------------------*/
        //.i_tsn_as_cross_port_link       ( w_tsn_as_cross_port_link       )  , // 
        //.i_tsn_as_cross_port_speed      ( w_tsn_as_cross_port_speed      )  , //
        .i_tsn_as_cross_port_axi_data   ( w_tsn_as_cross_port_axi_data   )  , // 
        .i_tsn_as_cross_axi_data_keep   ( w_tsn_as_cross_axi_data_keep   )  , // 
        .i_tsn_as_cross_axi_data_user   (    )        ,
        .i_tsn_as_cross_axi_data_valid  ( w_tsn_as_cross_axi_data_valid  )  , // 
        .o_tsn_as_cross_axi_data_ready  ( w_tsn_as_cross_axi_data_ready  )  , // 
        .i_tsn_as_cross_axi_data_last   ( w_tsn_as_cross_axi_data_last   )  , // 
        
        .i_tsn_as_cross_metadata        ( w_tsn_as_cross_metadata        )  , // 
        .i_tsn_as_cross_metadata_valid  ( w_tsn_as_cross_metadata_valid  )  , // 
        .i_tsn_as_cross_metadata_last   ( w_tsn_as_cross_metadata_last   )  , // 
        .o_tsn_as_cross_metadata_ready  ( w_tsn_as_cross_metadata_ready  )  , // 

        .i_tsn_as_tx_req                ( 1'b0 ) ,
        .o_tsn_as_tx_ack                (  ) ,
    `endif 
    `ifdef LLDP
        /*---------------------------------------- ?? PORT ????????? -------------------------------------------*/
        //.i_lldp_cross_port_link        ( w_lldp_cross_port_link         )     , // 
        //.i_lldp_cross_port_speed       ( w_lldp_cross_port_speed        )     , // 
        .i_lldp_cross_port_axi_data    ( w_lldp_cross_port_axi_data     )     , // 
        .i_lldp_cross_axi_data_keep    ( w_lldp_cross_axi_data_keep     )     , // 
        .i_lldp_cross_axi_data_user    (    )        ,
        .i_lldp_cross_axi_data_valid   ( w_lldp_cross_axi_data_valid    )     , // 
        .o_lldp_cross_axi_data_ready   ( w_lldp_cross_axi_data_ready    )     , // 
        .i_lldp_cross_axi_data_last    ( w_lldp_cross_axi_data_last     )     , // 
        
        .i_lldp_cross_metadata         ( w_lldp_cross_metadata         )      , // 
        .i_lldp_cross_metadata_valid   ( w_lldp_cross_metadata_valid   )      , // 
        .i_lldp_cross_metadata_last    ( w_lldp_cross_metadata_last    )      , // 
        .o_lldp_cross_metadata_ready   ( w_lldp_cross_metadata_ready   )      , // 

        .i_lldp_tx_req                 ( 1'b0 ) , 
        .o_lldp_tx_ack                 (  ) , 
    `endif 
    /*-------------------- TXMAC ????????? -----------------------*/
    `ifdef CPU_MAC
        //pmac???????
        .o_pmac0_tx_axis_data         ( w_pmac0_tx_axis_data    )      , 
        .o_pmac0_tx_axis_user         ( w_pmac0_tx_axis_user    )      , 
        .o_pmac0_tx_axis_keep         ( w_pmac0_tx_axis_keep    )      , 
        .o_pmac0_tx_axis_last         ( w_pmac0_tx_axis_last    )      , 
        .o_pmac0_tx_axis_valid        ( w_pmac0_tx_axis_valid   )      , 
        //.o_pmac0_ethertype            ( w_pmac0_ethertype       )      , 
        .i_pmac0_tx_axis_ready        ( w_pmac0_tx_axis_ready   )      ,
        //emac???????                
        .o_emac0_tx_axis_data         ( w_emac0_tx_axis_data    )      , 
        .o_emac0_tx_axis_user         ( w_emac0_tx_axis_user    )      , 
        .o_emac0_tx_axis_keep         ( w_emac0_tx_axis_keep    )      , 
        .o_emac0_tx_axis_last         ( w_emac0_tx_axis_last    )      , 
        .o_emac0_tx_axis_valid        ( w_emac0_tx_axis_valid   )      , 
        //.o_emac0_ethertype            ( w_emac0_ethertype       )      ,
        .i_emac0_tx_axis_ready        ( w_emac0_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac0_fifoc_empty           (w_mac0_fifoc_empty       )      ,    
        .i_mac0_scheduing_rst         (w_mac0_scheduing_rst     )      ,
        .i_mac0_scheduing_rst_vld     (w_mac0_scheduing_rst_vld )      ,  
    `endif
    `ifdef MAC1
        //pmac???????
        .o_pmac1_tx_axis_data         ( w_pmac1_tx_axis_data    )      , 
        .o_pmac1_tx_axis_user         ( w_pmac1_tx_axis_user    )      , 
        .o_pmac1_tx_axis_keep         ( w_pmac1_tx_axis_keep    )      , 
        .o_pmac1_tx_axis_last         ( w_pmac1_tx_axis_last    )      , 
        .o_pmac1_tx_axis_valid        ( w_pmac1_tx_axis_valid   )      , 
        //.o_pmac1_ethertype            ( w_pmac1_ethertype       )      , 
        .i_pmac1_tx_axis_ready        ( w_pmac1_tx_axis_ready   )      ,
        //emac???????               
        .o_emac1_tx_axis_data         ( w_emac1_tx_axis_data    )      , 
        .o_emac1_tx_axis_user         ( w_emac1_tx_axis_user    )      , 
        .o_emac1_tx_axis_keep         ( w_emac1_tx_axis_keep    )      , 
        .o_emac1_tx_axis_last         ( w_emac1_tx_axis_last    )      , 
        .o_emac1_tx_axis_valid        ( w_emac1_tx_axis_valid   )      , 
        //.o_emac1_ethertype            ( w_emac1_ethertype       )      ,
        .i_emac1_tx_axis_ready        ( w_emac1_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac1_fifoc_empty           ( w_mac1_fifoc_empty       )     ,    
        .i_mac1_scheduing_rst         ( w_mac1_scheduing_rst     )     ,
        .i_mac1_scheduing_rst_vld     ( w_mac1_scheduing_rst_vld )     , 
    `endif
    `ifdef MAC2
        //pmac???????
        .o_pmac2_tx_axis_data         ( w_pmac2_tx_axis_data    )      , 
        .o_pmac2_tx_axis_user         ( w_pmac2_tx_axis_user    )      , 
        .o_pmac2_tx_axis_keep         ( w_pmac2_tx_axis_keep    )      , 
        .o_pmac2_tx_axis_last         ( w_pmac2_tx_axis_last    )      , 
        .o_pmac2_tx_axis_valid        ( w_pmac2_tx_axis_valid   )      , 
        //.o_pmac2_ethertype            ( w_pmac2_ethertype       )      , 
        .i_pmac2_tx_axis_ready        ( w_pmac2_tx_axis_ready   )      ,
        //emac???????              
        .o_emac2_tx_axis_data         ( w_emac2_tx_axis_data    )      , 
        .o_emac2_tx_axis_user         ( w_emac2_tx_axis_user    )      , 
        .o_emac2_tx_axis_keep         ( w_emac2_tx_axis_keep    )      , 
        .o_emac2_tx_axis_last         ( w_emac2_tx_axis_last    )      , 
        .o_emac2_tx_axis_valid        ( w_emac2_tx_axis_valid   )      , 
        //.o_emac2_ethertype            ( w_emac2_ethertype       )      ,
        .i_emac2_tx_axis_ready        ( w_emac2_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac2_fifoc_empty           (w_mac2_fifoc_empty       )      ,    
        .i_mac2_scheduing_rst         (w_mac2_scheduing_rst     )      ,
        .i_mac2_scheduing_rst_vld     (w_mac2_scheduing_rst_vld )      , 
    `endif
    `ifdef MAC3
        //pmac???????
        .o_pmac3_tx_axis_data         ( w_pmac3_tx_axis_data    )      , 
        .o_pmac3_tx_axis_user         ( w_pmac3_tx_axis_user    )      , 
        .o_pmac3_tx_axis_keep         ( w_pmac3_tx_axis_keep    )      , 
        .o_pmac3_tx_axis_last         ( w_pmac3_tx_axis_last    )      , 
        .o_pmac3_tx_axis_valid        ( w_pmac3_tx_axis_valid   )      , 
        //.o_pmac3_ethertype            ( w_pmac3_ethertype       )      , 
        .i_pmac3_tx_axis_ready        ( w_pmac3_tx_axis_ready   )      ,
        //emac???????              
        .o_emac3_tx_axis_data         ( w_emac3_tx_axis_data    )      , 
        .o_emac3_tx_axis_user         ( w_emac3_tx_axis_user    )      , 
        .o_emac3_tx_axis_keep         ( w_emac3_tx_axis_keep    )      , 
        .o_emac3_tx_axis_last         ( w_emac3_tx_axis_last    )      , 
        .o_emac3_tx_axis_valid        ( w_emac3_tx_axis_valid   )      , 
        //.o_emac3_ethertype            ( w_emac3_ethertype       )      ,
        .i_emac3_tx_axis_ready        ( w_emac3_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac3_fifoc_empty           (w_mac3_fifoc_empty       )      ,    
        .i_mac3_scheduing_rst         (w_mac3_scheduing_rst     )      ,
        .i_mac3_scheduing_rst_vld     (w_mac3_scheduing_rst_vld )      ,  
    `endif
    `ifdef MAC4
        //pmac???????
        .o_pmac4_tx_axis_data         ( w_pmac4_tx_axis_data    )      , 
        .o_pmac4_tx_axis_user         ( w_pmac4_tx_axis_user    )      , 
        .o_pmac4_tx_axis_keep         ( w_pmac4_tx_axis_keep    )      , 
        .o_pmac4_tx_axis_last         ( w_pmac4_tx_axis_last    )      , 
        .o_pmac4_tx_axis_valid        ( w_pmac4_tx_axis_valid   )      , 
        //.o_pmac4_ethertype            ( w_pmac4_ethertype       )      , 
        .i_pmac4_tx_axis_ready        ( w_pmac4_tx_axis_ready   )      ,
        //emac???????               
        .o_emac4_tx_axis_data         ( w_emac4_tx_axis_data    )      , 
        .o_emac4_tx_axis_user         ( w_emac4_tx_axis_user    )      , 
        .o_emac4_tx_axis_keep         ( w_emac4_tx_axis_keep    )      , 
        .o_emac4_tx_axis_last         ( w_emac4_tx_axis_last    )      , 
        .o_emac4_tx_axis_valid        ( w_emac4_tx_axis_valid   )      , 
        //.o_emac4_ethertype            ( w_emac4_ethertype       )      ,
        .i_emac4_tx_axis_ready        ( w_emac4_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac4_fifoc_empty           (w_mac4_fifoc_empty       )      ,    
        .i_mac4_scheduing_rst         (w_mac4_scheduing_rst     )      ,
        .i_mac4_scheduing_rst_vld     (w_mac4_scheduing_rst_vld )      , 
    `endif
    `ifdef MAC5
        //pmac???????
        .o_pmac5_tx_axis_data         ( w_pmac5_tx_axis_data    )      , 
        .o_pmac5_tx_axis_user         ( w_pmac5_tx_axis_user    )      , 
        .o_pmac5_tx_axis_keep         ( w_pmac5_tx_axis_keep    )      , 
        .o_pmac5_tx_axis_last         ( w_pmac5_tx_axis_last    )      , 
        .o_pmac5_tx_axis_valid        ( w_pmac5_tx_axis_valid   )      , 
        //.o_pmac5_ethertype            ( w_pmac5_ethertype       )      , 
        .i_pmac5_tx_axis_ready        ( w_pmac5_tx_axis_ready   )      ,
        //emac???????                
        .o_emac5_tx_axis_data         ( w_emac5_tx_axis_data    )      , 
        .o_emac5_tx_axis_user         ( w_emac5_tx_axis_user    )      , 
        .o_emac5_tx_axis_keep         ( w_emac5_tx_axis_keep    )      , 
        .o_emac5_tx_axis_last         ( w_emac5_tx_axis_last    )      , 
        .o_emac5_tx_axis_valid        ( w_emac5_tx_axis_valid   )      , 
        //.o_emac5_ethertype            ( w_emac5_ethertype       )      ,
        .i_emac5_tx_axis_ready        ( w_emac5_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac5_fifoc_empty           (w_mac5_fifoc_empty       )      ,    
        .i_mac5_scheduing_rst         (w_mac5_scheduing_rst     )      ,
        .i_mac5_scheduing_rst_vld     (w_mac5_scheduing_rst_vld )      , 
    `endif
    `ifdef MAC6
        //pmac???????
        .o_pmac6_tx_axis_data         ( w_pmac6_tx_axis_data    )      , 
        .o_pmac6_tx_axis_user         ( w_pmac6_tx_axis_user    )      , 
        .o_pmac6_tx_axis_keep         ( w_pmac6_tx_axis_keep    )      , 
        .o_pmac6_tx_axis_last         ( w_pmac6_tx_axis_last    )      , 
        .o_pmac6_tx_axis_valid        ( w_pmac6_tx_axis_valid   )      , 
        //.o_pmac6_ethertype            ( w_pmac6_ethertype       )      , 
        .i_pmac6_tx_axis_ready        ( w_pmac6_tx_axis_ready   )      ,
        //emac???????               
        .o_emac6_tx_axis_data         ( w_emac6_tx_axis_data    )      , 
        .o_emac6_tx_axis_user         ( w_emac6_tx_axis_user    )      , 
        .o_emac6_tx_axis_keep         ( w_emac6_tx_axis_keep    )      , 
        .o_emac6_tx_axis_last         ( w_emac6_tx_axis_last    )      , 
        .o_emac6_tx_axis_valid        ( w_emac6_tx_axis_valid   )      , 
        //.o_emac6_ethertype            ( w_emac6_ethertype       )      ,
        .i_emac6_tx_axis_ready        ( w_emac6_tx_axis_ready   )      ,
        // ???????????????????
        .o_mac6_fifoc_empty           (w_mac6_fifoc_empty       )      ,    
        .i_mac6_scheduing_rst         (w_mac6_scheduing_rst     )      ,
        .i_mac6_scheduing_rst_vld     (w_mac6_scheduing_rst_vld )      , 
    `endif
    `ifdef MAC7
        //pmac???????
        .o_pmac7_tx_axis_data         ( w_pmac7_tx_axis_data    )      , 
        .o_pmac7_tx_axis_user         ( w_pmac7_tx_axis_user    )      , 
        .o_pmac7_tx_axis_keep         ( w_pmac7_tx_axis_keep    )      , 
        .o_pmac7_tx_axis_last         ( w_pmac7_tx_axis_last    )      , 
        .o_pmac7_tx_axis_valid        ( w_pmac7_tx_axis_valid   )      , 
        //.o_pmac7_ethertype            ( w_pmac7_ethertype       )      , 
        .i_pmac7_tx_axis_ready        ( w_pmac7_tx_axis_ready   )      ,
        //emac???????               
        .o_emac7_tx_axis_data         ( w_emac7_tx_axis_data    )       , 
        .o_emac7_tx_axis_user         ( w_emac7_tx_axis_user    )       , 
        .o_emac7_tx_axis_keep         ( w_emac7_tx_axis_keep    )       , 
        .o_emac7_tx_axis_last         ( w_emac7_tx_axis_last    )       , 
        .o_emac7_tx_axis_valid        ( w_emac7_tx_axis_valid   )       , 
        //.o_emac7_ethertype            ( w_emac7_ethertype       )       ,
        .i_emac7_tx_axis_ready        ( w_emac7_tx_axis_ready   )       ,
        // ???????????????????
        .o_mac7_fifoc_empty           (w_mac7_fifoc_empty       )       ,    
        .i_mac7_scheduing_rst         (w_mac7_scheduing_rst     )       ,
        .i_mac7_scheduing_rst_vld     (w_mac7_scheduing_rst_vld )       
    `endif  
);


tx_mac_mng #(
    .PORT_NUM                   ( PORT_NUM              )  ,                   // ??????????????
    .METADATA_WIDTH             ( METADATA_WIDTH        )  ,                   // ???????METADATA????λ??
    .PORT_MNG_DATA_WIDTH        ( PORT_MNG_DATA_WIDTH   )  ,                   // Mac_port_mng ????λ??
    .PORT_FIFO_PRI_NUM          ( PORT_FIFO_PRI_NUM     )  ,                   // ????????????? FIFO ????????
    .REG_ADDR_BUS_WIDTH         ( REG_ADDR_OFS_WIDTH    )  ,
    .REG_DATA_BUS_WIDTH         ( REG_DATA_BUS_WIDTH    )  ,
    .CROSS_DATA_WIDTH           ( CROSS_DATA_WIDTH      )  
)tx_mac_mng_inst (
        .i_clk                      ( i_clk  )        ,   // 250MHz
        .i_rst                      ( i_rst )        ,
    /*---------------------------------------- 业务接口数据输出 -------------------------------------------*/
    `ifdef CPU_MAC
        /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
        //pmac通道数据
        .i_pmac0_tx_axis_data      ( w_pmac0_tx_axis_data  )         , 
        .i_pmac0_tx_axis_user      ( w_pmac0_tx_axis_user  )         , 
        .i_pmac0_tx_axis_keep      ( w_pmac0_tx_axis_keep  )         , 
        .i_pmac0_tx_axis_last      ( w_pmac0_tx_axis_last  )         , 
        .i_pmac0_tx_axis_valid     ( w_pmac0_tx_axis_valid )         , 
        .i_pmac0_ethertype         ( w_pmac0_ethertype     )         , 
        .o_pmac0_tx_axis_ready     ( w_pmac0_tx_axis_ready )         ,
        //emac通道数据              
        .i_emac0_tx_axis_data      ( w_emac0_tx_axis_data  )         , 
        .i_emac0_tx_axis_user      ( w_emac0_tx_axis_user  )         , 
        .i_emac0_tx_axis_keep      ( w_emac0_tx_axis_keep  )         , 
        .i_emac0_tx_axis_last      ( w_emac0_tx_axis_last  )         , 
        .i_emac0_tx_axis_valid     ( w_emac0_tx_axis_valid )         , 
        .i_emac0_ethertype         ( w_emac0_ethertype     )         ,
        .o_emac0_tx_axis_ready     ( w_emac0_tx_axis_ready )         ,
        // 调度流水线调度信息交互 
        .i_mac0_fifoc_empty        ( w_mac0_fifoc_empty       )      ,    
        .o_mac0_scheduing_rst      ( w_mac0_scheduing_rst     )      ,
        .o_mac0_scheduing_rst_vld  ( w_mac0_scheduing_rst_vld )      ,   
        /* ----------------------  CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac0_axi_data           ( o_cpu_mac0_axi_data)         ,
        .o_mac0_axi_data_keep      ( o_cpu_mac0_axi_data_keep )         ,
        .o_mac0_axi_data_valid     ( o_cpu_mac0_axi_data_valid )         ,
        .o_mac0_axi_data_user      ( o_cpu_mac0_axi_data_user )         ,
        .i_mac0_axi_data_ready     ( o_cpu_mac0_axi_data_ready )         ,
        .o_mac0_axi_data_last      ( o_cpu_mac0_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac0_time_irq           ( o_txcpu_mac0_time_irq)        	, // 打时间戳中断信号
        .o_mac0_frame_seq          ( o_txcpu_mac0_frame_seq)        , // 帧序列号
        .o_mac0_timestamp_addr     ( o_txtimestamp0_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC1
        /* ---------------------- CROSSBAR交换平面数据流输入? ------------------------- */
        //pmac通道数据
        .i_pmac1_tx_axis_data      ( w_pmac1_tx_axis_data  )         , 
        .i_pmac1_tx_axis_user      ( w_pmac1_tx_axis_user  )         , 
        .i_pmac1_tx_axis_keep      ( w_pmac1_tx_axis_keep  )         , 
        .i_pmac1_tx_axis_last      ( w_pmac1_tx_axis_last  )         , 
        .i_pmac1_tx_axis_valid     ( w_pmac1_tx_axis_valid )         , 
        .i_pmac1_ethertype         ( w_pmac1_ethertype     )         , 
        .o_pmac1_tx_axis_ready     ( w_pmac1_tx_axis_ready )         ,
        //emac通道数据           
        .i_emac1_tx_axis_data      ( w_emac1_tx_axis_data  )         , 
        .i_emac1_tx_axis_user      ( w_emac1_tx_axis_user  )         , 
        .i_emac1_tx_axis_keep      ( w_emac1_tx_axis_keep  )         , 
        .i_emac1_tx_axis_last      ( w_emac1_tx_axis_last  )         , 
        .i_emac1_tx_axis_valid     ( w_emac1_tx_axis_valid )         , 
        .i_emac1_ethertype         ( w_emac1_ethertype     )         ,
        .o_emac1_tx_axis_ready     ( w_emac1_tx_axis_ready )         ,
        // 调度流水线调度信息交互  
        .i_mac1_fifoc_empty        ( w_mac1_fifoc_empty       )         ,    
        .o_mac1_scheduing_rst      ( w_mac1_scheduing_rst     )         ,
        .o_mac1_scheduing_rst_vld  ( w_mac1_scheduing_rst_vld )         ,   
        /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac1_axi_data           ( o_mac1_axi_data)         ,
        .o_mac1_axi_data_keep      ( o_mac1_axi_data_keep )         ,
        .o_mac1_axi_data_valid     ( o_mac1_axi_data_valid )         ,
        .o_mac1_axi_data_user      ( o_mac1_axi_data_user )         ,
        .i_mac1_axi_data_ready     ( i_mac1_axi_data_ready )         ,
        .o_mac1_axi_data_last      ( o_mac1_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac1_time_irq           ( o_txmac1_time_irq)         	, // 打时间戳中断信号
        .o_mac1_frame_seq          ( o_txmac1_frame_seq)         	, // 帧序列号
        .o_mac1_timestamp_addr     ( o_txtimestamp1_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC2
        /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
        //pmac通道数据
        .i_pmac2_tx_axis_data      ( w_pmac2_tx_axis_data  )         , 
        .i_pmac2_tx_axis_user      ( w_pmac2_tx_axis_user  )         , 
        .i_pmac2_tx_axis_keep      ( w_pmac2_tx_axis_keep  )         , 
        .i_pmac2_tx_axis_last      ( w_pmac2_tx_axis_last  )         , 
        .i_pmac2_tx_axis_valid     ( w_pmac2_tx_axis_valid )         , 
        .i_pmac2_ethertype         ( w_pmac2_ethertype     )         , 
        .o_pmac2_tx_axis_ready     ( w_pmac2_tx_axis_ready )         ,
        //emac通道数据           
        .i_emac2_tx_axis_data      ( w_emac2_tx_axis_data  )         , 
        .i_emac2_tx_axis_user      ( w_emac2_tx_axis_user  )         , 
        .i_emac2_tx_axis_keep      ( w_emac2_tx_axis_keep  )         , 
        .i_emac2_tx_axis_last      ( w_emac2_tx_axis_last  )         , 
        .i_emac2_tx_axis_valid     ( w_emac2_tx_axis_valid )         , 
        .i_emac2_ethertype         ( w_emac2_ethertype     )         ,
        .o_emac2_tx_axis_ready     ( w_emac2_tx_axis_ready )         ,
        // 调度流水线调度信息交互 
        .i_mac2_fifoc_empty        ( w_mac2_fifoc_empty       )      ,    
        .o_mac2_scheduing_rst      ( w_mac2_scheduing_rst     )      ,
        .o_mac2_scheduing_rst_vld  ( w_mac2_scheduing_rst_vld )      ,   
        /* ----------------------  CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac2_axi_data           ( o_mac2_axi_data)         ,
        .o_mac2_axi_data_keep      ( o_mac2_axi_data_keep )         ,
        .o_mac2_axi_data_valid     ( o_mac2_axi_data_valid   )         ,
        .o_mac2_axi_data_user      ( o_mac2_axi_data_user )         ,
        .i_mac2_axi_data_ready     ( o_mac2_axi_data_ready )         ,
        .o_mac2_axi_data_last      ( o_mac2_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac2_time_irq           ( o_txmac2_time_irq)         	, // 打时间戳中断信号
        .o_mac2_frame_seq          ( o_txmac2_frame_seq)         	, // 帧序列号
        .o_mac2_timestamp_addr     ( o_txtimestamp2_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC3
        /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
        //pmac通道数据
        .i_pmac3_tx_axis_data      ( w_pmac3_tx_axis_data  )         , 
        .i_pmac3_tx_axis_user      ( w_pmac3_tx_axis_user  )         , 
        .i_pmac3_tx_axis_keep      ( w_pmac3_tx_axis_keep  )         , 
        .i_pmac3_tx_axis_last      ( w_pmac3_tx_axis_last  )         , 
        .i_pmac3_tx_axis_valid     ( w_pmac3_tx_axis_valid )         , 
        .i_pmac3_ethertype         ( w_pmac3_ethertype     )         , 
        .o_pmac3_tx_axis_ready     ( w_pmac3_tx_axis_ready )         ,
        //emac通道数据         
        .i_emac3_tx_axis_data      ( w_emac3_tx_axis_data  )         , 
        .i_emac3_tx_axis_user      ( w_emac3_tx_axis_user  )         , 
        .i_emac3_tx_axis_keep      ( w_emac3_tx_axis_keep  )         , 
        .i_emac3_tx_axis_last      ( w_emac3_tx_axis_last  )         , 
        .i_emac3_tx_axis_valid     ( w_emac3_tx_axis_valid )         , 
        .i_emac3_ethertype         ( w_emac3_ethertype     )         ,
        .o_emac3_tx_axis_ready     ( w_emac3_tx_axis_ready )         ,
        // 调度流水线调度信息交互 
        .i_mac3_fifoc_empty        ( w_mac3_fifoc_empty       )         ,    
        .o_mac3_scheduing_rst      ( w_mac3_scheduing_rst     )         ,
        .o_mac3_scheduing_rst_vld  ( w_mac3_scheduing_rst_vld )         ,   
        /* ----------------------  CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac3_axi_data           ( o_mac3_axi_data)         ,
        .o_mac3_axi_data_keep      ( o_mac3_axi_data_keep )         ,
        .o_mac3_axi_data_valid     ( o_mac3_axi_data_valid )         ,
        .o_mac3_axi_data_user      ( o_mac3_axi_data_user )         ,
        .i_mac3_axi_data_ready     ( o_mac3_axi_data_ready )         ,
        .o_mac3_axi_data_last      ( o_mac3_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac3_time_irq           ( o_txmac3_time_irq)         	, // 打时间戳中断信号
        .o_mac3_frame_seq          ( o_txmac3_frame_seq)         	, // 帧序列号
        .o_mac3_timestamp_addr     ( o_txtimestamp3_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC4
        /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
        //pmac通道数据
        .i_pmac4_tx_axis_data      ( w_pmac4_tx_axis_data  )         , 
        .i_pmac4_tx_axis_user      ( w_pmac4_tx_axis_user  )         , 
        .i_pmac4_tx_axis_keep      ( w_pmac4_tx_axis_keep  )         , 
        .i_pmac4_tx_axis_last      ( w_pmac4_tx_axis_last  )         , 
        .i_pmac4_tx_axis_valid     ( w_pmac4_tx_axis_valid )         , 
        .i_pmac4_ethertype         ( w_pmac4_ethertype     )         , 
        .o_pmac4_tx_axis_ready     ( w_pmac4_tx_axis_ready )         ,
        //emac通道数据             
        .i_emac4_tx_axis_data      ( w_emac4_tx_axis_data  )         , 
        .i_emac4_tx_axis_user      ( w_emac4_tx_axis_user  )         , 
        .i_emac4_tx_axis_keep      ( w_emac4_tx_axis_keep  )         , 
        .i_emac4_tx_axis_last      ( w_emac4_tx_axis_last  )         , 
        .i_emac4_tx_axis_valid     ( w_emac4_tx_axis_valid )         , 
        .i_emac4_ethertype         ( w_emac4_ethertype     )         ,
        .o_emac4_tx_axis_ready     ( w_emac4_tx_axis_ready )         ,
        // 调度流水线调度信息交互 
        .i_mac4_fifoc_empty        ( w_mac4_fifoc_empty       )      ,    
        .o_mac4_scheduing_rst      ( w_mac4_scheduing_rst     )      ,
        .o_mac4_scheduing_rst_vld  ( w_mac4_scheduing_rst_vld )      ,   
        /* ----------------------  CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac4_axi_data           ( o_mac4_axi_data)         		,
        .o_mac4_axi_data_keep      ( o_mac4_axi_data_keep )         ,
        .o_mac4_axi_data_valid     ( o_mac4_axi_data_valid )        ,
        .o_mac4_axi_data_user      ( o_mac4_axi_data_user )         ,
        .i_mac4_axi_data_ready     ( o_mac4_axi_data_ready )        ,
        .o_mac4_axi_data_last      ( o_mac4_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac4_time_irq           ( o_txmac4_time_irq)         	, // 打时间戳中断信号
        .o_mac4_frame_seq          ( o_txmac4_frame_seq)         	, // 帧序列号
        .o_mac4_timestamp_addr     ( o_txtimestamp4_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC5
        /* ---------------------- CROSSBAR交换平面数据流输入  ------------------------- */
        //pmac通道数据   
        .i_pmac5_tx_axis_data      ( w_pmac5_tx_axis_data  )         , 
        .i_pmac5_tx_axis_user      ( w_pmac5_tx_axis_user  )         , 
        .i_pmac5_tx_axis_keep      ( w_pmac5_tx_axis_keep  )         , 
        .i_pmac5_tx_axis_last      ( w_pmac5_tx_axis_last  )         , 
        .i_pmac5_tx_axis_valid     ( w_pmac5_tx_axis_valid )         , 
        .i_pmac5_ethertype         ( w_pmac5_ethertype     )         , 
        .o_pmac5_tx_axis_ready     ( w_pmac5_tx_axis_ready )         ,
        //emac通道数据                
        .i_emac5_tx_axis_data      ( w_emac5_tx_axis_data  )         , 
        .i_emac5_tx_axis_user      ( w_emac5_tx_axis_user  )         , 
        .i_emac5_tx_axis_keep      ( w_emac5_tx_axis_keep  )         , 
        .i_emac5_tx_axis_last      ( w_emac5_tx_axis_last  )         , 
        .i_emac5_tx_axis_valid     ( w_emac5_tx_axis_valid )         , 
        .i_emac5_ethertype         ( w_emac5_ethertype     )         ,
        .o_emac5_tx_axis_ready     ( w_emac5_tx_axis_ready )         ,
        // 调度流水线调度信息交互
        .i_mac5_fifoc_empty        ( w_mac5_fifoc_empty       )         ,    
        .o_mac5_scheduing_rst      ( w_mac5_scheduing_rst     )         ,
        .o_mac5_scheduing_rst_vld  ( w_mac5_scheduing_rst_vld )         ,   
        /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
        // 输出给接口层axi数据流
        .o_mac5_axi_data           ( o_mac5_axi_data)         		,
        .o_mac5_axi_data_keep      ( o_mac5_axi_data_keep )         ,
        .o_mac5_axi_data_valid     ( o_mac5_axi_data_valid )        ,
        .o_mac5_axi_data_user      ( o_mac5_axi_data_user )         ,
        .i_mac5_axi_data_ready     ( o_mac5_axi_data_ready )        ,
        .o_mac5_axi_data_last      ( o_mac5_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac5_time_irq           ( o_txmac5_time_irq)         	, // 打时间戳中断信号
        .o_mac5_frame_seq          ( o_txmac5_frame_seq)         	, // 帧序列号
        .o_mac5_timestamp_addr     ( o_txtimestamp5_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC6
        /* ---------------------- CROSSBAR交换平面数据流输入 ------------------------- */
        //pmac通道数据     
        .i_pmac6_tx_axis_data      ( w_pmac6_tx_axis_data  )         , 
        .i_pmac6_tx_axis_user      ( w_pmac6_tx_axis_user  )         , 
        .i_pmac6_tx_axis_keep      ( w_pmac6_tx_axis_keep  )         , 
        .i_pmac6_tx_axis_last      ( w_pmac6_tx_axis_last  )         , 
        .i_pmac6_tx_axis_valid     ( w_pmac6_tx_axis_valid )         , 
        .i_pmac6_ethertype         ( w_pmac6_ethertype     )         , 
        .o_pmac6_tx_axis_ready     ( w_pmac6_tx_axis_ready )         ,
        //emac通道数据                  
        .i_emac6_tx_axis_data      ( w_emac6_tx_axis_data  )         , 
        .i_emac6_tx_axis_user      ( w_emac6_tx_axis_user  )         , 
        .i_emac6_tx_axis_keep      ( w_emac6_tx_axis_keep  )         , 
        .i_emac6_tx_axis_last      ( w_emac6_tx_axis_last  )         , 
        .i_emac6_tx_axis_valid     ( w_emac6_tx_axis_valid )         , 
        .i_emac6_ethertype         ( w_emac6_ethertype     )         ,
        .o_emac6_tx_axis_ready     ( w_emac6_tx_axis_ready )         ,
        // 调度流水线调度信息交互  
        .i_mac6_fifoc_empty        ( w_mac6_fifoc_empty       )         ,    
        .o_mac6_scheduing_rst      ( w_mac6_scheduing_rst     )         ,
        .o_mac6_scheduing_rst_vld  ( w_mac6_scheduing_rst_vld )         ,    
        /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
        // 输出给接口层axi数据流
        .o_mac6_axi_data           ( o_mac6_axi_data)         			,
        .o_mac6_axi_data_keep      ( o_mac6_axi_data_keep )         	,
        .o_mac6_axi_data_valid     ( o_mac6_axi_data_valid )         	,
        .o_mac6_axi_data_user      ( o_mac6_axi_data_user )         	,
        .i_mac6_axi_data_ready     ( o_mac6_axi_data_ready )         	,
        .o_mac6_axi_data_last      ( o_mac6_axi_data_last )         	,
        // 报文时间打时间戳
        .o_mac6_time_irq           ( o_txmac6_time_irq)         	, // 打时间戳中断信号
        .o_mac6_frame_seq          ( o_txmac6_frame_seq)         	, // 帧序列号
        .o_mac6_timestamp_addr     ( o_txtimestamp6_addr)        	, // 打时间戳存储的 RAM 地址
    `endif
    `ifdef MAC7
        /* ---------------------- CROSSBAR交换平面数据流输入------------------------- */
        //pmac通道数据
        .i_pmac7_tx_axis_data      ( w_pmac7_tx_axis_data  )         , 
        .i_pmac7_tx_axis_user      ( w_pmac7_tx_axis_user  )         , 
        .i_pmac7_tx_axis_keep      ( w_pmac7_tx_axis_keep  )         , 
        .i_pmac7_tx_axis_last      ( w_pmac7_tx_axis_last  )         , 
        .i_pmac7_tx_axis_valid     ( w_pmac7_tx_axis_valid )         , 
        .i_pmac7_ethertype         ( w_pmac7_ethertype     )         , 
        .o_pmac7_tx_axis_ready     ( w_pmac7_tx_axis_ready )         ,
        //emac通道数据             
        .i_emac7_tx_axis_data      ( w_emac7_tx_axis_data  )         , 
        .i_emac7_tx_axis_user      ( w_emac7_tx_axis_user  )         , 
        .i_emac7_tx_axis_keep      ( w_emac7_tx_axis_keep  )         , 
        .i_emac7_tx_axis_last      ( w_emac7_tx_axis_last  )         , 
        .i_emac7_tx_axis_valid     ( w_emac7_tx_axis_valid )         , 
        .i_emac7_ethertype         ( w_emac7_ethertype     )         ,
        .o_emac7_tx_axis_ready     ( w_emac7_tx_axis_ready )         ,
        // 调度流水线调度信息交互
        .i_mac7_fifoc_empty        ( w_mac7_fifoc_empty       )      ,    
        .o_mac7_scheduing_rst      ( w_mac7_scheduing_rst     )      ,
        .o_mac7_scheduing_rst_vld  ( w_mac7_scheduing_rst_vld )      ,    
        /* ---------------------- CROSSBAR交换平面数据流输出 ------------------------- */
        //输出给接口层axi数据流
        .o_mac7_axi_data           ( o_mac7_axi_data)         		,
        .o_mac7_axi_data_keep      ( o_mac7_axi_data_keep )         ,
        .o_mac7_axi_data_valid     ( o_mac7_axi_data_valid )        ,
        .o_mac7_axi_data_user      ( o_mac7_axi_data_user )         ,
        .i_mac7_axi_data_ready     ( o_mac7_axi_data_ready )        ,
        .o_mac7_axi_data_last      ( o_mac7_axi_data_last )         ,
        // 报文时间打时间戳
        .o_mac7_time_irq           ( o_txmac7_time_irq)         	, // 打时间戳中断信号
        .o_mac7_frame_seq          ( o_txmac7_frame_seq)         	, // 帧序列号
        .o_mac7_timestamp_addr     ( o_txtimestamp7_addr)         	, // 打时间戳存储的 RAM 地址
    `endif
        /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
        // 寄存器控制信号                     
        .i_refresh_list_pulse                ( w_refresh_list_pulse      ), // 刷新寄存器列表（状态寄存器和控制寄存器）
        .i_switch_err_cnt_clr                ( w_switch_err_cnt_clr      ), // 刷新错误计数器
        .i_switch_err_cnt_stat               ( w_switch_err_cnt_stat     ), // 刷新错误状态寄存器
        // 寄存器写控制接口                                                    
        .i_switch_reg_bus_we                 ( w_txmac_reg_bus_we        ), // 寄存器写使能
        .i_switch_reg_bus_we_addr            ( w_txmac_reg_bus_we_addr   ), // 寄存器写地址
        .i_switch_reg_bus_we_din             ( w_txmac_reg_bus_we_din    ), // 寄存器写数据
        .i_switch_reg_bus_we_din_v           ( w_txmac_reg_bus_we_din_v  ), // 寄存器写数据使能
        // 寄存器读控制接口                                                    
        .i_switch_reg_bus_rd                 ( w_txmac_reg_bus_rd        ), // 寄存器读使能
        .i_switch_reg_bus_rd_addr            ( w_txmac_reg_bus_rd_addr   ), // 寄存器读地址
        .o_switch_reg_bus_rd_dout            ( w_txmac_reg_bus_rd_dout   ), // 读出寄存器数据
        .o_switch_reg_bus_rd_dout_v          ( w_txmac_reg_bus_rd_dout_v )  // 读数据有效使能
);

/*------------------- 特定端口转发的 IP 数据流 over 至 COSSBAR 交换架构中----------------*/

`ifdef TSN_AS
tsn_as_top #(
    .PORT_NUM               (PORT_NUM               ),  
    .REG_ADDR_BUS_WIDTH     (REG_ADDR_OFS_WIDTH     ),  
    .REG_DATA_BUS_WIDTH     (REG_DATA_BUS_WIDTH     ),  
    .METADATA_WIDTH         (METADATA_WIDTH         ),  
    .PORT_MNG_DATA_WIDTH    (PORT_MNG_DATA_WIDTH    ),  
    .PORT_FIFO_PRI_NUM      (PORT_FIFO_PRI_NUM      ),  
    .TIMESTAMP_WIDTH        (80        ),  
    .CROSS_DATA_WIDTH       (CROSS_DATA_WIDTH       )   
) u_tsn_as_top (
   
    `ifdef CPU_MAC
        .i_mac0_port_link               (                               ),  
        .i_mac0_port_axi_data           (                               ),  
        .i_mac0_axi_data_keep           (                               ),  
        .i_mac0_axi_data_valid          (                               ),  
        .o_mac0_axi_data_ready          (                               ),  
        .i_mac0_axi_data_last           (                               ),  
        .i_mac0_metadata                (                               ),  
        .i_mac0_metadata_valid          (                               ),  
        .i_mac0_metadata_last           (                               ),  
        .i_tx0_req                      (                               ),  
        .o_tx0_ack                      (                               ),  
    `endif
    `ifdef MAC1
        .i_mac1_port_link               (                               ),  
        .i_mac1_port_axi_data           (                               ),  
        .i_mac1_axi_data_keep           (                               ),  
        .i_mac1_axi_data_valid          (                               ),  
        .o_mac1_axi_data_ready          (                               ),  
        .i_mac1_axi_data_last           (                               ),  
        .i_mac1_metadata                (                               ),  
        .i_mac1_metadata_valid          (                               ),  
        .i_mac1_metadata_last           (                               ),  
        .i_tx1_req                      (                               ),  
        .o_tx1_ack                      (                               ),  
    `endif
    `ifdef MAC2
        .i_mac2_port_link               (                               ),  
        .i_mac2_port_axi_data           (                               ),  
        .i_mac2_axi_data_keep           (                               ),  
        .i_mac2_axi_data_valid          (                               ),  
        .o_mac2_axi_data_ready          (                               ),  
        .i_mac2_axi_data_last           (                               ),  
        .i_mac2_metadata                (                               ),  
        .i_mac2_metadata_valid          (                               ),  
        .i_mac2_metadata_last           (                               ),  
        .i_tx2_req                      (                               ),  
        .o_tx2_ack                      (                               ),  
    `endif
    `ifdef MAC3
        .i_mac3_port_link               (                               ),  
        .i_mac3_port_axi_data           (                               ),  
        .i_mac3_axi_data_keep           (                               ),  
        .i_mac3_axi_data_valid          (                               ),  
        .o_mac3_axi_data_ready          (                               ),  
        .i_mac3_axi_data_last           (                               ),  
        .i_mac3_metadata                (                               ),  
        .i_mac3_metadata_valid          (                               ),  
        .i_mac3_metadata_last           (                               ),  
        .i_tx3_req                      (                               ),  
        .o_tx3_ack                      (                               ),  
    `endif
    `ifdef MAC4
        .i_mac4_port_link               (                               ),  
        .i_mac4_port_axi_data           (                               ),  
        .i_mac4_axi_data_keep           (                               ),  
        .i_mac4_axi_data_valid          (                               ),  
        .o_mac4_axi_data_ready          (                               ),  
        .i_mac4_axi_data_last           (                               ),  
        .i_mac4_metadata                (                               ),  
        .i_mac4_metadata_valid          (                               ),  
        .i_mac4_metadata_last           (                               ),  
        .i_tx4_req                      (                               ),  
        .o_tx4_ack                      (                               ),  
    `endif
    `ifdef MAC5
        .i_mac5_port_link               (                               ),  
        .i_mac5_port_axi_data           (                               ),  
        .i_mac5_axi_data_keep           (                               ),  
        .i_mac5_axi_data_valid          (                               ),  
        .o_mac5_axi_data_ready          (                               ),  
        .i_mac5_axi_data_last           (                               ),  
        .i_mac5_metadata                (                               ),  
        .i_mac5_metadata_valid          (                               ),  
        .i_mac5_metadata_last           (                               ),  
        .i_tx5_req                      (                               ),  
        .o_tx5_ack                      (                               ),  
    `endif
    `ifdef MAC6
        .i_mac6_port_link               (                               ),  
        .i_mac6_port_axi_data           (                               ),  
        .i_mac6_axi_data_keep           (                               ),  
        .i_mac6_axi_data_valid          (                               ),  
        .o_mac6_axi_data_ready          (                               ),  
        .i_mac6_axi_data_last           (                               ),  
        .i_mac6_metadata                (                               ),  
        .i_mac6_metadata_valid          (                               ),  
        .i_mac6_metadata_last           (                               ),  
        .i_tx6_req                      (                               ),  
        .o_tx6_ack                      (                               ),  
    `endif
    `ifdef MAC7
        .i_mac7_port_link               (                               ),  
        .i_mac7_port_axi_data           (                               ),  
        .i_mac7_axi_data_keep           (                               ),  
        .i_mac7_axi_data_valid          (                               ),  
        .o_mac7_axi_data_ready          (                               ),  
        .i_mac7_axi_data_last           (                               ),  
        .i_mac7_metadata                (                               ),  
        .i_mac7_metadata_valid          (                               ),  
        .i_mac7_metadata_last           (                               ),  
        .i_tx7_req                      (                               ),  
        .o_tx7_ack                      (                               ),  
    `endif
        
        // TSN AS??????????
        .o_tsn_as_port_link             (                               ),  
        .o_tsn_as_port_axi_data         (                               ),  
        .o_tsn_as_axi_data_keep         (                               ),  
        .o_tsn_as_axi_data_valid        (                               ),  
        .i_tsn_as_axi_data_ready        (                               ),  
        .o_tsn_as_axi_data_last         (                               ),  
        .i_tsn_as_channel_end           (                               ),  
        .o_tsn_as_metadata              (                               ),  
        .o_tsn_as_metadata_valid        (                               ),  
        .o_tsn_as_metadata_last         (                               ),  
        
        // TXMAC??????????
    `ifdef CPU_MAC
        .o_mac0_port_link               (                               ),  
        .o_mac0_port_axi_data           (                               ),  
        .o_mac0_axi_data_keep           (                               ),  
        .o_mac0_axi_data_valid          (                               ),  
        .i_mac0_axi_data_ready          (                               ),  
        .o_mac0_axi_data_last           (                               ),  
        .o_tx0_req                      (                               ),  
        .i_tx0_ack                      (                               ),  
    `endif
    `ifdef MAC1
        .o_mac1_port_link               (                               ),  
        .o_mac1_port_axi_data           (                               ),  
        .o_mac1_axi_data_keep           (                               ),  
        .o_mac1_axi_data_valid          (                               ),  
        .i_mac1_axi_data_ready          (                               ),  
        .o_mac1_axi_data_last           (                               ),  
        .o_tx1_req                      (                               ),  
        .i_tx1_ack                      (                               ),  
    `endif
    `ifdef MAC2
        .o_mac2_port_link               (                               ),  
        .o_mac2_port_axi_data           (                               ),  
        .o_mac2_axi_data_keep           (                               ),  
        .o_mac2_axi_data_valid          (                               ),  
        .i_mac2_axi_data_ready          (                               ),  
        .o_mac2_axi_data_last           (                               ),  
        .o_tx2_req                      (                               ),  
        .i_tx2_ack                      (                               ),  
    `endif
    `ifdef MAC3
        .o_mac3_port_link               (                               ),  
        .o_mac3_port_axi_data           (                               ),  
        .o_mac3_axi_data_keep           (                               ),  
        .o_mac3_axi_data_valid          (                               ),  
        .i_mac3_axi_data_ready          (                               ),  
        .o_mac3_axi_data_last           (                               ),  
        .o_tx3_req                      (                               ),  
        .i_tx3_ack                      (                               ),  
    `endif
    `ifdef MAC4
        .o_mac4_port_link               (                               ),  
        .o_mac4_port_axi_data           (                               ),  
        .o_mac4_axi_data_keep           (                               ),  
        .o_mac4_axi_data_valid          (                               ),  
        .i_mac4_axi_data_ready          (                               ),  
        .o_mac4_axi_data_last           (                               ),  
        .o_tx4_req                      (                               ),  
        .i_tx4_ack                      (                               ),  
    `endif
    `ifdef MAC5
        .o_mac5_port_link               (                               ),  
        .o_mac5_port_axi_data           (                               ),  
        .o_mac5_axi_data_keep           (                               ),  
        .o_mac5_axi_data_valid          (                               ),  
        .i_mac5_axi_data_ready          (                               ),  
        .o_mac5_axi_data_last           (                               ),  
        .o_tx5_req                      (                               ),  
        .i_tx5_ack                      (                               ),  
    `endif
    `ifdef MAC6
        .o_mac6_port_link               (                               ),  
        .o_mac6_port_axi_data           (                               ),  
        .o_mac6_axi_data_keep           (                               ),  
        .o_mac6_axi_data_valid          (                               ),  
        .i_mac6_axi_data_ready          (                               ),  
        .o_mac6_axi_data_last           (                               ),  
        .o_tx6_req                      (                               ),  
        .i_tx6_ack                      (                               ),  
    `endif
    `ifdef MAC7
        .o_mac7_port_link               (                               ),  
        .o_mac7_port_axi_data           (                               ),  
        .o_mac7_axi_data_keep           (                               ),  
        .o_mac7_axi_data_valid          (                               ),  
        .i_mac7_axi_data_ready          (                               ),  
        .o_mac7_axi_data_last           (                               ),  
        .o_tx7_req                      (                               ),  
        .i_tx7_ack                      (                               ),   
    `endif
        .i_clk                          (i_clk                          ),  
        .i_rst                          (i_rst                          )
);
`endif

`ifdef LLDP
    lldp_top u_lldp_top();
`endif


switch_core_regs #(
    .REG_ADDR_BUS_WIDTH             (REG_ADDR_BUS_WIDTH) ,  
    .REG_ADDR_WIDTH                 (REG_ADDR_OFS_WIDTH) ,  
    .REG_DATA_BUS_WIDTH             (REG_DATA_BUS_WIDTH)    
)switch_core_regs_inst (
    .i_clk                          ( i_clk                         )     ,   // 250MHz
    .i_rst                          ( i_rst                         )     ,
    /*-------------------------------------- 平台寄存器接口 -----------------------------------------*/
    //                     
    .i_refresh_list_pulse           ( i_refresh_list_pulse          )     , 
    .i_switch_err_cnt_clr           ( i_switch_err_cnt_clr          )     , 
    .i_switch_err_cnt_stat          ( i_switch_err_cnt_stat         )     , 
    //    
    .i_switch_reg_bus_we            ( i_switch_reg_bus_we           )     , 
    .i_switch_reg_bus_we_addr       ( i_switch_reg_bus_we_addr      )     , 
    .i_switch_reg_bus_we_din        ( i_switch_reg_bus_we_din       )     , 
    .i_switch_reg_bus_we_din_v      ( i_switch_reg_bus_we_din_v     )     , 
    //     
    .i_switch_reg_bus_rd            ( i_switch_reg_bus_rd           )     , 
    .i_switch_reg_bus_rd_addr       ( i_switch_reg_bus_rd_addr      )     , 
    .o_switch_reg_bus_rd_dout       ( o_switch_reg_bus_rd_dout      )     , 
    .o_switch_reg_bus_rd_dout_v     ( o_switch_reg_bus_rd_dout_v    )     , 
    /*---------------------------------------------------------------------------------------------*/
    .o_refresh_list_pulse           ( w_refresh_list_pulse          )     , 
    .o_switch_err_cnt_clr           ( w_switch_err_cnt_clr          )     , 
    .o_switch_err_cnt_stat          ( w_switch_err_cnt_stat         )     , 
    /*----------------------------------- RXMAC寄存器接口 -------------------------------------------*/    
    .o_rxmac_reg_bus_we             ( w_rxmac_reg_bus_we            )     , 
    .o_rxmac_reg_bus_we_addr        ( w_rxmac_reg_bus_we_addr       )     , 
    .o_rxmac_reg_bus_we_din         ( w_rxmac_reg_bus_we_din        )     , 
    .o_rxmac_reg_bus_we_din_v       ( w_rxmac_reg_bus_we_din_v      )     , 

    .o_rxmac_reg_bus_rd             ( w_rxmac_reg_bus_rd            )     , 
    .o_rxmac_reg_bus_rd_addr        ( w_rxmac_reg_bus_rd_addr       )     , 
    .i_rxmac_reg_bus_rd_dout        ( w_rxmac_reg_bus_rd_dout       )     , 
    .i_rxmac_reg_bus_rd_dout_v      ( w_rxmac_reg_bus_rd_dout_v     )     , 
    /*----------------------------------- TXMAC寄存器接口 -------------------------------------------*/    
    .o_txmac_reg_bus_we             ( w_txmac_reg_bus_we            )     , 
    .o_txmac_reg_bus_we_addr        ( w_txmac_reg_bus_we_addr       )     , 
    .o_txmac_reg_bus_we_din         ( w_txmac_reg_bus_we_din        )     , 
    .o_txmac_reg_bus_we_din_v       ( w_txmac_reg_bus_we_din_v      )     , 

    .o_txmac_reg_bus_rd             ( w_txmac_reg_bus_rd            )     , 
    .o_txmac_reg_bus_rd_addr        ( w_txmac_reg_bus_rd_addr       )     , 
    .i_txmac_reg_bus_rd_dout        ( w_txmac_reg_bus_rd_dout       )     , 
    .i_txmac_reg_bus_rd_dout_v      ( w_txmac_reg_bus_rd_dout_v     )     , 
    /*----------------------------------- Swlist寄存器接口 -------------------------------------------*/   
    `ifdef END_POINTER_SWITCH_CORE 
        .o_swlist_reg_bus_we            ( w_swlist_reg_bus_we           )     , 
        .o_swlist_reg_bus_we_addr       ( w_swlist_reg_bus_we_addr      )     , 
        .o_swlist_reg_bus_we_din        ( w_swlist_reg_bus_we_din       )     , 
        .o_swlist_reg_bus_we_din_v      ( w_swlist_reg_bus_we_din_v     )     , 

        .o_swlist_reg_bus_rd            ( w_swlist_reg_bus_rd           )     , 
        .o_swlist_reg_bus_rd_addr       ( w_swlist_reg_bus_rd_addr      )     , 
        .i_swlist_reg_bus_rd_dout       ( w_swlist_reg_bus_rd_dout      )     , 
        .i_swlist_reg_bus_rd_dout_v     ( w_swlist_reg_bus_rd_dout_v    )     , 
    `endif
    /**----------------------------------- CB寄存器接口 -------------------------------------------*/
    .o_cb_reg_bus_we                ( w_cb_reg_bus_we               )     , 
    .o_cb_reg_bus_we_addr           ( w_cb_reg_bus_we_addr          )     , 
    .o_cb_reg_bus_we_din            ( w_cb_reg_bus_we_din           )     , 
    .o_cb_reg_bus_we_din_v          ( w_cb_reg_bus_we_din_v         )     , 
    
    .o_cb_reg_bus_rd                ( w_cb_reg_bus_rd               )     , 
    .o_cb_reg_bus_rd_addr           ( w_cb_reg_bus_rd_addr          )     , 
    .i_cb_reg_bus_rd_dout           ( w_cb_reg_bus_rd_dout          )     , 
    .i_cb_reg_bus_rd_dout_v         ( w_cb_reg_bus_rd_dout_v        )     , 
    /*----------------------------------- AS寄存器接口 -------------------------------------------*/
    .o_as_reg_bus_we                ( w_as_reg_bus_we               )     , 
    .o_as_reg_bus_we_addr           ( w_as_reg_bus_we_addr          )     , 
    .o_as_reg_bus_we_din            ( w_as_reg_bus_we_din           )     , 
    .o_as_reg_bus_we_din_v          ( w_as_reg_bus_we_din_v         )     , 
    .o_as_reg_bus_rd                ( w_as_reg_bus_rd               )     , 
    .o_as_reg_bus_rd_addr           ( w_as_reg_bus_rd_addr          )     , 
    .i_as_reg_bus_rd_dout           ( w_as_reg_bus_rd_dout          )     , 
    .i_as_reg_bus_rd_dout_v         ( w_as_reg_bus_rd_dout_v        )     , 
    /*----------------------------- EtherNet Interface寄存器接口----------------------------------------*/
    .o_eth_reg_bus_we               ( w_eth_reg_bus_we              )     , 
    .o_eth_reg_bus_we_addr          ( w_eth_reg_bus_we_addr         )     , 
    .o_eth_reg_bus_we_din           ( w_eth_reg_bus_we_din          )     , 
    .o_eth_reg_bus_we_din_v         ( w_eth_reg_bus_we_din_v        )     , 
    .o_eth_reg_bus_rd               ( w_eth_reg_bus_rd              )     , 
    .o_eth_reg_bus_rd_addr          ( w_eth_reg_bus_rd_addr         )     , 
    .i_eth_reg_bus_rd_dout          ( w_eth_reg_bus_rd_dout         )     , 
    .i_eth_reg_bus_rd_dout_v        ( w_eth_reg_bus_rd_dout_v       )     , 
    /*----------------------------- MCU Interface寄存器接口----------------------------------------*/
    .o_mcu_reg_bus_we               ( w_mcu_reg_bus_we              )     , 
    .o_mcu_reg_bus_we_addr          ( w_mcu_reg_bus_we_addr         )     , 
    .o_mcu_reg_bus_we_din           ( w_mcu_reg_bus_we_din          )     , 
    .o_mcu_reg_bus_we_din_v         ( w_mcu_reg_bus_we_din_v        )     , 
    .o_mcu_reg_bus_rd               ( w_mcu_reg_bus_rd              )     , 
    .o_mcu_reg_bus_rd_addr          ( w_mcu_reg_bus_rd_addr         )     , 
    .i_mcu_reg_bus_rd_dout          ( w_mcu_reg_bus_rd_dout         )     , 
    .i_mcu_reg_bus_rd_dout_v        ( w_mcu_reg_bus_rd_dout_v       )       
);

endmodule 