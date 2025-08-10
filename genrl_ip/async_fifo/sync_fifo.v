module sync_fifo #(
    parameter                       DEPTH                  = 4         ,
    parameter                       WIDTH                  = 8         ,
    parameter                       ALMOST_FULL_THRESHOLD  = 0         ,
    parameter                       ALMOST_EMPTY_THRESHOLD = 0         ,
    parameter                       FLOP_DATA_OUT          = 0         ,    //是否开启fwft
    
    parameter                       BADDR                  = log2(DEPTH),
    parameter                       CNT_WIDTH              = log2_cnt(DEPTH) 
)(
       
    input                           CLK                                ,
    input                           RST                                ,
    input                           WR_EN                              ,
    input  [WIDTH-1:0]              DIN                                ,
    output                          FULL                               ,
    input                           RD_EN                              ,
    output [WIDTH-1:0]              DOUT                               ,
    output                          EMPTY                              ,
    output                          ALMOST_FULL                        ,
    output                          ALMOST_EMPTY                       ,
    output [CNT_WIDTH-1:0]          DATA_CNT
);

//例化模板
// sync_fifo #(
//     .DEPTH                 (16                    ),
//     .WIDTH                 (32                    ),
//     .ALMOST_FULL_THRESHOLD (0                     ),
//     .ALMOST_EMPTY_THRESHOLD(0                     ),
//     .FLOP_DATA_OUT         (0                     ) //1为fwft ， 0为stander
// ) u_sync_fifo (
//     .CLK                   (clk                   ),
//     .RST                   (rst                   ),
//     .WR_EN                 (wr_en                 ),
//     .DIN                   (din                   ),
//     .FULL                  (full                  ),
//     .RD_EN                 (rd_en                 ),
//     .DOUT                  (dout                  ),
//     .EMPTY                 (empty                 ),
//     .ALMOST_FULL           (almost_full           ),
//     .ALMOST_EMPTY          (almost_empty          ),
//     .DATA_CNT              (data_cnt              )
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
reg    [WIDTH-1:0]         register [DEPTH-1:0]     ;
wire   [WIDTH-1:0]         data_out_c               ;

// assign语句
assign DATA_CNT      = status_cnt;
assign EMPTY         = (DATA_CNT == 0);
assign empty_n       = ~EMPTY;
assign FULL          = (DATA_CNT == DEPTH);
assign full_n        = ~FULL;
assign ALMOST_FULL   = (DATA_CNT > (DEPTH - (ALMOST_FULL_THRESHOLD == 0 ? 1 : ALMOST_FULL_THRESHOLD))) ? 1'b1 : 1'b0;
assign ALMOST_EMPTY  = (DATA_CNT <= ALMOST_EMPTY_THRESHOLD) ? 1'b1 : 1'b0;
assign data_out_c    = register[rd_ptr];
assign DOUT          = FLOP_DATA_OUT ? data_out_c : data_out_d;

// always块
always @(posedge CLK or negedge RST) begin
    if (RST)
        status_cnt <= 0;
    else begin
        case ({RD_EN, WR_EN})
            2'b00, 2'b11: status_cnt <= status_cnt;
            2'b01: if (status_cnt != DEPTH) status_cnt <= status_cnt + 1'b1;
            2'b10: if (status_cnt != 0)     status_cnt <= status_cnt - 1'b1;
        endcase
    end
end

always @(posedge CLK or negedge RST) begin
    if (RST)
        wr_ptr <= 0;
    else if (WR_EN && full_n)
        wr_ptr <= wr_ptr + 1'b1;
end

always @(posedge CLK or negedge RST) begin
    if (RST)
        rd_ptr <= 0;
    else if (RD_EN && empty_n)
        rd_ptr <= rd_ptr + 1'b1;
end

integer i;
always @(posedge CLK or negedge RST) begin
    if (RST) begin
        for (i = 0; i < DEPTH; i = i + 1)
            register[i] <= 0;
    end
    else if (WR_EN && full_n) begin
        register[wr_ptr] <= DIN;
    end
end

always @(posedge CLK or negedge RST) begin
    if (RST)
        data_out_d <= 0;
    else if (RD_EN && empty_n)
        data_out_d <= register[rd_ptr];
end

endmodule
