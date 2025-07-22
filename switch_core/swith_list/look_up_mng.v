module look_up_mng #(
        parameter                           HASH_DATA_WIDTH         =      12                   ,   // 哈希计算的值的位宽
        parameter                           PORT_NUM                =      4                    ,   // 交换机的端口数
        parameter                           ADDR_WIDTH              =      6                        // 地址表的深度
)(  
        input               wire                                    i_clk                       ,
        input               wire                                    i_rst                       ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
        input               wire                                    i_cfg_smac_list_clr         ,   // 静态MAC配置-清空列表
        input               wire                                    i_cfg_smac_list_we          ,   // 静态MAC配置-写使能
        input               wire        [47:0]                      i_cfg_smac_list_din_0       ,   // 静态MAC配置条目-MAC地址字段
        input               wire        [7:0]                       i_cfg_smac_list_din_1       ,   // 静态MAC配置条目-发送指定端口字段
        input               wire        [7:0]                       i_cfg_smac_list_din_2       ,   // 静态MAC配置条目-有效使能及掩码配置字段(掩码必须连续有效)
        /*----------------------------- KEY仲裁结果输入 ------------------------------*/
        input               wire   [PORT_NUM - 1:0]                 i_dmac_port                 ,   // 输入查表引擎的端口
        input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac_hash_key             ,   // 目的 mac 的哈希值
        input               wire   [47 : 0]                         i_dmac                      ,   // 目的 mac 的值
        input               wire                                    i_dmac_vld                  ,   // dmac_vld
        input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac_hash_key             ,   // 源 mac 的值有效标识
        input               wire   [47 : 0]                         i_smac                      ,   // 源 mac 的值
        input               wire                                    i_smac_vld                  ,   // smac_vld

        output              wire   [PORT_NUM - 1:0]                 o_tx_port                   ,
        output              wire                                    o_tx_port_vld               ,
        /*----------------------------- DMAC 表读写接口 ------------------------------*/
        input               wire                                    i_dmac_old_en               ,   // DMAC 老化时间使能
        input               wire   [HASH_DATA_WIDTH-1:0]            i_dmac_old_num              ,   // DMAC 老化的表项
        output              wire   [HASH_DATA_WIDTH-1:0]            o_dmac_item_mac_addr        ,   // DMAC 地址表项
        output              wire                                    o_dmac_item_mac_addr_vld    ,   // DMAC 地址表项有效位
        output              wire                                    o_dmac_item_mac_we          ,   // DMAC 地址表读写信号
        output              wire   [47:0]                           o_dmac_item_mac_in          ,   // MAC输入
        output              wire   [PORT_NUM - 1:0]                 o_dmac_item_mac_rx_port     ,   // DMAC 输入端口
        /*----------------------------- 哈希冲突表读写接口 ------------------------------*/
        output              wire                                    o_clash_clr                 ,   // 哈希冲突表清空
        input               wire                                    i_clash_rdy                 ,   
        input               wire                                    i_clash_old_en              ,   // DMAC 老化时间使能
        input               wire   [HASH_DATA_WIDTH-1:0]            i_clash_old_num             ,   // DMAC 老化的表项
        output              wire   [HASH_DATA_WIDTH-1:0]            o_clash_item_mac_addr       ,   // DMAC 地址表项
        output              wire                                    o_clash_item_mac_addr_vld   ,   // DMAC 地址表项有效位
        output              wire                                    o_clash_item_mac_we         ,   // DMAC 地址表读写信号
        output              wire   [47:0]                           o_clash_item_mac_in         ,   // MAC输入
        output              wire   [PORT_NUM - 1:0]                 o_clash_item_mac_rx_port    ,   // DMAC 输入端口
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        input               wire   [PORT_NUM  : 0]                  i_smac_tx_port_rslt         , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        input               wire                                    i_smac_tx_port_vld          ,
        // dmac
        input               wire   [PORT_NUM  : 0]                  i_dmac_tx_port_rslt         , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        input               wire                                    i_dmac_tx_port_vld          ,
        input               wire                                    i_clash_out                 , // 表明在 DMAC 中，没有查找到合适的表项，转到哈希冲突表查找
        // clash
        input               wire   [PORT_NUM  : 0]                  i_clash_tx_port_rslt        , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        input               wire                                    i_clash_tx_port_vld         
);


endmodule