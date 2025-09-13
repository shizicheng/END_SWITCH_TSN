// `include "synth_cmd_define.vh"

module wr_ack_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       CAM_MODEL               =      1        ,   // 1 - CAM 表,0 - TCAM 表
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,   // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                       DATA_CNT_WIDTH          =      clog2(LOOK_UP_DATA_WIDTH/8)       ,   // cam存储块的索引位宽
    parameter                       CAM_NUM                 =      1024     ,
    parameter                       FRAME_DATA_WIDTH        =      LOOK_UP_DATA_WIDTH * 2 + 48     ,   // TCAM编码后数据位宽：144*2+48=336位
    parameter                       FRAME_WORD_COUNT        =      (FRAME_DATA_WIDTH + 15) / 16    ,   // 需要的16位字数：312/16=20个字
    parameter                       FIFO_DEPTH              =      FRAME_WORD_COUNT                ,   // FIFO深度：基于字数+余量
    parameter                       CMD_WIDTH               =      2            // 命令位宽（写表/改表/删除表）

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
    // 寄存器控制信号                     
    input               wire                                            i_refresh_list_pulse                , // 刷新寄存器列表（状态寄存器和控制寄存器）
    input               wire                                            i_switch_err_cnt_clr                , // 刷新错误计数器
    input               wire                                            i_switch_err_cnt_stat               , // 刷新错误状态寄存器
    // 寄存器写控制接口             
    input               wire                                            i_switch_reg_bus_we                 , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]                 i_switch_reg_bus_we_addr            , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]                 i_switch_reg_bus_we_din             , // 寄存器写数据
    input               wire                                            i_switch_reg_bus_we_din_v             // 寄存器写数据使能
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

// 读FIFO选择 
reg    [9:0]                                                            r_read_frame_cnt                    ; // 读帧计数器
reg                                                                     r_read_frame_complete               ; // 读帧完成标志
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

/*---------------------------------------- 乒乓FIFO统一接口 -----------------------------------------*/
// 写FIFO选择（当前帧结束时切换）
assign w_current_fifo_full        = r_fifo_sel ? w_fifo1_full        : w_fifo0_full        ;
assign w_current_fifo_almost_full = r_fifo_sel ? w_fifo1_almost_full : w_fifo0_almost_full ;

// 读FIFO选择
assign w_current_fifo_dout         = r_fifo_rd_sel ? w_fifo1_dout         : w_fifo0_dout         ;
assign w_current_fifo_empty        = r_fifo_rd_sel ? w_fifo1_empty        : w_fifo0_empty        ;
assign w_current_fifo_almost_empty = r_fifo_rd_sel ? w_fifo1_almost_empty : w_fifo0_almost_empty ;
assign w_current_fifo_data_cnt     = r_fifo_rd_sel ? w_fifo1_data_cnt     : w_fifo0_data_cnt     ;

/*---------------------------------------- 命令类型解析 -----------------------------------------*/
// 解析寄存器地址 
always @(*) begin
    if (i_rst) begin
        r_cmd_type = 2'b00 ;
    end else begin
        r_cmd_type = (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v) ?
                      (i_switch_reg_bus_we_addr[7:6] == 2'b00) ? 2'b00 :  // 写表
                      (i_switch_reg_bus_we_addr[7:6] == 2'b01) ? 2'b01 :  // 改表
                      (i_switch_reg_bus_we_addr[7:6] == 2'b10) ? 2'b10 :  // 删除表
                                                                  2'b00 : 2'b00 ;
    end
end 

always @(posedge i_clk) begin
    if (i_rst) begin
        r_cmd_type_buffer <= 4'b0;
    end else begin
        r_cmd_type_buffer[1:0] <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && !r_fifo_sel) ? r_cmd_type : r_cmd_type_buffer[1:0];
        r_cmd_type_buffer[3:2] <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v &&  r_fifo_sel) ? r_cmd_type : r_cmd_type_buffer[3:2];
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
        end else if (r_fifo0_rd_en || r_fifo1_rd_en) begin
            r_read_frame_cnt <= r_read_frame_cnt + 1'b1 ;  // 读取数据时计数
        end
    end
end

// 读帧完成标志 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_read_frame_complete <= 1'b0 ;
    end else begin
        r_read_frame_complete <= ((r_fifo0_rd_en || r_fifo1_rd_en) && 
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
        end else if (w_current_fifo_empty && !i_cam_busy) begin
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
        r_fwft_data_valid <= (r_fifo0_rd_en || r_fifo1_rd_en);
    end
end

// FWFT数据寄存器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fwft_data_reg <= {REG_DATA_BUS_WIDTH{1'b0}} ;
    end else begin 
        r_fwft_data_reg <= (r_fifo0_rd_en || r_fifo1_rd_en) ? w_current_fifo_dout : r_fwft_data_reg ;
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
        if (r_fifo0_rd_en || r_fifo1_rd_en) begin
            r_data_valid_flag <= 1'b1 ;
        end else if ((r_cam_busy_d1 && !i_cam_busy) || (r_cmd_type > 2'b0 && !i_cam_busy)) begin
            r_data_valid_flag <= 1'b0 ;
        end
    end
end

// 帧数据计数器 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_frame_cnt <= 10'b0 ;
    end else begin
        r_frame_cnt <= r_frame_complete ? 10'b0 :  // 帧完成后复位计数器
                       (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v) ? 
                       r_frame_cnt + 1'b1 :  r_frame_cnt ;
    end
end
 
// 帧完成标志 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_frame_complete <= 1'b0 ;
    end else begin
        r_frame_complete <= (r_frame_cnt == (FRAME_WORD_COUNT - 1)&& !r_frame_complete) ? 1'b1 : 1'b0 ;  // 收到所有16位数据时帧完成
    end
end
 
// 双FIFO写使能控制 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo0_wr_en <= 1'b0 ;
        r_fifo1_wr_en <= 1'b0 ;
    end else begin
        r_fifo0_wr_en <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && 
                          !w_current_fifo_full && r_fifo_sel == 1'b0) ? 1'b1 : 1'b0 ;
        r_fifo1_wr_en <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && 
                          !w_current_fifo_full && r_fifo_sel == 1'b1) ? 1'b1 : 1'b0 ;
    end
end
 
// 双FIFO写数据 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_fifo0_din <= {REG_DATA_BUS_WIDTH{1'b0}} ;
        r_fifo1_din <= {REG_DATA_BUS_WIDTH{1'b0}} ;
    end else begin
        r_fifo0_din <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && r_fifo_sel == 1'b0) ? 
                       i_switch_reg_bus_we_din : r_fifo0_din ;
        r_fifo1_din <= (i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && r_fifo_sel == 1'b1) ? 
                       i_switch_reg_bus_we_din : r_fifo1_din ;
    end
end
 
// 输出忙信号控制 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_busy <= 1'b0 ;
        r_busy_trigger_fifo <= 2'd0 ;
    end else begin 
        if (!r_output_busy) begin 
            if (w_fifo0_full && !w_fifo1_empty && r_busy_trigger_fifo != 'd0) begin
                r_output_busy <= 1'b1 ;
                r_busy_trigger_fifo <= 1'b0 ;   
            end else if (w_fifo1_full && !w_fifo0_empty && r_busy_trigger_fifo != 'd1) begin
                r_output_busy <= 1'b1 ;
                r_busy_trigger_fifo <= 1'b1 ;  
            end
        end else begin 
            if (r_busy_trigger_fifo == 1'b0) begin 
                if (w_fifo1_empty) begin
                    r_output_busy <= 1'b0 ; 
                end
            end else begin 
                if (w_fifo0_empty) begin
                    r_output_busy <= 1'b0 ;
                end
            end
        end
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
        r_wait_busy <= 1'd0 ; 
    end else begin
        if (r_fifo_rd_sel_1d != r_fifo_rd_sel) begin
            r_wait_busy <= 1'b1;
        end else if(r_wait_busy_cnt)begin
            r_wait_busy <= 1'b0;
        end
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
                         {(r_fwft_data_reg[15:14] == 2'b00 || r_fwft_data_reg[15:14] == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[13:12] == 2'b00 || r_fwft_data_reg[13:12] == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[11:10] == 2'b00 || r_fwft_data_reg[11:10] == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[9:8]   == 2'b00 || r_fwft_data_reg[9:8]   == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[7:6]   == 2'b00 || r_fwft_data_reg[7:6]   == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[5:4]   == 2'b00 || r_fwft_data_reg[5:4]   == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[3:2]   == 2'b00 || r_fwft_data_reg[3:2]   == 2'b10) ? 1'b0 : 1'b1 ,
                          (r_fwft_data_reg[1:0]   == 2'b00 || r_fwft_data_reg[1:0]   == 2'b10) ? 1'b0 : 1'b1 } : 
                         {PORT_MNG_DATA_WIDTH{1'b0}} ;  // 无有效数据时输出0
    end
end
 
// 输出掩码生成，x态(10)对应掩码0，其他对应掩码1 
always @(posedge i_clk) begin
    if (i_rst) begin
        r_output_mask <= {PORT_MNG_DATA_WIDTH{1'b0}} ;
    end else begin
        r_output_mask <= r_fwft_data_valid ? 
                         {(r_fwft_data_reg[15:14] == 2'b10 || r_fwft_data_reg[15:14] == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[13:12] == 2'b10 || r_fwft_data_reg[13:12] == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[11:10] == 2'b10 || r_fwft_data_reg[11:10] == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[9:8]   == 2'b10 || r_fwft_data_reg[9:8]   == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[7:6]   == 2'b10 || r_fwft_data_reg[7:6]   == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[5:4]   == 2'b10 || r_fwft_data_reg[5:4]   == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[3:2]   == 2'b10 || r_fwft_data_reg[3:2]   == 2'b11) ? 1'b0 : 1'b1,
                          (r_fwft_data_reg[1:0]   == 2'b10 || r_fwft_data_reg[1:0]   == 2'b11) ? 1'b0 : 1'b1} : 
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