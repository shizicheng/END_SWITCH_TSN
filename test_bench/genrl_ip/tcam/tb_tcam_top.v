`timescale 1ns / 1ps

module tb_tcam_top();

  // 测试参数定义 - 测试144位数据宽度的参数化能力
  parameter                       LOOK_UP_DATA_WIDTH      =      144      ;   // 测试144位：6+6+4+2=18字节
  parameter                       PORT_MNG_DATA_WIDTH     =      8        ;   // Mac_port_mng 数据位宽
  parameter                       REG_ADDR_BUS_WIDTH      =      8        ;   // 接收 MAC 层的配置寄存器地址位宽
  parameter                       REG_DATA_BUS_WIDTH      =      16       ;   // 接收 MAC 层的配置寄存器数据位宽
  parameter                       CAM_NUM                 =      256      ;   // 测试表项深度256个表项
  parameter                       ACTION_WIDTH            =      24       ;   // Action数据位宽
  parameter                       TCAM_DATA_WIDTH         =      LOOK_UP_DATA_WIDTH * 2 ; // TCAM数据宽度：144*2=288位（每位用2位编码）
  parameter                       TCAM_ACTION_WIDTH       =      ACTION_WIDTH * 2       ; // Action TCAM编码宽度：24*2=48位
  parameter                       TOTAL_FRAME_WIDTH       =      TCAM_DATA_WIDTH + TCAM_ACTION_WIDTH ; // 288+48=336位
  parameter                       ACTUAL_DATA_WIDTH       =      144      ;   // 实际有效数据位宽：原始数据位宽

  // 时钟和复位信号
  reg                             tb_clk                  ;
  reg                             tb_rst                  ;

  // DUT输入输出信号
  reg     [LOOK_UP_DATA_WIDTH-1:0]        tb_i_look_up_data               ;
  reg                                     tb_i_look_up_data_vld           ;
  wire    [7:0]                           tb_o_acl_frmtype                ;
  wire    [15:0]                          tb_o_acl_fetchinfo              ;
  wire                                    tb_o_acl_vld                    ;
  wire                                    tb_o_tcam_busy                  ;
  reg                                     tb_i_refresh_list_pulse         ;
  reg                                     tb_i_switch_err_cnt_clr         ;
  reg                                     tb_i_switch_err_cnt_stat        ;
  reg                                     tb_i_switch_reg_bus_we          ;
  reg     [REG_ADDR_BUS_WIDTH-1:0]        tb_i_switch_reg_bus_we_addr     ;
  reg     [REG_DATA_BUS_WIDTH-1:0]        tb_i_switch_reg_bus_we_din      ;
  reg                                     tb_i_switch_reg_bus_we_din_v    ;
  reg                                     tb_i_switch_reg_bus_rd          ;
  reg     [REG_ADDR_BUS_WIDTH-1:0]        tb_i_switch_reg_bus_rd_addr     ;
  wire    [REG_DATA_BUS_WIDTH-1:0]        tb_o_switch_reg_bus_we_dout     ;
  wire                                    tb_o_switch_reg_bus_we_dout_v   ;
  wire                                    w_action_wea                    ;   // Action表写使能信号
  wire    [3:0]                           w_fsm_state                     ;   // CAM管理模块状态机状态

  // 状态机状态定义（与cam_bram_mng.v保持一致）
  parameter WRITE_STATE_IDLE      = 4'b0000;   // 写表状态：空闲
  parameter WRITE_STATE_COLLECT   = 4'b0001;   // 写表状态：收集修改/删除表数据
  parameter WRITE_STATE_ADDR_GEN  = 4'b0010;   // 写表状态：地址生成
  parameter WRITE_STATE_LOOKUP    = 4'b0011;   // 写表状态：查表获取索引（修改/删除表用）
  parameter WRITE_STATE_DELETE_ALL= 4'b0100;   // 写表状态：删除指定索引的所有CAM数据
  parameter WRITE_STATE_READ_ORIG = 4'b0101;   // 写表状态：读取原始数据
  parameter WRITE_STATE_WRITE_PAIR= 4'b0110;   // 写表状态：同时写入高低4bit CAM块对
  parameter WRITE_STATE_NEXT_CNT  = 4'b0111;   // 写表状态：下一个CAM块对
  parameter WRITE_STATE_DONE      = 4'b1000;   // 写表状态：完成

  /// 测试数据定义 - 扩展到8个测试用例
  reg     [47:0]                          test_dst_mac    [0:7]           ; // 目的MAC地址
  reg     [47:0]                          test_src_mac    [0:7]           ; // 源MAC地址
  reg     [31:0]                          test_vlan       [0:7]           ; // VLAN标签
  reg     [15:0]                          test_type_len   [0:7]           ; // 类型/长度字段
  reg     [23:0]                          test_action     [0:7]           ; // Action数据
  reg     [ACTUAL_DATA_WIDTH-1:0]         test_actual_data[0:7]           ; // 实际有效数据(144位)
  reg     [TCAM_DATA_WIDTH-1:0]           test_tcam_data  [0:7]           ; // TCAM编码数据(288位)
  reg     [TOTAL_FRAME_WIDTH-1:0]         test_frame_data [0:7]           ; // 完整的帧数据(288+24=312位)

  // 附加测试数据：未写入的查找数据
  reg     [ACTUAL_DATA_WIDTH-1:0]         test_unknown_data[0:3]          ; // 未写入的测试数据

  // 测试控制变量
  integer                                 i, j, k                         ;
  integer                                 test_pass_cnt                   ;
  integer                                 test_fail_cnt                   ;

  // 时钟生成
  initial
  begin
    tb_clk = 0;
    forever
      #5 tb_clk = ~tb_clk; // 100MHz时钟
  end

  // DUT例化
  tcam_top #(
             .LOOK_UP_DATA_WIDTH             ( LOOK_UP_DATA_WIDTH    ),
             .PORT_MNG_DATA_WIDTH            ( PORT_MNG_DATA_WIDTH   ),
             .REG_ADDR_BUS_WIDTH             ( REG_ADDR_BUS_WIDTH    ),
             .REG_DATA_BUS_WIDTH             ( REG_DATA_BUS_WIDTH    ),
             .CAM_NUM                        ( CAM_NUM               )
           ) dut (
             .i_clk                          ( tb_clk                        ),
             .i_rst                          ( tb_rst                        ),
             .i_look_up_data                 ( tb_i_look_up_data             ),
             .i_look_up_data_vld             ( tb_i_look_up_data_vld         ),
             .o_acl_frmtype                  ( tb_o_acl_frmtype              ),
             .o_acl_fetchinfo                ( tb_o_acl_fetchinfo            ),
             .o_acl_vld                      ( tb_o_acl_vld                  ),
             .o_tcam_busy                    ( tb_o_tcam_busy                ),
             .i_refresh_list_pulse           ( tb_i_refresh_list_pulse       ),
             .i_switch_err_cnt_clr           ( tb_i_switch_err_cnt_clr       ),
             .i_switch_err_cnt_stat          ( tb_i_switch_err_cnt_stat      ),
             .i_switch_reg_bus_we            ( tb_i_switch_reg_bus_we        ),
             .i_switch_reg_bus_we_addr       ( tb_i_switch_reg_bus_we_addr   ),
             .i_switch_reg_bus_we_din        ( tb_i_switch_reg_bus_we_din    ),
             .i_switch_reg_bus_we_din_v      ( tb_i_switch_reg_bus_we_din_v  ),
             .i_switch_reg_bus_rd            ( tb_i_switch_reg_bus_rd        ),
             .i_switch_reg_bus_rd_addr       ( tb_i_switch_reg_bus_rd_addr   ),
             .o_switch_reg_bus_we_dout       ( tb_o_switch_reg_bus_we_dout   ),
             .o_switch_reg_bus_we_dout_v     ( tb_o_switch_reg_bus_we_dout_v ),
             .w_action_wea                   (w_action_wea),
             .o_fsm_state                    (w_fsm_state)
           );

  // 函数：将1位数据编码为TCAM的2位表示
  // 00: 写入0, 01: 写入1, 10: 写入x态(don't care)
  function [1:0] encode_tcam_bit;
    input data_bit;
    input is_dont_care;
    begin
      if (is_dont_care)
      begin
        if (data_bit)
          encode_tcam_bit = 2'b11;  // don't care, 原始数据为1
        else
          encode_tcam_bit = 2'b10;  // don't care, 原始数据为0
      end
      else if (data_bit)
        encode_tcam_bit = 2'b01;  // 精确匹配1
      else
        encode_tcam_bit = 2'b00;  // 精确匹配0
    end
  endfunction

  // 函数：将144位数据编码为288位TCAM数据
  function [TCAM_DATA_WIDTH-1:0] encode_tcam_data;
    input [ACTUAL_DATA_WIDTH-1:0] data;
    input [ACTUAL_DATA_WIDTH-1:0] dont_care_mask;  // 1表示该位为don't care
    integer i;
    begin
      for (i = 0; i < ACTUAL_DATA_WIDTH; i = i + 1)
      begin
        // 保持位序：data[i] 编码到 encode_tcam_data[i*2+1:i*2]
        encode_tcam_data[i*2 +: 2] = encode_tcam_bit(data[i], dont_care_mask[i]);
      end

      // 添加调试输出（仅用于验证）
      $display("    Encoding debug: data[23:16]=%02h, mask[23:16]=%02h",
               data[23:16], dont_care_mask[23:16]);
      $display("    Encoded TCAM[47:32]=%04h", encode_tcam_data[47:32]);
    end
  endfunction

  // 函数：对Action数据进行TCAM编码（无don't care）
  function [TCAM_ACTION_WIDTH-1:0] encode_tcam_action;
    input [ACTION_WIDTH-1:0] action_data;
    integer i;
    begin
      for (i = 0; i < ACTION_WIDTH; i = i + 1)
      begin
        // Action数据都是确定的位，不存在x态
        encode_tcam_action[i*2 +: 2] = encode_tcam_bit(action_data[i], 1'b0);
      end
    end
  endfunction

  // 初始化测试数据
  initial
  begin
    // 测试数据0: 正常以太网帧 - 精确匹配
    test_dst_mac[0]   = 48'h001122334455;  // 目的MAC
    test_src_mac[0]   = 48'h665544332211;  // 源MAC
    test_vlan[0]      = 32'h81000064;      // VLAN标签
    test_type_len[0]  = 16'h0800;          // 类型字段 (IPv4)
    test_action[0]    = 24'h123456;        // Action

    // 测试数据1: 组播帧 - 精确匹配
    test_dst_mac[1]   = 48'h01005E123456;  // 组播MAC
    test_src_mac[1]   = 48'hAABBCCDDEEFF;  // 源MAC
    test_vlan[1]      = 32'h81000100;      // VLAN标签
    test_type_len[1]  = 16'h86DD;          // 类型字段 (IPv6)
    test_action[1]    = 24'h789ABC;        // Action

    // 测试数据2: 广播帧 - 精确匹配
    test_dst_mac[2]   = 48'hFFFFFFFFFFFF;  // 广播MAC
    test_src_mac[2]   = 48'h123456789ABC;  // 源MAC
    test_vlan[2]      = 32'h81000200;      // VLAN标签
    test_type_len[2]  = 16'h0806;          // 类型字段 (ARP)
    test_action[2]    = 24'hDEF012;        // Action

    // 测试数据3: 带有don't care位的表项 - VLAN字段的低8位为don't care
    test_dst_mac[3]   = 48'h112233445566;  // 目的MAC
    test_src_mac[3]   = 48'h778899AABBCC;  // 源MAC
    test_vlan[3]      = 32'h81000300;      // VLAN标签
    test_type_len[3]  = 16'h0800;          // 类型字段
    test_action[3]    = 24'h345678;        // Action

    // 测试数据4: 源MAC部分don't care
    test_dst_mac[4]   = 48'hAABBCCDDEEFF;  // 目的MAC
    test_src_mac[4]   = 48'h000000000000;  // 源MAC (将设为don't care)
    test_vlan[4]      = 32'h81000400;      // VLAN标签
    test_type_len[4]  = 16'h86DD;          // 类型字段
    test_action[4]    = 24'h567890;        // Action

    // 测试数据5: 类型字段don't care
    test_dst_mac[5]   = 48'h223344556677;  // 目的MAC
    test_src_mac[5]   = 48'h889900AABBCC;  // 源MAC
    test_vlan[5]      = 32'h81000500;      // VLAN标签
    test_type_len[5]  = 16'h0000;          // 类型字段 (将设为don't care)
    test_action[5]    = 24'h678901;        // Action

    // 测试数据6: 修改后的数据0 - 将部分0改为don't care
    test_dst_mac[6]   = 48'h001122334455;  // 与数据0相同
    test_src_mac[6]   = 48'h665544332211;  // 与数据0相同
    test_vlan[6]      = 32'h81000064;      // 与数据0相同
    test_type_len[6]  = 16'h0800;          // 与数据0相同
    test_action[6]    = 24'hABCDEF;        // 修改后的Action

    // 测试数据7: 修改后的数据1 - 改变Action
    test_dst_mac[7]   = 48'h01005E123456;  // 与数据1相同
    test_src_mac[7]   = 48'hAABBCCDDEEFF;  // 与数据1相同
    test_vlan[7]      = 32'h81000100;      // 与数据1相同
    test_type_len[7]  = 16'h86DD;          // 与数据1相同
    test_action[7]    = 24'hFEDCBA;        // 修改后的Action

    // 未写入的测试数据
    test_unknown_data[0] = {48'h998877665544, 48'h332211009988, 32'h81000999, 16'h1234};
    test_unknown_data[1] = {48'hDEADBEEFCAFE, 48'hBABEFACEDEAD, 32'h81001000, 16'h5678};
    test_unknown_data[2] = {48'h123456789012, 48'h345678901234, 32'h81002000, 16'h9ABC};
    test_unknown_data[3] = {48'hFEDCBA987654, 48'h321098765432, 32'h81003000, 16'hDEF0};

    // 组装完整的数据
    for (i = 0; i < 8; i = i + 1)
    begin
      // 组装144位的原始数据
      test_actual_data[i] = {test_dst_mac[i], test_src_mac[i], test_vlan[i], test_type_len[i]};

      // 根据测试用例设置don't care掩码并编码TCAM数据
      case (i)
        0, 1, 2:
        begin  // 精确匹配
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {ACTUAL_DATA_WIDTH{1'b0}});
          $display("Test case %0d: 精确匹配", i);
          $display("  Data: %036h", test_actual_data[i]);
          $display("  Mask: %036h", {ACTUAL_DATA_WIDTH{1'b0}});
        end
        3:
        begin  // VLAN低8位don't care (位置：[23:16])
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {{(ACTUAL_DATA_WIDTH-24){1'b0}}, 8'hFF, {16{1'b0}}});
          $display("Test case %0d: VLAN低8位don't care", i);
          $display("  Data: %036h", test_actual_data[i]);
          $display("  Mask: %036h", {{(ACTUAL_DATA_WIDTH-24){1'b0}}, 8'hFF, {16{1'b0}}});
          $display("  Data breakdown: DST=%012h SRC=%012h VLAN=%08h TYPE=%04h",
                   test_dst_mac[i], test_src_mac[i], test_vlan[i], test_type_len[i]);
          $display("  VLAN field position: [47:16], dont care bits: [23:16]");
        end
        4:
        begin  // 源MAC don't care (位置：[95:48])
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {{48{1'b0}}, {48{1'b1}}, {48{1'b0}}});
          $display("Test case %0d: 源MAC don't care", i);
          $display("  Data: %036h", test_actual_data[i]);
          $display("  Mask: %036h", {{48{1'b0}}, {48{1'b1}}, {48{1'b0}}});
          $display("  Source MAC dont care bits: [95:48]");
        end
        5:
        begin  // 类型字段don't care (位置：[15:0])
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {{(ACTUAL_DATA_WIDTH-16){1'b0}}, {16{1'b1}}});
          $display("Test case %0d: 类型字段don't care", i);
          $display("  Data: %036h", test_actual_data[i]);
          $display("  Mask: %036h", {{(ACTUAL_DATA_WIDTH-16){1'b0}}, {16{1'b1}}});
          $display("  Type field dont care bits: [15:0]");
        end
        6:
        begin  // 目的MAC低16位don't care (位置：[143:128])
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {{16{1'b1}}, {(ACTUAL_DATA_WIDTH-16){1'b0}}});
          $display("Test case %0d: 目的MAC低16位don't care", i);
          $display("  Data: %036h", test_actual_data[i]);
          $display("  Mask: %036h", {{16{1'b1}}, {(ACTUAL_DATA_WIDTH-16){1'b0}}});
          $display("  Dest MAC low 16 bits dont care: [143:128]");
        end
        7:
        begin  // 精确匹配 (修改测试)
          test_tcam_data[i] = encode_tcam_data(test_actual_data[i], {ACTUAL_DATA_WIDTH{1'b0}});
          $display("Test case %0d: 精确匹配 (修改测试)", i);
        end
      endcase

      // 组装完整的帧数据：288位TCAM数据 + 24位Action = 312位
      test_frame_data[i] = {test_tcam_data[i], test_action[i]};
    end
  end

  // 任务：等待时钟周期
  task wait_clk;
    input integer cycles;
    begin
      repeat(cycles) @(posedge tb_clk);
    end
  endtask

  // 任务：复位DUT
  task reset_dut;
    begin
      tb_rst = 1;
      tb_i_look_up_data_vld = 0;
      tb_i_refresh_list_pulse = 0;
      tb_i_switch_err_cnt_clr = 0;
      tb_i_switch_err_cnt_stat = 0;
      tb_i_switch_reg_bus_we = 0;
      tb_i_switch_reg_bus_we_addr = 0;
      tb_i_switch_reg_bus_we_din = 0;
      tb_i_switch_reg_bus_we_din_v = 0;
      tb_i_switch_reg_bus_rd = 0;
      tb_i_switch_reg_bus_rd_addr = 0;
      tb_i_look_up_data = 0;
      wait_clk(10);
      tb_rst = 0;
      wait_clk(5);
      $display("[%0t] Reset completed", $time);
    end
  endtask

  // 任务：等待Action写使能信号和状态机回到IDLE
  task wait_for_action_write;
    input [2:0] cmd_type;
    integer timeout_cnt;
    begin
      // 只对修改表和删除表操作等待w_action_wea信号和状态机回到IDLE
      if (cmd_type == 2'b01 || cmd_type == 2'b10)
      begin
        $display("[%0t] Waiting for operation completion (cmd_type=%0d)...", $time, cmd_type);

        // 第一步：等待w_action_wea信号拉高，表示Action表操作开始
        timeout_cnt = 0;
        while (!w_action_wea && timeout_cnt < 10000)
        begin
          wait_clk(1);
          timeout_cnt = timeout_cnt + 1;
        end

        if (timeout_cnt >= 10000)
        begin
          $display("[%0t] WARNING: Timeout waiting for w_action_wea signal!", $time);
        end
        else if (w_action_wea)
        begin
          $display("[%0t] ✓ w_action_wea signal detected - Action operation in progress", $time);

          // 等待w_action_wea信号拉低
          while (w_action_wea)
          begin
            wait_clk(1);
          end
          $display("[%0t] ✓ w_action_wea signal deasserted", $time);
        end

        // 第二步：等待状态机回到WRITE_STATE_IDLE状态
        $display("[%0t] Waiting for FSM to return to IDLE state...", $time);
        timeout_cnt = 0;
        while (w_fsm_state != WRITE_STATE_IDLE && timeout_cnt < 15000)
        begin
          wait_clk(1);
          timeout_cnt = timeout_cnt + 1;
          if (timeout_cnt % 1000 == 0)
          begin
            $write("[%0t] FSM state: ", $time);
            print_fsm_state(w_fsm_state);
            $write(" (waiting for IDLE)\n");
          end
        end

        if (timeout_cnt >= 15000)
        begin
          $write("[%0t] WARNING: Timeout waiting for FSM to return to IDLE! Current state: ", $time);
          print_fsm_state(w_fsm_state);
          $write("\n");
        end
        else
        begin
          $display("[%0t] ✓ FSM returned to IDLE state - Operation fully completed", $time);
        end

        // 额外等待确保系统稳定
        wait_clk(50);
      end
      else
      begin
        $display("[%0t] Write operation (cmd_type=%0d) - no need to wait for w_action_wea", $time, cmd_type);
      end
    end
  endtask

  // 任务：打印状态机状态名称
  task print_fsm_state;
    input [3:0] state;
    begin
      case (state)
        WRITE_STATE_IDLE:
          $write("IDLE");
        WRITE_STATE_COLLECT:
          $write("COLLECT");
        WRITE_STATE_ADDR_GEN:
          $write("ADDR_GEN");
        WRITE_STATE_LOOKUP:
          $write("LOOKUP");
        WRITE_STATE_DELETE_ALL:
          $write("DELETE_ALL");
        WRITE_STATE_READ_ORIG:
          $write("READ_ORIG");
        WRITE_STATE_WRITE_PAIR:
          $write("WRITE_PAIR");
        WRITE_STATE_NEXT_CNT:
          $write("NEXT_CNT");
        WRITE_STATE_DONE:
          $write("DONE");
        default:
          $write("UNKNOWN(%04b)", state);
      endcase
    end
  endtask

  // 任务：通过寄存器总线写入一帧数据（需要对原始数据进行TCAM编码）
  task write_frame_via_reg;
    input [2:0] cmd_type;  // 00-写表，01-改表，10-删除表
    input [ACTUAL_DATA_WIDTH-1:0] raw_data;  // 原始144位数据
    input [ACTUAL_DATA_WIDTH-1:0] dont_care_mask;  // don't care掩码，1表示该位为x态
    input [ACTION_WIDTH-1:0] action_data;  // 24位Action数据
    integer byte_cnt;
    reg [15:0] reg_data;
    integer total_words;
    reg [TCAM_DATA_WIDTH-1:0] encoded_tcam_data;  // 编码后的288位TCAM数据
    reg [TCAM_ACTION_WIDTH-1:0] encoded_action_data;  // 编码后的48位Action数据
    reg [TOTAL_FRAME_WIDTH-1:0] complete_frame_data;  // 完整的336位帧数据
    begin
      $display("[%0t] Starting frame write via register, cmd_type=%0d", $time, cmd_type);
      $display("  Raw data (%0d bits): %036h", ACTUAL_DATA_WIDTH, raw_data);
      $display("  Don't care mask: %036h", dont_care_mask);
      $display("  Action data: %06h", action_data);

      // 对原始数据进行TCAM编码：每位用2位表示 (00=0, 01=1, 10=x)
      encoded_tcam_data = encode_tcam_data(raw_data, dont_care_mask);

      // 对Action数据进行TCAM编码：每位用2位表示 (00=0, 01=1，无x态)
      encoded_action_data = encode_tcam_action(action_data);

      // 组装完整的帧数据：288位TCAM数据 + 48位Action = 336位
      complete_frame_data = {encoded_tcam_data, encoded_action_data};

      $display("  Encoded TCAM data (%0d bits): %072h", TCAM_DATA_WIDTH, encoded_tcam_data);
      $display("  Encoded Action data (%0d bits): %012h", TCAM_ACTION_WIDTH, encoded_action_data);
      $display("  Complete frame (%0d bits): %084h", TOTAL_FRAME_WIDTH, complete_frame_data);

      // 计算需要传输的16位字数：336位需要21个16位字
      total_words = (TOTAL_FRAME_WIDTH + 15) / 16;  // 向上取整 = 21个字

      // 等待模块不忙
      while (tb_o_tcam_busy)
      begin
        wait_clk(1);
      end

      // 按16位数据块依次传输整个帧数据
      // 寄存器地址固定：只使用命令类型，不累加索引
      // 00: 写表, 01: 改表, 10: 删除表
      for (byte_cnt = 0; byte_cnt < total_words; byte_cnt = byte_cnt + 1)
      begin
        // 每次写入前检查busy信号，如果为高则等待
        while (tb_o_tcam_busy)
        begin
          $display("[%0t] TCAM is busy, waiting before writing word %0d/%0d", $time, byte_cnt+1, total_words);
          wait_clk(1);
        end

        // 再次确认busy信号为低后才开始写入
        if (tb_o_tcam_busy)
        begin
          $display("[%0t] WARNING: TCAM became busy just before writing word %0d", $time, byte_cnt+1);
          while (tb_o_tcam_busy)
          begin
            wait_clk(1);
          end
        end

        // 寄存器地址固定为命令类型，不使用数据索引
        tb_i_switch_reg_bus_we_addr = {cmd_type[1:0], 6'h00};  // 高2位命令类型，低6位全0

        // 提取16位数据（从高位开始）
        if ((byte_cnt + 1) * 16 <= TOTAL_FRAME_WIDTH)
        begin
          // 完整的16位数据
          reg_data = complete_frame_data[TOTAL_FRAME_WIDTH-1-byte_cnt*16 -: 16];
        end
        else
        begin
          // 最后不完整的数据：只有8位有效数据 (312位的最后8位)
          reg_data = {complete_frame_data[7:0], 8'h00};  // 最低8位 + 高位补0
        end

        tb_i_switch_reg_bus_we_din = reg_data;
        tb_i_switch_reg_bus_we = 1;
        tb_i_switch_reg_bus_we_din_v = 1;

        $display("[%0t] Writing reg[%02h] = %04h (word %0d/%0d) [busy=%b]",
                 $time, tb_i_switch_reg_bus_we_addr, reg_data, byte_cnt+1, total_words, tb_o_tcam_busy);

        wait_clk(1);

        // 写入后检查busy信号状态
        if (tb_o_tcam_busy)
        begin
          $display("[%0t] TCAM became busy after writing word %0d", $time, byte_cnt+1);
        end

        tb_i_switch_reg_bus_we = 0;
        tb_i_switch_reg_bus_we_din_v = 0;
      end

      // 等待处理完成
      wait_clk(100);
      while (tb_o_tcam_busy)
      begin
        wait_clk(1);
      end

      //   // 等待Action表更新完成（仅对修改表和删除表操作）
      //   wait_for_action_write(cmd_type);

      $display("[%0t] Frame write completed", $time);
    end
  endtask

  // 任务：执行查表操作
  task lookup_table;
    input [LOOK_UP_DATA_WIDTH-1:0] lookup_data;
    input [23:0] expected_action;
    input expect_miss;  // 1表示期望查找失败，0表示期望查找成功
    begin
      $display("[%0t] Starting table lookup", $time);
      $display("  Lookup data: %036h", lookup_data);
      if (expect_miss)
        $display("  Expected: MISS (no match)");
      else
        $display("  Expected action: %06h", expected_action);
      while (w_fsm_state != 'd0)
      begin
        wait_clk(1);
      end
      // 发送查找数据
      tb_i_look_up_data = lookup_data;
      tb_i_look_up_data_vld = 1;

      wait_clk(1);
      tb_i_look_up_data_vld = 0;

      // 等待查找结果
      wait_clk(10); // 给一些时间让查找完成

      // 检查结果
      if (expect_miss)
      begin
        if (!tb_o_acl_vld)
        begin
          $display("[%0t] ✓ Lookup PASSED: Expected miss, got miss", $time);
          test_pass_cnt = test_pass_cnt + 1;
        end
        else
        begin
          $display("[%0t] ✗ Lookup FAILED: Expected miss, got hit with action %06h", $time, {tb_o_acl_fetchinfo, tb_o_acl_frmtype});
          test_fail_cnt = test_fail_cnt + 1;
        end
      end
      else
      begin
        if (tb_o_acl_vld)
        begin
          if ({tb_o_acl_fetchinfo, tb_o_acl_frmtype} == expected_action)
          begin
            $display("[%0t] ✓ Lookup PASSED: Got expected action %06h", $time, {tb_o_acl_fetchinfo, tb_o_acl_frmtype});
            test_pass_cnt = test_pass_cnt + 1;
          end
          else
          begin
            $display("[%0t] ✗ Lookup FAILED: Expected %06h, Got %06h", $time, expected_action, {tb_o_acl_fetchinfo, tb_o_acl_frmtype});
            test_fail_cnt = test_fail_cnt + 1;
          end
        end
        else
        begin
          $display("[%0t] ✗ Lookup FAILED: Expected hit with action %06h, got miss", $time, expected_action);
          test_fail_cnt = test_fail_cnt + 1;
        end
      end

      wait_clk(5);
    end
  endtask

  // 主测试流程
  initial
  begin
    $display("===========================================");
    $display("    TCAM TOP MODULE TEST BENCH START");
    $display("    TCAM 3-State Encoding Test (2bit per bit)");
    $display("===========================================");

    test_pass_cnt = 0;
    test_fail_cnt = 0;

    // 1. 复位系统
    reset_dut();

    // 2. 测试写入多个表项操作
    $display("\n--- 测试1: 写入多个表项 ---");
    // 写入8个表项（索引0-7）
    for (i = 0; i < 8; i = i + 1)
    begin
      $display("\n写入表项 %0d:", i);
      case (i)
        0, 1, 2:
        begin  // 精确匹配
          write_frame_via_reg(2'b00, test_actual_data[i], {{ACTUAL_DATA_WIDTH{1'b0}}}, test_action[i]);
        end
        3:
        begin  // VLAN低8位don't care (位置：[23:16])
          write_frame_via_reg(2'b00, test_actual_data[i], {{(ACTUAL_DATA_WIDTH-24){1'b0}}, 8'hFF, {16{1'b0}}}, test_action[i]);
        end
        4:
        begin  // 源MAC don't care (位置：[95:48])
          write_frame_via_reg(2'b00, test_actual_data[i], {{48{1'b0}}, {48{1'b1}}, {48{1'b0}}}, test_action[i]);
        end
        5:
        begin  // 类型字段don't care (位置：[15:0])
          write_frame_via_reg(2'b00, test_actual_data[i], {{(ACTUAL_DATA_WIDTH-16){1'b0}}, {16{1'b1}}}, test_action[i]);
        end
        // 6: begin  // 目的MAC低16位don't care (位置：[143:128])
        //     write_frame_via_reg(2'b00, test_actual_data[i], {{16{1'b1}}, {(ACTUAL_DATA_WIDTH-16){1'b0}}}, test_action[i]);
        // end
        // 7: begin  // 精确匹配 (修改测试)
        //     write_frame_via_reg(2'b00, test_actual_data[i], {ACTUAL_DATA_WIDTH{1'b0}}, test_action[i]);
        // end
      endcase

    end

    // 等待所有表项写入完成并确保系统稳定
    $display("\n--- 等待所有表项写入完成 ---");
    wait_clk(280); // 额外的等待时间
    while (tb_o_tcam_busy)
    begin
      $display("[%0t] 等待TCAM busy信号变为低电平...", $time);
      wait_clk(10);
    end
    wait_clk(50); // 确保系统完全稳定
    $display("[%0t] 所有表项写入完成，系统稳定，开始查表测试", $time);

    // 3. 测试乱序查表操作（包括精确匹配和模糊匹配）
    $display("\n--- 测试2: 乱序查表操作 ---");    // 乱序查找已写入的表项
    $display("\n查找表项 2 (广播帧):");
    lookup_table(test_actual_data[2], test_action[2], 0);

    $display("\n查找表项 0 (正常帧):");
    lookup_table(test_actual_data[0], test_action[0], 0);

    $display("\n查找表项 4 (源MAC don't care) - 用原始数据:");
    lookup_table(test_actual_data[4], test_action[4], 0);

    $display("\n查找表项 4 (源MAC don't care) - 用不同源MAC:");
    lookup_table({test_dst_mac[4], 48'h123456789ABC, test_vlan[4], test_type_len[4]}, test_action[4], 0);

    $display("\n查找表项 3 (VLAN低8位don't care) - 用原始数据:");
    lookup_table(test_actual_data[3], test_action[3], 0);

    $display("\n查找表项 3 (VLAN低8位don't care) - 用不同VLAN低位:");
    lookup_table({test_dst_mac[3], test_src_mac[3], 32'h810003AA, test_type_len[3]}, test_action[3], 0);

    $display("\n查找表项 1 (组播帧):");
    lookup_table(test_actual_data[1], test_action[1], 0);

    $display("\n查找表项 5 (类型don't care) - 用原始数据:");
    lookup_table(test_actual_data[5], test_action[5], 0);

    $display("\n查找表项 5 (类型don't care) - 用不同类型:");
    lookup_table({test_dst_mac[5], test_src_mac[5], test_vlan[5], 16'hABCD}, test_action[5], 0);

    // 4. 测试未写入数据的查表（应该失败）
    $display("\n--- 测试3: 查找未写入的数据 ---");
    for (i = 0; i < 4; i = i + 1)
    begin
      $display("\n查找未写入数据 %0d:", i);
      lookup_table(test_unknown_data[i], 24'h0, 1); // 期望查找失败
    end

    // 5. 测试改表操作（将0态改为don't care或1态改为don't care）
    $display("\n--- 测试4: 改表操作 ---");
    lookup_table(test_actual_data[2], test_action[2], 0);
    $display("\n修改表项0 - 将目的MAC低16位改为don't care:");
    write_frame_via_reg(2'b01, test_actual_data[1], {{16{1'b1}}, {(ACTUAL_DATA_WIDTH-16){1'b0}}}, test_action[6]); // 改表命令

    // 验证修改后的模糊匹配
    $display("\n验证修改后的表项0 - 用原始数据:");
    lookup_table(test_actual_data[1], test_action[6], 0);

    $display("\n验证修改后的表项0 - 用不同的目的MAC低位:");
    lookup_table({48'h01115E123456, test_src_mac[1], test_vlan[1], test_type_len[1]}, test_action[6], 0);
    lookup_table(test_actual_data[2], test_action[2], 0);
    $display("\n修改表项1的action:");
    write_frame_via_reg(2'b01, test_actual_data[2], {ACTUAL_DATA_WIDTH{1'b0}}, test_action[7]); // 改表命令，精确匹配但改变action

    $display("\n验证修改后的表项1:");
    lookup_table(test_actual_data[2], test_action[7], 0);

    // 6. 测试删除表项操作
    $display("\n--- 测试5: 删除表项 ---");
    $display("\n删除表项2 (广播帧):");
    write_frame_via_reg(2'b10, test_actual_data[2], {ACTUAL_DATA_WIDTH{1'b0}}, 24'h0); // 删除命令

    // 验证删除结果（应该查找不到）
    $display("\n验证删除后的表项2:");
    lookup_table(test_actual_data[2], 24'h0, 1); // 期望查找失败

    $display("\n删除表项4 (源MAC don't care):");
    write_frame_via_reg(2'b10, test_actual_data[4], {{48{1'b0}}, {48{1'b1}}, {48{1'b0}}}, 24'h0); // 删除命令

    $display("\n验证删除后的表项4:");
    lookup_table(test_actual_data[4], 24'h0, 1); // 期望查找失败

    // 7. 验证其他表项未受影响
    $display("\n--- 测试6: 验证其他表项未受影响 ---");

    $display("\n验证表项0 (修改后的don't care版本):");
    lookup_table(test_actual_data[0], test_action[6], 0);

    $display("\n验证表项1 (修改后的action):");
    lookup_table(test_actual_data[1], test_action[7], 0);

    $display("\n验证表项3 (VLAN don't care):");
    lookup_table(test_actual_data[3], test_action[3], 0);

    $display("\n验证表项5 (类型don't care):");
    lookup_table(test_actual_data[5], test_action[5], 0);

  end

  // 监控信号变化
  initial
  begin
    $monitor("[%0t] busy=%b, acl_vld=%b, acl_action=%06h, fsm_state=%04b",
             $time, tb_o_tcam_busy, tb_o_acl_vld, {tb_o_acl_fetchinfo, tb_o_acl_frmtype}, w_fsm_state);
  end

  // 专门监控状态机变化
  reg [3:0] prev_fsm_state;
  initial
    prev_fsm_state = WRITE_STATE_IDLE;

  always @(w_fsm_state)
  begin
    if (w_fsm_state != prev_fsm_state)
    begin
      $write("[%0t] FSM state change: ", $time);
      print_fsm_state(prev_fsm_state);
      $write(" -> ");
      print_fsm_state(w_fsm_state);
      $write("\n");
      prev_fsm_state = w_fsm_state;
    end
  end

endmodule
