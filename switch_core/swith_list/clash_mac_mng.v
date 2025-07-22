module clash_mac_mng #(
        parameter                           PORT_NUM                =      4                  ,   // 交换机的端口数
        parameter                           HASH_DATA_WIDTH         =      12                 ,   // 哈希计算的值的位宽
        parameter                           ADDR_WIDTH              =      6                        // 地址表的深度
)(  
        input               wire                                        i_clk                 ,
        input               wire                                        i_rst                 ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
        input               wire                                        i_cfg_smac_list_clr   , // 用于一键清空静态MAC列表
        output              wire                                        o_match_rdy           ,
        /*----------------------------- 老化表项接口 ------------------------------*/
        input               wire        [7:0]                           i_cfg_live_time       ,
        output              wire        [HASH_DATA_WIDTH-1:0]           o_old_num             ,
        output              wire                                        o_old_en              ,
        /*----------------------------- DMAC 读写接口 ------------------------------*/
        input               wire        [HASH_DATA_WIDTH-1:0]           i_item_mac_addr       ,
        input               wire                                        i_item_mac_addr_vld   ,
        input               wire                                        i_item_mac_we         ,
        input               wire        [47:0]                          i_item_mac_in         ,
        input               wire        [PORT_NUM:0]                    i_rx_port_in          ,
        /*----------------------------- 查表输出接口接口 ------------------------------*/     
        output              wire                                        o_clash_tx_port_rslt  ,
        output              wire        [PORT_NUM:0]                    o_clash_tx_port_vld          
);




endmodule