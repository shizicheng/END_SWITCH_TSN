module ptp_time_reg_list#(
    parameter                                                   REG_ADDR_BUS_WIDTH      =      8        ,  // 接收 MAC 层的配置寄存器地址位宽
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,   // 接收 MAC 层的配置寄存器数据位宽
    parameter                                                   TIMESTAMP_WIDTH         =      80       
    
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    /*---------------------------------------- 报文中的时间信息 -------------------------------------------*/
    // sync报文  
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_sync_origintimestamp              , // 如果两步法，则sync报文只有header+reserved
    input               wire   [63:0]                           i_sync_correctionfield              , // 一步法 sync报文的修正域字段
    input               wire   [7:0]                            i_sync_port                         , // sync报文的报文序号，独立维护
    input               wire                                    i_sync_valid                        , // sync报文有效信号
    // follow up 报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_follow_up_origintimestamp         , // 两步法对应sync报文的时间戳，如果是一步法，没有follow up报文
    input               wire   [63:0]                           i_follow_up_correctionfield         , // follow up报文或者sync报文对应的修正域字段
    input               wire                                    i_follow_up_valid                   , // follow up报文有效信号    
    input               wire   [7:0]                            i_follow_up_port                    , // follow up报文的报文序号，关联sync
    input               wire   [31:0]                           i_follow_up_rateratio               , // 主频比 --表示方法见11.4.4.3.6小节
    // Pdelay_resp报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resprectimestamp_t1        , // 报文携带的对端接收到pdelay_req报文时的时间戳 t1
    input               wire   [7:0]                            i_pdelay_resp_port                  , // pdelay_req报文的报文序号，独立维护     
    input               wire                                    i_pdelay_resp_valid                 , // pdelay_resp报文有效信号     
    // Pdelay_Resp_Follow_Up报文
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_pdelay_resporigntimestamp_t2      , // 报文携带的对端发出pdelay_resp报文时的时间戳 t2  
    input               wire   [7:0]                            i_pdelay_respfw_port                , // pdelay_resp_follow_up报文的报文序号，独立维护    
    input               wire                                    i_pdelay_respfw_valid               , // pdelay_resp_follow_up报文有效信号 
    /*---------------------------------------- 事件时间戳 -------------------------------------------*/
    input               wire                                    i_sync_out_timestamp                , // 主时钟 sync报文出站原始时间戳
    input               wire   [7:0]                            i_sync_out_port                     , // 时间戳对应的端口
    input               wire                                    i_sync_out_valid                    ,
    input               wire                                    i_sync_in_timestamp                 , // 从时钟 sync报文入站时间戳
    input               wire   [7:0]                            i_sync_in_port                      , // 时间戳对应的端口
    input               wire                                    i_sync_in_valid                     ,

    input               wire                                    i_pdelay_req_out_timestamp_t0       , // pdelay_req出站时间戳
    input               wire   [7:0]                            i_pdelay_req_out_port               , // 时间戳对应的端口
    input               wire                                    i_pdelay_req_out_valid              ,
    input               wire                                    i_pdelay_req_in_timestamp_t1        , // pdelay_req入站时间戳
    input               wire   [7:0]                            i_pdelay_req_in_port                , // 时间戳对应的端口
    input               wire                                    i_pdelay_req_in_valid               ,

    input               wire                                    i_pdelay_resp_out_timestamp_t2      , // pdelay_resp出站时间戳
    input               wire   [7:0]                            i_pdelay_resp_out_port              , // 时间戳对应的端口
    input               wire                                    i_pdelay_resp_out_valid             ,
    input               wire                                    i_pdelay_resp_in_timestamp_t3       , // pdelay_resp入站时间戳
    input               wire   [7:0]                            i_pdelay_resp_in_port               , // 时间戳对应的端口
    input               wire                                    i_pdelay_resp_in_valid              ,
    /*---------------------------------- 计算出的时间戳信息 -------------------------------------------*/
    // 相位偏差计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_slave_clockoffset                 , // 计算出的主从时间戳的偏差
    input               wire                                    i_slave_clockoffset_sign            , // 时钟偏差的标志位，0：从时钟小于主时钟 1：相反
    input               wire                                    i_slave_clockoffset_valid           , 
    // 路径延迟计算结果
    input               wire   [31:0]                           i_pdelay_time                       , // 路径延迟 
    input               wire                                    i_pdelay_time_valid                 , // 路径延迟     
    // 转发延迟计算结果
    input               wire   [31:0]                           i_forward_time                      , // sync报文的驻留时间 
    input               wire                                    i_forward_time_valid                , // sync报文的驻留时间 
    // 频率校准计算结果
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_clock_add_gap                     , // 频率补偿值
    input               wire                                    i_clock_add_gap_sign                , // gap用来加还是减    
    input               wire                                    i_clock_add_gap_valid               , 
    /*-------------------------------- 算法计算需要的时间戳信息 ---------------------------------------*/
    // 时钟偏差需要参数
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_sync_origintimestamp              , // 
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_slaveport_pdelay                  , // salve端口的路径延迟
    output              wire   [63:0]                           o_correctionfield                   , // 修正域字段 包含之前经过系统的路径延迟和驻留延迟
    output              wire                                    o_clockoffsettime_valid             , // 时钟偏差的valid

    // pdelay需要的参数
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_t0                         ,
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_t1                         ,
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_t2                         ,
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_t3                         ,
    output              wire                                    o_pdelaytime_valid                  , // 路径延迟参数 valid

    // 转发延迟需要参数
    output              wire   [31:0]                           o_sync_in_t4                        , // 从系统 sync报文进站打时间戳t4  转发延迟在ns域，32bit位宽
    output              wire   [31:0]                           o_sync_out_t5                       , // 从系统 sync报文出站打时间戳t5  转发延迟在ns域，32bit位宽
    output              wire                                    o_forwardtime_valid                 , // 转发延迟需要的参数
    /*--------------------------------造帧需要的时间戳 -----------------------------------------------*/
    input               wire   [15:0]                           i_ptpmessagetype                    , // ptp报文消息类型                          
    input               wire   [7:0]                            i_ptp_port                          , // 报文来自哪个端口                         
    input               wire   [6:0]                            i_timestamp_addr                    , // 存储时间戳的地址               
    input               wire                                    i_timestamp_rd                      , // 解析出来后，就开始读，读完送入ptp-tx-pkt 

    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_req_in_timestamp           , 
    output              wire                                    o_pdelay_req_in_timestamp_valid     ,
    
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_resp_out_timestamp         , 
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_pdelay_resp_out_timestamp_valid   , 

    output              wire   [TIMESTAMP_WIDTH-1:0]            o_sync_out_timestamp                , // 主时钟 sync出站的时间戳
    output              wire   [TIMESTAMP_WIDTH-1:0]            o_sync_out_timestamp_valid            // 主时钟 sync出站的时间戳




);


endmodule