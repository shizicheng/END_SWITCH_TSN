/****************************************************************************
 * Ethernet Frame Generator Module
 * 
 * Description: Generate standard Ethernet frames with configurable MAC addresses,
 *              VLAN tags, R-Tag fields, and payload data. Includes CRC calculation.
 * 
 * Author: Auto-generated testbench
 * Date: 2025-10-08
 ****************************************************************************/

`timescale 1ns / 1ps

module eth_frame_generator #(
    parameter DATA_WIDTH          = 8                    ,  // 数据位宽
    parameter MIN_FRAME_SIZE      = 64                   ,  // 最小帧长度
    parameter MAX_FRAME_SIZE      = 1518                 ,  // 最大帧长度
    parameter MAC_ADDR_WIDTH      = 48                      // MAC地址位宽
)(
    input  wire                   i_clk                  ,  // 时钟信号
    input  wire                   i_rst                  ,  // 复位信号
    
    // 控制信号
    input  wire                   i_gen_frame           ,  // 生成帧使能
    input  wire [15:0]            i_frame_len           ,  // 帧长度(不包括前导码)
    input  wire                   i_add_vlan            ,  // 是否添加VLAN标签
    input  wire                   i_add_rtag            ,  // 是否添加R-TAG
    
    // MAC地址配置
    input  wire [47:0]            i_dst_mac             ,  // 目的MAC地址
    input  wire [47:0]            i_src_mac             ,  // 源MAC地址
    
    // VLAN配置
    input  wire [15:0]            i_vlan_tag            ,  // VLAN标签
    
    // R-TAG配置  
    input  wire [15:0]            i_rtag                ,  // R-TAG字段
    
    // 以太类型
    input  wire [15:0]            i_ether_type          ,  // 以太类型字段
    
    // AXI-Stream 输出接口
    output reg  [DATA_WIDTH-1:0]   o_axi_data            ,  // 输出数据
    output reg                     o_axi_data_valid      ,  // 数据有效
    input  wire                    i_axi_data_ready      ,  // 数据就绪
    output reg                     o_axi_data_last       ,  // 数据结束
    output reg  [DATA_WIDTH/8-1:0] o_axi_data_keep     ,  // 数据掩码
    
    // 状态输出
    output reg                    o_frame_done          ,  // 帧生成完成
    output reg                    o_busy                   // 忙状态
);

// 内部信号定义
localparam PREAMBLE_SIZE      = 7                       ;  // 前导码长度
localparam SFD_SIZE           = 1                       ;  // 帧起始定界符长度  
localparam MAC_ADDR_SIZE      = 6                       ;  // MAC地址长度
localparam VLAN_SIZE          = 4                       ;  // VLAN标签长度
localparam RTAG_SIZE          = 4                       ;  // R-TAG字段长度
localparam ETHER_TYPE_SIZE    = 2                       ;  // 以太类型长度
localparam CRC_SIZE           = 4                       ;  // CRC长度
localparam MIN_PAYLOAD_SIZE   = 46                      ;  // 最小载荷长度

// 状态机定义
localparam [3:0] IDLE           = 4'b0000;
localparam [3:0] PREAMBLE       = 4'b0001;
localparam [3:0] SFD            = 4'b0010;
localparam [3:0] DST_MAC        = 4'b0011;
localparam [3:0] SRC_MAC        = 4'b0100;
localparam [3:0] VLAN_TAG       = 4'b0101;
localparam [3:0] RTAG_FIELD     = 4'b0110;
localparam [3:0] ETHER_TYPE     = 4'b0111;
localparam [3:0] PAYLOAD        = 4'b1000;
localparam [3:0] CRC            = 4'b1001;
localparam [3:0] DONE           = 4'b1010;

reg  [3:0]                r_current_state                                 ;
reg  [3:0]                r_next_state                                    ;

// 计数器和寄存器
reg  [15:0]               r_byte_cnt                    ;  // 字节计数器
reg  [15:0]               r_total_frame_len             ;  // 总帧长度
reg  [7:0]                r_preamble_data              ;  // 前导码数据
reg  [7:0]                r_sfd_data                   ;  // SFD数据
reg  [47:0]               r_dst_mac_reg                ;  // 目的MAC寄存器
reg  [47:0]               r_src_mac_reg                ;  // 源MAC寄存器
reg  [15:0]               r_vlan_tag_reg               ;  // VLAN标签寄存器
reg  [15:0]               r_rtag_reg                   ;  // R-TAG寄存器
reg  [15:0]               r_ether_type_reg             ;  // 以太类型寄存器
reg                       r_add_vlan_reg               ;  // VLAN标志寄存器
reg                       r_add_rtag_reg               ;  // R-TAG标志寄存器
reg  [15:0]               r_payload_len                ;  // 载荷长度
reg  [7:0]                r_payload_data               ;  // 载荷数据
reg  [31:0]               r_crc_calc                   ;  // CRC计算值
reg                       r_crc_en                     ;  // CRC使能
reg  [7:0]                r_crc_data_in               ;  // CRC输入数据

// LFSR for payload data generation
reg  [31:0]               r_lfsr                       ;  // 载荷数据生成LFSR

// CRC计算模块实例化
wire [31:0]               w_crc_out                    ;
reg                       r_crc_rst                    ;

CRC32_D8 u_crc32(
    .i_clk    (i_clk        ),
    .i_rst    (r_crc_rst    ),
    .i_en     (r_crc_en     ),
    .i_data   (r_crc_data_in),
    .o_crc    (w_crc_out    )
);

// 状态机时序逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_current_state <= IDLE;
    end else begin
        r_current_state <= r_next_state;
    end
end

// 状态机组合逻辑
always @(*) begin
    r_next_state = r_current_state;
    
    case (r_current_state)
        IDLE: begin
            if (i_gen_frame && i_axi_data_ready) begin
                r_next_state = PREAMBLE;
            end
        end
        
        PREAMBLE: begin
            if (i_axi_data_ready && r_byte_cnt >= PREAMBLE_SIZE - 1) begin
                r_next_state = SFD;
            end
        end
        
        SFD: begin
            if (i_axi_data_ready) begin
                r_next_state = DST_MAC;
            end
        end
        
        DST_MAC: begin
            if (i_axi_data_ready && r_byte_cnt >= MAC_ADDR_SIZE - 1) begin
                r_next_state = SRC_MAC;
            end
        end
        
        SRC_MAC: begin
            if (i_axi_data_ready && r_byte_cnt >= MAC_ADDR_SIZE - 1) begin
                if (r_add_vlan_reg) begin
                    r_next_state = VLAN_TAG;
                end else if (r_add_rtag_reg) begin
                    r_next_state = RTAG_FIELD;
                end else begin
                    r_next_state = ETHER_TYPE;
                end
            end
        end
        
        VLAN_TAG: begin
            if (i_axi_data_ready && r_byte_cnt >= VLAN_SIZE - 1) begin
                if (r_add_rtag_reg) begin
                    r_next_state = RTAG_FIELD;
                end else begin
                    r_next_state = ETHER_TYPE;
                end
            end
        end
        
        RTAG_FIELD: begin
            if (i_axi_data_ready && r_byte_cnt >= RTAG_SIZE - 1) begin
                r_next_state = ETHER_TYPE;
            end
        end
        
        ETHER_TYPE: begin
            if (i_axi_data_ready && r_byte_cnt >= ETHER_TYPE_SIZE - 1) begin
                r_next_state = PAYLOAD;
            end
        end
        
        PAYLOAD: begin
            if (i_axi_data_ready && r_byte_cnt >= r_payload_len - 1) begin
                r_next_state = CRC;
            end
        end
        
        CRC: begin
            if (i_axi_data_ready && r_byte_cnt >= CRC_SIZE - 1) begin
                r_next_state = DONE;
            end
        end
        
        DONE: begin
            r_next_state = IDLE;
        end
        
        default: begin
            r_next_state = IDLE;
        end
    endcase
end

// 计算总帧长度和载荷长度
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_total_frame_len <= 0;
        r_payload_len     <= 0;
        r_dst_mac_reg     <= 0;
        r_src_mac_reg     <= 0;
        r_vlan_tag_reg    <= 0;
        r_rtag_reg        <= 0;
        r_ether_type_reg  <= 0;
        r_add_vlan_reg    <= 0;
        r_add_rtag_reg    <= 0;
    end else if (i_gen_frame && r_current_state == IDLE) begin
        r_dst_mac_reg     <= i_dst_mac;
        r_src_mac_reg     <= i_src_mac;
        r_vlan_tag_reg    <= i_vlan_tag;
        r_rtag_reg        <= i_rtag;
        r_ether_type_reg  <= i_ether_type;
        r_add_vlan_reg    <= i_add_vlan;
        r_add_rtag_reg    <= i_add_rtag;
        
        // 计算帧长度
        r_total_frame_len <= PREAMBLE_SIZE + SFD_SIZE + 2*MAC_ADDR_SIZE + 
                           (i_add_vlan ? VLAN_SIZE : 0) + 
                           (i_add_rtag ? RTAG_SIZE : 0) + 
                           ETHER_TYPE_SIZE + i_frame_len + CRC_SIZE;
        
        // 计算载荷长度（确保最小46字节）
        if (i_frame_len < MIN_PAYLOAD_SIZE) begin
            r_payload_len <= MIN_PAYLOAD_SIZE;
        end else begin
            r_payload_len <= i_frame_len;
        end
    end
end

// 字节计数器
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_byte_cnt <= 0;
    end else if (r_current_state == IDLE) begin
        r_byte_cnt <= 0;
    end else if (r_current_state != r_next_state) begin
        r_byte_cnt <= 0;  // 状态切换时复位计数器
    end else if (o_axi_data_valid && i_axi_data_ready) begin
        r_byte_cnt <= r_byte_cnt + 1;
    end
end

// LFSR载荷数据生成
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_lfsr <= 32'hABCDEF01;
    end else if (r_current_state == PAYLOAD && o_axi_data_valid && i_axi_data_ready) begin
        r_lfsr <= {r_lfsr[30:0], r_lfsr[31] ^ r_lfsr[21] ^ r_lfsr[1] ^ r_lfsr[0]};
    end
end

// 输出数据生成
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_axi_data       <= 0;
        o_axi_data_valid <= 0;
        o_axi_data_last  <= 0;
        o_axi_data_keep  <= 0;
        r_crc_en         <= 0;
        r_crc_data_in    <= 0;
        r_crc_rst        <= 1;
    end else begin
        r_crc_rst <= 0;
        
        case (r_current_state)
            IDLE: begin
                o_axi_data_valid <= 0;
                o_axi_data_last  <= 0;
                o_axi_data_keep  <= 0;
                r_crc_en         <= 0;
                if (i_gen_frame) begin
                    r_crc_rst <= 1;
                end
            end
            
            PREAMBLE: begin
                o_axi_data       <= 8'h55;  // 前导码
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 0;  // 前导码不参与CRC计算
            end
            
            SFD: begin
                o_axi_data       <= 8'hD5;  // 帧起始定界符
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 0;  // SFD不参与CRC计算
            end
            
            DST_MAC: begin
                o_axi_data       <= r_dst_mac_reg[(MAC_ADDR_SIZE-1-r_byte_cnt)*8 +: 8];
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= r_dst_mac_reg[(MAC_ADDR_SIZE-1-r_byte_cnt)*8 +: 8];
            end
            
            SRC_MAC: begin
                o_axi_data       <= r_src_mac_reg[(MAC_ADDR_SIZE-1-r_byte_cnt)*8 +: 8];
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= r_src_mac_reg[(MAC_ADDR_SIZE-1-r_byte_cnt)*8 +: 8];
            end
            
            VLAN_TAG: begin
                case (r_byte_cnt)
                    0: o_axi_data <= 8'h81;       // VLAN TPID高字节
                    1: o_axi_data <= 8'h00;       // VLAN TPID低字节
                    2: o_axi_data <= r_vlan_tag_reg[15:8];  // VLAN TCI高字节
                    3: o_axi_data <= r_vlan_tag_reg[7:0];   // VLAN TCI低字节
                endcase
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= o_axi_data;
            end
            
            RTAG_FIELD: begin
                o_axi_data       <= r_rtag_reg[(RTAG_SIZE-1-r_byte_cnt)*8 +: 8];
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= r_rtag_reg[(RTAG_SIZE-1-r_byte_cnt)*8 +: 8];
            end
            
            ETHER_TYPE: begin
                o_axi_data       <= r_ether_type_reg[(ETHER_TYPE_SIZE-1-r_byte_cnt)*8 +: 8];
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= r_ether_type_reg[(ETHER_TYPE_SIZE-1-r_byte_cnt)*8 +: 8];
            end
            
            PAYLOAD: begin
                o_axi_data       <= r_lfsr[7:0];  // 使用LFSR生成载荷数据
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= 0;
                r_crc_en         <= 1;
                r_crc_data_in    <= r_lfsr[7:0];
            end
            
            CRC: begin
                o_axi_data       <= w_crc_out[(CRC_SIZE-1-r_byte_cnt)*8 +: 8];
                o_axi_data_valid <= 1;
                o_axi_data_keep  <= 1'b1;
                o_axi_data_last  <= (r_byte_cnt == CRC_SIZE - 1);
                r_crc_en         <= 0;
            end
            
            DONE: begin
                o_axi_data_valid <= 0;
                o_axi_data_last  <= 0;
                o_axi_data_keep  <= 0;
                r_crc_en         <= 0;
            end
            
            default: begin
                o_axi_data_valid <= 0;
                o_axi_data_last  <= 0;
                o_axi_data_keep  <= 0;
                r_crc_en         <= 0;
            end
        endcase
    end
end

// 状态输出
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        o_busy       <= 0;
        o_frame_done <= 0;
    end else begin
        o_busy       <= (r_current_state != IDLE);
        o_frame_done <= (r_current_state == DONE);
    end
end

endmodule