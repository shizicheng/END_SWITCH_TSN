module swlist#(
    parameter                                                   PORT_NUM                =      8        ,  // 交换机的端口数
    parameter                                                   PORT_WIDTH              =      PORT_NUM ,  // 端口位宽，等于端口数
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   METADATA_WIDTH          =      64       ,  // 信息流（METADATA）的位宽
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽 
    parameter                                                   HASH_DATA_WIDTH         =      15       ,  // 哈希计算的值的位宽
    parameter                                                   ADDR_WIDTH              =      6        ,  // 地址表的深度 
    parameter                                                   VLAN_ID_WIDTH           =      12       ,  // VLAN ID位宽
    parameter                                                   MAC_ADDR_WIDTH          =      48       ,  // MAC地址位宽
    parameter                                                   STATIC_RAM_SIZE         =      256      ,  // 静态MAC表的位宽 
    parameter                                                   AGE_SCAN_INTERVAL       =      5        ,  // 老化扫描间隔（秒）
    parameter                                                   SIM_MODE                =      0        ,  // 仿真模式：1=快速仿真模式，0=正常模式
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,   
`ifdef CPU_MAC
    input               wire   [11:0]                           i_vlan_id_cpu                       , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac_cpu_hash_key                 , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac_cpu                          , // 目的 mac 的值
    input               wire                                    i_dmac_cpu_vld                      , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac_cpu_hash_key                 , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac_cpu                          , // 源 mac 的值
    input               wire                                    i_smac_cpu_vld                      , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_cpu_port                       ,
    output              wire                                    o_tx_cpu_port_vld                   ,
    output              wire   [1:0]                            o_tx_cpu_port_broadcast             , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC1
    input               wire   [11:0]                           i_vlan_id1                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac1_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac1                             , // 目的 mac 的值
    input               wire                                    i_dmac1_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac1_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac1                             , // 源 mac 的值
    input               wire                                    i_smac1_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_1_port                         ,
    output              wire                                    o_tx_1_port_vld                     ,
    output              wire   [1:0]                            o_tx_1_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif  
`ifdef MAC2
    input               wire   [11:0]                           i_vlan_id2                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac2_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac2                             , // 目的 mac 的值
    input               wire                                    i_dmac2_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac2_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac2                             , // 源 mac 的值
    input               wire                                    i_smac2_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_2_port                         ,
    output              wire                                    o_tx_2_port_vld                     ,
    output              wire   [1:0]                            o_tx_2_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC3
    input               wire   [11:0]                           i_vlan_id3                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac3_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac3                             , // 目的 mac 的值
    input               wire                                    i_dmac3_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac3_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac3                             , // 源 mac 的值
    input               wire                                    i_smac3_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_3_port                          ,
    output              wire                                    o_tx_3_port_vld                      ,
    output              wire   [1:0]                            o_tx_3_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC4
    input               wire   [11:0]                           i_vlan_id4                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac4_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac4                             , // 目的 mac 的值
    input               wire                                    i_dmac4_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac4_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac4                             , // 源 mac 的值
    input               wire                                    i_smac4_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_4_port                         ,
    output              wire                                    o_tx_4_port_vld                     ,
    output              wire   [1:0]                            o_tx_4_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC5
    input               wire   [11:0]                           i_vlan_id5                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac5_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac5                             , // 目的 mac 的值
    input               wire                                    i_dmac5_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac5_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac5                             , // 源 mac 的值
    input               wire                                    i_smac5_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_5_port                         ,
    output              wire                                    o_tx_5_port_vld                     ,
    output              wire   [1:0]                            o_tx_5_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC6
    input               wire   [11:0]                           i_vlan_id6                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac6_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac6                             , // 目的 mac 的值
    input               wire                                    i_dmac6_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac6_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac6                             , // 源 mac 的值
    input               wire                                    i_smac6_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_6_port                         ,
    output              wire                                    o_tx_6_port_vld                     ,
    output              wire   [1:0]                            o_tx_6_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif
`ifdef MAC7
    input               wire   [11:0]                           i_vlan_id7                          , // VLAN ID值
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac7_hash_key                    , // 目的 mac 的哈希值
    input               wire   [47 : 0]                         i_dmac7                             , // 目的 mac 的值
    input               wire                                    i_dmac7_vld                         , // dmac_vld
    input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac7_hash_key                    , // 源 mac 的值有效标识
    input               wire   [47 : 0]                         i_smac7                             , // 源 mac 的值
    input               wire                                    i_smac7_vld                         , // smac_vld

    output              wire   [PORT_WIDTH - 1:0]               o_tx_7_port                         ,
    output              wire                                    o_tx_7_port_vld                     ,
    output              wire   [1:0]                            o_tx_7_port_broadcast               , // 01:组播 10：广播 11:泛洪
`endif 
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
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
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_we_dout            , // 读出寄存器数据
    output              wire                                    o_switch_reg_bus_we_dout_v            // 读数据有效使能
);

// 包含头文件
`include "synth_cmd_define.vh"

// key_arbit模块输出的仲裁结果信号
    wire   [11 : 0]                         w_vlan_id                           ; // VLAN ID信号
    wire   [PORT_NUM - 1:0]                 w_dmac_port                         ; // 仲裁输出的DMAC端口
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_hash_key                     ; // 目的MAC的哈希值
    wire   [47 : 0]                         w_dmac                              ; // 目的MAC的值
    wire                                    w_dmac_vld                          ; // DMAC有效信号
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_hash_key                     ; // 源MAC的哈希值
    wire   [47 : 0]                         w_smac                              ; // 源MAC的值
    wire                                    w_smac_vld                          ; // SMAC有效信号
    wire   [PORT_NUM - 1:0]                 w_tx_port                           ; // 最终输出端口
    wire                                    w_tx_port_vld                       ; // 最终输出端口有效信号
    wire   [1:0]                            w_tx_port_broadcast                 ; // 01:组播 10：广播 11:泛洪
     
    // DMAC表读写接口信号
    wire   [11 : 0]                         w_dmac_item_vlan_id                 ; // DMAC表VLAN ID
    wire   [HASH_DATA_WIDTH-1:0]            w_dmac_item_dmac_addr               ; // DMAC地址表项
    wire                                    w_dmac_item_dmac_addr_vld           ; // DMAC地址表项有效位
    wire   [47:0]                           w_dmac_item_dmac_in                 ; // DMAC输入
    wire   [HASH_DATA_WIDTH-1:0]            w_dmac_item_smac_addr               ; // SMAC地址表项
    wire                                    w_dmac_item_smac_addr_vld           ; // SMAC地址表项有效位
    wire   [47:0]                           w_dmac_item_smac_in                 ; // SMAC输入
    wire   [PORT_NUM - 1:0]                 w_dmac_item_mac_rx_port             ; // DMAC输入端口
    
    // CLASH冲突表读写接口信号
    wire   [11 : 0]                         w_clash_item_vlan_id                ; // CLASH表VLAN ID
    wire   [HASH_DATA_WIDTH-1:0]            w_clash_item_dmac_addr              ; // CLASH DMAC地址表项
    wire                                    w_clash_item_dmac_addr_vld          ; // CLASH DMAC地址表项有效位
    wire   [47:0]                           w_clash_item_dmac_in                ; // CLASH DMAC输入
    wire   [HASH_DATA_WIDTH-1:0]            w_clash_item_smac_addr              ; // CLASH SMAC地址表项
    wire                                    w_clash_item_smac_addr_vld          ; // CLASH SMAC地址表项有效位
    wire   [47:0]                           w_clash_item_smac_in                ; // CLASH SMAC输入
    wire   [PORT_NUM - 1:0]                 w_clash_item_mac_rx_port            ; // CLASH输入端口

    // 查表结果信号
    wire   [PORT_NUM : 0]                   w_smac_tx_port_rslt                 ; // SMAC查表结果端口向量
    wire                                    w_smac_tx_port_vld                  ; // SMAC查表结果有效信号

    wire                                    w_dmac_find_out_en                  ; // DMAC查找输出使能
    wire   [PORT_NUM:0]                     w_dmac_find_rslt                    ; // DMAC查找结果端口向量
    wire                                    w_dmac_find_out_clash               ; // DMAC查找冲突标志

    wire   [PORT_NUM:0]                     w_clash_tx_port_rslt                ; // 冲突表查表结果端口向量
    wire                                    w_clash_tx_port_vld                 ; // 冲突表查表结果有效信号

    // look_up_mng输出信号
    wire   [47 : 0]                         w_lookup_dmac_out                   ; // 查表引擎输出DMAC
    wire   [11 : 0]                         w_lookup_vlan_id                    ; // 查表引擎输出VLAN ID
    wire                                    w_lookup_dmac_vld_out               ; // 查表引擎输出DMAC有效信号

    // key_arbit输出到各端口的信号  
`ifdef CPU_MAC
    wire   [PORT_NUM : 0]                   w_tx_cpu_port                       ; // CPU端口输出
    wire                                    w_tx_cpu_port_vld                   ; // CPU端口输出有效
    wire   [1:0]                            w_tx_cpu_port_broadcast             ; // CPU端口广播类型输出
`endif
`ifdef MAC1
    wire   [PORT_NUM : 0]                   w_tx_1_port                         ; // MAC1端口输出
    wire                                    w_tx_1_port_vld                     ; // MAC1端口输出有效
    wire   [1:0]                            w_tx_1_port_broadcast               ; // MAC1端口广播类型输出
`endif
`ifdef MAC2
    wire   [PORT_NUM : 0]                   w_tx_2_port                         ; // MAC2端口输出
    wire                                    w_tx_2_port_vld                     ; // MAC2端口输出有效
    wire   [1:0]                            w_tx_2_port_broadcast               ; // MAC2端口广播类型输出
`endif
`ifdef MAC3
    wire   [PORT_NUM : 0]                   w_tx_3_port                         ; // MAC3端口输出
    wire                                    w_tx_3_port_vld                     ; // MAC3端口输出有效
    wire   [1:0]                            w_tx_3_port_broadcast               ; // MAC3端口广播类型输出
`endif
`ifdef MAC4
    wire   [PORT_NUM : 0]                   w_tx_4_port                         ; // MAC4端口输出
    wire                                    w_tx_4_port_vld                     ; // MAC4端口输出有效
    wire   [1:0]                            w_tx_4_port_broadcast               ; // MAC4端口广播类型输出
`endif
`ifdef MAC5
    wire   [PORT_NUM : 0]                   w_tx_5_port                         ; // MAC5端口输出
    wire                                    w_tx_5_port_vld                     ; // MAC5端口输出有效
    wire   [1:0]                            w_tx_5_port_broadcast               ; // MAC5端口广播类型输出
`endif
`ifdef MAC6
    wire   [PORT_NUM : 0]                   w_tx_6_port                         ; // MAC6端口输出
    wire                                    w_tx_6_port_vld                     ; // MAC6端口输出有效
    wire   [1:0]                            w_tx_6_port_broadcast               ; // MAC6端口广播类型输出
`endif
`ifdef MAC7
    wire   [PORT_NUM : 0]                   w_tx_7_port                         ; // MAC7端口输出
    wire                                    w_tx_7_port_vld                     ; // MAC7端口输出有效
    wire   [1:0]                            w_tx_7_port_broadcast               ; // MAC7端口广播类型输出
`endif
    
    // 各端口输出连接
`ifdef CPU_MAC
    assign o_tx_cpu_port = w_tx_cpu_port[PORT_NUM-1:0];                          // 连接CPU端口输出
    assign o_tx_cpu_port_vld = w_tx_cpu_port_vld;                                // 连接CPU端口有效信号
    assign o_tx_cpu_port_broadcast = w_tx_cpu_port_broadcast;                    // 连接CPU端口广播类型信号
`endif
`ifdef MAC1
    assign o_tx_1_port = w_tx_1_port[PORT_NUM-1:0];                              // 连接MAC1端口输出
    assign o_tx_1_port_vld = w_tx_1_port_vld;                                    // 连接MAC1端口有效信号
    assign o_tx_1_port_broadcast = w_tx_1_port_broadcast;                        // 连接MAC1端口广播类型信号
`endif
`ifdef MAC2
    assign o_tx_2_port = w_tx_2_port[PORT_NUM-1:0];                              // 连接MAC2端口输出
    assign o_tx_2_port_vld = w_tx_2_port_vld;                                    // 连接MAC2端口有效信号
    assign o_tx_2_port_broadcast = w_tx_2_port_broadcast;                        // 连接MAC2端口广播类型信号
`endif
`ifdef MAC3
    assign o_tx_3_port = w_tx_3_port[PORT_NUM-1:0];                              // 连接MAC3端口输出
    assign o_tx_3_port_vld = w_tx_3_port_vld;                                    // 连接MAC3端口有效信号
    assign o_tx_3_port_broadcast = w_tx_3_port_broadcast;                        // 连接MAC3端口广播类型信号
`endif
`ifdef MAC4
    assign o_tx_4_port = w_tx_4_port[PORT_NUM-1:0];                              // 连接MAC4端口输出
    assign o_tx_4_port_vld = w_tx_4_port_vld;                                    // 连接MAC4端口有效信号
    assign o_tx_4_port_broadcast = w_tx_4_port_broadcast;                        // 连接MAC4端口广播类型信号
`endif
`ifdef MAC5
    assign o_tx_5_port = w_tx_5_port[PORT_NUM-1:0];                              // 连接MAC5端口输出
    assign o_tx_5_port_vld = w_tx_5_port_vld;                                    // 连接MAC5端口有效信号
    assign o_tx_5_port_broadcast = w_tx_5_port_broadcast;                        // 连接MAC5端口广播类型信号
`endif
`ifdef MAC6
    assign o_tx_6_port = w_tx_6_port[PORT_NUM-1:0];                              // 连接MAC6端口输出
    assign o_tx_6_port_vld = w_tx_6_port_vld;                                    // 连接MAC6端口有效信号
    assign o_tx_6_port_broadcast = w_tx_6_port_broadcast;                        // 连接MAC6端口广播类型信号
`endif
`ifdef MAC7
    assign o_tx_7_port = w_tx_7_port[PORT_NUM-1:0];                              // 连接MAC7端口输出
    assign o_tx_7_port_vld = w_tx_7_port_vld;                                    // 连接MAC7端口有效信号
    assign o_tx_7_port_broadcast = w_tx_7_port_broadcast;                        // 连接MAC7端口广播类型信号
`endif
    

// 外部输入需要查表的信息   
key_arbit #(
    .PORT_NUM                   (PORT_NUM                   ),
    .REG_ADDR_BUS_WIDTH         (REG_ADDR_BUS_WIDTH         ),
    .REG_DATA_BUS_WIDTH         (REG_DATA_BUS_WIDTH         ),
    .METADATA_WIDTH             (METADATA_WIDTH             ),
    .PORT_MNG_DATA_WIDTH        (PORT_MNG_DATA_WIDTH        ),
    .HASH_DATA_WIDTH            (HASH_DATA_WIDTH            ),
    .CROSS_DATA_WIDTH           (CROSS_DATA_WIDTH           ) 
) key_arbit_inst (
    .i_clk                      (i_clk                      ),
    .i_rst                      (i_rst                      ),
`ifdef CPU_MAC
    .i_vlan_id_cpu              (i_vlan_id_cpu              ),
    .i_dmac_cpu_hash_key        (i_dmac_cpu_hash_key        ),
    .i_dmac_cpu                 (i_dmac_cpu                 ),
    .i_dmac_cpu_vld             (i_dmac_cpu_vld             ),
    .i_smac_cpu_hash_key        (i_smac_cpu_hash_key        ),
    .i_smac_cpu                 (i_smac_cpu                 ),
    .i_smac_cpu_vld             (i_smac_cpu_vld             ),
    .o_tx_cpu_port              (w_tx_cpu_port              ), 
    .o_tx_cpu_port_vld          (w_tx_cpu_port_vld          ), 
    .o_tx_cpu_port_broadcast    (w_tx_cpu_port_broadcast    ),
`endif
`ifdef MAC1
    .i_vlan_id1                 (i_vlan_id1                 ),
    .i_dmac1_hash_key           (i_dmac1_hash_key           ),
    .i_dmac1                    (i_dmac1                    ),
    .i_dmac1_vld                (i_dmac1_vld                ),
    .i_smac1_hash_key           (i_smac1_hash_key           ),
    .i_smac1                    (i_smac1                    ),
    .i_smac1_vld                (i_smac1_vld                ),
    .o_tx_1_port                (w_tx_1_port                ), 
    .o_tx_1_port_vld            (w_tx_1_port_vld            ), 
    .o_tx_1_port_broadcast      (w_tx_1_port_broadcast      ),
`endif
`ifdef MAC2
    .i_vlan_id2                 (i_vlan_id2                 ),
    .i_dmac2_hash_key           (i_dmac2_hash_key           ),
    .i_dmac2                    (i_dmac2                    ),
    .i_dmac2_vld                (i_dmac2_vld                ),
    .i_smac2_hash_key           (i_smac2_hash_key           ),
    .i_smac2                    (i_smac2                    ),
    .i_smac2_vld                (i_smac2_vld                ),
    .o_tx_2_port                (w_tx_2_port                ), 
    .o_tx_2_port_vld            (w_tx_2_port_vld            ), 
    .o_tx_2_port_broadcast      (w_tx_2_port_broadcast      ),
`endif
`ifdef MAC3
    .i_vlan_id3                 (i_vlan_id3                 ),
    .i_dmac3_hash_key           (i_dmac3_hash_key           ),
    .i_dmac3                    (i_dmac3                    ),
    .i_dmac3_vld                (i_dmac3_vld                ),
    .i_smac3_hash_key           (i_smac3_hash_key           ),
    .i_smac3                    (i_smac3                    ),
    .i_smac3_vld                (i_smac3_vld                ),
    .o_tx_3_port                (w_tx_3_port                ), 
    .o_tx_3_port_vld            (w_tx_3_port_vld            ), 
    .o_tx_3_port_broadcast      (w_tx_3_port_broadcast      ),
`endif
`ifdef MAC4
    .i_vlan_id4                 (i_vlan_id4                 ),
    .i_dmac4_hash_key           (i_dmac4_hash_key           ),
    .i_dmac4                    (i_dmac4                    ),
    .i_dmac4_vld                (i_dmac4_vld                ),
    .i_smac4_hash_key           (i_smac4_hash_key           ),
    .i_smac4                    (i_smac4                    ),
    .i_smac4_vld                (i_smac4_vld                ),
    .o_tx_4_port                (w_tx_4_port                ), 
    .o_tx_4_port_vld            (w_tx_4_port_vld            ), 
    .o_tx_4_port_broadcast      (w_tx_4_port_broadcast      ),
`endif
`ifdef MAC5
    .i_vlan_id5                 (i_vlan_id5                 ),
    .i_dmac5_hash_key           (i_dmac5_hash_key           ),
    .i_dmac5                    (i_dmac5                    ),
    .i_dmac5_vld                (i_dmac5_vld                ),
    .i_smac5_hash_key           (i_smac5_hash_key           ),
    .i_smac5                    (i_smac5                    ),
    .i_smac5_vld                (i_smac5_vld                ),
    .o_tx_5_port                (w_tx_5_port                ), 
    .o_tx_5_port_vld            (w_tx_5_port_vld            ), 
    .o_tx_5_port_broadcast      (w_tx_5_port_broadcast      ),
`endif
`ifdef MAC6
    .i_vlan_id6                 (i_vlan_id6                 ),
    .i_dmac6_hash_key           (i_dmac6_hash_key           ),
    .i_dmac6                    (i_dmac6                    ),
    .i_dmac6_vld                (i_dmac6_vld                ),
    .i_smac6_hash_key           (i_smac6_hash_key           ),
    .i_smac6                    (i_smac6                    ),
    .i_smac6_vld                (i_smac6_vld                ),
    .o_tx_6_port                (w_tx_6_port                ), 
    .o_tx_6_port_vld            (w_tx_6_port_vld            ), 
    .o_tx_6_port_broadcast      (w_tx_6_port_broadcast      ),
`endif
`ifdef MAC7
    .i_vlan_id7                 (i_vlan_id7                 ),
    .i_dmac7_hash_key           (i_dmac7_hash_key           ),
    .i_dmac7                    (i_dmac7                    ),
    .i_dmac7_vld                (i_dmac7_vld                ),
    .i_smac7_hash_key           (i_smac7_hash_key           ),
    .i_smac7                    (i_smac7                    ),
    .i_smac7_vld                (i_smac7_vld                ),
    .o_tx_7_port                (w_tx_7_port                ), 
    .o_tx_7_port_vld            (w_tx_7_port_vld            ), 
    .o_tx_7_port_broadcast      (w_tx_7_port_broadcast      ),
`endif
    // 仲裁输出
    .o_dmac_port                (w_dmac_port                ),
    .o_vlan_id                  (w_vlan_id                  ),
    .o_dmac_hash_key            (w_dmac_hash_key            ),
    .o_dmac                     (w_dmac                     ),
    .o_dmac_vld                 (w_dmac_vld                 ),
    .o_smac_hash_key            (w_smac_hash_key            ),
    .o_smac                     (w_smac                     ),
    .o_smac_vld                 (w_smac_vld                 ),
    // 查表结果输入
    .i_tx_port                  (w_tx_port                  ),
    .i_tx_port_vld              (w_tx_port_vld              ),
    .i_tx_port_broadcast        (w_tx_port_broadcast        )
);

// 从仲裁模块输入，通过查找引擎分发到三个查表模块，三个查表模块返回查表结果，经过仲裁得到最终的查表结果并返回给上一级
look_up_mng #(
    .HASH_DATA_WIDTH            (HASH_DATA_WIDTH              ),
    .PORT_NUM                   (PORT_NUM                     ),
    .ADDR_WIDTH                 (ADDR_WIDTH                   ),
    .LOCAL_MAC                  (48'h000000000000             )
) look_up_mng_inst (    
    .i_clk                      (i_clk                        ),
    .i_rst                      (i_rst                        ),
    /*------------------------------- KEY仲裁结果输入 --------------------*/
    .i_vlan_id                  (w_vlan_id                    ), 
    .i_dmac_port                (w_dmac_port                  ),
    .i_dmac_hash_key            (w_dmac_hash_key              ),
    .i_dmac                     (w_dmac                       ),
    .i_dmac_vld                 (w_dmac_vld                   ),
    .i_smac_hash_key            (w_smac_hash_key              ),
    .i_smac                     (w_smac                       ),
    .i_smac_vld                 (w_smac_vld                   ),
    
    .o_tx_port                  (w_tx_port                    ), 
    .o_tx_port_vld              (w_tx_port_vld                ), 
    .o_tx_port_broadcast        (w_tx_port_broadcast          ),
    /*----------------------------- SMAC 表读写接口 ------------------------*/         
    .o_dmac                     (w_lookup_dmac_out            ), 
    .o_vlan_id                  (w_lookup_vlan_id             ),
    .o_dmac_vld                 (w_lookup_dmac_vld_out        ), 
    /*----------------------------- DMAC 表读写接口 ------------------------*/
    .o_dmac_item_vlan_id        (w_dmac_item_vlan_id          ),
    .o_dmac_item_dmac_addr      (w_dmac_item_dmac_addr        ), 
    .o_dmac_item_dmac_addr_vld  (w_dmac_item_dmac_addr_vld    ), 
    .o_dmac_item_dmac           (w_dmac_item_dmac_in          ), 
    .o_dmac_item_smac_addr      (w_dmac_item_smac_addr        ), 
    .o_dmac_item_smac_addr_vld  (w_dmac_item_smac_addr_vld    ), 
    .o_dmac_item_smac           (w_dmac_item_smac_in          ), 
    .o_dmac_item_mac_rx_port    (w_dmac_item_mac_rx_port      ), 
    /*----------------------------- 哈希冲突表读写接口 -----------------------*/
    .o_clash_item_vlan_id       (w_clash_item_vlan_id         ),
    .o_clash_item_dmac_addr     (w_clash_item_dmac_addr       ), 
    .o_clash_item_dmac_addr_vld (w_clash_item_dmac_addr_vld   ), 
    .o_clash_item_dmac          (w_clash_item_dmac_in         ), 
    .o_clash_item_smac_addr     (w_clash_item_smac_addr       ), 
    .o_clash_item_smac_addr_vld (w_clash_item_smac_addr_vld   ), 
    .o_clash_item_smac          (w_clash_item_smac_in         ), 
    .o_clash_item_mac_rx_port   (w_clash_item_mac_rx_port     ), 
    /*----------------------------- 查表的结果 ------------------------------*/
    .i_smac_tx_port_rslt        (w_smac_tx_port_rslt          ), 
    .i_smac_tx_port_vld         (w_smac_tx_port_vld           ), 

    .i_dmac_tx_port_rslt        (w_dmac_find_rslt             ), 
    .i_dmac_lookup_vld          (w_dmac_find_out_en           ), 
    .i_dmac_lookup_clash        (w_dmac_find_out_clash        ), 

    .i_clash_tx_port_rslt       (w_clash_tx_port_rslt         ), 
    .i_clash_tx_port_vld        (w_clash_tx_port_vld          )  
);

// 静态MAC表，存组播
smac_mng #(
    .DATA_WIDTH                 (VLAN_ID_WIDTH+MAC_ADDR_WIDTH ),
    .STATIC_RAM_SIZE            (STATIC_RAM_SIZE              ),
    .REG_ADDR_BUS_WIDTH         (REG_ADDR_BUS_WIDTH           ),
    .REG_DATA_BUS_WIDTH         (REG_DATA_BUS_WIDTH           )
) smac_mng_inst (    
    .i_sys_clk                  (i_clk                        ),
    .i_sys_rst                  (i_rst                        ),
    
    // reg port    
    .i_ram_reg_bus_we           (i_switch_reg_bus_we          ), 
    .i_ram_reg_bus_we_addr      (i_switch_reg_bus_we_addr     ),
    .i_ram_reg_bus_we_din       (i_switch_reg_bus_we_din      ),
    .i_ram_reg_bus_we_din_v     (i_switch_reg_bus_we_din_v    ),
    
    .i_ram_reg_bus_rd           (i_switch_reg_bus_rd          ),
    .i_ram_reg_bus_rd_addr      (i_switch_reg_bus_rd_addr     ),
    .o_ram_reg_bus_we_din       (o_switch_reg_bus_we_dout     ),
    .o_ram_reg_bus_we_din_v     (o_switch_reg_bus_we_dout_v   ),
    
    // input data port    
    .i_vlan_id                  (w_vlan_id                    ),
    .i_query_data               (w_lookup_dmac_out            ), 
    .i_query_valid              (w_lookup_dmac_vld_out        ),
    
    // output data port    
    .o_port_vector              (w_smac_tx_port_rslt          ),
    .o_port_vector_valid        (w_smac_tx_port_vld           )
);

// 动态MAC表查表，自行学习MAC表，支持老化功能
dmac_mng #(
    .PORT_NUM                   (PORT_NUM                   ),
    .HASH_DATA_WIDTH            (HASH_DATA_WIDTH            ),
    .REG_ADDR_BUS_WIDTH         (REG_ADDR_BUS_WIDTH         ),
    .REG_DATA_BUS_WIDTH         (REG_DATA_BUS_WIDTH         ), 
    .AGE_SCAN_INTERVAL          (AGE_SCAN_INTERVAL          ),
    .SIM_MODE                   (SIM_MODE                   )
) dmac_mng_inst (
    .i_clk                      (i_clk                      ),
    .i_rst                      (i_rst                      ),
    // reg write
    .i_reg_bus_we               (i_switch_reg_bus_we        ), 
    .i_reg_bus_addr             (i_switch_reg_bus_we_addr   ), 
    .i_reg_bus_data             (i_switch_reg_bus_we_din    ), 
    .i_reg_bus_data_vld         (i_switch_reg_bus_we_din_v  ),
    // reg read
    .i_reg_bus_re               (i_switch_reg_bus_rd        ), 
    .i_reg_bus_raddr            (i_switch_reg_bus_rd_addr   ), 
    .o_reg_bus_rdata            (o_switch_reg_bus_we_dout   ), 
    .o_reg_bus_rdata_vld        (o_switch_reg_bus_we_dout_v ),
    // DMAC/SMAC lookup
    .i_vlan_id                  (w_dmac_item_vlan_id        ), 
    .i_dmac                     (w_dmac_item_dmac_addr      ),   
    .i_dmac_hash_addr           (w_dmac_item_dmac_addr_vld  ),   
    .i_dmac_hash_vld            (w_dmac_item_dmac_in        ),   
    .i_smac                     (w_dmac_item_smac_addr      ),   
    .i_smac_hash_addr           (w_dmac_item_smac_addr_vld  ),   
    .i_smac_hash_vld            (w_dmac_item_smac_in        ),   
    .i_rx_port                  (w_dmac_item_mac_rx_port    ),   
    // lookup output
    .o_dmac_lookup_vld          (w_dmac_find_out_en         ),              
    .o_dmac_tx_port             (w_dmac_find_rslt           ),            
    .o_dmac_lookup_hit          (                           ),         
    .o_lookup_clash             (w_dmac_find_out_clash      ), 
    .o_table_full               (                           )
);
// HASH冲突表 如果动态MAC表出现冲突，则以冲突表的查表结果为准 
clash_mac_mng #(
    .DATA_WIDTH                 (VLAN_ID_WIDTH+MAC_ADDR_WIDTH ),
    .STATIC_RAM_SIZE            (STATIC_RAM_SIZE              ),
    .REG_ADDR_BUS_WIDTH         (REG_ADDR_BUS_WIDTH           ),
    .REG_DATA_BUS_WIDTH         (REG_DATA_BUS_WIDTH           )
) clash_mac_mng_inst (
    .i_sys_clk                  (i_clk                        ),
    .i_sys_rst                  (i_rst                        ),

    // reg port
    .i_ram_reg_bus_we           (i_switch_reg_bus_we          ), 
    .i_ram_reg_bus_we_addr      (i_switch_reg_bus_we_addr     ),
    .i_ram_reg_bus_we_din       (i_switch_reg_bus_we_din      ),
    .i_ram_reg_bus_we_din_v     (i_switch_reg_bus_we_din_v    ),

    .i_ram_reg_bus_rd           (i_switch_reg_bus_rd          ),
    .i_ram_reg_bus_rd_addr      (i_switch_reg_bus_rd_addr     ),
    .o_ram_reg_bus_we_din       (o_switch_reg_bus_we_dout     ),
    .o_ram_reg_bus_we_din_v     (o_switch_reg_bus_we_dout_v   ),

    // input data port
    .i_query_data               (w_clash_item_dmac_in          ), 
    .i_query_valid              (w_clash_item_dmac_addr_vld    ),

    // output data port
    .o_port_vector              (w_clash_tx_port_rslt          ),
    .o_port_vector_valid        (w_clash_tx_port_vld           )
);
endmodule
