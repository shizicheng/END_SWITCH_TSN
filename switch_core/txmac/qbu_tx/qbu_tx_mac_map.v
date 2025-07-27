module qbu_tx_mac_map#(
    parameter                                           AXIS_DATA_WIDTH     = 'd8   ,
                                                        QUEUE_NUM           = 'd8    
)(
    input           wire                                i_clk                       ,
    input           wire                                i_rst                       ,
    //缓存队列需要发送的数据
    input           wire    [AXIS_DATA_WIDTH - 1:0]     i_mac_tx_axis_data          ,
    input           wire    [(AXIS_DATA_WIDTH/8)-1:0]   i_mac_tx_axis_keep          , //keep数据掩码
    input           wire                                i_mac_tx_axis_last          ,
    input           wire                                i_mac_tx_axis_valid         ,
    output          wire                                o_mac_tx_axis_ready         ,
    //数据优先级
    input           wire    [QUEUE_NUM - 1:0]           i_tx_mac_forward_info       , //来自哪个通道的数据，哪个通道就为1
    input           wire                                i_tx_mac_forward_info_vld   ,           
    //经过映射后的eMAC和pMAC数据
    output          wire    [AXIS_DATA_WIDTH - 1:0]     o_emac_tx_axis_data         ,
    output          wire    [15:0]                      o_emac_tx_axis_user         ,
    output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   o_emac_tx_axis_keep         ,
    output          wire                                o_emac_tx_axis_last         ,
    output          wire                                o_emac_tx_axis_valid        ,
    output          wire    [15:0]                      o_emac_tx_axis_type         ,
    input           wire                                i_emac_tx_axis_ready        ,

    output          wire    [AXIS_DATA_WIDTH - 1:0]     o_pmac_tx_axis_data  	    ,
    output          wire    [15:0]                      o_pmac_tx_axis_user  	    ,
    output          wire    [(AXIS_DATA_WIDTH/8)-1:0]   o_pmac_tx_axis_keep  	    ,
    output          wire                                o_pmac_tx_axis_last  	    ,
    output          wire                                o_pmac_tx_axis_valid 	    ,
    output          wire    [15:0]                      o_pmac_tx_axis_type  	    , 
    input           wire                                i_pmac_tx_axis_ready        

);

// 内部reg信号定义
reg  [AXIS_DATA_WIDTH-1:0]      r_emac_tx_axis_data      ;
reg  [15:0]                     r_emac_tx_axis_user      ;
reg  [(AXIS_DATA_WIDTH/8)-1:0]  r_emac_tx_axis_keep      ;
reg                             r_emac_tx_axis_last      ;
reg                             r_emac_tx_axis_valid     ;
reg  [15:0]                     r_emac_tx_axis_type      ;

reg  [AXIS_DATA_WIDTH-1:0]      r_pmac_tx_axis_data      ;
reg  [15:0]                     r_pmac_tx_axis_user      ;
reg  [(AXIS_DATA_WIDTH/8)-1:0]  r_pmac_tx_axis_keep      ;
reg                             r_pmac_tx_axis_last      ;
reg                             r_pmac_tx_axis_valid     ;
reg  [15:0]                     r_pmac_tx_axis_type      ;

// ready信号
wire                            w_emac_ready             ;
wire                            w_pmac_ready             ;

// 映射选择信号
wire                            w_emac_sel               ;
wire                            w_pmac_sel               ;

// 只允许一个通道有效
assign w_emac_sel           = i_tx_mac_forward_info_vld && (i_tx_mac_forward_info[0] || i_tx_mac_forward_info[1]);
assign w_pmac_sel           = i_tx_mac_forward_info_vld && (~w_emac_sel);

// ready信号
assign w_emac_ready         = i_emac_tx_axis_ready;
assign w_pmac_ready         = i_pmac_tx_axis_ready;

// AXI ready输出
assign o_mac_tx_axis_ready  = (w_emac_sel && w_emac_ready) || (w_pmac_sel && w_pmac_ready);

// eMAC数据输出
assign o_emac_tx_axis_data  = r_emac_tx_axis_data  ;
assign o_emac_tx_axis_user  = r_emac_tx_axis_user  ;
assign o_emac_tx_axis_keep  = r_emac_tx_axis_keep  ;
assign o_emac_tx_axis_last  = r_emac_tx_axis_last  ;
assign o_emac_tx_axis_valid = r_emac_tx_axis_valid ;
assign o_emac_tx_axis_type  = r_emac_tx_axis_type  ;

// pMAC数据输出
assign o_pmac_tx_axis_data  = r_pmac_tx_axis_data  ;
assign o_pmac_tx_axis_user  = r_pmac_tx_axis_user  ;
assign o_pmac_tx_axis_keep  = r_pmac_tx_axis_keep  ;
assign o_pmac_tx_axis_last  = r_pmac_tx_axis_last  ;
assign o_pmac_tx_axis_valid = r_pmac_tx_axis_valid ;
assign o_pmac_tx_axis_type  = r_pmac_tx_axis_type  ;

// 数据映射逻辑
always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        r_emac_tx_axis_data  <= {AXIS_DATA_WIDTH{1'b0}};
        r_emac_tx_axis_user  <= 16'd0;
        r_emac_tx_axis_keep  <= {(AXIS_DATA_WIDTH/8){1'b0}};
        r_emac_tx_axis_last  <= 1'b0;
        r_emac_tx_axis_valid <= 1'b0;
        r_emac_tx_axis_type  <= 16'd0;

        r_pmac_tx_axis_data  <= {AXIS_DATA_WIDTH{1'b0}};
        r_pmac_tx_axis_user  <= 16'd0;
        r_pmac_tx_axis_keep  <= {(AXIS_DATA_WIDTH/8){1'b0}};
        r_pmac_tx_axis_last  <= 1'b0;
        r_pmac_tx_axis_valid <= 1'b0;
        r_pmac_tx_axis_type  <= 16'd0;
    end
    else begin
        // eMAC通道
        if(w_emac_sel && i_mac_tx_axis_valid && w_emac_ready) begin
            r_emac_tx_axis_data  <= i_mac_tx_axis_data;
            r_emac_tx_axis_user  <= {14'd0, i_tx_mac_forward_info[1], i_tx_mac_forward_info[0]}; //可自定义
            r_emac_tx_axis_keep  <= i_mac_tx_axis_keep;
            r_emac_tx_axis_last  <= i_mac_tx_axis_last;
            r_emac_tx_axis_valid <= 1'b1;
            r_emac_tx_axis_type  <= 16'h0001; //可自定义
        end
        else begin
            r_emac_tx_axis_valid <= 1'b0;
        end

        // pMAC通道
        if(w_pmac_sel && i_mac_tx_axis_valid && w_pmac_ready) begin
            r_pmac_tx_axis_data  <= i_mac_tx_axis_data;
            r_pmac_tx_axis_user  <= {8'd0, i_tx_mac_forward_info}; //可自定义
            r_pmac_tx_axis_keep  <= i_mac_tx_axis_keep;
            r_pmac_tx_axis_last  <= i_mac_tx_axis_last;
            r_pmac_tx_axis_valid <= 1'b1;
            r_pmac_tx_axis_type  <= 16'h0002; //可自定义
        end
        else begin
            r_pmac_tx_axis_valid <= 1'b0;
        end
    end
end

endmodule
