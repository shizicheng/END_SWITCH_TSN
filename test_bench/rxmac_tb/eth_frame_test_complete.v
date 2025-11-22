//==============================================================================
// 文件名        : eth_frame_test_complete.v
// 作者          : AI Assistant  
// 创建日期      : 2025-10-11
// 版本          : V2.0
// 描述          : 完整的以太网帧测试示例 - 展示如何使用帧生成器和便捷任务
//==============================================================================

/*
=============================================================================
完整的以太网帧测试示例
=============================================================================

tb_rx_mac_switch.v 现在支持两种帧生成方式：

1. 使用 eth_frame_generator 模块 (硬件生成器)
2. 使用便捷任务 (软件生成器)

每个端口都可以独立选择使用哪种方式。

=============================================================================
使用方法示例：
=============================================================================

initial begin
    // 等待复位完成
    wait(r_rst_n == 1'b1);
    repeat (100) @(posedge r_clk);
    
    $display("=== 以太网帧测试开始 ===");
    
    //=========================================================================
    // 方式1：使用eth_frame_generator模块 (推荐用于重复性测试)
    //=========================================================================
    
    $display("\n[测试1] 使用帧生成器发送IPv4帧");
    gen_send_ipv4_frame(0, 16'd64);      // 端口0，64字节IPv4帧
    repeat (20) @(posedge r_clk);
    
    $display("\n[测试2] 使用帧生成器发送VLAN帧");
    gen_send_vlan_frame(1, 16'd100, 12'h100, 3'h7);  // 端口1，100字节，VLAN ID=256，优先级7
    repeat (20) @(posedge r_clk);
    
    $display("\n[测试3] 使用帧生成器发送PTP帧");
    gen_send_ptp_frame(2, 16'd76);       // 端口2，76字节PTP帧
    repeat (20) @(posedge r_clk);
    
    //=========================================================================
    // 方式2：使用便捷任务 (推荐用于灵活配置)
    //=========================================================================
    
    $display("\n[测试4] 使用便捷任务发送IPv4帧");
    quick_send_ipv4(3, 48'h01_02_03_04_05_06, 48'h00_11_22_33_44_55, 46);
    repeat (20) @(posedge r_clk);
    
    $display("\n[测试5] 使用便捷任务发送VLAN帧");
    quick_send_vlan(4, 48'h01_02_03_04_05_06, 48'h00_AA_BB_CC_DD_EE, 12'h200, 42);
    repeat (20) @(posedge r_clk);
    
    $display("\n[测试6] 使用便捷任务发送广播帧");
    quick_send_broadcast(5, 48'h00_12_34_56_78_9A, 64);
    repeat (20) @(posedge r_clk);
    
    //=========================================================================
    // 高级配置：自定义帧生成器配置
    //=========================================================================
    
    $display("\n[测试7] 自定义帧生成器配置");
    // 配置端口6为复杂VLAN+RTAG帧
    config_frame_generator(6, 16'd128, 1'b1, 1'b1, 16'h8100, 16'h1234, ETH_TYPE_TSN);
    start_frame_generator(6);
    wait_frame_generation_done(6);
    repeat (20) @(posedge r_clk);
    
    //=========================================================================
    // 批量测试
    //=========================================================================
    
    $display("\n[测试8] 批量测试序列");
    send_test_sequence(0, 16); // 从端口0开始，发送16个测试帧
    repeat (100) @(posedge r_clk);
    
    //=========================================================================
    // 性能测试：同时使用多个端口
    //=========================================================================
    
    $display("\n[测试9] 多端口并行测试");
    
    // 同时配置多个帧生成器
    config_frame_generator(0, 16'd64,  1'b0, 1'b0, 16'h8100, 16'h0000, ETH_TYPE_IPV4);
    config_frame_generator(1, 16'd128, 1'b1, 1'b0, 16'h8100, 16'h0000, ETH_TYPE_IPV4);
    config_frame_generator(2, 16'd256, 1'b0, 1'b1, 16'h8100, 16'h5678, ETH_TYPE_TSN);
    config_frame_generator(3, 16'd512, 1'b1, 1'b1, 16'h8100, 16'h9ABC, ETH_TYPE_PTP);
    
    // 同时启动
    fork
        start_frame_generator(0);
        start_frame_generator(1);
        start_frame_generator(2);
        start_frame_generator(3);
    join
    
    // 等待全部完成
    fork
        wait_frame_generation_done(0);
        wait_frame_generation_done(1);
        wait_frame_generation_done(2);
        wait_frame_generation_done(3);
    join
    
    repeat (50) @(posedge r_clk);
    
    $display("\n=== 以太网帧测试完成 ===");
    
    #10000;
    $finish;
end

=============================================================================
API 参考
=============================================================================

//--------------------------------------------------------------------------
// 帧生成器控制API
//--------------------------------------------------------------------------

1. config_frame_generator(port_id, frame_len, vlan_enable, rtag_enable, vlan_tag, rtag, ether_type)
   - 配置指定端口的帧生成器参数
   - port_id: 端口号 (0-7)
   - frame_len: 帧长度 (包括头部，不包括前导码和CRC)
   - vlan_enable: 是否添加VLAN标签
   - rtag_enable: 是否添加RTAG标签  
   - vlan_tag: VLAN标签值 (TPID + TCI)
   - rtag: RTAG值
   - ether_type: 以太网类型

2. start_frame_generator(port_id)
   - 启动指定端口的帧生成器
   - port_id: 端口号 (0-7)

3. wait_frame_generation_done(port_id)
   - 等待指定端口的帧生成完成
   - port_id: 端口号 (0-7)

4. gen_send_ipv4_frame(port_id, frame_len)
   - 生成并发送标准IPv4帧
   - port_id: 端口号 (0-7)
   - frame_len: 帧长度

5. gen_send_vlan_frame(port_id, frame_len, vlan_id, vlan_pcp)
   - 生成并发送VLAN标签帧
   - port_id: 端口号 (0-7)  
   - frame_len: 帧长度
   - vlan_id: VLAN ID (12位)
   - vlan_pcp: VLAN优先级 (3位)

6. gen_send_ptp_frame(port_id, frame_len)
   - 生成并发送PTP帧
   - port_id: 端口号 (0-7)
   - frame_len: 帧长度

//--------------------------------------------------------------------------
// 便捷任务API (与之前相同)
//--------------------------------------------------------------------------

1. quick_send_ipv4(port_id, dest_mac, src_mac, payload_len)
2. quick_send_vlan(port_id, dest_mac, src_mac, vlan_id, payload_len)  
3. quick_send_broadcast(port_id, src_mac, payload_len)
4. quick_send_ptp(port_id, src_mac, payload_len)
5. quick_send_lldp(port_id, src_mac, payload_len)
6. send_test_sequence(start_port, frame_count)

=============================================================================
以太网类型常量
=============================================================================

ETH_TYPE_IPV4     = 16'h0800   // IPv4
ETH_TYPE_ARP      = 16'h0806   // ARP
ETH_TYPE_IPV6     = 16'h86DD   // IPv6
ETH_TYPE_MPLS     = 16'h8847   // MPLS
ETH_TYPE_PTP      = 16'h88F7   // PTP (IEEE 1588)
ETH_TYPE_LLDP     = 16'h88CC   // LLDP
ETH_TYPE_TSN      = 16'h22F0   // TSN (Time-Sensitive Networking)

=============================================================================
预定义MAC地址
=============================================================================

r_src_mac_table[0] = 48'h00_11_22_33_44_55
r_src_mac_table[1] = 48'h00_AA_BB_CC_DD_EE  
r_src_mac_table[2] = 48'h00_12_34_56_78_9A
r_src_mac_table[3] = 48'h00_FE_DC_BA_98_76
...

r_dst_mac_table[0] = 48'h01_02_03_04_05_06
r_dst_mac_table[1] = 48'h01_AA_BB_CC_DD_EE
...

=============================================================================
注意事项
=============================================================================

1. 端口数据源选择：
   - r_axi_source_sel[port_id] = 1: 使用帧生成器输出
   - r_axi_source_sel[port_id] = 0: 使用便捷任务输出

2. 帧生成器与便捷任务可以混合使用，但同一端口同一时间只能使用一种方式

3. 帧生成器适合重复性、高性能测试
   便捷任务适合灵活配置、单次测试

4. 所有长度单位都是字节，不包括前导码和帧间隔

5. 帧生成器会自动计算和添加CRC32校验

*/