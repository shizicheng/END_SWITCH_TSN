module async_fifo#(
    parameter   DATA_WIDTH      = 8000,
    parameter   FIFO_DEPTH      = 16,
    parameter   REAL_DEPTH      = 2**clog2(FIFO_DEPTH),
    parameter   PTR_WIDTH       = clog2s(REAL_DEPTH),
    parameter   DATA_FLOAT_OUT  = 1'b0,
    parameter   RAM_STYLE       = 1  // RAM综合类型选择：
                                     // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                     // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快 

)(
    input                       i_wr_rst,
    input                       i_wr_clk,
    input                       i_wr_en,
    input   [DATA_WIDTH-1:0]    i_wr_data,
    output                      o_wr_full,
    output  [PTR_WIDTH:0]       o_wr_cnt,
    
    input                       i_rd_rst,
    input                       i_rd_clk,
    input                       i_rd_en,
    output  [DATA_WIDTH-1:0]    o_rd_data,
    output                      o_rd_empty,
    output  [PTR_WIDTH:0]       o_rd_cnt 
);
`include "functions.vh"


//例化模板
// async_fifo/async_fifo_fwft #(
//     .DATA_WIDTH     (32                        ),
//     .FIFO_DEPTH     (64                        ),
//     .RAM_STYLE	   (RAM_STYLE				  ) 1:bram 0:lut
// ) u_async_fifo (
//     .i_wr_rst         (wr_rst                    ),
//     .i_wr_clk         (wr_clk                    ),
//     .i_wr_en          (wr_en                     ),
//     .i_wr_data        (wr_data                   ),
//     .o_wr_full        (wr_full                   ),
//     .o_wr_cnt         (wr_cnt                    ),
    
//     .i_rd_rst         (rd_rst                    ),
//     .i_rd_clk         (rd_clk                    ),
//     .i_rd_en          (rd_en                     ),
//     .o_rd_data        (rd_data                   ),
//     .o_rd_empty       (rd_empty                  ),
//     .o_rd_cnt         (rd_cnt                    )
// );

                                                                       
wire    [PTR_WIDTH-1:0]     wr_addr;
wire    [PTR_WIDTH-1:0]     rd_addr;
wire    [PTR_WIDTH:0]       wptr_gray;
wire    [PTR_WIDTH:0]       wptr_bin;
wire    [PTR_WIDTH:0]       rptr_gray;
wire    [PTR_WIDTH:0]       rptr_bin;
wire    [PTR_WIDTH:0]       wp2rp_syn;
wire    [PTR_WIDTH:0]       rp2wp_syn;

wire                        wr_en;
wire                        rd_en;


assign  wr_en = i_wr_en && ~o_wr_full;

assign  rd_en = i_rd_en && ~o_rd_empty;

fifomem #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(REAL_DEPTH),
    .DATA_FLOAT_OUT(DATA_FLOAT_OUT),
    .RAM_STYLE(RAM_STYLE)
)
x_fifomem(
    .rstn_wr_i(!i_wr_rst),
    .wr_clk_i(i_wr_clk),
    .wr_en_i(wr_en),
    .wr_addr_i(wr_addr),
    .wr_data_i(i_wr_data),
    .rstn_rd_i(!i_rd_rst),
    .rd_clk_i(i_rd_clk),
    .rd_en_i(rd_en),
    .rd_addr_i(rd_addr),
    .rd_data_o(o_rd_data)
);

rp2wp #(.PTR_WIDTH(PTR_WIDTH))
x_rp2wp(
    .wr_clk_i(i_wr_clk),
    .rstn_i(!i_wr_rst),
    .rptr_gray_i(rptr_gray),
    .rp2wp_gray_o(rp2wp_syn)
);

wp2rp #(.PTR_WIDTH(PTR_WIDTH))
x_wp2rp(
    .rd_clk_i(i_rd_clk),
    .rstn_i(!i_rd_rst),
    .wptr_gray_i(wptr_gray),
    .wp2rp_gray_o(wp2rp_syn)
);

rptr_empty #(.PTR_WIDTH(PTR_WIDTH),
             .DATA_FLOAT_OUT(DATA_FLOAT_OUT)
)           
x_rptr_empty(
    .rd_clk_i(i_rd_clk),
    .rstn_i(!i_rd_rst),
    .rd_en_i(i_rd_en),
    .wptr_gray_i(wp2rp_syn),   
    .rd_empty_o(o_rd_empty),
    .rd_addr_o(rd_addr),
    .rptr_gray_o(rptr_gray),
    .rptr_bin_o(rptr_bin)
);

wptr_full #(.PTR_WIDTH(PTR_WIDTH))
x_wptr_full(
    .wr_clk_i(i_wr_clk),
    .rstn_i(!i_wr_rst),
    .wr_en_i(i_wr_en),
    .rptr_gray_i(rp2wp_syn),
    .wptr_gray_o(wptr_gray),
    .wr_addr_o(wr_addr),
    .wr_full_o(o_wr_full),
    .wptr_bin_o(wptr_bin)
);

wr_cnt #(.PTR_WIDTH(PTR_WIDTH))
x_wr_cnt(
  .rstn_i(!i_wr_rst),

  .wr_clk_i(i_wr_clk),
  .wptr_bin_i(wptr_bin),
  .rp2wp_gray_i(rp2wp_syn),
  .wr_cnt_o(o_wr_cnt)

);

rd_cnt #(.PTR_WIDTH(PTR_WIDTH))
x_rd_cnt(
  .rstn_i(!i_rd_rst),

  .rd_clk_i(i_rd_clk),
  .rptr_bin_i(rptr_bin),
  .wp2rp_gray_i(wp2rp_syn),
  .rd_cnt_o(o_rd_cnt)
);



endmodule
