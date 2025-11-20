module  data_delay #(
    parameter   DWIDTH      =       8 ,
    parameter   DELAY       =       2 
)(
    input   wire                    i_clk   ,
    input   wire                    i_rst   ,

    input   wire  [DWIDTH-1:0]      i_data  ,
    
    output  wire  [DWIDTH-1:0]      o_data  
);

reg     [DWIDTH-1:0]    r_data_delay    [DELAY-1:0] ;

genvar i;

generate
    for ( i = 0; i < DELAY; i = i +1 ) begin
        if ( i == 0 ) begin
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst) begin
                    r_data_delay[i] <= {DWIDTH{1'b0}};
                end else begin
                    r_data_delay[i] <= i_data;
                end
            end
        end else if (i > 0) begin
            always @(posedge i_clk or posedge i_rst) begin
                if (i_rst) begin
                    r_data_delay[i] <= {DWIDTH{1'b0}};
                end else begin
                    r_data_delay[i] <= r_data_delay[i-1];
                end
            end
        end
    end
endgenerate

assign    o_data     =     r_data_delay[DELAY-1];   

endmodule