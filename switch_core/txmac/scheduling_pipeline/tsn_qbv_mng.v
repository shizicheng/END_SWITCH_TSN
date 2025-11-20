// 门控调度

`include "synth_cmd_define.vh"

module  tsn_qbv_mng #(
    parameter                                                   PORT_FIFO_PRI_NUM       =      8                        // 支持端口优先级 FIFO 的数量
)(
    input               wire                                    i_clk                            ,   // 250MHz
    input               wire                                    i_rst                            ,
    /*---------------------------------------- 寄存器配置接口 --------------------------------------*/
	input				wire   [PORT_FIFO_PRI_NUM-1:0]			i_fifoc_empty					 ,
    input               wire                                    i_refresh_list_pulse             ,
    input               wire   [79:0]                           i_current_time                   ,
    input               wire   [79:0]                           i_Base_time                      ,
    input               wire                                    i_Base_time_vld                  ,
    input               wire                                    i_ConfigChange                   ,
    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_ControlList                    ,
    input               wire   [7:0]                            i_ControlList_len                ,
    input               wire                                    i_ControlList_vld                ,
    input               wire   [15:0]                           i_cycle_time                     ,
    input               wire   [79:0]                           i_cycle_time_extension           ,
    input               wire                                    i_qbv_en                         , 
    // 状态寄存器
    output              wire                                    o_base_time_err                  ,
    output              wire                                    o_control_list_emp_err           ,
    /*---------------------------------- Qav 输入满足信用条件的队列向量结果 -------------------------*/ 
    input               wire   [PORT_FIFO_PRI_NUM-1:0]          i_queque                         , // 输出满足信用值的队列结果向量
    input               wire                                    i_queque_vld                     ,
    /*---------------------------------- 输出门控状态至 QOS 调度模块 ------------------------------*/ 
    output              wire   [PORT_FIFO_PRI_NUM-1:0]          o_ControlList_state              , // 门控列表的状态      
    output              wire                                    o_ControlList_state_vld    
);
// -----------
wire                                    w_copm_flag;
wire                                    w_same_flag;
wire        [PORT_FIFO_PRI_NUM-1:0]     w_ram0_dout;
wire        [PORT_FIFO_PRI_NUM-1:0]     w_ram1_dout;

// -----------
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_0;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_1;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_2;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_3;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_4;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_5;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_6;
(* HU_SET = "current_time_80bit_group", KEEP = "TRUE" *) reg     [9:0]      r_current_time_7;

(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_0;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_1;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_2;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_3;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_4;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_5;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_6;
(* HU_SET = "base_time_80bit_group", KEEP = "TRUE" *)    reg     [9:0]      r_admin_Base_time_7;

reg                                 comp_flag0,comp_flag1,comp_flag2,comp_flag3;
reg                                 comp_flag4,comp_flag5,comp_flag6,comp_flag7;

reg                                 same_flag0,same_flag1,same_flag2,same_flag3;
reg                                 same_flag4,same_flag5,same_flag6,same_flag7;

reg                                 ro_base_time_err;
reg                                 ro_control_list_emp_err;

reg     [PORT_FIFO_PRI_NUM:0]       ri_queque;
reg                                 ri_queque_vld;
reg     [PORT_FIFO_PRI_NUM:0]       rri_queque;
reg                                 rri_queque_vld;
reg                                 r_admin_ConfigChange;
reg     [PORT_FIFO_PRI_NUM-1:0]     r_admin_ControlList;
reg     [7:0]                       r_admin_ControlList_len;
reg                                 r_ControlList_vld;
reg     [15:0]                      r_admin_cycle_time;
reg                                 r_admin_qbv_en;
reg                                 r_Base_time_vld;     

reg     [7:0]                       r_controlList_cnt;
reg                                 r_start;
reg                                 r_config_soc;
reg                                 r_config_eoc;
reg                                 r_rd_pre_proc;
reg                                 r_rd_proc;
reg                                 r_op_ram_wr;
reg                                 r_op_ram_rd;
 
reg    [7:0]                        r_addra_0;
reg    [7:0]                        r_addra_1;
reg                                 r_wea_0,r_wea_1;
reg    [PORT_FIFO_PRI_NUM-1:0]      r_din0,r_din1;

reg    [15:0]                       r_cycle_cnt;
reg                                 r_ram_rd;
reg    [7:0]                        r_addrb_0;
reg    [7:0]                        r_addrb_1;

reg    [PORT_FIFO_PRI_NUM-1:0]      ro_ControlList_state;
reg                                 ro_ControlList_state_vld;

reg    [PORT_FIFO_PRI_NUM-1:0]      r0_admin_ControlList_len;
reg    [PORT_FIFO_PRI_NUM-1:0]      r1_admin_ControlList_len;
reg    [PORT_FIFO_PRI_NUM-1:0]      r2_admin_ControlList_len;

reg                                 r_cycle_complete_0;
reg                                 r_cycle_complete_1;
reg                                 r0_cycle_complete_0;
reg                                 r0_cycle_complete_1;


reg                                 r_same_flag;
reg                                 r0_same_flag;
reg                                 r_ram0_refresh;
reg                                 r_ram1_refresh;

wire   [PORT_FIFO_PRI_NUM-1:0]      w_ControlList_state;
wire                                w_configlist_refresh;
wire                                w_configpending;
wire                                w_ena_0;
wire                                w_ena_1;
wire                                w_dout_vld;
reg    [1:0]                        r_dout_vld;
// -----------
assign      w_copm_flag                 =   comp_flag0 | comp_flag1 | comp_flag2 | comp_flag3 | comp_flag4 | comp_flag5 | comp_flag6 | comp_flag7;
assign      w_same_flag                 =   same_flag0 & same_flag1 & same_flag2 & same_flag3 & same_flag4 & same_flag5 & same_flag6 & same_flag7 ; 
assign      o_base_time_err             =   ro_base_time_err; 
assign      o_control_list_emp_err      =   ro_control_list_emp_err;
assign      w_configlist_refresh        =   i_refresh_list_pulse | i_rst;
assign      o_ControlList_state         =   w_ControlList_state;
assign      o_ControlList_state_vld     =   ro_ControlList_state_vld;
// -----------
// ------ wr_ram_proc -------
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ri_queque       <= 8'd0;
        ri_queque_vld   <= 1'b0;
    end else begin
        ri_queque       <= (i_queque_vld == 1'b1) ? i_queque : ri_queque;
        ri_queque_vld   <= (i_queque_vld == 1'b1) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rri_queque       <= 8'd0;
        rri_queque_vld   <= 1'b0;
    end else begin
        rri_queque       <= (i_qbv_en == 1'b1 && i_queque_vld == 1'b1) ? i_queque : rri_queque;
        rri_queque_vld   <= (i_qbv_en == 1'b1 && i_queque_vld == 1'b1) ? 1'b1 : 
							 i_fifoc_empty == {PORT_FIFO_PRI_NUM{1'b1}} ? 1'b0 : rri_queque_vld;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_current_time_0    <=      10'd0;
        r_current_time_1    <=      10'd0;
        r_current_time_2    <=      10'd0;
        r_current_time_3    <=      10'd0;
        r_current_time_4    <=      10'd0;
        r_current_time_5    <=      10'd0;
        r_current_time_6    <=      10'd0;
        r_current_time_7    <=      10'd0;
    end else begin
        r_current_time_0    <=      i_current_time[9:0];
        r_current_time_1    <=      i_current_time[19:10];
        r_current_time_2    <=      i_current_time[29:20];
        r_current_time_3    <=      i_current_time[39:30];
        r_current_time_4    <=      i_current_time[49:40];
        r_current_time_5    <=      i_current_time[59:50];
        r_current_time_6    <=      i_current_time[69:60];
        r_current_time_7    <=      i_current_time[79:70];
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_admin_Base_time_0 <= 10'd0;
        r_admin_Base_time_1 <= 10'd0;
        r_admin_Base_time_2 <= 10'd0;
        r_admin_Base_time_3 <= 10'd0;
        r_admin_Base_time_4 <= 10'd0;
        r_admin_Base_time_5 <= 10'd0;
        r_admin_Base_time_6 <= 10'd0;
        r_admin_Base_time_7 <= 10'd0;
    end else begin
        r_admin_Base_time_0 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[9:0]   : r_admin_Base_time_0;
        r_admin_Base_time_1 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[19:10] : r_admin_Base_time_1;
        r_admin_Base_time_2 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[29:20] : r_admin_Base_time_2;
        r_admin_Base_time_3 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[39:30] : r_admin_Base_time_3;
        r_admin_Base_time_4 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[49:40] : r_admin_Base_time_4;
        r_admin_Base_time_5 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[59:50] : r_admin_Base_time_5;
        r_admin_Base_time_6 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[69:60] : r_admin_Base_time_6;
        r_admin_Base_time_7 <= ( i_Base_time_vld == 1'b1 ) ? i_Base_time[79:70] : r_admin_Base_time_7;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        comp_flag0 <= 1'b0;
        comp_flag1 <= 1'b0;
        comp_flag2 <= 1'b0;
        comp_flag3 <= 1'b0;
        comp_flag4 <= 1'b0;
        comp_flag5 <= 1'b0;
        comp_flag6 <= 1'b0;
        comp_flag7 <= 1'b0;
    end else begin
        comp_flag0 <= (r_admin_Base_time_0 < r_current_time_0) ? 1'b1 : 1'b0;
        comp_flag1 <= (r_admin_Base_time_1 < r_current_time_1) ? 1'b1 : 1'b0;
        comp_flag2 <= (r_admin_Base_time_2 < r_current_time_2) ? 1'b1 : 1'b0;
        comp_flag3 <= (r_admin_Base_time_3 < r_current_time_3) ? 1'b1 : 1'b0;
        comp_flag4 <= (r_admin_Base_time_4 < r_current_time_4) ? 1'b1 : 1'b0;
        comp_flag5 <= (r_admin_Base_time_5 < r_current_time_5) ? 1'b1 : 1'b0;
        comp_flag6 <= (r_admin_Base_time_6 < r_current_time_6) ? 1'b1 : 1'b0;
        comp_flag7 <= (r_admin_Base_time_7 < r_current_time_7) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        same_flag0 <= 1'b0;
        same_flag1 <= 1'b0;
        same_flag2 <= 1'b0;
        same_flag3 <= 1'b0;
        same_flag4 <= 1'b0;
        same_flag5 <= 1'b0;
        same_flag6 <= 1'b0;
        same_flag7 <= 1'b0;
    end else begin
        same_flag0 <= (r_admin_Base_time_0 == r_current_time_0) ? 1'b1 : 1'b0;
        same_flag1 <= (r_admin_Base_time_1 == r_current_time_1) ? 1'b1 : 1'b0;
        same_flag2 <= (r_admin_Base_time_2 == r_current_time_2) ? 1'b1 : 1'b0;
        same_flag3 <= (r_admin_Base_time_3 == r_current_time_3) ? 1'b1 : 1'b0;
        same_flag4 <= (r_admin_Base_time_4 == r_current_time_4) ? 1'b1 : 1'b0;
        same_flag5 <= (r_admin_Base_time_5 == r_current_time_5) ? 1'b1 : 1'b0;
        same_flag6 <= (r_admin_Base_time_6 == r_current_time_6) ? 1'b1 : 1'b0;
        same_flag7 <= (r_admin_Base_time_7 == r_current_time_7) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_base_time_err <= 1'b0;
    end else begin
        ro_base_time_err <= (r_Base_time_vld == 1'b1) ? 1'b0 : ( w_copm_flag == 1'b1 ) ? 1'b1 : ro_base_time_err;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_admin_ControlList     <= {PORT_FIFO_PRI_NUM{1'b0}};
        r_admin_ControlList_len <= 8'd0;
        r_admin_cycle_time      <= 16'd0;
        r_admin_qbv_en          <= 1'b0;
        r_ControlList_vld       <= 1'b0;
        r_Base_time_vld         <= 1'b0;
    end else begin  
        r_admin_ControlList     <= (i_ControlList_vld == 1'b1) ? i_ControlList : r_admin_ControlList;
        r_admin_ControlList_len <= (i_ControlList_vld == 1'b1) ? i_ControlList_len : r_admin_ControlList_len;
        r_admin_cycle_time      <= i_cycle_time;
        r_admin_qbv_en          <= i_qbv_en;
        r_ControlList_vld       <= i_ControlList_vld;
        r_Base_time_vld         <= i_Base_time_vld;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_controlList_cnt <= 8'd0;
    end else begin
        r_controlList_cnt <= (r_ControlList_vld == 1'b1 && r_controlList_cnt == r_admin_ControlList_len - 8'd1) ? 8'd0 : 
                             (r_ControlList_vld == 1'b1) ? r_controlList_cnt + 8'd1 : r_controlList_cnt;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_config_soc <= 1'b0;
        r_config_eoc <= 1'b0;
    end else begin
        r_config_soc <= (i_ControlList_vld == 1'b1 && r_ControlList_vld == 1'b0) ? 1'b1 : 1'b0;
        r_config_eoc <= (r_ControlList_vld == 1'b1 && r_controlList_cnt == r_admin_ControlList_len - 8'd1) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_start <= 1'b0;
    end else begin
        r_start <= (i_refresh_list_pulse == 1'b1) ? 1'b0 : (r_config_eoc == 1'b1) ? 1'b1 : r_start;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_control_list_emp_err <= 1'b0;
    end else begin
        ro_control_list_emp_err <= (r_start == 1'b0 && i_Base_time_vld == 1'b1) ? 1'b1: 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_cycle_complete_0  <= 1'b0;
        r_cycle_complete_1  <= 1'b0;
        r0_cycle_complete_0 <= 1'b0;
        r0_cycle_complete_1 <= 1'b0;
    end else begin
        r_cycle_complete_0  <= (r_rd_proc == 1'b1 && r_op_ram_rd ==1'b0 && r_addrb_0 == r0_admin_ControlList_len - 1'b1 && r_ram_rd == 1'b1) ? 1'b1 : 1'b0;
        r_cycle_complete_1  <= (r_rd_proc == 1'b1 && r_op_ram_rd ==1'b1 && r_addrb_1 == r0_admin_ControlList_len - 1'b1 && r_ram_rd == 1'b1) ? 1'b1 : 1'b0;
        r0_cycle_complete_0 <= r_cycle_complete_0;
        r0_cycle_complete_1 <= r_cycle_complete_1;
    end
end



always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r0_admin_ControlList_len <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        r0_admin_ControlList_len <= (r_rd_proc == 1'b0 && r_ControlList_vld == 1'b1) ? r2_admin_ControlList_len :
                                    (r_rd_proc == 1'b1 && r_cycle_complete_0 == 1'b1 && r_ram1_refresh == 1'b1 && r0_same_flag == 1'b1) ? r2_admin_ControlList_len:
                                    (r_rd_proc == 1'b1 && r_cycle_complete_1 == 1'b1 && r_ram0_refresh == 1'b1 && r_same_flag == 1'b1) ? r1_admin_ControlList_len:
                                    r0_admin_ControlList_len;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r1_admin_ControlList_len <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        r1_admin_ControlList_len <= (r_op_ram_wr == 1'b0 && r_ControlList_vld == 1'b1) ? r_admin_ControlList_len : r1_admin_ControlList_len;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r2_admin_ControlList_len <= {PORT_FIFO_PRI_NUM{1'b0}};
    end else begin
        r2_admin_ControlList_len <= (r_op_ram_wr == 1'b1 && r_ControlList_vld == 1'b1) ? r_admin_ControlList_len : r2_admin_ControlList_len;
    end
end

assign w_configpending = r_ram0_refresh | r_ram1_refresh;

// ------ rd_ram_proc -------
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rd_pre_proc <= 1'b0;
    end else begin
        r_rd_pre_proc <= (w_configlist_refresh == 1'b1 || r_config_soc == 1'b1) ? 1'b0 : 
                         (w_configpending == 1'b1 && ro_control_list_emp_err == 1'b0 && ro_base_time_err == 1'b0) ? 1'b1 : r_rd_proc;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_rd_proc <= 1'b0;
    end else begin
        r_rd_proc <= (r_rd_pre_proc == 1'b1 && (w_same_flag == 1'b1 || w_copm_flag == 1'b1)) ? 1'b1 : r_rd_proc;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_ram0_refresh <= 1'b0;
        r_ram1_refresh <= 1'b0;
    end else begin
        r_ram0_refresh <= (r_op_ram_wr == 1'b0 && r_config_eoc == 1'b1) ? 1'b1 :
                          (r_cycle_complete_0 == 1'b1) ? 1'b0 : r_ram0_refresh;
        r_ram1_refresh <= (r_op_ram_wr == 1'b1 && r_config_eoc == 1'b1) ? 1'b1 :
                          (r_cycle_complete_1 == 1'b1) ? 1'b0 : r_ram1_refresh;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_same_flag  <= 1'b0;
        r0_same_flag <= 1'b0;
    end else begin
        r_same_flag  <= ((w_same_flag == 1'b1 || w_copm_flag == 1'b1) && r_ram0_refresh == 1'b1) ? 1'b1 : 
                        (r_cycle_complete_0 == 1'b1) ? 1'b0 : r_same_flag;
        r0_same_flag <= ((w_same_flag == 1'b1 || w_copm_flag == 1'b1) && r_ram1_refresh == 1'b1) ? 1'b1 : 
                        (r_cycle_complete_1 == 1'b1) ? 1'b0 : r0_same_flag;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_op_ram_wr    <=  1'b0; 
        r_op_ram_rd    <=  1'b1;
    end else begin
        r_op_ram_wr    <=  (i_ControlList_vld == 1'b1 && r_ControlList_vld == 1'b0) ? ~r_op_ram_wr : r_op_ram_wr;
        r_op_ram_rd    <=  (r0_cycle_complete_0 == 1'b1 && r_ram1_refresh == 1'b1 && r0_same_flag == 1'b1) ? ~r_op_ram_rd : 
                           (r0_cycle_complete_1 == 1'b1 && r_ram0_refresh == 1'b1 && r_same_flag == 1'b1)  ? ~r_op_ram_rd : 
                           r_op_ram_rd;
    end
end


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_cycle_cnt <= 16'd0;
        r_ram_rd    <= 1'b0;
    end else begin
        r_cycle_cnt <= (r_rd_proc == 1'b1 && (r_cycle_cnt == r_admin_cycle_time - 16'd8)) ? 16'd0 : 
                       (r_rd_proc == 1'b1) ? r_cycle_cnt + 16'd8 : r_cycle_cnt;
        r_ram_rd    <= (r_rd_proc == 1'b1 && (r_cycle_cnt == r_admin_cycle_time - 16'd8)) ? 1'b1 : 1'b0;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_addrb_0 <= 8'd0;
        r_addrb_1 <= 8'd0;
    end else begin
        r_addrb_0 <= (r_rd_proc==1'b1 && r_ram_rd == 1'b1 && r_op_ram_rd == 1'b0 && r_addrb_0 != r0_admin_ControlList_len - 1'b1) ? r_addrb_0 + 8'd1 : 
                     (r_rd_proc==1'b1 && r_ram_rd == 1'b1 && r_op_ram_rd == 1'b0 && r_addrb_0 == r0_admin_ControlList_len - 1'b1) ? 8'd0 : r_addrb_0;
        r_addrb_1 <= (r_rd_proc==1'b1 && r_ram_rd == 1'b1 && r_op_ram_rd == 1'b1 && r_addrb_1 != r0_admin_ControlList_len - 1'b1) ? r_addrb_1 + 8'd1 : 
                     (r_rd_proc==1'b1 && r_ram_rd == 1'b1 && r_op_ram_rd == 1'b1 && r_addrb_1 == r0_admin_ControlList_len - 1'b1) ? 8'd0 : r_addrb_1;
    end 
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_addra_0  <= 8'd0;
        r_addra_1  <= 8'd0;
        r_wea_0    <= 1'b0;
        r_wea_1    <= 1'b0;
        r_din0     <= {(PORT_FIFO_PRI_NUM){1'b0}};
        r_din1     <= {(PORT_FIFO_PRI_NUM){1'b0}};
    end else begin
        r_wea_0    <= (r_op_ram_wr == 1'b0) ? r_ControlList_vld : r_wea_0;
        r_din0     <= (r_op_ram_wr == 1'b0) ? r_admin_ControlList : r_din0;
        r_addra_0  <= (r_op_ram_wr == 1'b0) ? r_controlList_cnt : r_addra_0;
        r_wea_1    <= (r_op_ram_wr == 1'b1) ? r_ControlList_vld : r_wea_1;
        r_din1     <= (r_op_ram_wr == 1'b1) ? r_admin_ControlList : r_din1;
        r_addra_1  <= (r_op_ram_wr == 1'b1) ? r_controlList_cnt : r_addra_1;
    end
end

assign w_ena_0 = (r_rd_proc == 1'b1 && r_op_ram_rd == 1'b0 && r_ram_rd == 1'b1) ? 1'b1 : 1'b0;
assign w_ena_1 = (r_rd_proc == 1'b1 && r_op_ram_rd == 1'b1 && r_ram_rd == 1'b1) ? 1'b1 : 1'b0;
assign w_dout_vld = w_ena_0 | w_ena_1;


always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_dout_vld <= 2'b0;
    end else begin
        r_dout_vld <= {r_dout_vld[0],w_dout_vld};
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        ro_ControlList_state <= {(PORT_FIFO_PRI_NUM){1'b0}};
    end else begin
        ro_ControlList_state <= (r_rd_proc == 1'b1 && r_op_ram_rd == 1'b0 && r_dout_vld[1]) ? w_ram0_dout :
                                (r_rd_proc == 1'b1 && r_op_ram_rd == 1'b1 && r_dout_vld[1]) ? w_ram1_dout : ro_ControlList_state;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if(i_rst) begin
        ro_ControlList_state_vld <= 1'b0;
    end else begin
        ro_ControlList_state_vld <= (r_admin_qbv_en == 1'b1) ? r_dout_vld[1] & rri_queque_vld : ri_queque_vld;
    end
end

assign w_ControlList_state = (r_admin_qbv_en == 1'b1) ? (ro_ControlList_state & rri_queque) : ri_queque;

// ------------
ram_simple2port #(
    .RAM_WIDTH          ( PORT_FIFO_PRI_NUM   ),    // Specify RAM data width
    .RAM_DEPTH          ( 256                 ),    // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE    ( "HIGH_PERFORMANCE"  )     // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
)ram_simple2port_u0(  
    .addra              ( r_addra_0           ),    // Write address bus, width determined from RAM_DEPTH
    .addrb              ( r_addrb_0           ),    // Read address bus, width determined from RAM_DEPTH
    .dina               ( r_din0              ),    // RAM input data
    .clka               ( i_clk               ),    // Write clock
    .clkb               ( i_clk               ),    // Read clock
    .wea                ( r_wea_0             ),    // Write enable
    .enb                ( w_ena_0             ),    // Read Enable, for additional power savings, disable when not in use
    .rstb               ( w_configlist_refresh),    // Output reset (does not affect memory contents)
    .regceb             ( 1'b1                ),    // Output register enable
    .doutb              ( w_ram0_dout         )     // RAM output data
);

ram_simple2port #(
    .RAM_WIDTH          ( PORT_FIFO_PRI_NUM   ),    // Specify RAM data width
    .RAM_DEPTH          ( 256                 ),    // Specify RAM depth (number of entries)
    .RAM_PERFORMANCE    ( "HIGH_PERFORMANCE"  )     // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
)ram_simple2port_u1(  
    .addra              ( r_addra_1           ),    // Write address bus, width determined from RAM_DEPTH
    .addrb              ( r_addrb_1           ),    // Read address bus, width determined from RAM_DEPTH
    .dina               ( r_din1              ),    // RAM input data
    .clka               ( i_clk               ),    // Write clock
    .clkb               ( i_clk               ),    // Read clock
    .wea                ( r_wea_1             ),    // Write enable
    .enb                ( w_ena_1             ),    // Read Enable, for additional power savings, disable when not in use
    .rstb               ( w_configlist_refresh),    // Output reset (does not affect memory contents)
    .regceb             ( 1'b1                ),    // Output register enable
    .doutb              ( w_ram1_dout         )     // RAM output data
);

endmodule