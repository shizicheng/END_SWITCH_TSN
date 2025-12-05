// `include "synth_cmd_define.vh"

module wr_ack_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      144      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       CAM_MODEL               =      1        ,   // 1 - CAM 表,0 - TCAM 表
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,   // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                       DATA_CNT_WIDTH          =      clog2(LOOK_UP_DATA_WIDTH/8)       ,   // cam存储块的索引位宽
    parameter                       CAM_NUM                 =      16     ,
    parameter                       FRAME_DATA_WIDTH        =      LOOK_UP_DATA_WIDTH * 2 + 48     ,   // TCAM编码后数据位宽：144*2+48=336位
    parameter                       FRAME_WORD_COUNT        =      (FRAME_DATA_WIDTH + 15) / 16    ,   // 需要的16位字数：312/16=20个字
    parameter                       FIFO_DEPTH              =      FRAME_WORD_COUNT                ,   // FIFO深度：基于字数+余量
    parameter                       CMD_WIDTH               =      2            , // 命令位宽（写表/改表/删除表）
    parameter                       PORT_ID                 =      3'd0         // 本端口号

)(
    input               wire                                            i_clk                               ,
    input               wire                                            i_rst                               ,
    /*----------------------- 下级模块接口 -----------------------------------------------*/
    input               wire                                            i_cam_busy                          , // 下级模块忙信号
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 写表 - config
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_config_data                       ,    
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_config_mask                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_config_data_cnt                   ,
    output              wire                                            o_config_data_vld                   ,
    // 改表 - change
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_change_data                       ,
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_change_mask                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_change_data_cnt                   ,
    output              wire                                            o_change_data_vld                   ,  
    // 删除表 - delete
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_delete_data                       ,
    output              wire   [(PORT_MNG_DATA_WIDTH-1):0]              o_delete_mask                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_delete_data_cnt                   ,
    output              wire                                            o_delete_data_vld                   ,
    // 状态输出
    output              wire                                            o_wr_ack_busy                       , // 当前模块忙信号
    /*---------------------------------------- 寄存器配置接口 -----------------------------------------*/
    // 端口选择配置
    input    wire [5:0]                       i_cfg_acl_port_sel                    , // 端口ACL参数-配置端口选择
    input    wire                             i_cfg_acl_port_sel_valid              , // 写入有效信号 



    // ACL配置状态指示
    output   wire                             o_cfg_acl_list_rdy_regs               , // 端口ACL参数-写入就绪指示：任一FIFO为空时为1 

    // // 条目选择配置
    // input    wire [4:0]                       i_cfg_acl_item_sel_regs               , // 端口ACL参数-配置条目选择
    // input    wire                             i_cfg_acl_item_sel_regs_valid         , // 写入有效信号
    // output   wire [4:0]                       o_cfg_acl_item_sel_regs               , // 读取条目选择配置
    // output   wire                             o_cfg_acl_item_sel_regs_valid         , // 读取有效信号

    // DMAC编码值配置（6个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_dmac_code_1            , // 端口ACL表项-写入dmac值[15:0]
    input    wire                             i_cfg_acl_item_dmac_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_2            , // 端口ACL表项-写入dmac值[31:16]
    input    wire                             i_cfg_acl_item_dmac_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_3            , // 端口ACL表项-写入dmac值[47:32]
    input    wire                             i_cfg_acl_item_dmac_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_4            , // 端口ACL表项-写入dmac值[63:48]
    input    wire                             i_cfg_acl_item_dmac_code_4_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_5            , // 端口ACL表项-写入dmac值[79:64]
    input    wire                             i_cfg_acl_item_dmac_code_5_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_dmac_code_6            , // 端口ACL表项-写入dmac值[95:80]
    input    wire                             i_cfg_acl_item_dmac_code_6_valid      , // 写入有效信号

    // SMAC编码值配置（6个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_smac_code_1            , // 端口ACL表项-写入smac值[15:0]
    input    wire                             i_cfg_acl_item_smac_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_2            , // 端口ACL表项-写入smac值[31:16]
    input    wire                             i_cfg_acl_item_smac_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_3            , // 端口ACL表项-写入smac值[47:32]
    input    wire                             i_cfg_acl_item_smac_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_4            , // 端口ACL表项-写入smac值[63:48]
    input    wire                             i_cfg_acl_item_smac_code_4_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_5            , // 端口ACL表项-写入smac值[79:64]
    input    wire                             i_cfg_acl_item_smac_code_5_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_smac_code_6            , // 端口ACL表项-写入smac值[95:80]
    input    wire                             i_cfg_acl_item_smac_code_6_valid      , // 写入有效信号

    // VLAN编码值配置（4个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_vlan_code_1            , // 端口ACL表项-写入vlan值[15:0]
    input    wire                             i_cfg_acl_item_vlan_code_1_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_2            , // 端口ACL表项-写入vlan值[31:16]
    input    wire                             i_cfg_acl_item_vlan_code_2_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_3            , // 端口ACL表项-写入vlan值[47:32]
    input    wire                             i_cfg_acl_item_vlan_code_3_valid      , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_vlan_code_4            , // 端口ACL表项-写入vlan值[63:48]
    input    wire                             i_cfg_acl_item_vlan_code_4_valid      , // 写入有效信号

    // Ethertype编码值配置（2个16位字段）
    input    wire [15:0]                      i_cfg_acl_item_ethertype_code_1       , // 端口ACL表项-写入ethertype值[15:0]
    input    wire                             i_cfg_acl_item_ethertype_code_1_valid , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_ethertype_code_2       , // 端口ACL表项-写入ethertype值[31:16]
    input    wire                             i_cfg_acl_item_ethertype_code_2_valid , // 写入有效信号

    // ACL动作配置
    input    wire [7:0]                       i_cfg_acl_item_action_pass_state      , // 端口ACL动作-报文状态
    input    wire                             i_cfg_acl_item_action_pass_state_valid, // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_action_cb_streamhandle , // 端口ACL动作-stream_handle值
    input    wire                             i_cfg_acl_item_action_cb_streamhandle_valid, // 写入有效信号

    input    wire [5:0]                       i_cfg_acl_item_action_flowctrl        , // 端口ACL动作-报文流控选择
    input    wire                             i_cfg_acl_item_action_flowctrl_valid  , // 写入有效信号

    input    wire [15:0]                      i_cfg_acl_item_action_txport          , // 端口ACL动作-报文发送端口映射
    input    wire                             i_cfg_acl_item_action_txport_valid      // 写入有效信号
);

/*---------------------------------------- clog2计算函数 ---------------------------------------------*/
function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = value - 1;
        for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
            temp = temp >> 1;
    end
endfunction 
 

/*---------------------------------------- 内部寄存器定义 -----------------------------------------*/
// 内部控制寄存器
reg    [CMD_WIDTH-1:0]                                                  r_cmd_type                          ; // 命令类型：00-写表，01-改表，10-删除表
reg    [CMD_WIDTH*2-1:0]                                                r_cmd_type_buffer                   ;
reg    [9:0]                                                            r_frame_cnt                         ; // 帧数据计数器
// reg                                                                     r_frame_start                       ; // 帧开始标志
reg                                                                     r_frame_complete                    ; // 帧完成标志

// 乒乓FIFO相关信号
reg                                                                     r_fifo_sel                          ; // FIFO选择信号：0-选择FIFO0，1-选择FIFO1
reg                                                                     r_fifo_rd_sel                       ; // 读FIFO选择信号
reg                                                                     r_fifo_rd_sel_1d                       ; // 读FIFO选择信号
reg                                                                     r_wait_busy_cnt                     ;
reg                                                                     r_wait_busy                         ;
// FIFO0相关信号
reg                                                                     r_fifo0_wr_en                       ;
reg    [REG_DATA_BUS_WIDTH-1:0]                                         r_fifo0_din                         ;
wire                                                                    w_fifo0_full                        ;
wire                                                                    w_fifo0_almost_full                 ;
reg                                                                     r_fifo0_rd_en                       ;
wire   [REG_DATA_BUS_WIDTH-1:0]                                         w_fifo0_dout                        ;
wire                                                                    w_fifo0_empty                       ;
wire                                                                    w_fifo0_almost_empty                ;
wire   [4:0]                                                            w_fifo0_data_cnt                    ;

// FIFO1相关信号  
reg                                                                     r_fifo1_wr_en                       ;
reg    [REG_DATA_BUS_WIDTH-1:0]                                         r_fifo1_din                         ;
wire                                                                    w_fifo1_full                        ;
wire                                                                    w_fifo1_almost_full                 ;
reg                                                                     r_fifo1_rd_en                       ;
wire   [REG_DATA_BUS_WIDTH-1:0]                                         w_fifo1_dout                        ;
wire                                                                    w_fifo1_empty                       ;
wire                                                                    w_fifo1_almost_empty                ;
wire   [4:0]                                                            w_fifo1_data_cnt                    ;

// FIFO统一接口信号（便于后续逻辑使用）
wire                                                                    w_current_fifo_full                 ;
wire                                                                    w_current_fifo_almost_full          ;
wire   [REG_DATA_BUS_WIDTH-1:0]                                         w_current_fifo_dout                 ;
wire                                                                    w_current_fifo_empty                ;
wire                                                                    w_current_fifo_almost_empty         ;
wire   [4:0]                                                            w_current_fifo_data_cnt             ;

// FWFT适配信号（用于保持原有时序逻辑）
reg                                                                     r_fwft_data_valid                   ; // FWFT数据有效信号
reg    [REG_DATA_BUS_WIDTH-1:0]                                         r_fwft_data_reg                     ; // FWFT数据寄存器

// 输出控制寄存器
reg                                                                     r_output_busy                       ;
reg    [1:0]                                                            r_busy_trigger_fifo                 ; // 记录触发busy的FIFO：0-FIFO0触发，1-FIFO1触发
reg    [CMD_WIDTH-1:0]                                                  r_current_cmd                       ; // 当前处理的命令
reg    [DATA_CNT_WIDTH-1:0]                                             r_output_cnt                        ; // 输出计数器
reg                                                                     r_output_valid                      ;
reg    [PORT_MNG_DATA_WIDTH-1:0]                                        r_output_data                       ;
reg    [PORT_MNG_DATA_WIDTH-1:0]                                        r_output_mask                       ;

// 流控制寄存器（新增）
reg                                                                     r_cam_busy_d1                       ; // i_cam_busy延迟一拍，用于检测下降沿
reg                                                                     r_data_valid_flag                   ; // 数据有效标志

// 输出寄存器
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_config_data                      ;
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_config_mask                      ;
reg   [DATA_CNT_WIDTH-1:0]                                              ro_config_data_cnt                  ;
reg                                                                     ro_config_data_vld                  ;
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_change_data                      ;
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_change_mask                      ;
reg   [DATA_CNT_WIDTH-1:0]                                              ro_change_data_cnt                  ;
reg                                                                     ro_change_data_vld                  ;
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_delete_data                      ;
reg   [(PORT_MNG_DATA_WIDTH-1):0]                                       ro_delete_mask                      ;
reg   [DATA_CNT_WIDTH-1:0]                                              ro_delete_data_cnt                  ;
reg                                                                     ro_delete_data_vld                  ;
reg                                                                     ro_wr_ack_busy                      ;
reg                                                                     ro_cfg_acl_list_rdy_regs            ; // 任一FIFO为空，允许开始写入新帧

// 读FIFO选择 
reg    [9:0]                                                            r_read_frame_cnt                    ; // 读帧计数器
reg                                                                     r_read_frame_complete               ; // 读帧完成标志
reg    [5:0]                                                            r_in_word_idx                       ; // 输入字索引（0..21）

// 当前拍的输入有效与数据（组合逻辑）
wire   [15:0]                                                           w_item_data [0:17]                  ;
wire   [17:0]                                                           w_item_valid                        ;

reg    [15:0]                                                           r_item_data_latched [0:20]          ;
reg                                                                     r_item_valid_latched [0:20]         ;
reg                                                                     ri_cfg_acl_port_sel_valid           ;                        

wire                                                                     w_input_valid                       ;
wire    [REG_DATA_BUS_WIDTH-1:0]                                         w_input_data                        ;
/*---------------------------------------- 输出assign -----------------------------------------*/
assign o_config_data     = ro_config_data                              ;
assign o_config_mask     = ro_config_mask                              ;
assign o_config_data_cnt = ro_config_data_cnt                          ;
assign o_config_data_vld = ro_config_data_vld                          ;
assign o_change_data     = ro_change_data                              ;
assign o_change_mask     = ro_change_mask                              ;
assign o_change_data_cnt = ro_change_data_cnt                          ;
assign o_change_data_vld = ro_change_data_vld                          ;
assign o_delete_data     = ro_delete_data                              ;
assign o_delete_mask     = ro_delete_mask                              ;
assign o_delete_data_cnt = ro_delete_data_cnt                          ;
assign o_delete_data_vld = ro_delete_data_vld                          ;
assign o_wr_ack_busy     = r_output_busy                               ;
assign o_cfg_acl_list_rdy_regs = ro_cfg_acl_list_rdy_regs              ;

/*---------------------------------------- 乒乓FIFO统一接口 -----------------------------------------*/
// 写FIFO选择（当前帧结束时切换）
assign w_current_fifo_full        = r_fifo_sel ? w_fifo1_full        : w_fifo0_full        ;
assign w_current_fifo_almost_full = r_fifo_sel ? w_fifo1_almost_full : w_fifo0_almost_full ;

// 读FIFO选择
assign w_current_fifo_dout         = r_fifo_rd_sel ? w_fifo1_dout         : w_fifo0_dout         ;
assign w_current_fifo_empty        = r_fifo_rd_sel ? w_fifo1_empty        : w_fifo0_empty        ;
assign w_current_fifo_almost_empty = r_fifo_rd_sel ? w_fifo1_almost_empty : w_fifo0_almost_empty ;
assign w_current_fifo_data_cnt     = r_fifo_rd_sel ? w_fifo1_data_cnt     : w_fifo0_data_cnt     ;

assign w_item_data[0]   = i_cfg_acl_item_dmac_code_1                   ;
assign w_item_data[1]   = i_cfg_acl_item_dmac_code_2                   ;
assign w_item_data[2]   = i_cfg_acl_item_dmac_code_3                   ;
assign w_item_data[3]   = i_cfg_acl_item_dmac_code_4                   ;
assign w_item_data[4]   = i_cfg_acl_item_dmac_code_5                   ;
assign w_item_data[5]   = i_cfg_acl_item_dmac_code_6                   ;
assign w_item_data[6]   = i_cfg_acl_item_smac_code_1                   ;
assign w_item_data[7]   = i_cfg_acl_item_smac_code_2                   ;
assign w_item_data[8]   = i_cfg_acl_item_smac_code_3                   ;
assign w_item_data[9]   = i_cfg_acl_item_smac_code_4                   ;
assign w_item_data[10]  = i_cfg_acl_item_smac_code_5                   ;
assign w_item_data[11]  = i_cfg_acl_item_smac_code_6                   ;
assign w_item_data[12]  = i_cfg_acl_item_vlan_code_1                   ;
assign w_item_data[13]  = i_cfg_acl_item_vlan_code_2                   ;
assign w_item_data[14]  = i_cfg_acl_item_vlan_code_3                   ;
assign w_item_data[15]  = i_cfg_acl_item_vlan_code_4                   ;
assign w_item_data[16]  = i_cfg_acl_item_ethertype_code_1              ;
assign w_item_data[17]  = i_cfg_acl_item_ethertype_code_2              ; 
       
assign w_item_valid[0]   = i_cfg_acl_item_dmac_code_1_valid            ;
assign w_item_valid[1]   = i_cfg_acl_item_dmac_code_2_valid            ;
assign w_item_valid[2]   = i_cfg_acl_item_dmac_code_3_valid            ;
assign w_item_valid[3]   = i_cfg_acl_item_dmac_code_4_valid            ;
assign w_item_valid[4]   = i_cfg_acl_item_dmac_code_5_valid            ;
assign w_item_valid[5]   = i_cfg_acl_item_dmac_code_6_valid            ;
assign w_item_valid[6]   = i_cfg_acl_item_smac_code_1_valid            ;
assign w_item_valid[7]   = i_cfg_acl_item_smac_code_2_valid            ;
assign w_item_valid[8]   = i_cfg_acl_item_smac_code_3_valid            ;
assign w_item_valid[9]   = i_cfg_acl_item_smac_code_4_valid            ;
assign w_item_valid[10]  = i_cfg_acl_item_smac_code_5_valid            ;
assign w_item_valid[11]  = i_cfg_acl_item_smac_code_6_valid            ;
assign w_item_valid[12]  = i_cfg_acl_item_vlan_code_1_valid            ;
assign w_item_valid[13]  = i_cfg_acl_item_vlan_code_2_valid            ;
assign w_item_valid[14]  = i_cfg_acl_item_vlan_code_3_valid            ;
assign w_item_valid[15]  = i_cfg_acl_item_vlan_code_4_valid            ;
assign w_item_valid[16]  = i_cfg_acl_item_ethertype_code_1_valid       ;
assign w_item_valid[17]  = i_cfg_acl_item_ethertype_code_2_valid       ; 

/*---------------------------------------- 命令与输入数据解析 -----------------------------------------*/
 
// 端口匹配
wire w_port_match;
assign w_port_match = (i_cfg_acl_port_sel[2:0] == PORT_ID);

always @(posedge i_clk) begin
    ri_cfg_acl_port_sel_valid <= i_cfg_acl_port_sel_valid;
end
// 命令解析：i_cfg_acl_port_sel[5:3]
always @(posedge i_clk) begin
    if (i_rst) begin
        r_cmd_type <= 2'b00;
    end else if (i_cfg_acl_port_sel_valid == 1'd1 && w_port_match == 1'd1) begin
        case(i_cfg_acl_port_sel[5:3])
            3'd0: r_cmd_type <= 2'b00; // 写
            3'd1: r_cmd_type <= 2'b01; // 改
            3'd2: r_cmd_type <= 2'b10; // 删
            default: r_cmd_type <= 2'b00;
        endcase
    end
end

// 逐拍输入顺序索引（0开始：DMAC1..6, SMAC1..6, VLAN1..4, ETH1..2, ACT_pass, ACT_cb, ACT_flow, ACT_txport）
always @(posedge i_clk) begin
    if (i_rst || r_frame_complete) begin
        r_in_word_idx <= 6'd0;
    end else if (w_input_valid == 1'd1 && w_port_match == 1'd1 && w_current_fifo_full == 1'd0) begin
        r_in_word_idx <= r_in_word_idx + 1'b1;
    end
end



genvar i;
generate
    for (i = 0; i < 18; i = i + 1) begin : gen_input_latch
        always @(posedge i_clk) begin
            if (i_rst || r_frame_complete) begin
                r_item_valid_latched[i] <= 1'b0;
                r_item_data_latched[i]  <= 16'b0; 
            end else begin
                r_item_data_latched[i]  <= w_item_valid[i] ? w_item_data[i]  : r_item_data_latched[i];
                r_item_valid_latched[i] <= w_item_valid[i] ? 1'b1            : r_item_valid_latched[i];
            end 
        end 
    end
endgenerate

// Special handling for spliced items 18, 19, 20, 21
always @(posedge i_clk) begin
    if (i_rst || r_frame_complete) begin
        r_item_valid_latched[18] <= 1'b0;
        r_item_data_latched[18]  <= 16'b0;
    end else begin
        if (i_cfg_acl_item_action_pass_state_valid)
             r_item_data_latched[18][15:8] <= i_cfg_acl_item_action_pass_state;
        
        if (i_cfg_acl_item_action_cb_streamhandle_valid) begin
             r_item_data_latched[18][7:0] <= i_cfg_acl_item_action_cb_streamhandle[15:8];
             r_item_valid_latched[18] <= 1'b1;
        end
    end
end

always @(posedge i_clk) begin
    if (i_rst || r_frame_complete) begin
        r_item_valid_latched[19] <= 1'b0;
        r_item_data_latched[19]  <= 16'b0;
    end else begin
        if (i_cfg_acl_item_action_cb_streamhandle_valid)
             r_item_data_latched[19][15:8] <= i_cfg_acl_item_action_cb_streamhandle[7:0];

        if (i_cfg_acl_item_action_flowctrl_valid)
             r_item_data_latched[19][7:2] <= i_cfg_acl_item_action_flowctrl;

        if (i_cfg_acl_item_action_txport_valid) begin
             r_item_data_latched[19][1:0] <= i_cfg_acl_item_action_txport[15:14];
             r_item_valid_latched[19] <= 1'b1;
        end
    end
end

always @(posedge i_clk) begin
    if (i_rst || r_frame_complete) begin
        r_item_valid_latched[20] <= 1'b0;
        r_item_data_latched[20]  <= 16'b0;
    end else begin
        if (i_cfg_acl_item_action_txport_valid) begin
             r_item_data_latched[20] <= {i_cfg_acl_item_action_txport[13:0],2'd0};
             r_item_valid_latched[20] <= 1'b1;
        end
    end
end
 

assign w_input_valid = (r_in_word_idx <= 6'd20) ? r_item_valid_latched[r_in_word_idx] : 1'b0;
assign w_input_data  = (r_in_word_idx <= 6'd20) ? r_item_data_latched[r_in_word_idx]  : {REG_DATA_BUS_WIDTH{1'b0}};

// 命令缓冲：根据当前写入所使用的FIFO分别记录
always @(posedge i_clk) begin
    if (i_rst) begin
        r_cmd_type_buffer <= 4'b0;
    end else if (w_port_match == 1'd1 && ri_cfg_acl_port_sel_valid == 1'd1) begin
        if (!r_fifo_sel) begin
            r_cmd_type_buffer[1:0] <= r_cmd_type;
        end else begin
            r_cmd_type_buffer[3:2] <= r_cmd_type;
        end
    end
end
/*---------------------------------------- 乒乓FIFO选择控制 -----------------------------------------*/
// 写FIFO选择：当一帧数据收集完成时切换到另一个FIFO
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo_sel <= 1'b0 ;
    end else begin
        r_fifo_sel <= r_frame_complete ? ~r_fifo_sel : r_fifo_sel ;
    end
end


// 读帧计数器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_read_frame_cnt <= 10'b0 ;
    end else begin
        if (r_read_frame_complete) begin
            r_read_frame_cnt <= 10'b0 ;  // 读帧完成后复位
        end else if (r_fifo0_rd_en == 1'd1 || r_fifo1_rd_en == 1'd1) begin
            r_read_frame_cnt <= r_read_frame_cnt + 1'b1 ;  // 读取数据时计数
        end
    end
end

// 读帧完成标志 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_read_frame_complete <= 1'b0 ;
    end else begin
        r_read_frame_complete <= ((r_fifo0_rd_en == 1'd1 || r_fifo1_rd_en == 1'd1) && 
                                 (r_read_frame_cnt == (FRAME_WORD_COUNT - 1))) ? 1'b1 : 1'b0 ;
    end
end

// 读FIFO选择 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo_rd_sel <= 1'b0 ;
    end else begin
        if (r_read_frame_complete) begin
            // 读完一帧后检查另一个FIFO是否有数据，有则切换
            if ((r_fifo_rd_sel == 1'b0 ) || 
                (r_fifo_rd_sel == 1'b1 )) begin
                r_fifo_rd_sel <= ~r_fifo_rd_sel ;
            end
        end else if (w_current_fifo_empty == 1'd1 && i_cam_busy == 1'd0) begin
            // 如果当前选择的FIFO为空但另一个FIFO有数据，则切换 
            if ((r_fifo_rd_sel == 1'b0 && !w_fifo1_empty) || 
                (r_fifo_rd_sel == 1'b1 && !w_fifo0_empty)) begin
                r_fifo_rd_sel <= ~r_fifo_rd_sel ;
            end
        end
    end
end 

/*---------------------------------------- FWFT适配逻辑（简化版本） -----------------------------------------*/
// FWFT数据有效信号 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fwft_data_valid <= 1'b0 ;
    end else begin 
        r_fwft_data_valid <= (r_fifo0_rd_en == 1'd1 || r_fifo1_rd_en == 1'd1);
    end
end

// FWFT数据寄存器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fwft_data_reg <= {REG_DATA_BUS_WIDTH{1'b0}} ;
    end else begin 
        r_fwft_data_reg <= (r_fifo0_rd_en == 1'd1 || r_fifo1_rd_en == 1'd1) ? w_current_fifo_dout : r_fwft_data_reg ;
    end
end  

// i_cam_busy下降沿检测
always @(posedge i_clk) begin
    if (i_rst) begin
        r_cam_busy_d1 <= 1'b0 ;
        r_fifo_rd_sel_1d <= 1'b0;
    end else begin
        r_cam_busy_d1 <= i_cam_busy ;
        r_fifo_rd_sel_1d <= r_fifo_rd_sel;
    end
end

// 数据有效标志 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_data_valid_flag <= 1'b0 ;
    end else begin
        // 当读取FIFO时拉高，当下级busy下降沿时清除
        if (r_fifo0_rd_en == 1'd1 || r_fifo1_rd_en == 1'd1) begin
            r_data_valid_flag <= 1'b1 ;
        end else if ((r_cam_busy_d1 == 1'd1 && i_cam_busy == 1'd0) || (r_cmd_type > 2'b0 && i_cam_busy == 1'd0)) begin
            r_data_valid_flag <= 1'b0 ;
        end
    end
end

// 帧数据计数器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_frame_cnt <= 10'b0 ;
    end else begin
        r_frame_cnt <= r_frame_complete ? 10'b0 :
                   (w_input_valid == 1'd1 && w_port_match == 1'd1) ? r_frame_cnt + 1'b1 : r_frame_cnt;
    end
end
 
// 帧完成标志 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_frame_complete <= 1'b0 ;
    end else begin
        r_frame_complete <= (r_frame_cnt == (FRAME_WORD_COUNT - 10'd1)&& r_frame_complete == 1'd0) ? 1'b1 : 1'b0 ;  // 收到所有16位数据时帧完成
    end
end
 
// 双FIFO写使能控制 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo0_wr_en <= 1'b0 ;
        r_fifo1_wr_en <= 1'b0 ;
    end else begin
        r_fifo0_wr_en <= (w_input_valid == 1'd1 && w_port_match == 1'd1 && w_current_fifo_full == 1'd0 && r_fifo_sel == 1'b0) ? 1'b1 : 1'b0;
        r_fifo1_wr_en <= (w_input_valid == 1'd1 && w_port_match == 1'd1 && w_current_fifo_full == 1'd0 && r_fifo_sel == 1'b1) ? 1'b1 : 1'b0;
    end
end
 
// 双FIFO写数据 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo0_din <= {REG_DATA_BUS_WIDTH{1'b0}} ;
        r_fifo1_din <= {REG_DATA_BUS_WIDTH{1'b0}} ;
    end else begin
        r_fifo0_din <= (w_input_valid == 1'd1 && w_port_match == 1'd1 && r_fifo_sel == 1'b0) ? w_input_data : r_fifo0_din ;
        r_fifo1_din <= (w_input_valid == 1'd1 && w_port_match == 1'd1 && r_fifo_sel == 1'b1) ? w_input_data : r_fifo1_din ;
    end
end 
 
// 输出忙信号控制 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_busy <= 1'b0 ;
    end else begin 
        r_output_busy <= (r_output_busy == 1'd0) ? 
                         ((w_fifo0_full == 1'd1 && w_fifo1_empty == 1'd0 && r_busy_trigger_fifo != 'd0) || 
                          (w_fifo1_full == 1'd1 && w_fifo0_empty == 1'd0 && r_busy_trigger_fifo != 'd1) ? 1'b1 : r_output_busy) : 
                         ((r_busy_trigger_fifo == 1'b0) ? (w_fifo1_empty ? 1'b0 : r_output_busy) : (w_fifo0_empty ? 1'b0 : r_output_busy));
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        r_busy_trigger_fifo <= 2'd0 ;
    end else begin 
        r_busy_trigger_fifo <= (r_output_busy == 1'd0) ? 
                               ((w_fifo0_full == 1'd1 && w_fifo1_empty == 1'd0 && r_busy_trigger_fifo != 'd0) ? 1'b0 : 
                                (w_fifo1_full == 1'd1 && w_fifo0_empty == 1'd0 && r_busy_trigger_fifo != 'd1) ? 1'b1 : r_busy_trigger_fifo) : 
                               r_busy_trigger_fifo;
    end
end
 
// 当前处理命令寄存 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_current_cmd <= 2'b00 ;
    end else begin
        r_current_cmd <= r_fifo_rd_sel ? r_cmd_type_buffer[3:2] : r_cmd_type_buffer[1:0];
    end
end
 
// 双FIFO读使能控制 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo0_rd_en <= 1'b0 ;
        r_fifo1_rd_en <= 1'b0 ;
    end else begin 
        r_fifo0_rd_en <= (!w_current_fifo_empty && !i_cam_busy && !r_data_valid_flag && 
                         r_fifo_rd_sel == 1'b0 && !r_fifo0_rd_en && !r_wait_busy) ? 1'b1 : 1'b0 ;
        r_fifo1_rd_en <= (!w_current_fifo_empty && !i_cam_busy && !r_data_valid_flag && 
                         r_fifo_rd_sel == 1'b1 && !r_fifo1_rd_en && !r_wait_busy) ? 1'b1 : 1'b0 ;
    end
end

always @(posedge i_clk) begin
    if (i_rst) begin
        r_wait_busy <= 1'b0;
    end else begin
        r_wait_busy <= (r_fifo_rd_sel_1d != r_fifo_rd_sel) ? 1'b1 :
                       (r_wait_busy_cnt == 1'b1)           ? 1'b0 :
                                                             r_wait_busy;
    end
end 

always @(posedge i_clk) begin
    if (i_rst) begin
        r_wait_busy_cnt <= 1'd0 ;
    end else begin
        r_wait_busy_cnt <= r_wait_busy;
    end
end

// 输出计数器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_cnt <= {DATA_CNT_WIDTH{1'b0}} ;
    end else begin  
        if (r_output_valid && (r_output_cnt == (LOOK_UP_DATA_WIDTH/8 + 3 - 1))) begin
            r_output_cnt <= {DATA_CNT_WIDTH{1'b0}} ;
        end 
        else if (r_output_valid) begin
            r_output_cnt <= r_output_cnt + 1'b1 ;
        end
    end
end 

// 输出有效信号 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_valid <= 1'b0 ;
    end else begin
        r_output_valid <= r_fwft_data_valid ;
    end
end
 
// 输出数据解析，16bit -> 8bit数据 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_data <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
    end else begin
        r_output_data <= r_fwft_data_valid ? 
                         {(r_fwft_data_reg[15:14] == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[13:12] == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[11:10] == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[9:8]   == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[7:6]   == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[5:4]   == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[3:2]   == 2'b01) ? 1'b1 : 1'b0 ,
                          (r_fwft_data_reg[1:0]   == 2'b01) ? 1'b1 : 1'b0 } : 
                         {PORT_MNG_DATA_WIDTH{1'b0}} ;  // 无有效数据时输出0
    end
end
 
// 输出掩码生成，x态(10)对应掩码0，其他对应掩码1 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_mask <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
    end else begin
        r_output_mask <= r_fwft_data_valid ? 
                         {(r_fwft_data_reg[15:14] >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[13:12] >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[11:10] >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[9:8]   >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[7:6]   >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[5:4]   >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[3:2]   >= 2'b10) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[1:0]   >= 2'b10) ? 1'b0 : 1'b1} : 
                         {PORT_MNG_DATA_WIDTH{1'b0}} ;  // 无有效数据时输出0
    end
end
 
// config相关输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_config_data     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_config_mask     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_config_data_cnt <= {DATA_CNT_WIDTH{1'b0}}      ;
        ro_config_data_vld <= 1'b0                        ;
    end else begin
        ro_config_data     <= (r_current_cmd == 2'b00) ? r_output_data : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_config_mask     <= (r_current_cmd == 2'b00) ? r_output_mask : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_config_data_cnt <= (r_current_cmd == 2'b00) ? r_output_cnt  : {DATA_CNT_WIDTH{1'b0}}      ;
        ro_config_data_vld <= (r_current_cmd == 2'b00) ? r_output_valid: 1'b0                        ;
    end
end

// change相关输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_change_data     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_change_mask     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_change_data_cnt <= {DATA_CNT_WIDTH{1'b0}}      ;
        ro_change_data_vld <= 1'b0                        ;
    end else begin
        ro_change_data     <= (r_current_cmd == 2'b01) ? r_output_data : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_change_mask     <= (r_current_cmd == 2'b01) ? r_output_mask : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_change_data_cnt <= (r_current_cmd == 2'b01) ? r_output_cnt  : {DATA_CNT_WIDTH{1'b0}}      ;
        ro_change_data_vld <= (r_current_cmd == 2'b01) ? r_output_valid: 1'b0                        ;
    end
end

// delete相关输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_delete_data     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_delete_mask     <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_delete_data_cnt <= {DATA_CNT_WIDTH{1'b0}}      ;
        ro_delete_data_vld <= 1'b0                        ;
    end else begin
        ro_delete_data     <= (r_current_cmd == 2'b10) ? r_output_data : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_delete_mask     <= (r_current_cmd == 2'b10) ? r_output_mask : {PORT_MNG_DATA_WIDTH{1'b0}} ;
        ro_delete_data_cnt <= (r_current_cmd == 2'b10) ? r_output_cnt  : {DATA_CNT_WIDTH{1'b0}}      ;
        ro_delete_data_vld <= (r_current_cmd == 2'b10) ? r_output_valid: 1'b0                        ;
    end
end

// 忙信号输出
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_wr_ack_busy <= 1'b0 ;
    end else begin
        ro_wr_ack_busy <= r_output_busy ;
    end
end

// 写入就绪指示：当乒乓FIFO中至少有一个为空时拉高，表示可以继续写入新的ACL帧数据
always @(posedge i_clk) begin
    if (i_rst) begin
        ro_cfg_acl_list_rdy_regs <= 1'b0 ;
    end else begin
        ro_cfg_acl_list_rdy_regs <= (w_fifo0_empty || w_fifo1_empty) ? 1'b1 : 1'b0 ;
    end
end
 

/*---------------------------------------- 乒乓FIFO例化 -----------------------------------------*/
// FIFO0例化
sync_fifo #(
    .DEPTH                   (FIFO_DEPTH               ),
    .WIDTH                   (REG_DATA_BUS_WIDTH       ),
    .ALMOST_FULL_THRESHOLD   (1                        ),
    .ALMOST_EMPTY_THRESHOLD  (1                        ),
    .FLOP_DATA_OUT           (1                        ) //1为fwft ， 0为standard
) u_sync_fifo0 (
    .i_clk                   (i_clk                    ),
    .i_rst                   (i_rst                    ),
    .i_wr_en                 (r_fifo0_wr_en            ),
    .i_din                   (r_fifo0_din              ),
    .o_full                  (w_fifo0_full             ),
    .i_rd_en                 (r_fifo0_rd_en            ),
    .o_dout                  (w_fifo0_dout             ),
    .o_empty                 (w_fifo0_empty            ),
    .o_almost_full           (w_fifo0_almost_full      ),
    .o_almost_empty          (w_fifo0_almost_empty     ),
    .o_data_cnt              (w_fifo0_data_cnt         )
);

// FIFO1例化
sync_fifo #(
    .DEPTH                   (FIFO_DEPTH               ),
    .WIDTH                   (REG_DATA_BUS_WIDTH       ),
    .ALMOST_FULL_THRESHOLD   (1                        ),
    .ALMOST_EMPTY_THRESHOLD  (1                        ),
    .FLOP_DATA_OUT           (1                        ) //1为fwft ， 0为standard
) u_sync_fifo1 (
    .i_clk                   (i_clk                    ),
    .i_rst                   (i_rst                    ),
    .i_wr_en                 (r_fifo1_wr_en            ),
    .i_din                   (r_fifo1_din              ),
    .o_full                  (w_fifo1_full             ),
    .i_rd_en                 (r_fifo1_rd_en            ),
    .o_dout                  (w_fifo1_dout             ),
    .o_empty                 (w_fifo1_empty            ),
    .o_almost_full           (w_fifo1_almost_full      ),
    .o_almost_empty          (w_fifo1_almost_empty     ),
    .o_data_cnt              (w_fifo1_data_cnt         )
);


endmodule