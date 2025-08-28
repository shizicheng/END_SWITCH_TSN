`include "synth_cmd_define.vh"

module cross_data_cache #(
    parameter       PORT_MNG_DATA_WIDTH     =      8        ,
    parameter       PORT_FIFO_PRI_NUM       =      8        ,
    parameter       FIFOC_WIDTH             =      12       ,
    parameter       CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // 聚合总线输出 
)(
    // sys interface
    input           wire                               i_clk                    ,
    input           wire                               i_rst                    ,
    // 寄存器配置信息       
    input           wire                               i_forward_mode           , // 0-存储转发；1-直通转发 
    // data stream pri interface        
    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri0              ,
    input           wire                               i_data_pri0_vld          ,
    // [11](1bit) : 是否为关键帧(Qbu); [10:0](11bit) ：data_len，数据长度信息 
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri0         , 
    input           wire                               i_meta_data_pri0_vld     , 
    output          wire                               o_data_pri0_ready        ,
    input           wire                               i_data0_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri1              ,     
    input           wire                               i_data_pri1_vld          ,
    
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri1         , 
    input           wire                               i_meta_data_pri1_vld     , 
    output          wire                               o_data_pri1_ready        ,
    input           wire                               i_data1_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri2              ,
    input           wire                               i_data_pri2_vld          ,

    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri2         , 
    input           wire                               i_meta_data_pri2_vld     , 
    output          wire                               o_data_pri2_ready        ,
    input           wire                               i_data2_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri3              ,
    input           wire                               i_data_pri3_vld          ,

    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri3         , 
    input           wire                               i_meta_data_pri3_vld     , 
    output          wire                               o_data_pri3_ready        ,
    input           wire                               i_data3_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri4              ,
    input           wire                               i_data_pri4_vld          ,
    
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri4         , 
    input           wire                               i_meta_data_pri4_vld     , 
    output          wire                               o_data_pri4_ready        ,
    input           wire                               i_data4_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri5              ,
    input           wire                               i_data_pri5_vld          ,
    
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri5         , 
    input           wire                               i_meta_data_pri5_vld     , 
    output          wire                               o_data_pri5_ready        ,
    input           wire                               i_data5_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri6              ,
    input           wire                               i_data_pri6_vld          ,
    
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri6         , 
    input           wire                               i_meta_data_pri6_vld     , 
    output          wire                               o_data_pri6_ready        ,
    input           wire                               i_data6_qbu_flag         ,

    input           wire    [CROSS_DATA_WIDTH-1:0]     i_data_pri7              ,
    input           wire                               i_data_pri7_vld          ,
    
    input           wire    [FIFOC_WIDTH-1:0]          i_meta_data_pri7         , 
    input           wire                               i_meta_data_pri7_vld     , 
    output          wire                               o_data_pri7_ready        ,
    input           wire                               i_data7_qbu_flag         ,
    // 与调度流水线交互接口
    output          wire   [PORT_FIFO_PRI_NUM:0]       o_mac_fifoc_empty       ,   
    input           wire   [PORT_FIFO_PRI_NUM:0]       i_mac_scheduing_rst     ,
    input           wire                               i_mac_scheduing_rst_vld ,
    /*-------------------- TXMAC 输出数据流 -----------------------*/
    //pmac通道数据
    output          wire    [CROSS_DATA_WIDTH - 1:0]   o_pmac_tx_axis_data   , 
    output          wire    [15:0]                     o_pmac_tx_axis_user   , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0] o_pmac_tx_axis_keep   , 
    output          wire                               o_pmac_tx_axis_last   , 
    output          wire                               o_pmac_tx_axis_valid  , 
    output          wire    [15:0]                     o_pmac_ethertype      , 
    input           wire                               i_pmac_tx_axis_ready  ,
    //emac通道数据               
    output          wire    [CROSS_DATA_WIDTH - 1:0]   o_emac_tx_axis_data   , 
    output          wire    [15:0]                     o_emac_tx_axis_user   , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0] o_emac_tx_axis_keep   , 
    output          wire                               o_emac_tx_axis_last   , 
    output          wire                               o_emac_tx_axis_valid  , 
    output          wire    [15:0]                     o_emac_ethertype      ,
    input           wire                               i_emac_tx_axis_ready  
);

/*--------- wire -------*/
wire                        w_fifo_pri0_full     ;
wire                        w_fifo_pri0_empty    ;
wire                        w_fifoc_pri0_full    ;
wire                        w_fifoc_pri0_empty   ;

wire                        w_fifo_pri1_full     ;
wire                        w_fifo_pri1_empty    ;
wire                        w_fifoc_pri1_full    ;
wire                        w_fifoc_pri1_empty   ;

wire                        w_fifo_pri2_full     ;
wire                        w_fifo_pri2_empty    ;
wire                        w_fifoc_pri2_full    ;
wire                        w_fifoc_pri2_empty   ;

wire                        w_fifo_pri3_full     ;
wire                        w_fifo_pri3_empty    ;
wire                        w_fifoc_pri3_full    ;
wire                        w_fifoc_pri3_empty   ;

wire                        w_fifo_pri4_full     ;
wire                        w_fifo_pri4_empty    ;
wire                        w_fifoc_pri4_full    ;
wire                        w_fifoc_pri4_empty   ;

wire                        w_fifo_pri5_full     ;
wire                        w_fifo_pri5_empty    ;
wire                        w_fifoc_pri5_full    ;
wire                        w_fifoc_pri5_empty   ;

wire                        w_fifo_pri6_full     ;
wire                        w_fifo_pri6_empty    ;
wire                        w_fifoc_pri6_full    ;
wire                        w_fifoc_pri6_empty   ;

wire                        w_fifo_pri7_full     ;
wire                        w_fifo_pri7_empty    ;
wire                        w_fifoc_pri7_full    ;
wire                        w_fifoc_pri7_empty   ;

/*--------- reg -------*/
reg                         r_data_pri0_ready    ;
reg                         r_data_pri1_ready    ;
reg                         r_data_pri2_ready    ;
reg                         r_data_pri3_ready    ;
reg                         r_data_pri4_ready    ;
reg                         r_data_pri5_ready    ;
reg                         r_data_pri6_ready    ;
reg                         r_data_pri7_ready    ;

/*--------- always -------*/

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri0_ready <= 1'b0;
    end 
    else begin
        r_data_pri0_ready <= ~w_fifo_pri0_full | ~w_fifoc_pri0_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri1_ready <= 1'b0;
    end 
    else begin
        r_data_pri1_ready <= ~w_fifo_pri1_full | ~w_fifoc_pri1_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri2_ready <= 1'b0;
    end 
    else begin
        r_data_pri2_ready <= ~w_fifo_pri2_full | ~w_fifoc_pri2_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri3_ready <= 1'b0;
    end 
    else begin
        r_data_pri3_ready <= ~w_fifo_pri3_full | ~w_fifoc_pri3_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri4_ready <= 1'b0;
    end 
    else begin
        r_data_pri4_ready <= ~w_fifo_pri4_full | ~w_fifoc_pri4_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri5_ready <= 1'b0;
    end 
    else begin
        r_data_pri5_ready <= ~w_fifo_pri5_full | ~w_fifoc_pri5_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri6_ready <= 1'b0;
    end 
    else begin
        r_data_pri6_ready <= ~w_fifo_pri6_full | ~w_fifoc_pri6_full;
    end
end

always @(posedge i_clk) begin
    if (i_rst == 1'b1) begin
        r_data_pri7_ready <= 1'b0;
    end 
    else begin
        r_data_pri7_ready <= ~w_fifo_pri7_full | ~w_fifoc_pri7_full;
    end
end

/*--------- inst ----------*/
sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri0_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri0_vld   ) ,
    .i_din                    ( i_data_pri0       ) ,
    .o_full                   ( w_fifo_pri0_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri0_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH     ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri0_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri0      ) ,
    .i_din                    ( i_meta_data_pri0_vld  ) ,
    .o_full                   ( w_fifoc_pri0_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri0_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri1_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri1_vld   ) ,
    .i_din                    ( i_data_pri1       ) ,
    .o_full                   ( w_fifo_pri1_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri1_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri1_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri1      ) ,
    .i_din                    ( i_meta_data_pri1_vld  ) ,
    .o_full                   ( w_fifoc_pri1_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri1_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri2_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri2_vld   ) ,
    .i_din                    ( i_data_pri2       ) ,
    .o_full                   ( w_fifo_pri2_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri2_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri2_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri2      ) ,
    .i_din                    ( i_meta_data_pri2_vld  ) ,
    .o_full                   ( w_fifoc_pri1_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri2_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri3_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri3_vld   ) ,
    .i_din                    ( i_data_pri3       ) ,
    .o_full                   ( w_fifo_pri3_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri3_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri3_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri3      ) ,
    .i_din                    ( i_meta_data_pri3_vld  ) ,
    .o_full                   ( w_fifoc_pri1_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri3_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri4_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri4_vld   ) ,
    .i_din                    ( i_data_pri4       ) ,
    .o_full                   ( w_fifo_pri4_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri4_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri4_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri4      ) ,
    .i_din                    ( i_meta_data_pri4_vld  ) ,
    .o_full                   ( w_fifoc_pri4_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri4_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri5_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri5_vld   ) ,
    .i_din                    ( i_data_pri5       ) ,
    .o_full                   ( w_fifo_pri5_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri5_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri5_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri5      ) ,
    .i_din                    ( i_meta_data_pri5_vld  ) ,
    .o_full                   ( w_fifoc_pri5_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri5_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri6_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri6_vld   ) ,
    .i_din                    ( i_data_pri6       ) ,
    .o_full                   ( w_fifo_pri6_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri6_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri6_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri6      ) ,
    .i_din                    ( i_meta_data_pri6_vld  ) ,
    .o_full                   ( w_fifoc_pri6_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri6_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFO_PRI_DEPTH ),
    .WIDTH                  ( CROSS_DATA_WIDTH ),
    .ALMOST_FULL_THRESHOLD  ( FIFO_PRI_DEPTH - 'd5 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b1 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) data_pri7_fifo_inst (       
    .i_clk                    ( i_clk             ) ,
    .i_rst                    ( i_rst             ) ,
    .i_wr_en                  ( i_data_pri7_vld   ) ,
    .i_din                    ( i_data_pri7       ) ,
    .o_full                   ( w_fifo_pri7_full  ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifo_pri7_empty ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

sync_fifo #(
    .DEPTH                  ( FIFOC_PRI_DEPTH ),
    .WIDTH                  ( FIFOC_WIDTH   ),
    .ALMOST_FULL_THRESHOLD  ( 'd32 - 'd1 ),
    .ALMOST_EMPTY_THRESHOLD ( 'd1 ),
    .FLOP_DATA_OUT          ( 1'b1 ), //是否开启fwft
    .RAM_STYLE              ( 1'b0 ) // RAM综合类型选择：
                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
) metadata_pri7_fifo_inst (       
    .i_clk                    ( i_clk                 ) ,
    .i_rst                    ( i_rst                 ) ,
    .i_wr_en                  ( i_meta_data_pri7      ) ,
    .i_din                    ( i_meta_data_pri7_vld  ) ,
    .o_full                   ( w_fifoc_pri7_full     ) ,
    .i_rd_en                  ( ) ,
    .o_dout                   ( ) ,
    .o_empty                  ( w_fifoc_pri7_empty    ) ,
    .o_almost_full            ( ) ,
    .o_almost_empty           ( ) ,
    .o_data_cnt               ( )
);

endmodule