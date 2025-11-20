module ptp_forward_delay
(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    input               wire   [31:0]                           i_sync_in_t4                        , // 从系统 sync报文进站打时间戳t4
    input               wire   [31:0]                           i_sync_out_t5                       , // 从系统 sync报文出站打时间戳t5
    input               wire                                    i_forwardtime_valid                 , // 转发延迟需要的参数

    output              wire   [31:0]                           o_forward_time                      ,   
    output              wire                                    o_forward_time_valid

);


endmodule 