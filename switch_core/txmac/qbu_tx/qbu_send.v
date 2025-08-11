`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/16 09:40:20
// Design Name: 
// Module Name: top_rec
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module qbu_send#(
    parameter                                           AXIS_DATA_WIDTH = 'd8       ,
                                                        QUEUE_NUM       = 'd8    
)(
    input           wire                                i_clk                       ,
    input           wire                                i_rst                       ,

    //pmac通道数据
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_pmac_tx_axis_data         , 
    input           wire    [15:0]                      i_pmac_tx_axis_user         , 
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_pmac_tx_axis_keep         , 
    input           wire                                i_pmac_tx_axis_last         , 
    input           wire                                i_pmac_tx_axis_valid        , 
    input           wire    [15:0]                      i_pmac_ethertype            , 
    output          wire                                o_pmac_tx_axis_ready        ,
    //emac通道数据
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_emac_tx_axis_data         , 
    input           wire    [15:0]                      i_emac_tx_axis_user         , 
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_emac_tx_axis_keep         , 
    input           wire                                i_emac_tx_axis_last         , 
    input           wire                                i_emac_tx_axis_valid        , 
    input           wire    [15:0]                      i_emac_ethertype            ,
    output          wire                                o_emac_tx_axis_ready        ,

    input           wire                                i_qbu_verify_valid          ,
    input           wire                                i_qbu_response_valid        ,

    //输出给接口层axi数据流
    output          wire    [AXIS_DATA_WIDTH - 1:0]     o_mac_axi_data              ,
    output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   o_mac_axi_data_keep         ,
    output          wire                                o_mac_axi_data_valid        ,
    output          wire    [15:0]                      o_mac_axi_data_user         ,
    input           wire                                i_mac_axi_data_ready        ,
    output          wire                                o_mac_axi_data_last         ,
    // //时间戳信号
    // output          wire                                o_mac_time_irq              , // 打时间戳中断信号
    // output          wire    [7:0]                       o_mac_frame_seq             , // 帧序列号
    // output          wire    [7:0]                       o_timestamp_addr            , // 打时间戳存储的 RAM 地址
    //寄存器接口

    output          wire    [7:0]                       o_frag_next_tx              ,
    output          wire                                o_tx_timeout                ,
    output          wire    [15:0]                      o_preempt_success_cnt       ,
    output          wire                                o_preempt_active            ,
    output          wire                                o_preemptable_frame         ,
    output          wire    [15:0]                      o_tx_frames_cnt             ,
    output          wire    [15:0]                      o_tx_fragment_cnt           ,
    output          wire                                o_tx_busy                   ,
   
    input           wire    [19:0]                      i_watchdog_timer            ,
    input           wire                                i_watchdog_timer_vld        ,
    input           wire    [ 7:0]                      i_min_frag_size             ,
    input           wire                                i_min_frag_size_vld         ,
    input           wire    [ 7:0]                      i_ipg_timer                 ,
    input           wire                                i_ipg_timer_vld             ,

    input           wire                                i_verify_enabled            ,
    input           wire                                i_start_verify              ,
    input           wire                                i_clear_verify              ,
    output 			wire 								o_verify_succ 		        ,//验证成功信号
    output 			wire 								o_verify_succ_val 	        ,//验证成功有效信号
    input           wire    [15:0]                      i_verify_timer		        ,//控制验证请求之间的等待时间
    input  			wire                                i_verify_timer_vld          ,
    output          wire    [15:0]                      o_err_verify_cnt            ,
    output          wire                                o_preempt_enable             //qbu功能激活成功


    //缓存队列需要发送的数据
    // input           wire    [AXIS_DATA_WIDTH - 1:0]     i_mac_tx_axis_data          ,
    // input           wire    [15:0]                      i_mac_tx_axis_user          , //user：数据长度信息
    // input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_mac_tx_axis_keep          , //keep数据掩码
    // input           wire                                i_mac_tx_axis_last          ,
    // input           wire                                i_mac_tx_axis_valid         ,
    // output          wire                                o_mac_tx_axis_ready         ,
    
    // input           wire    [QUEUE_NUM - 1:0]           i_emac_channel_cfg          ,
    // input           wire    [QUEUE_NUM - 1:0]           i_tx_mac_forward_info       , //哪个通道来的数据，内部设定哪些优先级走eMAC，哪些走pMAC
    // input           wire                                i_tx_mac_forward_info_vld   ,
);            


wire                [AXIS_DATA_WIDTH - 1:0]             o_top_Emac_tx_axis_data  ;  
wire                [15:0]                              o_top_Emac_tx_axis_user  ;  
wire                [(AXIS_DATA_WIDTH/8)-1:0]           o_top_Emac_tx_axis_keep  ;  
wire                                                    o_top_Emac_tx_axis_last  ;  
wire                                                    o_top_Emac_tx_axis_valid ;  
wire                [15:0]                              o_top_Emac_tx_axis_type  ;  

wire                [AXIS_DATA_WIDTH - 1:0]             o_top_Pmac_tx_axis_data  ;
wire                [15:0]                              o_top_Pmac_tx_axis_user  ;
wire                [(AXIS_DATA_WIDTH/8)-1:0]           o_top_Pmac_tx_axis_keep  ;
wire                                                    o_top_Pmac_tx_axis_last  ;
wire                                                    o_top_Pmac_tx_axis_valid ;
wire                [15:0]                              o_top_Pmac_tx_axis_type  ;      

wire                [AXIS_DATA_WIDTH - 1:0]             i_top_Emac_tx_axis_data  ;  
wire                [15:0]                              i_top_Emac_tx_axis_user  ;  
wire                [(AXIS_DATA_WIDTH/8)-1:0]           i_top_Emac_tx_axis_keep  ;  
wire                                                    i_top_Emac_tx_axis_last  ;  
wire                                                    i_top_Emac_tx_axis_valid ;  
wire                [15:0]                              i_top_Emac_tx_axis_type  ;  

wire                [AXIS_DATA_WIDTH - 1:0]             i_top_Pmac_tx_axis_data  ;
wire                [15:0]                              i_top_Pmac_tx_axis_user  ;
wire                [(AXIS_DATA_WIDTH/8)-1:0]           i_top_Pmac_tx_axis_keep  ;
wire                                                    i_top_Pmac_tx_axis_last  ;
wire                                                    i_top_Pmac_tx_axis_valid ;
wire                [15:0]                              i_top_Pmac_tx_axis_type  ;  

//                  FAST_qbu_Emac_tx 变量定义        
wire                                                    o_emac_send_busy         ;//eamc忙信号，表示emac正在发数据
wire                                                    o_emac_send_apply        ;//emac数据发送申请
wire                                                    i_rx_ready               ;//组帧模块准备好了信号
wire                [15:0]                              o_emac_send_type         ;//协议类型（参照mac帧格式）
wire                [AXIS_DATA_WIDTH-1 :0]              o_emac_send_data         ;//数据信号
wire                                                    o_emac_send_last         ;//最后一个数据信号
wire                [15:0]                              o_emac_send_len          ;//数据长度
wire                                                    o_emac_send_valid        ;//数据有效信号
wire                                                    o_emac_smd_val           ;//SMD编码有效信号
wire                [15:0]                              o_emac_smd               ;//SMD编码 

//                  mux 变量定义   
wire    [AXIS_DATA_WIDTH - 1:0]                         i_eth_send_data          ;//数据信号  
wire    [15:0]                                          i_eth_send_user          ;//数据信息  
wire    [(AXIS_DATA_WIDTH/8)-1:0]                       i_eth_send_keep          ;//数据掩码  
wire                                                    i_eth_send_last          ;//数据截至信号
wire                                                    i_eth_send_valid         ;//数据有效信号 
wire                                                    o_eth_send_ready         ;//准备信号
wire    [15:0]                                          i_eth_send_type          ;//数据类型
wire                                                    i_eth_smd                ;//SMD编码
wire                                                    i_eth_smd_val            ;//SMD编码有效信号

wire    [AXIS_DATA_WIDTH - 1:0]                         i_R_rx_axis_data         ;//数据信号  
wire    [15:0]                                          i_R_rx_axis_user         ;//数据信息  
wire    [(AXIS_DATA_WIDTH/8)-1:0]                       i_R_rx_axis_keep         ;//数据掩码  
wire                                                    i_R_rx_axis_last         ;//数据截至信号
//wire                                                      i_R_rx_axis_valid        ;//数据有效信号
wire                                                    o_R_rx_axis_ready        ; //准备信号 
wire    [AXIS_DATA_WIDTH - 1:0]                         i_V_rx_axis_data         ;//数据信号  
wire    [15:0]                                          i_V_rx_axis_user         ;//数据信息  
wire    [(AXIS_DATA_WIDTH/8)-1:0]                       i_V_rx_axis_keep         ;//数据掩码  
wire                                                    i_V_rx_axis_last         ;//数据截至信号
//wire                                                      i_V_rx_axis_valid        ;//数据有效信号
wire                                                    o_V_rx_axis_ready        ; //准备信号
                   
wire    [AXIS_DATA_WIDTH - 1:0]                         o_mux_axis_data          ;//数据信号  
wire    [15:0]                                          o_mux_axis_user          ;//数据信息  
wire    [(AXIS_DATA_WIDTH/8)-1:0]                       o_mux_axis_keep          ;//数据掩码  
wire                                                    o_mux_axis_last          ;//数据截至信号
wire                                                    o_mux_axis_valid         ;//数据有效信号 
wire                                                    i_mux_axis_ready         ;//准备信号
wire    [7:0]                                           o_mux_smd                ;//SMD编码
wire                                                    o_mux_smd_val            ;//SMD编码有效信号
//wire                                                      o_verify_succ            ;//验证成功信号
//wire                                                      o_verify_succ_val        ;//验证成功有效信号
                   
wire                                                    i_pmac_rx_ready          ;//此模块准备好了
wire    [15:0]                                          o_pmac_send_type         ;//数据类型
wire    [AXIS_DATA_WIDTH-1 :0]                          o_pmac_send_data         ;//数据
wire                                                    o_pmac_send_last         ;//数据截至信号
wire                                                    o_pmac_send_valid        ;//数据有效信号
wire    [15:0]                                          o_pmac_send_len          ;//数据长度
wire                                                    o_pmac_send_len_val      ;
wire    [15:0]                                          o_pmac_smd               ;//SMD
wire    [15:0]                                          o_pmac_fra               ;//帧计数器
wire                                                    o_pmac_smd_vld           ;//SMD有效信号
wire                                                    o_pmac_fra_vld           ;//帧计数器有效信号
wire                                                    o_pmac_crc               ;//为1则为crc否则为mcrc。
                   
wire    [15:0]                                          i_user_set               ;//用户设置(暂定最高位为)
wire                                                    i_user_set_val           ;//用户设置有效信号
wire                                                    i_mac_rx_ready           ;//此组帧准备好了
wire     [15:0]                                         o_mac_send_type          ;//数据类型
wire     [AXIS_DATA_WIDTH-1 :0]                         o_mac_send_data          ;//数据
wire                                                    o_mac_send_last          ;//数据截至信号
wire    [15:0]                                          o_mac_send_len           ;//数据长度
wire                                                    o_mac_send_valid         ;//数据有效信号
wire    [15:0]                                          o_mac_smd                ;//SMD
wire    [15:0]                                          o_mac_fra                ;//帧计数器
wire                                                    o_mac_smd_vld            ;//SMD有效信号
wire                                                    o_mac_fra_vld            ;//帧计数器有效信号
wire                                                    o_mac_crc                ;//为1则为crc否则为mcrc
wire                                                    o_occupy_succ            ;

wire    [AXIS_DATA_WIDTH - 1:0]     	                o_qbu_verify_data        ;
wire    [15:0]                      	                o_qbu_verify_user        ;
wire    [(AXIS_DATA_WIDTH/8)-1:0]   	                o_qbu_verify_keep        ;
wire                                	                o_qbu_verify_last        ;
wire                                	                o_qbu_verify_valid       ;
wire                                	                i_qbu_verify_ready       ;
wire    [7:0]                       	                o_qbu_verify_smd 	     ;
wire                                                    o_qbu_verify_smd_valid   ;

// wire    [7:0]                                           o_frag_next_tx           ;          
// wire                                                    o_tx_timeout             ;    
// wire    [15:0]                                          o_preempt_success_cnt    ;           
// wire                                                    o_preempt_active         ;    
// wire                                                    o_preemptable_frame      ;
// wire    [15:0]                                          o_tx_frames_cnt          ;
// wire    [15:0]                                          o_tx_fragment_cnt        ; 
// wire                                                    o_tx_busy                ;
                    
// wire    [19:0]                                          i_watchdog_timer         ;    
// wire                                                    i_watchdog_timer_vld     ;
// wire    [ 7:0]                                          i_min_frag_size          ;    
// wire                                                    i_min_frag_size_vld      ;  
// wire    [ 7:0]                                          i_ipg_timer              ;
// wire                                                    i_ipg_timer_vld          ;    

              
// qbu_tx_mac_map #(
//     .AXIS_DATA_WIDTH              (AXIS_DATA_WIDTH),
//     .QUEUE_NUM                    (QUEUE_NUM)
// ) inst_qbu_tx_mac_map (
//     .i_clk                        (i_clk                     ),
//     .i_rst                        (i_rst                     ),
//     .i_mac_tx_axis_data           (i_mac_tx_axis_data        ),
//     .i_mac_tx_axis_keep           (i_mac_tx_axis_keep        ),
//     .i_mac_tx_axis_user           (i_mac_tx_axis_user        ),
//     .i_mac_tx_axis_last           (i_mac_tx_axis_last        ),
//     .i_mac_tx_axis_valid          (i_mac_tx_axis_valid       ),
//     .o_mac_tx_axis_ready          (o_mac_tx_axis_ready       ),

//     .i_emac_channel_cfg           (i_emac_channel_cfg        ),
//     .i_tx_mac_forward_info        (i_tx_mac_forward_info     ),
//     .i_tx_mac_forward_info_vld    (i_tx_mac_forward_info_vld ),
//     .i_verify_succ                (o_verify_succ             ),
//     .i_verify_succ_valid          (o_verify_succ_val         ),

//     .o_emac_tx_axis_data          (i_top_Emac_tx_axis_data   ),
//     .o_emac_tx_axis_user          (i_top_Emac_tx_axis_user   ),
//     .o_emac_tx_axis_keep          (i_top_Emac_tx_axis_keep   ),
//     .o_emac_tx_axis_last          (i_top_Emac_tx_axis_last   ),
//     .o_emac_tx_axis_valid         (i_top_Emac_tx_axis_valid  ),
//     .o_emac_tx_axis_type          (i_top_Emac_tx_axis_type   ),
//     .i_emac_tx_axis_ready         (o_top_Emac_tx_axis_ready  ),

//     .o_pmac_tx_axis_data          (i_top_Pmac_tx_axis_data   ),
//     .o_pmac_tx_axis_user          (i_top_Pmac_tx_axis_user   ),
//     .o_pmac_tx_axis_keep          (i_top_Pmac_tx_axis_keep   ),
//     .o_pmac_tx_axis_last          (i_top_Pmac_tx_axis_last   ),
//     .o_pmac_tx_axis_valid         (i_top_Pmac_tx_axis_valid  ),
//     .o_pmac_tx_axis_type          (i_top_Pmac_tx_axis_type   ),
//     .i_pmac_tx_axis_ready         (o_top_Pmac_tx_axis_ready  )
// );

//保证最小帧长
frame_len_detect #(
        .AXIS_DATA_WIDTH                    (AXIS_DATA_WIDTH          )
    ) inst_frame_len_detect (
        .i_clk                              (i_clk                    ),
        .i_rst                              (i_rst                    ),
                    
        .i_top_Emac_tx_axis_data            (i_emac_tx_axis_data      ),
        .i_top_Emac_tx_axis_user            (i_emac_tx_axis_user      ),
        .i_top_Emac_tx_axis_keep            (i_emac_tx_axis_keep      ),
        .i_top_Emac_tx_axis_last            (i_emac_tx_axis_last      ),
        .i_top_Emac_tx_axis_valid           (i_emac_tx_axis_valid     ),
        .i_top_Emac_tx_axis_type            (i_emac_ethertype         ),   
        .o_top_Emac_tx_axis_ready           (o_emac_tx_axis_ready     ),
            
        .i_top_Pmac_tx_axis_data            (i_pmac_tx_axis_data      ),
        .i_top_Pmac_tx_axis_user            (i_pmac_tx_axis_user      ),
        .i_top_Pmac_tx_axis_keep            (i_pmac_tx_axis_keep      ),
        .i_top_Pmac_tx_axis_last            (i_pmac_tx_axis_last      ),
        .i_top_Pmac_tx_axis_valid           (i_pmac_tx_axis_valid     ),
        .i_top_Pmac_tx_axis_type            (i_pmac_ethertype         ),           
        .o_top_Pmac_tx_axis_ready           (o_pmac_tx_axis_ready     ),
            
        .o_top_Emac_tx_axis_data            (o_top_Emac_tx_axis_data  ),
        .o_top_Emac_tx_axis_user            (o_top_Emac_tx_axis_user  ),
        .o_top_Emac_tx_axis_keep            (o_top_Emac_tx_axis_keep  ),
        .o_top_Emac_tx_axis_last            (o_top_Emac_tx_axis_last  ),
        .o_top_Emac_tx_axis_valid           (o_top_Emac_tx_axis_valid ),
        .o_top_Emac_tx_axis_type            (o_top_Emac_tx_axis_type  ),
        .i_top_Emac_tx_axis_ready           (o_top_Emac_tx_axis_ready ),
            
        .o_top_Pmac_tx_axis_data            (o_top_Pmac_tx_axis_data  ),
        .o_top_Pmac_tx_axis_user            (o_top_Pmac_tx_axis_user  ),
        .o_top_Pmac_tx_axis_keep            (o_top_Pmac_tx_axis_keep  ),
        .o_top_Pmac_tx_axis_last            (o_top_Pmac_tx_axis_last  ),
        .o_top_Pmac_tx_axis_valid           (o_top_Pmac_tx_axis_valid ),
        .o_top_Pmac_tx_axis_type            (o_top_Pmac_tx_axis_type  ),
        .i_top_Pmac_tx_axis_ready           (o_top_Pmac_tx_axis_ready )
    );   
    
    
// qbu_tx_timestamp #(
//     .DWIDTH                                 (AXIS_DATA_WIDTH            )
// ) inst_qbu_tx_timestamp(                        
//     .i_clk                                  (i_clk                      ),
//     .i_rst                                  (i_rst                      ),
//     .i_mac_axis_data                        (o_mac_axi_data             ),
//     .i_mac_axis_valid                       (o_mac_axi_data_valid       ),
//     .o_mac_time_irq                         (o_mac_time_irq             ), // 需要连接或留空
//     .o_mac_frame_seq                        (o_mac_frame_seq            ), // 需要连接或留空
//     .o_timestamp_addr                       (o_timestamp_addr           )  // 需要连接或留空
// );

FAST_qbu_Emac_tx    #(
    .AXIS_DATA_WIDTH                        (AXIS_DATA_WIDTH            )
) inst_FAST_qbu_Emac_tx    (    
    .i_clk                                  (i_clk                      ),   
    .i_rst                                  (i_rst                      ),
    //输入emac通道数据准备发送  
    .i_top_Emac_tx_axis_data                (o_top_Emac_tx_axis_data    ),   
    .i_top_Emac_tx_axis_user                (o_top_Emac_tx_axis_user    ),   
    .i_top_Emac_tx_axis_keep                (o_top_Emac_tx_axis_keep    ),   
    .i_top_Emac_tx_axis_last                (o_top_Emac_tx_axis_last    ),   
    .i_top_Emac_tx_axis_valid               (o_top_Emac_tx_axis_valid   ),   
    .i_top_Emac_tx_axis_type                (o_top_Emac_tx_axis_type    ),   
    .o_top_Emac_tx_axis_ready               (o_top_Emac_tx_axis_ready   ),
    //输出给Mux模块 
    .i_pmac_send_busy                       (o_pamc_send_busy           ),
    .i_pmac_send_apply                      (o_pamc_send_apply          ),
    .o_emac_send_busy                       (o_emac_send_busy           ),
    .o_emac_send_apply                      (o_emac_send_apply          ),
    .i_rx_ready                             (o_emac_rx_ready            ),
    .o_send_type                            (o_emac_send_type           ),
    .o_send_data                            (o_emac_send_data           ),
    .o_send_last                            (o_emac_send_last           ),
    .o_send_valid                           (o_emac_send_valid          ),
    .o_smd_val                              (o_emac_smd_val             ),
    .o_send_len                             (o_emac_send_len            ),
    .o_smd                                  (o_emac_smd                 )                  
    );

    Mux #(
      .AXIS_DATA_WIDTH  (AXIS_DATA_WIDTH)
) inst_Mux    (
    .i_clk                                  (i_clk                      ),   
    .i_rst                                  (i_rst                      ),

    .i_eth_send_data                        (i_eth_send_data            ),
    .i_eth_send_user                        (i_eth_send_user            ),
    .i_eth_send_keep                        (i_eth_send_keep            ),
    .i_eth_send_last                        (i_eth_send_last            ),
    .i_eth_send_valid                       (i_eth_send_valid           ),
    .o_eth_send_ready                       (o_eth_send_ready           ),
    .i_eth_send_type                        (i_eth_send_type            ),
    .i_eth_smd                              (i_eth_smd                  ),
    .i_eth_smd_val                          (i_eth_smd_val              ),

    .i_verify_send_data                     (o_qbu_verify_data          ),
    .i_verify_send_user                     (o_qbu_verify_user          ),
    .i_verify_send_keep                     (o_qbu_verify_keep          ),
    .i_verify_send_last                     (o_qbu_verify_last          ),
    .i_verify_send_valid                    (o_qbu_verify_valid         ),
    .o_verify_send_ready                    (i_qbu_verify_ready         ),
    .i_verify_smd                           (o_qbu_verify_smd           ),
    .i_verify_smd_val                       (o_qbu_verify_smd_valid     ),

    .i_verify_succ                          (o_verify_succ              ),
    .i_verify_succ_val                      (o_verify_succ_val          ),

    .o_pmac_rx_ready                        (i_pmac_rx_ready            ),
    .i_pmac_send_type                       (o_pmac_send_type           ),
    .i_pmac_send_data                       (o_pmac_send_data           ),
    .i_pmac_send_last                       (o_pmac_send_last           ),
    .i_pmac_send_valid                      (o_pmac_send_valid          ),
    .i_pmac_send_len                        (o_pmac_send_len            ),
    .i_pmac_smd                             (o_pmac_smd                 ),
    .i_pmac_fra                             (o_pmac_fra                 ),
    .i_pmac_smd_vld                         (o_pmac_smd_vld             ),
    .i_pmac_fra_vld                         (o_pmac_fra_vld             ),
    .i_pmac_crc                             (o_pmac_crc                 ),

    .o_emac_rx_ready                        (o_emac_rx_ready            ),
    .i_emac_send_type                       (o_emac_send_type           ),
    .i_emac_send_data                       (o_emac_send_data           ),
    .i_emac_send_len                        (o_emac_send_len            ),
    .i_emac_send_last                       (o_emac_send_last           ),
    .i_emac_send_valid                      (o_emac_send_valid          ),
    .i_emac_smd_val                         (o_emac_smd_val             ),
    .i_emac_smd                             (o_emac_smd                 ),
    // 
    .i_mac_rx_ready                         (o_udp_ready                ),
    .o_mac_send_type                        (o_mac_send_type            ),
    .o_mac_send_data                        (o_mac_send_data            ),
    .o_mac_send_last                        (o_mac_send_last            ),
    .o_mac_send_valid                       (o_mac_send_valid           ),
    .o_mac_send_len                         (o_mac_send_len             ),
    .o_mac_smd                              (o_mac_smd                  ),
    .o_mac_fra                              (o_mac_fra                  ),
    .o_mac_smd_vld                          (o_mac_smd_vld              ),
    .o_mac_fra_vld                          (o_mac_fra_vld              ),
    .o_mac_crc                              (o_mac_crc                  )  
    );

    MAC_tx #(
      .AXIS_DATA_WIDTH  (AXIS_DATA_WIDTH)
) inst_MAC_tx    (
    .i_clk                                  (i_clk                      ),   
    .i_rst                                  (i_rst                      ),
    .i_target_mac                           (i_target_mac               ),
    .i_target_mac_valid                     (i_target_mac_valid         ),
    .i_source_mac                           (i_source_mac               ),
    .i_source_mac_valid                     (i_source_mac_valid         ),
    .o_udp_ready                            (o_udp_ready                ),

    .i_send_type                            (o_mac_send_type            ),
    .i_send_len                             (o_mac_send_len             ),
    .i_pmac_send_len_val                    (o_pmac_send_len_val        ),
    .i_pmac_send_len                        (o_pmac_send_len            ),
    .i_send_data                            (o_mac_send_data            ),
    .i_send_last                            (o_mac_send_last            ),
    .i_send_valid                           (o_mac_send_valid           ),
    .i_smd                                  (o_mac_smd                  ),
    .i_fra                                  (o_mac_fra                  ),
    .i_smd_vld                              (o_mac_smd_vld              ),
    .i_fra_vld                              (o_mac_fra_vld              ),
    .i_crc                                  (o_mac_crc                  ),
    .i_eamc_send_busy                       (o_emac_send_busy           ),
    .i_pamc_send_busy                       (o_emac_send_apply          ),
    //输出给phy接口层
    .o_mac_axi_data                         (o_mac_axi_data             ),  
    .o_mac_axi_data_keep                    (o_mac_axi_data_keep        ),  
    .o_mac_axi_data_valid                   (o_mac_axi_data_valid       ),  
    .o_mac_axi_data_user                    (o_mac_axi_data_user        ),  
    .i_mac_axi_data_ready                   (i_mac_axi_data_ready       ),  
    .o_mac_axi_data_last                    (o_mac_axi_data_last        ),  
    //寄存器接口    
    .o_tx_frames_cnt                        (o_tx_frames_cnt            ),    
    .o_tx_fragment_cnt                      (o_tx_fragment_cnt          ),    
    .i_ipg_timer                            (i_ipg_timer                ),    
    .i_ipg_timer_vld                        (i_ipg_timer_vld            ),    
    .o_tx_busy                              (o_tx_busy                  )   

    );

FAST_qbu_Pmac_tx  #(
      .AXIS_DATA_WIDTH  (AXIS_DATA_WIDTH)
)
inst_FAST_qbu_Pmac_tx(
    .i_clk                                  ( i_clk                       ),
    .i_rst                                  ( i_rst                       ),
    .i_top_Pmac_tx_axis_data                (o_top_Pmac_tx_axis_data      ),
    .i_top_Pmac_tx_axis_user                (o_top_Pmac_tx_axis_user      ),
    .i_top_Pmac_tx_axis_keep                (o_top_Pmac_tx_axis_keep      ),
    .i_top_Pmac_tx_axis_last                (o_top_Pmac_tx_axis_last      ),
    .i_top_Pmac_tx_axis_valid               (o_top_Pmac_tx_axis_valid     ),
    .i_top_Pmac_tx_axis_type                (o_top_Pmac_tx_axis_type      ),
    .o_pmac_send_len                        (o_pmac_send_len              ),
    .o_pmac_send_len_val                    (o_pmac_send_len_val          ),
    .i_emac_send_busy                       (o_emac_send_busy             ),
    .i_emac_send_apply                      (o_emac_send_apply            ),
    .i_rx_ready                             (i_pmac_rx_ready              ),
    .o_top_Pmac_tx_axis_ready               (o_top_Pmac_tx_axis_ready     ),
    .o_pamc_send_busy                       (o_pamc_send_busy             ),
    .o_pamc_send_apply                      (o_pamc_send_apply            ),
    .o_send_type                            (o_pmac_send_type             ),
    .o_send_data                            (o_pmac_send_data             ),
    .o_send_last                            (o_pmac_send_last             ),
    .o_send_valid                           (o_pmac_send_valid            ),
    .o_smd                                  (o_pmac_smd                   ),
    .o_fra                                  (o_pmac_fra                   ),
    .o_smd_vld                              (o_pmac_smd_vld               ),
    .o_fra_vld                              (o_pmac_fra_vld               ),
    .o_crc                                  (o_pmac_crc                   ),
    //寄存器接口                    
    .o_frag_next_tx                         (o_frag_next_tx               ),     
    .i_watchdog_timer                       (i_watchdog_timer             ),     
    .i_watchdog_timer_vld                   (i_watchdog_timer_vld         ),     
    .o_tx_timeout                           (o_tx_timeout                 ),     
    .o_preempt_success_cnt                  (o_preempt_success_cnt        ),     
    .i_min_frag_size                        (i_min_frag_size              ),     
    .i_min_frag_size_vld                    (i_min_frag_size_vld          ),     
    .o_preempt_active                       (o_preempt_active             ),     
    .o_preemptable_frame                    (o_preemptable_frame          )   
);

verified #(
    .AXIS_DATA_WIDTH                        (AXIS_DATA_WIDTH            )
) inst_verified (                             
    .i_clk                                  (i_clk                      ),
    .i_rst                                  (i_rst                      ),

    .i_qbu_verify_valid                     (i_qbu_verify_valid         ),
    .i_qbu_response_valid                   (i_qbu_response_valid       ),
    
    .o_verify_succ                          (o_verify_succ              ),
    .o_verify_succ_val                      (o_verify_succ_val          ),
    // verified_to_txmac
    .o_qbu_verify_data                      (o_qbu_verify_data          ), 
    .o_qbu_verify_user                      (o_qbu_verify_user          ), 
    .o_qbu_verify_keep                      (o_qbu_verify_keep          ), 
    .o_qbu_verify_last                      (o_qbu_verify_last          ), 
    .o_qbu_verify_valid                     (o_qbu_verify_valid         ), 
    .i_qbu_verify_ready                     (i_qbu_verify_ready         ), 
    .o_qbu_verify_smd                       (o_qbu_verify_smd           ), 
    .o_qbu_verify_smd_valid                 (o_qbu_verify_smd_valid     ), 
    //寄存器信号
    .i_verify_enabled                       (i_verify_enabled           ),
    .i_start_verify                         (i_start_verify             ),
    .i_clear_verify                         (i_clear_verify             ),
    .i_verify_timer                         (i_verify_timer             ),
    .i_verify_timer_vld                     (i_verify_timer_vld         ),
    .o_err_verify_cnt                       (o_err_verify_cnt           ),
    .o_preempt_enable                       (o_preempt_enable           )
);
/*
        ila_0 your_inst_ila_0 (
    .i_clk(i_clk), // input wire i_clk


    .probe0(o_pmac_send_data        ), // input wire [7:0]  probe0  
    .probe1(o_pmac_send_valid   ), // input wire [0:0]  probe1 
    .probe2(o_emac_send_data        ), // input wire [7:0]  probe2 
    .probe3(o_emac_send_valid   )
);
*/
endmodule
