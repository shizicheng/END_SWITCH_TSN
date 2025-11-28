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
    output          wire    [CROSS_DATA_WIDTH - 1:0]       o_emac_tx_axis_data      , 
    output          wire    [15:0]                         o_emac_tx_axis_user      , 
    output          wire    [(CROSS_DATA_WIDTH/8)-1:0]     o_emac_tx_axis_keep      , 
    output          wire                                   o_emac_tx_axis_last      , 
    output          wire                                   o_emac_tx_axis_valid     , 
    input           wire                                   i_emac_tx_axis_ready      
);

// ========================== 信号声明 - 使用数组 ==========================
// 输入信号数组
wire [CROSS_DATA_WIDTH-1:0]         i_data [7:0];
wire [CROSS_DATA_WIDTH/8-1:0]       i_data_keep [7:0];
wire [15:0]                         i_data_user [7:0];
wire                                i_data_vld [7:0];
wire                                i_data_last [7:0];
wire [METADATA_WIDTH-1:0]           i_meta_data_pri [7:0];
wire                                i_meta_data_pri_vld [7:0];

// 输出信号数组
wire                                o_data_ready [7:0];
wire                                o_data_busy [7:0];

// fifo_data 相关信号
wire                                w_data_fifo_full [7:0];
wire                                w_data_fifo_empty [7:0];
reg                                 r_data_fifo_rd_en [7:0];
wire [CROSS_DATA_WIDTH-1:0]         w_data_fifo_rd_data [7:0];

// fifo_info 相关信号
wire                                w_info_fifo_empty [7:0];
wire [15:0]                         w_info_fifo_datalen [7:0];
wire [15:0]                         w_info_fifo_keep [7:0];
reg  [CROSS_DATA_WIDTH-1:0]         r_data [7:0];
reg                                 r_info_fifo_data_vld [7:0];
reg [CROSS_DATA_WIDTH/8-1:0]        ri_info_fifo_data_keep [7:0];
reg [15:0]                          ri_info_fifo_data_cnt [7:0];
reg                                 r_info_fifo_rd_pre [7:0];
reg                                 r_info_fifo_rd_pre2 [7:0];
reg                                 r_info_fifo_rd_en [7:0];

// fifoc 相关信号
reg                                 r_c_fifo_qbu_flag [7:0];
reg [3:0]                           r_c_fifo_qos [7:0];
reg [15:0]                          w_c_fifo_wr_data [7:0];
reg                                 r_c_fifo_vld [7:0];
reg                                 r_c_fifo_rd_en [7:0];
wire [15:0]                         w_c_fifo_rd_data [7:0];
wire                                w_c_fifo_full [7:0];
wire                                w_c_fifo_empty [7:0];

// output 相关信号
reg [15:0]                          r_tx_mac_fifo_cnt [7:0];
reg                                 r_fifo_ready [7:0];
reg                                 r_fifo_busy [7:0];
reg                                 r_tx_mac_fifo_vld [7:0];
reg                                 r_tx_mac_fifo_last [7:0];
reg [15:0]                          r_tx_mac_fifo_keep [7:0];
reg                                 w_info_fifo_avaliable_flag [7:0];

// 数据包丢弃相关信号
wire [15:0]                         w_data_fifo_data_cnt [7:0];
wire [14:0]                         w_packet_length [7:0];
wire [15:0]                         w_fifo_remaining_space [7:0];
reg [14:0]                          r_packet_length [7:0];
reg                                 r_packet_valid [7:0];
reg                                 r_discard_packet [7:0];
reg                                 rr_discard_packet [7:0];
reg                                 r_packet_active [7:0];
reg [14:0]                          r_word_counter [7:0];
reg                                 r_fifo_wr_en [7:0];




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
// 将分散的输入信号连接到数组
assign i_data[0] = i_data0;
assign i_data_keep[0] = i_data0_keep;
assign i_data_user[0] = i_data0_user;
assign i_data_vld[0] = i_data0_vld;
assign i_data_last[0] = i_data0_last;
assign i_meta_data_pri[0] = i_meta_data0_pri;
assign i_meta_data_pri_vld[0] = i_meta_data0_pri_vld;
assign o_data0_ready = o_data_ready[0];
assign o_data0_busy = o_data_busy[0];

assign i_data[1] = i_data1;
assign i_data_keep[1] = i_data1_keep;
assign i_data_user[1] = i_data1_user;
assign i_data_vld[1] = i_data1_vld;
assign i_data_last[1] = i_data1_last;
assign i_meta_data_pri[1] = i_meta_data1_pri;
assign i_meta_data_pri_vld[1] = i_meta_data1_pri_vld;
assign o_data1_ready = o_data_ready[1];
assign o_data1_busy = o_data_busy[1];

assign i_data[2] = i_data2;
assign i_data_keep[2] = i_data2_keep;
assign i_data_user[2] = i_data2_user;
assign i_data_vld[2] = i_data2_vld;
assign i_data_last[2] = i_data2_last;
assign i_meta_data_pri[2] = i_meta_data2_pri;
assign i_meta_data_pri_vld[2] = i_meta_data2_pri_vld;
assign o_data2_ready = o_data_ready[2];
assign o_data2_busy = o_data_busy[2];

assign i_data[3] = i_data3;
assign i_data_keep[3] = i_data3_keep;
assign i_data_user[3] = i_data3_user;
assign i_data_vld[3] = i_data3_vld;
assign i_data_last[3] = i_data3_last;
assign i_meta_data_pri[3] = i_meta_data3_pri;
assign i_meta_data_pri_vld[3] = i_meta_data3_pri_vld;
assign o_data3_ready = o_data_ready[3];
assign o_data3_busy = o_data_busy[3];

assign i_data[4] = i_data4;
assign i_data_keep[4] = i_data4_keep;
assign i_data_user[4] = i_data4_user;
assign i_data_vld[4] = i_data4_vld;
assign i_data_last[4] = i_data4_last;
assign i_meta_data_pri[4] = i_meta_data4_pri;
assign i_meta_data_pri_vld[4] = i_meta_data4_pri_vld;
assign o_data4_ready = o_data_ready[4];
assign o_data4_busy = o_data_busy[4];

assign i_data[5] = i_data5;
assign i_data_keep[5] = i_data5_keep;
assign i_data_user[5] = i_data5_user;
assign i_data_vld[5] = i_data5_vld;
assign i_data_last[5] = i_data5_last;
assign i_meta_data_pri[5] = i_meta_data5_pri;
assign i_meta_data_pri_vld[5] = i_meta_data5_pri_vld;
assign o_data5_ready = o_data_ready[5];
assign o_data5_busy = o_data_busy[5];

assign i_data[6] = i_data6;
assign i_data_keep[6] = i_data6_keep;
assign i_data_user[6] = i_data6_user;
assign i_data_vld[6] = i_data6_vld;
assign i_data_last[6] = i_data6_last;
assign i_meta_data_pri[6] = i_meta_data6_pri;
assign i_meta_data_pri_vld[6] = i_meta_data6_pri_vld;
assign o_data6_ready = o_data_ready[6];
assign o_data6_busy = o_data_busy[6];

assign i_data[7] = i_data7;
assign i_data_keep[7] = i_data7_keep;
assign i_data_user[7] = i_data7_user;
assign i_data_vld[7] = i_data7_vld;
assign i_data_last[7] = i_data7_last;
assign i_meta_data_pri[7] = i_meta_data7_pri;
assign i_meta_data_pri_vld[7] = i_meta_data7_pri_vld;
assign o_data7_ready = o_data_ready[7];
assign o_data7_busy = o_data_busy[7];


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
                         (  w_c_fifo_empty[0] == 1'b0    
                         || w_c_fifo_empty[1] == 1'b0                     //当没有在调度过程时，任何一个fifo有数据完成输入，则输出fifo状态等待调
                         || w_c_fifo_empty[2] == 1'b0
                         || w_c_fifo_empty[3] == 1'b0
                         || w_c_fifo_empty[4] == 1'b0
                         || w_c_fifo_empty[5] == 1'b0
                         || w_c_fifo_empty[6] == 1'b0
                         || w_c_fifo_empty[7] == 1'b0) ? {w_c_fifo_empty[7],w_c_fifo_empty[6],w_c_fifo_empty[5],w_c_fifo_empty[4],w_c_fifo_empty[3],w_c_fifo_empty[2],w_c_fifo_empty[1],w_c_fifo_empty[0]} : r_fifoc_empty;
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
        ro_pmac_tx_axis_data     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[0] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? w_data_fifo_rd_data[0] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[1] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? w_data_fifo_rd_data[1] :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[2] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? w_data_fifo_rd_data[2] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[3] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? w_data_fifo_rd_data[3] :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[4] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? w_data_fifo_rd_data[4] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[5] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? w_data_fifo_rd_data[5] :  
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[6] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? w_data_fifo_rd_data[6] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[7] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? w_data_fifo_rd_data[7] : {CROSS_DATA_WIDTH{1'b0}}; 

        ro_pmac_tx_axis_user     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[0] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? w_c_fifo_rd_data[0] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[1] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? w_c_fifo_rd_data[1] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[2] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? w_c_fifo_rd_data[2] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[3] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? w_c_fifo_rd_data[3] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[4] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? w_c_fifo_rd_data[4] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[5] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? w_c_fifo_rd_data[5] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[6] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? w_c_fifo_rd_data[6] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[7] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? w_c_fifo_rd_data[7] : 16'd0;
                                                                                               
        ro_pmac_tx_axis_keep     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[0] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo_keep[0] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[1] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo_keep[1] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[2] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo_keep[2] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[3] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo_keep[3] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[4] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo_keep[4] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[5] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo_keep[5] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[6] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo_keep[6] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[7] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo_keep[7] : 16'd0;

        ro_pmac_tx_axis_last     <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[0] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo_last[0] :
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[1] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo_last[1] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[2] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo_last[2] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[3] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo_last[3] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[4] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo_last[4] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[5] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo_last[5] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[6] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo_last[6] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[7] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo_last[7] : 1'b0;

        ro_pmac_tx_axis_valid    <=  ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[0] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[0] == 1'b1 ) ? r_tx_mac_fifo_vld[0] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[1] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[1] == 1'b1 ) ? r_tx_mac_fifo_vld[1] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[2] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[2] == 1'b1 ) ? r_tx_mac_fifo_vld[2] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[3] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[3] == 1'b1 ) ? r_tx_mac_fifo_vld[3] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[4] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[4] == 1'b1 ) ? r_tx_mac_fifo_vld[4] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[5] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[5] == 1'b1 ) ? r_tx_mac_fifo_vld[5] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[6] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[6] == 1'b1 ) ? r_tx_mac_fifo_vld[6] : 
                                     ( i_pmac_tx_axis_ready == 1'b1 && r_c_fifo_qbu_flag[7] == 1'b0 && scheduing_work_flag == 1'b1 && ri_scheduing_rst[7] == 1'b1 ) ? r_tx_mac_fifo_vld[7] : 1'b0;  
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
            scheduing_work_flag <= ( ro_emac_tx_axis_last == 1'b1 || ro_pmac_tx_axis_last == 1'b1) ? 1'b0 : ( i_scheduing_rst_vld == 1'b1 ) ? 1'b1 : scheduing_work_flag;
            ro_emac_tx_axis_last_t <= ro_emac_tx_axis_last;
            ro_pmac_tx_axis_last_t <= ro_pmac_tx_axis_last;
        end
    end


// ========================== GENERATE 逻辑 ==========================
genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : fifo_gen
        // 记录数据末尾的 keep 信号
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                ri_info_fifo_data_keep[i] <= {(CROSS_DATA_WIDTH/8){1'b0}};
            end else begin
                ri_info_fifo_data_keep[i] <= (r_info_fifo_data_vld[i]) ? {(CROSS_DATA_WIDTH/8){1'b0}} : 
                                           (i_data_last[i] && i_data_vld[i]) ? i_data_keep[i] : 
                                           ri_info_fifo_data_keep[i];
            end
        end

        // 记录数据长度
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                ri_info_fifo_data_cnt[i] <= 16'd0;
            end else begin
                ri_info_fifo_data_cnt[i] <= (r_info_fifo_data_vld[i]) ? 16'd0 : 
                                          (i_data_vld[i]) ? ri_info_fifo_data_cnt[i] + 16'd1 : 
                                          ri_info_fifo_data_cnt[i];
            end
        end

        // 内部信息写入 FIFO 有效位
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_info_fifo_data_vld[i] <= 1'b0;
            end else begin
                r_info_fifo_data_vld[i] <= (i_data_last[i] && i_data_vld[i]) ? 1'b1 : 1'b0;
            end
        end

        // meta 信息头 qbu flag 标识
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_c_fifo_qbu_flag[i] <= 1'b0;
            end else begin
                r_c_fifo_qbu_flag[i] <= (r_c_fifo_vld[i]) ? 1'b0 : 
                                      (i_meta_data_pri_vld[i]) ? i_meta_data_pri[i][11] : 
                                      r_c_fifo_qbu_flag[i];
            end
        end

        // meta 信息头 qos 字段
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_c_fifo_qos[i] <= 4'b0;
            end else begin
                r_c_fifo_qos[i] <= (r_c_fifo_vld[i]) ? 4'b0 : 
                                 (i_meta_data_pri_vld[i]) ? i_meta_data_pri[i][18:15] : 
                                 r_c_fifo_qos[i];
            end
        end

        // user 字段
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                w_c_fifo_wr_data[i] <= 16'b0;
            end else begin
                w_c_fifo_wr_data[i] <= i_data_user[i];
            end
        end

        // meta 信息头写入 FIFO 有效位
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_c_fifo_vld[i] <= 1'b0;
            end else begin
                r_c_fifo_vld[i] <= i_data_last[i];
            end
        end

        // 标识该优先级 FIFO 是否可以继续写入数据(忙信号)
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_fifo_busy[i] <= 1'b0;
            end else begin
                r_fifo_busy[i] <= (i_data_vld[i] == 1'b0 && w_data_fifo_full[i] == 1'b0) ? 1'b1 : 1'b0;
            end
        end

        // 调度结果返回时，开始拉高读数据使能
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_data_fifo_rd_en[i] <= 1'b0;
            end else begin
                r_data_fifo_rd_en[i] <= ((r_tx_mac_fifo_cnt[i] == w_info_fifo_datalen[i]) && w_info_fifo_avaliable_flag[i]) ? 1'b0 : 
                                      (ri_scheduing_rst_vld && ri_scheduing_rst[i]) ? 1'b1 : 
                                      r_data_fifo_rd_en[i];
            end
        end

        // 调度结果返回时，开始拉高读 meta 使能
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_c_fifo_rd_en[i] <= 1'b0;
            end else begin
                r_c_fifo_rd_en[i] <= (ri_scheduing_rst_vld && ri_scheduing_rst[i]) ? 1'b1 : 1'b0;
            end
        end

        // 检测读出的数据长度
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_tx_mac_fifo_cnt[i] <= 16'd1;
            end else begin
                r_tx_mac_fifo_cnt[i] <= ((r_tx_mac_fifo_cnt[i] == w_info_fifo_datalen[i]) && w_info_fifo_avaliable_flag[i]) ? 16'd1 : 
                                      (r_data_fifo_rd_en[i]) ? (r_tx_mac_fifo_cnt[i] + 16'd1) : 
                                      r_tx_mac_fifo_cnt[i];
            end
        end

        // 可用标志
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                w_info_fifo_avaliable_flag[i] <= 1'b0;
            end else begin
                w_info_fifo_avaliable_flag[i] <= (r_info_fifo_rd_en[i]) ? 1'b1 : 
                                               (r_tx_mac_fifo_cnt[i] == w_info_fifo_datalen[i]) ? 1'b0 : 
                                               w_info_fifo_avaliable_flag[i];
            end
        end

        // 读使能预处理
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_info_fifo_rd_pre[i] <= 1'b0;
            end else begin
                r_info_fifo_rd_pre[i] <= (w_info_fifo_empty[i] == 1'b0) ? 1'b1 : 1'b0;
            end
        end

        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_info_fifo_rd_pre2[i] <= 1'b0;
            end else begin
                r_info_fifo_rd_pre2[i] <= r_info_fifo_rd_pre[i];
            end
        end

        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_info_fifo_rd_en[i] <= 1'b0;
            end else begin
                r_info_fifo_rd_en[i] <= (ri_scheduing_rst_vld && ri_scheduing_rst[i]) ? 1'b1 : 1'b0;
            end
        end

        // TX MAC 输出有效
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_tx_mac_fifo_vld[i] <= 1'b0;
            end else begin
                r_tx_mac_fifo_vld[i] <= r_data_fifo_rd_en[i];
            end
        end

        // TX MAC 输出 last 和 keep 信号
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_tx_mac_fifo_last[i] <= 1'b0;
                r_tx_mac_fifo_keep[i] <= 16'd0;
            end else begin
                r_tx_mac_fifo_last[i] <= (r_tx_mac_fifo_vld[i] && r_tx_mac_fifo_cnt[i] == w_info_fifo_datalen[i]) ? 1'b1 : 1'b0;
                r_tx_mac_fifo_keep[i] <= (r_tx_mac_fifo_vld[i] && r_tx_mac_fifo_cnt[i] == w_info_fifo_datalen[i]) ? w_info_fifo_keep[i] : 16'd0;
            end
        end


        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_data[i] <= 1'b0;
            end else begin
                r_data[i] <= i_data[i];
            end
        end

        // 输出信号连接
        assign o_data_ready[i] = ~w_data_fifo_full[i];
        assign o_data_busy[i] = r_fifo_busy[i];

    //========================== 新增数据包长度和FIFO空间计算 ==========================

        // 提取数据包长度（user[14:0]）
        assign w_packet_length[i] = i_data_user[i][14:0];
        
        // 计算FIFO剩余空间（假设FIFO深度为16384）
        assign w_fifo_remaining_space[i] = 16'd16384 - w_data_fifo_data_cnt[i];
        
        // 数据包丢弃标志
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_discard_packet[i] <= 1'b0;
                rr_discard_packet[i] <= 1'b0;
            end else begin
                r_discard_packet[i] <= (i_data_vld[i] == 1'b1 && r_packet_active[i] == 1'b0) ? 
                                      ((w_fifo_remaining_space[i] < {1'b0, w_packet_length[i]}) ? 1'b1 : 1'b0) : 
                                      (i_data_last[i] == 1'b1 && i_data_vld[i] == 1'b1) ? 1'b0 : 
                                      r_discard_packet[i]; 

                rr_discard_packet[i] <= r_discard_packet[i];
            end
        end


         // 数据包活跃标志
        always @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                r_packet_active[i] <= 1'b0;
            end else begin
                r_packet_active[i] <= (i_data_vld[i] == 1'b1 && r_packet_active[i] == 1'b0) ? 1'b1 : 
                                     (i_data_last[i] == 1'b1 && i_data_vld[i] == 1'b1) ? 1'b0 : 
                                     r_packet_active[i];
            end
        end       

        // 实际的FIFO写使能（考虑丢弃标志）
        always @(*) begin
            r_fifo_wr_en[i] = i_data_vld[i] && !r_discard_packet[i] && !w_data_fifo_full[i];
        end

    end
endgenerate



// ========================== FIFO 实例化 - 使用 GENERATE ==========================
genvar fifo_idx;
generate
    for (fifo_idx = 0; fifo_idx < 8; fifo_idx = fifo_idx + 1) begin : fifo_inst_gen
        
        // ------ 数据 FIFO (大容量，Block RAM) ------
        sync_fifo #(
            .DEPTH                   ( 32768              ),
            .WIDTH                   ( CROSS_DATA_WIDTH   ),
            .ALMOST_FULL_THRESHOLD   (      ),
            .ALMOST_EMPTY_THRESHOLD  ( 'd1 ),
            .FLOP_DATA_OUT           ( 1'b0 ),
            .RAM_STYLE               ( 1'b1 )
        ) pri_data_fifo_inst (       
            .i_clk                    ( i_clk                            ),
            .i_rst                   ( i_rst                            ),
            .i_wr_en                 ( r_fifo_wr_en[fifo_idx]             ),
            .i_din                   ( r_data[fifo_idx]                 ),
            .o_full                  ( w_data_fifo_full[fifo_idx]       ),
            .i_rd_en                 ( r_data_fifo_rd_en[fifo_idx]      ),
            .o_dout                  ( w_data_fifo_rd_data[fifo_idx]    ),
            .o_empty                 ( w_data_fifo_empty[fifo_idx]      ),
            .o_almost_full           ( ),
            .o_almost_empty          ( ),
            .o_data_cnt              ( w_data_fifo_data_cnt[fifo_idx] )
        );

        // ------ 信息 FIFO (小容量，Distributed RAM) ------
        sync_fifo #(
            .DEPTH                    ( 64       ),
            .WIDTH                   ( 32       ),
            .ALMOST_FULL_THRESHOLD   (          ),
            .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
            .FLOP_DATA_OUT           ( 1'b0 ), // fifo0 开启 FWFT
            .RAM_STYLE               ( 1'b0     )
        ) pri_info_fifo_inst (       
            .i_clk                    ( i_clk                                                              ),
            .i_rst                   ( i_rst                                                              ),
            .i_wr_en                 ( r_info_fifo_data_vld[fifo_idx] && !rr_discard_packet[fifo_idx]        ),
            .i_din                   ( {ri_info_fifo_data_keep[fifo_idx], ri_info_fifo_data_cnt[fifo_idx]} ),
            .o_full                  (                                                                    ),
            .i_rd_en                 ( r_info_fifo_rd_en[fifo_idx]                                        ),
            .o_dout                  ( {w_info_fifo_keep[fifo_idx], w_info_fifo_datalen[fifo_idx]}         ),
            .o_empty                 ( w_info_fifo_empty[fifo_idx]                                        ),
            .o_almost_full           (                                                                    ),
            .o_almost_empty          (                                                                    ),
            .o_data_cnt              (                                                                    )
        );

        // ------ 控制 FIFO (小容量，Distributed RAM) ------
        sync_fifo #(
            .DEPTH                    ( 64       ),
            .WIDTH                   ( 16       ),
            .ALMOST_FULL_THRESHOLD   (          ),
            .ALMOST_EMPTY_THRESHOLD  ( 'd1      ),
            .FLOP_DATA_OUT           ( 1'b0     ),
            .RAM_STYLE               ( 1'b0     )
        ) pri_control_fifo_inst (       
            .i_clk                    ( i_clk                            ),
            .i_rst                   ( i_rst                            ),
            .i_wr_en                 ( r_c_fifo_vld[fifo_idx] && !rr_discard_packet[fifo_idx] ),
            .i_din                   ( w_c_fifo_wr_data[fifo_idx]       ),
            .o_full                  ( w_c_fifo_full[fifo_idx]          ),
            .i_rd_en                 ( r_c_fifo_rd_en[fifo_idx]         ),
            .o_dout                  ( w_c_fifo_rd_data[fifo_idx]       ),
            .o_empty                 ( w_c_fifo_empty[fifo_idx]         ),
            .o_almost_full           (                                  ),
            .o_almost_empty          (                                  ),
            .o_data_cnt              (                                  )
        );

    end
endgenerate



endmodule