module rx_forward_mng#(
    parameter                                                   PORT_NUM                =      4        ,  // 交换机的端口数
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng 数据位宽
    parameter                                                   METADATA_WIDTH          =      81       ,  // 信息流位宽
	parameter                                                   PORT_INDEX              =      0        , 
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH*PORT_NUM // 聚合总线输出
)(
    input               wire                                    i_clk                              ,   // 250MHz
    input               wire                                    i_rst                              ,
    /*---------------------------------------- 控制转发相关的寄存器 -------------------------------------------*/
    input              wire                                     i_port_rxmac_down_regs             , // 端口接收方向MAC关闭使能
    input              wire                                     i_port_broadcast_drop_regs         , // 端口广播帧丢弃使能
    input              wire                                     i_port_multicast_drop_regs         , // 端口组播帧丢弃使能
    input              wire                                     i_port_loopback_drop_regs          , // 端口环回帧丢弃使能
    input              wire   [47:0]                            i_port_mac_regs                    , // 端口的 MAC 地址
    input              wire                                     i_port_mac_vld_regs                , // 使能端口 MAC 地址有效
    input              wire   [7:0]                             i_port_mtu_regs                    , // MTU配置值
    input              wire   [PORT_NUM-1:0]                    i_port_mirror_frwd_regs            , // 镜像转发寄存器，若对应的端口置1，则本端口接收到的任何转发数据帧将镜像转发值被置1的端口
    input              wire   [15:0]                            i_port_flowctrl_cfg_regs           , // 限流管理配置                                                                        
    input              wire   [4:0]                             i_port_rx_ultrashortinterval_num   , // 帧间隔                                                                          
    /*---------------------------------------- rx_frm_info_mng input 的信息流 -------------------------------------------*/
    input              wire                                     i_rtag_flag                        , // rtag标志 -> CB的报文    
    input              wire   [15:0]                            i_rtag_sequence                    , // [80:65] : CB协议 R-TAG字段
    input              wire   [1:0]                             i_port_speed                       , // [64:63](2bit) : port_speed 
    input              wire   [2:0]                             i_vlan_pri                         , // [62:60](3bit) : vlan_pri 
    input              wire                                     i_frm_vlan_flag                    , // [27](1bit) : frm_vlan_flag
    // input              wire   [PORT_NUM-1:0]                    i_rx_port                          , // [26:19](8bit) : 输入端口，bitmap表示
    input              wire                                     i_frm_discard                      , // crc是否正确：是否丢弃
    input              wire                                     i_frm_qbu                          , // [11](1bit) : 是否为关键帧(Qbu)
    // // 内部信息处理使用，不作为metadata字段 
    // input              wire                                     i_frm_info_vld                     , // 帧信息有效 
    // input              wire                                     i_broadcast_frm_en                 , // 广播帧 
    // input              wire                                     i_multicast_frm_en                 , // 组播帧 
    // input              wire                                     i_mac_time_irq                      , // 打时间戳中断信号
    // input              wire   [7:0]                             i_mac_frame_seq                     , // 帧序列号
    input              wire   [6:0]                             i_timestamp_addr                   , // 打时间戳存储的 RAM 地址 
    input              wire   [15:0]                            i_ethertype                        , // 以太网类型字段  
    input              wire                                     i_info_valid                       ,
    /*---------------------------------------- 查表模块根据哈希值返回的计算结果 ----------------------------------*/
    input              wire    [PORT_NUM-1:0]                  i_swlist_tx_port                    , // 发送端口信息   
    input              wire   [1:0]                            i_swlist_port_broadcast             , // 01:组播 10：广播 11:泛洪
    input              wire                                    i_swlist_vld                        , // 有效使能信号                                   
    /*---------------------------------------- ACL 匹配后输出的字段 ------------------------------ -------------*/
    input              wire                                    i_acl_vld                           , // acl匹配表的有效输出信号
    input              wire    [2:0]                           i_acl_action                        , // ACL操作: 000-允许 001-丢弃 010-重定向
    input              wire                                    i_acl_cb_frm                        , // CB协议帧标志
    input              wire    [7:0]                           i_acl_cb_streamhandle               , // stream_handle值(8bit)
    input              wire    [2:0]                           i_acl_flow_ctrl                     , // 流控配置: 00-100% 01-50% 10-25% 11-12.5%
    input              wire    [7:0]                           i_acl_forwardport                   , // 转发端口bitmap  
    // input              wire                                    i_acl_find_match                   , // 是否匹配到正确的条目
    // input              wire   [7:0]                            i_acl_frmtype                      , // 匹配出来的帧类型
    // input              wire   [15:0]                           i_acl_fetch_info                   , // 待定保留 
    
    // input              wire   [1:0]                            i_frm_cb_op                         , // [14:13](2bit) :[0]:1表示CB业务帧，[0]:0表示非CB业务帧  [1]：1 有 rtag 标签 [1]：0 无 rtag 标签 ok   
    // /*---------------------------------------- 单 PORT 聚合数据流输入 -------------------------------------------*/
    // input              wire                                    i_mac_port_link                    , // 端口的连接状态
    // input              wire   [1:0]                            i_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 

    input              wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac_port_axi_data                 , // 端口数据流，最高位表示crcerr
    input              wire   [15:0]                           i_mac_axi_data_user                 , // 是否关键帧 + 报文长度
    input              wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac_axi_data_keep                 , // 端口数据流掩码，有效字节指示
    input              wire                                    i_mac_axi_data_valid                , // 端口数据有效
    output             wire                                    o_mac_axi_data_ready                , // 交叉总线聚合架构反压流水线信号
    input              wire                                    i_mac_axi_data_last                 , // 数据流结束标识
    // /*---------------------------------------- 单 PORT 聚合数据流输出 -------------------------------------------*/
    // output             wire                                    o_mac_port_link                    , // 端口的连接状态
    // output             wire   [1:0]                            o_mac_port_speed                   , // 端口速率信息，00-10M，01-100M，10-1000M，10-10G 
    output             wire   [PORT_MNG_DATA_WIDTH-1:0]        o_mac_port_axi_data                 , // 端口数据流，最高位表示crcerr
    output             wire   [15:0]                           o_mac_axi_data_user                 , // 是否关键帧 + 报文长度
    output             wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    o_mac_axi_data_keep                 , // 端口数据流掩码，有效字节指示
    output             wire                                    o_mac_axi_data_valid                , // 端口数据有效
    input              wire                                    i_mac_axi_data_ready                , // 交叉总线聚合架构反压流水线信号
    output             wire                                    o_mac_axi_data_last                 , // 数据流结束标识
    /*---------------------------------------- 单 PORT 聚合信息流 -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]             o_cross_metadata                    , // 聚合总线 metadata 数据
    output             wire                                    o_cross_metadata_valid              , // 聚合总线 metadata 数据有效信号
    output             wire                                    o_cross_metadata_last               , // 信息流结束标识
    input              wire                                    i_cross_metadata_ready              , // 下游模块反压流水线 
    /*---------------------------------------- 诊断寄存器 -------------------------------------------*/
    output             wire                                    o_port_rx_ultrashort_frm            , // 端口接收超短帧(小于64字节)
    output             wire                                    o_port_rx_overlength_frm            , // 端口接收超长帧(大于MTU字节)
    output             wire                                    o_port_rx_crcerr_frm                , // 端口接收CRC错误帧
    output             wire  [15:0]                            o_port_rx_loopback_frm_cnt          , // 端口接收环回帧计数器值
    output             wire  [15:0]                            o_port_broadflow_drop_cnt           , // 端口接收到广播限流而丢弃的帧计数器值
    output             wire  [15:0]                            o_port_multiflow_drop_cnt           , // 端口接收到组播限流而丢弃的帧计数器值
    output             wire  [15:0]                            o_port_diag_state                     // 端口状态寄存器，详情见寄存器表说明定义 
);

   /*
        metadata 数据组成 (总位宽81bit)
            
            [80:65](16bit): CB协议 R-TAG字段 ok
            [64:63](2bit) : port_speed ok
            [62:60](3bit) : vlan_pri ok
            [59:52](8bit) : tx_prot (融合ACL转发端口) ok 
            [51:44](8bit) : acl_frmtype ok
            [43:36](8bit) : stream_handle，CB协议流标识 ok
            [35:28](8bit) : 保留字段
            [27](1bit)    : frm_vlan_flag ok
            [26:19](8bit) : 输入端口，bitmap表示 ok
            [18:15](4bit) : 保留
            [14:13](2bit) : 流识别匹配，[1]:rtag_flag [0]:cb_frm ok 
            [12](1bit)    : 丢弃位(由ACL action决定) ok
            [11](1bit)    : 是否为关键帧(Qbu) ok
            [10:4](7bit)  : time_stamp_addr，报文时间戳的地址信息 ok
            [3:0](4bit)   : 保留
    */
/*--------- 信号声明区 --------*/

// FIFO相关参数定义
localparam FIFO_DEPTH       = 30                                                                ;
localparam FIFO_WIDTH       = PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8) + 1                ; // data + keep + last
localparam FIFO_CNT_WIDTH   = 5                                                                 ; // log2(30) 向上取整

// FIFO相关信号
wire                                    w_fifo_wr_en                    ; // FIFO写使能
wire    [FIFO_WIDTH-1:0]                w_fifo_din                      ; // FIFO写入数据
wire                                    w_fifo_full                     ; // FIFO满信号
wire                                    w_fifo_rd_en                    ; // FIFO读使能
wire    [FIFO_WIDTH-1:0]                w_fifo_dout                     ; // FIFO读出数据
wire                                    w_fifo_empty                    ; // FIFO空信号
wire    [FIFO_CNT_WIDTH-1:0]            w_fifo_data_cnt                 ; // FIFO数据计数

// FIFO输出数据解包
wire    [PORT_MNG_DATA_WIDTH-1:0]       w_fifo_out_data                 ; // FIFO输出的数据
wire    [(PORT_MNG_DATA_WIDTH/8)-1:0]   w_fifo_out_keep                 ; // FIFO输出的keep
wire                                    w_fifo_out_last                 ; // FIFO输出的last

// user信号缓存（每帧第一拍）
reg                                     r_fifo_rd_en                    ;
reg     [15:0]                          r_frame_user                    ; // 缓存的user信号

// 流控模块相关wire信号
wire    [31:0]                          w_recive_package                ; // 接收包计数
wire    [31:0]                          w_recive_package_multi          ; // 接收包计数乘数
wire    [31:0]                          w_send_package                  ; // 发送包计数
wire    [31:0]                          w_send_package_multi            ; // 发送包计数乘数
wire    [PORT_MNG_DATA_WIDTH-1:0]       w_flow_data_out                 ; // 流控后数据输出
wire    [(PORT_MNG_DATA_WIDTH/8)-1:0]   w_flow_data_keep_out            ; // 流控后数据掩码
wire                                    w_flow_valid_out                ; // 流控后数据有效
wire                                    w_flow_ready                 ; // 流控模块ready
wire                                    w_flow_last_out                 ; // 流控后last信号

// 流控模块输入选择信号
wire    [PORT_MNG_DATA_WIDTH-1:0]       w_flow_ctrl_input_data          ; // 流控模块输入数据选择
wire    [(PORT_MNG_DATA_WIDTH/8)-1:0]   w_flow_ctrl_input_keep          ; // 流控模块输入掩码选择
wire                                    w_flow_ctrl_input_valid         ; // 流控模块输入有效选择
wire                                    w_flow_ctrl_input_last          ; // 流控模块输入last选择

// 流控判断条件辅助信号
reg                                     r_acl_match_flow_type           ; // ACL匹配流控帧类型
reg                                     r_flow_ctrl_enable              ; // 流控总使能

// 流控配置信号
reg     [2:0]                           ri_flow_ctrl_select             ; // 流控配置打拍

// 帧类型判断组合逻辑
wire    [7:0]                           w_frm_type                      ; // 根据以太网类型判断的帧类型

//-------------------- 变量声明区 --------------------
// 输入信号打拍 
reg                                     ri_mac_axi_data_valid           ;
reg     [PORT_MNG_DATA_WIDTH-1:0]       ri_mac_port_axi_data            ;
reg     [(PORT_MNG_DATA_WIDTH/8)-1:0]   ri_mac_axi_data_keep            ;
reg                                     ri_mac_axi_data_last            ;
reg     [15:0]                          ri_mac_axi_data_user            ;
reg     [15:0]                          ri_rtag_sequence                ;
reg                                     ri_frm_vlan_flag                ;
reg     [2:0]                           ri_vlan_pri                     ;
reg     [PORT_NUM-1:0]                  r_rx_port                       ;
reg     [7:0]                           ri_acl_frmtype                  ;
reg                                     ri_acl_vld                      ; 
// reg     [15:0]                          ri_acl_fetch_info               ;
reg     [1:0]                           ri_frm_cb_op                    ;
reg                                     ri_frm_qbu                      ;
reg     [6:0]                           ri_timestamp_addr               ;
reg     [1:0]                           ri_port_speed                   ;
reg     [15:0]                          ri_ethertype                    ; // 以太网类型打拍
reg     [PORT_NUM-1:0]                  ri_swlist_tx_port               ;
reg                                     ri_swlist_vld                   ;
reg                                     ri_frm_discard                  ;
reg     [7:0]                           ri_tx_prot                      ; // metadata补充字段
reg     [3:0]                           ri_qos_policy                   ; // metadata补充字段
reg                                     ri_discard                      ; // metadata丢弃位
reg     [15:0]                          ri_port_flowctrl_cfg_regs       ; // 流控配置寄存器打拍
reg     [2:0]                           ri_acl_action                   ; // ACL操作类型打拍
reg                                     ri_acl_cb_frm                   ; // ACL CB协议帧标志打拍
reg                                     ri_rtag_flag                    ; // RTAG标志打拍
reg     [7:0]                           ri_acl_cb_streamhandle          ; // ACL stream_handle打拍
reg     [1:0]                           ri_acl_flow_ctrl                ; // ACL流控配置打拍
reg     [7:0]                           ri_acl_forwardport              ; // ACL转发端口打拍

// 流控处理相关
reg                                     r_need_flow_ctrl                ;
reg                                     r_need_flow_ctrl_d1             ;

// metadata输出
reg     [METADATA_WIDTH-1:0]            ro_cross_metadata               ;
reg                                     ro_cross_metadata_valid         ;
reg                                     ro_cross_metadata_last          ;

// 数据流输出
reg     [PORT_MNG_DATA_WIDTH-1:0]       ro_mac_port_axi_data            ;
reg     [(PORT_MNG_DATA_WIDTH/8)-1:0]   ro_mac_axi_data_keep            ;
reg                                     ro_mac_axi_data_valid           ;
reg                                     ro_mac_axi_data_last            ;
reg     [15:0]                          ro_mac_axi_data_user            ;

// metadata_valid控制标志位
reg                                     r_swlist_vld_flag               ; // swlist_vld触发标志
reg                                     r_acl_vld_flag                  ; // acl_vld触发标志
wire                                    w_both_vld_ready                ; // 两个vld都已触发
wire                                    w_discard                       ;

// FIFO读取控制
reg                                     r_lookup_done                   ; // 查表完成标志
reg                                     r_frame_start                   ; // 帧起始标志
always @(posedge i_clk) begin
    if (i_rst) begin
        ri_mac_axi_data_valid   <= 1'b0;
        ri_mac_port_axi_data    <= {PORT_MNG_DATA_WIDTH{1'b0}};
        ri_mac_axi_data_keep    <= {(PORT_MNG_DATA_WIDTH/8){1'b0}};
        ri_mac_axi_data_last    <= 1'b0;
        ri_mac_axi_data_user    <= 16'd0;
        ri_rtag_sequence        <= 16'd0;
        ri_frm_vlan_flag        <= 1'b0;
        ri_vlan_pri             <= 3'd0;
        ri_acl_frmtype          <= 8'd0;
        ri_acl_vld              <= 1'b0; 
        ri_frm_cb_op            <= 2'd0;
        ri_frm_qbu              <= 1'b0;
        ri_timestamp_addr       <= 8'd0;
        ri_port_speed           <= 2'd0;
        ri_ethertype            <= 16'd0;
        ri_swlist_tx_port       <= {PORT_NUM{1'b0}};
        ri_swlist_vld           <= 1'b0;
        ri_frm_discard          <= 1'b0;
        ri_tx_prot              <= 8'd0;
        ri_qos_policy           <= 4'd0;
        ri_discard              <= 1'b0;
        ri_port_flowctrl_cfg_regs <= 16'd0;
        ri_acl_action           <= 3'd0;
        ri_acl_cb_frm           <= 1'b0;
        ri_rtag_flag            <= 1'b0;
        ri_acl_cb_streamhandle  <= 8'd0;
        ri_acl_flow_ctrl        <= 2'd0;
        ri_acl_forwardport      <= 8'd0; 
    end else begin
        ri_mac_axi_data_valid   <= i_mac_axi_data_valid;
        ri_mac_port_axi_data    <= i_mac_port_axi_data;
        ri_mac_axi_data_keep    <= i_mac_axi_data_keep;
        ri_mac_axi_data_last    <= i_mac_axi_data_last;
        ri_mac_axi_data_user    <= i_mac_axi_data_user;
        ri_rtag_flag            <= i_rtag_flag == 1'd1 || (ri_rtag_flag == 1'd1 && i_mac_axi_data_valid == 1'd1) ? 1'd1 : 1'd0;//ri_mac_axi_data_last ? 1'd0 : ri_rtag_flag
        ri_rtag_sequence        <= i_info_valid ? i_rtag_sequence : ri_rtag_sequence;
        ri_frm_vlan_flag        <= i_info_valid ? i_frm_vlan_flag : ri_frm_vlan_flag;
        ri_vlan_pri             <= i_info_valid ? i_vlan_pri      : ri_vlan_pri     ;
        ri_acl_frmtype          <= w_frm_type;
        ri_acl_vld              <= i_acl_vld; 
        ri_frm_cb_op            <= {ri_rtag_flag, ri_acl_cb_frm}; // [1]:rtag_flag [0]:cb_frm
        ri_frm_qbu              <= i_info_valid ? i_frm_qbu : ri_frm_qbu;
        ri_timestamp_addr       <= i_info_valid ? i_timestamp_addr : ri_timestamp_addr;
        ri_port_speed           <= i_info_valid ? i_port_speed : ri_port_speed;
        ri_ethertype            <= i_info_valid ? i_ethertype  : ri_ethertype ;
        ri_swlist_tx_port       <= i_swlist_vld ? i_swlist_tx_port : ri_swlist_tx_port; // ACL转发端口优先
        ri_swlist_vld           <= i_swlist_vld;
        ri_frm_discard          <= i_info_valid ? i_frm_discard : ri_frm_discard;
        ri_tx_prot              <= (ri_acl_forwardport != 8'd0) ? ri_acl_forwardport[PORT_NUM-1:0] : ri_swlist_tx_port; // ACL转发端口优先  
        ri_qos_policy           <= 4'd1;  
        ri_discard              <= i_info_valid ? i_frm_discard : ri_discard;
        // ri_discard              <= (ri_acl_action == 3'b001) ? 1'b1 : i_frm_discard; // ACL action=001为丢弃
        ri_port_flowctrl_cfg_regs <= i_port_flowctrl_cfg_regs       ;
        ri_acl_action           <= i_acl_vld ? i_acl_action          : ri_acl_action          ;
        ri_acl_cb_frm           <= i_acl_vld ? i_acl_cb_frm          : ri_acl_cb_frm          ;
        ri_acl_cb_streamhandle  <= i_acl_vld ? i_acl_cb_streamhandle : ri_acl_cb_streamhandle ;
        ri_acl_flow_ctrl        <= i_acl_vld ? i_acl_flow_ctrl       : ri_acl_flow_ctrl       ;
        ri_acl_forwardport      <= i_acl_vld ? i_acl_forwardport     : ri_acl_forwardport     ; 
    end
end

assign w_discard = (ri_acl_action == 3'b001) ? 1'b1 : ri_discard;

// 接收端口标识（基于参数PORT_INDEX）
always @(posedge i_clk) begin
    if (i_rst) begin
        r_rx_port <= {PORT_NUM{1'b0}};
    end else begin
        r_rx_port <= 1'b1 << PORT_INDEX[2:0];
    end
end
 
//-------------------- 帧类型判断组合逻辑 --------------------
// 根据以太网类型判断帧类型
// 0x88F7: 802.1AS (PTP) -> frm_type = 1
// 0x88CC: LLDP          -> frm_type = 2  
// 0x010B: RSTP          -> frm_type = 3
// 其他:                 -> frm_type = 0
assign w_frm_type = (i_ethertype == 16'h88F7) ? 8'd1 :
                    (i_ethertype == 16'h88CC) ? 8'd2 :
                    (i_ethertype == 16'h010B) ? 8'd3 : 
                    8'd0;

//-------------------- 流控配置逻辑 --------------------
// 流控配置拼接：ACL流控优先，如果ACL有效且流控配置不为0，使用ACL流控；否则使用寄存器配置
// [1:0]: 流控等级选择 (00=100%, 01=50%, 10=25%, 11=12.5%)
always @(posedge i_clk) begin
    if (i_rst)
        ri_flow_ctrl_select <= 3'd0;
    else
        ri_flow_ctrl_select <= (i_acl_vld == 1'b1 && i_acl_flow_ctrl != 3'b00) ? i_acl_flow_ctrl : ri_port_flowctrl_cfg_regs[2:0];
end

//-------------------- 流控判断逻辑 --------------------
// ACL匹配流控帧类型判断
always @(posedge i_clk) begin
    if (i_rst)
        r_acl_match_flow_type <= 1'b0;
    else
        r_acl_match_flow_type <= (ri_acl_vld == 1'b1 && ri_acl_frmtype == 8'h01) ? 1'b1 : 1'b0;
end

// 流控总使能判断
always @(posedge i_clk) begin
    if (i_rst)
        r_flow_ctrl_enable <= 1'b0;
    else
        r_flow_ctrl_enable <= 1'd1;  // 测试：r_flow_ctrl_enable <= (ri_port_flowctrl_cfg_regs[12] == 1'b1) ? 1'b1 : 1'b0;
end

// 流控处理使能：ACL匹配流控帧类型 && 流控总使能  // 不是单播就限流
always @(posedge i_clk) begin
    if (i_rst) begin
        r_need_flow_ctrl <= 1'b0;
    end else begin
        // r_need_flow_ctrl <= 1'b0; // 测试
        r_need_flow_ctrl <= (i_swlist_port_broadcast != 2'd0 && r_flow_ctrl_enable == 1'b1) ? 1'b1 :
                            (ro_mac_axi_data_last ? 1'b0 : r_need_flow_ctrl); 
    end
end

always @(posedge i_clk) begin
     r_need_flow_ctrl_d1 <=  r_need_flow_ctrl;
end

//-------------------- FIFO写入逻辑 --------------------
// FIFO写入使能：输入数据有效且FIFO未满
assign w_fifo_wr_en = i_mac_axi_data_valid && !w_fifo_full;

// FIFO写入数据打包：data + keep + last (不包含user)
assign w_fifo_din = {i_mac_axi_data_last, i_mac_axi_data_keep, i_mac_port_axi_data};

//-------------------- user信号缓存逻辑 --------------------
// 检测帧起始：上一拍无效，当前拍有效
always @(posedge i_clk) begin
    if (i_rst)
        r_frame_start <= 1'b0;
    else
        r_frame_start <= (!ri_mac_axi_data_valid && i_mac_axi_data_valid);
end

// 在帧起始时缓存user信号
always @(posedge i_clk) begin
    if (i_rst)
        r_frame_user <= 16'd0;
    else if (r_frame_start)
        r_frame_user <= {3'b000,ri_acl_cb_frm,i_mac_axi_data_user[11:0]};
end

//-------------------- FIFO读取逻辑 --------------------
// 查表完成标志：当i_swlist_vld拉高时，表示查表完成
always @(posedge i_clk) begin
    if (i_rst)
        r_lookup_done <= 1'b0;
    else
        r_lookup_done <= i_swlist_vld ? 1'b1 : (w_fifo_empty ? 1'b0 : r_lookup_done);
end

// FIFO读取使能：查表完成 && FIFO非空 && 下游ready
assign w_fifo_rd_en = r_lookup_done && !w_fifo_empty && 
                      ((r_need_flow_ctrl == 1'b1) ? w_flow_ready : i_mac_axi_data_ready);

// FIFO输出数据解包
assign w_fifo_out_data = w_fifo_dout[PORT_MNG_DATA_WIDTH-1:0];
assign w_fifo_out_keep = w_fifo_dout[PORT_MNG_DATA_WIDTH + (PORT_MNG_DATA_WIDTH/8) - 1 : PORT_MNG_DATA_WIDTH];
assign w_fifo_out_last = w_fifo_dout[FIFO_WIDTH-1];

always @(posedge i_clk) begin  
    r_fifo_rd_en <= w_fifo_rd_en;
end
//-------------------- FIFO模块实例化 --------------------
sync_fifo #(
    .DEPTH                  ( FIFO_DEPTH                )  ,
    .WIDTH                  ( FIFO_WIDTH                )  ,
    .ALMOST_FULL_THRESHOLD  ( 1                         )  ,
    .ALMOST_EMPTY_THRESHOLD ( 1                         )  ,
    .FLOP_DATA_OUT          ( 0                         )  , // 使用std模式
    .RAM_STYLE              ( 0                         )    // 使用Distributed RAM（小容量FIFO）
) u_data_fifo (
    .i_clk                  ( i_clk                     )  ,
    .i_rst                  ( i_rst                     )  ,
    .i_wr_en                ( w_fifo_wr_en              )  ,
    .i_din                  ( w_fifo_din                )  ,
    .o_full                 ( w_fifo_full               )  ,
    .i_rd_en                ( w_fifo_rd_en              )  ,
    .o_dout                 ( w_fifo_dout               )  ,
    .o_empty                ( w_fifo_empty              )  ,
    .o_almost_full          (                           )  , // 未使用
    .o_almost_empty         (                           )  , // 未使用
    .o_data_cnt             ( w_fifo_data_cnt           )
);

//-------------------- 流控模块输入选择逻辑 --------------------
// 从FIFO读出的数据送入流控模块或直接输出
assign w_flow_ctrl_input_data  = r_need_flow_ctrl_d1  == 1'd1 && r_fifo_rd_en == 1'd1 ? w_fifo_out_data : {PORT_MNG_DATA_WIDTH{1'b0}};
assign w_flow_ctrl_input_keep  = r_need_flow_ctrl_d1  == 1'd1 && r_fifo_rd_en == 1'd1 ? w_fifo_out_keep : {(PORT_MNG_DATA_WIDTH/8){1'b0}};
assign w_flow_ctrl_input_valid = r_need_flow_ctrl_d1 ? r_fifo_rd_en    : 1'd0;// FIFO读取时数据有效
assign w_flow_ctrl_input_last  = r_need_flow_ctrl_d1  == 1'd1 && r_fifo_rd_en == 1'd1 ? w_fifo_out_last : 1'd0;

//-------------------- 流控模块实例化 --------------------
// 对特定帧类型做流控处理
flow_driver#(
    .SIM_MODE               ( "TRUE"                )  ,
    .REG_DATA_WIDTH         ( 16                    )  ,
    .PORT_MNG_DATA_WIDTH    ( PORT_MNG_DATA_WIDTH   )  ,
    .CLOCK_PERIOD           ( 250_000_000           ) 
) flow_driver_inst (                                       
    .i_sys_clk              ( i_clk                 )  ,
    .i_sys_rst              ( i_rst                 )  ,

    .i_pluse_clk            ( i_clk                 )  , // 使用系统时钟250MHz
    .i_pluse_rst            ( i_rst                 )  ,

    .i_port_rate            ( ri_port_speed         )  , // 端口速率: 00-100M 01-1000M 10-2500M 11-10G
    .i_flow_ctrl_select     (3'd0),//( ri_flow_ctrl_select   )  , // 流控配置: [1:0]流控等级 00:100% 01:50% 10:25% 11:12.5%  测试 
 
    .o_recive_package       ( w_recive_package      )  , // 接收数据包数 
    .o_recive_package_multi ( w_recive_package_multi)  , // 接收数据包数乘数
    .o_send_package         ( w_send_package        )  , // 发送数据包数量
    .o_send_package_multi   ( w_send_package_multi  )  , // 发送数据包数量乘数
 
    .i_flow_data            ( w_flow_ctrl_input_data )  , // 端口数据 (流控选择后)
    .i_flow_data_keep       ( w_flow_ctrl_input_keep )  , // 端口数据掩码信号 (流控选择后)
    .i_flow_valid           ( w_flow_ctrl_input_valid)  , // 端口数据有效 (流控选择后)
    .o_flow_ready           ( w_flow_ready           )  , // 端口数据就绪信号
    .i_flow_last            ( w_flow_ctrl_input_last )  , // 数据流结束标志 (流控选择后)
 
    .o_flow_data            ( w_flow_data_out       )  , // 流控后端口数据 
    .o_flow_data_keep       ( w_flow_data_keep_out  )  , // 流控后数据掩码信号
    .o_flow_valid           ( w_flow_valid_out      )  , // 流控后数据有效
    .i_flow_ready           ( i_mac_axi_data_ready  )  , // 下游模块ready信号
    .o_flow_last            ( w_flow_last_out       )    // 流控后数据结束标志

);

//-------------------- metadata拼接输出 --------------------
always @(posedge i_clk) begin
    if (i_rst)
        ro_cross_metadata <= {METADATA_WIDTH{1'b0}};
    else
        ro_cross_metadata <= {
            ri_rtag_sequence      , // [80:65] R-TAG字段 (16bit)
            ri_port_speed         , // [64:63] (2bit)
            ri_vlan_pri           , // [62:60] (3bit)
            ri_tx_prot            , // [59:52] tx_prot (8bit, 融合ACL转发端口)
            ri_acl_frmtype        , // [51:44] (8bit)
            ri_acl_cb_streamhandle, // [43:36] stream_handle (8bit)
            8'd0                  , // [35:28] 保留字段 (8bit)
            ri_frm_vlan_flag      , // [27] (1bit)
            r_rx_port             , // [26:19] 输入端口 (8bit)
            4'd0                  , // [18:15] 保留 (4bit)
            ri_frm_cb_op          , // [14:13] [1]:rtag_flag [0]:cb_frm (2bit)
            w_discard             , // [12] 丢弃位 (1bit)
            ri_frm_qbu            , // [11] (1bit)
            ri_timestamp_addr     , // [10:4] (7bit)
            4'd0                    // [3:0] 保留 (4bit)

        };
end

//-------------------- metadata_valid控制逻辑 --------------------
// swlist_vld触发标志 
always @(posedge i_clk) begin
    if (i_rst)
        r_swlist_vld_flag <= 1'b0;
    else
        r_swlist_vld_flag <= (w_both_vld_ready == 1'd1) ? 1'b0 : ((i_swlist_vld == 1'd1) ? 1'b1 : r_swlist_vld_flag);
end

// acl_vld触发标志  
always @(posedge i_clk) begin
    if (i_rst)
        r_acl_vld_flag <= 1'b0;
    else
        r_acl_vld_flag <= (w_both_vld_ready == 1'd1) ? 1'b0 : ((i_acl_vld == 1'd1) ? 1'b1 : r_acl_vld_flag);
end

// 两个vld都已触发的指示信号
assign w_both_vld_ready = r_swlist_vld_flag == 1'd1 && r_acl_vld_flag == 1'd1 ? 1'd1 : 1'd0;

// metadata_valid与数据流同步：查表完成后，随数据流输出而输出
always @(posedge i_clk) begin
    if (i_rst)
        ro_cross_metadata_valid <= 1'b0;
    else
        ro_cross_metadata_valid <= (((w_flow_valid_out == 1'd1 && ro_mac_axi_data_valid == 1'd0) || (ro_mac_axi_data_valid == 1'd0 && r_fifo_rd_en == 1'd1 && r_need_flow_ctrl == 1'd0))) ? 1'd1  
                                   : 1'b0;
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_cross_metadata_last <= 1'b0;
    else
        ro_cross_metadata_last <=  (((w_flow_valid_out == 1'd1 && ro_mac_axi_data_valid == 1'd0) || (ro_mac_axi_data_valid == 1'd0 && r_fifo_rd_en == 1'd1 && r_need_flow_ctrl == 1'd0))) ? 1'd1  
                                   : 1'b0;
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_mac_port_axi_data <= {PORT_MNG_DATA_WIDTH{1'b0}};
    else
        ro_mac_port_axi_data <= (r_need_flow_ctrl == 1'd1) ? (w_flow_valid_out ? w_flow_data_out : {PORT_MNG_DATA_WIDTH{1'b0}}) :
                                (r_fifo_rd_en) ? w_fifo_out_data : {PORT_MNG_DATA_WIDTH{1'b0}};
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_mac_axi_data_keep <= {(PORT_MNG_DATA_WIDTH/8){1'b0}};
    else
        ro_mac_axi_data_keep <= (r_need_flow_ctrl == 1'd1) ? (w_flow_valid_out ? w_flow_data_keep_out :{(PORT_MNG_DATA_WIDTH/8){1'b0}} ):
                                (r_fifo_rd_en == 1'd1) ? w_fifo_out_keep : {(PORT_MNG_DATA_WIDTH/8){1'b0}};
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_mac_axi_data_valid <= 1'b0;
    else
        ro_mac_axi_data_valid <= (r_need_flow_ctrl == 1'd1) ? w_flow_valid_out : r_fifo_rd_en;
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_mac_axi_data_last <= 1'b0;
    else
        ro_mac_axi_data_last <= (r_need_flow_ctrl == 1'd1) ? (w_flow_valid_out ? w_flow_last_out : 1'b0) :
                                (r_fifo_rd_en == 1'd1) ? w_fifo_out_last : 1'b0;
end

always @(posedge i_clk) begin
    if (i_rst)
        ro_mac_axi_data_user <= 16'd0;
    else
        ro_mac_axi_data_user <= r_frame_user;
end

// 数据流输出
assign o_mac_port_axi_data          = ro_mac_port_axi_data                                     ;
assign o_mac_axi_data_keep          = ro_mac_axi_data_keep                                     ;
assign o_mac_axi_data_valid         = ro_mac_axi_data_valid                                    ;
assign o_mac_axi_data_last          = ro_mac_axi_data_last                                     ;
assign o_mac_axi_data_user          = ro_mac_axi_data_user                                     ;
assign o_mac_axi_data_ready         = ~w_fifo_full                                             ; // FIFO未满时可以接收数据

// metadata输出
assign o_cross_metadata             = ro_cross_metadata                                        ;
assign o_cross_metadata_valid       = ro_cross_metadata_valid                                  ;
assign o_cross_metadata_last        = ro_cross_metadata_last                                   ;

// 诊断输出信号（暂时赋默认值，后续可扩展）
assign o_port_rx_ultrashort_frm     = 1'b0                                                     ;
assign o_port_rx_overlength_frm     = 1'b0                                                     ;
// assign o_port_rx_crcerr_frm         = ri_mac_port_axi_data[CROSS_DATA_WIDTH]                   ; // 最高位表示CRC错误
assign o_port_rx_loopback_frm_cnt   = 16'd0                                                    ;
assign o_port_broadflow_drop_cnt    = 16'd0                                                    ;
assign o_port_multiflow_drop_cnt    = 16'd0                                                    ;
assign o_port_diag_state            = {12'd0, w_send_package[3:0]}                             ; // 低4位显示发送包计数
endmodule