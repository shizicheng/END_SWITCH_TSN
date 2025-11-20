`include "synth_cmd_define.vh"

module cross_data_cache #(
    parameter       PORT_MNG_DATA_WIDTH     =      8        ,
    parameter       PORT_FIFO_PRI_NUM       =      8        ,
    parameter       METADATA_WIDTH          =      12       ,
    parameter       CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    // sys interface
    input           wire                                   i_clk                    ,
    input           wire                                   i_rst                    ,
    // 寄存器配置信息              
//  input           wire                                   i_forward_mode           , // 0-存储转发；1-直通转发 
    // data stream pri interface        
    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data0                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data0_keep             , 
    input           wire    [15:0]                         i_data0_user             ,
    input           wire                                   i_data0_vld              ,
    input           wire                                   i_data0_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data0_pri         , 
    input           wire                                   i_meta_data0_pri_vld     , 
    
    output          wire                                   o_data0_ready            ,
    output          wire                                   o_data0_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data1                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data1_keep             , 
    input           wire    [15:0]                         i_data1_user             ,
    input           wire                                   i_data1_vld              ,
    input           wire                                   i_data1_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data1_pri         , 
    input           wire                                   i_meta_data1_pri_vld     , 
    
    output          wire                                   o_data1_ready            ,
    output          wire                                   o_data1_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data2                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data2_keep             , 
    input           wire    [15:0]                         i_data2_user             ,
    input           wire                                   i_data2_vld              ,
    input           wire                                   i_data2_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data2_pri         , 
    input           wire                                   i_meta_data2_pri_vld     , 
    
    output          wire                                   o_data2_ready            ,
    output          wire                                   o_data2_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data3                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data3_keep             , 
    input           wire    [15:0]                         i_data3_user             ,
    input           wire                                   i_data3_vld              ,
    input           wire                                   i_data3_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data3_pri         , 
    input           wire                                   i_meta_data3_pri_vld     , 
    
    output          wire                                   o_data3_ready            ,
    output          wire                                   o_data3_busy             ,


    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data4                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data4_keep             , 
    input           wire    [15:0]                         i_data4_user             ,
    input           wire                                   i_data4_vld              ,
    input           wire                                   i_data4_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data4_pri         , 
    input           wire                                   i_meta_data4_pri_vld     , 
    
    output          wire                                   o_data4_ready            ,
    output          wire                                   o_data4_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data5                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data5_keep             , 
    input           wire    [15:0]                         i_data5_user             ,
    input           wire                                   i_data5_vld              ,
    input           wire                                   i_data5_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data5_pri         , 
    input           wire                                   i_meta_data5_pri_vld     , 
    
    output          wire                                   o_data5_ready            ,
    output          wire                                   o_data5_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data6                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data6_keep             , 
    input           wire    [15:0]                         i_data6_user             ,
    input           wire                                   i_data6_vld              ,
    input           wire                                   i_data6_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data6_pri         , 
    input           wire                                   i_meta_data6_pri_vld     , 
    
    output          wire                                   o_data6_ready            ,
    output          wire                                   o_data6_busy             ,

    input           wire    [CROSS_DATA_WIDTH-1:0]         i_data7                  ,
    input           wire    [CROSS_DATA_WIDTH/8-1:0]       i_data7_keep             , 
    input           wire    [15:0]                         i_data7_user             ,
    input           wire                                   i_data7_vld              ,
    input           wire                                   i_data7_last             , 
    input           wire    [METADATA_WIDTH-1:0]           i_meta_data7_pri         , 
    input           wire                                   i_meta_data7_pri_vld     , 
    
    output          wire                                   o_data7_ready            ,
    output          wire                                   o_data7_busy             ,    
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    output          wire    [PORT_FIFO_PRI_NUM-1:0]        o_fifoc_empty            ,
    input           wire    [PORT_FIFO_PRI_NUM-1:0]        i_scheduing_rst          ,
    input           wire                                   i_scheduing_rst_vld      ,
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]       o_pmac_tx_axis_data      , 
    output          wire    [15:0]                         o_pmac_tx_axis_user      , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]     o_pmac_tx_axis_keep      , 
    output          wire                                   o_pmac_tx_axis_last      , 
    output          wire                                   o_pmac_tx_axis_valid     , 
    input           wire                                   i_pmac_tx_axis_ready     ,
    //emac通道数据                      
	input			wire	[15:0]						   i_emac_tx_axis_user		,
    output          wire    [CROSS_DATA_WIDTH - 1:0]       o_emac_tx_axis_data      , 
    output          wire    [15:0]                         o_emac_tx_axis_user      , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]     o_emac_tx_axis_keep      , 
    output          wire                                   o_emac_tx_axis_last      , 
    output          wire                                   o_emac_tx_axis_valid     , 
    input           wire                                   i_emac_tx_axis_ready      
);

/*------------------------------------ fifo0 ----------------------------------------*/
/*------------------------------------ fifo0 ----------------------------------------*/
/*------------------------------------ fifo0 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo0_full            ;
    wire                                   w_data_fifo0_empty           ;
    reg                                    r_data_fifo0_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo0_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo0_empty          ;
    wire   [15:0]                          w_info_fifo0_datalen        ;
    wire   [15:0]                          w_info_fifo0_keep           ;
    reg                                    r_info_fifo0_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo0_data_keep               ; // 128 / 8
    reg   [15:0]                           ri_info_fifo0_data_cnt                ; // 在交换机设置成直通转发模式时，需要交换平面自己维护数据长度，并拉高 last 信号    
    reg                                    r_info_fifo0_rd_pre         ;
    reg                                    r_info_fifo0_rd_pre2        ;
    reg                                    r_info_fifo0_rd_en          ;

    // fifoc
    reg                                    r_c_fifo0_qbu_flag       ;
    reg         [3:0]                      r_c_fifo0_qos            ; 
    reg        [15:0]                      w_c_fifo0_wr_data        ;
    reg                                    r_c_fifo0_vld            ;
    reg                                    r_c_fifo0_rd_en          ;
    wire        [15:0]                      w_c_fifo0_rd_data        ;
    wire                                   w_c_fifo0_full           ;
    wire                                   w_c_fifo0_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo0_cnt   ; // 统计向 tx_mac 发送的字节数，结合输入锁存的 ri_info_fifo0_data_cnt 拉高 last 信号
    reg                                    r_fifo0_ready        ; // 
    reg                                    r_fifo0_busy        ; // 标识该优先级 FIFO 是否可以写数据（是否处于写数据进程并且FIFO未满）
    reg                                    r_tx_mac_fifo0_vld   ;  //r_data_rd_en的打一拍
    reg                                    r_tx_mac_fifo0_last  ;
    reg         [15:0]                     r_tx_mac_fifo0_keep  ;
    reg                                    w_info_fifo0_avaliable_flag;
/*------------------------------------ fifo1 ----------------------------------------*/
/*------------------------------------ fifo1 ----------------------------------------*/
/*------------------------------------ fifo1 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo1_full            ;
    wire                                   w_data_fifo1_empty           ;
    reg                                    r_data_fifo1_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo1_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo1_empty          ;
    wire   [15:0]                          w_info_fifo1_datalen        ;
    wire   [15:0]                          w_info_fifo1_keep           ;
    reg                                    r_info_fifo1_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo1_data_keep               ;
    reg   [15:0]                           ri_info_fifo1_data_cnt                ;
    reg                                    r_info_fifo1_rd_pre         ;
    reg                                    r_info_fifo1_rd_pre2        ;
    reg                                    r_info_fifo1_rd_en          ;

    // fifoc
    reg                                    r_c_fifo1_qbu_flag       ;
    reg         [3:0]                      r_c_fifo1_qos            ; 
    reg        [15:0]                      w_c_fifo1_wr_data        ;
    reg                                    r_c_fifo1_vld            ;
    reg                                    r_c_fifo1_rd_en          ;
    wire        [15:0]                      w_c_fifo1_rd_data        ;
    wire                                   w_c_fifo1_full           ;
    wire                                   w_c_fifo1_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo1_cnt   ;
    reg                                    r_fifo1_ready        ;
    reg                                    r_fifo1_busy         ;
    reg                                    r_tx_mac_fifo1_vld   ;
    reg                                    r_tx_mac_fifo1_last  ;
    reg         [15:0]                     r_tx_mac_fifo1_keep  ;
    reg                                    w_info_fifo1_avaliable_flag;
/*------------------------------------ fifo2 ----------------------------------------*/
/*------------------------------------ fifo2 ----------------------------------------*/
/*------------------------------------ fifo2 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo2_full            ;
    wire                                   w_data_fifo2_empty           ;
    reg                                    r_data_fifo2_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo2_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo2_empty          ;
    wire   [15:0]                          w_info_fifo2_datalen        ;
    wire   [15:0]                          w_info_fifo2_keep           ;
    reg                                    r_info_fifo2_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo2_data_keep               ;
    reg   [15:0]                           ri_info_fifo2_data_cnt                ;
    reg                                    r_info_fifo2_rd_pre         ;
    reg                                    r_info_fifo2_rd_pre2        ;
    reg                                    r_info_fifo2_rd_en          ;

    // fifoc
    reg                                    r_c_fifo2_qbu_flag       ;
    reg         [3:0]                      r_c_fifo2_qos            ; 
    reg        [15:0]                      w_c_fifo2_wr_data        ;
    reg                                    r_c_fifo2_vld            ;
    reg                                    r_c_fifo2_rd_en          ;
    wire        [15:0]                      w_c_fifo2_rd_data        ;
    wire                                   w_c_fifo2_full           ;
    wire                                   w_c_fifo2_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo2_cnt   ;
    reg                                    r_fifo2_ready        ;
    reg                                    r_fifo2_busy         ;
    reg                                    r_tx_mac_fifo2_vld   ;
    reg                                    r_tx_mac_fifo2_last  ;
    reg         [15:0]                     r_tx_mac_fifo2_keep  ;
    reg                                    w_info_fifo2_avaliable_flag;
/*------------------------------------ fifo3 ----------------------------------------*/
/*------------------------------------ fifo3 ----------------------------------------*/
/*------------------------------------ fifo3 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo3_full            ;
    wire                                   w_data_fifo3_empty           ;
    reg                                    r_data_fifo3_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo3_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo3_empty          ;
    wire   [15:0]                          w_info_fifo3_datalen        ;
    wire   [15:0]                          w_info_fifo3_keep           ;
    reg                                    r_info_fifo3_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo3_data_keep               ;
    reg   [15:0]                           ri_info_fifo3_data_cnt                ;
    reg                                    r_info_fifo3_rd_pre         ;
    reg                                    r_info_fifo3_rd_pre2        ;
    reg                                    r_info_fifo3_rd_en          ;

    // fifoc
    reg                                    r_c_fifo3_qbu_flag       ;
    reg         [3:0]                      r_c_fifo3_qos            ; 
    reg        [15:0]                      w_c_fifo3_wr_data        ;
    reg                                    r_c_fifo3_vld            ;
    reg                                    r_c_fifo3_rd_en          ;
    wire        [15:0]                      w_c_fifo3_rd_data        ;
    wire                                   w_c_fifo3_full           ;
    wire                                   w_c_fifo3_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo3_cnt   ;
    reg                                    r_fifo3_ready        ;
    reg                                    r_fifo3_busy         ;
    reg                                    r_tx_mac_fifo3_vld   ;
    reg                                    r_tx_mac_fifo3_last  ;
    reg         [15:0]                     r_tx_mac_fifo3_keep  ;
    reg                                    w_info_fifo3_avaliable_flag;
/*------------------------------------ fifo4 ----------------------------------------*/
/*------------------------------------ fifo4 ----------------------------------------*/
/*------------------------------------ fifo4 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo4_full            ;
    wire                                   w_data_fifo4_empty           ;
    reg                                    r_data_fifo4_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo4_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo4_empty          ;
    wire   [15:0]                          w_info_fifo4_datalen        ;
    wire   [15:0]                          w_info_fifo4_keep           ;
    reg                                    r_info_fifo4_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo4_data_keep               ;
    reg   [15:0]                           ri_info_fifo4_data_cnt                ;
    reg                                    r_info_fifo4_rd_pre         ;
    reg                                    r_info_fifo4_rd_pre2        ;
    reg                                    r_info_fifo4_rd_en          ;

    // fifoc
    reg                                    r_c_fifo4_qbu_flag       ;
    reg         [3:0]                      r_c_fifo4_qos            ; 
    reg        [15:0]                      w_c_fifo4_wr_data        ;
    reg                                    r_c_fifo4_vld            ;
    reg                                    r_c_fifo4_rd_en          ;
    wire        [15:0]                      w_c_fifo4_rd_data        ;
    wire                                   w_c_fifo4_full           ;
    wire                                   w_c_fifo4_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo4_cnt   ;
    reg                                    r_fifo4_ready        ;
    reg                                    r_fifo4_busy         ;
    reg                                    r_tx_mac_fifo4_vld   ;
    reg                                    r_tx_mac_fifo4_last  ;
    reg         [15:0]                     r_tx_mac_fifo4_keep  ;
    reg                                    w_info_fifo4_avaliable_flag;
/*------------------------------------ fifo5 ----------------------------------------*/
/*------------------------------------ fifo5 ----------------------------------------*/
/*------------------------------------ fifo5 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo5_full            ;
    wire                                   w_data_fifo5_empty           ;
    reg                                    r_data_fifo5_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo5_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo5_empty          ;
    wire   [15:0]                          w_info_fifo5_datalen        ;
    wire   [15:0]                          w_info_fifo5_keep           ;
    reg                                    r_info_fifo5_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo5_data_keep               ;
    reg   [15:0]                           ri_info_fifo5_data_cnt                ;
    reg                                    r_info_fifo5_rd_pre         ;
    reg                                    r_info_fifo5_rd_pre2        ;
    reg                                    r_info_fifo5_rd_en          ;

    // fifoc
    reg                                    r_c_fifo5_qbu_flag       ;
    reg         [3:0]                      r_c_fifo5_qos            ; 
    reg        [15:0]                      w_c_fifo5_wr_data        ;
    reg                                    r_c_fifo5_vld            ;
    reg                                    r_c_fifo5_rd_en          ;
    wire        [15:0]                      w_c_fifo5_rd_data        ;
    wire                                   w_c_fifo5_full           ;
    wire                                   w_c_fifo5_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo5_cnt   ;
    reg                                    r_fifo5_ready        ;
    reg                                    r_fifo5_busy         ;
    reg                                    r_tx_mac_fifo5_vld   ;
    reg                                    r_tx_mac_fifo5_last  ;
    reg         [15:0]                     r_tx_mac_fifo5_keep  ;
    reg                                    w_info_fifo5_avaliable_flag;
/*------------------------------------ fifo6 ----------------------------------------*/
/*------------------------------------ fifo6 ----------------------------------------*/
/*------------------------------------ fifo6 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo6_full            ;
    wire                                   w_data_fifo6_empty           ;
    reg                                    r_data_fifo6_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo6_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo6_empty          ;
    wire   [15:0]                          w_info_fifo6_datalen        ;
    wire   [15:0]                          w_info_fifo6_keep           ;
    reg                                    r_info_fifo6_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo6_data_keep               ;
    reg   [15:0]                           ri_info_fifo6_data_cnt                ;
    reg                                    r_info_fifo6_rd_pre         ;
    reg                                    r_info_fifo6_rd_pre2        ;
    reg                                    r_info_fifo6_rd_en          ;

    // fifoc
    reg                                    r_c_fifo6_qbu_flag       ;
    reg         [3:0]                      r_c_fifo6_qos            ; 
    reg        [15:0]                      w_c_fifo6_wr_data        ;
    reg                                    r_c_fifo6_vld            ;
    reg                                    r_c_fifo6_rd_en          ;
    wire        [15:0]                      w_c_fifo6_rd_data        ;
    wire                                   w_c_fifo6_full           ;
    wire                                   w_c_fifo6_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo6_cnt   ;
    reg                                    r_fifo6_ready        ;
    reg                                    r_fifo6_busy         ;
    reg                                    r_tx_mac_fifo6_vld   ;
    reg                                    r_tx_mac_fifo6_last  ;
    reg         [15:0]                     r_tx_mac_fifo6_keep  ;
    reg                                    w_info_fifo6_avaliable_flag;
/*------------------------------------ fifo7 ----------------------------------------*/
/*------------------------------------ fifo7 ----------------------------------------*/
/*------------------------------------ fifo7 ----------------------------------------*/
    //fifo_data
    wire                                   w_data_fifo7_full            ;
    wire                                   w_data_fifo7_empty           ;
    reg                                    r_data_fifo7_rd_en               ;    
    wire   [CROSS_DATA_WIDTH-1:0]          w_data_fifo7_rd_data             ;
        
    // fifo_info       
    wire                                   w_info_fifo7_empty          ;
    wire   [15:0]                          w_info_fifo7_datalen        ;
    wire   [15:0]                          w_info_fifo7_keep           ;
    reg                                    r_info_fifo7_data_vld       ;
    reg   [CROSS_DATA_WIDTH/8-1:0]         ri_info_fifo7_data_keep               ;
    reg   [15:0]                           ri_info_fifo7_data_cnt                ;
    reg                                    r_info_fifo7_rd_pre         ;
    reg                                    r_info_fifo7_rd_pre2        ;
    reg                                    r_info_fifo7_rd_en          ;

    // fifoc
    reg                                    r_c_fifo7_qbu_flag       ;
    reg         [3:0]                      r_c_fifo7_qos            ; 
    reg        [15:0]                      w_c_fifo7_wr_data        ;
    reg                                    r_c_fifo7_vld            ;
    reg                                    r_c_fifo7_rd_en          ;
    wire        [15:0]                      w_c_fifo7_rd_data        ;
    wire                                   w_c_fifo7_full           ;
    wire                                   w_c_fifo7_empty          ;

    //output
    reg         [15:0]                     r_tx_mac_fifo7_cnt   ;
    reg                                    r_fifo7_ready        ;
    reg                                    r_fifo7_busy         ;
    reg                                    r_tx_mac_fifo7_vld   ;
    reg                                    r_tx_mac_fifo7_last  ;
    reg         [15:0]                     r_tx_mac_fifo7_keep  ;
    reg                                    w_info_fifo7_avaliable_flag;


reg     [PORT_FIFO_PRI_NUM-1:0]        ri_scheduing_rst     ;   
reg                                    ri_scheduing_rst_vld ;
// reg     [PORT_FIFO_PRI_NUM-1:0]        ri_scheduing_rst_output     ;   
reg                                    scheduing_work_flag ;


reg     [PORT_FIFO_PRI_NUM-1:0]        r_data_flag          ;

reg     [CROSS_DATA_WIDTH - 1:0]       ro_pmac_tx_axis_data ;
reg     [15:0]                         ro_pmac_tx_axis_user ;
reg     [(CROSS_DATA_WIDTH/8)-1:0]     ro_pmac_tx_axis_keep ;
reg                                    ro_pmac_tx_axis_last ;
reg                                    ro_pmac_tx_axis_last_t;
reg                                    ro_pmac_tx_axis_valid;

reg     [CROSS_DATA_WIDTH - 1:0]       ro_emac_tx_axis_data ;
reg     [15:0]                         ro_emac_tx_axis_user ;
reg     [(CROSS_DATA_WIDTH/8)-1:0]     ro_emac_tx_axis_keep ;
reg                                    ro_emac_tx_axis_last ;
reg                                    ro_emac_tx_axis_last_t;
reg                                    ro_emac_tx_axis_valid;

reg     [PORT_FIFO_PRI_NUM-1:0]        r_fifoc_empty;      

/*------------------------------------ assign ----------------------------------------*/
/*------------------------------------ assign ----------------------------------------*/
/*------------------------------------ assign ----------------------------------------*/
assign      o_data0_ready       =      ~w_data_fifo0_full    ;
assign      o_data1_ready       =      ~w_data_fifo1_full    ;
assign      o_data2_ready       =      ~w_data_fifo2_full    ;
assign      o_data3_ready       =      ~w_data_fifo3_full    ;
assign      o_data4_ready       =      ~w_data_fifo4_full    ;
assign      o_data5_ready       =      ~w_data_fifo5_full    ;
assign      o_data6_ready       =      ~w_data_fifo6_full    ;
assign      o_data7_ready       =      ~w_data_fifo7_full    ;

assign      o_data0_busy       =      r_fifo0_busy    ;
assign      o_data1_busy       =      r_fifo1_busy    ;
assign      o_data2_busy       =      r_fifo2_busy    ;
assign      o_data3_busy       =      r_fifo3_busy    ;
assign      o_data4_busy       =      r_fifo4_busy    ;
assign      o_data5_busy       =      r_fifo5_busy    ;
assign      o_data6_busy       =      r_fifo6_busy    ;
assign      o_data7_busy       =      r_fifo7_busy    ;

assign      o_fifoc_empty       =      r_fifoc_empty;

assign     o_pmac_tx_axis_data  =      ro_pmac_tx_axis_data  ;  
assign     o_pmac_tx_axis_user  =      ro_pmac_tx_axis_user  ;  
assign     o_pmac_tx_axis_keep  =      ro_pmac_tx_axis_keep  ;  
assign     o_pmac_tx_axis_last  =      ro_pmac_tx_axis_last  ;  
assign     o_pmac_tx_axis_valid =      ro_pmac_tx_axis_valid ;  

assign     o_emac_tx_axis_data  =      ro_emac_tx_axis_data  ;   
assign     o_emac_tx_axis_user  =      ro_emac_tx_axis_user  ;   
assign     o_emac_tx_axis_keep  =      ro_emac_tx_axis_keep  ;   
assign     o_emac_tx_axis_last  =      ro_emac_tx_axis_last  ;   
assign     o_emac_tx_axis_valid =      ro_emac_tx_axis_valid ;   


/*------------------------------------ always ----------------------------------------*/
/*------------------------------------ always ----------------------------------------*/
/*------------------------------------ always ----------------------------------------*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        r_fifoc_empty <= {PORT_FIFO_PRI_NUM{1'b1}};
    end else begin
        r_fifoc_empty <= ( i_scheduing_rst_vld == 1'b1 || scheduing_work_flag == 1'b1) ? {PORT_FIFO_PRI_NUM{1'b1}} : 
                         (  w_c_fifo0_empty == 1'b0    
                         || w_c_fifo1_empty == 1'b0                     //当没有在调度过程时，任何一个fifo有数据完成输入，则输出fifo状态等待调
                         || w_c_fifo2_empty == 1'b0
                         || w_c_fifo3_empty == 1'b0
                         || w_c_fifo4_empty == 1'b0
                         || w_c_fifo5_empty == 1'b0
                         || w_c_fifo6_empty == 1'b0
                         || w_c_fifo7_empty == 1'b0) ? {w_c_fifo7_empty,w_c_fifo6_empty,w_c_fifo5_empty,w_c_fifo4_empty,w_c_fifo3_empty,w_c_fifo2_empty,w_c_fifo1_empty,w_c_fifo0_empty} : r_fifoc_empty;
                        // (ro_pmac_tx_axis_last_t==1'b1 || ro_emac_tx_axis_last_t==1'b1                               
                                                    //    || i_data0_last == 1'b1
                                                    //    || i_data1_last == 1'b1
                                                    //    || i_data2_last == 1'b1
                                                    //    || i_data3_last == 1'b1
                                                    //    || i_data4_last == 1'b1
                                                    //    || i_data5_last == 1'b1
                                                    //    || i_data6_last == 1'b1
                                                    //    || i_data7_last == 1'b1
        // r_fifoc_empty[0] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[0] == 1'b1 ) ? 1'b1 : ( i_data0_last == 1'b1 ) ? w_c_fifo0_empty : r_fifoc_empty[0];
        // r_fifoc_empty[1] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[1] == 1'b1 ) ? 1'b1 : ( i_data1_last == 1'b1 ) ? w_c_fifo1_empty : r_fifoc_empty[1];
        // r_fifoc_empty[2] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[2] == 1'b1 ) ? 1'b1 : ( i_data2_last == 1'b1 ) ? w_c_fifo2_empty : r_fifoc_empty[2];
        // r_fifoc_empty[3] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[3] == 1'b1 ) ? 1'b1 : ( i_data3_last == 1'b1 ) ? w_c_fifo3_empty : r_fifoc_empty[3];
        // r_fifoc_empty[4] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[4] == 1'b1 ) ? 1'b1 : ( i_data4_last == 1'b1 ) ? w_c_fifo4_empty : r_fifoc_empty[4];
        // r_fifoc_empty[5] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[5] == 1'b1 ) ? 1'b1 : ( i_data5_last == 1'b1 ) ? w_c_fifo5_empty : r_fifoc_empty[5];
        // r_fifoc_empty[6] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[6] == 1'b1 ) ? 1'b1 : ( i_data6_last == 1'b1 ) ? w_c_fifo6_empty : r_fifoc_empty[6];
        // r_fifoc_empty[7] <= ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst[7] == 1'b1 ) ? 1'b1 : ( i_data7_last == 1'b1 ) ? w_c_fifo7_empty : r_fifoc_empty[7];
    end
end



always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        ro_pmac_tx_axis_data     <=  {CROSS_DATA_WIDTH{1'b0}};
        ro_pmac_tx_axis_user     <=  16'd0;
        ro_pmac_tx_axis_keep     <=  16'd0;
        ro_pmac_tx_axis_last     <=  1'b0;
        ro_pmac_tx_axis_valid    <=  1'b0;

        ro_emac_tx_axis_data     <=  {CROSS_DATA_WIDTH{1'b0}};
        ro_emac_tx_axis_user     <=  16'd0;
        ro_emac_tx_axis_keep     <=  16'd0;
        ro_emac_tx_axis_last     <=  1'b0;
        ro_emac_tx_axis_valid    <=  1'b0;
    end else begin
        ro_pmac_tx_axis_data     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? w_data_fifo0_rd_data : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? w_data_fifo1_rd_data :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? w_data_fifo2_rd_data : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? w_data_fifo3_rd_data :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? w_data_fifo4_rd_data : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? w_data_fifo5_rd_data :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? w_data_fifo6_rd_data : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? w_data_fifo7_rd_data : {CROSS_DATA_WIDTH{1'b0}}; 

        ro_pmac_tx_axis_user     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? w_c_fifo0_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? w_c_fifo1_rd_data : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? w_c_fifo2_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? w_c_fifo3_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? w_c_fifo4_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? w_c_fifo5_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? w_c_fifo6_rd_data :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? w_c_fifo7_rd_data : 16'd0;
                                                                                               
        ro_pmac_tx_axis_keep     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_keep : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_keep : 16'd0;

        ro_pmac_tx_axis_last     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_last :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_last : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_last : 1'b0;

        ro_pmac_tx_axis_valid    <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_vld : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_vld : 1'b0;  

        ro_emac_tx_axis_data     <=  ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? w_data_fifo0_rd_data :
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? w_data_fifo1_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? w_data_fifo2_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? w_data_fifo3_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? w_data_fifo4_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? w_data_fifo5_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? w_data_fifo6_rd_data : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? w_data_fifo7_rd_data : {CROSS_DATA_WIDTH{1'b0}};

        ro_emac_tx_axis_user     <=  ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? {11'd0,w_c_fifo0_rd_data} :
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? {11'd0,w_c_fifo1_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? {11'd0,w_c_fifo2_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? {11'd0,w_c_fifo3_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? {11'd0,w_c_fifo4_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? {11'd0,w_c_fifo5_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? {11'd0,w_c_fifo6_rd_data} : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? {11'd0,w_c_fifo7_rd_data} : 16'd0;

        ro_emac_tx_axis_keep     <=  ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_keep :
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_keep : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_keep : 16'd0;

        ro_emac_tx_axis_last     <=  ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_last :
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_last : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_last : 1'b0;

        ro_emac_tx_axis_valid    <=  ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo0_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo0_vld :
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo1_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo1_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo2_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo2_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo3_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo3_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo4_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo4_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo5_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo5_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo6_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo6_vld : 
                                     ( i_emac_tx_axis_ready == 1'b1 && r_c_fifo7_qbu_flag == 1'b1 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo7_vld : 1'b0; 
    end
end

    // 锁存 TXMAC 调度流水线返回的调度结果
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_scheduing_rst <= {PORT_FIFO_PRI_NUM{1'b0}};
        end else begin
            ri_scheduing_rst <= ( i_scheduing_rst_vld == 1'b1 ) ? i_scheduing_rst : ri_scheduing_rst;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_scheduing_rst_vld <= 1'b0;
            scheduing_work_flag <= 1'b0;
            ro_emac_tx_axis_last_t <= 1'b0;
            ro_pmac_tx_axis_last_t <= 1'b0;
        end else begin
            ri_scheduing_rst_vld <= i_scheduing_rst_vld;//
            scheduing_work_flag <= ( ro_emac_tx_axis_last == 1'b1 || ro_pmac_tx_axis_last == 1'b1) ? 1'b0 : ( i_scheduing_rst_vld == 1'b1 && i_scheduing_rst != {PORT_FIFO_PRI_NUM{1'b0}}) ? 1'b1 : scheduing_work_flag;
            ro_emac_tx_axis_last_t <= ro_emac_tx_axis_last;
            ro_pmac_tx_axis_last_t <= ro_pmac_tx_axis_last;
        end
    end

//----------- fifo0 ------------
    // 记录数据末尾的 keep 信号，用于交换平面给 TXMAC 数据流时产生 keep 信号
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo0_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo0_data_keep <= ( r_info_fifo0_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data0_last == 1'b1 &&  i_data0_vld == 1'b1 ) ? i_data0_keep : ri_info_fifo0_data_keep;
        end
    end

    // 记录数据长度，用于交换平面给 TXMAC 数据流时产生 last 信号
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo0_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo0_data_cnt <= ( r_info_fifo0_data_vld == 1'b1 ) ? 16'd0 : ( i_data0_vld == 1'b1 ) ? ri_info_fifo0_data_cnt + 16'd1 : ri_info_fifo0_data_cnt;
        end
    end

    // 内部信息写入 FIFO 有效位
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo0_data_vld <= 1'b0;
        end else begin
            r_info_fifo0_data_vld <= ( i_data0_last == 1'b1 &&  i_data0_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    // meta 信息头 qbu flag 标识
    /*
	always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo0_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo0_qbu_flag <= (  r_c_fifo0_vld == 1'b1 ) ? 1'b0 : ( i_meta_data0_pri_vld == 1'b1 ) ? i_meta_data0_pri[11] : r_c_fifo0_qbu_flag;
        end
    end
	*/
		always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo0_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo0_qbu_flag <= (  r_c_fifo0_vld == 1'b1 ) ? 1'b0 : ( i_meta_data0_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo0_qbu_flag;
        end
    end
	
    // meta 信息头 qos 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo0_qos <= 1'b0;
        end else begin
            r_c_fifo0_qos <= (  r_c_fifo0_vld == 1'b1 ) ? 1'b0 : ( i_meta_data0_pri_vld == 1'b1 ) ? i_meta_data0_pri[18:15] : r_c_fifo0_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo0_wr_data <= 1'b0;
        end else begin
            w_c_fifo0_wr_data <= i_data0_user;
        end
    end

    // meta 信息头写入 FIFO 有效位
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo0_vld <= 1'b0;
        end else begin
            r_c_fifo0_vld <= i_data0_last;   //i_meta_data0_pri_vld;    //写完一整个数据包后，c_fifo_empty才为0，相当于允许被TXMAC调度
        end
    end

    // 标识该优先级 FIFO 是否可以继续写入数据(忙信号)
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo0_busy <= 1'b0;
        end else begin
            r_fifo0_busy <= ( i_data0_vld == 1'b0 && w_data_fifo0_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    // 调度结果返回 FIFO0 的结果时，开始拉高读数据使能
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo0_rd_en <= 1'b0;
        end else begin
            r_data_fifo0_rd_en <= ( (r_tx_mac_fifo0_cnt == w_info_fifo0_datalen) && w_info_fifo0_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? 1'b1 : r_data_fifo0_rd_en;
        end
    end

    // 调度结果返回 FIFO0 的结果时，开始拉高读 meta 使能
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo0_rd_en <= 1'b0;
        end else begin
            r_c_fifo0_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end
    
    // 检测读出的数据长度
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo0_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo0_cnt <= ( (r_tx_mac_fifo0_cnt == w_info_fifo0_datalen) && w_info_fifo0_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo0_rd_en == 1'b1 ) ? (r_tx_mac_fifo0_cnt + 16'd1) : r_tx_mac_fifo0_cnt;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo0_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo0_avaliable_flag <= ( r_info_fifo0_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo0_cnt == w_info_fifo0_datalen ) ? 1'b0: w_info_fifo0_avaliable_flag;
        end
    end


    // 拉高 info 数据末尾产生 last keep 信号

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo0_rd_pre <= 1'b0;
        end else begin
            r_info_fifo0_rd_pre <= ( w_info_fifo0_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo0_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo0_rd_pre2 <= r_info_fifo0_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo0_rd_en <= 1'b0;
        end else begin
            r_info_fifo0_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? 1'b1 : 1'b0;//( r_info_fifo0_rd_pre == 1'b1 && r_info_fifo0_rd_pre2 == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo0_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo0_vld <= r_data_fifo0_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo0_last  <= 1'b0;
            r_tx_mac_fifo0_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo0_last <= ( r_tx_mac_fifo0_vld == 1'b1 && r_tx_mac_fifo0_cnt == w_info_fifo0_datalen ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo0_keep <= ( r_tx_mac_fifo0_vld == 1'b1 && r_tx_mac_fifo0_cnt == w_info_fifo0_datalen ) ? w_info_fifo0_keep : 16'd0;
        end
    end


//----------- fifo1 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo1_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo1_data_keep <= ( r_info_fifo1_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data1_last == 1'b1 &&  i_data1_vld == 1'b1 ) ? i_data1_keep : ri_info_fifo1_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo1_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo1_data_cnt <= ( r_info_fifo1_data_vld == 1'b1 ) ? 16'd0 : ( i_data1_vld == 1'b1 ) ? ri_info_fifo1_data_cnt + 16'd1 : ri_info_fifo1_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo1_data_vld <= 1'b0;
        end else begin
            r_info_fifo1_data_vld <= ( i_data1_last == 1'b1 &&  i_data1_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo1_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo1_qbu_flag <= (  r_c_fifo1_vld == 1'b1 ) ? 1'b0 : ( i_meta_data1_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo1_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo1_qos <= 1'b0;
        end else begin
            r_c_fifo1_qos <= (  r_c_fifo1_vld == 1'b1 ) ? 1'b0 : ( i_meta_data1_pri_vld == 1'b1 ) ? i_meta_data1_pri[18:15] : r_c_fifo1_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo1_wr_data <= 1'b0;
        end else begin
            w_c_fifo1_wr_data <= i_data1_user;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo1_vld <= 1'b0;
        end else begin
            r_c_fifo1_vld <= i_data1_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo1_busy <= 1'b0;
        end else begin
            r_fifo1_busy <= ( i_data1_vld == 1'b0 && w_data_fifo1_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo1_rd_en <= 1'b0;
        end else begin
            r_data_fifo1_rd_en <= ( (r_tx_mac_fifo1_cnt == w_info_fifo1_datalen) && w_info_fifo1_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? 1'b1 : r_data_fifo1_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo1_rd_en <= 1'b0;
        end else begin
            r_c_fifo1_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo1_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo1_cnt <= ( (r_tx_mac_fifo1_cnt == w_info_fifo1_datalen) && w_info_fifo1_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo1_rd_en == 1'b1 ) ? (r_tx_mac_fifo1_cnt + 16'd1) : r_tx_mac_fifo1_cnt;
        end
    end

   always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo1_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo1_avaliable_flag <= ( r_info_fifo1_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo1_cnt == w_info_fifo1_datalen ) ? 1'b0: w_info_fifo1_avaliable_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo1_rd_pre <= 1'b0;
        end else begin
            r_info_fifo1_rd_pre <= ( w_info_fifo1_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo1_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo1_rd_pre2 <= r_info_fifo1_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo1_rd_en <= 1'b0;
        end else begin
            r_info_fifo1_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo1_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo1_vld <= r_data_fifo1_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo1_last  <= 1'b0;
            r_tx_mac_fifo1_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo1_last <= ( r_tx_mac_fifo1_vld == 1'b1 && r_tx_mac_fifo1_cnt == w_info_fifo1_datalen ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo1_keep <= ( r_tx_mac_fifo1_vld == 1'b1 && r_tx_mac_fifo1_cnt == w_info_fifo1_datalen ) ? w_info_fifo1_keep : 16'd0;
        end
    end

    //----------- fifo2 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo2_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo2_data_keep <= ( r_info_fifo2_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data2_last == 1'b1 &&  i_data2_vld == 1'b1 ) ? i_data2_keep : ri_info_fifo2_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo2_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo2_data_cnt <= ( r_info_fifo2_data_vld == 1'b1 ) ? 16'd0 : ( i_data2_vld == 1'b1 ) ? ri_info_fifo2_data_cnt + 16'd1 : ri_info_fifo2_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo2_data_vld <= 1'b0;
        end else begin
            r_info_fifo2_data_vld <= ( i_data2_last == 1'b1 &&  i_data2_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo2_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo2_qbu_flag <= (  r_c_fifo2_vld == 1'b1 ) ? 1'b0 : ( i_meta_data2_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo2_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo2_qos <= 1'b0;
        end else begin
            r_c_fifo2_qos <= (  r_c_fifo2_vld == 1'b1 ) ? 1'b0 : ( i_meta_data2_pri_vld == 1'b1 ) ? i_meta_data2_pri[18:15] : r_c_fifo2_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo2_wr_data <= 1'b0;
        end else begin
            w_c_fifo2_wr_data <= i_data2_user;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo2_vld <= 1'b0;
        end else begin
            r_c_fifo2_vld <= i_data2_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo2_busy <= 1'b0;
        end else begin
            r_fifo2_busy <= ( i_data2_vld == 1'b0 && w_data_fifo2_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo2_rd_en <= 1'b0;
        end else begin
            r_data_fifo2_rd_en <= ( (r_tx_mac_fifo2_cnt == w_info_fifo2_datalen) && w_info_fifo2_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? 1'b1 : r_data_fifo2_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo2_rd_en <= 1'b0;
        end else begin
            r_c_fifo2_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo2_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo2_cnt <= ( (r_tx_mac_fifo2_cnt == w_info_fifo2_datalen) && w_info_fifo2_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo2_rd_en == 1'b1 ) ? (r_tx_mac_fifo2_cnt + 16'd1) : r_tx_mac_fifo2_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo2_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo2_avaliable_flag <= ( r_info_fifo2_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo2_cnt == w_info_fifo2_datalen ) ? 1'b0: w_info_fifo2_avaliable_flag;
        end
    end



    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo2_rd_pre <= 1'b0;
        end else begin
            r_info_fifo2_rd_pre <= (  w_info_fifo2_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo2_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo2_rd_pre2 <= r_info_fifo2_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo2_rd_en <= 1'b0;
        end else begin
            r_info_fifo2_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo2_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo2_vld <= r_data_fifo2_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo2_last  <= 1'b0;
            r_tx_mac_fifo2_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo2_last <= ( r_tx_mac_fifo2_vld == 1'b1 && r_tx_mac_fifo2_cnt == w_info_fifo2_datalen  ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo2_keep <= ( r_tx_mac_fifo2_vld == 1'b1 && r_tx_mac_fifo2_cnt == w_info_fifo2_datalen  ) ? w_info_fifo2_keep : 16'd0;
        end
    end

    //----------- fifo3 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo3_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo3_data_keep <= ( r_info_fifo3_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data3_last == 1'b1 &&  i_data3_vld == 1'b1 ) ? i_data3_keep : ri_info_fifo3_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo3_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo3_data_cnt <= ( r_info_fifo3_data_vld == 1'b1 ) ? 16'd0 : ( i_data3_vld == 1'b1 ) ? ri_info_fifo3_data_cnt + 16'd1 : ri_info_fifo3_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo3_data_vld <= 1'b0;
        end else begin
            r_info_fifo3_data_vld <= ( i_data3_last == 1'b1 &&  i_data3_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo3_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo3_qbu_flag <= (  r_c_fifo3_vld == 1'b1 ) ? 1'b0 : ( i_meta_data3_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo3_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo3_qos <= 1'b0;
        end else begin
            r_c_fifo3_qos <= (  r_c_fifo3_vld == 1'b1 ) ? 1'b0 : ( i_meta_data3_pri_vld == 1'b1 ) ? i_meta_data3_pri[18:15] : r_c_fifo3_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo3_wr_data <= 1'b0;
        end else begin
            w_c_fifo3_wr_data <= i_data3_user;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo3_vld <= 1'b0;
        end else begin
            r_c_fifo3_vld <= i_data3_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo3_busy <= 1'b0;
        end else begin
            r_fifo3_busy <= ( i_data3_vld == 1'b0 && w_data_fifo3_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo3_rd_en <= 1'b0;
        end else begin
            r_data_fifo3_rd_en <= ( (r_tx_mac_fifo3_cnt == w_info_fifo3_datalen) && w_info_fifo3_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? 1'b1 : r_data_fifo3_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo3_rd_en <= 1'b0;
        end else begin
            r_c_fifo3_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo3_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo3_cnt <= ( (r_tx_mac_fifo3_cnt == w_info_fifo3_datalen) && w_info_fifo3_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo3_rd_en == 1'b1 ) ? (r_tx_mac_fifo3_cnt + 16'd1) : r_tx_mac_fifo3_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo3_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo3_avaliable_flag <= ( r_info_fifo3_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo3_cnt == w_info_fifo3_datalen ) ? 1'b0: w_info_fifo3_avaliable_flag;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo3_rd_pre <= 1'b0;
        end else begin
            r_info_fifo3_rd_pre <= ( w_info_fifo3_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo3_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo3_rd_pre2 <= r_info_fifo3_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo3_rd_en <= 1'b0;
        end else begin
            r_info_fifo3_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo3_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo3_vld <= r_data_fifo3_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo3_last  <= 1'b0;
            r_tx_mac_fifo3_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo3_last <= ( r_tx_mac_fifo3_vld == 1'b1 && r_tx_mac_fifo3_cnt == w_info_fifo3_datalen  ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo3_keep <= ( r_tx_mac_fifo3_vld == 1'b1 && r_tx_mac_fifo3_cnt == w_info_fifo3_datalen  ) ? w_info_fifo3_keep : 16'd0;
        end
    end

    //----------- fifo4 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo4_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo4_data_keep <= ( r_info_fifo4_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data4_last == 1'b1 &&  i_data4_vld == 1'b1 ) ? i_data4_keep : ri_info_fifo4_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo4_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo4_data_cnt <= ( r_info_fifo4_data_vld == 1'b1 ) ? 16'd0 : ( i_data4_vld == 1'b1 ) ? ri_info_fifo4_data_cnt + 16'd1 : ri_info_fifo4_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo4_data_vld <= 1'b0;
        end else begin
            r_info_fifo4_data_vld <= ( i_data4_last == 1'b1 &&  i_data4_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo4_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo4_qbu_flag <= (  r_c_fifo4_vld == 1'b1 ) ? 1'b0 : ( i_meta_data4_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo4_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo4_qos <= 1'b0;
        end else begin
            r_c_fifo4_qos <= (  r_c_fifo4_vld == 1'b1 ) ? 1'b0 : ( i_meta_data4_pri_vld == 1'b1 ) ? i_meta_data4_pri[18:15] : r_c_fifo4_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo4_wr_data <= 1'b0;
        end else begin
            w_c_fifo4_wr_data <= i_data4_user;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo4_vld <= 1'b0;
        end else begin
            r_c_fifo4_vld <= i_data4_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo4_busy <= 1'b0;
        end else begin
            r_fifo4_busy <= ( i_data4_vld == 1'b0 && w_data_fifo4_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo4_rd_en <= 1'b0;
        end else begin
            r_data_fifo4_rd_en <= ( (r_tx_mac_fifo4_cnt == w_info_fifo4_datalen) && w_info_fifo4_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? 1'b1 : r_data_fifo4_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo4_rd_en <= 1'b0;
        end else begin
            r_c_fifo4_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo4_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo4_cnt <= ( (r_tx_mac_fifo4_cnt == w_info_fifo4_datalen) && w_info_fifo4_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo4_rd_en == 1'b1 ) ? (r_tx_mac_fifo4_cnt + 16'd1) : r_tx_mac_fifo4_cnt;
        end
    end
    
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo4_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo4_avaliable_flag <= ( r_info_fifo4_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo4_cnt == w_info_fifo4_datalen ) ? 1'b0: w_info_fifo4_avaliable_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo4_rd_pre <= 1'b0;
        end else begin
            r_info_fifo4_rd_pre <= ( w_info_fifo4_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo4_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo4_rd_pre2 <= r_info_fifo4_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo4_rd_en <= 1'b0;
        end else begin
            r_info_fifo4_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo4_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo4_vld <= r_data_fifo4_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo4_last  <= 1'b0;
            r_tx_mac_fifo4_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo4_last <= ( r_tx_mac_fifo4_vld == 1'b1 && r_tx_mac_fifo4_cnt == w_info_fifo4_datalen  ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo4_keep <= ( r_tx_mac_fifo4_vld == 1'b1 && r_tx_mac_fifo4_cnt == w_info_fifo4_datalen  ) ? w_info_fifo4_keep : 16'd0;
        end
    end

    //----------- fifo5 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo5_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo5_data_keep <= ( r_info_fifo5_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data5_last == 1'b1 &&  i_data5_vld == 1'b1 ) ? i_data5_keep : ri_info_fifo5_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo5_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo5_data_cnt <= ( r_info_fifo5_data_vld == 1'b1 ) ? 16'd0 : ( i_data5_vld == 1'b1 ) ? ri_info_fifo5_data_cnt + 16'd1 : ri_info_fifo5_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo5_data_vld <= 1'b0;
        end else begin
            r_info_fifo5_data_vld <= ( i_data5_last == 1'b1 &&  i_data5_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo5_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo5_qbu_flag <= (  r_c_fifo5_vld == 1'b1 ) ? 1'b0 : ( i_meta_data5_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo5_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo5_qos <= 1'b0;
        end else begin
            r_c_fifo5_qos <= (  r_c_fifo5_vld == 1'b1 ) ? 1'b0 : ( i_meta_data5_pri_vld == 1'b1 ) ? i_meta_data5_pri[18:15] : r_c_fifo5_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo5_wr_data <= 1'b0;
        end else begin
            w_c_fifo5_wr_data <= i_data5_user;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo5_vld <= 1'b0;
        end else begin
            r_c_fifo5_vld <= i_data5_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo5_busy <= 1'b0;
        end else begin
            r_fifo5_busy <= ( i_data5_vld == 1'b0 && w_data_fifo5_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo5_rd_en <= 1'b0;
        end else begin
            r_data_fifo5_rd_en <= ( (r_tx_mac_fifo5_cnt == w_info_fifo5_datalen) && w_info_fifo5_avaliable_flag ==1'b1) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? 1'b1 : r_data_fifo5_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo5_rd_en <= 1'b0;
        end else begin
            r_c_fifo5_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo5_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo5_cnt <= ( (r_tx_mac_fifo5_cnt == w_info_fifo5_datalen) && w_info_fifo5_avaliable_flag ==1'b1) ? 16'd1 : ( r_data_fifo5_rd_en == 1'b1 ) ? (r_tx_mac_fifo5_cnt + 16'd1) : r_tx_mac_fifo5_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo5_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo5_avaliable_flag <= ( r_info_fifo5_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo5_cnt == w_info_fifo5_datalen ) ? 1'b0: w_info_fifo5_avaliable_flag;
        end
    end


    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo5_rd_pre <= 1'b0;
        end else begin
            r_info_fifo5_rd_pre <= ( w_info_fifo5_empty == 1'b0 ) ? 1'b1 : 1'b0;//( r_data_fifo5_rd_en == 1'b1 && w_info_fifo5_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo5_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo5_rd_pre2 <= r_info_fifo5_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo5_rd_en <= 1'b0;
        end else begin
            r_info_fifo5_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo5_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo5_vld <= r_data_fifo5_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo5_last  <= 1'b0;
            r_tx_mac_fifo5_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo5_last <= ( r_tx_mac_fifo5_vld == 1'b1 && r_tx_mac_fifo5_cnt == w_info_fifo5_datalen) ? 1'b1 : 1'b0;
            r_tx_mac_fifo5_keep <= ( r_tx_mac_fifo5_vld == 1'b1 && r_tx_mac_fifo5_cnt == w_info_fifo5_datalen) ? w_info_fifo5_keep : 16'd0;
        end
    end

    //----------- fifo6 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo6_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo6_data_keep <= ( r_info_fifo6_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data6_last == 1'b1 &&  i_data6_vld == 1'b1 ) ? i_data6_keep : ri_info_fifo6_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo6_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo6_data_cnt <= ( r_info_fifo6_data_vld == 1'b1 ) ? 16'd0 : ( i_data6_vld == 1'b1 ) ? ri_info_fifo6_data_cnt + 16'd1 : ri_info_fifo6_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo6_data_vld <= 1'b0;
        end else begin
            r_info_fifo6_data_vld <= ( i_data6_last == 1'b1 &&  i_data6_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo6_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo6_qbu_flag <= (  r_c_fifo6_vld == 1'b1 ) ? 1'b0 : ( i_meta_data6_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo6_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo6_qos <= 1'b0;
        end else begin
            r_c_fifo6_qos <= (  r_c_fifo6_vld == 1'b1 ) ? 1'b0 : ( i_meta_data6_pri_vld == 1'b1 ) ? i_meta_data6_pri[18:15] : r_c_fifo6_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo6_wr_data <= 1'b0;
        end else begin
            w_c_fifo6_wr_data <= i_data6_user;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo6_vld <= 1'b0;
        end else begin
            r_c_fifo6_vld <= i_data6_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo6_busy <= 1'b0;
        end else begin
            r_fifo6_busy <= ( i_data6_vld == 1'b0 && w_data_fifo6_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo6_rd_en <= 1'b0;
        end else begin
            r_data_fifo6_rd_en <= ( (r_tx_mac_fifo6_cnt == w_info_fifo6_datalen) && w_info_fifo6_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? 1'b1 : r_data_fifo6_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo6_rd_en <= 1'b0;
        end else begin
            r_c_fifo6_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo6_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo6_cnt <= ( (r_tx_mac_fifo6_cnt == w_info_fifo6_datalen) && w_info_fifo6_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo6_rd_en == 1'b1 ) ? (r_tx_mac_fifo6_cnt + 16'd1) : r_tx_mac_fifo6_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo6_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo6_avaliable_flag <= ( r_info_fifo6_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo6_cnt == w_info_fifo6_datalen ) ? 1'b0: w_info_fifo6_avaliable_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo6_rd_pre <= 1'b0;
        end else begin
            r_info_fifo6_rd_pre <= ( w_info_fifo6_empty == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo6_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo6_rd_pre2 <= r_info_fifo6_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo6_rd_en <= 1'b0;
        end else begin
            r_info_fifo6_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo6_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo6_vld <= r_data_fifo6_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo6_last  <= 1'b0;
            r_tx_mac_fifo6_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo6_last <= ( r_tx_mac_fifo6_vld == 1'b1 && r_tx_mac_fifo6_cnt == w_info_fifo6_datalen ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo6_keep <= ( r_tx_mac_fifo6_vld == 1'b1 && r_tx_mac_fifo6_cnt == w_info_fifo6_datalen ) ? w_info_fifo6_keep : 16'd0;
        end
    end

    //----------- fifo7 ------------
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo7_data_keep <= {(CROSS_DATA_WIDTH/8){1'b0}};
        end else begin
            ri_info_fifo7_data_keep <= ( r_info_fifo7_data_vld == 1'b1 ) ? {(CROSS_DATA_WIDTH/8){1'b0}} :( i_data7_last == 1'b1 &&  i_data7_vld == 1'b1 ) ? i_data7_keep : ri_info_fifo7_data_keep;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            ri_info_fifo7_data_cnt <= 16'd0;
        end else begin
            ri_info_fifo7_data_cnt <= ( r_info_fifo7_data_vld == 1'b1 ) ? 16'd0 : ( i_data7_vld == 1'b1 ) ? ri_info_fifo7_data_cnt + 16'd1 : ri_info_fifo7_data_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo7_data_vld <= 1'b0;
        end else begin
            r_info_fifo7_data_vld <= ( i_data7_last == 1'b1 &&  i_data7_vld == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo7_qbu_flag <= 1'b0;
        end else begin
            r_c_fifo7_qbu_flag <= (  r_c_fifo7_vld == 1'b1 ) ? 1'b0 : ( i_meta_data7_pri_vld == 1'b1 ) ? i_emac_tx_axis_user[13] : r_c_fifo7_qbu_flag;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo7_qos <= 1'b0;
        end else begin
            r_c_fifo7_qos <= (  r_c_fifo7_vld == 1'b1 ) ? 1'b0 : ( i_meta_data7_pri_vld == 1'b1 ) ? i_meta_data7_pri[18:15] : r_c_fifo7_qos;
        end
    end

   // user 字段
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_c_fifo7_wr_data <= 1'b0;
        end else begin
            w_c_fifo7_wr_data <= i_data7_user;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo7_vld <= 1'b0;
        end else begin
            r_c_fifo7_vld <= i_data7_last;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_fifo7_busy <= 1'b0;
        end else begin
            r_fifo7_busy <= ( i_data7_vld == 1'b0 && w_data_fifo7_full == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_data_fifo7_rd_en <= 1'b0;
        end else begin
            r_data_fifo7_rd_en <= ( (r_tx_mac_fifo7_cnt == w_info_fifo7_datalen) && w_info_fifo7_avaliable_flag ==1'b1 ) ? 1'b0 : ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? 1'b1 : r_data_fifo7_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_c_fifo7_rd_en <= 1'b0;
        end else begin
            r_c_fifo7_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo7_cnt <= 16'd1;
        end else begin
            r_tx_mac_fifo7_cnt <= ( (r_tx_mac_fifo7_cnt == w_info_fifo7_datalen) && w_info_fifo7_avaliable_flag ==1'b1 ) ? 16'd1 : ( r_data_fifo7_rd_en == 1'b1 ) ? (r_tx_mac_fifo7_cnt + 16'd1) : r_tx_mac_fifo7_cnt;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            w_info_fifo7_avaliable_flag <= 1'b0;
        end else begin
            w_info_fifo7_avaliable_flag <= ( r_info_fifo7_rd_en == 1'b1) ? 1'b1 : ( r_tx_mac_fifo7_cnt == w_info_fifo7_datalen ) ? 1'b0: w_info_fifo7_avaliable_flag;
        end
    end

   
    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo7_rd_pre <= 1'b0;
        end else begin
            r_info_fifo7_rd_pre <= ( w_info_fifo7_empty == 1'b0) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo7_rd_pre2 <= 1'b0;
        end else begin
            r_info_fifo7_rd_pre2 <= r_info_fifo7_rd_pre;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_info_fifo7_rd_en <= 1'b0;
        end else begin
            r_info_fifo7_rd_en <= ( ri_scheduing_rst_vld == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? 1'b1 : 1'b0;//( r_info_fifo7_rd_pre == 1'b1 && r_info_fifo7_rd_pre2 == 1'b0 ) ? 1'b1 : 1'b0;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo7_vld <= 1'b0;
        end else begin
            r_tx_mac_fifo7_vld <= r_data_fifo7_rd_en;
        end
    end

    always @(posedge i_clk or posedge i_rst) begin
        if (i_rst == 1'b1) begin
            r_tx_mac_fifo7_last  <= 1'b0;
            r_tx_mac_fifo7_keep  <= 16'd0;
        end else begin
            r_tx_mac_fifo7_last <= ( r_tx_mac_fifo7_vld == 1'b1 && r_tx_mac_fifo7_cnt == w_info_fifo7_datalen ) ? 1'b1 : 1'b0;
            r_tx_mac_fifo7_keep <= ( r_tx_mac_fifo7_vld == 1'b1 && r_tx_mac_fifo7_cnt == w_info_fifo7_datalen ) ? w_info_fifo7_keep : 16'd0;
        end
    end



/*--------- inst ----------*/

// ------ fifo0 -------
    sync_fifo #(
        .DEPTH                    ( 16384              )
        ,.WIDTH                   ( CROSS_DATA_WIDTH   )
        ,.ALMOST_FULL_THRESHOLD   (      )
        ,.ALMOST_EMPTY_THRESHOLD  ( 'd1 )
        ,.FLOP_DATA_OUT           ( 1'b0 ) //是否开启fwft
        ,.RAM_STYLE               ( 1'b1 ) // RAM综合类型选择：
                                            // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                            // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
    ) pri0_fifo_inst (       
        .i_clk                    ( i_clk                ) 
        ,.i_rst                   ( i_rst                ) 
        ,.i_wr_en                 ( i_data0_vld          ) 
        ,.i_din                   ( i_data0              ) 
        ,.o_full                  ( w_data_fifo0_full     )    
        ,.i_rd_en                 ( r_data_fifo0_rd_en        )    
        ,.o_dout                  ( w_data_fifo0_rd_data      )    
        ,.o_empty                 ( w_data_fifo0_empty    ) 
        ,.o_almost_full           ( ) 
        ,.o_almost_empty          ( ) 
        ,.o_data_cnt              (  )
    );

    sync_fifo #(
        .DEPTH                    ( 64       )
        ,.WIDTH                   ( 32       )
        ,.ALMOST_FULL_THRESHOLD   (          )
        ,.ALMOST_EMPTY_THRESHOLD  ( 'd1      )
        ,.FLOP_DATA_OUT           ( 1'b1     ) //是否开启fwft
        ,.RAM_STYLE               ( 1'b0     ) // RAM综合类型选择：
                                            // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                            // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
    ) pri0_fifo_info_inst (       
        .i_clk                    ( i_clk                          ) 
        ,.i_rst                   ( i_rst                          ) 
        ,.i_wr_en                 ( r_info_fifo0_data_vld               ) 
        ,.i_din                   ( { ri_info_fifo0_data_keep,ri_info_fifo0_data_cnt } ) 
        ,.o_full                  (                                )    
        ,.i_rd_en                 ( r_info_fifo0_rd_en             )    
        ,.o_dout                  ( { w_info_fifo0_keep,w_info_fifo0_datalen } )    
        ,.o_empty                 ( w_info_fifo0_empty         ) 
        ,.o_almost_full           (                                ) 
        ,.o_almost_empty          (                                ) 
        ,.o_data_cnt              (                                )
    );

    sync_fifo #(
        .DEPTH                    ( 64       )
        ,.WIDTH                   ( 16       )
        ,.ALMOST_FULL_THRESHOLD   (          )
        ,.ALMOST_EMPTY_THRESHOLD  ( 'd1      )
        ,.FLOP_DATA_OUT           ( 1'b0     ) //是否开启fwft
        ,.RAM_STYLE               ( 1'b0     ) // RAM综合类型选择：
                                            // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                            // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
    ) pri0_fifoc_inst (       
        .i_clk                    ( i_clk                            ) 
        ,.i_rst                   ( i_rst                            ) 
        ,.i_wr_en                 ( r_c_fifo0_vld                ) 
        ,.i_din                   ( w_c_fifo0_wr_data                    ) //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
        ,.o_full                  ( w_c_fifo0_full                )    
        ,.i_rd_en                 ( r_c_fifo0_rd_en                    )    
        ,.o_dout                  ( w_c_fifo0_rd_data                  )    
        ,.o_empty                 ( w_c_fifo0_empty               ) 
        ,.o_almost_full           (                                  ) 
        ,.o_almost_empty          (                                  ) 
        ,.o_data_cnt              (                                  )
    );

// ------ fifo1 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri1_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data1_vld          ),
    .i_din                   ( i_data1              ),
    .o_full                  ( w_data_fifo1_full    ),
    .i_rd_en                 ( r_data_fifo1_rd_en   ),
    .o_dout                  ( w_data_fifo1_rd_data ),
    .o_empty                 ( w_data_fifo1_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri1_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo1_data_vld          ),
    .i_din                   ( { ri_info_fifo1_data_keep,ri_info_fifo1_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo1_rd_en             ),
    .o_dout                  ( { w_info_fifo1_keep,w_info_fifo1_datalen } ),
    .o_empty                 ( w_info_fifo1_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri1_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo1_vld                   ),
    .i_din                   ( w_c_fifo1_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo1_full                  ),
    .i_rd_en                 ( r_c_fifo1_rd_en                 ),
    .o_dout                  ( w_c_fifo1_rd_data               ),
    .o_empty                 ( w_c_fifo1_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo2 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri2_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data2_vld          ),
    .i_din                   ( i_data2              ),
    .o_full                  ( w_data_fifo2_full    ),
    .i_rd_en                 ( r_data_fifo2_rd_en   ),
    .o_dout                  ( w_data_fifo2_rd_data ),
    .o_empty                 ( w_data_fifo2_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri2_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo2_data_vld          ),
    .i_din                   ( { ri_info_fifo2_data_keep,ri_info_fifo2_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo2_rd_en             ),
    .o_dout                  ( { w_info_fifo2_keep,w_info_fifo2_datalen } ),
    .o_empty                 ( w_info_fifo2_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri2_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo2_vld                   ),
    .i_din                  ( w_c_fifo2_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo2_full                  ),
    .i_rd_en                 ( r_c_fifo2_rd_en                 ),
    .o_dout                  ( w_c_fifo2_rd_data               ),
    .o_empty                 ( w_c_fifo2_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo3 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri3_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data3_vld          ),
    .i_din                   ( i_data3              ),
    .o_full                  ( w_data_fifo3_full    ),
    .i_rd_en                 ( r_data_fifo3_rd_en   ),
    .o_dout                  ( w_data_fifo3_rd_data ),
    .o_empty                 ( w_data_fifo3_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri3_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo3_data_vld          ),
    .i_din                   ( { ri_info_fifo3_data_keep,ri_info_fifo3_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo3_rd_en             ),
    .o_dout                  ( { w_info_fifo3_keep,w_info_fifo3_datalen } ),
    .o_empty                 ( w_info_fifo3_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri3_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo3_vld                   ),
    .i_din                  ( w_c_fifo3_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo3_full                  ),
    .i_rd_en                 ( r_c_fifo3_rd_en                 ),
    .o_dout                  ( w_c_fifo3_rd_data               ),
    .o_empty                 ( w_c_fifo3_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo4 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri4_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data4_vld          ),
    .i_din                   ( i_data4              ),
    .o_full                  ( w_data_fifo4_full    ),
    .i_rd_en                 ( r_data_fifo4_rd_en   ),
    .o_dout                  ( w_data_fifo4_rd_data ),
    .o_empty                 ( w_data_fifo4_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri4_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo4_data_vld          ),
    .i_din                   ( { ri_info_fifo4_data_keep,ri_info_fifo4_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo4_rd_en             ),
    .o_dout                  ( { w_info_fifo4_keep,w_info_fifo4_datalen } ),
    .o_empty                 ( w_info_fifo4_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri4_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo4_vld                   ),
    .i_din                  ( w_c_fifo4_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo4_full                  ),
    .i_rd_en                 ( r_c_fifo4_rd_en                 ),
    .o_dout                  ( w_c_fifo4_rd_data               ),
    .o_empty                 ( w_c_fifo4_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo5 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri5_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data5_vld          ),
    .i_din                   ( i_data5              ),
    .o_full                  ( w_data_fifo5_full    ),
    .i_rd_en                 ( r_data_fifo5_rd_en   ),
    .o_dout                  ( w_data_fifo5_rd_data ),
    .o_empty                 ( w_data_fifo5_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri5_fifo_info_inst (       
    .i_clk                   ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo5_data_vld          ),
    .i_din                   ( {15'd0,ri_info_fifo5_data_keep,ri_info_fifo5_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo5_rd_en             ),
    .o_dout                  ( { w_info_fifo5_keep,w_info_fifo5_datalen } ),
    .o_empty                 ( w_info_fifo5_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri5_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo5_vld                   ),
    .i_din                  ( w_c_fifo5_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo5_full                  ),
    .i_rd_en                 ( r_c_fifo5_rd_en                 ),
    .o_dout                  ( w_c_fifo5_rd_data               ),
    .o_empty                 ( w_c_fifo5_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo6 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri6_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data6_vld          ),
    .i_din                   ( i_data6              ),
    .o_full                  ( w_data_fifo6_full    ),
    .i_rd_en                 ( r_data_fifo6_rd_en   ),
    .o_dout                  ( w_data_fifo6_rd_data ),
    .o_empty                 ( w_data_fifo6_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri6_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo6_data_vld          ),
    .i_din                   ( { ri_info_fifo6_data_keep,ri_info_fifo6_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo6_rd_en             ),
    .o_dout                  ( { w_info_fifo6_keep,w_info_fifo6_datalen } ),
    .o_empty                 ( w_info_fifo6_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri6_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo6_vld                   ),
    .i_din                  ( w_c_fifo6_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo6_full                  ),
    .i_rd_en                 ( r_c_fifo6_rd_en                 ),
    .o_dout                  ( w_c_fifo6_rd_data               ),
    .o_empty                 ( w_c_fifo6_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

// ------ fifo7 -------
sync_fifo #(
    .DEPTH                    ( 16384              ),
    .WIDTH                   ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD   (      ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
    .FLOP_DATA_OUT           ( 1'b0 ),
    .RAM_STYLE               ( 1'b1 )
) pri7_fifo_inst (       
    .i_clk                    ( i_clk                ),
    .i_rst                   ( i_rst                ),
    .i_wr_en                 ( i_data7_vld          ),
    .i_din                   ( i_data7              ),
    .o_full                  ( w_data_fifo7_full    ),
    .i_rd_en                 ( r_data_fifo7_rd_en   ),
    .o_dout                  ( w_data_fifo7_rd_data ),
    .o_empty                 ( w_data_fifo7_empty   ),
    .o_almost_full           ( ),
    .o_almost_empty          ( ),
    .o_data_cnt              (  )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 32       ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri7_fifo_info_inst (       
    .i_clk                    ( i_clk                          ),
    .i_rst                   ( i_rst                          ),
    .i_wr_en                 ( r_info_fifo7_data_vld          ),
    .i_din                   ( { ri_info_fifo7_data_keep,ri_info_fifo7_data_cnt } ),
    .o_full                  (                                ),
    .i_rd_en                 ( r_info_fifo7_rd_en             ),
    .o_dout                  ( { w_info_fifo7_keep,w_info_fifo7_datalen } ),
    .o_empty                 ( w_info_fifo7_empty             ),
    .o_almost_full           (                                ),
    .o_almost_empty          (                                ),
    .o_data_cnt              (                                )
);

sync_fifo #(
    .DEPTH                    ( 64       ),
    .WIDTH                   ( 16        ),
    .ALMOST_FULL_THRESHOLD   (          ),
    .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
    .FLOP_DATA_OUT           ( 1'b0     ),
    .RAM_STYLE               ( 1'b0     )
) pri7_fifoc_inst (       
    .i_clk                    ( i_clk                            ),
    .i_rst                   ( i_rst                            ),
    .i_wr_en                 ( r_c_fifo7_vld                   ),
    .i_din                   ( w_c_fifo7_wr_data                    ), //{ r_c_fifo0_qbu_flag,r_c_fifo0_qos }
    .o_full                  ( w_c_fifo7_full                  ),
    .i_rd_en                 ( r_c_fifo7_rd_en                 ),
    .o_dout                  ( w_c_fifo7_rd_data               ),
    .o_empty                 ( w_c_fifo7_empty                 ),
    .o_almost_full           (                                  ),
    .o_almost_empty          (                                  ),
    .o_data_cnt              (                                  )
);

endmodule