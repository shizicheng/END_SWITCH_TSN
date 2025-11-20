/*
    通过两次收到sync报文的发出时间戳的差值 和 收到一次第一次sync报文后，开始计数的本地计数器，到第二次sync报文到来时的本地计数器值
    的比来计算和主时钟的频率比
*/

module ptp_sync_frequency
(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    // 时钟频率偏差需要参数
    input               wire   [79:0]                           i_sync_origintimestamp              , // 主时钟发出的sync报文的时间戳，不随着sync报文的转发而改变
    input               wire                                    i_sync_origintimestamp_valid        ,
    input               wire   [79:0]                           i_sync_in_t4                        , // 从系统收到sync报文时的当前的时间戳
    input               wire                                    i_sync_in_t4_valid                  , 

    output              wire   [79:0]                           o_clock_add_gap                     , // 频率补偿值
    output              wire                                    o_clock_add_gap_sign                , // gap用来加还是减    
    output              wire                                    o_clock_add_gap_valid                 
);

endmodule 