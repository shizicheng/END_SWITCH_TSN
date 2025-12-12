module swlist_regs #(
        parameter                           REG_ADDR_BUS_WIDTH      =      8                                    ,   // 接收 MAC 层的配置寄存器地??位宽
        parameter                           REG_DATA_BUS_WIDTH      =      16                                   ,   // 接收 MAC 层的配置寄存器数据位??
        parameter                           AGE_TIME_WIDTH          =      10                                   ,   // 老化时间位宽，支??1024??
        parameter                           TABLE_FULL_THRESHOLD    =      29491                                ,   // MAC表满阈???（90% of 32K = 29491??
        parameter                           AGE_SCAN_INTERVAL       =      5                                    ,   // 老化扫描间隔（秒??
        parameter                           HASH_DATA_WIDTH         =      15                                   ,
        parameter                           SIM_MODE                =      0                                        // 仿真模式??1=快???仿真模式，0=正常模式
)(                      
        input               wire                                        i_clk                                   ,
        input               wire                                        i_rst                                   , 
        /*----------------------------- 寄存器写控制接口 ------------------------------*/     
        input               wire                                        i_reg_bus_we                            , // 寄存器写使能
        input               wire        [REG_ADDR_BUS_WIDTH-1:0]        i_reg_bus_addr                          , // 寄存器写地址
        input               wire        [REG_DATA_BUS_WIDTH-1:0]        i_reg_bus_data                          , // 寄存器写数据
        input               wire                                        i_reg_bus_data_vld                      , // 寄存器写数据使能
        
        /*----------------------------- 寄存器读控制接口 ------------------------------*/
        input               wire                                        i_reg_bus_re                            , // 寄存器读使能
        input               wire        [REG_ADDR_BUS_WIDTH-1:0]        i_reg_bus_raddr                         , // 寄存器读地址
        output              wire        [REG_DATA_BUS_WIDTH-1:0]        o_reg_bus_rdata                         , // 寄存器读数据
        output              wire                                        o_reg_bus_rdata_vld                     , // 寄存器读数据有效
        
        input               wire        [HASH_DATA_WIDTH-1:0]           i_mac_table_addr                        ,
        input               wire        [3:0]                           i_fsm_cur_state                         ,

        output              wire                                        o_table_clear_req                       ,
        output              wire        [AGE_TIME_WIDTH-1:0]            o_age_time_threshold                    ,
        output              wire                                        o_table_rd                              ,
        output              wire        [11:0]                          o_table_raddr                           ,
        output              wire        [14:0]                          o_table_full_threshold                  , // MAC表满阈???配置寄存器
        output              wire        [31:0]                          o_age_scan_interval                     , // 老化扫描间隔配置寄存器（秒）
		
		// SMAC
		output				wire		[1:0]							o_smac_list_we							,
		output				wire		[68:0]							o_smac_list_din							,
		output				wire		[7:0]							o_smac_list_addr						,
		input				wire		[68:0]							i_smac_list_dout						,
		output				wire										o_smac_list_clr							,


        input               wire        [57:0]                          i_dmac_list_dout                        ,
        input               wire        [15:0]                          i_dmac_list_cnt                         ,
        input               wire                                        i_dmac_list_full_er_stat                ,
        input               wire        [15:0]                          i_dmac_list_full_er_cnt                 ,

        input               wire        [14:0]                          i_table_entry_cnt                       ,
        input               wire        [15:0]                          i_learn_success_cnt                     ,
        input               wire        [REG_DATA_BUS_WIDTH-1:0]        i_collision_cnt                         ,
        input               wire        [REG_DATA_BUS_WIDTH-1:0]        i_port_move_cnt                        
);

/*---------------------------------------- SMAC寄存器地址定义 -------------------------------------------*/
localparam	REG_SMAC_LIST_CLR			= 8'h00								; // SMAC表清空操作
localparam	REG_SMAC_LIST_WE			= 8'h01								; // SMAC表读写操作
localparam	REG_SMAC_LIST_DIN_0			= 8'h02								; // [47:32]
localparam	REG_SMAC_LIST_DIN_1			= 8'h03								; // [31:16]
localparam	REG_SMAC_LIST_DIN_2			= 8'h04								; // [15:0]
localparam	REG_SMAC_LIST_DIN_3			= 8'h05								; // [60:48] VLAN ID
localparam	REG_SMAC_LIST_DIN_4			= 8'h06								; // [67:61] port
localparam	REG_SMAC_LIST_DIN_VALID		= 8'h07								;
localparam	REG_SMAC_LIST_WRADDR		= 8'h08								;
localparam	REG_SMAC_LIST_DOUT_0		= 8'h09								; // [47:32]
localparam	REG_SMAC_LIST_DOUT_1		= 8'h0A								; // [31:16]
localparam	REG_SMAC_LIST_DOUT_2		= 8'h0B								; // [15:0]
localparam	REG_SMAC_LIST_DOUT_3		= 8'h0C								; // [60:48] VLAN ID
localparam	REG_SMAC_LIST_DOUT_4		= 8'h0D								; // [67:61] port
localparam	REG_SMAC_LIST_DOUT_VALID	= 8'h0E								;

/*---------------------------------------- DMAC寄存器地址定义 -------------------------------------------*/
localparam  REG_DMAC_TABLE_CLEAR        = 8'h10                             ; // MAC表清空寄存器
localparam  REG_AGE_TIME_THRESHOLD      = 8'h11                             ; // 老化时间阈值配置寄存器
localparam  REG_DMAC_TABLE_RD           = 8'h12                             ;
localparam  REG_DMAC_TABLE_RADDR        = 8'h13                             ;
localparam  REG_DMAC_TABLE_DOUT0        = 8'h14                             ;
localparam  REG_DMAC_TABLE_DOUT1        = 8'h15                             ;
localparam  REG_DMAC_TABLE_DOUT2        = 8'h16                             ;
localparam  REG_DMAC_TABLE_NUM          = 8'h41                             ;
localparam  REG_DMAC_TABLE_FULL_ERSTAT  = 8'h44                             ;
localparam  REG_DMAC_TABLE_FULL_ERCNT   = 8'h48                             ;
localparam  REG_TABLE_FULL_THRESHOLD    = 8'h50                             ; // MAC表满阈值配置寄存器
localparam  REG_AGE_SCAN_INTERVAL       = 8'h51                             ; // 老化扫描间隔配置寄存器
localparam  REG_TABLE_ENTRY_CNT         = 8'h52                             ; // MAC表项计数器(只读)
localparam  REG_LEARN_STATISTICS        = 8'h53                             ; // MAC学习统计寄存器(只读)
localparam  REG_COLLISION_STATISTICS    = 8'h54                             ; // 哈希冲突统计寄存器(只读)
localparam  REG_PORT_MOVE_STATISTICS    = 8'h55                             ; // 端口移动统计寄存器(只读)
/*---------------------------------------- 状态机定义 -------------------------------------------*/
localparam  IDLE                        = 4'd0                              ; // 空闲状???
localparam  FIFO_READ_WAIT              = 4'd1                              ; // FIFO读取等待状???（STD模式??要）
localparam  DMAC_LOOKUP                 = 4'd2                              ; // DMAC查表状???
localparam  DMAC_REFRESH                = 4'd3                              ; // DMAC命中老化时间刷新状???
localparam  SMAC_LEARN_CHECK            = 4'd4                              ; // SMAC学习??查状??
localparam  SMAC_LEARN_UPDATE           = 4'd5                              ; // SMAC学习更新状???
localparam  AGE_SCAN                    = 4'd6                              ; // 老化扫描状???
localparam  AGE_UPDATE                  = 4'd7                              ; // 老化更新状???
// 配置寄存??
// 寄存器相关信???  
reg                                     r_reg_bus_we                        ;
reg         [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg         [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                     r_reg_bus_data_vld                  ;

// 寄存器读控制信号
reg                                     r_reg_bus_re                        ;
reg         [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg         [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                     r_reg_bus_rdata_vld                 ;

reg         [AGE_TIME_WIDTH-1:0]        r_age_time_threshold                ; // 老化时间阈???（默认300秒）
reg                                     r_table_clear_req                   ; // 表清空请??
reg         [14:0]                      r_table_full_threshold              ; // MAC表满阈???配置寄存器
reg         [31:0]                      r_age_scan_interval                 ; // 老化扫描间隔配置寄存器（秒）
reg                                     r_table_rd;
reg         [11:0]                      r_table_raddr;


reg			[1:0]						r_smac_list_we						;
reg			[67:0]						r_smac_list_din						;
reg			[7:0]						r_smac_list_addr					;
reg										r_smac_list_clr						;

/*========================================  输入数据管理 ========================================*/
// FIFO输入缓存管理：支持连续输入???不会覆盖正在处理的数据
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we       <= i_reg_bus_we;
        r_reg_bus_addr     <= i_reg_bus_addr;
        r_reg_bus_data     <= i_reg_bus_data;
        r_reg_bus_data_vld <= i_reg_bus_data_vld;
        r_reg_bus_re       <= i_reg_bus_re;
        r_reg_bus_raddr    <= i_reg_bus_raddr;
    end
end

/*======================================== 配置寄存器管?? ========================================*/
// 表清空请求寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_clear_req <= 1'b0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_DMAC_TABLE_CLEAR)) begin
        r_table_clear_req <= r_reg_bus_data[0];
    end else if ((r_table_clear_req == 1'd1) && (i_mac_table_addr == {HASH_DATA_WIDTH{1'b1}}) && (i_fsm_cur_state == AGE_SCAN)) begin
        r_table_clear_req <= 1'b0;
    end
end

// 老化时间阈???配置寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_time_threshold <= 10'd300;
    end else if(SIM_MODE == 1) begin
        r_age_time_threshold <= 10'd8;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_AGE_TIME_THRESHOLD)) begin
        r_age_time_threshold <= r_reg_bus_data[AGE_TIME_WIDTH-1:0];
    end
end

// 表满阈???配置寄存器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_full_threshold <= TABLE_FULL_THRESHOLD;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_TABLE_FULL_THRESHOLD)) begin
        r_table_full_threshold <= r_reg_bus_data[14:0];
    end
end

// 老化扫描间隔配置寄存??
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_age_scan_interval <= AGE_SCAN_INTERVAL;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_AGE_SCAN_INTERVAL)) begin
        r_age_scan_interval <= {{16{1'b0}}, r_reg_bus_data};
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_rd <= 1'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_DMAC_TABLE_RD)) begin
        r_table_rd <= r_reg_bus_data[0];
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_table_raddr   <=  12'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_DMAC_TABLE_RADDR)) begin
        r_table_raddr   <= r_reg_bus_data[11:0];
    end
end

assign o_table_clear_req                        = r_table_clear_req;
assign o_age_time_threshold                     = r_age_time_threshold;
assign o_table_full_threshold                   = r_table_full_threshold;
assign o_age_scan_interval                      = r_age_scan_interval;
assign o_table_rd                               = r_table_rd;
assign o_table_raddr                            = r_table_raddr;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_smac_list_clr   <=  1'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_CLR)) begin
        r_smac_list_clr   <= r_reg_bus_data[0];
    end else begin
		r_smac_list_clr   <=  1'd0;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_smac_list_we   <=  2'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_WE)) begin
        r_smac_list_we   <= r_reg_bus_data[1:0];
    end else begin
		r_smac_list_we   <=  2'd0;
	end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_smac_list_din   <=  68'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_0)) begin
        r_smac_list_din[47:32]   <= r_reg_bus_data[15:0];
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_1)) begin
        r_smac_list_din[31:16]   <= r_reg_bus_data[15:0];
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_2)) begin
        r_smac_list_din[15:0]   <= r_reg_bus_data[15:0];
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_3)) begin
        r_smac_list_din[59:48]   <= r_reg_bus_data[11:0];
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_4)) begin
        r_smac_list_din[67:60]   <= r_reg_bus_data[7:0];
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_DIN_VALID)) begin
        r_smac_list_din[68]   <= r_reg_bus_data[0];
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_smac_list_addr   <=  8'd0;
    end else if ((r_reg_bus_we == 1'd1) && (r_reg_bus_data_vld == 1'd1) && (r_reg_bus_addr == REG_SMAC_LIST_WRADDR)) begin
        r_smac_list_addr   <= r_reg_bus_data[7:0];
    end
end


assign o_smac_list_addr  = r_smac_list_addr;
assign o_smac_list_clr   = r_smac_list_clr;
assign o_smac_list_din   = r_smac_list_din;
assign o_smac_list_we    = r_smac_list_we;

/*======================================== 寄存器读控制逻辑 ========================================*/
// 寄存器读数据逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            REG_AGE_TIME_THRESHOLD: begin
                // 自???应位宽:直接截取或扩??,防止REG_DATA_BUS_WIDTH<AGE_TIME_WIDTH时出??
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_age_time_threshold[AGE_TIME_WIDTH-1:0];
            end
            REG_DMAC_TABLE_CLEAR: begin
                r_reg_bus_rdata <= {{(REG_DATA_BUS_WIDTH-1){1'b0}}, r_table_clear_req};
            end
            REG_TABLE_FULL_THRESHOLD: begin
                // 自???应位宽:直接截取低位,防止REG_DATA_BUS_WIDTH<15时出??
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | r_table_full_threshold[14:0];
            end
            REG_AGE_SCAN_INTERVAL: begin 
                r_reg_bus_rdata <= r_age_scan_interval[REG_DATA_BUS_WIDTH-1:0]; 
            end
            REG_DMAC_TABLE_RD: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}}, r_table_rd}; 
            end
            REG_DMAC_TABLE_RADDR: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-12{1'b0}}, r_table_raddr[11:0]}; 
            end
            REG_DMAC_TABLE_DOUT0: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}}, i_dmac_list_dout[31:16]}; 
            end
            REG_DMAC_TABLE_DOUT1: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}}, i_dmac_list_dout[15:0]}; 
            end
            REG_DMAC_TABLE_DOUT2: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-9{1'b0}}, i_dmac_list_dout[57:48]}; 
            end
            REG_DMAC_TABLE_NUM: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}}, i_dmac_list_cnt[15:0]}; 
            end
            REG_DMAC_TABLE_FULL_ERSTAT: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}}, i_dmac_list_full_er_stat}; 
            end
            REG_DMAC_TABLE_FULL_ERCNT: begin 
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-16{1'b0}}, i_dmac_list_full_er_cnt[15:0]}; 
            end
            REG_TABLE_ENTRY_CNT: begin 
                // 自???应位宽:直接截取低位,防止REG_DATA_BUS_WIDTH<15时出??
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH{1'b0}}} | i_table_entry_cnt[14:0]; 
            end
            REG_LEARN_STATISTICS: begin
                r_reg_bus_rdata <= {i_learn_success_cnt[15:0]};
            end
            REG_COLLISION_STATISTICS: begin
                r_reg_bus_rdata <= i_collision_cnt[REG_DATA_BUS_WIDTH-1:0];
            end
            REG_PORT_MOVE_STATISTICS: begin
                r_reg_bus_rdata <= i_port_move_cnt[REG_DATA_BUS_WIDTH-1:0];
            end
			REG_SMAC_LIST_DOUT_0: begin
                r_reg_bus_rdata <= i_smac_list_dout[47:32];
            end
			REG_SMAC_LIST_DOUT_1: begin
                r_reg_bus_rdata <= i_smac_list_dout[31:16];
            end
			REG_SMAC_LIST_DOUT_2: begin
                r_reg_bus_rdata <= i_smac_list_dout[15:0];
            end
			REG_SMAC_LIST_DOUT_3: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-12{1'b0}},i_smac_list_dout[59:48]};
            end
			REG_SMAC_LIST_DOUT_4: begin
                r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-8{1'b0}},i_smac_list_dout[67:60]};
            end
			REG_SMAC_LIST_DOUT_VALID : begin
				r_reg_bus_rdata <= {{REG_DATA_BUS_WIDTH-1{1'b0}},i_smac_list_dout[68]};
			end
            default: begin
                r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
            end
        endcase
    end else begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end
end

// 寄存器读数据有效标志
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata_vld <= 1'b0;
    end else begin
        r_reg_bus_rdata_vld <= r_reg_bus_re;
    end
end

assign o_reg_bus_rdata      = r_reg_bus_rdata;
assign o_reg_bus_rdata_vld  = r_reg_bus_rdata_vld;

endmodule