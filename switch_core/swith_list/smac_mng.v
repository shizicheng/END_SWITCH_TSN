// 静态 MAC 地址表项采用分布式寄存器并行查表方式
module smac_mng #(
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
        /*----------------------------- 查找 DMAC 输入 ------------------------------*/
        input               wire        [47:0]                      i_mac_in                    ,   
        input               wire                                    i_mac_in_vld                ,   
        output              wire                                    o_match_rdy                 , 
        /*----------------------------- 表项的状态 ------------------------------*/
        output              wire        [15:0]                      smac_list_num               ,
        output              wire                                    smac_list_full              ,
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        input               wire   [PORT_NUM  : 0]                  o_smac_tx_port_rslt         , // 最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        input               wire                                    o_smac_tx_port_vld          
);


endmodule