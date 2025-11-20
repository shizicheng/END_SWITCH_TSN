/*
    主时钟当前应该的时间戳 ： master_timestamp = i_sync_origintimestamp + i_slaveport_pdelay + i_correctionfield 
                            slave_timestamp  = i_sync_in_t4 
                            clockoffset = master_timestamp - slave_timestamp
*/

module ptp_sync_phase
(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    // 时钟偏差需要参数
    input               wire   [79:0]                           i_sync_origintimestamp              , // 主时钟发出的sync报文的时间戳，不随着sync报文的转发而改变
    input               wire   [79:0]                           i_slaveport_pdelay                  , // salve端口的路径延迟
    input               wire   [79:0]                           i_correctionfield                   , // 修正域字段 包含之前经过系统的路径延迟和驻留延迟
    input               wire                                    i_clockoffsettime_valid             , // 时钟偏差的valid

    input               wire   [79:0]                           i_sync_in_t4                        , // 从系统收到sync报文时的当前的时间戳
    input               wire                                    i_sync_in_t4_valid                  , 

    output              wire   [79:0]                           o_slave_clockoffset                 , // 计算出的主从时间戳的偏差
    output              wire                                    o_slave_clockoffset_sign            , // 时钟偏差的标志位，0：从时钟小于主时钟 1：相反
    output              wire                                    o_slave_clockoffset_valid            

);


endmodule 