`timescale 1ns / 1ps

module tb_tsn_cb();

/*========================================== 参数定义 ==========================================*/
parameter                                   CLK_PERIOD              = 4         ; // 250MHz时钟周期
parameter                                   PORT_NUM                = 8         ; // 端口数量
parameter                                   RECOVERY_MODE           = 0         ; // 0:向量恢复 1:匹配恢复

/*========================================== 信号声明 ==========================================*/
// 时钟和复位
reg                                         clk                                 ;
reg                                         rst                                 ;

// 输入信号 - 8个MAC通道
reg                                         i_rtag_flag0                        ;
reg    [15:0]                               i_rtag_sequence0                    ;
reg    [7:0]                                i_stream_handle0                    ;

reg                                         i_rtag_flag1                        ;
reg    [15:0]                               i_rtag_sequence1                    ;
reg    [7:0]                                i_stream_handle1                    ;

reg                                         i_rtag_flag2                        ;
reg    [15:0]                               i_rtag_sequence2                    ;
reg    [7:0]                                i_stream_handle2                    ;

reg                                         i_rtag_flag3                        ;
reg    [15:0]                               i_rtag_sequence3                    ;
reg    [7:0]                                i_stream_handle3                    ;

reg                                         i_rtag_flag4                        ;
reg    [15:0]                               i_rtag_sequence4                    ;
reg    [7:0]                                i_stream_handle4                    ;

reg                                         i_rtag_flag5                        ;
reg    [15:0]                               i_rtag_sequence5                    ;
reg    [7:0]                                i_stream_handle5                    ;

reg                                         i_rtag_flag6                        ;
reg    [15:0]                               i_rtag_sequence6                    ;
reg    [7:0]                                i_stream_handle6                    ;

reg                                         i_rtag_flag7                        ;
reg    [15:0]                               i_rtag_sequence7                    ;
reg    [7:0]                                i_stream_handle7                    ;

// 输出信号
wire   [PORT_NUM-1:0]                       o_pass_en                           ;
wire   [PORT_NUM-1:0]                       o_discard_en                        ;
wire   [PORT_NUM-1:0]                       o_judge_finish                      ;

// 测试控制
integer                                     test_case_num                       ;
integer                                     pass_count                          ;
integer                                     fail_count                          ;
integer                                     i                                   ;

/*========================================== 时钟和复位生成 ==========================================*/
// 时钟生成 - 250MHz
initial begin
    clk = 1'b0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// 复位生成
initial begin
    rst = 1'b1;
    #(CLK_PERIOD*10);
    rst = 1'b0;
    $display("[%0t] Reset released, simulation start", $time);
end

/*========================================== DUT例化 ==========================================*/
tsn_cb_top #(
    .RECOVERY_MODE      (RECOVERY_MODE      ),
    .PORT_NUM           (PORT_NUM           )
) u_dut (
    .i_clk              (clk                ),
    .i_rst              (rst                ),
    
    .i_rtag_flag0       (i_rtag_flag0       ),
    .i_rtag_squence0    (i_rtag_sequence0   ),
    .i_stream_handle0   (i_stream_handle0   ),
    
    .i_rtag_flag1       (i_rtag_flag1       ),
    .i_rtag_squence1    (i_rtag_sequence1   ),
    .i_stream_handle1   (i_stream_handle1   ),
    
    .i_rtag_flag2       (i_rtag_flag2       ),
    .i_rtag_squence2    (i_rtag_sequence2   ),
    .i_stream_handle2   (i_stream_handle2   ),
    
    .i_rtag_flag3       (i_rtag_flag3       ),
    .i_rtag_squence3    (i_rtag_sequence3   ),
    .i_stream_handle3   (i_stream_handle3   ),
    
    .i_rtag_flag4       (i_rtag_flag4       ),
    .i_rtag_squence4    (i_rtag_sequence4   ),
    .i_stream_handle4   (i_stream_handle4   ),
    
    .i_rtag_flag5       (i_rtag_flag5       ),
    .i_rtag_squence5    (i_rtag_sequence5   ),
    .i_stream_handle5   (i_stream_handle5   ),
    
    .i_rtag_flag6       (i_rtag_flag6       ),
    .i_rtag_squence6    (i_rtag_sequence6   ),
    .i_stream_handle6   (i_stream_handle6   ),
    
    .i_rtag_flag7       (i_rtag_flag7       ),
    .i_rtag_squence7    (i_rtag_sequence7   ),
    .i_stream_handle7   (i_stream_handle7   ),
    
    .o_pass_en          (o_pass_en          ),
    .o_discard_en       (o_discard_en       ),
    .o_judge_finish     (o_judge_finish     )
);

/*========================================== 初始化任务 ==========================================*/
task init_all_inputs;
begin
    i_rtag_flag0 = 1'b0;
    i_rtag_sequence0 = 16'h0;
    i_stream_handle0 = 8'h0;
    
    i_rtag_flag1 = 1'b0;
    i_rtag_sequence1 = 16'h0;
    i_stream_handle1 = 8'h0;
    
    i_rtag_flag2 = 1'b0;
    i_rtag_sequence2 = 16'h0;
    i_stream_handle2 = 8'h0;
    
    i_rtag_flag3 = 1'b0;
    i_rtag_sequence3 = 16'h0;
    i_stream_handle3 = 8'h0;
    
    i_rtag_flag4 = 1'b0;
    i_rtag_sequence4 = 16'h0;
    i_stream_handle4 = 8'h0;
    
    i_rtag_flag5 = 1'b0;
    i_rtag_sequence5 = 16'h0;
    i_stream_handle5 = 8'h0;
    
    i_rtag_flag6 = 1'b0;
    i_rtag_sequence6 = 16'h0;
    i_stream_handle6 = 8'h0;
    
    i_rtag_flag7 = 1'b0;
    i_rtag_sequence7 = 16'h0;
    i_stream_handle7 = 8'h0;
end
endtask

/*========================================== 发送数据包任务 ==========================================*/
// 向指定通道发送单个数据包
task send_packet;
input [2:0]     channel;        // 通道号 0-7
input [7:0]     stream_handle;  // 流标识
input [15:0]    sequence;       // 序列号
input [31:0]    hold_cycles;    // 保持周期数
begin
    case(channel)
        3'd0: begin
            i_rtag_flag0 = 1'b1;
            i_rtag_sequence0 = sequence;
            i_stream_handle0 = stream_handle;@(posedge clk);i_rtag_flag0 = 1'b0;
            $display("[%0t] CH0: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd1: begin
            i_rtag_flag1 = 1'b1;
            i_rtag_sequence1 = sequence;
            i_stream_handle1 = stream_handle;@(posedge clk);i_rtag_flag1 = 1'b0;
            $display("[%0t] CH1: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd2: begin
            i_rtag_flag2 = 1'b1;
            i_rtag_sequence2 = sequence;
            i_stream_handle2 = stream_handle;@(posedge clk);i_rtag_flag2 = 1'b0;
            $display("[%0t] CH2: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd3: begin
            i_rtag_flag3 = 1'b1;
            i_rtag_sequence3 = sequence;
            i_stream_handle3 = stream_handle;@(posedge clk);i_rtag_flag3 = 1'b0;
            $display("[%0t] CH3: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd4: begin
            i_rtag_flag4 = 1'b1;
            i_rtag_sequence4 = sequence;
            i_stream_handle4 = stream_handle;@(posedge clk);i_rtag_flag4 = 1'b0;
            $display("[%0t] CH4: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd5: begin
            i_rtag_flag5 = 1'b1;
            i_rtag_sequence5 = sequence;
            i_stream_handle5 = stream_handle;@(posedge clk);i_rtag_flag5 = 1'b0;
            $display("[%0t] CH5: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd6: begin
            i_rtag_flag6 = 1'b1;
            i_rtag_sequence6 = sequence;
            i_stream_handle6 = stream_handle;@(posedge clk);i_rtag_flag6 = 1'b0;
            $display("[%0t] CH6: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
        3'd7: begin
            i_rtag_flag7 = 1'b1;
            i_rtag_sequence7 = sequence;
            i_stream_handle7 = stream_handle;@(posedge clk);i_rtag_flag7 = 1'b0;
            $display("[%0t] CH7: Send pkt - stream=%0d, seq=%0d", $time, stream_handle, sequence);
        end
    endcase
    
    // // 保持指定周期后清除flag
    // repeat(hold_cycles) @(posedge clk);
    
    // case(channel)
    //     3'd0: i_rtag_flag0 = 1'b0;
    //     3'd1: i_rtag_flag1 = 1'b0;
    //     3'd2: i_rtag_flag2 = 1'b0;
    //     3'd3: i_rtag_flag3 = 1'b0;
    //     3'd4: i_rtag_flag4 = 1'b0;
    //     3'd5: i_rtag_flag5 = 1'b0;
    //     3'd6: i_rtag_flag6 = 1'b0;
    //     3'd7: i_rtag_flag7 = 1'b0;
    // endcase
end
endtask

// 等待判断完成并检查结果
task wait_and_check;
input [2:0]     channel;        // 期望的通道号
input           expected_pass;  // 期望通过
input           expected_discard; // 期望丢弃
begin
    // 等待judge_finish信号
    wait(o_judge_finish[channel] == 1'b1);
    @(posedge clk);
    
    // 检查结果
    if(o_pass_en[channel] == expected_pass && o_discard_en[channel] == expected_discard) begin
        $display("[%0t] ✓ PASS - CH%0d: pass=%0b, discard=%0b (Expected)", 
                 $time, channel, o_pass_en[channel], o_discard_en[channel]);
        pass_count = pass_count + 1;
    end else begin
        $display("[%0t] ✗ FAIL - CH%0d: pass=%0b, discard=%0b (Expected pass=%0b, discard=%0b)", 
                 $time, channel, o_pass_en[channel], o_discard_en[channel], expected_pass, expected_discard);
        fail_count = fail_count + 1;
    end
    
    // 等待judge_finish清除
    wait(o_judge_finish[channel] == 1'b0);
    @(posedge clk);
end
endtask

/*========================================== 测试用例 ==========================================*/
initial begin
    test_case_num = 0;
    pass_count = 0;
    fail_count = 0;
    
    // 初始化所有输入
    init_all_inputs();
    
    // 等待复位释放
    wait(rst == 1'b0);
    repeat(10) @(posedge clk);
    
    $display("\n========================================");
    $display("    TSN CB Test Cases Start");
    $display("========================================\n");
    
    
    /*========== 测试用例1: 单通道顺序包测试 ==========*/
    test_case_num = 1;
    $display("\n[TEST CASE %0d] Single channel sequential packets", test_case_num);
    $display("Description: Send sequential packets on CH0, all should pass");
    
    // TakeAny状态，第一个包
    send_packet(3'd0, 8'd16, 16'd5, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    // 正序包
    send_packet(3'd0, 8'd16, 16'd6, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd16, 16'd7, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例2: 重复包检测 ==========*/
    test_case_num = 2;
    $display("\n[TEST CASE %0d] Duplicate packet detection", test_case_num);
    $display("Description: Send duplicate packet, should be discarded");
    
    // 发送重复序列号
    send_packet(3'd0, 8'd16, 16'd7, 1);
    wait_and_check(3'd0, 1'b0, 1'b1); // 应该丢弃
    repeat(5) @(posedge clk);
    
    // 继续正常序列
    send_packet(3'd0, 8'd16, 16'd8, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例3: 乱序包测试（超前） ==========*/
    test_case_num = 3;
    $display("\n[TEST CASE %0d] Out-of-order packet (advance)", test_case_num);
    $display("Description: Send packet with sequence jump");
    
    // 跳过2个序列号
    send_packet(3'd0, 8'd16, 16'd11, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过（乱序但在范围内）
    repeat(5) @(posedge clk);
    
    // 发送跳过的序列号（滞后）
    send_packet(3'd0, 8'd16, 16'd9, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过（滞后但在历史范围内）
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd16, 16'd10, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例4: 异常包检测（超出范围） ==========*/
    test_case_num = 4;
    $display("\n[TEST CASE %0d] Rogue packet detection", test_case_num);
    $display("Description: Send packet far beyond history range");
    
    // 发送超出历史范围的序列号（rogue包）
    send_packet(3'd0, 8'd16, 16'd50, 1);
    wait_and_check(3'd0, 1'b0, 1'b1); // 应该丢弃
    repeat(5) @(posedge clk);
    
    // 继续正常序列
    send_packet(3'd0, 8'd16, 16'd12, 1);
    wait_and_check(3'd0, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例5: 多通道相同流测试 ==========*/
    test_case_num = 5;
    $display("\n[TEST CASE %0d] Multi-channel same stream", test_case_num);
    $display("Description: Send same stream from different channels");
    
    // CH1和CH2同时发送相同流的不同序列号
    fork
        begin
            send_packet(3'd1, 8'd14, 16'd20, 1);
            wait_and_check(3'd1, 1'b1, 1'b0); // 第一个到达，应该通过
        end
        begin
            repeat(3) @(posedge clk);
            send_packet(3'd2, 8'd14, 16'd20, 1);
            wait_and_check(3'd2, 1'b0, 1'b1); // 重复包，应该丢弃
        end
    join
    repeat(10) @(posedge clk);
    
    // 从CH1继续发送
    send_packet(3'd1, 8'd14, 16'd21, 1);
    wait_and_check(3'd1, 1'b1, 1'b0); // 应该通过
    repeat(5) @(posedge clk);
    
    // 从CH2发送相同的序列号
    send_packet(3'd2, 8'd14, 16'd21, 1);
    wait_and_check(3'd2, 1'b0, 1'b1); // 重复包，应该丢弃
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例6: 多通道不同流测试 ==========*/
    test_case_num = 6;
    $display("\n[TEST CASE %0d] Multi-channel different streams", test_case_num);
    $display("Description: Send different streams from different channels");
    
    // 并行发送不同流
    fork
        begin
            send_packet(3'd3, 8'd10, 16'd1, 1);
            send_packet(3'd4, 8'd11, 16'd1, 1);
            send_packet(3'd5, 8'd12, 16'd1, 1);
            @(posedge clk);
            wait_and_check(3'd3, 1'b1, 1'b0);
        end
        begin
            
            
            repeat(2) @(posedge clk);
            wait_and_check(3'd4, 1'b1, 1'b0);
        end
        begin
            repeat(3) @(posedge clk);
            wait_and_check(3'd5, 1'b1, 1'b0);
        end
    join
    repeat(10) @(posedge clk);
    
    
    /*========== 测试用例7: 快速连续包测试 ==========*/
    // test_case_num = 7;
    // $display("\n[TEST CASE %0d] Rapid sequential packets", test_case_num);
    // $display("Description: Send packets back-to-back");
    
    // // for(i = 0; i < 5; i = i + 1) begin
    // //     send_packet(3'd6, 8'd13, 16'd10 + i, 1);

    // //     wait_and_check(3'd6, 1'b1, 1'b0);
    
    // // end
    
    // send_packet(3'd6, 8'd13, 16'd10, 1);
    // send_packet(3'd6, 8'd13, 16'd11, 1);
    // send_packet(3'd6, 8'd13, 16'd12, 1);
    // send_packet(3'd6, 8'd13, 16'd13, 1);
    // send_packet(3'd6, 8'd13, 16'd14, 1);
    // send_packet(3'd6, 8'd13, 16'd15, 1);
    // repeat(10) @(posedge clk);
    
    
    /*========== 测试用例8: 间隔递增序列号测试 ==========*/
    test_case_num = 8;
    $display("\n[TEST CASE %0d] Increment with gaps", test_case_num);
    $display("Description: Sequence numbers with varying gaps");
    
    // +1, +2, +3递增
    send_packet(3'd7, 8'd19, 16'd100, 1);
    wait_and_check(3'd7, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd7, 8'd19, 16'd101, 1); // +1
    wait_and_check(3'd7, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd7, 8'd19, 16'd103, 1); // +2
    wait_and_check(3'd7, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd7, 8'd19, 16'd106, 1); // +3
    wait_and_check(3'd7, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    
    /*========== 测试用例9: 全通道压力测试 ==========*/
    test_case_num = 9;
    $display("\n[TEST CASE %0d] All channels stress test", test_case_num);
    $display("Description: All 8 channels sending simultaneously");
    
    // fork
    //     begin 
    //       send_packet(3'd0, 8'd0, 16'd1, 1); 
    //       send_packet(3'd1, 8'd1, 16'd1, 1); 
    //       send_packet(3'd2, 8'd2, 16'd1, 1); 
    //       send_packet(3'd3, 8'd3, 16'd1, 1); 
    //       send_packet(3'd4, 8'd4, 16'd1, 1); 
    //       send_packet(3'd5, 8'd5, 16'd1, 1); 
    //       send_packet(3'd6, 8'd6, 16'd1, 1); 
    //       send_packet(3'd7, 8'd7, 16'd1, 1); 
    //     end
    // join

 
            i_rtag_flag0 = 1'b1;
            i_rtag_sequence0 = 8'd1;
            i_rtag_flag1 = 1'b1;
            i_rtag_sequence1 = 8'd1;
            i_rtag_flag2 = 1'b1;
            i_rtag_sequence2 = 8'd1;
            i_rtag_flag3 = 1'b1;
            i_rtag_sequence3 = 8'd1;
            i_rtag_flag4 = 1'b1;
            i_rtag_sequence4 = 8'd1;
            i_rtag_flag5 = 1'b1;
            i_rtag_sequence5 = 8'd1;
            i_rtag_flag6 = 1'b1;
            i_rtag_sequence6 = 8'd1;
            i_rtag_flag7 = 1'b1;
            i_rtag_sequence7 = 8'd1;
            i_stream_handle0 = 8'd0;
            i_stream_handle1 = 8'd1;
            i_stream_handle2 = 8'd2;
            i_stream_handle3 = 8'd3;
            i_stream_handle4 = 8'd4;
            i_stream_handle5 = 8'd5;
            i_stream_handle6 = 8'd6;
            i_stream_handle7 = 8'd7;
            @(posedge clk);
            i_rtag_flag0 = 1'b0; 
            i_rtag_flag1 = 1'b0; 
            i_rtag_flag2 = 1'b0; 
            i_rtag_flag3 = 1'b0; 
            i_rtag_flag4 = 1'b0; 
            i_rtag_flag5 = 1'b0; 
            i_rtag_flag6 = 1'b0; 
            i_rtag_flag7 = 1'b0; 
    repeat(20) @(posedge clk);
    
    
    /*========== 测试用例10: 滞后包连续测试 ==========*/
    test_case_num = 10;
    $display("\n[TEST CASE %0d] Consecutive lagging packets", test_case_num);
    $display("Description: Send out-of-order then fill gaps");
    
    // 先发送跳跃的序列号
    send_packet(3'd0, 8'd8, 16'd200, 1);
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd8, 16'd205, 1); // 跳到205
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    // 回填中间的序列号
    send_packet(3'd0, 8'd8, 16'd201, 1);
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd8, 16'd202, 1);
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd8, 16'd203, 1);
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    send_packet(3'd0, 8'd8, 16'd204, 1);
    wait_and_check(3'd0, 1'b1, 1'b0);
    repeat(5) @(posedge clk);
    
    // 再次发送已接收的包（应该被检测为重复）
    send_packet(3'd0, 8'd8, 16'd202, 1);
    wait_and_check(3'd0, 1'b0, 1'b1); // 重复，应该丢弃
    repeat(5) @(posedge clk);
    
    
//     /*========== 测试总结 ==========*/
//     repeat(50) @(posedge clk);
    
//     $display("\n========================================");
//     $display("    Test Summary");
//     $display("========================================");
//     $display("Total Test Cases: %0d", test_case_num);
//     $display("Passed Checks:    %0d", pass_count);
//     $display("Failed Checks:    %0d", fail_count);
//     $display("========================================\n");
    
//     if(fail_count == 0) begin
//         $display("✓✓✓ ALL TESTS PASSED ✓✓✓\n");
//     end else begin
//         $display("✗✗✗ SOME TESTS FAILED ✗✗✗\n");
//     end
    
//     #1000;
//     // $finish;
end

// /*========================================== 监控输出 ==========================================*/
// // 监控所有输出变化
// always @(posedge clk) begin
//     if(o_judge_finish != 8'h0) begin
//         for(i = 0; i < 8; i = i + 1) begin
//             if(o_judge_finish[i]) begin
//                 $display("[%0t] → CH%0d Judge: pass=%0b, discard=%0b", 
//                          $time, i, o_pass_en[i], o_discard_en[i]);
//             end
//         end
//     end
// end
 
// // 匹配恢复算法全场景测试用例
// initial begin
//     test_case_num = 200;
//     pass_count = 0;
//     fail_count = 0;
//     init_all_inputs();
//     wait(rst == 1'b0);
//     repeat(10) @(posedge clk);
//     $display("\n========================================");
//     $display("  Match Recovery Full Test Cases");
//     $display("========================================\n");

//     // Test Case 1: TakeAny状态首包处理
//     $display("[MATCH CASE 1] TakeAny首包处理");
//     send_packet(3'd0, 8'd10, 16'd100, 1); wait_and_check(3'd0, 1'b1, 1'b0); // 首包
//     send_packet(3'd1, 8'd20, 16'd200, 1); wait_and_check(3'd1, 1'b1, 1'b0); // 首包

//     // Test Case 2: 正常顺序包处理
//     $display("[MATCH CASE 2] 正常顺序包处理");
//     send_packet(3'd0, 8'd10, 16'd101, 1); wait_and_check(3'd0, 1'b1, 1'b0);
//     send_packet(3'd0, 8'd10, 16'd102, 1); wait_and_check(3'd0, 1'b1, 1'b0);
//     send_packet(3'd1, 8'd20, 16'd201, 1); wait_and_check(3'd1, 1'b1, 1'b0);

//     // Test Case 3: 重复包检测与丢弃
//     $display("[MATCH CASE 3] 重复包检测与丢弃");
//     send_packet(3'd0, 8'd10, 16'd102, 1); wait_and_check(3'd0, 1'b0, 1'b1); // 重复包
//     send_packet(3'd1, 8'd20, 16'd201, 1); wait_and_check(3'd1, 1'b0, 1'b1); // 重复包

//     // Test Case 4: 乱序包处理
//     $display("[MATCH CASE 4] 乱序包处理");
//     send_packet(3'd0, 8'd10, 16'd110, 1); wait_and_check(3'd0, 1'b1, 1'b0); // 跳跃包
//     send_packet(3'd0, 8'd10, 16'd105, 1); wait_and_check(3'd0, 1'b1, 1'b0); // 滞后包
//     send_packet(3'd0, 8'd10, 16'd108, 1); wait_and_check(3'd0, 1'b1, 1'b0); // 跳跃包

//     // Test Case 5: 多通道并行输入处理
//     $display("[MATCH CASE 5] 多通道并行输入处理");
//     fork
//         begin send_packet(3'd2, 8'd30, 16'd500, 1); wait_and_check(3'd2, 1'b1, 1'b0); end
//         begin send_packet(3'd3, 8'd40, 16'd600, 1); wait_and_check(3'd3, 1'b1, 1'b0); end
//     join
//     send_packet(3'd2, 8'd30, 16'd501, 1); wait_and_check(3'd2, 1'b1, 1'b0);
//     send_packet(3'd3, 8'd40, 16'd601, 1); wait_and_check(3'd3, 1'b1, 1'b0);

//     // Test Case 6: 定时器重置功能（简单验证，详细需长仿真）
//     $display("[MATCH CASE 6] 定时器重置功能");
//     send_packet(3'd0, 8'd50, 16'd1000, 1); wait_and_check(3'd0, 1'b1, 1'b0);
//     send_packet(3'd0, 8'd50, 16'd1001, 1); wait_and_check(3'd0, 1'b1, 1'b0);
//     send_packet(3'd0, 8'd50, 16'd1002, 1); wait_and_check(3'd0, 1'b1, 1'b0);

//     // Test Case 7: 边界情况处理
//     $display("[MATCH CASE 7] 边界情况处理");
//     send_packet(3'd0, 8'd60, 16'hFFFE, 1); wait_and_check(3'd0, 1'b1, 1'b0); // Near max
//     send_packet(3'd0, 8'd60, 16'hFFFF, 1); wait_and_check(3'd0, 1'b1, 1'b0); // Max
//     send_packet(3'd0, 8'd60, 16'h0000, 1); wait_and_check(3'd0, 1'b1, 1'b0); // Rollover
//     send_packet(3'd0, 8'd60, 16'h0000, 1); wait_and_check(3'd0, 1'b0, 1'b1); // Duplicate rollover

//     $display("\n[Match Recovery Test] Passed: %0d, Failed: %0d", pass_count, fail_count);
//     #100;
// end

endmodule
// 匹配恢复算法基础测试用例


