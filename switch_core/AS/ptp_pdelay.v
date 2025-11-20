module ptp_pdelay(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    input               wire   [79:0]                           i_pdelay_t0                         ,
    input               wire   [79:0]                           i_pdelay_t1                         ,
    input               wire   [79:0]                           i_pdelay_t2                         ,
    input               wire   [79:0]                           i_pdelay_t3                         ,
    input               wire                                    i_pdelaytime_valid                  , // 路径延迟参数 valid  
    
    output              wire   [79:0]                           o_pdelay_time                       ,
    output              wire                                    o_pdelay_time_valid                         
);

endmodule 