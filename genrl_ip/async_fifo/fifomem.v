module fifomem#(    
    parameter   DATA_WIDTH  = 8,
                FIFO_DEPTH  = 16,
                DATA_FLOAT_OUT = 1'b0,
                RAM_STYLE = 1 // 1: BRAM, 0: LUTRAM
)(
    rstn_wr_i,
    wr_clk_i,
    wr_en_i,
    wr_addr_i,
    wr_data_i,
    rstn_rd_i,
    rd_clk_i,
    rd_en_i,
    rd_addr_i,
    rd_data_o
); 

`include "functions.vh"
parameter   ADDR_WIDTH  = clog2s(FIFO_DEPTH);

input                           rstn_wr_i;
input                           wr_clk_i;
input                           wr_en_i;
input       [ADDR_WIDTH-1:0]    wr_addr_i;
input       [DATA_WIDTH-1:0]    wr_data_i;
input                           rstn_rd_i;
input                           rd_clk_i;
input                           rd_en_i;
input       [ADDR_WIDTH-1:0]    rd_addr_i;
output      [DATA_WIDTH-1:0]    rd_data_o;

reg [DATA_WIDTH-1:0]    rd_data_o  ;   

generate
    if (RAM_STYLE) begin : gen_bram
        (* ram_style = "block" *) 
        reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
        always @(posedge wr_clk_i )begin 
            if(wr_en_i) begin 
                mem[wr_addr_i] <= #1  wr_data_i; 
            end
        end

        always @(posedge rd_clk_i )begin 
            if(rd_en_i) begin
                rd_data_o <= #1 mem[rd_addr_i];      
            end 
        end
    end 
    else begin : gen_lutram
        (* ram_style = "distributed" *) 
        reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

        always @(posedge wr_clk_i )begin 
            if(wr_en_i) begin 
                mem[wr_addr_i] <= #1  wr_data_i; 
            end
        end

        always @(posedge rd_clk_i )begin 
            if(rd_en_i) begin
                rd_data_o <= #1 mem[rd_addr_i];      
            end 
        end
    end
endgenerate


 


endmodule


