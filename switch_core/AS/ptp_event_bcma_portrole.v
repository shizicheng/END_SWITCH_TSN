/*
    进来一个就生成一个通道的角色倾向，全部进来完全后，开启最终通道间的比较，得到最终的角色分配
    将优先级最高的stpv锁存，后续持续监测ann报文，如果有更优的ann报文 ，主时钟则改为从时钟状态， 重新分配端口角色
    从时钟状态不变，重新分配端口角色
*/


module ptp_event_bcma_portrole#(
    parameter                                                   PORT_NUM                =      8        , 
    parameter                                                   TIMESTAMP_WIDTH         =      80       ,
    parameter                                                   PORT_NUM_WIDTH          =     clog2(PORT_NUM) 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    
    // 报文解析数据输入
    input               wire   [PORT_NUM_WIDTH-1:0]             i_messagerec_port                   , // 接收报文的端口

    input               wire   [PORT_NUM-1:0]                   i_port_link                         , // 端口link向量
    // Announce报文 时钟同步生成树优先级向量 time-synchronization spanning tree priority vectors  -- 10.3.4小节标识各变量含义 
    input               wire   [7:0]                            i_stpv_priority1                    , // systemIdentity priority1  
    input               wire   [7:0]                            i_stpv_clkclass                     ,  
    input               wire   [7:0]                            i_stpv_clkaccuracy                  ,  
    input               wire   [15:0]                           i_stpv_variance                     ,
    input               wire   [7:0]                            i_stpv_priority2                    ,
    input               wire   [63:0]                           i_stpv_clkidentity                  ,
    input               wire   [15:0]                           i_stpv_stepsremoved                 , // stepsRemoved     
    input               wire   [TIMESTAMP_WIDTH-1:0]            i_stpv_sourceportid                 , // sourcePortIdentity ，来自header字段
    input               wire   [15:0]                           i_stpv_portnumrecofport             , // 端口接收 PTP 报文的编号 ， 来自metadata
    input               wire                                    i_stpv_valid                        ,

    input               wire   [15:0]                           i_ann_sequenceid                    , // Announce报文的报文序号，独立维护

    // 和ptp_fsm交互
    // BMCA
    input               wire   [2:0]                            i_ptp_bcm_state                     , // 00: master 01 : slave 11: reserved
    input               wire                                    i_ptp_bcm_state_valid               ,
    
    output              wire                                    o_bcm_event_start                   , // 开始bcma
    output              wire                                    o_bcm_event_monitor_end             , // 结束监听状态 
    output              wire                                    o_bcm_event_forced_gm               , // 强制最佳主时钟
    output              wire                                    o_bcm_event_forced_slave            , // 强制从时钟
    output              wire                                    o_bcm_event_rec_better_ann          , // 收到更优时钟参数事件    8个端口任意一个收到
    output              wire                                    o_bcm_event_rec_nobetter_ann        , // 收到非更优时钟参数事件     
    output              wire                                    o_bcm_event_master_timeout          , // 超时未收到announe事件
    output              wire                                    o_bcm_event_master_linkdown         , // 从端口断开连接事件
    output              wire                                    o_bcm_event_lisence_master          , // 所有端口接收到了，或者超时，跳入主时钟监听
    output              wire                                    o_bcm_event_lisence_slave           , // 所有端口接收到了，或者超时，跳入从时钟监听

    // PORT ROLE
    output              wire   [PORT_NUM*2-1:0]                 o_bcm_port_role                     , // 8个端口的角色分配
    output              wire                                    o_bcm_port_valid                             

);
/*---------------------------------------- clog2计算函数 -------------------------------------------*/
function integer clog2;
    input integer value;
    integer temp;
    begin
        temp = value - 1;
        for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
            temp = temp >> 1;
    end
endfunction 
// 内部角色分配状态跳转事件  bcm确定主从时钟状态和端口角色最终分配完成应该同时完成，避免意外bug
wire                w_portrole_event_start                  ;
wire                w_portrole_event_roletrend              ;
wire                w_portrole_event_wait_end               ;
wire                w_portrole_event_role_confirmed         ;
wire                w_portrole_event_end                    ;


endmodule            