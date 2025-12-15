module clash_mac_mng #(
        parameter                           PORT_NUM                =      4                  ,   // 交换机的端口数
        parameter                           HASH_DATA_WIDTH         =      12                 ,   // 哈希计算的值的位宽
		parameter                           AGE_TIME_WIDTH          =      10                 ,   // 老化时间位宽
        parameter                           STATIC_RAM_SIZE         =      128                    // 地址表的深度
		
)(  
        input               wire                                        i_clk                 ,
        input               wire                                        i_rst                 ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
		input				wire		[68:0]							i_din				  , //写数据，其中[47:0]为MAC地址，[60:48]为VLAN字段，[68:61为]转发端口
		input				wire		[1:0]							i_we				  , //RAM操作符：00-无效操作；01-写操作；10：读操作；11-删除操作
		input				wire		[$clog2(STATIC_RAM_SIZE)-1:0]	i_addr				  , //操作表项地址
		output				wire		[68:0]							o_dout				  , //输出表项的数据
		
		input				wire										i_dmac_find_out_clash ,
		input				wire		[67:0]							i_dmac_find_info	  ,
		input				wire										i_dmac_find_info_vld  ,
		/*----------------------------- 老化表项接口 ------------------------------*/
        input               wire        [AGE_TIME_WIDTH-1:0]            i_cfg_live_time       ,
		input				wire										i_cfg_live_time_vld	  ,
        /*----------------------------- 表项的状态 ------------------------------*/
        output              wire        [7:0]                       	o_clash_mac_list_num  , //有效写入表项的个数
        output              wire                                    	o_clash_mac_list_full , //表满标志位
		output				wire										o_clash_mac_list_empty, //表空标志位
		output				wire		[15:0]							o_clash_mac_list_clash_num, //写入表项冲突计数器，写入冲突：写入表项时需检查表项中是否已经存在，若存在则为写入冲突
        /*----------------------------- 查找 DMAC 输入 ------------------------------*/
        input               wire        [59:0]                      	i_lookup_in           , //查表数据（Vlan id + MAC）[60:48] - vlan id [47:0] - mac
        input               wire                                    	i_lookup_vld          , //查表数据有效标志位
        /*----------------------------- 查表输出接口接口 ------------------------------*/     
        output              wire                                        o_clash_tx_port_rslt  ,
        output              wire        [PORT_NUM:0]                    o_clash_tx_port_vld          
);

//==========================================================================
//    69bit 分布式寄存器阵列
//    bit[68]: Valid标志位
//    bit[67:60]: 转发端口 bitmap（8bit）
//    bit[59:48]: VLAN ID (12bit)
//    bit[47:0] : MAC 地址 (48bit)
//==========================================================================
reg [68:0] 					mem 		[0:STATIC_RAM_SIZE-1];
reg [AGE_TIME_WIDTH-1:0]    timestamp   [0:STATIC_RAM_SIZE-1];
genvar 		i;

//==========================================================================
// 2. 复位 & 配置接口逻辑
//==========================================================================
wire 									nop_en					;
wire 									write_en  				;
wire 									read_en   				;
wire 									delete_en 				;
reg 		[15:0] 						r_smac_list_clash_num	;
reg 		[68:0] 						r_dout					;
reg 		       						hit_found				;
reg 		[7:0] 						hit_bitmap				;
reg 		[7:0] 						r_valid_cnt				; 
reg 		 	   						r_clash_mac_list_full	;
reg 		 	   						r_clash_mac_list_empty	;

// 老化相关信号
reg                                     r_age_timer_pulse                   ; // 老化定时器脉冲（1秒脉冲）
reg         [AGE_TIME_WIDTH-1:0]        r_global_timestamp                  ; // 全局时间戳计数器（秒）
// 分级时间计数器相关信
reg         [15:0]                      r_us_cnt                            ; // 微秒计数器（1-65535us，支持不同时钟频率）
reg         [9:0]                       r_ms_cnt                            ; // 毫秒计数??
reg         [31:0]                      r_s_cnt                             ; // 毫秒总计数器（用于1秒脉冲生成）
reg                                     r_us_pulse                          ;  
reg                                     r_ms_pulse                          ;  

// 时间计算 - 支持仿真模式和正常模
localparam  US_CNT_MAX                  = SIM_MODE ? 16'd5 : CLK_FREQ_MHZ   ; // 仿真模式??10个时钟周??=1us，正常模式：CLK_FREQ_MHZ个时钟周??=1us
localparam  MS_CNT_MAX                  = SIM_MODE ? 10'd5 : 10'd1000       ; // 仿真模式??10us=1ms，正常模式：1000us=1ms  
localparam  S_CNT_MAX                   = SIM_MODE ? 10'd5 : 10'd1000       ; // 仿真模式??10ms=1s，正常模式：1000ms=1s  

	
	assign nop_en    = (i_we == 2'b00);
	assign write_en  = (i_we == 2'b01);
	assign read_en   = (i_we == 2'b10);
	assign delete_en = (i_we == 2'b11);
	
	// 写冲突检测（组合逻辑，写前全表扫描）
	reg  [255:0] clash_det;
	wire		 clash_flag;
	generate 
		for (i = 0; i < STATIC_RAM_SIZE; i = i + 1) begin
			always @(posedge i_clk) begin
				if (i_rst) begin
					clash_det[i] = 1'b0;
				end else if (write_en) begin
					if (mem[i][68] == 1'b1 &&           // 已有有效条目
						mem[i][59:48] == i_din[59:48] &&           // VLAN 相同
						mem[i][47:0]  == i_din[47:0]) begin        // MAC  相同
						clash_det[i] = 1'b1;
					end
					else begin
						clash_det[i] = 1'b0;
					end
				end else if (i_dmac_find_out_clash) begin
					if (mem[i][68] == 1'b1 &&           // 已有有效条目
						mem[i][59:48] == i_dmac_find_info[59:48] &&           // VLAN 相同
						mem[i][47:0]  == i_dmac_find_info[47:0]) begin        // MAC  相同
						clash_det[i] = 1'b1;
					end
					else begin
						clash_det[i] = 1'b0;
					end
				end
			end
		end
		
		for (i = 0; i < STATIC_RAM_SIZE; i = i + 1) begin
			always @(posedge i_clk) begin
				if (i_rst) begin
					mem[i] <= 69'd0;
				end else if (i_smac_list_clr) begin
					mem[i] <= 69'd0;
				end else if (write_en && !clash_flag && !r_clash_mac_list_full) begin
					mem[i_addr] <= i_din;  
				end else if (i_dmac_find_out_clash && !clash_flag && !r_clash_mac_list_full) begin
					mem[i_addr] <= i_dmac_find_info;  
				end else if (delete_en) begin
					mem[i_addr] <= 69'd0;
				end
			end
		end
		
		for (i = 0; i < STATIC_RAM_SIZE; i = i + 1) begin
			always @(posedge i_clk) begin
				if (i_rst) begin
					timestamp[i] <= {AGE_TIME_WIDTH{1'd0}};
				end else if (i_smac_list_clr) begin
					timestamp[i] <= {AGE_TIME_WIDTH{1'd0}};
				end else if (write_en && !clash_flag && !r_clash_mac_list_full) begin
					timestamp[i_addr] <= r_global_timestamp;  
				end else if (i_dmac_find_out_clash && !clash_flag && !r_clash_mac_list_full) begin
					timestamp[i_addr] <= r_global_timestamp;  
				end else if (delete_en) begin
					timestamp[i_addr] <= 69'd0;
				end
			end
		end
	endgenerate
	
	assign clash_flag = |clash_det;

	always @(posedge i_clk) begin
		if (i_rst) begin
			r_dout  <= 69'd0;
		end
		else if (read_en && !r_clash_mac_list_empty) begin
			r_dout 	<= mem[i_addr];
		end
	end
	
	assign o_dout = r_dout;

	always @(posedge i_clk) begin
		if (i_rst) begin
			r_smac_list_clash_num <= 16'd0;
		end
		else if(write_en && clash_flag) begin
			r_smac_list_clash_num <= r_smac_list_clash_num + 1'b1;
		end
	end

	assign o_smac_list_clash_num = r_smac_list_clash_num;
	//==========================================================================
	// 3. 全并行查表（256路并行比较器）
	//==========================================================================
	assign o_clash_tx_port_rslt = hit_bitmap[PORT_NUM-1:0];
	assign o_clash_tx_port_vld  = hit_found;
	
	integer j;
	always @(posedge i_clk) begin
		if (i_rst) begin
			hit_found  = 1'b0;
			hit_bitmap = 8'd0;
		end
		else if (i_lookup_vld && nop_en) begin
			for (j = 0; j < STATIC_RAM_SIZE; j = j + 1) begin
				if (mem[j][68] && 
					mem[j][59:48] == i_lookup_in[59:48] && 
					mem[j][47:0]  == i_lookup_in[47:0]) begin
					hit_found  = 1'b1;
					hit_bitmap = mem[j][67:60];   // 取出端口 bitmap
				end
			end
		end
		else begin
			hit_found  = 1'b0;
		end
	end

	//==========================================================================
	// 4. 有效表项计数（实时统计）
	//==========================================================================
	
	always @(posedge i_clk) begin
		if (i_rst) begin
			r_valid_cnt = 8'd0;
		end
		else if(write_en && !clash_flag && r_clash_mac_list_full && i_din[68]) begin
			r_valid_cnt <= r_valid_cnt + 1'b1;
		end else if(delete_en) begin
			r_valid_cnt <= r_valid_cnt - 1'b1;
		end
	end

	assign o_smac_list_num = r_valid_cnt;

	always @(posedge i_clk) begin
		if (i_rst) begin
			r_clash_mac_list_full <= 1'b0;
		end else if((r_valid_cnt == STATIC_RAM_SIZE - 1'b1) && (write_en == 1'b1) && (!clash_flag)) begin
			r_clash_mac_list_full <= 1'b1;
		end else if(r_clash_mac_list_full == 1'b1 && delete_en == 1'b1) begin
			r_clash_mac_list_full <= 1'b0;
		end
	end
	
	always @(posedge i_clk) begin
		if (i_rst) begin
			r_clash_mac_list_empty <= 1'b1;
		end else if(r_valid_cnt == 8'd0 && delete_en) begin
			r_clash_mac_list_empty <= 1'b1;
		end else if(r_valid_cnt != 8'd0)begin
			r_clash_mac_list_empty <= 1'b0;
		end
	end

	assign o_clash_mac_list_full  = r_clash_mac_list_full;
	assign o_clash_mac_list_empty = r_clash_mac_list_empty;

/*======================================== 时间计数?? ========================================*/
	// 微秒计数器  
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_us_cnt <= 16'd0;
		end else if (r_us_cnt >= US_CNT_MAX - 1) begin
			r_us_cnt <= 16'd0;
		end else begin
			r_us_cnt <= r_us_cnt + 1'b1;
		end
	end

	// 微秒脉冲信号生成  
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_us_pulse <= 1'b0;
		end else begin
			r_us_pulse <= (r_us_cnt == US_CNT_MAX - 1);
		end
	end
	// 毫秒计数器  
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_ms_cnt <= 10'd0;
		end else if (r_us_pulse) begin
			if (r_ms_cnt >= MS_CNT_MAX - 1) begin
				r_ms_cnt <= 10'd0;
			end else begin
				r_ms_cnt <= r_ms_cnt + 1'b1;
			end
		end
	end

	// 毫秒脉冲信号生成  
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_ms_pulse <= 1'b0;
		end else begin
			r_ms_pulse <= r_us_pulse == 1'd1 && (r_ms_cnt == MS_CNT_MAX - 1) ? 1'd1 : 1'd0;
		end
	end

	// 毫秒总计数器 
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_s_cnt <= 32'd0;
		end else if (r_ms_pulse) begin
			if (r_s_cnt >= S_CNT_MAX - 1) begin
				r_s_cnt <= 32'd0;
			end else begin
				r_s_cnt <= r_s_cnt + 1'b1;
			end
		end
	end

	// 1秒脉冲信号
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_age_timer_pulse <= 1'b0;
		end else begin
			r_age_timer_pulse <= r_ms_pulse == 1'd1 && (r_s_cnt == S_CNT_MAX - 1) ? 1'd1 : 1'd0;
		end
	end

	// 全局时间戳计数器  
	always @(posedge i_clk or posedge i_rst) begin
		if (i_rst) begin
			r_global_timestamp <= {AGE_TIME_WIDTH{1'b0}};
		end else if (r_age_timer_pulse) begin
			r_global_timestamp <= r_global_timestamp + 1'b1;
		end
	end
	
	

	

endmodule