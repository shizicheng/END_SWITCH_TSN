module rx_frm_acl_mng #(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                             ,   // 250MHz
    input               wire                                    i_rst                             ,
    /*---------------------------------------- 单 PORT 聚合数据流 -------------------------------------------*/
    input              wire                                    i_mac_port_link                    , // 端口的连接状态
    input              wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    input              wire   [CROSS_DATA_WIDTH:0]             i_mac_port_axi_data                , // 端口数据流，最高位表示crcerr
    input              wire   [(CROSS_DATA_WIDTH/8)-1:0]       i_mac_axi_data_keep                , // 端口数据流掩码，有效字节指示
    input              wire                                    i_mac_axi_data_valid               , // 端口数据有效
    output             wire                                    o_mac_axi_data_ready               , // 交叉总线聚合架构反压流水线信号
    input              wire                                    i_mac_axi_data_last                , // 数据流结束标识
    /*---------------------------------------- ACL 寄存器 -------------------------------------------*/
    input              wire   [PORT_NUM-1:0]                   i_acl_port_sel                     , // 选择要配置的端口
    input              wire                                    i_acl_clr_list_regs                , // 清空寄存器列表
    output             wire                                    o_acl_list_rdy_regs                , // 配置寄存器操作空闲
    input              wire   [4:0]                            i_acl_item_sel_regs                , // 配置条目选择
    input              wire   [5:0]                            i_acl_item_waddr_regs              , // 每个条目最大支持比对 64 字节
    input              wire   [7:0]                            i_acl_item_din_regs                , // 需要比较的字节数据
    input              wire                                    i_acl_item_we_regs                 , // 配置使能信号
    input              wire   [15:0]                           i_acl_item_rslt_regs               , // 匹配的结果值 - [7:0] 输出帧类型, [15:8] ACL转发指定端口
    input              wire                                    i_acl_item_complete_regs           , // 端口 ACL 参数配置完成使能信号      
    /*---------------------------------------- ACL 匹配后输出的字段 -------------------------------------------*/ 
    output             wire                                    o_acl_vld                          , // acl匹配表的有效输出信号
    output             wire                                    o_acl_find_match                   , // 是否匹配到正确的条目
    output             wire   [7:0]                            o_acl_frmtype                      , // 匹配出来的帧类型
    output             wire   [15:0]                           o_acl_fetch_info                     // 待定保留

);


endmodule