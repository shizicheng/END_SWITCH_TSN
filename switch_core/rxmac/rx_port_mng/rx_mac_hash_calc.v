module rx_mac_hash_calc#(
    parameter           CWIDTH              =           12
)(
    input               wire                                    i_clk                   ,   // 250MHz
    input               wire                                    i_rst                   ,
    /*---------------------------------------- 寄存器配置接口 -------------------------------------------*/
    input               wire        [15:0]                      i_hash_poly_regs        ,
    input               wire        [15:0]                      i_hash_init_val_regs    ,
    input               wire                                    i_hash_regs_vld         ,
    /*--------------------------------- 信息提取模块输入的 MAC 信息 -------------------------------------*/
    input               wire   [7:0]                            i_dmac_data                        , // 目的 MAC 地址的值
    input               wire                                    i_damac_data_vld                   , // 数据有效值
    input               wire                                    i_dmac_soc                         ,
    input               wire                                    i_dmac_eoc                         ,
    input               wire   [7:0]                            i_smac_data                        , // 源 MAC 地址的值
    input               wire                                    i_samac_data_vld                   , // 数据有效值
    input               wire                                    i_smac_soc                         ,
    input               wire                                    i_smac_eoc                         ,    
    /*--------------------------------- 输出 hash 的计算结果 -------------------------------------*/     
    output              wire   [CWIDTH - 1 : 0]                 o_dmac_hash_key                    ,
    output              wire   [47 : 0]                         o_dmac                             ,
    output              wire                                    o_dmac_vld                         , 
    output              wire   [CWIDTH - 1 : 0]                 o_smac_hash_key                    ,
    output              wire   [47 : 0]                         o_smac                             ,
    output              wire                                    o_smac_vld                          
);



endmodule