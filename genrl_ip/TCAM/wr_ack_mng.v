`include "synth_cmd_define.vh"

module wr_ack_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽 
    parameter                       CAM_MODEL               =      1        ,   // 1 - CAM 表,0 - TCAM 表
    parameter                       REG_ADDR_BUS_WIDTH      =      8        ,   // 接收 MAC 层的配置寄存器地址位宽
    parameter                       REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                       DATA_CNT_WIDTH          =      clog2(LOOK_UP_DATA_WIDTH/8)       ,   // cam存储块的索引位宽
    parameter                       CAM_NUM                 =      1024     

)(
    input               wire                                            i_clk                               ,
    input               wire                                            i_rst                               ,
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 写表 - config
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_config_data                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_config_data_cnt                   ,
    output              wire                                            o_config_data_vld                   ,
    // 改表 - change
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_change_data                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_change_data_cnt                   ,
    output              wire                                            o_change_data_vld                   ,  
    // 删除表 - delete
    output              wire   [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    o_delete_data                       ,
    output              wire   [DATA_CNT_WIDTH-1:0]                     o_delete_data_cnt                   ,
    output              wire                                            o_delete_data_vld                   ,  
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

/*---------------------------------------- 参数定义 -------------------------------------------------*/
// 寄存器地址定义
localparam                      ADDR_CTRL_REG               =       8'h00   ; // 控制寄存器地址
localparam                      ADDR_DATA_REG               =       8'h01   ; // 数据寄存器地址  
localparam                      ADDR_CNT_REG                =       8'h02   ; // 计数寄存器地址

// 操作类型定义
localparam                      OP_CONFIG                   =       2'b00   ; // 写表操作
localparam                      OP_CHANGE                   =       2'b01   ; // 改表操作
localparam                      OP_DELETE                   =       2'b10   ; // 删除表操作

/*---------------------------------------- 输入信号打拍 ---------------------------------------------*/
reg                             ri_refresh_list_pulse                       ; // 刷新寄存器列表脉冲打拍
reg                             ri_switch_err_cnt_clr                       ; // 错误计数清零信号打拍
reg                             ri_switch_err_cnt_stat                      ; // 错误状态寄存器信号打拍

/*---------------------------------------- 内部寄存器信号 -------------------------------------------*/
reg     [REG_DATA_BUS_WIDTH-1:0]    r_ctrl_reg                             ; // 控制寄存器[1:0]-操作类型,[2]-触发位
reg     [REG_DATA_BUS_WIDTH-1:0]    r_data_reg                             ; // 数据寄存器
reg     [REG_DATA_BUS_WIDTH-1:0]    r_cnt_reg                              ; // 计数寄存器

/*---------------------------------------- 内部逻辑信号 ---------------------------------------------*/
reg     [7:0]                       r_decoded_data                         ; // 解码后的8bit数据
reg     [DATA_CNT_WIDTH-1:0]        r_cam_cnt                              ; // CAM索引计数
reg                                 r_operation_trigger                    ; // 操作触发信号
reg                                 r_reg_write_pulse                      ; // 寄存器写入脉冲

/*---------------------------------------- 输出信号寄存器 -------------------------------------------*/
// 写表输出寄存器
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    ro_config_data            ; // 写表数据输出
reg     [DATA_CNT_WIDTH-1:0]                     ro_config_data_cnt        ; // 写表计数输出
reg                                              ro_config_data_vld        ; // 写表有效信号输出

// 改表输出寄存器
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    ro_change_data            ; // 改表数据输出
reg     [DATA_CNT_WIDTH-1:0]                     ro_change_data_cnt        ; // 改表计数输出
reg                                              ro_change_data_vld        ; // 改表有效信号输出

// 删除表输出寄存器
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]    ro_delete_data            ; // 删除表数据输出
reg     [DATA_CNT_WIDTH-1:0]                     ro_delete_data_cnt        ; // 删除表计数输出
reg                                              ro_delete_data_vld        ; // 删除表有效信号输出

/*---------------------------------------- 组合逻辑信号 ---------------------------------------------*/
wire                            w_ctrl_reg_write                           ; // 控制寄存器写入信号
wire                            w_data_reg_write                           ; // 数据寄存器写入信号
wire                            w_cnt_reg_write                            ; // 计数寄存器写入信号
wire    [1:0]                   w_operation_type                           ; // 操作类型

/*---------------------------------------- 输入信号打拍逻辑 --------------------------------------*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_refresh_list_pulse   <= 1'b0;
        ri_switch_err_cnt_clr   <= 1'b0;
        ri_switch_err_cnt_stat  <= 1'b0;
    end else begin
        ri_refresh_list_pulse   <= i_refresh_list_pulse;
        ri_switch_err_cnt_clr   <= i_switch_err_cnt_clr;
        ri_switch_err_cnt_stat  <= i_switch_err_cnt_stat;
    end
end

/*---------------------------------------- 组合逻辑部分 ---------------------------------------------*/
// 寄存器写入信号生成
assign w_ctrl_reg_write = i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && (i_switch_reg_bus_we_addr == ADDR_CTRL_REG);
assign w_data_reg_write = i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && (i_switch_reg_bus_we_addr == ADDR_DATA_REG);
assign w_cnt_reg_write  = i_switch_reg_bus_we && i_switch_reg_bus_we_din_v && (i_switch_reg_bus_we_addr == ADDR_CNT_REG);

// 操作类型提取
assign w_operation_type = r_ctrl_reg[1:0];

// 生成寄存器写入脉冲信号
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_write_pulse <= 1'b0;
    end else begin
        r_reg_write_pulse <= i_switch_reg_bus_we && i_switch_reg_bus_we_din_v;
    end
end

// 控制寄存器管理
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_ctrl_reg <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else begin
        r_ctrl_reg <= w_ctrl_reg_write ? i_switch_reg_bus_we_din : r_ctrl_reg;
    end
end

// 数据寄存器管理
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_data_reg <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else begin
        r_data_reg <= w_data_reg_write ? i_switch_reg_bus_we_din : r_data_reg;
    end
end

// 计数寄存器管理
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_cnt_reg <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else begin
        r_cnt_reg <= w_cnt_reg_write ? i_switch_reg_bus_we_din : r_cnt_reg;
    end
end

// 将16bit数据按2bit一组解码为8bit数据：00->0, 01->1, 10->x态(暂时处理为1)
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_decoded_data <= 8'b0;
    end else begin
        r_decoded_data[0] <= (r_data_reg[1:0] == 2'b01) ? 1'b1 :
                             (r_data_reg[1:0] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[1] <= (r_data_reg[3:2] == 2'b01) ? 1'b1 :
                             (r_data_reg[3:2] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[2] <= (r_data_reg[5:4] == 2'b01) ? 1'b1 :
                             (r_data_reg[5:4] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[3] <= (r_data_reg[7:6] == 2'b01) ? 1'b1 :
                             (r_data_reg[7:6] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[4] <= (r_data_reg[9:8] == 2'b01) ? 1'b1 :
                             (r_data_reg[9:8] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[5] <= (r_data_reg[11:10] == 2'b01) ? 1'b1 :
                             (r_data_reg[11:10] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[6] <= (r_data_reg[13:12] == 2'b01) ? 1'b1 :
                             (r_data_reg[13:12] == 2'b10) ? 1'b1 : 1'b0;
        r_decoded_data[7] <= (r_data_reg[15:14] == 2'b01) ? 1'b1 :
                             (r_data_reg[15:14] == 2'b10) ? 1'b1 : 1'b0;
    end
end
 
// CAM索引计数器管理
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_cam_cnt <= {DATA_CNT_WIDTH{1'b0}};
    end else begin
        r_cam_cnt <= r_cnt_reg[DATA_CNT_WIDTH-1:0];
    end
end
 
// 操作触发信号生成，当控制寄存器触发位被设置时产生脉冲
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_operation_trigger <= 1'b0;
    end else begin
        r_operation_trigger <= w_ctrl_reg_write && i_switch_reg_bus_we_din[2];
    end
end
 
// 写表操作输出控制
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_config_data <= {(PORT_MNG_DATA_WIDTH*CAM_MODEL){1'b0}};
    end else begin
        ro_config_data <= (r_operation_trigger && (w_operation_type == OP_CONFIG)) ? 
                          r_decoded_data[PORT_MNG_DATA_WIDTH*CAM_MODEL-1:0] : ro_config_data;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_config_data_cnt <= {DATA_CNT_WIDTH{1'b0}};
    end else begin
        ro_config_data_cnt <= (r_operation_trigger && (w_operation_type == OP_CONFIG)) ? 
                              r_cam_cnt : ro_config_data_cnt;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_config_data_vld <= 1'b0;
    end else begin
        ro_config_data_vld <= (r_operation_trigger && (w_operation_type == OP_CONFIG)) ? 
                              1'b1 : 1'b0;
    end
end
 
// 改表操作输出控制
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_change_data <= {(PORT_MNG_DATA_WIDTH*CAM_MODEL){1'b0}};
    end else begin
        ro_change_data <= (r_operation_trigger && (w_operation_type == OP_CHANGE)) ? 
                          r_decoded_data[PORT_MNG_DATA_WIDTH*CAM_MODEL-1:0] : ro_change_data;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_change_data_cnt <= {DATA_CNT_WIDTH{1'b0}};
    end else begin
        ro_change_data_cnt <= (r_operation_trigger && (w_operation_type == OP_CHANGE)) ? 
                              r_cam_cnt : ro_change_data_cnt;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_change_data_vld <= 1'b0;
    end else begin
        ro_change_data_vld <= (r_operation_trigger && (w_operation_type == OP_CHANGE)) ? 
                              1'b1 : 1'b0;
    end
end
 
// 删除表操作输出控制
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_delete_data <= {(PORT_MNG_DATA_WIDTH*CAM_MODEL){1'b0}};
    end else begin
        ro_delete_data <= (r_operation_trigger && (w_operation_type == OP_DELETE)) ? 
                          r_decoded_data[PORT_MNG_DATA_WIDTH*CAM_MODEL-1:0] : ro_delete_data;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_delete_data_cnt <= {DATA_CNT_WIDTH{1'b0}};
    end else begin
        ro_delete_data_cnt <= (r_operation_trigger && (w_operation_type == OP_DELETE)) ? 
                              r_cam_cnt : ro_delete_data_cnt;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_delete_data_vld <= 1'b0;
    end else begin
        ro_delete_data_vld <= (r_operation_trigger && (w_operation_type == OP_DELETE)) ? 
                              1'b1 : 1'b0;
    end
end

/*---------------------------------------- 输出信号连接 -----------------------------------------*/
assign o_config_data     = ro_config_data;
assign o_config_data_cnt = ro_config_data_cnt;
assign o_config_data_vld = ro_config_data_vld;

assign o_change_data     = ro_change_data;
assign o_change_data_cnt = ro_change_data_cnt;
assign o_change_data_vld = ro_change_data_vld;

assign o_delete_data     = ro_delete_data;
assign o_delete_data_cnt = ro_delete_data_cnt;
assign o_delete_data_vld = ro_delete_data_vld;

endmodule