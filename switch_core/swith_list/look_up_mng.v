module look_up_mng #(
        parameter                           HASH_DATA_WIDTH         =      12                   ,   // 哈希计算的值的位宽
        parameter                           PORT_NUM                =      4                    ,   // 交换机的端口数
        parameter                           PORTBIT_NUM             =      clog2(PORT_NUM)      ,
        parameter                           ADDR_WIDTH              =      6                    ,   // 地址表的深度
        parameter   [47:0]                  LOCAL_MAC               = 48'h000000000001             // 本地MAC地址参数
)(  
        input               wire                                    i_clk                       ,
        input               wire                                    i_rst                       ,
        /*----------------------------- KEY仲裁结果输入 ------------------------------*/
        input               wire   [11 : 0]                         i_vlan_id                   ,   // 输入报文的VLAN ID
        input               wire   [PORT_NUM - 1:0]                 i_dmac_port                 ,   // 输入查表引擎的端口
        input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_dmac_hash_key             ,   // 目的 mac 的哈希值
        input               wire   [47 : 0]                         i_dmac                      ,   // 目的 mac 的值
        input               wire                                    i_dmac_vld                  ,   // dmac_vld
        input               wire   [HASH_DATA_WIDTH - 1 : 0]        i_smac_hash_key             ,   // 源 mac 的值有效标识
        input               wire   [47 : 0]                         i_smac                      ,   // 源 mac 的值
        input               wire                                    i_smac_vld                  ,   // smac_vld

        output              wire   [PORT_NUM  :0 ]                  o_tx_port                   ,   // 最高位为1表明为自己MAC的，不需要查表
        output              wire                                    o_tx_port_vld               ,  
        output              wire   [1:0]                            o_tx_port_broadcast         ,   // 01:组播 10：广播 11:泛洪
        /*----------------------------- SMAC 表读写接口 ------------------------------*/         
        output              wire   [47 : 0]                         o_dmac                      ,   // 目的 mac 的值
        output              wire   [11 : 0]                         o_vlan_id                   ,   // vlan_id 值
        output              wire                                    o_dmac_vld                  ,   // dmac_vld
        /*----------------------------- DMAC 表读写接口 ------------------------------*/
        output              wire   [11 : 0]                         o_dmac_item_vlan_id         ,   // vlan_id 值
        output              wire   [HASH_DATA_WIDTH-1:0]            o_dmac_item_dmac_addr       ,   // DMAC 地址表项
        output              wire                                    o_dmac_item_dmac_addr_vld   ,   // DMAC 地址表项有效位
        output              wire   [47 : 0]                         o_dmac_item_dmac            ,   // DMAC 地址表读写信号
        output              wire   [HASH_DATA_WIDTH-1:0]            o_dmac_item_smac_addr       ,   // DMAC 地址表项
        output              wire                                    o_dmac_item_smac_addr_vld   ,   // DMAC 地址表项有效位
        output              wire   [47 : 0]                         o_dmac_item_smac            ,   // DMAC 地址表读写信号 
        output              wire   [PORT_NUM - 1:0]                 o_dmac_item_mac_rx_port     ,   // DMAC 输入端口
        /*----------------------------- 哈希冲突表读写接口 ------------------------------*/
        output              wire   [11 : 0]                         o_clash_item_vlan_id        ,   // vlan_id 值
        output              wire   [HASH_DATA_WIDTH-1:0]            o_clash_item_dmac_addr      ,   // DMAC 地址表项
        output              wire                                    o_clash_item_dmac_addr_vld  ,   // DMAC 地址表项有效位
        output              wire   [47 : 0]                         o_clash_item_dmac           ,   // DMAC 地址表读写信号
        output              wire   [HASH_DATA_WIDTH-1:0]            o_clash_item_smac_addr      ,   // DMAC 地址表项
        output              wire                                    o_clash_item_smac_addr_vld  ,   // DMAC 地址表项有效位
        output              wire   [47 : 0]                         o_clash_item_smac           ,   // DMAC 地址表读写信号 
        output              wire   [PORT_NUM - 1:0]                 o_clash_item_mac_rx_port    ,   // DMAC 输入端口
        /*----------------------------- 查表的结果 ------------------------------*/
        // smac
        input               wire   [PORT_NUM-1: 0]                  i_smac_tx_port_rslt         ,  
        input               wire                                    i_smac_tx_port_vld          ,
        // dmac  
        input               wire   [PORT_NUM-1: 0]                  i_dmac_tx_port_rslt         ,
        input               wire                                    i_dmac_lookup_vld           ,  
        input               wire                                    i_dmac_lookup_clash         , // 表明在 DMAC 中，没有查找到合适的表项，转到哈希冲突表查找
		input				wire   [57:0]                          	i_dmac_list_dout			,
        // clash
        input               wire   [PORT_NUM-1: 0]                  i_clash_tx_port_rslt        , 
        input               wire                                    i_clash_tx_port_vld         
);

/*---------------------------------------- clog2计算函数 -------------------------------------------*/
function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = value - 1;
        for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
            temp = temp >> 1;
    end
endfunction 
// 输入信号打拍寄存器
reg    [11 : 0]                         ri_vlan_id                   ;   // VLAN ID打拍
reg    [PORT_NUM - 1:0]                 ri_dmac_port                 ;   // DMAC端口打拍
reg    [HASH_DATA_WIDTH - 1 : 0]        ri_dmac_hash_key             ;   // DMAC哈希值打拍
reg    [47 : 0]                         ri_dmac                      ;   // DMAC值打拍
reg                                     ri_dmac_vld                  ;   // DMAC有效信号打拍
reg    [HASH_DATA_WIDTH - 1 : 0]        ri_smac_hash_key             ;   // SMAC哈希值打拍
reg    [47 : 0]                         ri_smac                      ;   // SMAC值打拍
reg                                     ri_smac_vld                  ;   // SMAC有效信号打拍

// 查表结果输入信号打拍
reg    [PORT_NUM-1: 0]                  ri_smac_tx_port_rslt         ;   // SMAC查表结果打拍
reg                                     ri_smac_tx_port_vld          ;   // SMAC查表结果有效打拍
reg    [PORT_NUM-1: 0]                  ri_dmac_tx_port_rslt         ;   // DMAC查表结果打拍
reg                                     ri_dmac_lookup_vld           ;   // DMAC查找有效打拍
reg                                     ri_dmac_lookup_clash         ;   // DMAC查找冲突打拍
reg    [PORT_NUM-1: 0]                  ri_clash_tx_port_rslt        ;   // 冲突查表结果打拍
reg                                     ri_clash_tx_port_vld         ;   // 冲突查表结果有效打拍

// 输出寄存器
// 所有输出信号直接使用已有寄存器，无需额外输出寄存器

// 中间逻辑信号
wire                                    w_dmac_req_en                ;   // DMAC表请求使能
wire                                    w_smac_req_en                ;   // SMAC表请求使能
wire                                    w_clash_req_en               ;   // 冲突表请求使能
reg                                     r_is_self_mac                ;   // 是否为自己MAC标识
reg    [PORT_NUM-1:0]                   r_final_tx_port              ;   // 最终输出端口
reg                                     r_final_tx_port_vld          ;   // 最终输出端口有效
// reg    [2:0]                            r_lookup_state               ;   // 查表状态计数器
reg                                     r_smac_result_ready          ;   // SMAC结果准备就绪
reg                                     r_dmac_result_ready          ;   // DMAC结果准备就绪
reg                                     r_clash_result_ready         ;   // CLASH结果准备就绪
reg                                     r_all_results_ready          ;   // 所有结果准备就绪
reg    [PORT_NUM-1:0]                   r_smac_lookup_result         ;   // SMAC查表结果
reg    [PORT_NUM-1:0]                   r_dmac_lookup_result         ;   // DMAC查表结果
reg    [PORT_NUM-1:0]                   r_clash_lookup_result        ;   // CLASH查表结果
reg    [PORT_NUM-1:0]                   r_flood_port                 ;   // 泛洪端口

// MAC地址类型检测相关信号
reg    [1:0]                            r_mac_type                   ;   // MAC地址类型：00-单播，01-组播，10-广播
reg                                     r_is_broadcast               ;   // 是否为广播地址
reg                                     r_is_multicast               ;   // 是否为组播地址
reg    [1:0]                            r_broadcast_result           ;   // 广播类型结果
// 广播地址检测 (全F地址)
reg                                     r_is_broadcast_flag1         ;
reg                                     r_is_broadcast_flag2         ;
reg                                     r_is_broadcast_flag3         ;
wire                                    w_mac_eq_0                   ;
wire                                    w_mac_eq_1                   ;
wire                                    w_mac_eq_2                   ;
wire                                    w_mac_eq_all                 ;

// 本地MAC地址 - 参数化配置
wire   [47:0]                           w_local_mac                  ;   // 本地MAC地址
wire                                    w_all_rslt_ready             ;
assign w_all_rslt_ready = r_dmac_result_ready == 1'd1;//r_smac_result_ready == 1'd1 && r_dmac_result_ready == 1'd1 && r_clash_result_ready == 1'd1 ;
/*======================= 输出信号连接 ===========================*/
assign o_tx_port                    = r_is_self_mac ? {{1'b1}, {PORT_NUM{1'b0}}} : {{1'b0}, r_final_tx_port};
assign o_tx_port_vld                = r_is_self_mac ? 1'b1 : r_final_tx_port_vld;
assign o_tx_port_broadcast          = r_broadcast_result;
assign o_dmac                       = ri_dmac;
assign o_vlan_id                    = ri_vlan_id;
assign o_dmac_vld                   = ri_dmac_vld;
assign o_dmac_item_dmac_addr        = ri_dmac_hash_key;
assign o_dmac_item_dmac_addr_vld    = w_dmac_req_en;
assign o_dmac_item_dmac             = ri_dmac;
assign o_dmac_item_smac_addr        = ri_smac_hash_key;
assign o_dmac_item_smac_addr_vld    = w_smac_req_en;
assign o_dmac_item_smac             = ri_smac;
assign o_dmac_item_mac_rx_port      = ri_dmac_port;
assign o_dmac_item_vlan_id          = ri_vlan_id;
assign o_clash_item_dmac_addr       = ri_dmac_hash_key;
assign o_clash_item_dmac_addr_vld   = w_clash_req_en;
assign o_clash_item_dmac            = ri_dmac;
assign o_clash_item_smac_addr       = ri_smac_hash_key;
assign o_clash_item_smac_addr_vld   = w_smac_req_en;
assign o_clash_item_smac            = ri_smac;
assign o_clash_item_mac_rx_port     = ri_dmac_port;
assign o_clash_item_vlan_id         = ri_vlan_id;

wire [47:0]	w_cur_dmac;
// 输出寄存器读取的MAC表数据（只输出有效的58bit：VLAN_ID[11:0] + PORT[7:0] + MAC[47:0]??
// 格式：{VLAN_ID[11:2], PORT[7:0], MAC[47:0]}
assign w_cur_dmac = i_dmac_list_dout[47:0];

/*======================= 输入信号打拍逻辑 =======================*/
// 所有信号打拍处理
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        ri_vlan_id              <= 12'd0;
        ri_dmac_port            <= {PORT_NUM{1'b0}};
        ri_dmac_hash_key        <= {HASH_DATA_WIDTH{1'b0}};
        ri_dmac                 <= 48'd0;
        ri_dmac_vld             <= 1'b0;
        ri_smac_hash_key        <= {HASH_DATA_WIDTH{1'b0}};
        ri_smac                 <= 48'd0;
        ri_smac_vld             <= 1'b0;
        ri_smac_tx_port_rslt    <= {PORT_NUM{1'b0}};
        ri_smac_tx_port_vld     <= 1'b0;
        ri_dmac_tx_port_rslt    <= {PORT_NUM{1'b0}};
        ri_dmac_lookup_vld      <= 1'b0;
        ri_dmac_lookup_clash    <= 1'b0;
        ri_clash_tx_port_rslt   <= {PORT_NUM{1'b0}};
        ri_clash_tx_port_vld    <= 1'b0;
    end
    else begin
        ri_vlan_id              <= i_vlan_id;
        ri_dmac_port            <= i_dmac_port;
        ri_dmac_hash_key        <= i_dmac_hash_key;
        ri_dmac                 <= i_dmac;
        ri_dmac_vld             <= i_dmac_vld;
        ri_smac_hash_key        <= i_smac_hash_key;
        ri_smac                 <= i_smac;
        ri_smac_vld             <= i_smac_vld;
        ri_smac_tx_port_rslt    <= i_smac_tx_port_rslt;
        ri_smac_tx_port_vld     <= i_smac_tx_port_vld;
        ri_dmac_tx_port_rslt    <= i_dmac_tx_port_rslt;
        ri_dmac_lookup_vld      <= i_dmac_lookup_vld;
        ri_dmac_lookup_clash    <= i_dmac_lookup_clash;
        ri_clash_tx_port_rslt   <= i_clash_tx_port_rslt;
        ri_clash_tx_port_vld    <= i_clash_tx_port_vld;
    end
end

/*======================= 查表请求分发逻辑 =======================*/
// DMAC表请求使能
assign w_dmac_req_en = ri_dmac_vld;

// SMAC表请求使能
assign w_smac_req_en = ri_smac_vld;

// 冲突表请求使能
assign w_clash_req_en = ri_dmac_vld;

/*======================= 自己MAC检查逻辑 =======================*/
// 本地MAC地址参数化配置
assign w_local_mac = LOCAL_MAC;

// 是否为自己MAC检查 
//modify at 12.02
//assign w_mac_eq_0 = (ri_dmac[47:32] == w_local_mac[47:32]);
//assign w_mac_eq_1 = (ri_dmac[31:16] == w_local_mac[31:16]);
//assign w_mac_eq_2 = (ri_dmac[15:0]  == w_local_mac[15:0]) ;
assign w_mac_eq_0 = (w_cur_dmac[47:32] == w_local_mac[47:32]);
assign w_mac_eq_1 = (w_cur_dmac[31:16] == w_local_mac[31:16]);
assign w_mac_eq_2 = (w_cur_dmac[15:0]  == w_local_mac[15:0]) ;
assign w_mac_eq_all = w_mac_eq_0 == 1'd1 && w_mac_eq_1 == 1'd1 && w_mac_eq_2 == 1'd1;

always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_is_self_mac <= 1'b0;
    else
        r_is_self_mac <= w_mac_eq_all ? 1'b1 : 1'b0;
end

/*======================= MAC地址类型检测逻辑 =======================*/


// 广播地址检测标志位
/*
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        r_is_broadcast_flag1 <= 1'b0;
        r_is_broadcast_flag2 <= 1'b0;
        r_is_broadcast_flag3 <= 1'b0;
    end
    else begin 
        r_is_broadcast_flag1 <= (ri_dmac[47:32] == 16'hFFFF) ? 1'd1 : 1'd0;
        r_is_broadcast_flag2 <= (ri_dmac[31:16] == 16'hFFFF) ? 1'd1 : 1'd0;
        r_is_broadcast_flag3 <= (ri_dmac[15:0]  == 16'hFFFF) ? 1'd1 : 1'd0;
    end
end
*/
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        r_is_broadcast_flag1 <= 1'b0;
        r_is_broadcast_flag2 <= 1'b0;
        r_is_broadcast_flag3 <= 1'b0;
    end
    else begin 
        r_is_broadcast_flag1 <= (w_cur_dmac[47:32] == 16'hFFFF) ? 1'd1 : 1'd0;
        r_is_broadcast_flag2 <= (w_cur_dmac[31:16] == 16'hFFFF) ? 1'd1 : 1'd0;
        r_is_broadcast_flag3 <= (w_cur_dmac[15:0]  == 16'hFFFF) ? 1'd1 : 1'd0;
    end
end

// 所有标志位都为1时，r_is_broadcast拉高
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_is_broadcast <= 1'b0;
    else
        r_is_broadcast <= r_is_broadcast_flag1 == 1'd1 && r_is_broadcast_flag2 == 1'd1 && r_is_broadcast_flag3 == 1'd1;
end

// 组播地址检测 (最高字节最低位为1)
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_is_multicast <= 1'b0;
    else
        r_is_multicast <= w_cur_dmac[40] ? 1'b1 : 1'b0;  // 第40位(最高字节最低位)
end

// MAC地址类型编码
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_mac_type <= 2'b00;
    else
        r_mac_type <= r_is_broadcast ? 2'b10 : 
                     (r_is_multicast ? 2'b01 : 2'b00);
end

// 最终广播类型结果  00 单播 01 组播 10 广播 11 泛洪
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_broadcast_result <= 2'b00;
    else
        r_broadcast_result <= r_dmac_result_ready ? 
                             (r_mac_type == 2'b10 ? 2'b10 :
                             (r_mac_type == 2'b01 ? 2'b01 :
                             ((r_final_tx_port == r_flood_port) && (r_final_tx_port != {PORT_NUM{1'b0}}) ? 2'b11 : 2'b00))) :
                             r_broadcast_result;
end

/*======================= 查表结果收集逻辑 =======================*/
// SMAC查表结果收集
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        r_smac_result_ready <= 1'b0;
        r_smac_lookup_result <= {PORT_NUM{1'b0}};
    end
    else if (r_all_results_ready == 1'd1 && r_final_tx_port_vld == 1'd1) begin
        r_smac_result_ready <= 1'b0;
        r_smac_lookup_result <= {PORT_NUM{1'b0}};
    end
    else begin
        r_smac_result_ready  <= i_smac_tx_port_vld ? 1'b1 : r_smac_result_ready;
        r_smac_lookup_result <= i_smac_tx_port_vld ? i_smac_tx_port_rslt : r_smac_lookup_result;
    end
end

// DMAC查表结果收集
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        r_dmac_result_ready <= 1'b0;
        r_dmac_lookup_result <= {PORT_NUM{1'b0}};
    end
    else if (r_all_results_ready == 1'd1 && r_final_tx_port_vld == 1'd1) begin
        r_dmac_result_ready <= 1'b0;
        r_dmac_lookup_result <= {PORT_NUM{1'b0}};
    end
    else begin
        r_dmac_result_ready <= i_dmac_lookup_vld ? 1'b1 : r_dmac_result_ready;
        r_dmac_lookup_result <= i_dmac_lookup_vld ? i_dmac_tx_port_rslt : r_dmac_lookup_result;
    end
end

// CLASH查表结果收集
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        r_clash_result_ready <= 1'b0;
        r_clash_lookup_result <= {PORT_NUM{1'b0}};
    end
    else if (r_all_results_ready == 1'd1 && r_final_tx_port_vld == 1'd1) begin
        r_clash_result_ready <= 1'b0;
        r_clash_lookup_result <= {PORT_NUM{1'b0}};
    end
    else begin
        r_clash_result_ready  <= i_clash_tx_port_vld ? 1'b1 : r_clash_result_ready;
        r_clash_lookup_result <= i_clash_tx_port_vld ? i_clash_tx_port_rslt : r_clash_lookup_result;
    end
end

// 所有结果准备就绪判断
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_all_results_ready <= 1'b0;
    else
        r_all_results_ready <= r_dmac_result_ready == 1'd1;
        // r_all_results_ready <= r_smac_result_ready == 1'd1 && r_dmac_result_ready == 1'd1 && r_clash_result_ready == 1'd1;
end

// 泛洪端口生成 - 除了输入端口外，其他端口全为1
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_flood_port <= {PORT_NUM{1'b0}};
    else
        r_flood_port <= ri_dmac_vld ? ~ri_dmac_port : r_flood_port;
end

/*======================= 查表结果仲裁逻辑 =======================*/
// 最终输出端口仲裁 - 优先级：smac > dmac > clash > flood   暂时只采用dmmac的查表结果
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_final_tx_port <= {PORT_NUM{1'b0}};
    else if (w_all_rslt_ready)
        // r_final_tx_port <= (r_smac_lookup_result != {PORT_NUM{1'b0}}) ? r_smac_lookup_result :
        //                   ((r_dmac_lookup_result != {PORT_NUM{1'b0}}) && ri_dmac_lookup_clash == 1'd0) ? r_dmac_lookup_result :
        //                   (r_clash_lookup_result != {PORT_NUM{1'b0}}) ? r_clash_lookup_result : 
        //                   r_flood_port;
        r_final_tx_port <= ((r_dmac_lookup_result != {PORT_NUM{1'b0}}) && ri_dmac_lookup_clash == 1'd0) ? r_dmac_lookup_result :
                             r_flood_port ;
end

// 最终输出端口有效
always @(posedge i_clk or negedge i_rst) begin
    if (i_rst)
        r_final_tx_port_vld <= 1'b0;
    else
        r_final_tx_port_vld <= r_all_results_ready;
end


endmodule