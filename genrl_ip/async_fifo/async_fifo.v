module async_fifo#(
    parameter   DATA_WIDTH      = 8,
    parameter   FIFO_DEPTH      = 16,
    parameter   PTR_WIDTH       = clog2s(FIFO_DEPTH),
    parameter   DATA_FLOAT_OUT  = 1'b0 

)(
    input                       WR_RST,
    input                       WR_CLK,
    input                       WR_EN,
    input   [DATA_WIDTH-1:0]    WR_DATA,
    output                      WR_FULL,
    output  [PTR_WIDTH:0]       WR_CNT,
    
    input                       RD_RST,
    input                       RD_CLK,
    input                       RD_EN,
    output  [DATA_WIDTH-1:0]    RD_DATA,
    output                      RD_EMPTY,
    output  [PTR_WIDTH:0]       RD_CNT 
);
`include "functions.vh"


//例化模板
// async_fifo #(
//     .DATA_WIDTH     (32                        ),
//     .FIFO_DEPTH     (64                        ),
//     .DATA_FLOAT_OUT (1'b0                      )  //1为fwft ， 0为stander
// ) u_async_fifo (
//     .WR_RST         (wr_rst                    ),
//     .WR_CLK         (wr_clk                    ),
//     .WR_EN          (wr_en                     ),
//     .WR_DATA        (wr_data                   ),
//     .WR_FULL        (wr_full                   ),
//     .WR_CNT         (wr_cnt                    ),
    
//     .RD_RST         (rd_rst                    ),
//     .RD_CLK         (rd_clk                    ),
//     .RD_EN          (rd_en                     ),
//     .RD_DATA        (rd_data                   ),
//     .RD_EMPTY       (rd_empty                  ),
//     .RD_CNT         (rd_cnt                    )
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


assign  wr_en = WR_EN && ~WR_FULL;

assign  rd_en = RD_EN && ~RD_EMPTY;

fifomem #(
    .DATA_WIDTH(DATA_WIDTH),
    .FIFO_DEPTH(FIFO_DEPTH),
    .DATA_FLOAT_OUT(DATA_FLOAT_OUT)
)
x_fifomem(
    .rstn_wr_i(!WR_RST),
    .wr_clk_i(WR_CLK),
    .wr_en_i(wr_en),
    .wr_addr_i(wr_addr),
    .wr_data_i(WR_DATA),
    .rstn_rd_i(!RD_RST),
    .rd_clk_i(RD_CLK),
    .rd_en_i(rd_en),
    .rd_addr_i(rd_addr),
    .rd_data_o(RD_DATA)
);

rp2wp #(.PTR_WIDTH(PTR_WIDTH))
x_rp2wp(
    .wr_clk_i(WR_CLK),
    .rstn_i(!WR_RST),
    .rptr_gray_i(rptr_gray),
    .rp2wp_gray_o(rp2wp_syn)
);

wp2rp #(.PTR_WIDTH(PTR_WIDTH))
x_wp2rp(
    .rd_clk_i(RD_CLK),
    .rstn_i(!RD_RST),
    .wptr_gray_i(wptr_gray),
    .wp2rp_gray_o(wp2rp_syn)
);

rptr_empty #(.PTR_WIDTH(PTR_WIDTH),
             .DATA_FLOAT_OUT(DATA_FLOAT_OUT)
)           
x_rptr_empty(
    .rd_clk_i(RD_CLK),
    .rstn_i(!RD_RST),
    .rd_en_i(RD_EN),
    .wptr_gray_i(wp2rp_syn),   
    .rd_empty_o(RD_EMPTY),
    .rd_addr_o(rd_addr),
    .rptr_gray_o(rptr_gray),
    .rptr_bin_o(rptr_bin)
);

wptr_full #(.PTR_WIDTH(PTR_WIDTH))
x_wptr_full(
    .wr_clk_i(WR_CLK),
    .rstn_i(!WR_RST),
    .wr_en_i(WR_EN),
    .rptr_gray_i(rp2wp_syn),
    .wptr_gray_o(wptr_gray),
    .wr_addr_o(wr_addr),
    .wr_full_o(WR_FULL),
    .wptr_bin_o(wptr_bin)
);

wr_cnt #(.PTR_WIDTH(PTR_WIDTH))
x_wr_cnt(
  .rstn_i(!WR_RST),

  .wr_clk_i(WR_CLK),
  .wptr_bin_i(wptr_bin),
  .rp2wp_gray_i(rp2wp_syn),
  .wr_cnt_o(WR_CNT)

);

rd_cnt #(.PTR_WIDTH(PTR_WIDTH))
x_rd_cnt(
  .rstn_i(!RD_RST),

  .rd_clk_i(RD_CLK),
  .rptr_bin_i(rptr_bin),
  .wp2rp_gray_i(wp2rp_syn),
  .rd_cnt_o(RD_CNT)
);



endmodule
