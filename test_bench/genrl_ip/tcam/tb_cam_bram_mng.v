`timescale 1ns / 1ps

module tb_cam_bram_mng;

/*---------------------------------------- 参数定义 -------------------------------------------------*/
localparam                      LOOK_UP_DATA_WIDTH      =      16       ;   // 测试用16bit数据位宽
localparam                      PORT_MNG_DATA_WIDTH     =      8        ;   // Mac_port_mng 数据位宽 
localparam                      CAM_MODEL               =      1        ;   // 1 - CAM 表,0 - TCAM 表
localparam                      CAM_NUM                 =      128      ;   // 测试用128个表项
localparam                      DATA_CNT_WIDTH          =      clog2(LOOK_UP_DATA_WIDTH/8);
localparam                      CAM_BLOCK_NUM           =      LOOK_UP_DATA_WIDTH/(PORT_MNG_DATA_WIDTH/2); // 4个CAM块

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

/*---------------------------------------- 信号定义 -------------------------------------------------*/
// 时钟和复位信号
reg                                             clk                                     ;
reg                                             rst                                     ;

// 查表信号
reg     [LOOK_UP_DATA_WIDTH-1:0]                i_look_up_data                          ;
reg                                             i_look_up_data_vld                      ;
wire    [CAM_NUM-1:0]                           o_acl_addr                              ;

// 写表信号
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_config_data                           ;
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_config_data_mask                      ;
reg     [DATA_CNT_WIDTH-1:0]                    i_config_data_cnt                       ;
reg                                             i_config_data_vld                       ;

// 改表信号
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_change_data                           ;
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_change_data_mask                      ;
reg     [DATA_CNT_WIDTH-1:0]                    i_change_data_cnt                       ;
reg                                             i_change_data_vld                       ;

// 删除表信号
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_delete_data                           ;
reg     [(PORT_MNG_DATA_WIDTH*CAM_MODEL-1):0]   i_delete_data_mask                      ;
reg     [DATA_CNT_WIDTH-1:0]                    i_delete_data_cnt                       ;
reg                                             i_delete_data_vld                       ;

// Action表信号
wire    [clog2(CAM_NUM)-1:0]                    o_action_addra                          ;
wire    [23:0]                                  o_action_din                            ;
wire                                            o_action_wea                            ;

// 控制信号 
wire                                            o_busy                                  ;

/*---------------------------------------- 时钟生成 -------------------------------------------------*/
initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz时钟
end

/*---------------------------------------- 复位生成 -------------------------------------------------*/
initial begin
    rst = 1;
    #100;
    rst = 0;
    $display("[%t] Reset released", $time);
end

/*---------------------------------------- 测试任务定义 ---------------------------------------------*/
// 等待模块就绪 - 简化版，直接使用wait语句
task wait_ready;
begin
    while(o_busy)
   
    #1
    @(posedge clk);
    $display("[%t] Module is READY", $time);
end
endtask

// 检查ready状态 - 如果不ready就报错
task check_ready_high;
begin
    if (o_busy) begin
        $display("ERROR: Module not ready when attempting operation at time %0t", $time);
        $finish;
    end
end
endtask

// 写表任务 - 写入16位数据，分两次8位写入，严格检查ready状态
task write_cam_entry(
    input [15:0] data_16bit,      // 16位完整数据
    input [15:0] mask_16bit,      // 16位完整掩码
    input [DATA_CNT_WIDTH-1:0] entry_idx
);
begin
    $display("[%t] Starting Write Entry %0d: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
    @(posedge clk);
    // 第一次写入：写入低8位数据到CAM块0和1 (cnt=0)
    wait(!o_busy); @(posedge clk);
    i_config_data <= data_16bit[7:0];        // 低8位数据
    i_config_data_mask <= mask_16bit[7:0];   // 低8位掩码
    i_config_data_cnt <= 2'd0;               // cnt=0，表示写第0对CAM块
    i_config_data_vld <= 1'b1;    @(posedge clk);
    i_config_data_vld <= 1'b0;
    $display("[%t] Write Entry %0d Part1 START: data=0x%02X, mask=0x%02X, cnt=0", $time, entry_idx, data_16bit[7:0], mask_16bit[7:0]);

    @(posedge clk);
    // 等待ready信号拉高，表示第一次写入完成
    $display("[%t] Write Entry %0d Part1: Waiting for ready...", $time, entry_idx);
     wait(!o_busy); @(posedge clk);
    $display("[%t] Write Entry %0d Part1 COMPLETE", $time, entry_idx);
       
    i_config_data <= data_16bit[15:8];       // 高8位数据
    i_config_data_mask <= mask_16bit[15:8];  // 高8位掩码
    i_config_data_cnt <= 2'd1;               // cnt=1，表示写第1对CAM块
    i_config_data_vld <= 1'b1;    @(posedge clk);
    i_config_data_vld <= 1'b0;
    $display("[%t] Write Entry %0d Part2 START: data=0x%02X, mask=0x%02X, cnt=1", $time, entry_idx, data_16bit[15:8], mask_16bit[15:8]);

    
    // 等待第二次写入完成
    $display("[%t] Write Entry %0d Part2: Waiting for ready...", $time, entry_idx);
    wait(!o_busy); @(posedge clk);
    $display("[%t] Write Entry %0d FULLY COMPLETE: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
end
endtask

// 改表任务 - 修改16位数据，分两次8位写入，严格检查ready状态
task change_cam_entry(
    input [15:0] data_16bit,      // 16位完整数据
    input [15:0] mask_16bit,      // 16位完整掩码
    input [DATA_CNT_WIDTH-1:0] entry_idx
);
begin
    $display("[%t] Starting Change Entry %0d: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
    
    // 第一次修改：修改低8位数据到CAM块0和1 (cnt=0)
    wait_ready();
      // 双重检查ready状态
    @(posedge clk);
    i_change_data <= data_16bit[7:0];        // 低8位数据
    i_change_data_mask <= mask_16bit[7:0];   // 低8位掩码
    i_change_data_cnt <= 2'd0;               // cnt=0，表示修改第0对CAM块
    i_change_data_vld <= 1'b1;
    $display("[%t] Change Entry %0d Part1 START: data=0x%02X, mask=0x%02X, cnt=0", $time, entry_idx, data_16bit[7:0], mask_16bit[7:0]);

    
 
    
    // 第二次修改：修改高8位数据到CAM块2和3 (cnt=1)
      // 再次检查ready状态
    @(posedge clk);
    i_change_data <= data_16bit[15:8];       // 高8位数据
    i_change_data_mask <= mask_16bit[15:8];  // 高8位掩码
    i_change_data_cnt <= 2'd1;               // cnt=1，表示修改第1对CAM块
    i_change_data_vld <= 1'b1;
    $display("[%t] Change Entry %0d Part2 START: data=0x%02X, mask=0x%02X, cnt=1", $time, entry_idx, data_16bit[15:8], mask_16bit[15:8]);
    @(posedge clk);
    i_change_data_vld <= 1'b0;
    
    // 等待第二次修改完成
    $display("[%t] Change Entry %0d Part2: Waiting for ready...", $time, entry_idx);
    wait_ready();
    $display("[%t] Change Entry %0d FULLY COMPLETE: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
end
endtask

// 删除表任务 - 删除16位数据，分两次8位操作，严格检查ready状态
task delete_cam_entry(
    input [15:0] data_16bit,      // 16位完整数据
    input [15:0] mask_16bit,      // 16位完整掩码
    input [DATA_CNT_WIDTH-1:0] entry_idx
);
begin
    $display("[%t] Starting Delete Entry %0d: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
    
    // 第一次删除：删除低8位数据到CAM块0和1 (cnt=0)
    wait_ready();
      // 双重检查ready状态
    @(posedge clk);
    i_delete_data <= data_16bit[7:0];        // 低8位数据
    i_delete_data_mask <= mask_16bit[7:0];   // 低8位掩码
    i_delete_data_cnt <= 2'd0;               // cnt=0，表示删除第0对CAM块
    i_delete_data_vld <= 1'b1;
    $display("[%t] Delete Entry %0d Part1 START: data=0x%02X, mask=0x%02X, cnt=0", $time, entry_idx, data_16bit[7:0], mask_16bit[7:0]);
 
 
    
    // 第二次删除：删除高8位数据到CAM块2和3 (cnt=1)
      // 再次检查ready状态
    @(posedge clk);
    i_delete_data <= data_16bit[15:8];       // 高8位数据
    i_delete_data_mask <= mask_16bit[15:8];  // 高8位掩码
    i_delete_data_cnt <= 2'd1;               // cnt=1，表示删除第1对CAM块
    i_delete_data_vld <= 1'b1;
    $display("[%t] Delete Entry %0d Part2 START: data=0x%02X, mask=0x%02X, cnt=1", $time, entry_idx, data_16bit[15:8], mask_16bit[15:8]);
    @(posedge clk);
    i_delete_data_vld <= 1'b0;
    
    // 等待第二次删除完成
    $display("[%t] Delete Entry %0d Part2: Waiting for ready...", $time, entry_idx);
    wait_ready();
    $display("[%t] Delete Entry %0d FULLY COMPLETE: full_data=0x%04X, full_mask=0x%04X", $time, entry_idx, data_16bit, mask_16bit);
end
endtask

// 查表任务
task lookup_cam(
    input [LOOK_UP_DATA_WIDTH-1:0] lookup_data
);
begin
    @(posedge clk);
    i_look_up_data <= lookup_data;
    i_look_up_data_vld <= 1'b1;
    @(posedge clk);
    i_look_up_data_vld <= 1'b0;
    // 等待查表结果（流水线延迟）
    repeat(5) @(posedge clk);
    $display("[%t] Lookup data=0x%04X, result=0x%032X", $time, lookup_data, o_acl_addr);
end
endtask

/*---------------------------------------- 初始化信号 -----------------------------------------------*/
initial begin
    // 初始化所有输入信号
    i_look_up_data = 0;
    i_look_up_data_vld = 0;
    i_config_data = 0;
    i_config_data_mask = 0;
    i_config_data_cnt = 0;
    i_config_data_vld = 0;
    i_change_data = 0;
    i_change_data_mask = 0;
    i_change_data_cnt = 0;
    i_change_data_vld = 0;
    i_delete_data = 0;
    i_delete_data_mask = 0;
    i_delete_data_cnt = 0;
    i_delete_data_vld = 0;
end

/*---------------------------------------- 主测试流程 -----------------------------------------------*/
initial begin
    $display("========================================");
    $display("CAM BRAM Management Module Test Start");
    $display("LOOK_UP_DATA_WIDTH = %0d", LOOK_UP_DATA_WIDTH);
    $display("CAM_NUM = %0d", CAM_NUM);
    $display("CAM_BLOCK_NUM = %0d", CAM_BLOCK_NUM);
    $display("========================================");
    
    // 等待复位释放
    wait (!rst);
    repeat(10) @(posedge clk);
    
    /*---------------------------------------- 测试1：写表操作 ----------------------------------------*/
    $display("\n[Test 1] Writing CAM Entries...");
    
    // 写入表项0：数据=0xABCD，精确匹配（掩码=0xFFFF）
    write_cam_entry(16'hABCD, 16'hFFFF, 0);
    
    // 写入表项1：数据=0x1234，精确匹配（掩码=0xFFFF）  
    write_cam_entry(16'h1234, 16'hFFFF, 1);
    
    // 写入表项2：数据=0x5678，只关心高8bit（掩码=0xFF00）
    write_cam_entry(16'h5678, 16'hFF00, 2);
    
    // 写入表项3：数据=0x9ABC，只关心低8bit（掩码=0x00FF）
    write_cam_entry(16'h9ABC, 16'h00FF, 3);
    
    // // 写入表项4：数据=0xDEF0，完全不关心（掩码=0x0000）
    // write_cam_entry(16'hDEF0, 16'h0000, 4);
    wait(!o_busy);
    @(posedge clk);
    /*---------------------------------------- 测试2：查表操作 ----------------------------------------*/
    $display("\n[Test 2] Lookup Operations...");
    
    i_look_up_data <= 16'h1234;i_look_up_data_vld <= 1'b1;@(posedge clk);
    i_look_up_data <= 16'hABCD;@(posedge clk);
    i_look_up_data <= 16'h5678;@(posedge clk);
    i_look_up_data <= 16'h9ABC;@(posedge clk);
        i_look_up_data <= 16'hABCD;@(posedge clk);
    i_look_up_data <= 16'h5678;@(posedge clk);
    i_look_up_data <= 16'h9ABC;@(posedge clk);
        i_look_up_data <= 16'hABCD;@(posedge clk);
    i_look_up_data <= 16'h5678;@(posedge clk);
    i_look_up_data <= 16'h9ABC;@(posedge clk);
    // i_look_up_data_vld <= 1'b1;
    // @(posedge clk);
    i_look_up_data_vld <= 1'b0;
    // 查表测试1：查找0xABCD，应该匹配表项0
    // lookup_cam(16'hABCD);
    
    // // 查表测试2：查找0x1234，应该匹配表项1
    // lookup_cam(16'h1234);
    
    // // 查表测试3：查找0x5678，应该匹配表项2（只关心高8bit=0x56）和表项4（完全不关心）
    // lookup_cam(16'h5678);
    
    // // 查表测试4：查找0x9ABC，应该匹配表项3（只关心低8bit=0xBC）和表项4（完全不关心）
    // lookup_cam(16'h9ABC);
    
    // // 查表测试5：查找0xFFFF，应该匹配表项4（完全不关心）
    // lookup_cam(16'hFFFF);
    
    /*---------------------------------------- 测试3：改表操作 ----------------------------------------*/
    $display("\n[Test 3] Change Operations...");
    
    // 修改表项2：从0x5678(mask=0xFF00)改为0x8765(mask=0xFF00)
    change_cam_entry(16'h5678, 16'hF0F0, 2);
    repeat(80) @(posedge clk);
    // 修改后查表测试：查找0x5678，现在应该只匹配表项4（完全不关心）
    i_look_up_data <= 16'h5678;i_look_up_data_vld <= 1'b1;@(posedge clk);
    i_look_up_data_vld <= 1'b0;
    repeat(10) @(posedge clk);
    // // 查找0x8765，应该匹配修改后的表项2
    // lookup_cam(16'h8765);
    
    /*---------------------------------------- 测试4：删除表操作 ----------------------------------------*/
    $display("\n[Test 4] Delete Operations...");
    
    // 删除表项4（完全不关心的表项）
    delete_cam_entry(16'h5678, 16'h0000, 4);
      repeat(80) @(posedge clk);
    // 删除后查表测试：查找0x5678，现在应该没有匹配
    i_look_up_data <= 16'h5678;i_look_up_data_vld <= 1'b1;@(posedge clk);
    i_look_up_data_vld <= 1'b0;
    
    // 删除表项0
    delete_cam_entry(16'h9ABC, 16'hFFFF, 0);
     repeat(80) @(posedge clk);
    // 删除后查表测试：查找0xABCD，现在应该没有匹配
    i_look_up_data <= 16'h9ABC;i_look_up_data_vld <= 1'b1;@(posedge clk);
    i_look_up_data_vld <= 1'b0;
    
    /*---------------------------------------- 测试5：边界条件测试 ----------------------------------*/
    $display("\n[Test 5] Boundary Conditions...");
    
    // 测试连续操作
    write_cam_entry(16'hEFEF, 16'hFFFF, 10);
    lookup_cam(16'hEFEF);
    change_cam_entry(16'hFEFE, 16'hFFFF, 10);
    lookup_cam(16'hFEFE);
    delete_cam_entry(16'hFEFE, 16'hFFFF, 10);
    lookup_cam(16'hFEFE);
    
    /*---------------------------------------- 测试完成 --------------------------------------------*/
    $display("\n========================================");
    $display("CAM BRAM Management Module Test Complete");
    $display("========================================");
    
    repeat(50) @(posedge clk);
    $finish;
end

/*---------------------------------------- 监测信号变化 ---------------------------------------------*/
// 监测Action表写入
always @(posedge clk) begin
    if (o_action_wea) begin
        $display("[%t] Action Table Write: addr=%0d, data=0x%06X", $time, o_action_addra, o_action_din);
    end
end

// 监测模块状态变化
reg o_ready_prev;
always @(posedge clk) begin
    o_ready_prev <= !o_busy;
    if (o_ready_prev && o_busy) begin
        $display("[%t] Module becomes BUSY", $time);
    end
    if (!o_ready_prev && !o_busy) begin
        $display("[%t] Module becomes READY", $time);
    end
end

// 实时监测协议违规 - 在ready拉低时不应该有valid信号
always @(posedge clk) begin
    if (o_busy) begin
        if (i_config_data_vld) begin
            $display("ERROR: Config data valid asserted when module not ready at time %0t", $time);
            $display("       !o_busy=%b, i_config_data_vld=%b", !o_busy, i_config_data_vld);
            $finish;
        end
        if (i_change_data_vld) begin
            $display("ERROR: Change data valid asserted when module not ready at time %0t", $time);
            $display("       !o_busy=%b, i_change_data_vld=%b", !o_busy, i_change_data_vld);
            $finish;
        end
        if (i_delete_data_vld) begin
            $display("ERROR: Delete data valid asserted when module not ready at time %0t", $time);
            $display("       !o_busy=%b, i_delete_data_vld=%b", !o_busy, i_delete_data_vld);
            $finish;
        end
    end
end

/*---------------------------------------- DUT例化 -------------------------------------------------*/
cam_bram_mng #(
    .LOOK_UP_DATA_WIDTH     ( LOOK_UP_DATA_WIDTH    ),
    .PORT_MNG_DATA_WIDTH    ( PORT_MNG_DATA_WIDTH   ),
    .CAM_MODEL              ( CAM_MODEL             ),
    .CAM_NUM                ( CAM_NUM               ),
    .DATA_CNT_WIDTH         ( DATA_CNT_WIDTH        ),
    .CAM_BLOCK_NUM          ( CAM_BLOCK_NUM         )
) dut (
    .i_clk                  ( clk                   ),
    .i_rst                  ( rst                   ),
    
    // 查表接口
    .i_look_up_data         ( i_look_up_data        ),
    .i_look_up_data_vld     ( i_look_up_data_vld    ),
    .o_acl_addr             ( o_acl_addr            ),
    
    // 写表接口
    .i_config_data          ( i_config_data         ),
    .i_config_data_mask     ( i_config_data_mask    ),
    .i_config_data_cnt      ( i_config_data_cnt     ),
    .i_config_data_vld      ( i_config_data_vld     ),
    
    // 改表接口
    .i_change_data          ( i_change_data         ),
    .i_change_data_mask     ( i_change_data_mask    ),
    .i_change_data_cnt      ( i_change_data_cnt     ),
    .i_change_data_vld      ( i_change_data_vld     ),
    
    // 删除表接口
    .i_delete_data          ( i_delete_data         ),
    .i_delete_data_mask     ( i_delete_data_mask    ),
    .i_delete_data_cnt      ( i_delete_data_cnt     ),
    .i_delete_data_vld      ( i_delete_data_vld     ),
    
    // Action表接口
    .o_action_addra         ( o_action_addra        ),
    .o_action_din           ( o_action_din          ),
    .o_action_wea           ( o_action_wea          ),
    
    // 控制接口 
    .o_busy                 ( o_busy                )
);


endmodule
