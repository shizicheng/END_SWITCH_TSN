`include "synth_cmd_define.vh"

module switch_core_regs#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      16      ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_ADDR_WIDTH          =      10      ,  // 接收 MAC 层的配置寄存器地址位宽    
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
    output              wire   [REG_ADDR_WIDTH-1:0]             o_rxmac_reg_bus_we_addr             , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_rxmac_reg_bus_we_din              , // 寄存器写数据
    output              wire                                    o_rxmac_reg_bus_we_din_v            , // 寄存器写数据使能
    // 寄存器读控制接口 
    output              wire                                    o_rxmac_reg_bus_rd                  , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_rxmac_reg_bus_rd_addr             , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_rxmac_reg_bus_rd_dout             , // 读出寄存器数据
    input               wire                                    i_rxmac_reg_bus_rd_dout_v           , // 读数据有效使能
    /*----------------------------------- TXMAC寄存器接口 -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_txmac_reg_bus_we                  , // 寄存器写使能
    output              wire   [REG_ADDR_WIDTH-1:0]         	o_txmac_reg_bus_we_addr             , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_txmac_reg_bus_we_din              , // 寄存器写数据
    output              wire                                    o_txmac_reg_bus_we_din_v            , // 寄存器写数据使能
    // 寄存器读控制接口 
    output              wire                                    o_txmac_reg_bus_rd                  , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]         	o_txmac_reg_bus_rd_addr             , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_txmac_reg_bus_rd_dout             , // 读出寄存器数据
    input               wire                                    i_txmac_reg_bus_rd_dout_v           , // 读数据有效使能
    /*----------------------------------- Swlist寄存器接口 -------------------------------------------*/
    `ifdef END_POINTER_SWITCH_CORE 
    // 寄存器写控制接口     
        output              wire                                    o_swlist_reg_bus_we                 , // 寄存器写使能
        output              wire   [REG_ADDR_WIDTH-1:0]             o_swlist_reg_bus_we_addr            , // 寄存器写地址
        output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_swlist_reg_bus_we_din             , // 寄存器写数据
        output              wire                                    o_swlist_reg_bus_we_din_v           , // 寄存器写数据使能
        // 寄存器读控制接口
        output              wire                                    o_swlist_reg_bus_rd                 , // 寄存器读使能
        output              wire   [REG_ADDR_WIDTH-1:0]             o_swlist_reg_bus_rd_addr            , // 寄存器读地址
        input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_swlist_reg_bus_rd_dout            , // 读出寄存器数据
        input               wire                                    i_swlist_reg_bus_rd_dout_v          , // 读数据有效使能
    `endif
    /*-----------------------------------   CB寄存器接口  -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_cb_reg_bus_we                     , // 寄存器写使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_cb_reg_bus_we_addr                , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_cb_reg_bus_we_din                 , // 寄存器写数据
    output              wire                                    o_cb_reg_bus_we_din_v               , // 寄存器写数据使能
    // 寄存器读控制接口                                                                                
    output              wire                                    o_cb_reg_bus_rd                     , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_cb_reg_bus_rd_addr                , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_cb_reg_bus_rd_dout                , // 读出寄存器数据
    input               wire                                    i_cb_reg_bus_rd_dout_v              , // 读数据有效使能
	/*-----------------------------------   AS寄存器接口  -------------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_as_reg_bus_we                     , // 寄存器写使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_as_reg_bus_we_addr                , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_as_reg_bus_we_din                 , // 寄存器写数据
    output              wire                                    o_as_reg_bus_we_din_v               , // 寄存器写数据使能
    // 寄存器读控制接口                                                                              
    output              wire                                    o_as_reg_bus_rd                     , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_as_reg_bus_rd_addr                , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_as_reg_bus_rd_dout                , // 读出寄存器数据
    input               wire                                    i_as_reg_bus_rd_dout_v              , // 读数据有效使能
	/*--------------------------   EtherNet Interface寄存器接口  ------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_eth_reg_bus_we                     , // 寄存器写使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_eth_reg_bus_we_addr                , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_eth_reg_bus_we_din                 , // 寄存器写数据
    output              wire                                    o_eth_reg_bus_we_din_v               , // 寄存器写数据使能
    // 寄存器读控制接口                                                                              
    output              wire                                    o_eth_reg_bus_rd                     , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_eth_reg_bus_rd_addr                , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_eth_reg_bus_rd_dout                , // 读出寄存器数据
    input               wire                                    i_eth_reg_bus_rd_dout_v              , // 读数据有效使能
    /*--------------------------   MCU Interface寄存器接口  ------------------------------------*/
    // 寄存器写控制接口     
    output              wire                                    o_mcu_reg_bus_we                     , // 寄存器写使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_mcu_reg_bus_we_addr                , // 寄存器写地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_mcu_reg_bus_we_din                 , // 寄存器写数据
    output              wire                                    o_mcu_reg_bus_we_din_v               , // 寄存器写数据使能
    // 寄存器读控制接口                                                                              
    output              wire                                    o_mcu_reg_bus_rd                     , // 寄存器读使能
    output              wire   [REG_ADDR_WIDTH-1:0]             o_mcu_reg_bus_rd_addr                , // 寄存器读地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_mcu_reg_bus_rd_dout                , // 读出寄存器数据
    input               wire                                    i_mcu_reg_bus_rd_dout_v                // 读数据有效使能
);


    /*---------------------------------------- 寄存器地址定义 ------------------------------------------*/
    localparam AIO_ADDR_MSB         =		6'h00			;
    localparam MCU_IF_ADDR_MSB      =		6'h01			;
    localparam ETH_IF_ADDR_MSB      =		6'h02			;
    localparam SWILIST_ADDR_MSB     =		6'h05			;
    localparam RXMAC_ADDR_MSB       =		6'h06			;
    localparam TXMAC_ADDR_MSB       =		6'h08			;
    localparam CB_ADDR_MSB          =		6'h13			;
    localparam AS_ADDR_MSB          =		6'h0C			;

    /*---------------------------------------- 内部信号定义 -------------------------------------------*/
    reg                                    r_switch_reg_bus_we                 ;
    reg   [REG_ADDR_BUS_WIDTH-1:0]         r_switch_reg_bus_we_addr            ;
    reg                                    r_switch_reg_bus_we_din             ;
    reg   [REG_ADDR_BUS_WIDTH-1:0]         r_switch_reg_bus_we_din_v           ;
    reg                                    r_switch_reg_bus_rd                 ;
    reg   [REG_ADDR_BUS_WIDTH-1:0]         r_switch_reg_bus_rd_addr            ;
    reg                                    r_switch_reg_bus_rd_0               ;
    reg   [REG_ADDR_BUS_WIDTH-1:0]         r_switch_reg_bus_rd_addr_0          ;
    reg                                    r_switch_reg_bus_rd_1               ;
    reg   [REG_ADDR_BUS_WIDTH-1:0]         r_switch_reg_bus_rd_addr_1          ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_swlist_reg_bus_rd_dout            ;
    wire                                   w_swlist_reg_bus_rd_dout_v          ;
    /*--------------------------------------  AIO寄存器  ----------------------------------------------*/				
    localparam VERSION_0            =		16'h0000		;
    localparam VERSION_1            =		16'h0000		;
    localparam VERSION_2            =		16'h0000		;
    localparam VERSION_3            =		16'h0000		;

    reg   [REG_DATA_BUS_WIDTH-1:0]         r_aio_reg_bus_rd_dout               ;// AIO寄存器读数据
    reg   [REG_DATA_BUS_WIDTH-1:0]         r_aio_reg_bus_rd_dout_v             ;// AIO寄存器读数据有效位
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_sw_func_ind_0                ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_sw_func_ind_1                ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_sgmii_inf_ind                ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_pcie_inf_ind                 ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_llp_gen_ind_0                ;
    wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_llp_gen_ind_1                ;
    reg   [REG_DATA_BUS_WIDTH-1:0]         r_asic_test_register                ;
  //wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_err_state_0                  ;
  //wire  [REG_DATA_BUS_WIDTH-1:0]         w_asic_err_state_1                  ;    
  //reg   [REG_DATA_BUS_WIDTH-1:0]         r_asic_err_state_clr_0              ;   
  //reg   [REG_DATA_BUS_WIDTH-1:0]         r_asic_err_state_clr_1              ;  
  //reg   [REG_DATA_BUS_WIDTH-1:0]         r_asic_err_cnt_clr_0                ;  
  //reg   [REG_DATA_BUS_WIDTH-1:0]         r_asic_err_cnt_clr_1                ; 
    `ifdef END_POINTER_SWITCH_CORE 
        assign w_swlist_reg_bus_rd_dout = i_swlist_reg_bus_rd_dout;
        assign w_swlist_reg_bus_rd_dout_v = i_swlist_reg_bus_rd_dout_v;
    `else
        assign w_swlist_reg_bus_rd_dout = {REG_DATA_BUS_WIDTH{1'b0}};
        assign w_swlist_reg_bus_rd_dout_v = 1'b0;
    `endif

    /*------------------------------- 通用接口（刷新整个平台的寄存器） ---------------------------------*/
    assign o_refresh_list_pulse  = i_refresh_list_pulse;
    assign o_switch_err_cnt_clr  = i_switch_err_cnt_clr;
    assign o_switch_err_cnt_stat = i_switch_err_cnt_stat;

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst == 1'b1) begin
            r_switch_reg_bus_rd_addr    <=  {REG_ADDR_BUS_WIDTH{1'b0}};
            r_switch_reg_bus_rd         <=  1'b0;
            r_switch_reg_bus_rd_addr_0  <=  {REG_ADDR_BUS_WIDTH{1'b0}};
            r_switch_reg_bus_rd_0       <=  1'b0;
            r_switch_reg_bus_rd_addr_1  <=  {REG_ADDR_BUS_WIDTH{1'b0}};
            r_switch_reg_bus_rd_1       <=  1'b0;
        end else begin
            r_switch_reg_bus_rd_addr    <=  i_switch_reg_bus_rd_addr;
            r_switch_reg_bus_rd         <=  i_switch_reg_bus_rd;
            r_switch_reg_bus_rd_addr_0  <=  r_switch_reg_bus_rd_addr;
            r_switch_reg_bus_rd_0       <=  r_switch_reg_bus_rd;
            r_switch_reg_bus_rd_addr_1  <=  r_switch_reg_bus_rd_addr_0;
            r_switch_reg_bus_rd_1       <=  r_switch_reg_bus_rd_0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst == 1'b1) begin
            r_switch_reg_bus_we        <=  1'b0;
            r_switch_reg_bus_we_addr   <=  {REG_ADDR_BUS_WIDTH{1'b0}};
            r_switch_reg_bus_we_din    <=  {REG_DATA_BUS_WIDTH{1'b0}};
            r_switch_reg_bus_we_din_v  <=  1'b0;
        end else begin
            r_switch_reg_bus_we        <=  i_switch_reg_bus_we;
            r_switch_reg_bus_we_addr   <=  i_switch_reg_bus_we_addr;
            r_switch_reg_bus_we_din    <=  r_switch_reg_bus_we_din;
            r_switch_reg_bus_we_din_v  <=  r_switch_reg_bus_we_din_v;
        end
    end

    
    assign o_switch_reg_bus_rd_dout = r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && i_rxmac_reg_bus_rd_dout_v == 1'b1 ? i_rxmac_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && i_txmac_reg_bus_rd_dout_v == 1'b1 ? i_txmac_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && w_swlist_reg_bus_rd_dout_v == 1'b1 ? w_swlist_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && i_cb_reg_bus_rd_dout_v == 1'b1 ? i_cb_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && i_as_reg_bus_rd_dout_v == 1'b1 ? i_as_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && i_eth_reg_bus_rd_dout_v == 1'b1 ? i_eth_reg_bus_rd_dout :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == AIO_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 && r_aio_reg_bus_rd_dout_v == 1'b1 ?  r_aio_reg_bus_rd_dout : 
                                      {REG_DATA_BUS_WIDTH{1'b0}};

    assign o_switch_reg_bus_rd_dout_v=r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? i_rxmac_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? i_txmac_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? w_swlist_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? i_cb_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? i_as_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? i_eth_reg_bus_rd_dout_v :
                                      r_switch_reg_bus_rd_addr_1[REG_ADDR_BUS_WIDTH-1 -: 6] == AIO_ADDR_MSB && r_switch_reg_bus_rd_1 == 1'b1 ? r_aio_reg_bus_rd_dout_v : 
                                      1'b0;

      /*----------------------------------- RXMAC寄存器接口 -------------------------------------------*/
    assign o_rxmac_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_rxmac_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_rxmac_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_rxmac_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_rxmac_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == RXMAC_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_rxmac_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];

    /*----------------------------------- TXMAC寄存器接口 -------------------------------------------*/
    assign o_txmac_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_txmac_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_txmac_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_txmac_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_txmac_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == TXMAC_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_txmac_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];
 
    /*----------------------------------- Swlist寄存器接口 -------------------------------------------*/
    `ifdef END_POINTER_SWITCH_CORE 
        assign o_swlist_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
        assign o_swlist_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
        assign o_swlist_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
        assign o_swlist_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
        assign o_swlist_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == SWILIST_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
        assign o_swlist_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];
    `endif
    /*-----------------------------------   CB寄存器接口  -------------------------------------------*/
    assign o_cb_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_cb_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_cb_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_cb_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_cb_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == CB_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_cb_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];    

	/*-----------------------------------   AS寄存器接口  -------------------------------------------*/
    assign o_as_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_as_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_as_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_as_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_as_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == AS_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_as_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];    

	/*--------------------------   EtherNet Interface寄存器接口  ------------------------------------*/
    assign o_eth_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_eth_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_eth_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_eth_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_eth_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == ETH_IF_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_eth_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0]; 

    /*--------------------------   MCU Interface寄存器接口  ------------------------------------*/
    assign o_mcu_reg_bus_we = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == MCU_IF_ADDR_MSB ? i_switch_reg_bus_we : 1'b0;
    assign o_mcu_reg_bus_we_addr = i_switch_reg_bus_we_addr[REG_ADDR_WIDTH-1 : 0];
    assign o_mcu_reg_bus_we_din = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == MCU_IF_ADDR_MSB ? i_switch_reg_bus_we_din : {REG_DATA_BUS_WIDTH{1'b0}};
    assign o_mcu_reg_bus_we_din_v = i_switch_reg_bus_we_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == MCU_IF_ADDR_MSB ? i_switch_reg_bus_we_din_v : 1'b0;
    assign o_mcu_reg_bus_rd = i_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == MCU_IF_ADDR_MSB ? i_switch_reg_bus_rd : 1'b0;
    assign o_mcu_reg_bus_rd_addr = i_switch_reg_bus_rd_addr[REG_ADDR_WIDTH-1 : 0];   
   
    /*-----------------------------------  AIO寄存器接口  -------------------------------------------*/
    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst == 1'b1) begin
            r_aio_reg_bus_rd_dout_v     <=  1'b0;
        end else begin
            r_aio_reg_bus_rd_dout_v     <=  (r_switch_reg_bus_rd_addr[REG_ADDR_BUS_WIDTH-1 -: 6] == AIO_ADDR_MSB && r_switch_reg_bus_rd == 1'b1) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst == 1'b1) begin
            r_aio_reg_bus_rd_dout       <=  {REG_DATA_BUS_WIDTH{1'b0}};
        end else begin
            r_aio_reg_bus_rd_dout       <=  r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h00} && r_switch_reg_bus_rd == 1'b1 ? VERSION_0 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h01} && r_switch_reg_bus_rd == 1'b1 ? VERSION_1 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h02} && r_switch_reg_bus_rd == 1'b1 ? VERSION_2 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h03} && r_switch_reg_bus_rd == 1'b1 ? VERSION_3 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h04} && r_switch_reg_bus_rd == 1'b1 ? w_asic_sw_func_ind_0 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h05} && r_switch_reg_bus_rd == 1'b1 ? w_asic_sw_func_ind_1 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h06} && r_switch_reg_bus_rd == 1'b1 ? w_asic_sgmii_inf_ind :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h07} && r_switch_reg_bus_rd == 1'b1 ? w_asic_pcie_inf_ind :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h08} && r_switch_reg_bus_rd == 1'b1 ? w_asic_llp_gen_ind_0 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h09} && r_switch_reg_bus_rd == 1'b1 ? w_asic_llp_gen_ind_1 :
                                            r_switch_reg_bus_rd_addr == {AIO_ADDR_MSB,10'h10} && r_switch_reg_bus_rd == 1'b1 ? r_asic_test_register : r_aio_reg_bus_rd_dout;
        end
    end

    /*--------------------------------------  AIO寄存器  ----------------------------------------------*/
    assign w_asic_sw_func_ind_0 = 16'h0000;
    assign w_asic_sw_func_ind_1 = 16'h0000;
    assign w_asic_sgmii_inf_ind = 16'h0000;
    assign w_asic_pcie_inf_ind  = 16'h0000;
    assign w_asic_llp_gen_ind_0 = 16'h0000;
    assign w_asic_llp_gen_ind_1 = 16'h0000;

    always @(posedge i_clk or posedge i_rst) begin
        if(i_rst == 1'b1) begin
            r_asic_test_register    <=  {REG_DATA_BUS_WIDTH{1'b0}};
        end else begin
            r_asic_test_register    <=  r_switch_reg_bus_we == 1'b1 && r_switch_reg_bus_we_addr == {AIO_ADDR_MSB,10'h10} && r_switch_reg_bus_we_din_v == 1'b1 ?  r_switch_reg_bus_we_din : r_asic_test_register;   
        end
    end

endmodule