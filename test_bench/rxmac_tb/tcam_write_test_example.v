`timescale 1ns / 1ns

//==============================================================================
// TCAM写表测试示例
// 演示如何使用tcam_write_test_utils模块进行TCAM初始化
//==============================================================================

module tcam_write_test_example;

    //==========================================================================
    // 参数定义
    //==========================================================================
    parameter   CLK_PERIOD              = 8;                   // 时钟周期 125MHz
    parameter   LOOK_UP_DATA_WIDTH      = 144;                 // 查找数据宽度
    parameter   ACTION_WIDTH            = 24;                  // Action数据位宽
    parameter   REG_ADDR_BUS_WIDTH      = 8;                   // 寄存器地址位宽
    parameter   REG_DATA_BUS_WIDTH      = 16;                  // 寄存器数据位宽

    //==========================================================================
    // 信号定义
    //==========================================================================
    
    // 时钟复位信号
    reg                                 clk                             ;
    reg                                 rst_n                           ;
    
    // TCAM写表工具控制信号
    reg                                 tb_i_write_start                ;
    reg  [2:0]                          tb_i_cmd_type                   ;
    reg  [LOOK_UP_DATA_WIDTH-1:0]       tb_i_raw_data                   ;
    reg  [LOOK_UP_DATA_WIDTH-1:0]       tb_i_dont_care_mask             ;
    reg  [ACTION_WIDTH-1:0]             tb_i_action_data                ;
    
    // TCAM写表工具状态信号
    wire                                tcam_o_write_done               ;
    wire                                tcam_o_write_busy               ;
    
    // 寄存器总线信号
    wire                                tcam_o_reg_bus_we               ;
    wire [REG_ADDR_BUS_WIDTH-1:0]       tcam_o_reg_bus_we_addr          ;
    wire [REG_DATA_BUS_WIDTH-1:0]       tcam_o_reg_bus_we_din           ;
    wire                                tcam_o_reg_bus_we_din_v         ;
    
    // TCAM忙信号 (testbench中模拟为非忙状态)
    wire                                tb_i_tcam_busy = 1'b0           ;

    //==========================================================================
    // 时钟和复位生成
    //==========================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    initial begin
        rst_n = 1'b0;
        #(CLK_PERIOD * 10);
        rst_n = 1'b1;
    end

    //==========================================================================
    // TCAM写表工具实例化
    //==========================================================================
    tcam_write_test_utils #(
        .LOOK_UP_DATA_WIDTH     (LOOK_UP_DATA_WIDTH),
        .ACTION_WIDTH           (ACTION_WIDTH),
        .REG_ADDR_BUS_WIDTH     (REG_ADDR_BUS_WIDTH),
        .REG_DATA_BUS_WIDTH     (REG_DATA_BUS_WIDTH)
    ) u_tcam_write_test_utils (
        .clk                    (clk),
        .rst                    (~rst_n),                   // 模块使用高电平复位
        .o_reg_bus_we           (tcam_o_reg_bus_we),
        .o_reg_bus_we_addr      (tcam_o_reg_bus_we_addr),
        .o_reg_bus_we_din       (tcam_o_reg_bus_we_din),
        .o_reg_bus_we_din_v     (tcam_o_reg_bus_we_din_v),
        .i_tcam_busy            (tb_i_tcam_busy),
        .i_write_start          (tb_i_write_start),
        .i_cmd_type             (tb_i_cmd_type),
        .i_raw_data             (tb_i_raw_data),
        .i_dont_care_mask       (tb_i_dont_care_mask),
        .i_action_data          (tb_i_action_data),
        .o_write_done           (tcam_o_write_done),
        .o_write_busy           (tcam_o_write_busy)
    );

    //==========================================================================
    // 信号初始化
    //==========================================================================
    initial begin
        tb_i_write_start     = 1'b0;
        tb_i_cmd_type        = 3'b000;
        tb_i_raw_data        = {LOOK_UP_DATA_WIDTH{1'b0}};
        tb_i_dont_care_mask  = {LOOK_UP_DATA_WIDTH{1'b0}};
        tb_i_action_data     = {ACTION_WIDTH{1'b0}};
    end

    //==========================================================================
    // TCAM写表任务定义
    //==========================================================================
    
    // TCAM单个表项写入task
    task tcam_write_entry;
        input [47:0] dmac;
        input [47:0] smac;
        input [15:0] vlan_ether_type;
        input [2:0]  vlan_priority;
        input [11:0] vlan_id;
        input [15:0] ether_type;
        input [23:0] action_data;
        
        reg [143:0] raw_data_144bit;
        reg [143:0] dont_care_mask_144bit;
        
        begin
            // 构造144bit原始数据: DMAC(48bit) + SMAC(48bit) + VLAN_TAG(32bit) + EtherType(16bit)
            raw_data_144bit = {dmac, smac, vlan_ether_type, vlan_priority, 1'b0, vlan_id, ether_type};
            
            // 设置don't care掩码 (0表示精确匹配，1表示don't care)
            dont_care_mask_144bit = 144'h0; // 全部精确匹配
            
            $display("[%0t] Writing TCAM entry:", $time);
            $display("  DMAC: %012h", dmac);
            $display("  SMAC: %012h", smac);
            $display("  VLAN: %04h %01h %03h", vlan_ether_type, vlan_priority, vlan_id);
            $display("  EtherType: %04h", ether_type);
            $display("  Action: %06h", action_data);
            $display("  Raw Data (144bit): %036h", raw_data_144bit);
            
            // 配置TCAM写表工具
            tb_i_cmd_type       = 3'b000;               // 写表命令
            tb_i_raw_data       = raw_data_144bit;      // 原始数据
            tb_i_dont_care_mask = dont_care_mask_144bit; // don't care掩码
            tb_i_action_data    = action_data;          // Action数据
            
            // 启动写表操作
            tb_i_write_start = 1'b1;
            @(posedge clk);
            tb_i_write_start = 1'b0;
            
            // 等待写表完成
            wait(tcam_o_write_done);
            @(posedge clk);
            
            $display("  TCAM entry write completed");
            
            // 写入完成后延时1微秒
            $display("  Waiting 1us before next write operation...");
            #1000; // 1微秒延时 (1ns时间精度)
            $display("  1us delay completed\n");
        end
    endtask
    
    // TCAM表项初始化task
    task tcam_initialize;
        begin
            $display("\n===============================================");
            $display("=== TCAM Initialization Started ===");
            $display("===============================================");
            
            // 写入TCAM表项1: IPv4单播帧
            tcam_write_entry(
                48'h001122334455,          // DMAC
                48'h00AABBCCDDEE,          // SMAC  
                16'h8100,                  // VLAN EtherType
                3'h1,                      // VLAN Priority
                12'h123,                   // VLAN ID
                16'h0800,                  // EtherType (IPv4)
                24'h123456                 // Action Data
            );
            
            // 写入TCAM表项2: 广播帧
            tcam_write_entry(
                48'hFFFFFFFFFFFF,          // 广播DMAC
                48'h001234567890,          // SMAC
                16'h8100,                  // VLAN EtherType
                3'h0,                      // VLAN Priority
                12'h100,                   // VLAN ID
                16'h0800,                  // EtherType (IPv4)
                24'h654321                 // Action Data
            );
            
            // 写入TCAM表项3: 组播帧
            tcam_write_entry(
                48'h01005E000001,          // 组播DMAC
                48'h005056C00001,          // SMAC
                16'h8100,                  // VLAN EtherType
                3'h2,                      // VLAN Priority
                12'h200,                   // VLAN ID
                16'h0806,                  // EtherType (ARP)
                24'hABCDEF                 // Action Data
            );
            
            // 写入TCAM表项4: PTP帧
            tcam_write_entry(
                48'h01001B190000,          // PTP组播DMAC
                48'h00047F123456,          // SMAC
                16'h8100,                  // VLAN EtherType
                3'h7,                      // VLAN Priority (最高优先级)
                12'h001,                   // VLAN ID
                16'h88F7,                  // EtherType (PTP)
                24'h888888                 // Action Data
            );
            
            $display("===============================================");
            $display("=== TCAM Initialization Completed ===");
            $display("===============================================\n");
        end
    endtask

    //==========================================================================
    // 测试主流程
    //==========================================================================
    initial begin
        // 等待复位完成
        wait(rst_n == 1'b1);
        repeat (50) @(posedge clk);
        
        $display("\n===============================================");
        $display("=== TCAM Write Test Example Started ===");
        $display("===============================================");
        
        // 执行TCAM初始化
        tcam_initialize();
        
        // 测试完成后再运行一段时间
        repeat (100) @(posedge clk);
        
        $display("\n===============================================");
        $display("=== TCAM Write Test Example Completed ===");
        $display("===============================================");
        
        $display("\n[INFO] Test completed successfully!");
        $finish;
    end

endmodule