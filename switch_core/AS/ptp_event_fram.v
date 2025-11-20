/*
    根据各个子状态机的状态控制各自的计数器计时，到达计数器阈值后请求发帧
*/
module ptp_event_fram#(
    parameter                                                   PORT_NUM                =      8                , 
    parameter                                                   PORT_NUM_WIDTH          =     clog2(PORT_NUM) 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    // 各个子状态机的状态
    input               wire   [7:0]                            i_bcm_state                         , 
    input               wire   [7:0]                            i_portrole_state                    ,
    input               wire   [7:0]                            i_sync_state                        ,
    input               wire   [7:0]                            i_pdelay_state                      ,
    input               wire   [7:0]                            i_pdelay_resp_state                 ,                                     

    // 和ptp-tx-pkt交互
    output              wire                                    o_announce_req                      , // 请求转发/造帧annoucne报文  [0] : 主动发帧 【1】 ： 转发帧 
    output              wire                                    o_sync_req                          , // 请求转发/造帧sync报文
    output              wire                                    o_follow_up_req                     , // 请求转发/造帧follow_up报文   
    output              wire                                    o_pdelayreq_req                     , // 请求转发/造帧pdelayreq报文   
    output              wire                                    o_pdelayresp_req                    , // 请求转发/造帧pdelayresp报文   
    output              wire                                    o_pdelayresp_fw_req                 , // 请求转发/造帧pdelayreq_follow_up报文
    
    input               wire                                    i_announce_ack                      , 
    input               wire                                    i_sync_ack                          , 
    input               wire                                    i_follow_up_ack                     , 
    input               wire                                    i_pdelayreq_ack                     , 
    input               wire                                    i_pdelayresp_ack                    , 
    input               wire                                    i_pdelayresp_fw_ack                 , 
 
    output              wire   [PORT_NUM-1:0]                   o_announce_send_port                , // announce报文的转发端口向量
    output              wire   [PORT_NUM-1:0]                   o_sync_send_port                    , // sync报文的转发端口向量 
    output              wire   [PORT_NUM-1:0]                   o_follow_up_send_port               , // follow_up报文的转发端口向量     
    output              wire   [PORT_NUM-1:0]                   o_pdelay_req_send_port              , // pdelay_req报文的转发端口向量     
    output              wire   [PORT_NUM-1:0]                   o_pdelay_resp_send_port             , // pdelay_resp报文的转发端口向量         
    output              wire   [PORT_NUM-1:0]                   o_pdelay_resp_followup_send_port    , // pdelay_resp_followup报文的转发端口向量

    // PORT ROLE 根据端口角色确定发帧端口
    input               wire   [PORT_NUM*2-1:0]                 i_bcm_port_role                     , // 8个端口的角色分配
    input               wire                                    i_bcm_port_valid                       
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
endmodule