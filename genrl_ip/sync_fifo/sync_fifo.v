module sync_fifo #(
    parameter                       DEPTH                  = 360       ,
    parameter                       WIDTH                  = 1024      ,
    parameter                       ALMOST_FULL_THRESHOLD  = 1         ,
    parameter                       ALMOST_EMPTY_THRESHOLD = 1         ,
    parameter                       FLOP_DATA_OUT          = 0         , //是否开启fwft
    parameter                       RAM_STYLE              = 1         , // RAM综合类型选择：
                                                                           // 1: Block RAM - 适用于大容量FIFO，节省LUT资源
                                                                           // 0: Distributed RAM(LUT RAM) - 适用于小容量FIFO，访问速度快
                                                                            
    parameter                       BADDR                  = log2(DEPTH),
    parameter                       CNT_WIDTH              = log2_cnt(DEPTH) 
)(
       
    input                           i_clk                                ,
    input                           i_rst                                ,
    input                           i_wr_en                              ,
    input  [WIDTH-1:0]              i_din                                ,
    output                          o_full                               ,
    input                           i_rd_en                              ,
    output [WIDTH-1:0]              o_dout                               ,
    output                          o_empty                              ,
    output                          o_almost_full                        ,
    output                          o_almost_empty                       ,
    output [CNT_WIDTH-1:0]          o_data_cnt
);

//例化模板
// sync_fifo #(
//     .DEPTH                   (16                    ),
//     .WIDTH                   (32                    ),
//     .ALMOST_FULL_THRESHOLD   (1                     ),
//     .ALMOST_EMPTY_THRESHOLD  (1                     ),
//     .FLOP_DATA_OUT           (0                     ) //1为fwft ， 0为stander
// ) u_sync_fifo (
//     .i_clk                   (clk                   ),
//     .i_rst                   (rst                   ),
//     .i_wr_en                 (wr_en                 ),
//     .i_din                   (din                   ),
//     .o_full                  (full                  ),
//     .i_rd_en                 (rd_en                 ),
//     .o_dout                  (dout                  ),
//     .o_empty                 (empty                 ),
//     .o_almost_full           (almost_full           ),
//     .o_almost_empty          (almost_empty          ),
//     .o_data_cnt              (data_cnt              )
// );

function integer log2;
  input [31:0] value;
  begin
    log2 = 1;
    while(value > (2**log2))
        log2 = log2+1;
  end
endfunction

// Add one more bit when value=2**log2,
// used for counter width calculation
function integer log2_cnt;
  input [31:0] value;
  begin
    log2_cnt = 1;
    while(value >= (2**log2_cnt))
        log2_cnt = log2_cnt+1;
  end
endfunction

// 内部信号声明
reg    [BADDR-1:0]         rd_ptr, wr_ptr           ;
reg    [CNT_WIDTH-1:0]     status_cnt               ;
reg    [WIDTH-1:0]         data_out_d               ;

wire   [WIDTH-1:0]         data_out_c               ;
wire empty_n,full_n;
// assign语句
assign o_data_cnt      = status_cnt;
assign o_empty         = (o_data_cnt == 0);
assign empty_n       = ~o_empty;
assign o_full          = (o_data_cnt == DEPTH);
assign full_n        = ~o_full;
assign o_almost_full   = (o_data_cnt > (DEPTH - (ALMOST_FULL_THRESHOLD == 0 ? 1 : ALMOST_FULL_THRESHOLD))) ? 1'b1 : 1'b0;
assign o_almost_empty  = (o_data_cnt <= ALMOST_EMPTY_THRESHOLD) ? 1'b1 : 1'b0;

// always块
always @(posedge i_clk ) begin
    if (i_rst)
        status_cnt <= 0;
    else begin
        case ({i_rd_en, i_wr_en})
            2'b00, 2'b11: status_cnt <= status_cnt;
            2'b01: if (status_cnt != DEPTH) status_cnt <= status_cnt + 1'b1;
            2'b10: if (status_cnt != 0)     status_cnt <= status_cnt - 1'b1;
        endcase
    end
end

always @(posedge i_clk ) begin
    if (i_rst)
        wr_ptr <= 'd0;
    else if (i_wr_en && full_n) begin
        if (wr_ptr == DEPTH - 1)
            wr_ptr <= 'd0;  // 环形缓冲区，回绕到0
        else
            wr_ptr <= wr_ptr + 1'b1;
    end
end

always @(posedge i_clk ) begin
    if (i_rst)
        rd_ptr <= 'd0;
    else if (i_rd_en && empty_n) begin
        if (rd_ptr == DEPTH - 1)
            rd_ptr <= 'd0;  // 环形缓冲区，回绕到0
        else
            rd_ptr <= rd_ptr + 1'b1;
    end
end

// 参数化RAM类型选择
generate
    if (RAM_STYLE == 1) begin : gen_block_ram
        (* ram_style="block" *)
        reg [WIDTH-1:0] register [DEPTH-1:0]; 
        assign data_out_c = register[rd_ptr];
        
        always @(posedge i_clk ) begin
            if (i_wr_en && full_n) begin 
                    register[wr_ptr] <= #1 i_din; 
            end
        end

        always @(posedge i_clk ) begin 
            if (i_rd_en && empty_n) begin
                data_out_d <= #1 register[rd_ptr];
            end
        end

    end else if (RAM_STYLE == 0) begin : gen_distributed_ram
        (* ram_style="distributed" *)
        reg [WIDTH-1:0] register [DEPTH-1:0]; 
        always @(posedge i_clk ) begin
            if (i_wr_en && full_n) begin 
                    register[wr_ptr] <= #1 i_din; 
            end
        end

        always @(posedge i_clk ) begin 
            if (i_rd_en && empty_n) begin
                data_out_d <= #1 register[rd_ptr];
            end
        end
        
        assign data_out_c = register[rd_ptr];
    end  
endgenerate
assign o_dout = FLOP_DATA_OUT ? ((i_rd_en & empty_n) ? data_out_c : data_out_d) : data_out_d;





endmodule
