module req_arbit (
    input       wire                    i_clk               ,
    input       wire                    i_rst               ,
    // -------                          
    input       wire                    i_port0_req         , 
    input       wire                    i_data0_qbu_flag    , // 关键帧标志位
    
    input       wire                    i_port1_req         ,
    input       wire                    i_data1_qbu_flag    ,

    input       wire                    i_port2_req         ,
    input       wire                    i_data2_qbu_flag    , 

    input       wire                    i_port3_req         ,
    input       wire                    i_data3_qbu_flag    ,

    input       wire                    i_port4_req         ,
    input       wire                    i_data4_qbu_flag    ,

    input       wire                    i_port5_req         ,
    input       wire                    i_data5_qbu_flag    ,

    input       wire                    i_port6_req         ,
    input       wire                    i_data6_qbu_flag    ,

    input       wire                    i_port7_req         ,
    input       wire                    i_data7_qbu_flag    ,

    input       wire                    i_port8_req         ,
    input       wire                    i_data8_qbu_flag    ,

    input       wire                    i_port9_req         ,
    input       wire                    i_data9_qbu_flag    ,
    // --------
    input       wire                    i_data_ready        , // 标识 FIFO 是否忙；1:空闲  0：忙
    // --------
    output      wire    [9:0]           o_port_ack          , // 仲裁结果 
    output      wire                    o_port_vld            // 仲裁有效标志位
    
);

// req 请求信号不定时输i_data_ready 上升沿不对齐
// 检测到 i_data_ready 上升沿，开始启动仲裁（等待 req 有效）

// -----------
    reg                                 ri_data_ready           ;
    reg                                 r_arbiter_run           ;
    reg                 [9:0]           r_req                   ;
    reg                 [9:0]           r_req_qbu               ;
    reg                 [9:0]           r_arbiter_data          ;
    reg                                 r_arbiter_valid         ;
    reg                                 r_arbiter_valid_d2      ;
    reg                                 r_req_And_Gate          ;
    reg                                 r_req_qbu_And_Gate      ;
    reg                                 r_result_valid          ;
    reg                                 r_result_type           ;// 0 : req 1 : req_qbu 
    reg                                 r_ready_posdge          ;
    reg                 [9:0]           ro_port_ack             ;
    reg                                 ro_port_vld             ;                 
// -----------
    wire                [9:0]           w_all_req                   ;
    wire                [9:0]           w_all_qbu_req               ;
    wire                                w_req_And_Gate          ;
    wire                                w_req_qbu_And_Gate      ;
    wire                                w_ready_posdge          ;
    wire                                w_ready_negedge         ;
    wire                                w_result_valid          ;
    wire                [9:0]           w_arbiter_result        ;
// -----------
assign w_req_And_Gate       =   |w_all_req                  ;  
assign w_req_qbu_And_Gate   =   |w_all_qbu_req              ;
assign w_ready_posdge       =   (i_data_ready == 1'b1 && ri_data_ready == 1'b0) ? 1'b1 : 1'b0;
assign w_ready_negedge      =   (i_data_ready == 1'b0 && ri_data_ready == 1'b1) ? 1'b1 : 1'b0;
// assign w_all_req             = {i_port0_req,i_port1_req,i_port2_req,i_port3_req,i_port4_req,i_port5_req,i_port6_req,i_port7_req,i_port8_req,i_port9_req};
// assign w_all_qbu_req         = {i_data0_qbu_flag,i_data1_qbu_flag,i_data2_qbu_flag,i_data3_qbu_flag,i_data4_qbu_flag,i_data5_qbu_flag,i_data6_qbu_flag,3'b0};
assign w_all_req                =   {i_port9_req,i_port8_req,i_port7_req,i_port6_req,i_port5_req,i_port4_req,i_port3_req,i_port2_req,i_port1_req,i_port0_req};
assign w_all_qbu_req            =   {3'b0,i_data6_qbu_flag,i_data5_qbu_flag,i_data4_qbu_flag,i_data3_qbu_flag,i_data2_qbu_flag,i_data1_qbu_flag,i_data0_qbu_flag};
assign o_port_ack           =   ro_port_ack             ;
assign o_port_vld           =   ro_port_vld             ;
//补0 弊端： 会造成 3个周期的仲裁空转(高位的优先级响应) 消除弊端 多例化一个仲裁模块 通道数为 7 个
// ---------
    Arbiter_RR Arbiter_RR(
        .i_sys_clk             (i_clk                  ),
        .i_sys_rst             (i_rst                  ),

        .i_arbiter_data        (r_arbiter_data         ),
        .i_arbiter_valid       (r_arbiter_valid_d2     ),
        
        .o_arbiter_result      (w_arbiter_result       ),
        .o_arbiter_valid       (w_result_valid         )    
    );  

    always @(posedge i_clk) begin
        if(i_rst)
            ri_data_ready <= 1'b0;
        else 
            ri_data_ready <= i_data_ready;
    end 

    always @(posedge i_clk) begin
        if(i_rst)begin 
            r_req               <= 10'd0;
            r_req_qbu           <= 7'd0 ;
            r_req_And_Gate      <= 1'b0 ;
            r_req_qbu_And_Gate  <= 1'b0 ;
            r_result_valid      <= 1'b0 ;
            r_ready_posdge      <= 1'b0 ;
            r_arbiter_valid_d2  <= 1'b0 ;
        end else begin 
            r_req               <= w_all_req         ;
            r_req_qbu           <= w_all_qbu_req     ;
            r_req_And_Gate      <= w_req_And_Gate    ;
            r_req_qbu_And_Gate  <= w_req_qbu_And_Gate;
            r_result_valid      <= w_result_valid    ;
            r_ready_posdge      <= w_ready_posdge    ;
            r_arbiter_valid_d2  <= r_arbiter_valid;
        end 
    end

    always @(posedge i_clk) begin
        if(i_rst)
            r_arbiter_run <= 1'b0; 
        else begin 
            r_arbiter_run <= ((w_result_valid == 1'b1 && r_result_valid == 1'b0) || w_ready_negedge) == 1'b1 ? 1'b0 : 
                             (w_ready_posdge == 1'b1) ? 1'b1 : 
                             r_arbiter_run;
        end 
    end 

// //@1: 上升沿 & 不为 0  
// //@2: run & 仲裁从0 到 1
    always @(posedge i_clk) begin
        if(i_rst)
            r_arbiter_valid <= 1'd0;
        else begin 
            r_arbiter_valid <= (((r_ready_posdge == 1'b1) && (r_req_And_Gate == 1'b1 || r_req_qbu_And_Gate == 1'b1)) || (r_arbiter_run == 1'b1  && w_req_And_Gate == 1'b1 && r_req_And_Gate == 1'b0)) ? 1'b1 : 
                               1'b0;
        end 
    end 

    always @(posedge i_clk) begin
        if(i_rst)
            r_arbiter_data <= 10'd0;
        else begin
            r_arbiter_data <= (r_req_qbu_And_Gate == 1'b1) ? r_req_qbu    :
                              (r_req_And_Gate     == 1'b1) ? r_req        :
                              r_arbiter_data;
        end
    end 
    always @(posedge i_clk) begin
        if(i_rst)
            r_result_type <= 1'b0;
        else begin 
            r_result_type <= (w_result_valid == 1'b1 && r_result_valid == 1'b0) ? 1'b0 : 
                             (r_req_qbu_And_Gate == 1'b1) ? r_result_type <= 1'b1 : 
                             r_result_type;
        end 
    end 

    // always @(posedge i_clk) begin
    //     if(i_rst)
    //         ro_port_ack <= 10'd0;
    //     else 
    //         ro_port_ack <= {w_arbiter_result[0],w_arbiter_result[1],w_arbiter_result[2],w_arbiter_result[3],w_arbiter_result[4],
    //                         w_arbiter_result[5],w_arbiter_result[6],w_arbiter_result[7],w_arbiter_result[8],w_arbiter_result[9]};
    // end 


    always @(posedge i_clk) begin
        if(i_rst)
            ro_port_ack <= 10'd0;
        else 
            ro_port_ack <= w_arbiter_result;
    end 
    always @(posedge i_clk) begin
        if(i_rst)
            ro_port_vld <= 1'b0;
        else begin
            ro_port_vld <= (w_result_valid == 1'b1) ? 1'b1 : 
                           1'b0 ;
        end
    end 

endmodule