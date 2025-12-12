// 静态 MAC 地址表项采用分布式寄存器并行查表方式
module smac_mng #(
        parameter                           PORT_NUM                =      4                    ,     // 交换机的端口数
        parameter                           STATIC_RAM_SIZE         =      128                        // 地址表的深度
)(  
        input               wire                                    i_clk                       ,
        input               wire                                    i_rst                       ,
        /*----------------------------- 控制寄存器接口 ------------------------------*/
		input				wire		[68:0]						i_din						, //写数据，其中[47:0]为MAC地址，[60:48]为VLAN字段，[68:61为]转发端口
		input				wire		[1:0]						i_we						, //RAM操作符：00-无效操作；01-写操作；10：读操作；11-删除操作
		input				wire		[$clog2(STATIC_RAM_SIZE)-1:0]i_addr						, //操作表项地址
		output				wire		[68:0]						o_dout						, //输出表项的数据
		input				wire									i_smac_list_clr				,
        /*----------------------------- 查找 DMAC 输入 ------------------------------*/
        input               wire        [59:0]                      i_lookup_in                 , //查表数据（Vlan id + MAC）[60:48] - vlan id [47:0] - mac
        input               wire                                    i_lookup_vld                , //查表数据有效标志位
        /*----------------------------- 表项的状态 ------------------------------*/
        output              wire        [7:0]                       o_smac_list_num             , //有效写入表项的个数
        output              wire                                    o_smac_list_full            , //表满标志位
		output				wire									o_smac_list_empty			, //表空标志位
		output				wire		[15:0]						o_smac_list_clash_num		, //写入表项冲突计数器，写入冲突：写入表项时需检查表项中是否已经存在，若存在则为写入冲突
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        output               wire   [PORT_NUM-1: 0]                 o_smac_tx_port_rslt         , // 输出的转发端口bitmap,最高位为1，代表该报文是本地网卡设备的，将该报文转到内部网卡端口处理
        output               wire                                   o_smac_tx_port_vld          
);
	//==========================================================================
	//    69bit 分布式寄存器阵列
	//    bit[68]: Valid标志位
	//    bit[67:60]: 转发端口 bitmap（8bit）
	//    bit[59:48]: VLAN ID (12bit)
	//    bit[47:0] : MAC 地址 (48bit)
	//==========================================================================
	reg [68:0] mem [0:STATIC_RAM_SIZE-1];
	genvar i;

	//==========================================================================
	// 2. 复位 & 配置接口逻辑
	//==========================================================================
	wire nop_en		;
	wire write_en  	;
	wire read_en   	;
	wire delete_en 	;
	
	reg [15:0] r_smac_list_clash_num;
	reg [68:0] r_dout;
	reg        hit_found;
	reg  [7:0] hit_bitmap;
	reg  [7:0] r_valid_cnt; 
	reg  	   r_smac_list_full;
	reg  	   r_smac_list_empty;

	
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
				end
			end
		end
		
		for (i = 0; i < STATIC_RAM_SIZE; i = i + 1) begin
			always @(posedge i_clk) begin
				if (i_rst) begin
					mem[i] <= 69'd0;
				end else if (i_smac_list_clr) begin
					mem[i] <= 69'd0;
				end else if (write_en && !clash_flag && !r_smac_list_full) begin
					mem[i_addr] <= i_din;  
				end else if (delete_en) begin
					mem[i_addr] <= 69'd0;
				end
			end
		end
	endgenerate
	
	assign clash_flag = |clash_det;

	always @(posedge i_clk) begin
		if (i_rst) begin
			r_dout  <= 69'd0;
		end
		else if (read_en && !r_smac_list_empty) begin
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
	assign o_smac_tx_port_rslt = hit_bitmap[PORT_NUM-1:0];
	assign o_smac_tx_port_vld  = hit_found;
	
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
		else if(write_en && !clash_flag && r_smac_list_full && i_din[68]) begin
			r_valid_cnt <= r_valid_cnt + 1'b1;
		end else if(delete_en) begin
			r_valid_cnt <= r_valid_cnt - 1'b1;
		end
	end

	assign o_smac_list_num = r_valid_cnt;

	always @(posedge i_clk) begin
		if (i_rst) begin
			r_smac_list_full <= 1'b0;
		end else if((r_valid_cnt == STATIC_RAM_SIZE - 1'b1) && (write_en == 1'b1) && (!clash_flag)) begin
			r_smac_list_full <= 1'b1;
		end else if(r_smac_list_full == 1'b1 && delete_en == 1'b1) begin
			r_smac_list_full <= 1'b0;
		end
	end
	
	always @(posedge i_clk) begin
		if (i_rst) begin
			r_smac_list_empty <= 1'b1;
		end else if(r_valid_cnt == 8'd0 && delete_en == 1'b1) begin
			r_smac_list_empty <= 1'b1;
		end else if(r_valid_cnt != 8'd0)begin
			r_smac_list_empty <= 1'b0;
		end
	end

	assign o_smac_list_full  = r_smac_list_full;
	assign o_smac_list_empty = r_smac_list_empty;

endmodule