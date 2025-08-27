// 静态 MAC 地址表项采用分布式寄存器并行查表方式
module smac_mng #(
        parameter                           PORT_NUM                =      4                    ,   // 交换机的端口数
        parameter                           ADDR_WIDTH              =      6                        // 地址表的深度
)(  
        input               wire                                    i_clk                       ,
        input               wire                                    i_rst                       ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
      
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