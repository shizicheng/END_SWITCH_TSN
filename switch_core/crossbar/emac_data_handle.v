`include "synth_cmd_define.vh"

module emac_data_handle#(
    parameter                      PORT_ATTRIBUTE          =      0        ,
    parameter                      REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                      REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位宽
    parameter                      METADATA_WIDTH          =      81       ,  // 信息流（METADATA）的位宽
    parameter                      PORT_MNG_DATA_WIDTH     =      8        ,
    parameter                      PORT_FIFO_PRI_NUM       =      8        , 
    parameter                      CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    input                                                       i_clk                           ,
    input                                                       i_rst                           ,
/********************************rx port*********************************************/
    //rxmac0通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac0_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac0_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac0_qbu_axis_user              , 
    input          wire                                         i_rxmac0_qbu_axis_valid             , 
    output         wire                                         o_rxmac0_qbu_axis_ready             ,
    input          wire                                         i_rxmac0_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac0_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac0_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac0_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac0_qbu_metadata_ready         , // 下游模块反压流水线   

    //rxmac1通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac1_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac1_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac1_qbu_axis_user              , 
    input          wire                                         i_rxmac1_qbu_axis_valid             , 
    output         wire                                         o_rxmac1_qbu_axis_ready             ,
    input          wire                                         i_rxmac1_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac1_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac1_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac1_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac1_qbu_metadata_ready         , // 下游模块反压流水线   
    
    //rxmac2通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac2_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac2_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac2_qbu_axis_user              , 
    input          wire                                         i_rxmac2_qbu_axis_valid             , 
    output         wire                                         o_rxmac2_qbu_axis_ready             ,
    input          wire                                         i_rxmac2_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac2_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac2_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac2_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac2_qbu_metadata_ready         , // 下游模块反压流水线   
    //rxmac3通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac3_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac3_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac3_qbu_axis_user              , 
    input          wire                                         i_rxmac3_qbu_axis_valid             , 
    output         wire                                         o_rxmac3_qbu_axis_ready             ,
    input          wire                                         i_rxmac3_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac3_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac3_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac3_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac3_qbu_metadata_ready         , // 下游模块反压流水线   
    //rxmac4通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac4_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac4_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac4_qbu_axis_user              , 
    input          wire                                         i_rxmac4_qbu_axis_valid             , 
    output         wire                                         o_rxmac4_qbu_axis_ready             ,
    input          wire                                         i_rxmac4_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac4_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac4_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac4_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac4_qbu_metadata_ready         , // 下游模块反压流水线   
    
    //rxmac5通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac5_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac5_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac5_qbu_axis_user              , 
    input          wire                                         i_rxmac5_qbu_axis_valid             , 
    output         wire                                         o_rxmac5_qbu_axis_ready             ,
    input          wire                                         i_rxmac5_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac5_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac5_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac5_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac5_qbu_metadata_ready         , // 下游模块反压流水线   

    //rxmac6通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac6_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac6_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac6_qbu_axis_user              , 
    input          wire                                         i_rxmac6_qbu_axis_valid             , 
    output         wire                                         o_rxmac6_qbu_axis_ready             ,
    input          wire                                         i_rxmac6_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac6_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac6_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac6_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac6_qbu_metadata_ready         , // 下游模块反压流水线   

    //rxmac7通道关键帧数据              
    input          wire    [CROSS_DATA_WIDTH - 1:0]             i_rxmac7_qbu_axis_data              , 
    input          wire    [(CROSS_DATA_WIDTH/8)-1:0]           i_rxmac7_qbu_axis_keep              , 
    input          wire    [15:0]                               i_rxmac7_qbu_axis_user              , 
    input          wire                                         i_rxmac7_qbu_axis_valid             , 
    output         wire                                         o_rxmac7_qbu_axis_ready             ,
    input          wire                                         i_rxmac7_qbu_axis_last              , 
 
    input          wire   [METADATA_WIDTH-1:0]                  i_rxmac7_qbu_metadata               , // 总线 metadata 数据
    input          wire                                         i_rxmac7_qbu_metadata_valid         , // 总线 metadata 数据有效信号
    input          wire                                         i_rxmac7_qbu_metadata_last          , // 信息流结束标识
    output         wire                                         o_rxmac7_qbu_metadata_ready         , // 下游模块反压流水线


/********************************tx port*********************************************/
    //emac通道数据              
    output          wire    [CROSS_DATA_WIDTH - 1:0]            o_emac0_tx_axis_data                , 
    output          wire    [15:0]                              o_emac0_tx_axis_user                , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]          o_emac0_tx_axis_keep                , 
    output          wire                                        o_emac0_tx_axis_last                , 
    output          wire                                        o_emac0_tx_axis_valid               , 
    input           wire                                        i_emac0_tx_axis_ready               

);  


//**********************wire******************************************

wire [7:0]                      w_all_metadata_valid;
wire [7:0]                      w_all_tx_port [7:0];

//**********************reg******************************************

reg   [CROSS_DATA_WIDTH:0]             ri_emac_cross_port_axi_data [PORT_FIFO_PRI_NUM-1:0]   ;
reg   [15:0]                           ri_emac_cross_axi_data_user [PORT_FIFO_PRI_NUM-1:0]   ;
reg   [(CROSS_DATA_WIDTH/8)-1:0]       ri_emac_cross_axi_data_keep [PORT_FIFO_PRI_NUM-1:0]   ;
reg                                    ri_emac_cross_axi_data_valid[PORT_FIFO_PRI_NUM-1:0]   ;
reg                                    ri_emac_cross_axi_data_last [PORT_FIFO_PRI_NUM-1:0]   ;

reg   [CROSS_DATA_WIDTH:0]             rri_emac_cross_port_axi_data [PORT_FIFO_PRI_NUM-1:0]   ;
reg   [15:0]                           rri_emac_cross_axi_data_user [PORT_FIFO_PRI_NUM-1:0]   ;
reg   [(CROSS_DATA_WIDTH/8)-1:0]       rri_emac_cross_axi_data_keep [PORT_FIFO_PRI_NUM-1:0]   ;
reg                                    rri_emac_cross_axi_data_valid[PORT_FIFO_PRI_NUM-1:0]   ;
reg                                    rri_emac_cross_axi_data_last [PORT_FIFO_PRI_NUM-1:0]   ;

reg                                    ro_emac_cross_axi_data_ready [PORT_FIFO_PRI_NUM-1:0]   ;


reg       [METADATA_WIDTH-1:0]         ri_emac_cross_metadata       [PORT_FIFO_PRI_NUM-1:0]     ;    
reg       [METADATA_WIDTH-1:0]         ri_emac_cross_metadata_valid [PORT_FIFO_PRI_NUM-1:0]     ; 
reg       [METADATA_WIDTH-1:0]         ri_emac_cross_metadata_last  [PORT_FIFO_PRI_NUM-1:0]     ;  

reg     [CROSS_DATA_WIDTH - 1:0]       ro_emac_tx_axis_data ;
reg     [15:0]                         ro_emac_tx_axis_user ;
reg     [(CROSS_DATA_WIDTH/8)-1:0]     ro_emac_tx_axis_keep ;
reg                                    ro_emac_tx_axis_last ;
reg                                    ro_emac_tx_axis_valid;

reg                                    r_frame_flag  [PORT_FIFO_PRI_NUM-1:0]   ;      

//******************************ASSIGN********************************
assign w_all_metadata_valid = {i_rxmac7_qbu_metadata_valid,i_rxmac6_qbu_metadata_valid,i_rxmac5_qbu_metadata_valid,
                                i_rxmac4_qbu_metadata_valid,i_rxmac3_qbu_metadata_valid,i_rxmac2_qbu_metadata_valid,
                                i_rxmac1_qbu_metadata_valid,i_rxmac0_qbu_metadata_valid};


assign w_all_tx_port[0] =  i_rxmac0_qbu_metadata[59:52];
assign w_all_tx_port[1] =  i_rxmac1_qbu_metadata[59:52];
assign w_all_tx_port[2] =  i_rxmac2_qbu_metadata[59:52];
assign w_all_tx_port[3] =  i_rxmac3_qbu_metadata[59:52];
assign w_all_tx_port[4] =  i_rxmac4_qbu_metadata[59:52];                               
assign w_all_tx_port[5] =  i_rxmac5_qbu_metadata[59:52];
assign w_all_tx_port[6] =  i_rxmac6_qbu_metadata[59:52];
assign w_all_tx_port[7] =  i_rxmac7_qbu_metadata[59:52];

//EMAC0
assign     o_rxmac0_qbu_axis_ready      =   1'b1;    
assign     o_rxmac0_qbu_metadata_ready  =   1'b1;
assign     o_emac0_tx_axis_data         =   ro_emac_tx_axis_data   ;   
assign     o_emac0_tx_axis_user         =   ro_emac_tx_axis_user   ;   
assign     o_emac0_tx_axis_keep         =   ro_emac_tx_axis_keep   ;   
assign     o_emac0_tx_axis_last         =   ro_emac_tx_axis_last   ;   
assign     o_emac0_tx_axis_valid        =   ro_emac_tx_axis_valid  ; 

// emac1
assign     o_rxmac1_qbu_axis_ready      =   1'b1;//ro_rxmac1_qbu_axis_ready    ;
assign     o_rxmac1_qbu_metadata_ready  =   1'b1;//ro_rxmac1_qbu_metadata_ready;
//
// emac2//
assign     o_rxmac2_qbu_axis_ready      =   1'b1;//ro_rxmac2_qbu_axis_ready    ;
assign     o_rxmac2_qbu_metadata_ready  =   1'b1;//ro_rxmac2_qbu_metadata_ready;
//
// emac3//
assign     o_rxmac3_qbu_axis_ready      =   1'b1;//ro_rxmac3_qbu_axis_ready    ;
assign     o_rxmac3_qbu_metadata_ready  =   1'b1;//ro_rxmac3_qbu_metadata_ready;
//
// emac4//
assign     o_rxmac4_qbu_axis_ready      =   1'b1;//ro_rxmac4_qbu_axis_ready    ;
assign     o_rxmac4_qbu_metadata_ready  =   1'b1;//ro_rxmac4_qbu_metadata_ready;
//
// emac5//
assign     o_rxmac5_qbu_axis_ready      =   1'b1;//ro_rxmac5_qbu_axis_ready    ;
assign     o_rxmac5_qbu_metadata_ready  =   1'b1;//ro_rxmac5_qbu_metadata_ready;
//
// emac6//
assign     o_rxmac6_qbu_axis_ready      =   1'b1;//ro_rxmac6_qbu_axis_ready    ;
assign     o_rxmac6_qbu_metadata_ready  =   1'b1;//ro_rxmac6_qbu_metadata_ready;
//
// emac7//
assign     o_rxmac7_qbu_axis_ready      =   1'b1;//ro_rxmac7_qbu_axis_ready    ;
assign     o_rxmac7_qbu_metadata_ready  =   1'b1;//ro_rxmac7_qbu_metadata_ready;





/************************************input**********************************/
/************************************input**********************************/
/************************************input**********************************/
genvar i;
generate
    for (i = 0; i < 8; i = i +1) begin
        if (i == 0) begin
            `ifdef CPU_MAC
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data [i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user [i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep [i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last [i]       <=  1'b0;
                        
                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;                      
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac0_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac0_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac0_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac0_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac0_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;

                        ri_emac_cross_metadata[i]           <=  i_rxmac0_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac0_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac0_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i == 1) begin
            `ifdef MAC1
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac1_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac1_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac1_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac1_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac1_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;    

                        ri_emac_cross_metadata[i]           <=  i_rxmac1_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac1_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac1_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i == 2) begin
            `ifdef MAC2
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac2_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac2_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac2_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac2_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac2_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;

                        ri_emac_cross_metadata[i]           <=  i_rxmac2_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac2_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac2_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i==3) begin
            `ifdef MAC3
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac3_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac3_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac3_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac3_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac3_qbu_axis_last  ;


                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;

                        ri_emac_cross_metadata[i]           <=  i_rxmac3_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac3_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac3_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i==4) begin
            `ifdef MAC4
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac4_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac4_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac4_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac4_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac4_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;

                        ri_emac_cross_metadata[i]           <=  i_rxmac4_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac4_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac4_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i==5) begin
            `ifdef MAC5
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;
                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac5_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac5_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac5_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac5_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac5_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;

                        ri_emac_cross_metadata[i]           <=  i_rxmac5_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac5_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac5_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i==6) begin
            `ifdef MAC6
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;

                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac6_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac6_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac6_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac6_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac6_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;  

                        ri_emac_cross_metadata[i]           <=  i_rxmac6_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac6_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac6_qbu_metadata_last  ;
                    end
                end
            `endif
        end
        else if (i==7) begin
            `ifdef MAC7
                // 输入寄存器打拍，CROSS交换平面数据流扇出过大，插入寄存器进行隔离
                always @(posedge i_clk or posedge i_rst) begin
                    if (i_rst == 1'b1) begin
                        ri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        ri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        ri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        ri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        ri_emac_cross_axi_data_last[i]       <=  1'b0;
                        ri_emac_cross_metadata[i]            <=  {METADATA_WIDTH{1'b0}};

                        rri_emac_cross_port_axi_data[i]       <=  {(CROSS_DATA_WIDTH + 1){1'b0}};
                        rri_emac_cross_axi_data_user[i]       <=  {16{1'b0}};
                        rri_emac_cross_axi_data_keep[i]       <=  {(CROSS_DATA_WIDTH/8){1'b0}};
                        rri_emac_cross_axi_data_valid[i]      <=  1'b0;
                        rri_emac_cross_axi_data_last[i]       <=  1'b0;
                        
                        ri_emac_cross_metadata_valid[i]      <=  1'b0;
                        ri_emac_cross_metadata_last[i]       <=  1'b0;
                    end else begin
                        ri_emac_cross_port_axi_data[i]      <=  i_rxmac7_qbu_axis_data  ;
                        ri_emac_cross_axi_data_keep[i]      <=  i_rxmac7_qbu_axis_keep  ;
                        ri_emac_cross_axi_data_user[i]      <=  i_rxmac7_qbu_axis_user  ;
                        ri_emac_cross_axi_data_valid[i]     <=  i_rxmac7_qbu_axis_valid ;
                        ri_emac_cross_axi_data_last[i]      <=  i_rxmac7_qbu_axis_last  ;

                        rri_emac_cross_port_axi_data[i]       <=  ri_emac_cross_port_axi_data[i] ;
                        rri_emac_cross_axi_data_user[i]       <=  ri_emac_cross_axi_data_user[i] ;
                        rri_emac_cross_axi_data_keep[i]       <=  ri_emac_cross_axi_data_keep[i] ;
                        rri_emac_cross_axi_data_valid[i]      <=  ri_emac_cross_axi_data_valid[i];
                        rri_emac_cross_axi_data_last[i]       <=  ri_emac_cross_axi_data_last[i] ;                       

                        ri_emac_cross_metadata[i]           <=  i_rxmac7_qbu_metadata       ;
                        ri_emac_cross_metadata_valid[i]     <=  i_rxmac7_qbu_metadata_valid ;
                        ri_emac_cross_metadata_last[i]      <=  i_rxmac7_qbu_metadata_last  ;
                    end
                end
            `endif
        end

        // 从锁存 tx_prot 信息中判断该帧是否是该 cross_bar_tx_port 处理
         always @(posedge i_clk or posedge i_rst) begin
             if (i_rst == 1'b1) begin
                 r_frame_flag[i] <= 1'b0;
             end else begin
                 r_frame_flag[i] <= ( ro_emac_tx_axis_last == 1'b1) ? 1'b0 : ( w_all_metadata_valid[i] == 1'b1 && w_all_tx_port[i][PORT_ATTRIBUTE] == 1'b1 ) ? 1'b1 : r_frame_flag[i];
             end                   
         end
    end

endgenerate


/************************************handle**********************************/
/************************************handle**********************************/
/************************************handle**********************************/
    //判断是否当前tx端口的数据
    // generate
    //     for (i = 0; i < PORT_FIFO_PRI_NUM; i = i + 1) begin
                // 从锁存 tx_prot 信息中判断该帧是否是该 cross_bar_tx_port 处理
                // always @(posedge i_clk or posedge i_rst) begin
                //     if (i_rst == 1'b1) begin
                //         r_frame_flag[i] <= 1'b0;
                //     end else begin
                //         r_frame_flag[i] <= ( ro_emac_tx_axis_last == 1'b1) ? 1'b0 : ( w_all_metadata_valid[i] == 1'b1 && w_all_tx_port[i][PORT_ATTRIBUTE] == 1'b1 ) ? 1'b1 : r_frame_flag[i];
                //     end                   
                // end
    //     end 
    // endgenerate


/************************************output**********************************/
/************************************output**********************************/
/************************************output**********************************/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst == 1'b1) begin
        ro_emac_tx_axis_data     <=  {CROSS_DATA_WIDTH{1'b0}};
        ro_emac_tx_axis_user     <=  16'd0;
        ro_emac_tx_axis_keep     <=  16'd0;
        ro_emac_tx_axis_last     <=  1'b0;
        ro_emac_tx_axis_valid    <=  1'b0;
    end else begin
        ro_emac_tx_axis_data     <=  ( r_frame_flag[0] == 1'b1 ) ? rri_emac_cross_port_axi_data[0] :
                                     ( r_frame_flag[1] == 1'b1 ) ? rri_emac_cross_port_axi_data[1] : 
                                     ( r_frame_flag[2] == 1'b1 ) ? rri_emac_cross_port_axi_data[2] : 
                                     ( r_frame_flag[3] == 1'b1 ) ? rri_emac_cross_port_axi_data[3] : 
                                     ( r_frame_flag[4] == 1'b1 ) ? rri_emac_cross_port_axi_data[4] : 
                                     ( r_frame_flag[5] == 1'b1 ) ? rri_emac_cross_port_axi_data[5] : 
                                     ( r_frame_flag[6] == 1'b1 ) ? rri_emac_cross_port_axi_data[6] : 
                                     ( r_frame_flag[7] == 1'b1 ) ? rri_emac_cross_port_axi_data[7] : {CROSS_DATA_WIDTH{1'b0}};

        ro_emac_tx_axis_user     <=  ( r_frame_flag[0] == 1'b1 ) ? rri_emac_cross_axi_data_user[0] :
                                     ( r_frame_flag[1] == 1'b1 ) ? rri_emac_cross_axi_data_user[1] : 
                                     ( r_frame_flag[2] == 1'b1 ) ? rri_emac_cross_axi_data_user[2] : 
                                     ( r_frame_flag[3] == 1'b1 ) ? rri_emac_cross_axi_data_user[3] : 
                                     ( r_frame_flag[4] == 1'b1 ) ? rri_emac_cross_axi_data_user[4] : 
                                     ( r_frame_flag[5] == 1'b1 ) ? rri_emac_cross_axi_data_user[5] : 
                                     ( r_frame_flag[6] == 1'b1 ) ? rri_emac_cross_axi_data_user[6] : 
                                     ( r_frame_flag[7] == 1'b1 ) ? rri_emac_cross_axi_data_user[7] : 16'd0;

        ro_emac_tx_axis_keep     <=  ( r_frame_flag[0] == 1'b1 ) ? rri_emac_cross_axi_data_keep[0] :
                                     ( r_frame_flag[1] == 1'b1 ) ? rri_emac_cross_axi_data_keep[1] : 
                                     ( r_frame_flag[2] == 1'b1 ) ? rri_emac_cross_axi_data_keep[2] : 
                                     ( r_frame_flag[3] == 1'b1 ) ? rri_emac_cross_axi_data_keep[3] : 
                                     ( r_frame_flag[4] == 1'b1 ) ? rri_emac_cross_axi_data_keep[4] : 
                                     ( r_frame_flag[5] == 1'b1 ) ? rri_emac_cross_axi_data_keep[5] : 
                                     ( r_frame_flag[6] == 1'b1 ) ? rri_emac_cross_axi_data_keep[6] : 
                                     ( r_frame_flag[7] == 1'b1 ) ? rri_emac_cross_axi_data_keep[7] : 16'd0;

        ro_emac_tx_axis_last     <=  ( r_frame_flag[0] == 1'b1 ) ? rri_emac_cross_axi_data_last[0] :
                                     ( r_frame_flag[1] == 1'b1 ) ? rri_emac_cross_axi_data_last[1] : 
                                     ( r_frame_flag[2] == 1'b1 ) ? rri_emac_cross_axi_data_last[2] : 
                                     ( r_frame_flag[3] == 1'b1 ) ? rri_emac_cross_axi_data_last[3] : 
                                     ( r_frame_flag[4] == 1'b1 ) ? rri_emac_cross_axi_data_last[4] : 
                                     ( r_frame_flag[5] == 1'b1 ) ? rri_emac_cross_axi_data_last[5] : 
                                     ( r_frame_flag[6] == 1'b1 ) ? rri_emac_cross_axi_data_last[6] : 
                                     ( r_frame_flag[7] == 1'b1 ) ? rri_emac_cross_axi_data_last[7] : 1'b0;

        ro_emac_tx_axis_valid    <=  ( r_frame_flag[0] == 1'b1 ) ? rri_emac_cross_axi_data_valid[0] :
                                     ( r_frame_flag[1] == 1'b1 ) ? rri_emac_cross_axi_data_valid[1] : 
                                     ( r_frame_flag[2] == 1'b1 ) ? rri_emac_cross_axi_data_valid[2] : 
                                     ( r_frame_flag[3] == 1'b1 ) ? rri_emac_cross_axi_data_valid[3] : 
                                     ( r_frame_flag[4] == 1'b1 ) ? rri_emac_cross_axi_data_valid[4] : 
                                     ( r_frame_flag[5] == 1'b1 ) ? rri_emac_cross_axi_data_valid[5] : 
                                     ( r_frame_flag[6] == 1'b1 ) ? rri_emac_cross_axi_data_valid[6] : 
                                     ( r_frame_flag[7] == 1'b1 ) ? rri_emac_cross_axi_data_valid[7] : 1'b0; 
    
    end
end

endmodule