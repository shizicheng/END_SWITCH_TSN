module cb_regs_list#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地�?位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // 接收 MAC 层的配置寄存器数据位�?
    parameter                                                   PORT_NUM                =      8 
)(
    input               wire                                    i_clk                            ,   // 250MHz
    input               wire                                    i_rst                            ,    
    /*---------------------------------------- 上层配置寄存�? -----------------------------------------*/
    // 寄存器写控制接口     
    input               wire                                    i_switch_reg_bus_we              , // 寄存器写使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr         , // 寄存器写地址
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din          , // 寄存器写数据
    input               wire                                    i_switch_reg_bus_we_din_v        , // 寄存器写数据使能
    // 寄存器读控制接口       
    input               wire                                    i_switch_reg_bus_rd              , // 寄存器读使能
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr         , // 寄存器读地址
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout         , // 读出寄存器数�?
    output              wire                                    o_switch_reg_bus_rd_dout_v       ,  // 读数据有效使�?

    input               wire   [15:0]                           i_recovsequm,
    input               wire   [7:0]                            i_takeany,
    input               wire   [15:0]                           i_frercpsseprcvypassed_low16,
    input               wire   [15:0]                           i_frercpsseprcvypassed_mid16_1,
    input               wire   [15:0]                           i_frercpsseprcvypassed_mid16_2, 
    input               wire   [15:0]                           i_frercpsseprcvypassed_high16,
    input               wire   [15:0]                           i_frercpsseprcvydiscarded_low16,
    input               wire   [15:0]                           i_frercpsseprcvydiscarded_mid16_1,
    input               wire   [15:0]                           i_frercpsseprcvydiscarded_mid16_2, 
    input               wire   [15:0]                           i_frercpsseprcvydiscarded_high16,
    input               wire   [15:0]                           i_frercpsseprcvyresets_low16,
    input               wire   [15:0]                           i_frercpsseprcvyresets_high16,
    input               wire   [7:0]                            i_stream_valid,

    output              wire   [7:0]                            o_max_stream_count,
    output              wire   [7:0]                            o_frerseqrcvyalgorithm_identification,
    output              wire   [7:0]                            o_frerseqrcvyhistorylength,
    output              wire   [15:0]                           o_frerseqrcvyresetmsec,
    output              wire   [7:0]                            o_current_stream_handle
);

/*---------------------------------------- CB寄存器地�?定义 -------------------------------------------*/
localparam REG_FRERSEQRCVYALGORITHM_IDENTIFICATION  = 8'h00;
localparam REG_FRERSEQRCVYHISTORYLENGTH             = 8'h01;
localparam REG_FRERSEQRCVYRESETMSEC                 = 8'h02;
localparam REG_MAXSTREAM_COUNT                      = 8'h03;
localparam REG_CURRENT_STREAM_HANDLE                = 8'h04;
localparam REG_RECOVSEQNUM                          = 8'h05;
localparam REG_TAKEANY                              = 8'h06;
localparam REG_FRERSEQRCVYPASSED_LOW16              = 8'h07;
localparam REG_FRERSEQRCVYPASSED_MID16_1            = 8'h08;
localparam REG_FRERSEQRCVYPASSED_MID16_2            = 8'h09;
localparam REG_FRERSEQRCVYPASSED_HIGH16             = 8'h0A;
localparam REG_FRERSEQRCVYDISCARDED_LOW16           = 8'h0B;
localparam REG_FRERSEQRCVYDISCARDED_MID16_1         = 8'h0C;
localparam REG_FRERSEQRCVYDISCARDED_MID16_2         = 8'h0D;
localparam REG_FRERSEQRCVYDISCARDED_HIGH16          = 8'h0E;
localparam REG_FRERSEQRCVYRESETS_LOW16              = 8'h0F;
localparam REG_FRERSEQRCVYRESETS_HIGH16             = 8'h10;
localparam REG_STREAM_VALID                         = 8'h11;

/*------------------------------------------- 寄存器信号定�? ------------------------------------------*/
// 寄存器写控制信号  
reg                                         r_reg_bus_we                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_addr                      ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_data                      ;
reg                                         r_reg_bus_data_vld                  ;
// 寄存器读控制信号
reg                                         r_reg_bus_re                        ;
reg             [REG_ADDR_BUS_WIDTH-1:0]    r_reg_bus_raddr                     ;
reg             [REG_DATA_BUS_WIDTH-1:0]    r_reg_bus_rdata                     ;
reg                                         r_reg_bus_rdata_vld                 ;

reg             [7:0]                       r_max_stream_count                  ;
reg             [7:0]                       r_frerseqrcvyalgorithm_identification;
reg             [7:0]                       r_frerseqrcvyhistorylength          ;
reg             [15:0]                      r_frerseqrcvyresetmsec              ;
reg             [7:0]                       r_current_stream_handle             ;


/*========================================  寄存器读写控制信号管�? ========================================*/
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_we          <= 1'b0;
        r_reg_bus_addr        <= {REG_ADDR_BUS_WIDTH{1'b0}};
        r_reg_bus_data        <= {REG_DATA_BUS_WIDTH{1'b0}};
        r_reg_bus_data_vld    <= 1'b0;
        r_reg_bus_re          <= 1'b0;
        r_reg_bus_raddr       <= {REG_ADDR_BUS_WIDTH{1'b0}};
    end else begin
        r_reg_bus_we          <= i_switch_reg_bus_we;
        r_reg_bus_addr        <= i_switch_reg_bus_we_addr;
        r_reg_bus_data        <= i_switch_reg_bus_we_din;
        r_reg_bus_data_vld    <= i_switch_reg_bus_we_din_v;
        r_reg_bus_re          <= i_switch_reg_bus_rd;
        r_reg_bus_raddr       <= i_switch_reg_bus_rd_addr;
    end
end 

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
		r_frerseqrcvyalgorithm_identification   <= 8'h00;
        r_frerseqrcvyhistorylength              <= 8'h04;
        r_frerseqrcvyresetmsec                  <= 16'h03E8;
        r_max_stream_count                      <= 8'h40;
        r_current_stream_handle                 <= 8'h3F;
    end else begin
        r_frerseqrcvyalgorithm_identification   <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FRERSEQRCVYALGORITHM_IDENTIFICATION ? r_reg_bus_data[7:0] : r_frerseqrcvyalgorithm_identification;
        r_frerseqrcvyhistorylength              <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FRERSEQRCVYHISTORYLENGTH ? r_reg_bus_data[7:0] : r_frerseqrcvyhistorylength;
        r_frerseqrcvyresetmsec                  <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_FRERSEQRCVYRESETMSEC ? r_reg_bus_data[15:0] : r_frerseqrcvyresetmsec;
        r_max_stream_count                      <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_MAXSTREAM_COUNT ? r_reg_bus_data[7:0] : r_max_stream_count;
        r_current_stream_handle                 <= r_reg_bus_we == 1'b1 && r_reg_bus_data_vld == 1'b1 && r_reg_bus_addr == REG_CURRENT_STREAM_HANDLE ? r_reg_bus_data[7:0] : r_current_stream_handle;
    end
end

assign o_max_stream_count                  = r_max_stream_count;
assign o_frerseqrcvyalgorithm_identification = r_frerseqrcvyalgorithm_identification;
assign o_frerseqrcvyhistorylength          = r_frerseqrcvyhistorylength;
assign o_frerseqrcvyresetmsec              = r_frerseqrcvyresetmsec;
assign o_current_stream_handle             = r_current_stream_handle;

/*========================================= 寄存器读控制逻辑 =========================================*/
// 寄存器读数据逻辑
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end else if (r_reg_bus_re) begin
        case (r_reg_bus_raddr)
            REG_FRERSEQRCVYALGORITHM_IDENTIFICATION : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},r_frerseqrcvyalgorithm_identification};
            REG_FRERSEQRCVYHISTORYLENGTH            : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},r_frerseqrcvyhistorylength};
            REG_FRERSEQRCVYRESETMSEC                : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},r_frerseqrcvyresetmsec};
            REG_MAXSTREAM_COUNT                     : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},r_max_stream_count};
            REG_CURRENT_STREAM_HANDLE               : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},r_current_stream_handle};
            REG_RECOVSEQNUM                         : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},i_recovsequm};
            REG_TAKEANY                             : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}},i_takeany};
            REG_FRERSEQRCVYPASSED_LOW16             : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvypassed_low16};
            REG_FRERSEQRCVYPASSED_MID16_1           : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvypassed_mid16_1};
            REG_FRERSEQRCVYPASSED_MID16_2           : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvypassed_mid16_2};
            REG_FRERSEQRCVYPASSED_HIGH16            : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvypassed_high16};
            REG_FRERSEQRCVYDISCARDED_LOW16          : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvydiscarded_low16};
            REG_FRERSEQRCVYDISCARDED_MID16_1        : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvydiscarded_mid16_1};
            REG_FRERSEQRCVYDISCARDED_MID16_2        : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvydiscarded_mid16_2};
            REG_FRERSEQRCVYDISCARDED_HIGH16         : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvydiscarded_high16};
            REG_FRERSEQRCVYRESETS_LOW16             : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvyresets_low16};
            REG_FRERSEQRCVYRESETS_HIGH16            : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-16){1'b0}},i_frercpsseprcvyresets_high16};
            REG_STREAM_VALID                        : r_reg_bus_rdata   <= {{(REG_DATA_BUS_WIDTH-8){1'b0}}, i_stream_valid};
            default                                 : r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
        endcase
    end else begin
        r_reg_bus_rdata <= {REG_DATA_BUS_WIDTH{1'b0}};
    end
end
// 寄存器读数据有效标志
always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        r_reg_bus_rdata_vld <= 1'b0;
    end else begin
        r_reg_bus_rdata_vld <= r_reg_bus_re;
    end
end

assign o_switch_reg_bus_rd_dout  = r_reg_bus_rdata;
assign o_switch_reg_bus_rd_dout_v= r_reg_bus_rdata_vld;


endmodule