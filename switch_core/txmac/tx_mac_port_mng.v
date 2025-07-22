`include "synth_cmd_define.vh"

module  tx_mac_port_mng #(
    parameter                                                   PORT_NUM                =      4        ,                   // 交换机的端口数
    parameter                                                   METADATA_WIDTH          =      64       ,                   // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,                   // Mac_port_mng 数据位宽
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,                   // 支持端口优先级 FIFO 的数量
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM  // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
        /*---------------------------------------- 特殊 IP 核接口输入 -------------------------------------------*/
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
    /*---------------------------------------- CROSS 数据流输入 -------------------------------------------*/
    // 聚合总线输入数据流
    input              wire   [CROSS_DATA_WIDTH:0]              i_cross_rx_data                     , // 聚合总线数据流，最高位表示crcerr
    input              wire                                     i_cross_rx_data_valid               , // 聚合总线数据流有效信号
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]        i_cross_rx_data_keep                , // 端口数据流掩码，有效字节指示
    output             wire   [PORT_NUM - 1:0]                  o_cross_rx_data_ready               , // 下游模块反压流水线
    input              wire                                     i_mac_axi_data_last                 , // 数据流结束标识
    //聚合总线输入信息流
    input              wire   [METADATA_WIDTH-1:0]              i_cross_metadata                    , // 聚合总线 metadata 数据
    input              wire                                     i_cross_metadata_valid              , // 聚合总线 metadata 数据有效信号
    input              wire                                     i_cross_metadata_last               , // 信息流结束标识
    output             wire                                     o_cross_metadata_ready              ,  // 下游模块反压流水线  
    /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
    // 数据流信息 
    output              wire                                    o_mac_port_link                     , // 端口的连接状态
    output              wire   [1:0]                            o_mac_port_speed                    , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    output              wire                                    o_mac_port_filter_preamble_v        , // 端口是否过滤前导码信息
    output              wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac_axi_data                      , // 端口数据流
    output              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac_axi_data_keep                 , // 端口数据流掩码，有效字节指示
    output              wire                                    o_mac_axi_data_valid                , // 端口数据有效
    input               wire                                    i_mac_axi_data_ready                , // 端口数据就绪信号,表示当前模块准备好接收数据
    output              wire                                    o_mac_axi_data_last                 , // 数据流结束标识
    // 报文时间打时间戳 
    output              wire                                    o_mac_time_irq                      , // 打时间戳中断信号
    output              wire  [7:0]                             o_mac_frame_seq                     , // 帧序列号
    output              wire  [7:0]                             o_timestamp_addr                      // 打时间戳存储的 RAM 地址
);

`ifdef TSN_AS
    wire                                    w_as_port_link                      ; // 端口的连接状态
    wire   [1:0]                            w_as_port_speed                     ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_as_port_filter_preamble_v         ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_as_axi_data                       ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_as_axi_data_keep                  ; // 端口数据流掩码，有效字节指示
    wire                                    w_as_axi_data_valid                 ; // 端口数据有效
    wire   [63:0]                           w_as_axi_data_user                  ; // AS 协议信息流
    wire                                    w_as_axi_data_ready                 ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_as_axi_data_last                  ; // 数据流结束标识

    assign          i_as_port_link              =   w_as_port_link              ;
    assign          i_as_port_speed             =   w_as_port_speed             ;
    assign          i_as_port_filter_preamble_v =   w_as_port_filter_preamble_v ;
    assign          i_as_axi_data               =   w_as_axi_data               ;
    assign          i_as_axi_data_keep          =   w_as_axi_data_keep          ;
    assign          i_as_axi_data_valid         =   w_as_axi_data_valid         ;
    assign          i_as_axi_data_user          =   w_as_axi_data_user          ;
    assign          w_as_axi_data_ready         =   o_as_axi_data_ready         ;
    assign          i_as_axi_data_last          =   w_as_axi_data_last          ;
`endif

`ifdef LLDP
    wire                                    w_lldp_port_link                    ; // 端口的连接状态
    wire   [1:0]                            w_lldp_port_speed                   ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_lldp_port_filter_preamble_v       ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_lldp_axi_data                     ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_lldp_axi_data_keep                ; // 端口数据流掩码，有效字节指示
    wire                                    w_lldp_axi_data_valid               ; // 端口数据有效
    wire   [63:0]                           w_lldp_axi_data_user                ; // LLDP 协议信息流
    wire                                    w_lldp_axi_data_ready               ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_lldp_axi_data_last                ; // 数据流结束标识

    assign      i_lldp_port_link              =   w_lldp_port_link              ;
    assign      i_lldp_port_speed             =   w_lldp_port_speed             ;
    assign      i_lldp_port_filter_preamble_v =   w_lldp_port_filter_preamble_v ;
    assign      i_lldp_axi_data               =   w_lldp_axi_data               ;
    assign      i_lldp_axi_data_keep          =   w_lldp_axi_data_keep          ;
    assign      i_lldp_axi_data_valid         =   w_lldp_axi_data_valid         ;
    assign      i_lldp_axi_data_user          =   w_lldp_axi_data_user          ;
    assign      o_lldp_axi_data_ready         =   w_lldp_axi_data_ready         ;
    assign      i_lldp_axi_data_last          =   w_lldp_axi_data_last          ;
`endif

`ifdef TSN_CB
    wire                                    w_cb_port_link                      ; // 端口的连接状态
    wire   [1:0]                            w_cb_port_speed                     ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_cb_port_filter_preamble_v         ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_cb_axi_data                       ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_cb_axi_data_keep                  ; // 端口数据流掩码，有效字节指示
    wire                                    w_cb_axi_data_valid                 ; // 端口数据有效
    wire   [63:0]                           w_cb_axi_data_user                  ; // LLDP 协议信息流
    wire                                    w_cb_axi_data_ready                 ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_cb_axi_data_last                  ; // 数据流结束标识

    assign      i_cb_port_link                  =   w_cb_port_link              ;
    assign      i_cb_port_speed                 =   w_cb_port_speed             ;
    assign      i_cb_port_filter_preamble_v     =   w_cb_port_filter_preamble_v ;
    assign      i_cb_axi_data                   =   w_cb_axi_data               ;
    assign      i_cb_axi_data_keep              =   w_cb_axi_data_keep          ;
    assign      i_cb_axi_data_valid             =   w_cb_axi_data_valid         ;
    assign      i_cb_axi_data_user              =   w_cb_axi_data_user          ;
    assign      w_cb_axi_data_ready             =   o_cb_axi_data_ready         ;
    assign      i_cb_axi_data_last              =   w_cb_axi_data_last          ;
`endif

    wire   [CROSS_DATA_WIDTH:0]              w_cross_rx_data                    ; // 聚合总线数据流，最高位表示crcerr
    wire                                     w_cross_rx_data_valid              ; // 聚合总线数据流有效信号
    wire   [(CROSS_DATA_WIDTH/8)-1:0]        w_cross_rx_data_keep               ; // 端口数据流掩码，有效字节指示
    wire   [PORT_NUM - 1:0]                  w_cross_rx_data_ready              ; // 下游模块反压流水线
    wire                                     w_mac_axi_data_last                ; // 数据流结束标识
    //聚合总线输入信息流
    wire   [METADATA_WIDTH-1:0]              w_cross_metadata                   ; // 聚合总线 metadata 数据
    wire                                     w_cross_metadata_valid             ; // 聚合总线 metadata 数据有效信号
    wire                                     w_cross_metadata_last              ; // 信息流结束标识
    wire                                     w_cross_metadata_ready             ;  // 下游模块反压流水线  
    /*------------------------------------------ IP 核接口输出 -------------------------------------------*/
    // 数据流信息 
    wire                                    w_mac_port_link                     ; // 端口的连接状态
    wire   [1:0]                            w_mac_port_speed                    ; // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    wire                                    w_mac_port_filter_preamble_v        ; // 端口是否过滤前导码信息
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac_axi_data                      ; // 端口数据流
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac_axi_data_keep                 ; // 端口数据流掩码，有效字节指示
    wire                                    w_mac_axi_data_valid                ; // 端口数据有效
    wire                                    w_mac_axi_data_ready                ; // 端口数据就绪信号,表示当前模块准备好接收数据
    wire                                    w_mac_axi_data_last                 ; // 数据流结束标识
    // 报文时间打时间戳 
    wire                                    w_mac_time_irq                      ; // 打时间戳中断信号
    wire  [7:0]                             w_mac_frame_seq                     ; // 帧序列号
    wire  [7:0]                             w_timestamp_addr                    ; // 打时间戳存储的 RAM 地址

    assign          i_cross_rx_data             =    w_cross_rx_data                ;    
    assign          i_cross_rx_data_valid       =    w_cross_rx_data_valid          ;    
    assign          i_cross_rx_data_keep        =    w_cross_rx_data_keep           ;    
    assign          w_cross_rx_data_ready       =    o_cross_rx_data_ready          ;    
    assign          i_mac_axi_data_last         =    w_mac_axi_data_last            ;   
            
    assign          i_cross_metadata            =    w_cross_metadata               ;
    assign          i_cross_metadata_valid      =    w_cross_metadata_valid         ;
    assign          i_cross_metadata_last       =    w_cross_metadata_last          ;
    assign          w_cross_metadata_ready      =    o_cross_metadata_ready         ;
            
    assign          w_mac_port_link             =    o_mac_port_link                ;
    assign          w_mac_port_speed            =    o_mac_port_speed               ;
    assign          w_mac_port_filter_preamble_v=    o_mac_port_filter_preamble_v   ;
    assign          w_mac_axi_data              =    o_mac_axi_data                 ;
    assign          w_mac_axi_data_keep         =    o_mac_axi_data_keep            ;
    assign          w_mac_axi_data_valid        =    o_mac_axi_data_valid           ;
    assign          i_mac_axi_data_ready        =    w_mac_axi_data_ready           ;
    assign          w_mac_axi_data_last         =    o_mac_axi_data_last            ;
            
    assign          w_mac_time_irq              =    o_mac_time_irq                 ;  
    assign          w_mac_frame_seq             =    o_mac_frame_seq                ;  
    assign          w_timestamp_addr            =    o_timestamp_addr               ;  
             

    wire                                    w_mac_port_link                         ;
    wire   [1:0]                            w_mac_port_speed                        ;
    wire                                    w_mac_port_filter_preamble_v            ;
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac_axi_data                          ;
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac_axi_data_keep                     ;
    wire                                    w_mac_axi_data_valid                    ;
    wire                                    w_mac_axi_data_ready                    ;
    wire                                    w_mac_axi_data_last                     ;       

    assign          w_mac_port_link                 =  o_mac_port_link              ;
    assign          w_mac_port_speed                =  o_mac_port_speed             ;
    assign          w_mac_port_filter_preamble_v    =  o_mac_port_filter_preamble_v ;
    assign          w_mac_axi_data                  =  o_mac_axi_data               ;
    assign          w_mac_axi_data_keep             =  o_mac_axi_data_keep          ;
    assign          w_mac_axi_data_valid            =  o_mac_axi_data_valid         ;
    assign          i_mac_axi_data_ready            =  w_mac_axi_data_ready         ;
    assign          w_mac_axi_data_last             =  o_mac_axi_data_last          ;
    /*--------------------------- 内部调度流水线信息交互 ---------------------------*/
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_tx_mac_forward_info                   ;          
    wire                                    w_tx_mac_forward_info_vld               ;  
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_ControlList_state                     ;
    wire   [PORT_FIFO_PRI_NUM-1:0]          w_fifo_pri_rd_en                        ;

forward_cache_mng #(
    .PORT_NUM                                       (PORT_NUM                   ),           // 交换机的端口数
    .METADATA_WIDTH                                 (METADATA_WIDTH             ),           // 信息流（METADATA）的位宽
    .PORT_MNG_DATA_WIDTH                            (PORT_MNG_DATA_WIDTH        ),           // Mac_port_mng 数据位宽
    .PORT_FIFO_PRI_NUM                              ('d8                        ),           // 支持端口优先级 FIFO 的数量
    .FIFO_NUM_BYTE                                  ('d150000                   ),           // 优先级 FIFO 缓存大小(Byte)
    .FIFO_ADDR_WIDTH                                ('d14                       ),           // 优先级 FIFO 缓存大小
    .CROSS_DATA_WIDTH                               (CROSS_DATA_WIDTH           )            // 聚合总线输出 
)forward_cache_mng_inst (
    .i_clk                                          (i_clk                      ),   // 250MHz
    .i_rst                                          (i_rst                      ),
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/

    /*---------------------------------------- 特殊 IP 核接口输入 ---------------------------------------*/
`ifdef TSN_AS
    // 数据流信息 
    .i_as_port_link                                 (w_as_port_link                 ), // 端口的连接状态
    .i_as_port_speed                                (w_as_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_as_port_filter_preamble_v                    (w_as_port_filter_preamble_v    ), // 端口是否过滤前导码信息
    .i_as_axi_data                                  (w_as_axi_data                  ), // 端口数据流
    .i_as_axi_data_keep                             (w_as_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .i_as_axi_data_valid                            (w_as_axi_data_valid            ), // 端口数据有效
    .i_as_axi_data_user                             (w_as_axi_data_user             ), // AS 协议信息流
    .o_as_axi_data_ready                            (w_as_axi_data_ready            ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_as_axi_data_last                             (w_as_axi_data_last             ), // 数据流结束标识
`endif
`ifdef LLDP
    // 数据流信息 
    .i_lldp_port_link                               (w_lldp_port_link               ), // 端口的连接状态
    .i_lldp_port_speed                              (w_lldp_port_speed              ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_lldp_port_filter_preamble_v                  (w_lldp_port_filter_preamble_v  ), // 端口是否过滤前导码信息
    .i_lldp_axi_data                                (w_lldp_axi_data                ), // 端口数据流
    .i_lldp_axi_data_keep                           (w_lldp_axi_data_keep           ), // 端口数据流掩码，有效字节指示
    .i_lldp_axi_data_valid                          (w_lldp_axi_data_valid          ), // 端口数据有效
    .i_lldp_axi_data_user                           (w_lldp_axi_data_user           ), // LLDP 协议信息流
    .o_lldp_axi_data_ready                          (w_lldp_axi_data_ready          ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_lldp_axi_data_last                           (w_lldp_axi_data_last           ), // 数据流结束标识
`endif
`ifdef TSN_CB 
    // 数据流信息 
    .i_cb_port_link                                 (w_cb_port_link                 ), // 端口的连接状态
    .i_cb_port_speed                                (w_cb_port_speed                ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .i_cb_port_filter_preamble_v                    (w_cb_port_filter_preamble_v    ), // 端口是否过滤前导码信息
    .i_cb_axi_data                                  (w_cb_axi_data                  ), // 端口数据流
    .i_cb_axi_data_keep                             (w_cb_axi_data_keep             ), // 端口数据流掩码，有效字节指示
    .i_cb_axi_data_valid                            (w_cb_axi_data_valid            ), // 端口数据有效
    .i_cb_axi_data_user                             (w_cb_axi_data_user             ), // CB 协议信息流
    .o_cb_axi_data_ready                            (w_cb_axi_data_ready            ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .i_cb_axi_data_last                             (w_cb_axi_data_last             ), // 数据流结束标识
`endif
    /*---------------------------------------- CROSS 数据流输入 --------------------------------------*/
    // 聚合总线输入数据流
    .i_cross_rx_data                                (w_cross_rx_data                ) , // 聚合总线数据流，最高位表示crcerr
    .i_cross_rx_data_valid                          (w_cross_rx_data_valid          ) , // 聚合总线数据流有效信号
    .i_cross_rx_data_keep                           (w_cross_rx_data_keep           ) , // 端口数据流掩码，有效字节指示
    .o_cross_rx_data_ready                          (w_cross_rx_data_ready          ) , // 下游模块反压流水线
    .i_mac_axi_data_last                            (w_mac_axi_data_last            ) , // 数据流结束标识
    //聚合总线输入信息流
    .i_cross_metadata                               (w_cross_metadata               ), // 聚合总线 metadata 数据
    .i_cross_metadata_valid                         (w_cross_metadata_valid         ), // 聚合总线 metadata 数据有效信号
    .i_cross_metadata_last                          (w_cross_metadata_last          ), // 信息流结束标识
    .o_cross_metadata_ready                         (w_cross_metadata_ready         ), // 下游模块反压流水线  
    /*---------------------------------- 端口队列管理模块的调度信息输出 ------------------------------*/
    .o_tx_mac_forward_info                          (w_tx_mac_forward_info          ), // 调度相关帧信息 0:7 - 8个优先级 FIFO 的空信号
    .o_tx_mac_forward_info_vld                      (w_tx_mac_forward_info_vld      ), // 调度相关帧信息使能，每发送完一个报文，触发使能信号，调度信息流走一次调度流水线 
    /*------------------------- 调度流水线的最后一级来读取特定优先级 FIFO 数据 ------------------------*/
    .i_fifo_pri_rd_en                               (w_fifo_pri_rd_en               ), 
    .o_mac_port_link                                (w_mac_port_link                ), // 端口的连接状态
    .o_mac_port_speed                               (w_mac_port_speed               ), // 端口速率信息，00-10M，01-100M，10-1000M，10-10G
    .o_mac_port_filter_preamble_v                   (w_mac_port_filter_preamble_v   ), // 端口是否过滤前导码信息
    .o_mac_axi_data                                 (w_mac_axi_data                 ), // 端口数据流
    .o_mac_axi_data_keep                            (w_mac_axi_data_keep            ), // 端口数据流掩码，有效字节指示
    .o_mac_axi_data_valid                           (w_mac_axi_data_valid           ), // 端口数据有效
    .i_mac_axi_data_ready                           (i_mac_axi_data_ready           ), // 端口数据就绪信号,表示当前模块准备好接收数据
    .o_mac_axi_data_last                            (w_mac_axi_data_last            ) // 数据流结束标识
);

tsn_qbv_mng #(
    .PORT_FIFO_PRI_NUM                              (PORT_FIFO_PRI_NUM              ),                   // 支持端口优先级 FIFO 的数量
)tsn_qbv_mng_inst (
    .i_clk                                          (i_clk                          ),   // 250MHz
    .i_rst                                          (i_rst                          ),
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/

    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    .o_ControlList_state                            (w_ControlList_state            )                   // 门控列表的状态
);

tx_qos_mng #(
    .PORT_FIFO_PRI_NUM                              (PORT_FIFO_PRI_NUM              ),                   // 支持端口优先级 FIFO 的数量
)tx_qos_mng_inst (
    .i_clk                                          (i_clk                          ),   // 250MHz
    .i_rst                                          (i_rst                          ),
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    
    /*------------------------------------ 输入调度信息 --------------------------------*/ 
    .i_tx_mac_forward_info                          (w_tx_mac_forward_info          ),  // 调度相关帧信息 0:7 - 8个优先级 FIFO 的空信号   
    .i_tx_mac_forward_info_vld                      (w_tx_mac_forward_info_vld      ), // 调度相关帧信息使能，每发送完一个报文，触发使能信号，调度信息流走一次调度流水线  
    .i_ControlList_state                            (w_ControlList_state            ),  // 门控列表的状态
    /*---------------------------- 根据调度算法输出需要调度优先级队列 --------------------------------*/ 
    .o_fifo_pri_rd_en                               (w_fifo_pri_rd_en               )                    
);

endmodule