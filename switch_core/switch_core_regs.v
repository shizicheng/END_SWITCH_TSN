module switch_core_regs#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16         // 接收 MAC 层的配置寄存器数据位宽
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- 寄存器配置接口与接口平台交互 -------------------------------------------*/
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
    output              wire                                    o_switch_reg_bus_rd_dout_v          , // 读数据有效使能
    /*----------------------------------- 通用接口（刷新整个平台的寄存器） -------------------------------------------*/
    output              wire                                    o_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    output              wire                                    o_switch_err_cnt_clr                , // 刷新错误计数器
    output              wire                                    o_switch_err_cnt_stat               , // 刷新错误状态寄存器
    /*----------------------------------- RXMAC寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_rxmac_reg_bus_we                  , // 寄存器写使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_rxmac_reg_bus_we_addr             , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_rxmac_reg_bus_we_din              , // 寄存器写数据
    output              wire                                    o_rxmac_reg_bus_we_din_v            , // 寄存器写数据使能
    // 寄存器读控制接口 
    output              wire                                    o_rxmac_reg_bus_rd                  , // 寄存器读使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_rxmac_reg_bus_rd_addr             , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_rxmac_reg_bus_rd_dout             , // 读出寄存器数据
    input               wire                                    i_rxmac_reg_bus_rd_dout_v           , // 读数据有效使能
    /*----------------------------------- TXMAC寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_txmac_reg_bus_we                  , // 寄存器写使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_txmac_reg_bus_we_addr             , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_txmac_reg_bus_rd_din              , // 寄存器写数据
    output              wire                                    o_txmac_reg_bus_rd_din_v            , // 寄存器写数据使能
    // 寄存器读控制接口 
    output              wire                                    o_txmac_reg_bus_rd                  , // 寄存器读使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_txmac_reg_bus_rd_addr             , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_txmac_reg_bus_rd_dout             , // 读出寄存器数据
    input               wire                                    i_txmac_reg_bus_rd_dout_v           , // 读数据有效使能
    /*----------------------------------- Swlist寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_swlist_reg_bus_we                 , // 寄存器写使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_swlist_reg_bus_we_addr            , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_swlist_reg_bus_we_din             , // 寄存器写数据
    output              wire                                    o_swlist_reg_bus_we_din_v           , // 寄存器写数据使能
    // 寄存器读控制接口
    output              wire                                    o_swlist_reg_bus_rd                 , // 寄存器读使能
    output              wire   [REG_ADDR_BUS_WIDTH-1:0]         o_swlist_reg_bus_rd_addr            , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_swlist_reg_bus_rd_dout            , // 读出寄存器数据
    input               wire                                    i_swlist_reg_bus_rd_dout_v           // 读数据有效使能
);



endmodule