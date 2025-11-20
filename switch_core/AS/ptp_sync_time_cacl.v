module ptp_sync_time_cacl (
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,

    // ptp_sync_phase
    input               wire   [79:0]                           i_sync_origintimestamp              , // 主时钟发出的sync报文的时间戳，不随着sync报文的转发而改变
    input               wire   [79:0]                           i_slaveport_pdelay                  , // salve端口的路径延迟
    input               wire   [79:0]                           i_correctionfield                   , // 修正域字段 包含之前经过系统的路径延迟和驻留延迟
    input               wire                                    i_clockoffsettime_valid             , // 时钟偏差的valid
    input               wire   [79:0]                           i_sync_in_t4                        , // 从系统收到sync报文时的当前的时间戳
    input               wire                                    i_sync_in_t4_valid                  , 

    output              wire   [79:0]                           o_slave_clockoffset                 , // 计算出的主从时间戳的偏差
    output              wire                                    o_slave_clockoffset_sign            , // 时钟偏差的标志位，0：从时钟小于主时钟 1：相反
    output              wire                                    o_slave_clockoffset_valid           , 

    // ptp_sync_frequency
    input               wire                                    i_sync_origintimestamp_valid        ,
    output              wire   [79:0]                           o_clock_add_gap                     , // 频率补偿值
    output              wire                                    o_clock_add_gap_sign                , // gap用来加还是减    
    output              wire                                    o_clock_add_gap_valid               ,      

    // ptp_forward_delay
    input               wire   [31:0]                           i_sync_out_t5                       , // 从系统 sync报文出站打时间戳t5
    input               wire                                    i_forwardtime_valid                 , // 转发延迟需要的参数

    output              wire   [31:0]                           o_forward_time                      ,   
    output              wire                                    o_forward_time_valid                ,

    // ptp_pdelay
    input               wire   [79:0]                           i_pdelay_t0                         ,
    input               wire   [79:0]                           i_pdelay_t1                         ,
    input               wire   [79:0]                           i_pdelay_t2                         ,
    input               wire   [79:0]                           i_pdelay_t3                         ,
    input               wire                                    i_pdelaytime_valid                  , // 路径延迟参数 valid  
    
    output              wire   [79:0]                           o_pdelay_time                       ,
    output              wire                                    o_pdelay_time_valid                    
);

// ptp_sync_phase实例化
ptp_sync_phase u_ptp_sync_phase           (
    .i_clk                          (i_clk                      ),
    .i_rst                          (i_rst                      ),
    .i_sync_origintimestamp         (i_sync_origintimestamp     ),
    .i_slaveport_pdelay             (i_slaveport_pdelay         ),
    .i_correctionfield              (i_correctionfield          ),
    .i_clockoffsettime_valid        (i_clockoffsettime_valid    ),
    .i_sync_in_t4                   (i_sync_in_t4               ),
    .i_sync_in_t4_valid             (i_sync_in_t4_valid         ),
    .o_slave_clockoffset            (o_slave_clockoffset        ),
    .o_slave_clockoffset_sign       (o_slave_clockoffset_sign   ),
    .o_slave_clockoffset_valid      (o_slave_clockoffset_valid  )
);

// ptp_sync_frequency实例化
ptp_sync_frequency u_ptp_sync_frequency   (
    .i_clk                          (i_clk                      ),
    .i_rst                          (i_rst                      ),
    .i_sync_origintimestamp         (i_sync_origintimestamp     ),
    .i_sync_origintimestamp_valid   (i_sync_origintimestamp_valid),
    .i_sync_in_t4                   (i_sync_in_t4               ),
    .i_sync_in_t4_valid             (i_sync_in_t4_valid         ),
    .o_clock_add_gap                (o_clock_add_gap            ),
    .o_clock_add_gap_sign           (o_clock_add_gap_sign       ),
    .o_clock_add_gap_valid          (o_clock_add_gap_valid      )
);

// ptp_pdelay实例化
ptp_pdelay u_ptp_pdelay                   (
    .i_clk                          (i_clk                      ),
    .i_rst                          (i_rst                      ),
    .i_pdelay_t0                    (i_pdelay_t0                ),
    .i_pdelay_t1                    (i_pdelay_t1                ),
    .i_pdelay_t2                    (i_pdelay_t2                ),
    .i_pdelay_t3                    (i_pdelay_t3                ),
    .i_pdelaytime_valid             (i_pdelaytime_valid         ),
    .o_pdelay_time                  (o_pdelay_time              ),
    .o_pdelay_time_valid            (o_pdelay_time_valid        )
);

// ptp_forward_delay实例化
ptp_forward_delay u_ptp_forward_delay     (
    .i_clk                          (i_clk                      ),
    .i_rst                          (i_rst                      ),
    .i_sync_in_t4                   (i_sync_in_t4[31:0]         ),
    .i_sync_out_t5                  (i_sync_out_t5              ),
    .i_forwardtime_valid            (i_forwardtime_valid        ),
    .o_forward_time                 (o_forward_time             ),
    .o_forward_time_valid           (o_forward_time_valid       )
);

endmodule