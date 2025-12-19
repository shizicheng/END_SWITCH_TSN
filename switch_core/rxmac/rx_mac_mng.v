`include "synth_cmd_define.vh"

module rx_mac_mng
#(
    parameter                                                   PORT_NUM                =      8        ,  // �������Ķ˿���
    parameter                                                   REG_ADDR_BUS_WIDTH      =      9        ,  // ���� MAC ������üĴ�����ַλ��
    parameter                                                   REG_DATA_BUS_WIDTH      =      16       ,  // ���� MAC ������üĴ�������λ��
    parameter                                                   METADATA_WIDTH          =      81       ,  // ��Ϣ����METADATA����λ��
    parameter                                                   PORT_MNG_DATA_WIDTH     =      8        ,  // Mac_port_mng ����λ�� 
    parameter                                                   PORT_FIFO_PRI_NUM       =      8        ,  // ���ȼ�fifo����
    parameter                                                   HASH_DATA_WIDTH         =      15       ,  // ��ϣ�����ֵ��λ��
    parameter                                                   CROSS_DATA_WIDTH        =     PORT_MNG_DATA_WIDTH // �ۺ�������� 
)(
    input               wire                                    i_clk                               ,   // 250MHz
    input               wire                                    i_rst                               ,
    /*---------------------------------------- CPU_MAC������ -------------------------------------------*/
`ifdef CPU_MAC
    // �����������
    input               wire                                    i_cpu_mac0_port_link                , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_cpu_mac0_port_speed               , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_cpu_mac0_port_filter_preamble_v   , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_cpu_mac0_axi_data                 , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_cpu_mac0_axi_data_keep            , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_cpu_mac0_axi_data_valid           , // �˿�������Ч
    output              wire                                    o_cpu_mac0_axi_data_ready           , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_cpu_mac0_axi_data_last            , // ������������ʶ
    // ����ʱ���ʱ���
    output              wire                                    o_cpu_mac0_time_irq                 , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_cpu_mac0_frame_seq                , // ֡���к�
    output              wire  [7:0]                             o_timestamp0_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac0_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac0_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac0_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac0_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac0_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac0_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // CPU_MAC �����������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac0_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac0_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac0_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac0_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac0_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac0_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac0_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac0_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac0_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac0_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac0_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac0_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx0_req                           ,

    input              wire                                     i_mac0_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac0_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac0_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac0_tx7_ack_rst                  , // �˿ڵ����ȼ��������

    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac0_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac0_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac0_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac0_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac0_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac0_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac0_metadata                    , // ���� metadata ����
    output              wire                                    o_emac0_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac0_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac0_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
	/*---------------------------------------- MAC1 ������ -------------------------------------------*/
`ifdef MAC1
    // ��������Ϣ 
    input               wire                                    i_mac1_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac1_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac1_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac1_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac1_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac1_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac1_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac1_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac1_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac1_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp1_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac1_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac1_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac1_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac1_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac1_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac1_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC1 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac1_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac1_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac1_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac1_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac1_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac1_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac1_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac1_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_mac1_cross_metadata               , // ���� metadata ����
    output              wire                                    o_mac1_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output              wire                                    o_mac1_cross_metadata_last          , // ��Ϣ��������ʶ
    input               wire                                    i_mac1_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output              wire                                    o_tx1_req                           ,

    input              wire                                     i_mac1_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac1_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac1_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac1_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac1_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac1_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac1_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac1_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac1_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac1_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac1_metadata                    , // ���� metadata ����
    output              wire                                    o_emac1_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac1_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac1_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC2 ������ -------------------------------------------*/
`ifdef MAC2
    // ��������Ϣ 
    input               wire                                    i_mac2_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac2_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac2_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac2_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac2_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac2_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac2_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac2_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac2_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac2_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp2_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac2_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac2_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac2_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac2_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac2_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac2_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC2 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac2_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac2_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac2_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac2_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac2_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac2_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac2_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac2_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac2_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac2_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac2_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac2_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx2_req                           ,

    input              wire                                     i_mac2_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac2_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac2_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac2_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac2_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac2_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac2_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac2_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac2_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac2_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac2_metadata                    , // ���� metadata ����
    output              wire                                    o_emac2_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac2_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac2_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC3 ������ -------------------------------------------*/
`ifdef MAC3
    // ��������Ϣ 
    input               wire                                    i_mac3_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac3_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac3_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac3_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac3_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac3_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac3_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac3_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac3_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac3_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp3_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac3_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac3_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac3_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac3_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac3_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac3_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  

    // MAC3 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac3_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac3_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac3_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac3_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac3_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac3_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac3_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac3_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac3_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac3_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac3_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac3_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx3_req                           ,

    input              wire                                     i_mac3_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac3_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac3_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac3_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac3_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac3_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac3_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac3_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac3_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac3_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac3_metadata                    , // ���� metadata ����
    output              wire                                    o_emac3_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac3_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac3_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC4 ������ -------------------------------------------*/
`ifdef MAC4
    // ��������Ϣ 
    input               wire                                    i_mac4_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac4_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac4_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac4_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac4_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac4_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac4_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac4_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac4_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac4_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp4_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac4_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac4_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac4_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac4_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac4_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac4_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC4 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac4_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac4_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac4_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac4_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac4_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac4_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac4_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac4_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac4_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac4_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac4_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac4_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx4_req                           ,

    input              wire                                     i_mac4_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac4_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac4_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac4_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac4_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac4_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac4_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac4_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac4_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac4_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac4_metadata                    , // ���� metadata ����
    output              wire                                    o_emac4_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac4_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac4_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC5 ������ -------------------------------------------*/
`ifdef MAC5
    // ��������Ϣ 
    input               wire                                    i_mac5_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac5_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac5_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac5_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac5_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac5_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac5_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac5_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac5_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac5_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp5_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac5_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac5_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac5_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac5_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac5_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac5_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC5 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac5_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac5_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac5_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac5_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac5_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac5_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac5_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac5_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac5_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac5_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac5_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac5_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx5_req                           ,

    input              wire                                     i_mac5_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac5_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac5_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac5_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac5_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac5_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac5_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac5_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac5_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac5_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac5_metadata                    , // ���� metadata ����
    output              wire                                    o_emac5_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac5_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac5_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC6 ������ -------------------------------------------*/
`ifdef MAC6
    // ��������Ϣ 
    input               wire                                    i_mac6_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac6_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac6_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac6_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac6_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac6_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac6_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac6_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac6_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac6_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp6_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac6_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac6_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac6_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac6_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac6_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac6_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC6 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac6_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac6_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac6_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac6_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac6_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac6_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac6_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac6_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac6_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac6_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac6_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac6_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx6_req                           ,

    input              wire                                     i_mac6_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac6_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac6_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac6_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac6_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac6_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac6_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac6_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac6_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac6_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac6_metadata                    , // ���� metadata ����
    output              wire                                    o_emac6_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac6_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac6_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    /*---------------------------------------- MAC7 ������ -------------------------------------------*/
`ifdef MAC7
    // ��������Ϣ 
    input               wire                                    i_mac7_port_link                    , // �˿ڵ�����״̬
    input               wire   [1:0]                            i_mac7_port_speed                   , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    input               wire                                    i_mac7_port_filter_preamble_v       , // �˿��Ƿ����ǰ������Ϣ
    input               wire   [PORT_MNG_DATA_WIDTH-1:0]        i_mac7_axi_data                     , // �˿�������
    input               wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    i_mac7_axi_data_keep                , // �˿�����������,��Ч�ֽ�ָʾ
    input               wire                                    i_mac7_axi_data_valid               , // �˿�������Ч
    output              wire                                    o_mac7_axi_data_ready               , // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    input               wire                                    i_mac7_axi_data_last                , // ������������ʶ
    // ����ʱ���ʱ��� 
    output              wire                                    o_mac7_time_irq                     , // ��ʱ����ж��ź�
    output              wire  [7:0]                             o_mac7_frame_seq                    , // ֡���к�
    output              wire  [7:0]                             o_timestamp7_addr                   , // ��ʱ����洢�� RAM ��ַ
    // ���潻���߼�
    output             wire                                     o_mac7_rtag_flag                    , // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
    output             wire   [15:0]                            o_mac7_rtag_squence                 , // rtag_squencenum
    output             wire   [7:0]                             o_mac7_stream_handle                , // ACL��ʶ��,������,ÿ��������ά���Լ���

    input              wire                                     i_mac7_pass_en                      , // �жϽ��,���Խ��ո�֡
    input              wire                                     i_mac7_discard_en                   , // �жϽ��,���Զ�����֡
    input              wire                                     i_mac7_judge_finish                 , // �жϽ��,��ʾ���α��ĵ��ж����  
    // MAC7 ���������
    /*---------------------------------------- �� PORT ��������� -------------------------------------------*/
    output              wire                                    o_mac7_cross_port_link              , // �˿ڵ�����״̬
    output              wire   [1:0]                            o_mac7_cross_port_speed             , // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_mac7_cross_port_axi_data          , // �˿�������,���λ��ʾcrcerr
    output              wire   [15:0]                           o_mac7_cross_port_axi_user          ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_mac7_cross_axi_data_keep          , // �˿�����������,��Ч�ֽ�ָʾ
    output              wire                                    o_mac7_cross_axi_data_valid         , // �˿�������Ч
    input               wire                                    i_mac7_cross_axi_data_ready         , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_mac7_cross_axi_data_last          , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output             wire   [METADATA_WIDTH-1:0]              o_mac7_cross_metadata               , // ���� metadata ����
    output             wire                                     o_mac7_cross_metadata_valid         , // ���� metadata ������Ч�ź�
    output             wire                                     o_mac7_cross_metadata_last          , // ��Ϣ��������ʶ
    input              wire                                     i_mac7_cross_metadata_ready         , // ����ģ�鷴ѹ��ˮ�� 

    output             wire                                     o_tx7_req                           ,

    input              wire                                     i_mac7_tx0_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx0_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx1_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx1_ack_rst                  , // �˿ڵ����ȼ��������  
    input              wire                                     i_mac7_tx2_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx2_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx3_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx3_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx4_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx4_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx5_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx5_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx6_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx6_ack_rst                  , // �˿ڵ����ȼ��������
    input              wire                                     i_mac7_tx7_ack                      , // ��Ӧʹ���ź�
    input              wire   [PORT_FIFO_PRI_NUM-1:0]           i_mac7_tx7_ack_rst                  , // �˿ڵ����ȼ��������
    /*---------------------------------------- �� PORT �ؼ�֡��������� -------------------------------------------*/ 
    output              wire   [CROSS_DATA_WIDTH-1:0]           o_emac7_port_axi_data               , // �˿������������λ��ʾcrcerr
    output              wire   [15:0]                           o_emac7_port_axi_user               ,
    output              wire   [(CROSS_DATA_WIDTH/8)-1:0]       o_emac7_axi_data_keep               , // �˿����������룬��Ч�ֽ�ָʾ
    output              wire                                    o_emac7_axi_data_valid              , // �˿�������Ч
    input               wire                                    i_emac7_axi_data_ready              , // �������߾ۺϼܹ���ѹ��ˮ���ź�
    output              wire                                    o_emac7_axi_data_last               , // ������������ʶ
    /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
    output              wire   [METADATA_WIDTH-1:0]             o_emac7_metadata                    , // ���� metadata ����
    output              wire                                    o_emac7_metadata_valid              , // ���� metadata ������Ч�ź�
    output              wire                                    o_emac7_metadata_last               , // ��Ϣ��������ʶ
    input               wire                                    i_emac7_metadata_ready              , // ����ģ�鷴ѹ��ˮ�� 
`endif
    
`ifdef END_POINTER_SWITCH_CORE
    `ifdef CPU_MAC
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id_cpu                       ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac_cpu_hash_key                 , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac_cpu                          , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac_cpu_vld                      , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac_cpu_hash_key                 , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac_cpu                          , // Դ mac ��ֵ
        output              wire                                    o_smac_cpu_vld                      , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_cpu_port                       , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_cpu_port_broadcast             , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_cpu_port_vld                   ,
    `endif
    `ifdef MAC1
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id1                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac1_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac1                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac1_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac1_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac1                             , // Դ mac ��ֵ
        output              wire                                    o_smac1_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_1_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_1_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_1_port_vld                     ,
    `endif
    `ifdef MAC2
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id2                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac2_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac2                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac2_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac2_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac2                             , // Դ mac ��ֵ
        output              wire                                    o_smac2_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_2_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_2_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_2_port_vld                     ,
    `endif
    `ifdef MAC3
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id3                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac3_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac3                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac3_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac3_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac3                             , // Դ mac ��ֵ
        output              wire                                    o_smac3_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_3_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_3_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_3_port_vld                     ,
    `endif
    `ifdef MAC4
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id4                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac4_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac4                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac4_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac4_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac4                             , // Դ mac ��ֵ
        output              wire                                    o_smac4_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_4_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_4_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_4_port_vld                     ,
    `endif
    `ifdef MAC5
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id5                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac5_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac5                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac5_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac5_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac5                             , // Դ mac ��ֵ
        output              wire                                    o_smac5_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_5_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_5_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_5_port_vld                     ,
    `endif
    `ifdef MAC6
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id6                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac6_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac6                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac6_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac6_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac6                             , // Դ mac ��ֵ
        output              wire                                    o_smac6_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_6_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_6_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_6_port_vld                     ,
    `endif
    `ifdef MAC7
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        output              wire   [11:0]                           o_vlan_id7                          ,
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_dmac7_hash_key                    , // Ŀ�� mac �Ĺ�ϣֵ
        output              wire   [47 : 0]                         o_dmac7                             , // Ŀ�� mac ��ֵ
        output              wire                                    o_dmac7_vld                         , // dmac_vld
        output              wire   [HASH_DATA_WIDTH - 1 : 0]        o_smac7_hash_key                    , // Դ mac ��ֵ��Ч��ʶ
        output              wire   [47 : 0]                         o_smac7                             , // Դ mac ��ֵ
        output              wire                                    o_smac7_vld                         , // smac_vld

        input               wire   [PORT_NUM - 1:0]                 i_tx_7_port                         , // ������ģ�鷵�صĲ���˿���Ϣ
        input               wire   [1:0]                            i_tx_7_port_broadcast               , // 01:�鲥 10���㲥 11:����
        input               wire                                    i_tx_7_port_vld                     ,
    `endif
`endif

	
	/*---------------------------------------- �Ĵ������ýӿ� -------------------------------------------*/
    // �Ĵ��������ź�                     
    input               wire                                    i_refresh_list_pulse                , // ˢ�¼Ĵ����б���״̬�Ĵ����Ϳ��ƼĴ�����
    input               wire                                    i_switch_err_cnt_clr                , // ˢ�´��������
    input               wire                                    i_switch_err_cnt_stat               , // ˢ�´���״̬�Ĵ���
    // �Ĵ���д���ƽӿ�     
    input               wire                                    i_switch_reg_bus_we                 , // �Ĵ���дʹ��
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_we_addr            , // �Ĵ���д��ַ
    input               wire   [REG_DATA_BUS_WIDTH-1:0]         i_switch_reg_bus_we_din             , // �Ĵ���д����
    input               wire                                    i_switch_reg_bus_we_din_v           , // �Ĵ���д����ʹ��
    // �Ĵ��������ƽӿ�     
    input               wire                                    i_switch_reg_bus_rd                 , // �Ĵ�����ʹ��
    input               wire   [REG_ADDR_BUS_WIDTH-1:0]         i_switch_reg_bus_rd_addr            , // �Ĵ�������ַ
    output              wire   [REG_DATA_BUS_WIDTH-1:0]         o_switch_reg_bus_rd_dout            , // �����Ĵ�������
    output              wire                                    o_switch_reg_bus_rd_dout_v            // ��������Чʹ��

    /*
        metadata �������
            [93:79] : CBЭ�� R-TAG�ֶ�
            [78:64] : CBЭ�� R-TAG�ֶ�
            [63](1bit) : port_speed 
            [62:60](3bit) : vlan_pri 
            [59:52](8bit) : tx_prot
            [51:44](8bit) : acl_frmtype
            [43:28](16bit): acl_fetchinfo
            [27](1bit) : frm_vlan_flag
            [26:19](8bit) : ����˿�,bitmap��ʾ
            [18:15](4bit) : Qos����
            [14:13](2bit) : ���ิ��������(cb),01��ʾ����,10��ʾ����,00��ʾ��CBҵ��֡
            [12](1bit) : ����λ
            [11](1bit) : �Ƿ�Ϊ�ؼ�֡(Qbu)
            [10:4](7bit) ��time_stamp_addr,����ʱ����ĵ�ַ��Ϣ
    */
);

`ifdef CPU_MAC

    wire                                    w_cpu_mac0_port_link                ; // �˿ڵ�����״̬
    wire   [1:0]                            w_cpu_mac0_port_speed               ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_cpu_mac0_port_filter_preamble_v   ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_cpu_mac0_axi_data                 ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_cpu_mac0_axi_data_keep            ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_cpu_mac0_axi_data_valid           ; // �˿�������Ч
    wire                                    w_cpu_mac0_axi_data_ready           ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_cpu_mac0_axi_data_last            ; // ������������ʶ

    wire                                    w_cpu_mac0_time_irq                 ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_cpu_mac0_frame_seq                ; // ֡���к�
    wire  [7:0]                             w_timestamp0_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac0_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac0_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac0_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
	wire   [15:0]							w_mac0_cross_port_axi_user			;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac0_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac0_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac0_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac0_cross_axi_data_last          ; // ������������ʶ

    wire   [METADATA_WIDTH-1:0]             w_mac0_cross_metadata               ; // �ۺ����� metadata ����
    wire                                    w_mac0_cross_metadata_valid         ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac0_cross_metadata_last          ; // ��Ϣ��������ʶ
    wire                                    w_mac0_cross_metadata_ready         ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_cpu                       ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac_cpu_hash_key                 ; 
    wire   [47 : 0]                         w_dmac_cpu                          ; 
    wire                                    w_dmac_cpu_vld                      ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac_cpu_hash_key                 ; 
    wire   [47 : 0]                         w_smac_cpu                          ; 
    wire                                    w_smac_cpu_vld                      ; 
    // // R-TAG ���к�����Ч�ź� wire ��������
    // wire   [15:0]                           w_mac0_rtag_sequence                ;
    // wire                                    w_mac0_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign              o_mac0_rtag_sequence                    =   w_mac0_rtag_sequence             ;
    // assign              o_mac0_rtag_valid                       =   w_mac0_rtag_valid                ;
    wire                                    w_mac0_rtag_flag                    ;
    wire   [15:0]                           w_mac0_rtag_squence                 ;
    wire   [7:0]                            w_mac0_stream_handle                ;
    wire   [15:0]                           w_hash_ploy_regs_0                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_0              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_0                   ;
    wire                                    w_port_rxmac_down_regs_0            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_0        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_0        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_0         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_0                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_0               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_0                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_0           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_0          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_0  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_0                    ; // ѡ��Ҫ���õĶ˿�
	wire								    w_acl_port_sel_0_valid				;
    wire                                    w_acl_clr_list_regs_0               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_0               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_0               ; // ������Ŀѡ��
//    wire   [95:0]                           w_acl_item_dmac_code_0              ;
//    wire   [95:0]                           w_acl_item_smac_code_0              ;
//    wire   [63:0]                           w_acl_item_vlan_code_0              ;
//    wire   [31:0]                           w_acl_item_ethtype_code_0           ;
//    wire   [5:0]                            w_acl_item_action_pass_state_0      ;
//    wire   [15:0]                           w_acl_item_action_cb_streamhandle_0 ;
//    wire   [5:0]                            w_acl_item_action_flowctrl_0        ;
//    wire   [15:0]                           w_acl_item_action_txport_0          ;
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_a1_valid      			; // д����Ч�ź�															
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_a2_valid      			; // д����Ч�ź�															
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_a3_valid      			; // д����Ч�ź�															
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_a4_valid      			; // д����Ч�ź�															
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_a5_valid      			; // д����Ч�ź�															
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_a6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_a6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_a1_valid      			; // д����Ч�ź�															                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_a2_valid      			; // д����Ч�ź�																                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_a3_valid      			; // д����Ч�ź�															                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_a4_valid      			; // д����Ч�ź�															                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_a5_valid      			; // д����Ч�ź�															                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_a6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_a6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_a1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_a1_valid      			; // д����Ч�ź�											
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_a2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_a2_valid      			; // д����Ч�ź�												
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_a3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_a3_valid      			; // д����Ч�ź�											
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_a4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_a4_valid      			; // д����Ч�ź�							           		
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_a1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_a1_valid 			; // д����Ч�ź�																                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_a2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_a2_valid 			; // д����Ч�ź�													                                                                 		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_a     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_a_valid		; // д����Ч�ź�																	                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_a 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_a_valid	; // д����Ч�ź�																
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_a        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_a_valid  		; // д����Ч�ź�																
	wire   [15:0]                       	w_cfg_acl_item_action_txport_a          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_a_valid      		; // д����Ч�ź�

    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_0                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_0          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_0          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_0              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_0        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_0         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_0         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_0                ; // �˿�0�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_0               ; // �˿�0����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_0                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_0                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_0            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_0                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_0                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_0                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_0                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_0                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_0                       ; // ֡���
    wire                                    w_reset_0                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac0_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac0_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac0_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac0_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac0_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac0_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac0_metadata                    ; // ���� metadata ����
    wire                                    w_emac0_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac0_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac0_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
    assign              o_mac0_rtag_flag                        =   w_mac0_rtag_flag                 ;
    assign              o_mac0_rtag_squence                     =   w_mac0_rtag_squence              ;
    assign              o_mac0_stream_handle                    =   w_mac0_stream_handle             ;

    assign              w_cpu_mac0_port_link                    =   i_cpu_mac0_port_link             ;       
    assign              w_cpu_mac0_port_speed                   =   i_cpu_mac0_port_speed            ;       
    assign              w_cpu_mac0_port_filter_preamble_v       =   i_cpu_mac0_port_filter_preamble_v;       
    assign              w_cpu_mac0_axi_data                     =   i_cpu_mac0_axi_data              ;       
    assign              w_cpu_mac0_axi_data_keep                =   i_cpu_mac0_axi_data_keep         ;       
    assign              w_cpu_mac0_axi_data_valid               =   i_cpu_mac0_axi_data_valid        ;    
    assign              w_cpu_mac0_axi_data_last                =   i_cpu_mac0_axi_data_last         ;
    assign              o_cpu_mac0_axi_data_ready               =   w_cpu_mac0_axi_data_ready        ;   

    assign              o_cpu_mac0_time_irq                     =   w_cpu_mac0_time_irq              ;
    assign              o_cpu_mac0_frame_seq                    =   w_cpu_mac0_frame_seq             ;
    assign              o_timestamp0_addr                       =   w_timestamp0_addr                ;

    assign              o_mac0_cross_port_link                  =  w_mac0_cross_port_link            ;
    assign              o_mac0_cross_port_speed                 =  w_mac0_cross_port_speed           ;
    assign              o_mac0_cross_port_axi_data              =  w_mac0_cross_port_axi_data        ;
	assign 				o_mac0_cross_port_axi_user				=  w_mac0_cross_port_axi_user		 ;
    assign              o_mac0_cross_axi_data_keep              =  w_mac0_cross_axi_data_keep        ;
    assign              o_mac0_cross_axi_data_valid             =  w_mac0_cross_axi_data_valid       ;
    assign              w_mac0_cross_axi_data_ready             =  i_mac0_cross_axi_data_ready       ; 
    assign              o_mac0_cross_axi_data_last              =  w_mac0_cross_axi_data_last        ;

    assign              o_mac0_cross_metadata                   =  w_mac0_cross_metadata             ; 
    assign              o_mac0_cross_metadata_valid             =  w_mac0_cross_metadata_valid       ; 
    assign              o_mac0_cross_metadata_last              =  w_mac0_cross_metadata_last        ; 
    assign              w_mac0_cross_metadata_ready             =  i_mac0_cross_metadata_ready       ;  

    assign              o_emac0_port_axi_data                   =  w_emac0_port_axi_data             ; // �˿������������λ��ʾcrcerr
    assign              o_emac0_port_axi_user                   =  w_emac0_port_axi_user             ;
    assign              o_emac0_axi_data_keep                   =  w_emac0_axi_data_keep             ; // �˿����������룬��Ч�ֽ�ָʾ
    assign              o_emac0_axi_data_valid                  =  w_emac0_axi_data_valid            ; // �˿�������Ч
    assign              w_emac0_axi_data_ready                  =  i_emac0_axi_data_ready            ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign              o_emac0_axi_data_last                   =  w_emac0_axi_data_last             ; // ������������ʶ 
    assign              o_emac0_metadata                        =  w_emac0_metadata                  ; // ���� metadata ����
    assign              o_emac0_metadata_valid                  =  w_emac0_metadata_valid            ; // ���� metadata ������Ч�ź�
    assign              o_emac0_metadata_last                   =  w_emac0_metadata_last             ; // ��Ϣ��������ʶ
    assign              w_emac0_metadata_ready                  =  i_emac0_metadata_ready            ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC1
    wire                                    w_mac1_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac1_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac1_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac1_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac1_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac1_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac1_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac1_axi_data_last                ; // ������������ʶ

    wire                                    w_mac1_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac1_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp1_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac1_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac1_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac1_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac1_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire	[15:0]							w_mac1_cross_port_axi_user			;
    wire                                    w_mac1_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac1_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac1_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac1_cross_metadata               ; // �ۺ����� metadata ����
    wire                                    w_mac1_cross_metadata_valid         ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac1_cross_metadata_last          ; // ��Ϣ��������ʶ
    wire                                    w_mac1_cross_metadata_ready         ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac1                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac1_hash_key                    ; 
    wire   [47 : 0]                         w_dmac1                             ; 
    wire                                    w_dmac1_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac1_hash_key                    ; 
    wire   [47 : 0]                         w_smac1                             ; 
    wire                                    w_smac1_vld                         ;     // R-TAG ���к�����Ч�ź� wire ��������
    // wire   [15:0]                           w_mac1_rtag_sequence                ;
    // wire                                    w_mac1_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac1_rtag_sequence                =   w_mac1_rtag_sequence             ;
    // assign      o_mac1_rtag_valid                   =   w_mac1_rtag_valid                ;
    wire                                    w_mac1_rtag_flag                    ;
    wire   [15:0]                           w_mac1_rtag_squence                 ;
    wire   [7:0]                            w_mac1_stream_handle                ;

    wire   [15:0]                           w_hash_ploy_regs_1                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_1              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_1                   ;
    wire                                    w_port_rxmac_down_regs_1            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_1        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_1        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_1         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_1                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_1               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_1                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_1           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_1          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_1  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_1                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_1_valid				;
    wire                                    w_acl_clr_list_regs_1               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_1               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_1               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_b1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_b2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_b3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_b4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_b5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_b6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_b6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_b1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_b2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_b3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_b4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_b5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_b6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_b6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_b1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_b1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_b2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_b2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_b3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_b3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_b4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_b4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_b1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_b1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_b2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_b2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_b     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_b_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_b 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_b_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_b        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_b_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_b          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_b_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_1                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_1          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_1          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_1              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_1        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_1         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_1         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_1                ; // �˿�0�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_1               ; // �˿�0����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_1                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_1                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_1            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_1                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_1                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_1                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_1                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_1                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_1                       ; // ֡���
    wire                                    w_reset_1                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac1_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac1_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac1_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac1_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac1_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac1_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac1_metadata                    ; // ���� metadata ����
    wire                                    w_emac1_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac1_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac1_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
    assign      o_mac1_rtag_flag                =   w_mac1_rtag_flag                 ;
    assign      o_mac1_rtag_squence             =   w_mac1_rtag_squence              ;
    assign      o_mac1_stream_handle            =   w_mac1_stream_handle             ;
        
    assign      w_mac1_port_link                    =        i_mac1_port_link             ;                            
    assign      w_mac1_port_speed                   =        i_mac1_port_speed            ;                            
    assign      w_mac1_port_filter_preamble_v       =        i_mac1_port_filter_preamble_v;                            
    assign      w_mac1_axi_data                     =        i_mac1_axi_data              ;                            
    assign      w_mac1_axi_data_keep                =        i_mac1_axi_data_keep         ;                            
    assign      w_mac1_axi_data_valid               =        i_mac1_axi_data_valid        ;                            
    assign      o_mac1_axi_data_ready               =        w_mac1_axi_data_ready        ;              
    assign      w_mac1_axi_data_last                =        i_mac1_axi_data_last         ;
                                                
    assign      o_mac1_time_irq                     =        w_mac1_time_irq              ;                                
    assign      o_mac1_frame_seq                    =        w_mac1_frame_seq             ;                                
    assign      o_timestamp1_addr                   =        w_timestamp1_addr            ;     

    assign     o_mac1_cross_port_link               =  w_mac1_cross_port_link            ;
    assign     o_mac1_cross_port_speed              =  w_mac1_cross_port_speed           ;
    assign     o_mac1_cross_port_axi_data           =  w_mac1_cross_port_axi_data        ;
	assign 	   o_mac1_cross_port_axi_user			=  w_mac1_cross_port_axi_user		 ;
    assign     o_mac1_cross_axi_data_keep           =  w_mac1_cross_axi_data_keep        ;
    assign     o_mac1_cross_axi_data_valid          =  w_mac1_cross_axi_data_valid       ;
    assign     w_mac1_cross_axi_data_ready          =  i_mac1_cross_axi_data_ready       ; 
    assign     o_mac1_cross_axi_data_last           =  w_mac1_cross_axi_data_last        ;
    assign     o_mac1_cross_metadata                =  w_mac1_cross_metadata             ; 
    assign     o_mac1_cross_metadata_valid          =  w_mac1_cross_metadata_valid       ; 
    assign     o_mac1_cross_metadata_last           =  w_mac1_cross_metadata_last        ; 
    assign     w_mac1_cross_metadata_ready          =  i_mac1_cross_metadata_ready       ;   

    assign     o_emac1_port_axi_data                =  w_emac1_port_axi_data             ; // �˿������������λ��ʾcrcerr
    assign     o_emac1_port_axi_user                =  w_emac1_port_axi_user             ;
    assign     o_emac1_axi_data_keep                =  w_emac1_axi_data_keep             ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac1_axi_data_valid               =  w_emac1_axi_data_valid            ; // �˿�������Ч
    assign     w_emac1_axi_data_ready               =  i_emac1_axi_data_ready            ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac1_axi_data_last                =  w_emac1_axi_data_last             ; // ������������ʶ 
    assign     o_emac1_metadata                     =  w_emac1_metadata                  ; // ���� metadata ����
    assign     o_emac1_metadata_valid               =  w_emac1_metadata_valid            ; // ���� metadata ������Ч�ź�
    assign     o_emac1_metadata_last                =  w_emac1_metadata_last             ; // ��Ϣ��������ʶ
    assign     w_emac1_metadata_ready               =  i_emac1_metadata_ready            ; // ����ģ�鷴ѹ��ˮ�� i
                         
`endif

`ifdef MAC2
    wire                                    w_mac2_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac2_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac2_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac2_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac2_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac2_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac2_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac2_axi_data_last                ; // ������������ʶ

    wire                                    w_mac2_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac2_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp2_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac2_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac2_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac2_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac2_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac2_cross_port_axi_user			;
    wire                                    w_mac2_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac2_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac2_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac2_cross_metadata              ; // �ۺ����� metadata ����
    wire                                    w_mac2_cross_metadata_valid        ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac2_cross_metadata_last         ; // ��Ϣ��������ʶ
    wire                                    w_mac2_cross_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac2                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac2_hash_key                    ; 
    wire   [47 : 0]                         w_dmac2                             ; 
    wire                                    w_dmac2_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac2_hash_key                    ; 
    wire   [47 : 0]                         w_smac2                             ; 
    wire                                    w_smac2_vld                         ; 
    // wire   [15:0]                           w_mac2_rtag_sequence                ;
    // wire                                    w_mac2_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac2_rtag_sequence            =   w_mac2_rtag_sequence             ;
    // assign      o_mac2_rtag_valid               =   w_mac2_rtag_valid                ;
    wire                                    w_mac2_rtag_flag                    ;
    wire   [15:0]                           w_mac2_rtag_squence                 ;
    wire   [7:0]                            w_mac2_stream_handle                ;

    wire   [15:0]                           w_hash_ploy_regs_2                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_2              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_2                   ;
    wire                                    w_port_rxmac_down_regs_2            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_2        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_2        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_2         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_2                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_2               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_2                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_2           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_2          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_2  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_2                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_2_valid				;
    wire                                    w_acl_clr_list_regs_2               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_2               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_2               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_c1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_c2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_c3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_c4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_c5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_c6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_c6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_c1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_c2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_c3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_c4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_c5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_c6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_c6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_c1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_c1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_c2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_c2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_c3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_c3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_c4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_c4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_c1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_c1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_c2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_c2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_c     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_c_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_c 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_c_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_c        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_c_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_c          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_c_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_2                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_2          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_2          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_2              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_2        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_2         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_2         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_2                ; // �˿�0�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_2               ; // �˿�0����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_2                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_2                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_2            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_2                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_2                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_2                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_2                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_2                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_2                       ; // ֡���
    wire                                    w_reset_2                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac2_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac2_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac2_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac2_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac2_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac2_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac2_metadata                    ; // ���� metadata ����
    wire                                    w_emac2_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac2_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac2_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
    assign      o_mac2_rtag_flag                =   w_mac2_rtag_flag                 ;
    assign      o_mac2_rtag_squence             =   w_mac2_rtag_squence              ;
    assign      o_mac2_stream_handle            =   w_mac2_stream_handle             ;


    assign      w_mac2_port_link                =   i_mac2_port_link                 ;  
    assign      w_mac2_port_speed               =   i_mac2_port_speed                ;  
    assign      w_mac2_port_filter_preamble_v   =   i_mac2_port_filter_preamble_v    ;  
    assign      w_mac2_axi_data                 =   i_mac2_axi_data                  ;  
    assign      w_mac2_axi_data_keep            =   i_mac2_axi_data_keep             ;  
    assign      w_mac2_axi_data_valid           =   i_mac2_axi_data_valid            ;            
    assign      o_mac2_axi_data_ready           =   w_mac2_axi_data_ready            ;
    assign      w_mac2_axi_data_last            =   i_mac2_axi_data_last             ;              
        
    assign      o_mac2_time_irq                 =   w_mac2_time_irq                  ;                   
    assign      o_mac2_frame_seq                =   w_mac2_frame_seq                 ;                     
    assign      o_timestamp2_addr               =   w_timestamp2_addr                ;      

    assign     o_mac2_cross_port_link               =  w_mac2_cross_port_link            ;
    assign     o_mac2_cross_port_speed              =  w_mac2_cross_port_speed           ;
    assign     o_mac2_cross_port_axi_data           =  w_mac2_cross_port_axi_data        ;
	assign 	   o_mac2_cross_port_axi_user			=  w_mac2_cross_port_axi_user		 ;
    assign     o_mac2_cross_axi_data_keep           =  w_mac2_cross_axi_data_keep        ;
    assign     o_mac2_cross_axi_data_valid          =  w_mac2_cross_axi_data_valid       ;
    assign     w_mac2_cross_axi_data_ready          =  i_mac2_cross_axi_data_ready       ; 
    assign     o_mac2_cross_axi_data_last           =  w_mac2_cross_axi_data_last        ;
    assign     o_mac2_cross_metadata                =  w_mac2_cross_metadata             ; 
    assign     o_mac2_cross_metadata_valid          =  w_mac2_cross_metadata_valid       ; 
    assign     o_mac2_cross_metadata_last           =  w_mac2_cross_metadata_last        ; 
    assign     w_mac2_cross_metadata_ready          =  i_mac2_cross_metadata_ready       ;                  

    assign     o_emac2_port_axi_data                =  w_emac2_port_axi_data             ; // �˿������������λ��ʾcrcerr
    assign     o_emac2_port_axi_user                =  w_emac2_port_axi_user             ;
    assign     o_emac2_axi_data_keep                =  w_emac2_axi_data_keep             ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac2_axi_data_valid               =  w_emac2_axi_data_valid            ; // �˿�������Ч
    assign     w_emac2_axi_data_ready               =  i_emac2_axi_data_ready            ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac2_axi_data_last                =  w_emac2_axi_data_last             ; // ������������ʶ 
    assign     o_emac2_metadata                     =  w_emac2_metadata                  ; // ���� metadata ����
    assign     o_emac2_metadata_valid               =  w_emac2_metadata_valid            ; // ���� metadata ������Ч�ź�
    assign     o_emac2_metadata_last                =  w_emac2_metadata_last             ; // ��Ϣ��������ʶ
    assign     w_emac2_metadata_ready               =  i_emac2_metadata_ready            ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC3
    wire                                    w_mac3_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac3_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac3_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac3_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac3_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac3_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac3_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac3_axi_data_last                ; // ������������ʶ

    wire                                    w_mac3_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac3_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp3_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac3_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac3_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac3_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac3_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac3_cross_port_axi_user			;
    wire                                    w_mac3_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac3_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac3_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac3_cross_metadata              ; // �ۺ����� metadata ����
    wire                                    w_mac3_cross_metadata_valid        ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac3_cross_metadata_last         ; // ��Ϣ��������ʶ
    wire                                    w_mac3_cross_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac3                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac3_hash_key                    ; 
    wire   [47 : 0]                         w_dmac3                             ; 
    wire                                    w_dmac3_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac3_hash_key                    ; 
    wire   [47 : 0]                         w_smac3                             ; 
    wire                                    w_smac3_vld                         ; 
    // wire   [15:0]                           w_mac3_rtag_sequence                ;
    // wire                                    w_mac3_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac3_rtag_sequence            =   w_mac3_rtag_sequence        ;
    // assign      o_mac3_rtag_valid               =   w_mac3_rtag_valid           ;
    wire                                    w_mac3_rtag_flag                    ;
    wire   [15:0]                           w_mac3_rtag_squence                 ;
    wire   [7:0]                            w_mac3_stream_handle                ;

    wire   [15:0]                           w_hash_ploy_regs_3                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_3              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_3                   ;
    wire                                    w_port_rxmac_down_regs_3            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_3        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_3        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_3         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_3                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_3               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_3                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_3           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_3          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_3  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_3                    ; // ѡ��Ҫ���õĶ˿�
	wire 									w_acl_port_sel_3_valid				;
    wire                                    w_acl_clr_list_regs_3               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_3               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_3               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_d1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_d2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_d3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_d4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_d5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_d6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_d6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_d1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_d2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_d3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_d4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_d5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_d6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_d6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_d1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_d1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_d2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_d2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_d3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_d3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_d4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_d4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_d1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_d1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_d2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_d2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_d     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_d_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_d 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_d_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_d        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_d_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_d          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_d_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_3                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_3          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_3          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_3              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_3        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_3         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_3         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_3                ; // �˿�3�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_3               ; // �˿�3����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_3                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_3                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_3            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_3                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_3                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_3                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_3                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_3                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_3                       ; // ֡���
    wire                                    w_reset_3                           ;
    wire   [CROSS_DATA_WIDTH-1:0]           w_emac3_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac3_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac3_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac3_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac3_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac3_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac3_metadata                    ; // ���� metadata ����
    wire                                    w_emac3_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac3_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac3_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
    assign      o_mac3_rtag_flag                =   w_mac3_rtag_flag                 ;
    assign      o_mac3_rtag_squence             =   w_mac3_rtag_squence              ;
    assign      o_mac3_stream_handle            =   w_mac3_stream_handle             ;


    assign      w_mac3_port_link                =   i_mac3_port_link             ;  
    assign      w_mac3_port_speed               =   i_mac3_port_speed            ;  
    assign      w_mac3_port_filter_preamble_v   =   i_mac3_port_filter_preamble_v;  
    assign      w_mac3_axi_data                 =   i_mac3_axi_data              ;  
    assign      w_mac3_axi_data_keep            =   i_mac3_axi_data_keep         ;  
    assign      w_mac3_axi_data_valid           =   i_mac3_axi_data_valid        ;            
    assign      o_mac3_axi_data_ready           =   w_mac3_axi_data_ready        ;
    assign      w_mac3_axi_data_last            =   i_mac3_axi_data_last         ;              
              
    assign      o_mac3_time_irq                 =   w_mac3_time_irq              ;                   
    assign      o_mac3_frame_seq                =   w_mac3_frame_seq             ;                     
    assign      o_timestamp3_addr               =   w_timestamp3_addr            ;   

    assign     o_mac3_cross_port_link           =  w_mac3_cross_port_link        ;
    assign     o_mac3_cross_port_speed          =  w_mac3_cross_port_speed       ;
    assign     o_mac3_cross_port_axi_data       =  w_mac3_cross_port_axi_data    ;
	assign 	   o_mac3_cross_port_axi_user		=  w_mac3_cross_port_axi_user	 ;
    assign     o_mac3_cross_axi_data_keep       =  w_mac3_cross_axi_data_keep    ;
    assign     o_mac3_cross_axi_data_valid      =  w_mac3_cross_axi_data_valid   ;
    assign     w_mac3_cross_axi_data_ready      =  i_mac3_cross_axi_data_ready   ; 
    assign     o_mac3_cross_axi_data_last       =  w_mac3_cross_axi_data_last    ;
    assign     o_mac3_cross_metadata            =  w_mac3_cross_metadata         ; 
    assign     o_mac3_cross_metadata_valid      =  w_mac3_cross_metadata_valid   ; 
    assign     o_mac3_cross_metadata_last       =  w_mac3_cross_metadata_last    ; 
    assign     w_mac3_cross_metadata_ready      =  i_mac3_cross_metadata_ready   ;    

    assign     o_emac3_port_axi_data            =  w_emac3_port_axi_data         ; // �˿������������λ��ʾcrcerr
    assign     o_emac3_port_axi_user            =  w_emac3_port_axi_user         ;
    assign     o_emac3_axi_data_keep            =  w_emac3_axi_data_keep         ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac3_axi_data_valid           =  w_emac3_axi_data_valid        ; // �˿�������Ч
    assign     w_emac3_axi_data_ready           =  i_emac3_axi_data_ready        ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac3_axi_data_last            =  w_emac3_axi_data_last         ; // ������������ʶ 
    assign     o_emac3_metadata                 =  w_emac3_metadata              ; // ���� metadata ����
    assign     o_emac3_metadata_valid           =  w_emac3_metadata_valid        ; // ���� metadata ������Ч�ź�
    assign     o_emac3_metadata_last            =  w_emac3_metadata_last         ; // ��Ϣ��������ʶ
    assign     w_emac3_metadata_ready           =  i_emac3_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC4
    wire                                    w_mac4_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac4_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac4_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac4_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac4_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac4_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac4_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac4_axi_data_last                ; // ������������ʶ

    wire                                    w_mac4_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac4_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp4_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac4_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac4_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac4_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac4_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac4_cross_port_axi_user			;
    wire                                    w_mac4_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac4_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac4_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac4_cross_metadata                   ; // �ۺ����� metadata ����
    wire                                    w_mac4_cross_metadata_valid             ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac4_cross_metadata_last              ; // ��Ϣ��������ʶ
    wire                                    w_mac4_cross_metadata_ready             ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac4                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac4_hash_key                    ; 
    wire   [47 : 0]                         w_dmac4                             ; 
    wire                                    w_dmac4_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac4_hash_key                    ; 
    wire   [47 : 0]                         w_smac4                             ; 
    wire                                    w_smac4_vld                         ; 
    // wire   [15:0]                           w_mac4_rtag_sequence                ;
    // wire                                    w_mac4_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac4_rtag_sequence            =   w_mac4_rtag_sequence             ;
    // assign      o_mac4_rtag_valid               =   w_mac4_rtag_valid                ;
    wire                                    w_mac4_rtag_flag                    ;
    wire   [15:0]                           w_mac4_rtag_squence                 ;
    wire   [7:0]                            w_mac4_stream_handle                ;

    wire   [15:0]                           w_hash_ploy_regs_4                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_4              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_4                   ;
    wire                                    w_port_rxmac_down_regs_4            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_4        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_4        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_4         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_4                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_4               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_4                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_4           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_4          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_4  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_4                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_4_valid				;
    wire                                    w_acl_clr_list_regs_4               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_4               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_4               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_e1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_e2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_e3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_e4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_e5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_e6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_e6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_e1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_e2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_e3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_e4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_e5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_e6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_e6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_e1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_e1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_e2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_e2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_e3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_e3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_e4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_e4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_e1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_e1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_e2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_e2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_e     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_e_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_e 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_e_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_e        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_e_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_e          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_e_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_4                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_4          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_4          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_4              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_4        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_4         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_4         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_4                ; // �˿�4�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_4               ; // �˿�4����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_4                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_4                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_4            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_4                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_4                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_4                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_4                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_4                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_4                       ; // ֡���
    wire                                    w_reset_4                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac4_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac4_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac4_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac4_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac4_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac4_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac4_metadata                    ; // ���� metadata ����
    wire                                    w_emac4_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac4_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac4_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����

    assign      o_mac4_rtag_flag                =   w_mac4_rtag_flag                 ;
    assign      o_mac4_rtag_squence             =   w_mac4_rtag_squence              ;
    assign      o_mac4_stream_handle            =   w_mac4_stream_handle             ;


    assign      w_mac4_port_link                =   i_mac4_port_link             ;  
    assign      w_mac4_port_speed               =   i_mac4_port_speed            ;  
    assign      w_mac4_port_filter_preamble_v   =   i_mac4_port_filter_preamble_v;  
    assign      w_mac4_axi_data                 =   i_mac4_axi_data              ;  
    assign      w_mac4_axi_data_keep            =   i_mac4_axi_data_keep         ;  
    assign      w_mac4_axi_data_valid           =   i_mac4_axi_data_valid        ;            
    assign      o_mac4_axi_data_ready           =   w_mac4_axi_data_ready        ;
    assign      w_mac4_axi_data_last            =   i_mac4_axi_data_last         ;              
              
    assign      o_mac4_time_irq                 =   w_mac4_time_irq              ;                   
    assign      o_mac4_frame_seq                =   w_mac4_frame_seq             ;                     
    assign      o_timestamp4_addr               =   w_timestamp4_addr            ;  

    assign     o_mac4_cross_port_link           =  w_mac4_cross_port_link            ;
    assign     o_mac4_cross_port_speed          =  w_mac4_cross_port_speed           ;
    assign     o_mac4_cross_port_axi_data       =  w_mac4_cross_port_axi_data        ;
	assign     o_mac4_cross_port_axi_user		=  w_mac4_cross_port_axi_user		 ;
    assign     o_mac4_cross_axi_data_keep       =  w_mac4_cross_axi_data_keep        ;
    assign     o_mac4_cross_axi_data_valid      =  w_mac4_cross_axi_data_valid       ;
    assign     w_mac4_cross_axi_data_ready      =  i_mac4_cross_axi_data_ready       ; 
    assign     o_mac4_cross_axi_data_last       =  w_mac4_cross_axi_data_last        ;
    assign     o_mac4_cross_metadata            =  w_mac4_cross_metadata             ; 
    assign     o_mac4_cross_metadata_valid      =  w_mac4_cross_metadata_valid       ; 
    assign     o_mac4_cross_metadata_last       =  w_mac4_cross_metadata_last        ; 
    assign     w_mac4_cross_metadata_ready      =  i_mac4_cross_metadata_ready       ;  

    assign     o_emac4_port_axi_data            =  w_emac4_port_axi_data         ; // �˿������������λ��ʾcrcerr
    assign     o_emac4_port_axi_user            =  w_emac4_port_axi_user         ;
    assign     o_emac4_axi_data_keep            =  w_emac4_axi_data_keep         ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac4_axi_data_valid           =  w_emac4_axi_data_valid        ; // �˿�������Ч
    assign     w_emac4_axi_data_ready           =  i_emac4_axi_data_ready        ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac4_axi_data_last            =  w_emac4_axi_data_last         ; // ������������ʶ 
    assign     o_emac4_metadata                 =  w_emac4_metadata              ; // ���� metadata ����
    assign     o_emac4_metadata_valid           =  w_emac4_metadata_valid        ; // ���� metadata ������Ч�ź�
    assign     o_emac4_metadata_last            =  w_emac4_metadata_last         ; // ��Ϣ��������ʶ
    assign     w_emac4_metadata_ready           =  i_emac4_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC5
    wire                                    w_mac5_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac5_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac5_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac5_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac5_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac5_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac5_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac5_axi_data_last                ; // ������������ʶ

    wire                                    w_mac5_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac5_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp5_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac5_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac5_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac5_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac5_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac5_cross_port_axi_user			;
    wire                                    w_mac5_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac5_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac5_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac5_cross_metadata                   ; // �ۺ����� metadata ����
    wire                                    w_mac5_cross_metadata_valid             ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac5_cross_metadata_last              ; // ��Ϣ��������ʶ
    wire                                    w_mac5_cross_metadata_ready             ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac5                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac5_hash_key                    ; 
    wire   [47 : 0]                         w_dmac5                             ; 
    wire                                    w_dmac5_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac5_hash_key                    ; 
    wire   [47 : 0]                         w_smac5                             ; 
    wire                                    w_smac5_vld                         ; 
    // wire   [15:0]                           w_mac5_rtag_sequence                ;
    // wire                                    w_mac5_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac5_rtag_sequence            =   w_mac5_rtag_sequence             ;
    // assign      o_mac5_rtag_valid               =   w_mac5_rtag_valid                ;
    wire                                    w_mac5_rtag_flag                    ;
    wire   [15:0]                           w_mac5_rtag_squence                 ;
    wire   [7:0]                            w_mac5_stream_handle                ;

    wire   [15:0]                           w_hash_ploy_regs_5                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_5              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_5                   ;
    wire                                    w_port_rxmac_down_regs_5            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_5        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_5        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_5         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_5                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_5               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_5                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_5           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_5          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_5  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_5                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_5_valid				;
    wire                                    w_acl_clr_list_regs_5               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_5               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_5               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_f1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_f2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_f3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_f4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_f5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_f6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_f6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_f1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_f2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_f3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_f4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_f5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_f6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_f6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_f1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_f1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_f2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_f2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_f3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_f3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_f4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_f4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_f1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_f1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_f2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_f2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_f     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_f_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_f 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_f_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_f        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_f_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_f          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_f_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_5                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_5          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_5          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_5              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_5        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_5         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_5         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_5                ; // �˿�5�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_5               ; // �˿�5����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_5                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_5                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_5            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_5                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_5                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_5                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_5                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_5                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_5                       ; // ֡���
    wire                                    w_reset_5                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac5_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac5_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac5_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac5_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac5_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac5_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac5_metadata                    ; // ���� metadata ����
    wire                                    w_emac5_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac5_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac5_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����

    assign      o_mac5_rtag_flag                =   w_mac5_rtag_flag                 ;
    assign      o_mac5_rtag_squence             =   w_mac5_rtag_squence              ;
    assign      o_mac5_stream_handle            =   w_mac5_stream_handle             ;


    assign      w_mac5_port_link                =   i_mac5_port_link             ;  
    assign      w_mac5_port_speed               =   i_mac5_port_speed            ;  
    assign      w_mac5_port_filter_preamble_v   =   i_mac5_port_filter_preamble_v;  
    assign      w_mac5_axi_data                 =   i_mac5_axi_data              ;  
    assign      w_mac5_axi_data_keep            =   i_mac5_axi_data_keep         ;  
    assign      w_mac5_axi_data_valid           =   i_mac5_axi_data_valid        ;            
    assign      o_mac5_axi_data_ready           =   w_mac5_axi_data_ready        ;
    assign      w_mac5_axi_data_last            =   i_mac5_axi_data_last         ;              
             
    assign      o_mac5_time_irq                 =   w_mac5_time_irq              ;                   
    assign      o_mac5_frame_seq                =   w_mac5_frame_seq             ;                     
    assign      o_timestamp5_addr               =   w_timestamp5_addr            ;  

    assign     o_mac5_cross_port_link               =  w_mac5_cross_port_link            ;
    assign     o_mac5_cross_port_speed              =  w_mac5_cross_port_speed           ;
    assign     o_mac5_cross_port_axi_data           =  w_mac5_cross_port_axi_data        ;
	assign 	   o_mac5_cross_port_axi_user			=  w_mac5_cross_port_axi_user		 ;
    assign     o_mac5_cross_axi_data_keep           =  w_mac5_cross_axi_data_keep        ;
    assign     o_mac5_cross_axi_data_valid          =  w_mac5_cross_axi_data_valid       ;
    assign     w_mac5_cross_axi_data_ready          =  i_mac5_cross_axi_data_ready       ; 
    assign     o_mac5_cross_axi_data_last           =  w_mac5_cross_axi_data_last        ;
    assign     o_mac5_cross_metadata                =  w_mac5_cross_metadata             ; 
    assign     o_mac5_cross_metadata_valid          =  w_mac5_cross_metadata_valid       ; 
    assign     o_mac5_cross_metadata_last           =  w_mac5_cross_metadata_last        ; 
    assign     w_mac5_cross_metadata_ready          =  i_mac5_cross_metadata_ready       ;  

    assign     o_emac5_port_axi_data            =  w_emac5_port_axi_data         ; // �˿������������λ��ʾcrcerr
    assign     o_emac5_port_axi_user            =  w_emac5_port_axi_user         ;
    assign     o_emac5_axi_data_keep            =  w_emac5_axi_data_keep         ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac5_axi_data_valid           =  w_emac5_axi_data_valid        ; // �˿�������Ч
    assign     w_emac5_axi_data_ready           =  i_emac5_axi_data_ready        ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac5_axi_data_last            =  w_emac5_axi_data_last         ; // ������������ʶ 
    assign     o_emac5_metadata                 =  w_emac5_metadata              ; // ���� metadata ����
    assign     o_emac5_metadata_valid           =  w_emac5_metadata_valid        ; // ���� metadata ������Ч�ź�
    assign     o_emac5_metadata_last            =  w_emac5_metadata_last         ; // ��Ϣ��������ʶ
    assign     w_emac5_metadata_ready           =  i_emac5_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC6
    wire                                    w_mac6_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac6_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac6_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac6_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac6_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac6_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac6_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac6_axi_data_last                ; // ������������ʶ

    wire                                    w_mac6_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac6_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp6_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac6_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac6_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac6_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac6_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac6_cross_port_axi_user			;
    wire                                    w_mac6_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac6_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac6_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac6_cross_metadata               ; // �ۺ����� metadata ����
    wire                                    w_mac6_cross_metadata_valid         ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac6_cross_metadata_last          ; // ��Ϣ��������ʶ
    wire                                    w_mac6_cross_metadata_ready         ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac6                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac6_hash_key                    ; 
    wire   [47 : 0]                         w_dmac6                             ; 
    wire                                    w_dmac6_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac6_hash_key                    ; 
    wire   [47 : 0]                         w_smac6                             ; 
    wire                                    w_smac6_vld                         ; 
    // wire   [15:0]                           w_mac6_rtag_sequence                ;
    // wire                                    w_mac6_rtag_valid                   ;
    // // ��������ź� assign ����
    // assign      o_mac6_rtag_sequence            =   w_mac6_rtag_sequence        ;
    // assign      o_mac6_rtag_valid               =   w_mac6_rtag_valid           ;
    wire                                    w_mac6_rtag_flag                    ;
    wire   [15:0]                           w_mac6_rtag_squence                 ;
    wire   [7:0]                            w_mac6_stream_handle                ;
    wire   [15:0]                           w_hash_ploy_regs_6                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_6              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_6                   ;
    wire                                    w_port_rxmac_down_regs_6            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_6        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_6        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_6         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_6                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_6               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_6                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_6           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_6          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_6  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_6                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_6_valid				;
    wire                                    w_acl_clr_list_regs_6               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_6               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_6               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_g1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_g2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_g3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_g4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_g5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_g6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_g6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_g1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_g2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_g3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_g4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_g5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_g6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_g6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_g1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_g1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_g2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_g2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_g3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_g3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_g4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_g4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_g1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_g1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_g2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_g2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_g     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_g_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_g 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_g_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_g        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_g_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_g          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_g_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_6                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_6          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_6          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_6              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_6        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_6         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_6         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_6                ; // �˿�6�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_6               ; // �˿�6����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_6                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_6                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_6            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_6                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_6                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_6                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_6                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_6                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_6                       ; // ֡���
    wire                                    w_reset_6                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac6_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac6_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac6_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac6_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac6_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac6_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac6_metadata                    ; // ���� metadata ����
    wire                                    w_emac6_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac6_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac6_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
    assign      o_mac6_rtag_flag                =   w_mac6_rtag_flag             ;
    assign      o_mac6_rtag_squence             =   w_mac6_rtag_squence          ;
    assign      o_mac6_stream_handle            =   w_mac6_stream_handle         ;


    assign      w_mac6_port_link                =   i_mac6_port_link             ;  
    assign      w_mac6_port_speed               =   i_mac6_port_speed            ;  
    assign      w_mac6_port_filter_preamble_v   =   i_mac6_port_filter_preamble_v;  
    assign      w_mac6_axi_data                 =   i_mac6_axi_data              ;  
    assign      w_mac6_axi_data_keep            =   i_mac6_axi_data_keep         ;  
    assign      w_mac6_axi_data_valid           =   i_mac6_axi_data_valid        ;            
    assign      o_mac6_axi_data_ready           =   w_mac6_axi_data_ready        ;
    assign      w_mac6_axi_data_last            =   i_mac6_axi_data_last         ;              

    assign      o_mac6_time_irq                 =   w_mac6_time_irq              ;                   
    assign      o_mac6_frame_seq                =   w_mac6_frame_seq             ;                     
    assign      o_timestamp6_addr               =   w_timestamp6_addr            ;  

    assign     o_mac6_cross_port_link           =  w_mac6_cross_port_link        ;
    assign     o_mac6_cross_port_speed          =  w_mac6_cross_port_speed       ;
    assign     o_mac6_cross_port_axi_data       =  w_mac6_cross_port_axi_data    ;
	assign     o_mac6_cross_port_axi_user		=  w_mac6_cross_port_axi_user    ;
    assign     o_mac6_cross_axi_data_keep       =  w_mac6_cross_axi_data_keep    ;
    assign     o_mac6_cross_axi_data_valid      =  w_mac6_cross_axi_data_valid   ;
    assign     w_mac6_cross_axi_data_ready      =  i_mac6_cross_axi_data_ready   ; 
    assign     o_mac6_cross_axi_data_last       =  w_mac6_cross_axi_data_last    ;
    assign     o_mac6_cross_metadata            =  w_mac6_cross_metadata         ; 
    assign     o_mac6_cross_metadata_valid      =  w_mac6_cross_metadata_valid   ; 
    assign     o_mac6_cross_metadata_last       =  w_mac6_cross_metadata_last    ; 
    assign     w_mac6_cross_metadata_ready      =  i_mac6_cross_metadata_ready   ; 

    assign     o_emac6_port_axi_data            =  w_emac6_port_axi_data         ; // �˿������������λ��ʾcrcerr
    assign     o_emac6_port_axi_user            =  w_emac6_port_axi_user         ;
    assign     o_emac6_axi_data_keep            =  w_emac6_axi_data_keep         ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac6_axi_data_valid           =  w_emac6_axi_data_valid        ; // �˿�������Ч
    assign     w_emac6_axi_data_ready           =  i_emac6_axi_data_ready        ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac6_axi_data_last            =  w_emac6_axi_data_last         ; // ������������ʶ 
    assign     o_emac6_metadata                 =  w_emac6_metadata              ; // ���� metadata ����
    assign     o_emac6_metadata_valid           =  w_emac6_metadata_valid        ; // ���� metadata ������Ч�ź�
    assign     o_emac6_metadata_last            =  w_emac6_metadata_last         ; // ��Ϣ��������ʶ
    assign     w_emac6_metadata_ready           =  i_emac6_metadata_ready        ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef MAC7
    wire                                    w_mac7_port_link                    ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac7_port_speed                   ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
    wire                                    w_mac7_port_filter_preamble_v       ; // �˿��Ƿ����ǰ������Ϣ
    wire   [PORT_MNG_DATA_WIDTH-1:0]        w_mac7_axi_data                     ; // �˿�������
    wire   [(PORT_MNG_DATA_WIDTH/8)-1:0]    w_mac7_axi_data_keep                ; // �˿�����������,��Ч�ֽ�ָʾ
    wire                                    w_mac7_axi_data_valid               ; // �˿�������Ч
    wire                                    w_mac7_axi_data_ready               ; // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
    wire                                    w_mac7_axi_data_last                ; // ������������ʶ

    wire                                    w_mac7_time_irq                     ; // ��ʱ����ж��ź�
    wire  [7:0]                             w_mac7_frame_seq                    ; // ֡���к�
    wire  [7:0]                             w_timestamp7_addr                   ; // ��ʱ����洢�� RAM ��ַ

    wire                                    w_mac7_cross_port_link              ; // �˿ڵ�����״̬
    wire   [1:0]                            w_mac7_cross_port_speed             ; // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
    wire   [CROSS_DATA_WIDTH-1:0]           w_mac7_cross_port_axi_data          ; // �˿�������,���λ��ʾcrcerr
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_mac7_cross_axi_data_keep          ; // �˿�����������,��Ч�ֽ�ָʾ
	wire   [15:0]							w_mac7_cross_port_axi_user			;
    wire                                    w_mac7_cross_axi_data_valid         ; // �˿�������Ч
    wire                                    w_mac7_cross_axi_data_ready         ; // �������߾ۺϼܹ���ѹ��ˮ���ź�
    wire                                    w_mac7_cross_axi_data_last          ; // ������������ʶ
    wire   [METADATA_WIDTH-1:0]             w_mac7_cross_metadata               ; // �ۺ����� metadata ����
    wire                                    w_mac7_cross_metadata_valid         ; // �ۺ����� metadata ������Ч�ź�
    wire                                    w_mac7_cross_metadata_last          ; // ��Ϣ��������ʶ
    wire                                    w_mac7_cross_metadata_ready         ; // ����ģ�鷴ѹ��ˮ�� 

    wire   [11:0]                           w_vlan_id_mac7                      ;
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_dmac7_hash_key                    ; 
    wire   [47 : 0]                         w_dmac7                             ; 
    wire                                    w_dmac7_vld                         ; 
    wire   [HASH_DATA_WIDTH - 1 : 0]        w_smac7_hash_key                    ; 
    wire   [47 : 0]                         w_smac7                             ; 
    wire                                    w_smac7_vld                         ; 
    // wire   [15:0]                           w_mac7_rtag_sequence                ;
    // wire                                    w_mac7_rtag_valid                   ;

    wire                                    w_mac7_rtag_flag                    ;
    wire   [15:0]                           w_mac7_rtag_squence                 ;
    wire   [7:0]                            w_mac7_stream_handle                ;
    wire   [15:0]                           w_hash_ploy_regs_7                  ; // ��ϣ����ʽ
    wire   [15:0]                           w_hash_init_val_regs_7              ; // ��ϣ����ʽ��ʼֵ
    wire                                    w_hash_regs_vld_7                   ;
    wire                                    w_port_rxmac_down_regs_7            ; // �˿ڽ��շ���MAC�ر�ʹ��
    wire                                    w_port_broadcast_drop_regs_7        ; // �˿ڹ㲥֡����ʹ��
    wire                                    w_port_multicast_drop_regs_7        ; // �˿��鲥֡����ʹ��
    wire                                    w_port_loopback_drop_regs_7         ; // �˿ڻ���֡����ʹ��
    wire   [47:0]                           w_port_mac_regs_7                   ; // �˿ڵ� MAC ��ַ
    wire                                    w_port_mac_vld_regs_7               ; // ʹ�ܶ˿� MAC ��ַ��Ч
    wire   [7:0]                            w_port_mtu_regs_7                   ; // MTU����ֵ
    wire   [PORT_NUM-1:0]                   w_port_mirror_frwd_regs_7           ; // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
    wire   [15:0]                           w_port_flowctrl_cfg_regs_7          ; // ������������
    wire   [4:0]                            w_port_rx_ultrashortinterval_num_7  ; // ֡���
    // ACL �Ĵ���
    wire   [6-1:0]                   		w_acl_port_sel_7                    ; // ѡ��Ҫ���õĶ˿�
	wire									w_acl_port_sel_7_valid				;
    wire                                    w_acl_clr_list_regs_7               ; // ��ռĴ����б�
    wire                                    w_acl_list_rdy_regs_7               ; // ���üĴ�����������
    wire   [4:0]                            w_acl_item_sel_regs_7               ; // ������Ŀѡ��
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h1            			; // �˿�ACL����-д��dmacֵ[15:0]
	wire                               		w_cfg_acl_item_dmac_code_h1_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h2            			; // �˿�ACL����-д��dmacֵ[31:16]
	wire                               		w_cfg_acl_item_dmac_code_h2_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h3            			; // �˿�ACL����-д��dmacֵ[47:32]
	wire                               		w_cfg_acl_item_dmac_code_h3_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h4            			; // �˿�ACL����-д��dmacֵ[63:48]
	wire                               		w_cfg_acl_item_dmac_code_h4_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h5            			; // �˿�ACL����-д��dmacֵ[79:64]
	wire                               		w_cfg_acl_item_dmac_code_h5_valid      			; // д����Ч�ź�						
	wire   [15:0]                      		w_cfg_acl_item_dmac_code_h6            			; // �˿�ACL����-д��dmacֵ[95:80]
	wire                               		w_cfg_acl_item_dmac_code_h6_valid      			; // д����Ч�ź�	
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h1            			; // �˿�ACL����-д��smacֵ[15:0]
	wire                               		w_cfg_acl_item_smac_code_h1_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h2            			; // �˿�ACL����-д��smacֵ[31:16]
	wire                               		w_cfg_acl_item_smac_code_h2_valid      			; // д����Ч�ź�						                     
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h3            			; // �˿�ACL����-д��smacֵ[47:32]
	wire                               		w_cfg_acl_item_smac_code_h3_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h4            			; // �˿�ACL����-д��smacֵ[63:48]
	wire                               		w_cfg_acl_item_smac_code_h4_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h5            			; // �˿�ACL����-д��smacֵ[79:64]
	wire                               		w_cfg_acl_item_smac_code_h5_valid      			; // д����Ч�ź�						                 
	wire   [15:0]                      		w_cfg_acl_item_smac_code_h6            			; // �˿�ACL����-д��smacֵ[95:80]
	wire                               		w_cfg_acl_item_smac_code_h6_valid      			; // д����Ч�ź�	
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_h1            			; // �˿�ACL����-д��vlanֵ[15:0]
	wire                                	w_cfg_acl_item_vlan_code_h1_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_h2            			; // �˿�ACL����-д��vlanֵ[31:16]
	wire                                	w_cfg_acl_item_vlan_code_h2_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_h3            			; // �˿�ACL����-д��vlanֵ[47:32]
	wire                                	w_cfg_acl_item_vlan_code_h3_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_vlan_code_h4            			; // �˿�ACL����-д��vlanֵ[63:48]
	wire                                	w_cfg_acl_item_vlan_code_h4_valid      			; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_h1       			; // �˿�ACL����-д��ethertypeֵ[15:0]
	wire                                	w_cfg_acl_item_ethertype_code_h1_valid 			; // д����Ч�ź�						                          
	wire   [15:0]                       	w_cfg_acl_item_ethertype_code_h2       			; // �˿�ACL����-д��ethertypeֵ[31:16]
	wire                                	w_cfg_acl_item_ethertype_code_h2_valid 			; // д����Ч�ź�						                                                     		                                          
	wire   [7:0]                        	w_cfg_acl_item_action_pass_state_h     			; // �˿�ACL����-����״̬
	wire                                	w_cfg_acl_item_action_pass_state_h_valid		; // д����Ч�ź�							                          
	wire   [15:0]                       	w_cfg_acl_item_action_cb_streamhandle_h 		; // �˿�ACL����-stream_handleֵ
	wire                                	w_cfg_acl_item_action_cb_streamhandle_h_valid	; // д����Ч�ź�						
	wire   [5:0]                        	w_cfg_acl_item_action_flowctrl_h        		; // �˿�ACL����-��������ѡ��
	wire                                	w_cfg_acl_item_action_flowctrl_h_valid  		; // д����Ч�ź�						
	wire   [15:0]                       	w_cfg_acl_item_action_txport_h          		; // �˿�ACL����-���ķ��Ͷ˿�ӳ��
	wire                                	w_cfg_acl_item_action_txport_h_valid      		; // д����Ч�ź�
    // ״̬�Ĵ���
    wire   [15:0]                           w_port_diag_state_7                 ; // �˿�״̬�Ĵ���,������Ĵ�����˵������
    // ��ϼĴ���
    wire                                    w_port_rx_ultrashort_frm_7          ; // �˿ڽ��ճ���֡(С��64�ֽ�)
    wire                                    w_port_rx_overlength_frm_7          ; // �˿ڽ��ճ���֡(����MTU�ֽ�)
    wire                                    w_port_rx_crcerr_frm_7              ; // �˿ڽ���CRC����֡
    wire   [15:0]                           w_port_rx_loopback_frm_cnt_7        ; // �˿ڽ��ջ���֡������ֵ
    wire   [15:0]                           w_port_broadflow_drop_cnt_7         ; // �˿ڽ��յ��㲥������������֡������ֵ
    wire   [15:0]                           w_port_multiflow_drop_cnt_7         ; // �˿ڽ��յ��鲥������������֡������ֵ
    // ����ͳ�ƼĴ���
    wire   [15:0]                           w_port_rx_byte_cnt_7                ; // �˿�7�����ֽڸ���������ֵ
    wire   [15:0]                           w_port_rx_frame_cnt_7               ; // �˿�7����֡����������ֵ
    //qbu_rx�Ĵ���
    wire                                    w_rx_busy_7                         ; // ����æ�ź�
    wire   [15:0]                           w_rx_fragment_cnt_7                 ; // ���շ�Ƭ����
    wire                                    w_rx_fragment_mismatch_7            ; // ��Ƭ��ƥ��
    wire   [15:0]                           w_err_rx_crc_cnt_7                  ; // CRC�������
    wire   [15:0]                           w_err_rx_frame_cnt_7                ; // ֡�������
    wire   [15:0]                           w_err_fragment_cnt_7                ; // ��Ƭ�������
    wire   [15:0]                           w_rx_frames_cnt_7                   ; // ����֡����
    wire   [7:0]                            w_frag_next_rx_7                    ; // ��һ����Ƭ��
    wire   [7:0]                            w_frame_seq_7                       ; // ֡���
    wire                                    w_reset_7                           ;

    wire   [CROSS_DATA_WIDTH-1:0]           w_emac7_port_axi_data               ; // �˿������������λ��ʾcrcerr
    wire   [15:0]                           w_emac7_port_axi_user               ;
    wire   [(CROSS_DATA_WIDTH/8)-1:0]       w_emac7_axi_data_keep               ; // �˿����������룬��Ч�ֽ�ָʾ
    wire                                    w_emac7_axi_data_valid              ; // �˿�������Ч
    wire                                    w_emac7_axi_data_ready              ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    wire                                    w_emac7_axi_data_last               ; // ������������ʶ 
    wire   [METADATA_WIDTH-1:0]             w_emac7_metadata                    ; // ���� metadata ����
    wire                                    w_emac7_metadata_valid              ; // ���� metadata ������Ч�ź�
    wire                                    w_emac7_metadata_last               ; // ��Ϣ��������ʶ
    wire                                    w_emac7_metadata_ready              ; // ����ģ�鷴ѹ��ˮ�� i
    // ��������ź� assign ����
   
    assign      o_mac7_rtag_flag                =   w_mac7_rtag_flag                 ;
    assign      o_mac7_rtag_squence             =   w_mac7_rtag_squence              ;
    assign      o_mac7_stream_handle            =   w_mac7_stream_handle             ;

    assign      w_mac7_port_link                =   i_mac7_port_link                 ;  
    assign      w_mac7_port_speed               =   i_mac7_port_speed                ;  
    assign      w_mac7_port_filter_preamble_v   =   i_mac7_port_filter_preamble_v    ;  
    assign      w_mac7_axi_data                 =   i_mac7_axi_data                  ;  
    assign      w_mac7_axi_data_keep            =   i_mac7_axi_data_keep             ;  
    assign      w_mac7_axi_data_valid           =   i_mac7_axi_data_valid            ;            
    assign      o_mac7_axi_data_ready           =   w_mac7_axi_data_ready            ;
    assign      w_mac7_axi_data_last            =   i_mac7_axi_data_last             ;              
                     
    assign      o_mac7_time_irq                 =   w_mac7_time_irq                  ;                   
    assign      o_mac7_frame_seq                =   w_mac7_frame_seq                 ;                     
    assign      o_timestamp7_addr               =   w_timestamp7_addr                ;  

    assign     o_mac7_cross_port_link           =  w_mac7_cross_port_link            ;
    assign     o_mac7_cross_port_speed          =  w_mac7_cross_port_speed           ;
    assign     o_mac7_cross_port_axi_data       =  w_mac7_cross_port_axi_data        ;
	assign     o_mac7_cross_port_axi_user		=  w_mac7_cross_port_axi_user		 ;
    assign     o_mac7_cross_axi_data_keep       =  w_mac7_cross_axi_data_keep        ;
    assign     o_mac7_cross_axi_data_valid      =  w_mac7_cross_axi_data_valid       ;
    assign     w_mac7_cross_axi_data_ready      =  i_mac7_cross_axi_data_ready       ; 
    assign     o_mac7_cross_axi_data_last       =  w_mac7_cross_axi_data_last        ;
    assign     o_mac7_cross_metadata            =  w_mac7_cross_metadata             ; 
    assign     o_mac7_cross_metadata_valid      =  w_mac7_cross_metadata_valid       ; 
    assign     o_mac7_cross_metadata_last       =  w_mac7_cross_metadata_last        ; 
    assign     w_mac7_cross_metadata_ready      =  i_mac7_cross_metadata_ready       ; 

    assign     o_emac7_port_axi_data            =  w_emac7_port_axi_data             ; // �˿������������λ��ʾcrcerr
    assign     o_emac7_port_axi_user            =  w_emac7_port_axi_user             ;
    assign     o_emac7_axi_data_keep            =  w_emac7_axi_data_keep             ; // �˿����������룬��Ч�ֽ�ָʾ
    assign     o_emac7_axi_data_valid           =  w_emac7_axi_data_valid            ; // �˿�������Ч
    assign     w_emac7_axi_data_ready           =  i_emac7_axi_data_ready            ; // �������߾ۺϼܹ���ѹ��ˮ���ź� i
    assign     o_emac7_axi_data_last            =  w_emac7_axi_data_last             ; // ������������ʶ 
    assign     o_emac7_metadata                 =  w_emac7_metadata                  ; // ���� metadata ����
    assign     o_emac7_metadata_valid           =  w_emac7_metadata_valid            ; // ���� metadata ������Ч�ź�
    assign     o_emac7_metadata_last            =  w_emac7_metadata_last             ; // ��Ϣ��������ʶ
    assign     w_emac7_metadata_ready           =  i_emac7_metadata_ready            ; // ����ģ�鷴ѹ��ˮ�� i
`endif

`ifdef END_POINTER_SWITCH_CORE
    `ifdef CPU_MAC
        // ��������ź� assign ����
        assign      o_vlan_id_cpu           =   w_vlan_id_cpu                       ;
        assign      o_dmac_cpu_hash_key     =   w_dmac_cpu_hash_key                 ;
        assign      o_dmac_cpu              =   w_dmac_cpu                          ;
        assign      o_dmac_cpu_vld          =   w_dmac_cpu_vld                      ;
        assign      o_smac_cpu_hash_key     =   w_smac_cpu_hash_key                 ;
        assign      o_smac_cpu              =   w_smac_cpu                          ;
        assign      o_smac_cpu_vld          =   w_smac_cpu_vld                      ;
    `endif
    `ifdef MAC1
        // ��������ź� assign ����
        assign      o_vlan_id1            	=   w_vlan_id_mac1                   	;
        assign      o_dmac1_hash_key        =   w_dmac1_hash_key                 	;
        assign      o_dmac1                 =   w_dmac1                          	;
        assign      o_dmac1_vld             =   w_dmac1_vld                      	;
        assign      o_smac1_hash_key        =   w_smac1_hash_key                 	;
        assign      o_smac1                 =   w_smac1                          	;
        assign      o_smac1_vld             =   w_smac1_vld                      	;
    `endif
    `ifdef MAC2	
        // ��������ź� assign ����
        assign      o_vlan_id2             	=   w_vlan_id_mac2                   	;
        assign      o_dmac2_hash_key       	=   w_dmac2_hash_key                 	;
        assign      o_dmac2                	=   w_dmac2                          	;
        assign      o_dmac2_vld            	=   w_dmac2_vld                      	;
        assign      o_smac2_hash_key       	=   w_smac2_hash_key                 	;
        assign      o_smac2                	=   w_smac2                          	;
        assign      o_smac2_vld            	=   w_smac2_vld                      	;
    `endif
    `ifdef MAC3	
        // ��������ź� assign ����
        assign      o_vlan_id3             	=   w_vlan_id_mac3                   	;
        assign      o_dmac3_hash_key       	=   w_dmac3_hash_key            		;
        assign      o_dmac3                	=   w_dmac3                     		;
        assign      o_dmac3_vld            	=   w_dmac3_vld                 		;
        assign      o_smac3_hash_key       	=   w_smac3_hash_key            		;
        assign      o_smac3                	=   w_smac3                     		;
        assign      o_smac3_vld            	=   w_smac3_vld                 		;
    `endif
    `ifdef MAC4 
        // ��������ź� assign ����
        assign      o_vlan_id4              =   w_vlan_id_mac4                   	;
        assign      o_dmac4_hash_key        =   w_dmac4_hash_key                 	;
        assign      o_dmac4                 =   w_dmac4                          	;
        assign      o_dmac4_vld             =   w_dmac4_vld                      	;
        assign      o_smac4_hash_key        =   w_smac4_hash_key                 	;
        assign      o_smac4                 =   w_smac4                          	;
        assign      o_smac4_vld             =   w_smac4_vld                      	;
    `endif
    `ifdef MAC5
        // ��������ź� assign ����
        assign      o_vlan_id5              =   w_vlan_id_mac5                   	;
        assign      o_dmac5_hash_key        =   w_dmac5_hash_key                 	;
        assign      o_dmac5                 =   w_dmac5                          	;
        assign      o_dmac5_vld             =   w_dmac5_vld                      	;
        assign      o_smac5_hash_key        =   w_smac5_hash_key                 	;
        assign      o_smac5                 =   w_smac5                          	;
        assign      o_smac5_vld             =   w_smac5_vld                      	;
    `endif
    `ifdef MAC6
        // ��������ź� assign ����
        assign      o_vlan_id6              =   w_vlan_id_mac6                   	;
        assign      o_dmac6_hash_key        =   w_dmac6_hash_key    				;
        assign      o_dmac6                 =   w_dmac6             				;
        assign      o_dmac6_vld             =   w_dmac6_vld         				;
        assign      o_smac6_hash_key        =   w_smac6_hash_key    				;
        assign      o_smac6                 =   w_smac6             				;
        assign      o_smac6_vld             =   w_smac6_vld         				;
    `endif
    `ifdef MAC7
        // ��������ź� assign ����
        assign      o_vlan_id7              =   w_vlan_id_mac7                   	;
        assign      o_dmac7_hash_key        =   w_dmac7_hash_key                 	;
        assign      o_dmac7                 =   w_dmac7                          	;
        assign      o_dmac7_vld             =   w_dmac7_vld                      	;
        assign      o_smac7_hash_key        =   w_smac7_hash_key                 	;
        assign      o_smac7                 =   w_smac7                          	;
        assign      o_smac7_vld             =   w_smac7_vld                      	;
    `endif	
`endif

`ifdef CPU_MAC
    wire   [PORT_NUM - 1:0]                 w_tx_cpu_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_cpu_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_cpu_port_vld                   ;
`endif

`ifdef MAC1
    wire   [PORT_NUM - 1:0]                 w_tx_1_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_1_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_1_port_vld                   ;
`endif

`ifdef MAC2
    wire   [PORT_NUM - 1:0]                 w_tx_2_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_2_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_2_port_vld                   ;
`endif

`ifdef MAC3
    wire   [PORT_NUM - 1:0]                 w_tx_3_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_3_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_3_port_vld                   ;
`endif

`ifdef MAC4
    wire   [PORT_NUM - 1:0]                 w_tx_4_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_4_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_4_port_vld                   ;
`endif

`ifdef MAC5
    wire   [PORT_NUM - 1:0]                 w_tx_5_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_5_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_5_port_vld                   ;
`endif

`ifdef MAC6
    wire   [PORT_NUM - 1:0]                 w_tx_6_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_6_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_6_port_vld                   ;
`endif

`ifdef MAC7
    wire   [PORT_NUM - 1:0]                 w_tx_7_port                       ; // ������ģ�鷵�صĲ���˿���Ϣ
    wire   [1:0]                            w_tx_7_port_broadcast             ; // 01:�鲥 10���㲥 11:����
    wire                                    w_tx_7_port_vld                   ;
`endif

`ifdef END_POINTER_SWITCH_CORE
    `ifdef CPU_MAC
        assign w_tx_cpu_port                       =   i_tx_cpu_port                       ;
        assign w_tx_cpu_port_broadcast             =   i_tx_cpu_port_broadcast             ;
        assign w_tx_cpu_port_vld                   =   i_tx_cpu_port_vld                   ;
    `endif
    `ifdef MAC1
        assign w_tx_1_port                         =   i_tx_1_port                         ;
        assign w_tx_1_port_broadcast               =   i_tx_1_port_broadcast               ;
        assign w_tx_1_port_vld                     =   i_tx_1_port_vld                     ;
    `endif
    `ifdef MAC2
        assign w_tx_2_port                         =   i_tx_2_port                         ;
        assign w_tx_2_port_broadcast               =   i_tx_2_port_broadcast               ;
        assign w_tx_2_port_vld                     =   i_tx_2_port_vld                     ;
    `endif
    `ifdef MAC3
        assign w_tx_3_port                         =   i_tx_3_port                         ;
        assign w_tx_3_port_broadcast               =   i_tx_3_port_broadcast               ;
        assign w_tx_3_port_vld                     =   i_tx_3_port_vld                     ;    
    `endif
    `ifdef MAC4
        assign w_tx_4_port                         =   i_tx_4_port                         ;
        assign w_tx_4_port_broadcast               =   i_tx_4_port_broadcast               ;
        assign w_tx_4_port_vld                     =   i_tx_4_port_vld                     ;
    `endif
    `ifdef MAC5
        assign w_tx_5_port                         =   i_tx_5_port                         ;
        assign w_tx_5_port_broadcast               =   i_tx_5_port_broadcast               ;
        assign w_tx_5_port_vld                     =   i_tx_5_port_vld                     ;
    `endif
    `ifdef MAC6
        assign w_tx_6_port                         =   i_tx_6_port                         ;
        assign w_tx_6_port_broadcast               =   i_tx_6_port_broadcast               ;
        assign w_tx_6_port_vld                     =   i_tx_6_port_vld                     ;
    `endif
    `ifdef MAC7
        assign w_tx_7_port                         =   i_tx_7_port                         ;
        assign w_tx_7_port_broadcast               =   i_tx_7_port_broadcast               ;
        assign w_tx_7_port_vld                     =   i_tx_7_port_vld                     ;
    `endif
`elsif END_POINTER
    `ifdef CPU_MAC
        assign w_tx_cpu_port                       =   8'b0000_0011                       ;
        assign w_tx_cpu_port_broadcast             =   2'b00                              ;
        assign w_tx_cpu_port_vld                   =   1'b1                               ;
    `endif
    `ifdef MAC1
        assign w_tx_1_port                         =   8'b0000_0001                       ;
        assign w_tx_1_port_broadcast               =   2'b00                              ;
        assign w_tx_1_port_vld                     =   1'b1                               ;
    `endif
    `ifdef MAC2
        assign w_tx_2_port                         =   8'b0000_0001                       ;
        assign w_tx_2_port_broadcast               =   2'b00                              ;
        assign w_tx_2_port_vld                     =   1'b1                               ;
    `endif
`endif

`ifdef CPU_MAC
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ), // �ۺ��������
        .PORT_INDEX                         (0                                      )  // �˿ں�                            
    )rx_port_mng_inst0 (
        .i_clk                              (i_clk                                  ),   // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_cpu_mac0_port_link                   ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_cpu_mac0_port_speed                  ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_cpu_mac0_port_filter_preamble_v      ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_cpu_mac0_axi_data                    ), // �˿�������
        .i_mac_axi_data_keep                (w_cpu_mac0_axi_data_keep               ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_cpu_mac0_axi_data_valid              ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_cpu_mac0_axi_data_ready              ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_cpu_mac0_axi_data_last               ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_cpu_mac0_time_irq                    ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_cpu_mac0_frame_seq                   ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp0_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac0_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac0_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac0_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac0_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac0_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac0_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_cpu                          ),
        .o_dmac_hash_key                    (w_dmac_cpu_hash_key                    ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac_cpu                             ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac_cpu_vld                         ), // dmac_vld
        .o_smac_hash_key                    (w_smac_cpu_hash_key                    ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac_cpu                             ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac_cpu_vld                         ), // smac_vld
        .i_swlist_tx_port                   (w_tx_cpu_port                          ),
        .i_swlist_vld                       (w_tx_cpu_port_vld                      ),
        .i_swlist_port_broadcast            (w_tx_cpu_port_broadcast                ),
        
        // ���潻���߼�
        .o_tx_req                           (o_tx0_req                              ),
        .i_mac_tx0_ack                      (i_mac0_tx0_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac0_tx0_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac0_tx1_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac0_tx1_ack_rst                     ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac0_tx2_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac0_tx2_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac0_tx3_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac0_tx3_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac0_tx4_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac0_tx4_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac0_tx5_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac0_tx5_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac0_tx6_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac0_tx6_ack_rst                     ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac0_tx7_ack                         ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac0_tx7_ack_rst                     ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac0_qbu_verify_valid                ),
        .o_qbu_response_valid               (o_mac0_qbu_response_valid              ),

        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac0_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac0_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac0_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac0_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac0_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac0_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac0_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac0_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac0_cross_metadata                  ), // �ۺ����� metadata ����                
        .o_cross_metadata_valid             (w_mac0_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź� 
        .o_cross_metadata_last              (w_mac0_cross_metadata_last             ), // ��Ϣ��������ʶ 
        .i_cross_metadata_ready             (w_mac0_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ��  
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac0_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac0_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac0_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac0_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac0_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac0_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac0_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac0_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac0_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac0_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_0), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_0), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_0),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_0), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_0), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_0), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_0), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_0), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_0), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_0), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_0), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_0), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_0), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_0), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_0_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_0), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_0), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_0), // ������Ŀѡ��

		// DMAC
		.i_cfg_acl_item_dmac_code_1     	(w_cfg_acl_item_dmac_code_a1	  ),  
		.i_cfg_acl_item_dmac_code_1_valid	(w_cfg_acl_item_dmac_code_a1_valid),
		.i_cfg_acl_item_dmac_code_2     	(w_cfg_acl_item_dmac_code_a2      ),  
		.i_cfg_acl_item_dmac_code_2_valid	(w_cfg_acl_item_dmac_code_a2_valid),
		.i_cfg_acl_item_dmac_code_3     	(w_cfg_acl_item_dmac_code_a3      ),  
		.i_cfg_acl_item_dmac_code_3_valid	(w_cfg_acl_item_dmac_code_a3_valid),
		.i_cfg_acl_item_dmac_code_4     	(w_cfg_acl_item_dmac_code_a4      ),  
		.i_cfg_acl_item_dmac_code_4_valid	(w_cfg_acl_item_dmac_code_a4_valid),
		.i_cfg_acl_item_dmac_code_5     	(w_cfg_acl_item_dmac_code_a5      ),  
		.i_cfg_acl_item_dmac_code_5_valid	(w_cfg_acl_item_dmac_code_a5_valid),
		.i_cfg_acl_item_dmac_code_6     	(w_cfg_acl_item_dmac_code_a6      ),  
		.i_cfg_acl_item_dmac_code_6_valid	(w_cfg_acl_item_dmac_code_a6_valid),
																			
		// SMAC                                       
		.i_cfg_acl_item_smac_code_1     	(w_cfg_acl_item_smac_code_a1	  ),       
		.i_cfg_acl_item_smac_code_1_valid	(w_cfg_acl_item_smac_code_a1_valid),
		.i_cfg_acl_item_smac_code_2     	(w_cfg_acl_item_smac_code_a2      ),       
		.i_cfg_acl_item_smac_code_2_valid	(w_cfg_acl_item_smac_code_a2_valid),
		.i_cfg_acl_item_smac_code_3     	(w_cfg_acl_item_smac_code_a3      ),
		.i_cfg_acl_item_smac_code_3_valid	(w_cfg_acl_item_smac_code_a3_valid),
		.i_cfg_acl_item_smac_code_4     	(w_cfg_acl_item_smac_code_a4      ),
		.i_cfg_acl_item_smac_code_4_valid	(w_cfg_acl_item_smac_code_a4_valid),
		.i_cfg_acl_item_smac_code_5     	(w_cfg_acl_item_smac_code_a5      ),
		.i_cfg_acl_item_smac_code_5_valid	(w_cfg_acl_item_smac_code_a5_valid),
		.i_cfg_acl_item_smac_code_6     	(w_cfg_acl_item_smac_code_a6      ),
		.i_cfg_acl_item_smac_code_6_valid	(w_cfg_acl_item_smac_code_a6_valid),
	
		// VLAN
		.i_cfg_acl_item_vlan_code_1     	(w_cfg_acl_item_vlan_code_a1	  ),
		.i_cfg_acl_item_vlan_code_1_valid	(w_cfg_acl_item_vlan_code_a1_valid),
		.i_cfg_acl_item_vlan_code_2     	(w_cfg_acl_item_vlan_code_a2      ),
		.i_cfg_acl_item_vlan_code_2_valid	(w_cfg_acl_item_vlan_code_a2_valid),
		.i_cfg_acl_item_vlan_code_3     	(w_cfg_acl_item_vlan_code_a3      ),
		.i_cfg_acl_item_vlan_code_3_valid	(w_cfg_acl_item_vlan_code_a3_valid),
		.i_cfg_acl_item_vlan_code_4     	(w_cfg_acl_item_vlan_code_a4      ),
		.i_cfg_acl_item_vlan_code_4_valid	(w_cfg_acl_item_vlan_code_a4_valid),
	
		// Ethertype
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_a1	  ),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_a1_valid),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_a2      ),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_a2_valid),
															
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_a),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_a_valid),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_a),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_a_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_a),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_a_valid),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_a),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_a_valid),

        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_0), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_0           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_0           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_0               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_0         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_0          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_0          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_0                 ), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_0                  )  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC1
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (1                                      )  // �˿ں�  
    )rx_port_mng_inst1 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac1_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac1_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac1_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac1_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac1_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac1_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac1_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac1_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac1_time_irq                        ), // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac1_frame_seq                       ), // ֡���к�
        .o_timestamp_addr                   (w_timestamp1_addr                      ), // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac1_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac1_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac1_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac1_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac1_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac1_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac1                        ),
        .o_dmac_hash_key                    (w_dmac1_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac1                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac1_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac1_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac1                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac1_vld                           ), // smac_vld

        .i_swlist_tx_port                   (w_tx_1_port                           ),
        .i_swlist_vld                       (w_tx_1_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_1_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx1_req                             ),
        .i_mac_tx0_ack                      (i_mac1_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac1_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac1_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac1_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac1_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac1_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac1_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac1_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac1_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac1_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac1_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac1_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac1_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac1_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac1_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac1_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac1_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac1_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac1_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac1_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac1_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac1_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac1_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac1_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac1_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac1_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac1_cross_metadata                  ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac1_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac1_cross_metadata_last             ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac1_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac1_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac1_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac1_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac1_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac1_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac1_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac1_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac1_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac1_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac1_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_1), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_1), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_1),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_1), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_1), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_1), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_1), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_1), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_1), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_1), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_1), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_1), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_1), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_1), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_1_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_1), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_1), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_1), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     	(w_cfg_acl_item_dmac_code_b1	  ),  
		.i_cfg_acl_item_dmac_code_1_valid	(w_cfg_acl_item_dmac_code_b1_valid),
		.i_cfg_acl_item_dmac_code_2     	(w_cfg_acl_item_dmac_code_b2      ),  
		.i_cfg_acl_item_dmac_code_2_valid	(w_cfg_acl_item_dmac_code_b2_valid),
		.i_cfg_acl_item_dmac_code_3     	(w_cfg_acl_item_dmac_code_b3      ),  
		.i_cfg_acl_item_dmac_code_3_valid	(w_cfg_acl_item_dmac_code_b3_valid),
		.i_cfg_acl_item_dmac_code_4     	(w_cfg_acl_item_dmac_code_b4      ),  
		.i_cfg_acl_item_dmac_code_4_valid	(w_cfg_acl_item_dmac_code_b4_valid),
		.i_cfg_acl_item_dmac_code_5     	(w_cfg_acl_item_dmac_code_b5      ),  
		.i_cfg_acl_item_dmac_code_5_valid	(w_cfg_acl_item_dmac_code_b5_valid),
		.i_cfg_acl_item_dmac_code_6     	(w_cfg_acl_item_dmac_code_b6      ),  
		.i_cfg_acl_item_dmac_code_6_valid	(w_cfg_acl_item_dmac_code_b6_valid),
																			
		// SMAC                                       
		.i_cfg_acl_item_smac_code_1     	(w_cfg_acl_item_smac_code_b1	  ),       
		.i_cfg_acl_item_smac_code_1_valid	(w_cfg_acl_item_smac_code_b1_valid),
		.i_cfg_acl_item_smac_code_2     	(w_cfg_acl_item_smac_code_b2      ),       
		.i_cfg_acl_item_smac_code_2_valid	(w_cfg_acl_item_smac_code_b2_valid),
		.i_cfg_acl_item_smac_code_3     	(w_cfg_acl_item_smac_code_b3      ),
		.i_cfg_acl_item_smac_code_3_valid	(w_cfg_acl_item_smac_code_b3_valid),
		.i_cfg_acl_item_smac_code_4     	(w_cfg_acl_item_smac_code_b4      ),
		.i_cfg_acl_item_smac_code_4_valid	(w_cfg_acl_item_smac_code_b4_valid),
		.i_cfg_acl_item_smac_code_5     	(w_cfg_acl_item_smac_code_b5      ),
		.i_cfg_acl_item_smac_code_5_valid	(w_cfg_acl_item_smac_code_b5_valid),
		.i_cfg_acl_item_smac_code_6     	(w_cfg_acl_item_smac_code_b6      ),
		.i_cfg_acl_item_smac_code_6_valid	(w_cfg_acl_item_smac_code_b6_valid),
	
		// VLAN
		.i_cfg_acl_item_vlan_code_1     	(w_cfg_acl_item_vlan_code_b1	  ),
		.i_cfg_acl_item_vlan_code_1_valid	(w_cfg_acl_item_vlan_code_b1_valid),
		.i_cfg_acl_item_vlan_code_2     	(w_cfg_acl_item_vlan_code_b2      ),
		.i_cfg_acl_item_vlan_code_2_valid	(w_cfg_acl_item_vlan_code_b2_valid),
		.i_cfg_acl_item_vlan_code_3     	(w_cfg_acl_item_vlan_code_b3      ),
		.i_cfg_acl_item_vlan_code_3_valid	(w_cfg_acl_item_vlan_code_b3_valid),
		.i_cfg_acl_item_vlan_code_4     	(w_cfg_acl_item_vlan_code_b4      ),
		.i_cfg_acl_item_vlan_code_4_valid	(w_cfg_acl_item_vlan_code_b4_valid),
	
		// Ethertype
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_b1	  ),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_b1_valid),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_b2      ),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_b2_valid),
															
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_b			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_b_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_b		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_b_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_b 			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_b_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_b   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_b_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_1), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_1           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_1           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_1               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_1         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_1          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_1          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_1                 ), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_1                )  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC2
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (2                                      )  // �˿ں�  
    )rx_port_mng_inst2 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac2_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac2_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac2_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac2_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac2_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac2_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac2_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac2_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac2_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac2_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp2_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac2_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac2_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac2_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac2_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac2_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac2_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac2                        ),
        .o_dmac_hash_key                    (w_dmac2_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac2                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac2_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac2_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac2                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac2_vld                           ), // smac_vld
        .i_swlist_tx_port                   (w_tx_2_port                           ),
        .i_swlist_vld                       (w_tx_2_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_2_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx2_req                             ),
        .i_mac_tx0_ack                      (i_mac2_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac2_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac2_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac2_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac2_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac2_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac2_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac2_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac2_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac2_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac2_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac2_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac2_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac2_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac2_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac2_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac2_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac2_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac2_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac2_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac2_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac2_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac2_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac2_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac2_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac2_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac2_cross_metadata                      ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac2_cross_metadata_valid                ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac2_cross_metadata_last                 ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac2_cross_metadata_ready                ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac2_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac2_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac2_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac2_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac2_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac2_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac2_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac2_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac2_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac2_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_2), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_2), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_2),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_2), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_2), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_2), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_2), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_2), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_2), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_2), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_2), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_2), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_2), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_2), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_2_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_2), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_2), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_2), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_c1			),  
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_c1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_c2			),  
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_c2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_c3			),  
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_c3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_c4			),  
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_c4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_c5			),  
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_c5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_c6			),  
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_c6_valid		),																
		// SMAC                             				          	
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_c1			),       
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_c1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_c2			),       
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_c2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_c3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_c3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_c4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_c4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_c5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_c5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_c6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_c6_valid		),
		// VLAN					
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_c1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_c1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_c2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_c2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_c3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_c3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_c4			),
		.i_cfg_acl_item_vlan_code_4_valid					(w_cfg_acl_item_vlan_code_c4_valid		),
		// Ethertype
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_c1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_c1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_c2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_c2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_c),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_c_valid),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_c		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_c_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_c 			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_c_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_c   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_c_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_2), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_2           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_2           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_2               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_2         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_2          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_2          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_2), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_2)  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC3
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (3                                      )  // �˿ں�  
    )rx_port_mng_inst3 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac3_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac3_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac3_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac3_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac3_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac3_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac3_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac3_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac3_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac3_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp3_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac3_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac3_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac3_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac3_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac3_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac3_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac3                        ),
        .o_dmac_hash_key                    (w_dmac3_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac3                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac3_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac3_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac3                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac3_vld                           ), // smac_vld

        .i_swlist_tx_port                   (w_tx_3_port                           ),
        .i_swlist_vld                       (w_tx_3_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_3_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx3_req                             ),
        .i_mac_tx0_ack                      (i_mac3_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac3_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac3_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac3_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac3_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac3_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac3_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac3_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac3_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac3_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac3_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac3_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac3_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac3_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac3_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac3_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac3_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac3_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac3_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac3_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac3_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac3_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac3_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac3_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac3_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac3_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac3_cross_metadata                  ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac3_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac3_cross_metadata_last             ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac3_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac3_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac3_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac3_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac3_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac3_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac3_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac3_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac3_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac3_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac3_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_3), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_3), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_3),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_3), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_3), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_3), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_3), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_3), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_3), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_3), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_3), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_3), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_3), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_3), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_3_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_3), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_3), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_3), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_d1			),
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_d1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_d2			),
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_d2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_d3			),
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_d3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_d4			),
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_d4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_d5			),
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_d5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_d6			),
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_d6_valid		),														
		// SMAC                             				          	              
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_d1			),
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_d1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_d2			),
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_d2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_d3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_d3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_d4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_d4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_d5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_d5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_d6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_d6_valid		),	
		// VLAN				                                                          
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_d1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_d1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_d2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_d2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_d3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_d3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_d4			),
		.i_cfg_acl_item_vlan_code_4_valid				    (w_cfg_acl_item_vlan_code_d4_valid		),
		// Ethertype                                        
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_d1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_d1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_d2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_d2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_d			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_d_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_d		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_d_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_d 			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_d_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_d   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_d_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_3                 ), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_3           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_3           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_3               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_3         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_3          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_3          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_3                 ), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_3                )  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC4
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (4                                      )  // �˿ں�  
    )rx_port_mng_inst4 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac4_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac4_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac4_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac4_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac4_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac4_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac4_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac4_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac4_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac4_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp4_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac4_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac4_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac4_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac4_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac4_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac4_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac4                        ),
        .o_dmac_hash_key                    (w_dmac4_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac4                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac4_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac4_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac4                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac4_vld                           ), // smac_vld
        
        .i_swlist_tx_port                   (w_tx_4_port                           ),
        .i_swlist_vld                       (w_tx_4_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_4_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx4_req                             ),
        .i_mac_tx0_ack                      (i_mac4_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac4_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac4_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac4_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac4_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac4_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac4_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac4_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac4_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac4_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac4_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac4_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac4_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac4_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac4_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac4_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac4_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac4_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� ------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac4_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac4_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac4_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac4_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac4_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac4_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac4_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac4_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac4_cross_metadata                  ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac4_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac4_cross_metadata_last             ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac4_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac4_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac4_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac4_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac4_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac4_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac4_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac4_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac4_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac4_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac4_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_4), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_4), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_4), 
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_4), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_4), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_4), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_4), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_4), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_4), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_4), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_4), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_4), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_4), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_4), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_4_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_4), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_4), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_4), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_e1			),
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_e1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_e2			),
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_e2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_e3			),
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_e3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_e4			),
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_e4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_e5			),
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_e5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_e6			),
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_e6_valid		),														
		// SMAC                             				          	              
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_e1			),
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_e1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_e2			),
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_e2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_e3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_e3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_e4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_e4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_e5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_e5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_e6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_e6_valid		),	
		// VLAN				                                                          
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_e1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_e1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_e2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_e2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_e3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_e3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_e4			),
		.i_cfg_acl_item_vlan_code_4_valid				    (w_cfg_acl_item_vlan_code_e4_valid		),
		// Ethertype                                        
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_e1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_e1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_e2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_e2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_e			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_e_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_e		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_e_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_e 			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_e_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_e   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_e_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_4), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_4           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_4           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_4               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_4         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_4          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_4          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_4                 ), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_4                )  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC5
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (5                                      )  // �˿ں�  
    )rx_port_mng_inst5 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac5_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac5_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac5_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac5_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac5_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac5_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac5_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac5_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac5_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac5_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp5_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac5_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac5_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac5_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac5_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac5_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac5_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac5                        ),
        .o_dmac_hash_key                    (w_dmac5_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac5                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac5_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac5_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac5                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac5_vld                           ), // smac_vld
        
        .i_swlist_tx_port                   (w_tx_5_port                           ),
        .i_swlist_vld                       (w_tx_5_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_5_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx5_req                             ),
        .i_mac_tx0_ack                      (i_mac5_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac5_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac5_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac5_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac5_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac5_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac5_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac5_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac5_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac5_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac5_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac5_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac5_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac5_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac5_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac5_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac5_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac5_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac5_cross_port_link                ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac5_cross_port_speed               ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac5_cross_port_axi_data            ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac5_cross_port_axi_user            ),
        .o_mac_cross_axi_data_keep          (w_mac5_cross_axi_data_keep            ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac5_cross_axi_data_valid           ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac5_cross_axi_data_ready           ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac5_cross_axi_data_last            ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac5_cross_metadata                 ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac5_cross_metadata_valid           ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac5_cross_metadata_last            ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac5_cross_metadata_ready           ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac5_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac5_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac5_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac5_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac5_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac5_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac5_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac5_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac5_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac5_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_5), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_5), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_5),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_5), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_5), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_5), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_5), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_5), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_5), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_5), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_5), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_5), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_5), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_5), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_5_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_5), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_5), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_5), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_f1			),
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_f1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_f2			),
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_f2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_f3			),
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_f3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_f4			),
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_f4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_f5			),
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_f5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_f6			),
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_f6_valid		),														
		// SMAC                             				          	              
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_f1			),
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_f1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_f2			),
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_f2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_f3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_f3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_f4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_f4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_f5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_f5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_f6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_f6_valid		),	
		// VLAN				                                                          
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_f1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_f1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_f2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_f2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_f3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_f3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_f4			),
		.i_cfg_acl_item_vlan_code_4_valid				    (w_cfg_acl_item_vlan_code_f4_valid		),
		// Ethertype                                        
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_f1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_f1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_f2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_f2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_f			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_f_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_f		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_f_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_f			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_f_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_f   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_f_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_5), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_5           ), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_5           ), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_5               ), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_5         ), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_5          ), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_5          ), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_5), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_5)  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC6
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (6                                      )  // �˿ں�  
    )rx_port_mng_inst6 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac6_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac6_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac6_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac6_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac6_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac6_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac6_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac6_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac6_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac6_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp6_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac6_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac6_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac6_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac6_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac6_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac6_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac6                        ),
        .o_dmac_hash_key                    (w_dmac6_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac6                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac6_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac6_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac6                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac6_vld                           ), // smac_vld
        
        .i_swlist_tx_port                   (w_tx_6_port                           ),
        .i_swlist_vld                       (w_tx_6_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_6_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx6_req                             ),
        .i_mac_tx0_ack                      (i_mac6_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac6_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac6_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac6_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac6_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac6_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac6_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac6_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac6_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac6_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac6_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac6_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac6_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac6_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac6_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac6_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac6_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac6_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac6_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac6_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac6_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac6_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac6_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac6_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac6_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac6_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac6_cross_metadata                  ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac6_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac6_cross_metadata_last             ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac6_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac6_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac6_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac6_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac6_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac6_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac6_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac6_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac6_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac6_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac6_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_6), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_6), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_6),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_6), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_6), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_6), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_6), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_6), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_6), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_6), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_6), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_6), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_6), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_6), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_6_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_6), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_6), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_6), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_g1			),
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_g1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_g2			),
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_g2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_g3			),
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_g3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_g4			),
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_g4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_g5			),
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_g5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_g6			),
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_g6_valid		),														
		// SMAC                             				          	              
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_g1			),
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_g1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_g2			),
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_g2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_g3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_g3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_g4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_g4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_g5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_g5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_g6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_g6_valid		),	
		// VLAN				                                                          
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_g1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_g1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_g2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_g2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_g3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_g3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_g4			),
		.i_cfg_acl_item_vlan_code_4_valid				    (w_cfg_acl_item_vlan_code_g4_valid		),
		// Ethertype                                        
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_g1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_g1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_g2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_g2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_g			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_g_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_g		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_g_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_g			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_g_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_g   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_g_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_6), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_6), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_6), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_6), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_6), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_6), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_6), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_6), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_6)  // �˿�0����֡����������ֵ  
    );
`endif

`ifdef MAC7
    rx_port_mng#(
        .PORT_NUM                           (PORT_NUM                               ), // �������Ķ˿���
        .PORT_MNG_DATA_WIDTH                (PORT_MNG_DATA_WIDTH                    ), // Mac_port_mng ����λ��
        .HASH_DATA_WIDTH                    (HASH_DATA_WIDTH                        ), // ��ϣ�����ֵ��λ�� 
        .METADATA_WIDTH                     (METADATA_WIDTH                         ), // ��Ϣ��λ��
        .CROSS_DATA_WIDTH                   (CROSS_DATA_WIDTH                       ),  // �ۺ��������
        .PORT_INDEX                         (7                                      )  // �˿ں�  
    )rx_port_mng_inst7 (
        .i_clk                              (i_clk                                  ),       // 250MHz
        .i_rst                              (i_rst                                  ),
        // .i_switch_reg_bus_we                (i_switch_reg_bus_we                    ),
        // .i_switch_reg_bus_we_addr           (i_switch_reg_bus_we_addr               ),
        // .i_switch_reg_bus_we_din            (i_switch_reg_bus_we_din                ),
        // .i_switch_reg_bus_we_din_v          (i_switch_reg_bus_we_din_v              ),
        // .i_switch_reg_bus_rd                (i_switch_reg_bus_rd                    ),
        // .i_switch_reg_bus_rd_addr           (i_switch_reg_bus_rd_addr               ),
        // .o_switch_reg_bus_we_dout           (o_switch_reg_bus_we_dout               ),
        // .o_switch_reg_bus_we_dout_v         (o_switch_reg_bus_we_dout_v             ),
        /*---------------------------------------- ����� MAC ������ -------------------------------------------*/
        .i_mac_port_link                    (w_mac7_port_link                       ), // �˿ڵ�����״̬
        .i_mac_port_speed                   (w_mac7_port_speed                      ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G
        .i_mac_port_filter_preamble_v       (w_mac7_port_filter_preamble_v          ), // �˿��Ƿ����ǰ������Ϣ
        .i_mac_axi_data                     (w_mac7_axi_data                        ), // �˿�������
        .i_mac_axi_data_keep                (w_mac7_axi_data_keep                   ), // �˿�����������,��Ч�ֽ�ָʾ
        .i_mac_axi_data_valid               (w_mac7_axi_data_valid                  ), // �˿�������Ч
        .o_mac_axi_data_ready               (w_mac7_axi_data_ready                  ), // �˿����ݾ����ź�,��ʾ��ǰģ��׼���ý�������
        .i_mac_axi_data_last                (w_mac7_axi_data_last                   ), // ������������ʶ
        /*---------------------------------------- ��ʱ����ź� -------------------------------------------*/
        .o_mac_time_irq                     (w_mac7_time_irq                        ) , // ��ʱ����ж��ź�
        .o_mac_frame_seq                    (w_mac7_frame_seq                       ) , // ֡���к�
        .o_timestamp_addr                   (w_timestamp7_addr                      ) , // ��ʱ����洢�� RAM ��ַ
        // R-TAG ���к�����Ч�ź����
        .o_rtag_flag                        (w_mac7_rtag_flag                       ), // �Ƿ�Я��rtag��ǩ,��CBҵ��֡,��Ҫ�ȹ�CBģ������Ƿ�����,������crossbar
        .o_rtag_squence                     (w_mac7_rtag_squence                    ), // rtag_squencenum
        .o_stream_handle                    (w_mac7_stream_handle                   ), // ACL��ʶ��,������,ÿ��������ά���Լ���
        
        .i_pass_en                          (i_mac7_pass_en                         ), // �жϽ��,���Խ��ո�֡
        .i_discard_en                       (i_mac7_discard_en                      ), // �жϽ��,���Զ�����֡
        .i_judge_finish                     (i_mac7_judge_finish                    ), // �жϽ��,��ʾ���α��ĵ��ж����  
        /*---------------------------------------- ����Ĺ�ϣֵ -------------------------------------------*/
        .o_vlan_id                          (w_vlan_id_mac7                        ),
        .o_dmac_hash_key                    (w_dmac7_hash_key                      ), // Ŀ�� mac �Ĺ�ϣֵ
        .o_dmac                             (w_dmac7                               ), // Ŀ�� mac ��ֵ
        .o_dmac_vld                         (w_dmac7_vld                           ), // dmac_vld
        .o_smac_hash_key                    (w_smac7_hash_key                      ), // Դ mac ��ֵ��Ч��ʶ
        .o_smac                             (w_smac7                               ), // Դ mac ��ֵ
        .o_smac_vld                         (w_smac7_vld                           ), // smac_vld
        
        .i_swlist_tx_port                   (w_tx_7_port                           ),
        .i_swlist_vld                       (w_tx_7_port_vld                       ),
        .i_swlist_port_broadcast            (w_tx_7_port_broadcast                 ),
        // ���潻���߼�
        .o_tx_req                           (o_tx7_req                             ),
        .i_mac_tx0_ack                      (i_mac7_tx0_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx0_ack_rst                  (i_mac7_tx0_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx1_ack                      (i_mac7_tx1_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx1_ack_rst                  (i_mac7_tx1_ack_rst                    ), // �˿ڵ����ȼ��������  
        .i_mac_tx2_ack                      (i_mac7_tx2_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx2_ack_rst                  (i_mac7_tx2_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx3_ack                      (i_mac7_tx3_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx3_ack_rst                  (i_mac7_tx3_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx4_ack                      (i_mac7_tx4_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx4_ack_rst                  (i_mac7_tx4_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx5_ack                      (i_mac7_tx5_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx5_ack_rst                  (i_mac7_tx5_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx6_ack                      (i_mac7_tx6_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx6_ack_rst                  (i_mac7_tx6_ack_rst                    ), // �˿ڵ����ȼ��������
        .i_mac_tx7_ack                      (i_mac7_tx7_ack                        ), // ��Ӧʹ���ź�
        .i_mac_tx7_ack_rst                  (i_mac7_tx7_ack_rst                    ), // �˿ڵ����ȼ��������

        .o_qbu_verify_valid                 (o_mac7_qbu_verify_valid               ),
        .o_qbu_response_valid               (o_mac7_qbu_response_valid             ),
        /*---------------------------------------- �� PORT �ۺ������� -------------------------------------------*/
        // .o_mac_cross_port_link              (w_mac7_cross_port_link                 ), // �˿ڵ�����״̬
        // .o_mac_cross_port_speed             (w_mac7_cross_port_speed                ), // �˿�������Ϣ,00-10M,01-100M,10-1000M,10-10G 
        .o_mac_cross_port_axi_data          (w_mac7_cross_port_axi_data             ), // �˿�������,���λ��ʾcrcerr
        .o_mac_cross_port_axi_user          (w_mac7_cross_port_axi_user             ),
        .o_mac_cross_axi_data_keep          (w_mac7_cross_axi_data_keep             ), // �˿�����������,��Ч�ֽ�ָʾ
        .o_mac_cross_axi_data_valid         (w_mac7_cross_axi_data_valid            ), // �˿�������Ч
        .i_mac_cross_axi_data_ready         (w_mac7_cross_axi_data_ready            ), // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_mac_cross_axi_data_last          (w_mac7_cross_axi_data_last             ), // ������������ʶ
        /*---------------------------------------- �� PORT �ۺ���Ϣ�� -------------------------------------------*/
        .o_cross_metadata                   (w_mac7_cross_metadata                  ), // �ۺ����� metadata ����
        .o_cross_metadata_valid             (w_mac7_cross_metadata_valid            ), // �ۺ����� metadata ������Ч�ź�
        .o_cross_metadata_last              (w_mac7_cross_metadata_last             ), // ��Ϣ��������ʶ
        .i_cross_metadata_ready             (w_mac7_cross_metadata_ready            ), // ����ģ�鷴ѹ��ˮ�� 
        
        /*---------------------------------------- �� PORT �ؼ�֡�ۺ���Ϣ�� -------------------------------------------*/
        .o_emac_port_axi_data               (w_emac7_port_axi_data                  ) , // �˿������������λ��ʾcrcerr
        .o_emac_port_axi_user               (w_emac7_port_axi_user                  ) ,
        .o_emac_axi_data_keep               (w_emac7_axi_data_keep                  ) , // �˿����������룬��Ч�ֽ�ָʾ
        .o_emac_axi_data_valid              (w_emac7_axi_data_valid                 ) , // �˿�������Ч
        .i_emac_axi_data_ready              (w_emac7_axi_data_ready                 ) , // �������߾ۺϼܹ���ѹ��ˮ���ź�
        .o_emac_axi_data_last               (w_emac7_axi_data_last                  ) , // ������������ʶ 
        .o_emac_metadata                    (w_emac7_metadata                       ) , // ���� metadata ����
        .o_emac_metadata_valid              (w_emac7_metadata_valid                 ) , // ���� metadata ������Ч�ź�
        .o_emac_metadata_last               (w_emac7_metadata_last                  ) , // ��Ϣ��������ʶ
        .i_emac_metadata_ready              (w_emac7_metadata_ready                 ) , // ����ģ�鷴ѹ��ˮ�� 
        /*---------------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------------*/
        .i_hash_ploy_regs                   (w_hash_ploy_regs_7), // ��ϣ����ʽ
        .i_hash_init_val_regs               (w_hash_init_val_regs_7), // ��ϣ����ʽ��ʼֵ
        .i_hash_regs_vld                    (w_hash_regs_vld_7),
        .i_port_rxmac_down_regs             (w_port_rxmac_down_regs_7), // �˿ڽ��շ���MAC�ر�ʹ��
        .i_port_broadcast_drop_regs         (w_port_broadcast_drop_regs_7), // �˿ڹ㲥֡����ʹ��
        .i_port_multicast_drop_regs         (w_port_multicast_drop_regs_7), // �˿��鲥֡����ʹ��
        .i_port_loopback_drop_regs          (w_port_loopback_drop_regs_7), // �˿ڻ���֡����ʹ��
        .i_port_mac_regs                    (w_port_mac_regs_7), // �˿ڵ� MAC ��ַ
        .i_port_mac_vld_regs                (w_port_mac_vld_regs_7), // ʹ�ܶ˿� MAC ��ַ��Ч
        .i_port_mtu_regs                    (w_port_mtu_regs_7), // MTU����ֵ
        .i_port_mirror_frwd_regs            (w_port_mirror_frwd_regs_7), // ����ת���Ĵ���,����Ӧ�Ķ˿���1,�򱾶˿ڽ��յ����κ�ת������֡������ת��ֵ����1�Ķ˿�
        .i_port_flowctrl_cfg_regs           (w_port_flowctrl_cfg_regs_7), // ������������
        .i_port_rx_ultrashortinterval_num   (w_port_rx_ultrashortinterval_num_7), // ֡���
        // ACL �Ĵ���
        .i_acl_port_sel                     (w_acl_port_sel_7), // ѡ��Ҫ���õĶ˿�
		.i_acl_port_sel_valid				(w_acl_port_sel_7_valid),
        .i_acl_clr_list_regs                (w_acl_clr_list_regs_7), // ��ռĴ����б�
        .o_acl_list_rdy_regs                (w_acl_list_rdy_regs_7), // ���üĴ�����������
        .i_acl_item_sel_regs                (w_acl_item_sel_regs_7), // ������Ŀѡ��
		// DMAC
		.i_cfg_acl_item_dmac_code_1     					(w_cfg_acl_item_dmac_code_h1			),
		.i_cfg_acl_item_dmac_code_1_valid					(w_cfg_acl_item_dmac_code_h1_valid		),
		.i_cfg_acl_item_dmac_code_2     					(w_cfg_acl_item_dmac_code_h2			),
		.i_cfg_acl_item_dmac_code_2_valid					(w_cfg_acl_item_dmac_code_h2_valid		),
		.i_cfg_acl_item_dmac_code_3     					(w_cfg_acl_item_dmac_code_h3			),
		.i_cfg_acl_item_dmac_code_3_valid					(w_cfg_acl_item_dmac_code_h3_valid		),
		.i_cfg_acl_item_dmac_code_4     					(w_cfg_acl_item_dmac_code_h4			),
		.i_cfg_acl_item_dmac_code_4_valid					(w_cfg_acl_item_dmac_code_h4_valid		),
		.i_cfg_acl_item_dmac_code_5     					(w_cfg_acl_item_dmac_code_h5			),
		.i_cfg_acl_item_dmac_code_5_valid					(w_cfg_acl_item_dmac_code_h5_valid		),
		.i_cfg_acl_item_dmac_code_6     					(w_cfg_acl_item_dmac_code_h6			),
		.i_cfg_acl_item_dmac_code_6_valid					(w_cfg_acl_item_dmac_code_h6_valid		),														
		// SMAC                             				          	              
		.i_cfg_acl_item_smac_code_1     					(w_cfg_acl_item_smac_code_h1			),
		.i_cfg_acl_item_smac_code_1_valid					(w_cfg_acl_item_smac_code_h1_valid		),
		.i_cfg_acl_item_smac_code_2     					(w_cfg_acl_item_smac_code_h2			),
		.i_cfg_acl_item_smac_code_2_valid					(w_cfg_acl_item_smac_code_h2_valid		),
		.i_cfg_acl_item_smac_code_3     					(w_cfg_acl_item_smac_code_h3			),
		.i_cfg_acl_item_smac_code_3_valid					(w_cfg_acl_item_smac_code_h3_valid		),
		.i_cfg_acl_item_smac_code_4     					(w_cfg_acl_item_smac_code_h4			),
		.i_cfg_acl_item_smac_code_4_valid					(w_cfg_acl_item_smac_code_h4_valid		),
		.i_cfg_acl_item_smac_code_5     					(w_cfg_acl_item_smac_code_h5			),
		.i_cfg_acl_item_smac_code_5_valid					(w_cfg_acl_item_smac_code_h5_valid		),
		.i_cfg_acl_item_smac_code_6     					(w_cfg_acl_item_smac_code_h6			),
		.i_cfg_acl_item_smac_code_6_valid					(w_cfg_acl_item_smac_code_h6_valid		),	
		// VLAN				                                                          
		.i_cfg_acl_item_vlan_code_1     					(w_cfg_acl_item_vlan_code_h1			),
		.i_cfg_acl_item_vlan_code_1_valid					(w_cfg_acl_item_vlan_code_h1_valid		),
		.i_cfg_acl_item_vlan_code_2     					(w_cfg_acl_item_vlan_code_h2			),
		.i_cfg_acl_item_vlan_code_2_valid					(w_cfg_acl_item_vlan_code_h2_valid		),
		.i_cfg_acl_item_vlan_code_3     					(w_cfg_acl_item_vlan_code_h3			),
		.i_cfg_acl_item_vlan_code_3_valid					(w_cfg_acl_item_vlan_code_h3_valid		),
		.i_cfg_acl_item_vlan_code_4     					(w_cfg_acl_item_vlan_code_h4			),
		.i_cfg_acl_item_vlan_code_4_valid				    (w_cfg_acl_item_vlan_code_h4_valid		),
		// Ethertype                                        
		.i_cfg_acl_item_ethertype_code_1					(w_cfg_acl_item_ethertype_code_h1		),
		.i_cfg_acl_item_ethertype_code_1_valid				(w_cfg_acl_item_ethertype_code_h1_valid	),
		.i_cfg_acl_item_ethertype_code_2					(w_cfg_acl_item_ethertype_code_h2		),
		.i_cfg_acl_item_ethertype_code_2_valid				(w_cfg_acl_item_ethertype_code_h2_valid	),												
		// Action                                           
		.i_cfg_acl_item_action_pass_state					(w_cfg_acl_item_action_pass_state_h			),
		.i_cfg_acl_item_action_pass_state_valid				(w_cfg_acl_item_action_pass_state_h_valid		),
		.i_cfg_acl_item_action_cb_streamhandle				(w_cfg_acl_item_action_cb_streamhandle_h		),
		.i_cfg_acl_item_action_cb_streamhandle_valid		(w_cfg_acl_item_action_cb_streamhandle_h_valid),
		.i_cfg_acl_item_action_flowctrl 					(w_cfg_acl_item_action_flowctrl_h			),
		.i_cfg_acl_item_action_flowctrl_valid				(w_cfg_acl_item_action_flowctrl_h_valid		),
		.i_cfg_acl_item_action_txport   					(w_cfg_acl_item_action_txport_h   			),
		.i_cfg_acl_item_action_txport_valid					(w_cfg_acl_item_action_txport_h_valid			),
        // ״̬�Ĵ���
        .o_port_diag_state                  (w_port_diag_state_7), // �˿�״̬�Ĵ���,������Ĵ�����˵������ 
        // ��ϼĴ���
        .o_port_rx_ultrashort_frm           (w_port_rx_ultrashort_frm_7), // �˿ڽ��ճ���֡(С��64�ֽ�)
        .o_port_rx_overlength_frm           (w_port_rx_overlength_frm_7), // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .o_port_rx_crcerr_frm               (w_port_rx_crcerr_frm_7), // �˿ڽ���CRC����֡
        .o_port_rx_loopback_frm_cnt         (w_port_rx_loopback_frm_cnt_7), // �˿ڽ��ջ���֡������ֵ
        .o_port_broadflow_drop_cnt          (w_port_broadflow_drop_cnt_7), // �˿ڽ��յ��㲥������������֡������ֵ
        .o_port_multiflow_drop_cnt          (w_port_multiflow_drop_cnt_7), // �˿ڽ��յ��鲥������������֡������ֵ
        // ����ͳ�ƼĴ���
        .o_port_rx_byte_cnt                 (w_port_rx_byte_cnt_7), // �˿�0�����ֽڸ���������ֵ
        .o_port_rx_frame_cnt                (w_port_rx_frame_cnt_7)  // �˿�0����֡����������ֵ  
    );
`endif

/*---------------------------------------- rx_mac_reg ģ������ -------------------------------------------*/
rx_mac_reg #(
    .PORT_NUM               (PORT_NUM               ),
    .REG_ADDR_BUS_WIDTH     (REG_ADDR_BUS_WIDTH     ),
    .REG_DATA_BUS_WIDTH     (REG_DATA_BUS_WIDTH     )
) u_rx_mac_reg (
    .i_clk                                          (i_clk                  ),  // 250MHz
    .i_rst                                          (i_rst                  ),  // ��λ�ź�
    /*-------------------------------- ƽ̨�Ĵ��������� RXMAC ��صļĴ��� -------------------------------------*/
    `ifdef CPU_MAC
        .o_hash_ploy_regs_0                             (w_hash_ploy_regs_0                             ),  // ��ϣ����ʽ
        .o_hash_init_val_regs_0                         (w_hash_init_val_regs_0                         ),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_0                              (w_hash_regs_vld_0                              ),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_0                       (w_port_rxmac_down_regs_0                       ),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_0                   (w_port_broadcast_drop_regs_0                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_0                   (w_port_multicast_drop_regs_0                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_0                    (w_port_loopback_drop_regs_0                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_0                              (w_port_mac_regs_0                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_0                          (w_port_mac_vld_regs_0                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_0                              (w_port_mtu_regs_0                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_0                      (w_port_mirror_frwd_regs_0                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_0                     (w_port_flowctrl_cfg_regs_0                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_0             (w_port_rx_ultrashortinterval_num_0             ),  // ֡���
        // ACL �Ĵ���
        .o_acl_port_sel_0                               (w_acl_port_sel_0                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_0_valid							(w_acl_port_sel_0_valid							),
        .o_acl_clr_list_regs_0                          (w_acl_clr_list_regs_0                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_0                          (w_acl_list_rdy_regs_0                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_0                          (w_acl_item_sel_regs_0                          ),  // ������Ŀѡ��
		.o_cfg_acl_item_dmac_code_a1            		(w_cfg_acl_item_dmac_code_a1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_a1_valid      		(w_cfg_acl_item_dmac_code_a1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_a2            		(w_cfg_acl_item_dmac_code_a2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_a2_valid      		(w_cfg_acl_item_dmac_code_a2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_a3            		(w_cfg_acl_item_dmac_code_a3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_a3_valid      		(w_cfg_acl_item_dmac_code_a3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_a4            		(w_cfg_acl_item_dmac_code_a4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_a4_valid      		(w_cfg_acl_item_dmac_code_a4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_a5            		(w_cfg_acl_item_dmac_code_a5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_a5_valid      		(w_cfg_acl_item_dmac_code_a5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_a6            		(w_cfg_acl_item_dmac_code_a6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_a6_valid      		(w_cfg_acl_item_dmac_code_a6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_a1            		(w_cfg_acl_item_smac_code_a1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_a1_valid      		(w_cfg_acl_item_smac_code_a1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_a2            		(w_cfg_acl_item_smac_code_a2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_a2_valid      		(w_cfg_acl_item_smac_code_a2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_a3            		(w_cfg_acl_item_smac_code_a3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_a3_valid      		(w_cfg_acl_item_smac_code_a3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_a4            		(w_cfg_acl_item_smac_code_a4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_a4_valid      		(w_cfg_acl_item_smac_code_a4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_a5            		(w_cfg_acl_item_smac_code_a5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_a5_valid      		(w_cfg_acl_item_smac_code_a5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_a6            		(w_cfg_acl_item_smac_code_a6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_a6_valid      		(w_cfg_acl_item_smac_code_a6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_a1            		(w_cfg_acl_item_vlan_code_a1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_a1_valid      		(w_cfg_acl_item_vlan_code_a1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_a2            		(w_cfg_acl_item_vlan_code_a2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_a2_valid      		(w_cfg_acl_item_vlan_code_a2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_a3            		(w_cfg_acl_item_vlan_code_a3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_a3_valid      		(w_cfg_acl_item_vlan_code_a3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_a4            		(w_cfg_acl_item_vlan_code_a4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_a4_valid      		(w_cfg_acl_item_vlan_code_a4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_a1       		(w_cfg_acl_item_ethertype_code_a1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_a1_valid 		(w_cfg_acl_item_ethertype_code_a1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_a2       		(w_cfg_acl_item_ethertype_code_a2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_a2_valid 		(w_cfg_acl_item_ethertype_code_a2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_a     		(w_cfg_acl_item_action_pass_state_a     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_a_valid		(w_cfg_acl_item_action_pass_state_a_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_a 		(w_cfg_acl_item_action_cb_streamhandle_a 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_a_valid	(w_cfg_acl_item_action_cb_streamhandle_a_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_a        		(w_cfg_acl_item_action_flowctrl_a        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_a_valid  		(w_cfg_acl_item_action_flowctrl_a_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_a          		(w_cfg_acl_item_action_txport_a          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_a_valid    		(w_cfg_acl_item_action_txport_a_valid    		),  // д����Ч�ź�
        //  ״̬�Ĵ���
        .i_port_diag_state_0                            (w_port_diag_state_0                            ),  // �˿�״̬�Ĵ���
        //  ��ϼĴ���
        .i_port_rx_ultrashort_frm_0                     (w_port_rx_ultrashort_frm_0                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_0                     (w_port_rx_overlength_frm_0                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_0                         (w_port_rx_crcerr_frm_0                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_0                   (w_port_rx_loopback_frm_cnt_0                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_0                    (w_port_broadflow_drop_cnt_0                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_0                    (w_port_multiflow_drop_cnt_0                    ),  // �˿��鲥��������֡������ֵ
        // ����ͳ�ƼĴ���
        .i_port_rx_byte_cnt_0                           (w_port_rx_byte_cnt_0                           ),  // �˿�0�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_0                          (w_port_rx_frame_cnt_0                          ),  // �˿�0����֡����������ֵ
        // qbu �Ĵ���       
        .i_rx_busy_0                                    (w_rx_busy_0                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_0                            (w_rx_fragment_cnt_0                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_0                       (w_rx_fragment_mismatch_0                       ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_0                             (w_err_rx_crc_cnt_0                             ),  // CRC�������
        .i_err_rx_frame_cnt_0                           (w_err_rx_frame_cnt_0                           ),  // ֡�������
        .i_err_fragment_cnt_0                           (w_err_fragment_cnt_0                           ),  // ��Ƭ�������
        .i_rx_frames_cnt_0                              (w_rx_frames_cnt_0                              ),  // ����֡����
        .i_frag_next_rx_0                               (w_frag_next_rx_0                               ),  // ��һ����Ƭ��
        .i_frame_seq_0                                  (w_frame_seq_0                                  ),  // ֡���
        .o_reset_0                                      (w_reset_0                                      ),  // �˿�0��λ�ź�
    `endif
    `ifdef MAC1
        .o_hash_ploy_regs_1                             (w_hash_ploy_regs_1                             ),  // ��ϣ����ʽ
        .o_hash_init_val_regs_1                         (w_hash_init_val_regs_1                         ),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_1                              (w_hash_regs_vld_1                              ),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_1                       (w_port_rxmac_down_regs_1                       ),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_1                   (w_port_broadcast_drop_regs_1                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_1                   (w_port_multicast_drop_regs_1                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_1                    (w_port_loopback_drop_regs_1                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_1                              (w_port_mac_regs_1                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_1                          (w_port_mac_vld_regs_1                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_1                              (w_port_mtu_regs_1                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_1                      (w_port_mirror_frwd_regs_1                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_1                     (w_port_flowctrl_cfg_regs_1                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_1             (w_port_rx_ultrashortinterval_num_1             ),  // ֡���
        .o_acl_port_sel_1                               (w_acl_port_sel_1                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_1_valid							(w_acl_port_sel_1_valid							),
        .o_acl_clr_list_regs_1                          (w_acl_clr_list_regs_1                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_1                          (w_acl_list_rdy_regs_1                          ),  // ���üĴ�����������
        .o_cfg_acl_item_dmac_code_b1            		(w_cfg_acl_item_dmac_code_b1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_b1_valid      		(w_cfg_acl_item_dmac_code_b1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_b2            		(w_cfg_acl_item_dmac_code_b2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_b2_valid      		(w_cfg_acl_item_dmac_code_b2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_b3            		(w_cfg_acl_item_dmac_code_b3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_b3_valid      		(w_cfg_acl_item_dmac_code_b3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_b4            		(w_cfg_acl_item_dmac_code_b4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_b4_valid      		(w_cfg_acl_item_dmac_code_b4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_b5            		(w_cfg_acl_item_dmac_code_b5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_b5_valid      		(w_cfg_acl_item_dmac_code_b5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_b6            		(w_cfg_acl_item_dmac_code_b6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_b6_valid      		(w_cfg_acl_item_dmac_code_b6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_b1            		(w_cfg_acl_item_smac_code_b1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_b1_valid      		(w_cfg_acl_item_smac_code_b1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_b2            		(w_cfg_acl_item_smac_code_b2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_b2_valid      		(w_cfg_acl_item_smac_code_b2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_b3            		(w_cfg_acl_item_smac_code_b3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_b3_valid      		(w_cfg_acl_item_smac_code_b3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_b4            		(w_cfg_acl_item_smac_code_b4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_b4_valid      		(w_cfg_acl_item_smac_code_b4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_b5            		(w_cfg_acl_item_smac_code_b5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_b5_valid      		(w_cfg_acl_item_smac_code_b5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_b6            		(w_cfg_acl_item_smac_code_b6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_b6_valid      		(w_cfg_acl_item_smac_code_b6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_b1            		(w_cfg_acl_item_vlan_code_b1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_b1_valid      		(w_cfg_acl_item_vlan_code_b1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_b2            		(w_cfg_acl_item_vlan_code_b2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_b2_valid      		(w_cfg_acl_item_vlan_code_b2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_b3            		(w_cfg_acl_item_vlan_code_b3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_b3_valid      		(w_cfg_acl_item_vlan_code_b3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_b4            		(w_cfg_acl_item_vlan_code_b4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_b4_valid      		(w_cfg_acl_item_vlan_code_b4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_b1       		(w_cfg_acl_item_ethertype_code_b1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_b1_valid 		(w_cfg_acl_item_ethertype_code_b1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_b2       		(w_cfg_acl_item_ethertype_code_b2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_b2_valid 		(w_cfg_acl_item_ethertype_code_b2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_b     		(w_cfg_acl_item_action_pass_state_b     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_b_valid		(w_cfg_acl_item_action_pass_state_b_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_b 		(w_cfg_acl_item_action_cb_streamhandle_b 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_b_valid	(w_cfg_acl_item_action_cb_streamhandle_b_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_b        		(w_cfg_acl_item_action_flowctrl_b        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_b_valid  		(w_cfg_acl_item_action_flowctrl_b_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_b          		(w_cfg_acl_item_action_txport_b          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_b_valid    		(w_cfg_acl_item_action_txport_b_valid    		),  // д����Ч�ź�
		//  ״̬�Ĵ���
        .i_port_diag_state_1                            (w_port_diag_state_1                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_1                     (w_port_rx_ultrashort_frm_1                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_1                     (w_port_rx_overlength_frm_1                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_1                         (w_port_rx_crcerr_frm_1                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_1                   (w_port_rx_loopback_frm_cnt_1                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_1                    (w_port_broadflow_drop_cnt_1                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_1                    (w_port_multiflow_drop_cnt_1                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_1                           (w_port_rx_byte_cnt_1                           ),  // �˿�1�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_1                          (w_port_rx_frame_cnt_1                          ),  // �˿�1����֡����������ֵ
        .i_rx_busy_1                                    (w_rx_busy_1                            ),  // ����æ�ź�
        .i_rx_fragment_cnt_1                            (w_rx_fragment_cnt_1                    ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_1                       (w_rx_fragment_mismatch_1               ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_1                             (w_err_rx_crc_cnt_1                     ),  // CRC�������
        .i_err_rx_frame_cnt_1                           (w_err_rx_frame_cnt_1                   ),  // ֡�������
        .i_err_fragment_cnt_1                           (w_err_fragment_cnt_1                   ),  // ��Ƭ�������
        .i_rx_frames_cnt_1                              (w_rx_frames_cnt_1                      ),  // ����֡����
        .i_frag_next_rx_1                               (w_frag_next_rx_1                       ),  // ��һ����Ƭ��
        .i_frame_seq_1                                  (w_frame_seq_1                          ),  // ֡���
        .o_reset_1                                      (w_reset_1                              ),  // �˿�1��λ�ź�
    `endif
    `ifdef MAC2
        .o_hash_ploy_regs_2                             (w_hash_ploy_regs_2                       ),  // ��ϣ����ʽ
        .o_hash_init_val_regs_2                         (w_hash_init_val_regs_2                       ),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_2                              (w_hash_regs_vld_2                          ),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_2                       (w_port_rxmac_down_regs_2                   ),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_2                   (w_port_broadcast_drop_regs_2                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_2                   (w_port_multicast_drop_regs_2                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_2                    (w_port_loopback_drop_regs_2                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_2                              (w_port_mac_regs_2                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_2                          (w_port_mac_vld_regs_2                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_2                              (w_port_mtu_regs_2                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_2                      (w_port_mirror_frwd_regs_2                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_2                     (w_port_flowctrl_cfg_regs_2                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_2             (w_port_rx_ultrashortinterval_num_2             ),  // ֡���
        .o_acl_port_sel_2                               (w_acl_port_sel_2                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_2_valid							(w_acl_port_sel_2_valid							),
        .o_acl_clr_list_regs_2                          (w_acl_clr_list_regs_2                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_2                          (w_acl_list_rdy_regs_2                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_2                          (w_acl_item_sel_regs_2                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_c1            		(w_cfg_acl_item_dmac_code_c1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_c1_valid      		(w_cfg_acl_item_dmac_code_c1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_c2            		(w_cfg_acl_item_dmac_code_c2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_c2_valid      		(w_cfg_acl_item_dmac_code_c2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_c3            		(w_cfg_acl_item_dmac_code_c3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_c3_valid      		(w_cfg_acl_item_dmac_code_c3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_c4            		(w_cfg_acl_item_dmac_code_c4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_c4_valid      		(w_cfg_acl_item_dmac_code_c4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_c5            		(w_cfg_acl_item_dmac_code_c5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_c5_valid      		(w_cfg_acl_item_dmac_code_c5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_c6            		(w_cfg_acl_item_dmac_code_c6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_c6_valid      		(w_cfg_acl_item_dmac_code_c6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_c1            		(w_cfg_acl_item_smac_code_c1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_c1_valid      		(w_cfg_acl_item_smac_code_c1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_c2            		(w_cfg_acl_item_smac_code_c2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_c2_valid      		(w_cfg_acl_item_smac_code_c2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_c3            		(w_cfg_acl_item_smac_code_c3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_c3_valid      		(w_cfg_acl_item_smac_code_c3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_c4            		(w_cfg_acl_item_smac_code_c4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_c4_valid      		(w_cfg_acl_item_smac_code_c4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_c5            		(w_cfg_acl_item_smac_code_c5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_c5_valid      		(w_cfg_acl_item_smac_code_c5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_c6            		(w_cfg_acl_item_smac_code_c6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_c6_valid      		(w_cfg_acl_item_smac_code_c6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_c1            		(w_cfg_acl_item_vlan_code_c1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_c1_valid      		(w_cfg_acl_item_vlan_code_c1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_c2            		(w_cfg_acl_item_vlan_code_c2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_c2_valid      		(w_cfg_acl_item_vlan_code_c2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_c3            		(w_cfg_acl_item_vlan_code_c3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_c3_valid      		(w_cfg_acl_item_vlan_code_c3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_c4            		(w_cfg_acl_item_vlan_code_c4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_c4_valid      		(w_cfg_acl_item_vlan_code_c4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_c1       		(w_cfg_acl_item_ethertype_code_c1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_c1_valid 		(w_cfg_acl_item_ethertype_code_c1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_c2       		(w_cfg_acl_item_ethertype_code_c2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_c2_valid 		(w_cfg_acl_item_ethertype_code_c2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_c     		(w_cfg_acl_item_action_pass_state_c     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_c_valid		(w_cfg_acl_item_action_pass_state_c_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_c 		(w_cfg_acl_item_action_cb_streamhandle_c 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_c_valid	(w_cfg_acl_item_action_cb_streamhandle_c_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_c        		(w_cfg_acl_item_action_flowctrl_c        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_c_valid  		(w_cfg_acl_item_action_flowctrl_c_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_c          		(w_cfg_acl_item_action_txport_c          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_c_valid    		(w_cfg_acl_item_action_txport_c_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���        
        .i_port_diag_state_2                            (w_port_diag_state_2                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_2                     (w_port_rx_ultrashort_frm_2                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_2                     (w_port_rx_overlength_frm_2                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_2                         (w_port_rx_crcerr_frm_2                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_2                   (w_port_rx_loopback_frm_cnt_2                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_2                    (w_port_broadflow_drop_cnt_2                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_2                    (w_port_multiflow_drop_cnt_2                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_2                           (w_port_rx_byte_cnt_2                           ),  // �˿�2�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_2                          (w_port_rx_frame_cnt_2                          ),  // �˿�2����֡����������ֵ
        .i_rx_busy_2                                    (w_rx_busy_2                            ),  // ����æ�ź�
        .i_rx_fragment_cnt_2                            (w_rx_fragment_cnt_2                      ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_2                       (w_rx_fragment_mismatch_2               ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_2                             (w_err_rx_crc_cnt_2                     ),  // CRC�������
        .i_err_rx_frame_cnt_2                           (w_err_rx_frame_cnt_2                   ),  // ֡�������
        .i_err_fragment_cnt_2                           (w_err_fragment_cnt_2                   ),  // ��Ƭ�������
        .i_rx_frames_cnt_2                              (w_rx_frames_cnt_2                      ),  // ����֡����
        .i_frag_next_rx_2                               (w_frag_next_rx_2                       ),  // ��һ����Ƭ��
        .i_frame_seq_2                                  (w_frame_seq_2                          ),  // ֡���
        .o_reset_2                                      (w_reset_2                              ),  // �˿�2��λ�ź�
    `endif
    `ifdef MAC3
        .o_hash_ploy_regs_3                             (w_hash_ploy_regs_3                       		),  // ��ϣ����ʽ
        .o_hash_init_val_regs_3                         (w_hash_init_val_regs_3                       	),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_3                              (w_hash_regs_vld_3                          	),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_3                       (w_port_rxmac_down_regs_3                   	),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_3                   (w_port_broadcast_drop_regs_3                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_3                   (w_port_multicast_drop_regs_3                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_3                    (w_port_loopback_drop_regs_3                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_3                              (w_port_mac_regs_3                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_3                          (w_port_mac_vld_regs_3                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_3                              (w_port_mtu_regs_3                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_3                      (w_port_mirror_frwd_regs_3                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_3                     (w_port_flowctrl_cfg_regs_3                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_3             (w_port_rx_ultrashortinterval_num_3             ),  // ֡���
        .o_acl_port_sel_3                               (w_acl_port_sel_3                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_3_valid                         (w_acl_port_sel_3_valid                         ),  // ѡ��Ҫ���õĶ˿�
        .o_acl_clr_list_regs_3                          (w_acl_clr_list_regs_3                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_3                          (w_acl_list_rdy_regs_3                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_3                          (w_acl_item_sel_regs_3                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_d1            		(w_cfg_acl_item_dmac_code_d1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_d1_valid      		(w_cfg_acl_item_dmac_code_d1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_d2            		(w_cfg_acl_item_dmac_code_d2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_d2_valid      		(w_cfg_acl_item_dmac_code_d2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_d3            		(w_cfg_acl_item_dmac_code_d3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_d3_valid      		(w_cfg_acl_item_dmac_code_d3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_d4            		(w_cfg_acl_item_dmac_code_d4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_d4_valid      		(w_cfg_acl_item_dmac_code_d4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_d5            		(w_cfg_acl_item_dmac_code_d5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_d5_valid      		(w_cfg_acl_item_dmac_code_d5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_d6            		(w_cfg_acl_item_dmac_code_d6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_d6_valid      		(w_cfg_acl_item_dmac_code_d6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_d1            		(w_cfg_acl_item_smac_code_d1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_d1_valid      		(w_cfg_acl_item_smac_code_d1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_d2            		(w_cfg_acl_item_smac_code_d2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_d2_valid      		(w_cfg_acl_item_smac_code_d2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_d3            		(w_cfg_acl_item_smac_code_d3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_d3_valid      		(w_cfg_acl_item_smac_code_d3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_d4            		(w_cfg_acl_item_smac_code_d4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_d4_valid      		(w_cfg_acl_item_smac_code_d4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_d5            		(w_cfg_acl_item_smac_code_d5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_d5_valid      		(w_cfg_acl_item_smac_code_d5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_d6            		(w_cfg_acl_item_smac_code_d6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_d6_valid      		(w_cfg_acl_item_smac_code_d6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_d1            		(w_cfg_acl_item_vlan_code_d1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_d1_valid      		(w_cfg_acl_item_vlan_code_d1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_d2            		(w_cfg_acl_item_vlan_code_d2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_d2_valid      		(w_cfg_acl_item_vlan_code_d2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_d3            		(w_cfg_acl_item_vlan_code_d3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_d3_valid      		(w_cfg_acl_item_vlan_code_d3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_d4            		(w_cfg_acl_item_vlan_code_d4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_d4_valid      		(w_cfg_acl_item_vlan_code_d4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_d1       		(w_cfg_acl_item_ethertype_code_d1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_d1_valid 		(w_cfg_acl_item_ethertype_code_d1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_d2       		(w_cfg_acl_item_ethertype_code_d2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_d2_valid 		(w_cfg_acl_item_ethertype_code_d2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_d     		(w_cfg_acl_item_action_pass_state_d     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_d_valid		(w_cfg_acl_item_action_pass_state_d_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_d 		(w_cfg_acl_item_action_cb_streamhandle_d 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_d_valid	(w_cfg_acl_item_action_cb_streamhandle_d_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_d        		(w_cfg_acl_item_action_flowctrl_d        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_d_valid  		(w_cfg_acl_item_action_flowctrl_d_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_d          		(w_cfg_acl_item_action_txport_d          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_d_valid    		(w_cfg_acl_item_action_txport_d_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���        
        .i_port_diag_state_3                            (w_port_diag_state_3                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_3                     (w_port_rx_ultrashort_frm_3                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_3                     (w_port_rx_overlength_frm_3                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_3                         (w_port_rx_crcerr_frm_3                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_3                   (w_port_rx_loopback_frm_cnt_3                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_3                    (w_port_broadflow_drop_cnt_3                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_3                    (w_port_multiflow_drop_cnt_3                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_3                           (w_port_rx_byte_cnt_3                           ),  // �˿�3�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_3                          (w_port_rx_frame_cnt_3                          ),  // �˿�3����֡����������ֵ
        .i_rx_busy_3                                    (w_rx_busy_3                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_3                            (w_rx_fragment_cnt_3                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_3                       (w_rx_fragment_mismatch_3               ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_3                             (w_err_rx_crc_cnt_3                     ),  // CRC�������
        .i_err_rx_frame_cnt_3                           (w_err_rx_frame_cnt_3                   ),  // ֡�������
        .i_err_fragment_cnt_3                           (w_err_fragment_cnt_3                   ),  // ��Ƭ�������
        .i_rx_frames_cnt_3                              (w_rx_frames_cnt_3                      ),  // ����֡����
        .i_frag_next_rx_3                               (w_frag_next_rx_3                       ),  // ��һ����Ƭ��
        .i_frame_seq_3                                  (w_frame_seq_3                          ),  // ֡���
        .o_reset_3                                      (w_reset_3                              ),  // �˿�3��λ�ź�
    `endif
    `ifdef MAC4
        .o_hash_ploy_regs_4                             (w_hash_ploy_regs_4                       		),  // ��ϣ����ʽ
        .o_hash_init_val_regs_4                         (w_hash_init_val_regs_4                       	),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_4                              (w_hash_regs_vld_4                          	),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_4                       (w_port_rxmac_down_regs_4                   	),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_4                   (w_port_broadcast_drop_regs_4                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_4                   (w_port_multicast_drop_regs_4                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_4                    (w_port_loopback_drop_regs_4                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_4                              (w_port_mac_regs_4                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_4                          (w_port_mac_vld_regs_4                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_4                              (w_port_mtu_regs_4                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_4                      (w_port_mirror_frwd_regs_4                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_4                     (w_port_flowctrl_cfg_regs_4                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_4             (w_port_rx_ultrashortinterval_num_4             ),  // ֡���
        .o_acl_port_sel_4                               (w_acl_port_sel_4                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_4_valid							(w_acl_port_sel_4_valid							),
        .o_acl_clr_list_regs_4                          (w_acl_clr_list_regs_4                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_4                          (w_acl_list_rdy_regs_4                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_4                          (w_acl_item_sel_regs_4                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_e1            		(w_cfg_acl_item_dmac_code_e1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_e1_valid      		(w_cfg_acl_item_dmac_code_e1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_e2            		(w_cfg_acl_item_dmac_code_e2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_e2_valid      		(w_cfg_acl_item_dmac_code_e2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_e3            		(w_cfg_acl_item_dmac_code_e3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_e3_valid      		(w_cfg_acl_item_dmac_code_e3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_e4            		(w_cfg_acl_item_dmac_code_e4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_e4_valid      		(w_cfg_acl_item_dmac_code_e4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_e5            		(w_cfg_acl_item_dmac_code_e5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_e5_valid      		(w_cfg_acl_item_dmac_code_e5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_e6            		(w_cfg_acl_item_dmac_code_e6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_e6_valid      		(w_cfg_acl_item_dmac_code_e6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_e1            		(w_cfg_acl_item_smac_code_e1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_e1_valid      		(w_cfg_acl_item_smac_code_e1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_e2            		(w_cfg_acl_item_smac_code_e2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_e2_valid      		(w_cfg_acl_item_smac_code_e2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_e3            		(w_cfg_acl_item_smac_code_e3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_e3_valid      		(w_cfg_acl_item_smac_code_e3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_e4            		(w_cfg_acl_item_smac_code_e4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_e4_valid      		(w_cfg_acl_item_smac_code_e4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_e5            		(w_cfg_acl_item_smac_code_e5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_e5_valid      		(w_cfg_acl_item_smac_code_e5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_e6            		(w_cfg_acl_item_smac_code_e6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_e6_valid      		(w_cfg_acl_item_smac_code_e6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_e1            		(w_cfg_acl_item_vlan_code_e1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_e1_valid      		(w_cfg_acl_item_vlan_code_e1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_e2            		(w_cfg_acl_item_vlan_code_e2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_e2_valid      		(w_cfg_acl_item_vlan_code_e2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_e3            		(w_cfg_acl_item_vlan_code_e3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_e3_valid      		(w_cfg_acl_item_vlan_code_e3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_e4            		(w_cfg_acl_item_vlan_code_e4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_e4_valid      		(w_cfg_acl_item_vlan_code_e4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_e1       		(w_cfg_acl_item_ethertype_code_e1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_e1_valid 		(w_cfg_acl_item_ethertype_code_e1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_e2       		(w_cfg_acl_item_ethertype_code_e2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_e2_valid 		(w_cfg_acl_item_ethertype_code_e2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_e     		(w_cfg_acl_item_action_pass_state_e     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_e_valid		(w_cfg_acl_item_action_pass_state_e_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_e 		(w_cfg_acl_item_action_cb_streamhandle_e 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_e_valid	(w_cfg_acl_item_action_cb_streamhandle_e_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_e        		(w_cfg_acl_item_action_flowctrl_e        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_e_valid  		(w_cfg_acl_item_action_flowctrl_e_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_e          		(w_cfg_acl_item_action_txport_e          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_e_valid    		(w_cfg_acl_item_action_txport_e_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���
        .i_port_diag_state_4                            (w_port_diag_state_4                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_4                     (w_port_rx_ultrashort_frm_4                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_4                     (w_port_rx_overlength_frm_4                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_4                         (w_port_rx_crcerr_frm_4                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_4                   (w_port_rx_loopback_frm_cnt_4                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_4                    (w_port_broadflow_drop_cnt_4                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_4                    (w_port_multiflow_drop_cnt_4                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_4                           (w_port_rx_byte_cnt_4                           ),  // �˿�4�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_4                          (w_port_rx_frame_cnt_4                          ),  // �˿�4����֡����������ֵ
        .i_rx_busy_4                                    (w_rx_busy_4                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_4                            (w_rx_fragment_cnt_4                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_4                       (w_rx_fragment_mismatch_4                       ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_4                             (w_err_rx_crc_cnt_4                             ),  // CRC�������
        .i_err_rx_frame_cnt_4                           (w_err_rx_frame_cnt_4                           ),  // ֡�������
        .i_err_fragment_cnt_4                           (w_err_fragment_cnt_4                   ),  // ��Ƭ�������
        .i_rx_frames_cnt_4                              (w_rx_frames_cnt_4                      ),  // ����֡����
        .i_frag_next_rx_4                               (w_frag_next_rx_4                       ),  // ��һ����Ƭ��
        .i_frame_seq_4                                  (w_frame_seq_4                          ),  // ֡���
        .o_reset_4                                      (w_reset_4                              ),  // �˿�4��λ�ź�
    `endif
    `ifdef MAC5
        .o_hash_ploy_regs_5                             (w_hash_ploy_regs_5                       		),  // ��ϣ����ʽ
        .o_hash_init_val_regs_5                         (w_hash_init_val_regs_5                       	),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_5                              (w_hash_regs_vld_5                          	),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_5                       (w_port_rxmac_down_regs_5                   	),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_5                   (w_port_broadcast_drop_regs_5                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_5                   (w_port_multicast_drop_regs_5                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_5                    (w_port_loopback_drop_regs_5                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_5                              (w_port_mac_regs_5                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_5                          (w_port_mac_vld_regs_5                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_5                              (w_port_mtu_regs_5                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_5                      (w_port_mirror_frwd_regs_5                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_5                     (w_port_flowctrl_cfg_regs_5                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_5             (w_port_rx_ultrashortinterval_num_5             ),  // ֡���
        .o_acl_port_sel_5                               (w_acl_port_sel_5                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_5_valid							(w_acl_port_sel_5_valid							),
        .o_acl_clr_list_regs_5                          (w_acl_clr_list_regs_5                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_5                          (w_acl_list_rdy_regs_5                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_5                          (w_acl_item_sel_regs_5                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_f1            		(w_cfg_acl_item_dmac_code_f1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_f1_valid      		(w_cfg_acl_item_dmac_code_f1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_f2            		(w_cfg_acl_item_dmac_code_f2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_f2_valid      		(w_cfg_acl_item_dmac_code_f2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_f3            		(w_cfg_acl_item_dmac_code_f3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_f3_valid      		(w_cfg_acl_item_dmac_code_f3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_f4            		(w_cfg_acl_item_dmac_code_f4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_f4_valid      		(w_cfg_acl_item_dmac_code_f4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_f5            		(w_cfg_acl_item_dmac_code_f5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_f5_valid      		(w_cfg_acl_item_dmac_code_f5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_f6            		(w_cfg_acl_item_dmac_code_f6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_f6_valid      		(w_cfg_acl_item_dmac_code_f6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_f1            		(w_cfg_acl_item_smac_code_f1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_f1_valid      		(w_cfg_acl_item_smac_code_f1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_f2            		(w_cfg_acl_item_smac_code_f2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_f2_valid      		(w_cfg_acl_item_smac_code_f2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_f3            		(w_cfg_acl_item_smac_code_f3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_f3_valid      		(w_cfg_acl_item_smac_code_f3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_f4            		(w_cfg_acl_item_smac_code_f4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_f4_valid      		(w_cfg_acl_item_smac_code_f4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_f5            		(w_cfg_acl_item_smac_code_f5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_f5_valid      		(w_cfg_acl_item_smac_code_f5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_f6            		(w_cfg_acl_item_smac_code_f6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_f6_valid      		(w_cfg_acl_item_smac_code_f6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_f1            		(w_cfg_acl_item_vlan_code_f1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_f1_valid      		(w_cfg_acl_item_vlan_code_f1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_f2            		(w_cfg_acl_item_vlan_code_f2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_f2_valid      		(w_cfg_acl_item_vlan_code_f2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_f3            		(w_cfg_acl_item_vlan_code_f3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_f3_valid      		(w_cfg_acl_item_vlan_code_f3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_f4            		(w_cfg_acl_item_vlan_code_f4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_f4_valid      		(w_cfg_acl_item_vlan_code_f4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_f1       		(w_cfg_acl_item_ethertype_code_f1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_f1_valid 		(w_cfg_acl_item_ethertype_code_f1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_f2       		(w_cfg_acl_item_ethertype_code_f2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_f2_valid 		(w_cfg_acl_item_ethertype_code_f2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_f     		(w_cfg_acl_item_action_pass_state_f     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_f_valid		(w_cfg_acl_item_action_pass_state_f_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_f 		(w_cfg_acl_item_action_cb_streamhandle_f 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_f_valid	(w_cfg_acl_item_action_cb_streamhandle_f_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_f        		(w_cfg_acl_item_action_flowctrl_f        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_f_valid  		(w_cfg_acl_item_action_flowctrl_f_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_f          		(w_cfg_acl_item_action_txport_f          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_f_valid    		(w_cfg_acl_item_action_txport_f_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���
        .i_port_diag_state_5                            (w_port_diag_state_5                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_5                     (w_port_rx_ultrashort_frm_5                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_5                     (w_port_rx_overlength_frm_5                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_5                         (w_port_rx_crcerr_frm_5                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_5                   (w_port_rx_loopback_frm_cnt_5                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_5                    (w_port_broadflow_drop_cnt_5                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_5                    (w_port_multiflow_drop_cnt_5                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_5                           (w_port_rx_byte_cnt_5                           ),  // �˿�5�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_5                          (w_port_rx_frame_cnt_5                          ),  // �˿�5����֡����������ֵ
        .i_rx_busy_5                                    (w_rx_busy_5                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_5                            (w_rx_fragment_cnt_5                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_5                       (w_rx_fragment_mismatch_5                       ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_5                             (w_err_rx_crc_cnt_5                             ),  // CRC�������
        .i_err_rx_frame_cnt_5                           (w_err_rx_frame_cnt_5                           ),  // ֡�������
        .i_err_fragment_cnt_5                           (w_err_fragment_cnt_5                           ),  // ��Ƭ�������
        .i_rx_frames_cnt_5                              (w_rx_frames_cnt_5                      ),  // ����֡����
        .i_frag_next_rx_5                               (w_frag_next_rx_5                       ),  // ��һ����Ƭ��
        .i_frame_seq_5                                  (w_frame_seq_5                          ),  // ֡���
        .o_reset_5                                      (w_reset_5                              ),  // �˿�5��λ�ź�
    `endif
    `ifdef MAC6
        .o_hash_ploy_regs_6                             (w_hash_ploy_regs_6                       		),  // ��ϣ����ʽ
        .o_hash_init_val_regs_6                         (w_hash_init_val_regs_6                       	),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_6                              (w_hash_regs_vld_6                          	),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_6                       (w_port_rxmac_down_regs_6                   	),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_6                   (w_port_broadcast_drop_regs_6                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_6                   (w_port_multicast_drop_regs_6                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_6                    (w_port_loopback_drop_regs_6                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_6                              (w_port_mac_regs_6                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_6                          (w_port_mac_vld_regs_6                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_6                              (w_port_mtu_regs_6                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_6                      (w_port_mirror_frwd_regs_6                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_6                     (w_port_flowctrl_cfg_regs_6                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_6             (w_port_rx_ultrashortinterval_num_6             ),  // ֡���
        .o_acl_port_sel_6                               (w_acl_port_sel_6                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_6_valid							(w_acl_port_sel_6_valid                         ),  // ѡ��Ҫ���õĶ˿�
        .o_acl_clr_list_regs_6                          (w_acl_clr_list_regs_6                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_6                          (w_acl_list_rdy_regs_6                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_6                          (w_acl_item_sel_regs_6                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_g1            		(w_cfg_acl_item_dmac_code_g1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_g1_valid      		(w_cfg_acl_item_dmac_code_g1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_g2            		(w_cfg_acl_item_dmac_code_g2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_g2_valid      		(w_cfg_acl_item_dmac_code_g2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_g3            		(w_cfg_acl_item_dmac_code_g3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_g3_valid      		(w_cfg_acl_item_dmac_code_g3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_g4            		(w_cfg_acl_item_dmac_code_g4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_g4_valid      		(w_cfg_acl_item_dmac_code_g4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_g5            		(w_cfg_acl_item_dmac_code_g5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_g5_valid      		(w_cfg_acl_item_dmac_code_g5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_g6            		(w_cfg_acl_item_dmac_code_g6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_g6_valid      		(w_cfg_acl_item_dmac_code_g6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_g1            		(w_cfg_acl_item_smac_code_g1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_g1_valid      		(w_cfg_acl_item_smac_code_g1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_g2            		(w_cfg_acl_item_smac_code_g2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_g2_valid      		(w_cfg_acl_item_smac_code_g2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_g3            		(w_cfg_acl_item_smac_code_g3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_g3_valid      		(w_cfg_acl_item_smac_code_g3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_g4            		(w_cfg_acl_item_smac_code_g4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_g4_valid      		(w_cfg_acl_item_smac_code_g4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_g5            		(w_cfg_acl_item_smac_code_g5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_g5_valid      		(w_cfg_acl_item_smac_code_g5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_g6            		(w_cfg_acl_item_smac_code_g6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_g6_valid      		(w_cfg_acl_item_smac_code_g6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_g1            		(w_cfg_acl_item_vlan_code_g1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_g1_valid      		(w_cfg_acl_item_vlan_code_g1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_g2            		(w_cfg_acl_item_vlan_code_g2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_g2_valid      		(w_cfg_acl_item_vlan_code_g2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_g3            		(w_cfg_acl_item_vlan_code_g3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_g3_valid      		(w_cfg_acl_item_vlan_code_g3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_g4            		(w_cfg_acl_item_vlan_code_g4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_g4_valid      		(w_cfg_acl_item_vlan_code_g4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_g1       		(w_cfg_acl_item_ethertype_code_g1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_g1_valid 		(w_cfg_acl_item_ethertype_code_g1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_g2       		(w_cfg_acl_item_ethertype_code_g2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_g2_valid 		(w_cfg_acl_item_ethertype_code_g2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_g     		(w_cfg_acl_item_action_pass_state_g     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_g_valid		(w_cfg_acl_item_action_pass_state_g_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_g 		(w_cfg_acl_item_action_cb_streamhandle_g 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_g_valid	(w_cfg_acl_item_action_cb_streamhandle_g_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_g        		(w_cfg_acl_item_action_flowctrl_g        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_g_valid  		(w_cfg_acl_item_action_flowctrl_g_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_g          		(w_cfg_acl_item_action_txport_g          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_g_valid    		(w_cfg_acl_item_action_txport_g_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���
        .i_port_diag_state_6                            (w_port_diag_state_6                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_6                     (w_port_rx_ultrashort_frm_6                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_6                     (w_port_rx_overlength_frm_6                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_6                         (w_port_rx_crcerr_frm_6                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_6                   (w_port_rx_loopback_frm_cnt_6                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_6                    (w_port_broadflow_drop_cnt_6                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_6                    (w_port_multiflow_drop_cnt_6                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_6                           (w_port_rx_byte_cnt_6                           ),  // �˿�6�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_6                          (w_port_rx_frame_cnt_6                          ),  // �˿�6����֡����������ֵ
        .i_rx_busy_6                                    (w_rx_busy_6                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_6                            (w_rx_fragment_cnt_6                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_6                       (w_rx_fragment_mismatch_6                       ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_6                             (w_err_rx_crc_cnt_6                             ),  // CRC�������
        .i_err_rx_frame_cnt_6                           (w_err_rx_frame_cnt_6                           ),  // ֡�������
        .i_err_fragment_cnt_6                           (w_err_fragment_cnt_6                           ),  // ��Ƭ�������
        .i_rx_frames_cnt_6                              (w_rx_frames_cnt_6                              ),  // ����֡����
        .i_frag_next_rx_6                               (w_frag_next_rx_6                               ),  // ��һ����Ƭ��
        .i_frame_seq_6                                  (w_frame_seq_6                          ),  // ֡���
        .o_reset_6                                      (w_reset_6                              ),  // �˿�6��λ�ź�
    `endif
    `ifdef MAC7
        .o_hash_ploy_regs_7                             (w_hash_ploy_regs_7                       		),  // ��ϣ����ʽ
        .o_hash_init_val_regs_7                         (w_hash_init_val_regs_7                       	),  // ��ϣ����ʽ��ʼֵ
        .o_hash_regs_vld_7                              (w_hash_regs_vld_7                          	),  // ��ϣ�Ĵ�����Ч�ź�
        .o_port_rxmac_down_regs_7                       (w_port_rxmac_down_regs_7                       ),  // �˿ڽ��շ���MAC�ر�ʹ��
        .o_port_broadcast_drop_regs_7                   (w_port_broadcast_drop_regs_7                   ),  // �˿ڹ㲥֡����ʹ��
        .o_port_multicast_drop_regs_7                   (w_port_multicast_drop_regs_7                   ),  // �˿��鲥֡����ʹ��
        .o_port_loopback_drop_regs_7                    (w_port_loopback_drop_regs_7                    ),  // �˿ڻ���֡����ʹ��
        .o_port_mac_regs_7                              (w_port_mac_regs_7                              ),  // �˿ڵ� MAC ��ַ
        .o_port_mac_vld_regs_7                          (w_port_mac_vld_regs_7                          ),  // ʹ�ܶ˿� MAC ��ַ��Ч
        .o_port_mtu_regs_7                              (w_port_mtu_regs_7                              ),  // MTU����ֵ
        .o_port_mirror_frwd_regs_7                      (w_port_mirror_frwd_regs_7                      ),  // ����ת���Ĵ���
        .o_port_flowctrl_cfg_regs_7                     (w_port_flowctrl_cfg_regs_7                     ),  // ������������
        .o_port_rx_ultrashortinterval_num_7             (w_port_rx_ultrashortinterval_num_7             ),  // ֡���
        .o_acl_port_sel_7                               (w_acl_port_sel_7                               ),  // ѡ��Ҫ���õĶ˿�
		.o_acl_port_sel_7_valid                         (w_acl_port_sel_7_valid                         ),  // ѡ��Ҫ���õĶ˿�
        .o_acl_clr_list_regs_7                          (w_acl_clr_list_regs_7                          ),  // ��ռĴ����б�
        .i_acl_list_rdy_regs_7                          (w_acl_list_rdy_regs_7                          ),  // ���üĴ�����������
        .o_acl_item_sel_regs_7                          (w_acl_item_sel_regs_7                          ),  // ������Ŀѡ��
        .o_cfg_acl_item_dmac_code_h1            		(w_cfg_acl_item_dmac_code_h1            		), // �˿�ACL����-д��dmacֵ[15:0]
		.o_cfg_acl_item_dmac_code_h1_valid      		(w_cfg_acl_item_dmac_code_h1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_h2            		(w_cfg_acl_item_dmac_code_h2            		), // �˿�ACL����-д��dmacֵ[31:16]
		.o_cfg_acl_item_dmac_code_h2_valid      		(w_cfg_acl_item_dmac_code_h2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_h3            		(w_cfg_acl_item_dmac_code_h3            		), // �˿�ACL����-д��dmacֵ[47:32]
		.o_cfg_acl_item_dmac_code_h3_valid      		(w_cfg_acl_item_dmac_code_h3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_h4            		(w_cfg_acl_item_dmac_code_h4            		), // �˿�ACL����-д��dmacֵ[63:48]
		.o_cfg_acl_item_dmac_code_h4_valid      		(w_cfg_acl_item_dmac_code_h4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_h5            		(w_cfg_acl_item_dmac_code_h5            		), // �˿�ACL����-д��dmacֵ[79:64]
		.o_cfg_acl_item_dmac_code_h5_valid      		(w_cfg_acl_item_dmac_code_h5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_dmac_code_h6            		(w_cfg_acl_item_dmac_code_h6            		), // �˿�ACL����-д��dmacֵ[95:80]
		.o_cfg_acl_item_dmac_code_h6_valid      		(w_cfg_acl_item_dmac_code_h6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_h1            		(w_cfg_acl_item_smac_code_h1            		), // �˿�ACL����-д��smacֵ[15:0]
		.o_cfg_acl_item_smac_code_h1_valid      		(w_cfg_acl_item_smac_code_h1_valid      		), // д����Ч�ź�                   
		.o_cfg_acl_item_smac_code_h2            		(w_cfg_acl_item_smac_code_h2            		), // �˿�ACL����-д��smacֵ[31:16]
		.o_cfg_acl_item_smac_code_h2_valid      		(w_cfg_acl_item_smac_code_h2_valid      		), // д����Ч�ź�	                     
		.o_cfg_acl_item_smac_code_h3            		(w_cfg_acl_item_smac_code_h3            		), // �˿�ACL����-д��smacֵ[47:32]
		.o_cfg_acl_item_smac_code_h3_valid      		(w_cfg_acl_item_smac_code_h3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_h4            		(w_cfg_acl_item_smac_code_h4            		), // �˿�ACL����-д��smacֵ[63:48]
		.o_cfg_acl_item_smac_code_h4_valid      		(w_cfg_acl_item_smac_code_h4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_h5            		(w_cfg_acl_item_smac_code_h5            		), // �˿�ACL����-д��smacֵ[79:64]
		.o_cfg_acl_item_smac_code_h5_valid      		(w_cfg_acl_item_smac_code_h5_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_smac_code_h6            		(w_cfg_acl_item_smac_code_h6            		), // �˿�ACL����-д��smacֵ[95:80]
		.o_cfg_acl_item_smac_code_h6_valid      		(w_cfg_acl_item_smac_code_h6_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_h1            		(w_cfg_acl_item_vlan_code_h1            		), // �˿�ACL����-д��vlanֵ[15:0]
		.o_cfg_acl_item_vlan_code_h1_valid      		(w_cfg_acl_item_vlan_code_h1_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_h2            		(w_cfg_acl_item_vlan_code_h2            		), // �˿�ACL����-д��vlanֵ[31:16]
		.o_cfg_acl_item_vlan_code_h2_valid      		(w_cfg_acl_item_vlan_code_h2_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_h3            		(w_cfg_acl_item_vlan_code_h3            		), // �˿�ACL����-д��vlanֵ[47:32]
		.o_cfg_acl_item_vlan_code_h3_valid      		(w_cfg_acl_item_vlan_code_h3_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_vlan_code_h4            		(w_cfg_acl_item_vlan_code_h4            		), // �˿�ACL����-д��vlanֵ[63:48]
		.o_cfg_acl_item_vlan_code_h4_valid      		(w_cfg_acl_item_vlan_code_h4_valid      		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_h1       		(w_cfg_acl_item_ethertype_code_h1       		), // �˿�ACL����-д��ethertypeֵ[15:0]
		.o_cfg_acl_item_ethertype_code_h1_valid 		(w_cfg_acl_item_ethertype_code_h1_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_ethertype_code_h2       		(w_cfg_acl_item_ethertype_code_h2       		), // �˿�ACL����-д��ethertypeֵ[31:16]
		.o_cfg_acl_item_ethertype_code_h2_valid 		(w_cfg_acl_item_ethertype_code_h2_valid 		), // д����Ч�ź�
		.o_cfg_acl_item_action_pass_state_h     		(w_cfg_acl_item_action_pass_state_h     		), // �˿�ACL����-����״̬
		.o_cfg_acl_item_action_pass_state_h_valid		(w_cfg_acl_item_action_pass_state_h_valid		), // д����Ч�ź�
		.o_cfg_acl_item_action_cb_streamhandle_h 		(w_cfg_acl_item_action_cb_streamhandle_h 		), // �˿�ACL����-stream_handleֵ
		.o_cfg_acl_item_action_cb_streamhandle_h_valid	(w_cfg_acl_item_action_cb_streamhandle_h_valid	), // д����Ч�ź�
		.o_cfg_acl_item_action_flowctrl_h        		(w_cfg_acl_item_action_flowctrl_h        		), // �˿�ACL����-��������ѡ��
		.o_cfg_acl_item_action_flowctrl_h_valid  		(w_cfg_acl_item_action_flowctrl_h_valid  		), // д����Ч�ź�
		.o_cfg_acl_item_action_txport_h          		(w_cfg_acl_item_action_txport_h          		), // �˿�ACL����-���ķ��Ͷ˿�ӳ��
		.o_cfg_acl_item_action_txport_h_valid    		(w_cfg_acl_item_action_txport_h_valid    		), // д����Ч�ź�
		//  ״̬�Ĵ���
        .i_port_diag_state_7                            (w_port_diag_state_7                            ),  // �˿�״̬�Ĵ���
        .i_port_rx_ultrashort_frm_7                     (w_port_rx_ultrashort_frm_7                     ),  // �˿ڽ��ճ���֡(С��64�ֽ�)
        .i_port_rx_overlength_frm_7                     (w_port_rx_overlength_frm_7                     ),  // �˿ڽ��ճ���֡(����MTU�ֽ�)
        .i_port_rx_crcerr_frm_7                         (w_port_rx_crcerr_frm_7                         ),  // �˿ڽ���CRC����֡
        .i_port_rx_loopback_frm_cnt_7                   (w_port_rx_loopback_frm_cnt_7                   ),  // �˿ڽ��ջ���֡������ֵ
        .i_port_broadflow_drop_cnt_7                    (w_port_broadflow_drop_cnt_7                    ),  // �˿ڹ㲥��������֡������ֵ
        .i_port_multiflow_drop_cnt_7                    (w_port_multiflow_drop_cnt_7                    ),  // �˿��鲥��������֡������ֵ
        .i_port_rx_byte_cnt_7                           (w_port_rx_byte_cnt_7                           ),  // �˿�7�����ֽڸ���������ֵ
        .i_port_rx_frame_cnt_7                          (w_port_rx_frame_cnt_7                          ),  // �˿�7����֡����������ֵ
        .i_rx_busy_7                                    (w_rx_busy_7                                    ),  // ����æ�ź�
        .i_rx_fragment_cnt_7                            (w_rx_fragment_cnt_7                            ),  // ���շ�Ƭ����
        .i_rx_fragment_mismatch_7                       (w_rx_fragment_mismatch_7                       ),  // ��Ƭ��ƥ��
        .i_err_rx_crc_cnt_7                             (w_err_rx_crc_cnt_7                             ),  // CRC�������
        .i_err_rx_frame_cnt_7                           (w_err_rx_frame_cnt_7                           ),  // ֡�������
        .i_err_fragment_cnt_7                           (w_err_fragment_cnt_7                           ),  // ��Ƭ�������
        .i_rx_frames_cnt_7                              (w_rx_frames_cnt_7                              ),  // ����֡����
        .i_frag_next_rx_7                               (w_frag_next_rx_7                               ),  // ��һ����Ƭ��
        .i_frame_seq_7                                  (w_frame_seq_7                                  ),  // ֡���
        .o_reset_7                                      (w_reset_7                                      ),  // �˿�7��λ�ź�
    `endif
    /*---------------------------------------- �Ĵ������ýӿ� -------------------------------------------*/
    // �Ĵ��������ź�                     
    .i_refresh_list_pulse                           (i_refresh_list_pulse                           ),  // ˢ�¼Ĵ����б���״̬�Ĵ����Ϳ��ƼĴ�����
    .i_switch_err_cnt_clr                           (i_switch_err_cnt_clr                         ),  // ˢ�´��������
    .i_switch_err_cnt_stat                          (i_switch_err_cnt_stat                        ),  // ˢ�´���״̬�Ĵ���
    // �Ĵ���д���ƽӿ�         
    .i_switch_reg_bus_we                            (i_switch_reg_bus_we                          ),  // �Ĵ���дʹ��
    .i_switch_reg_bus_we_addr                       (i_switch_reg_bus_we_addr                     ),  // �Ĵ���д��ַ
    .i_switch_reg_bus_we_din                        (i_switch_reg_bus_we_din                      ),  // �Ĵ���д����
    .i_switch_reg_bus_we_din_v                      (i_switch_reg_bus_we_din_v                    ),  // �Ĵ���д����ʹ��
    // �Ĵ��������ƽӿ�         
    .i_switch_reg_bus_rd                            (i_switch_reg_bus_rd                        ),  // �Ĵ�����ʹ��
    .i_switch_reg_bus_rd_addr                       (i_switch_reg_bus_rd_addr                   ),  // �Ĵ�������ַ
    .o_switch_reg_bus_rd_dout                       (o_switch_reg_bus_rd_dout                   ),  // �����Ĵ�������
    .o_switch_reg_bus_rd_dout_v                     (o_switch_reg_bus_rd_dout_v                 )   // ��������Чʹ��
);

endmodule