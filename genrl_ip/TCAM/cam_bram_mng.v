// `include "synth_cmd_define.vh"

module cam_bram_mng #(
    parameter                       LOOK_UP_DATA_WIDTH      =      280      ,   // 需要查询的数据总位宽
    parameter                       PORT_MNG_DATA_WIDTH     =      8        ,   // Mac_port_mng 数据位宽
    parameter                       CAM_MODEL               =      1        ,   // 1 - CAM 表,0 - TCAM 表
    parameter                       CAM_NUM                 =      1024     ,   // CAM表项数量
    parameter                       ACTION_WIDTH            =      24       ,   // ACTION
    parameter                       BUFFER_WIDTH            =      LOOK_UP_DATA_WIDTH + ACTION_WIDTH        ,   // ACTION
    parameter                       DATA_CNT_WIDTH          =      clog2(LOOK_UP_DATA_WIDTH/8)              ,
    parameter                       CAM_NUM_BITCNT          =      clog2(CAM_NUM)                           ,  //
    parameter                       DATA_BITCNT             =      clog2(PORT_MNG_DATA_WIDTH)               ,  //
    parameter                       CAM_BLOCK_NUM           =      LOOK_UP_DATA_WIDTH/(PORT_MNG_DATA_WIDTH/2) // 70个CAM块
  )(
    input               wire                                            i_clk                               ,
    input               wire                                            i_rst                               ,
    /*----------------------- 根据寄存器输出操作 CAM 表的动作请求 ---------------------------------------*/
    // 查表 - look_up
    input               wire    [LOOK_UP_DATA_WIDTH-1:0]                i_look_up_data                      ,
    input               wire                                            i_look_up_data_vld                  ,
    output              wire    [CAM_NUM_BITCNT-1:0]                    o_acl_addr                          ,
    output              wire                                            o_acl_addr_vld                      ,
    // 写表 - config
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_config_data                       ,
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_config_data_mask                  ,
    input               wire   [DATA_CNT_WIDTH-1:0]                     i_config_data_cnt                   ,
    input               wire                                            i_config_data_vld                   ,

    // 改表 - change
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_change_data                       ,
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_change_data_mask                  ,
    input               wire   [DATA_CNT_WIDTH-1:0]                     i_change_data_cnt                   ,
    input               wire                                            i_change_data_vld                   ,

    // 删除表 - delete
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_delete_data                       ,
    input               wire   [(PORT_MNG_DATA_WIDTH-1):0]              i_delete_data_mask                  ,
    input               wire   [DATA_CNT_WIDTH-1:0]                     i_delete_data_cnt                   ,
    input               wire                                            i_delete_data_vld                   ,

    // 将写，改，删除的动作同步写到 action 表
    output              wire   [CAM_NUM_BITCNT-1:0]                     o_action_addra                      ,
    output              wire   [23:0]                                   o_action_din                        ,   //[23:8] - acl_fetchinfo, [7:0] - acl_frmtype
    output              wire                                            o_action_wea                        ,

    // 反压控制信号
    output              wire                                            o_busy                              ,   // 模块忙信号，高电平表示正在处理数据

    // 状态机状态输出（用于调试和同步）
    output              wire   [3:0]                                    o_fsm_state                             // 当前状态机状态
  );

  /*---------------------------------------- clog2计算函数 ---------------------------------------------*/
  function integer clog2;
    input integer value;
    integer temp;
    begin
      temp = value - 1;
      for (clog2 = 0; temp > 0; clog2 = clog2 + 1)
        temp = temp >> 1;
    end
  endfunction

  /*---------------------------------------- 参数定义 -------------------------------------------------*/
  localparam                      CAM_ADDR_WIDTH          =       4                           ;   // 每个CAM块地址位宽(16深度)
  localparam                      CAM_DATA_WIDTH          =       PORT_MNG_DATA_WIDTH/2       ;   // 每个CAM块数据位宽(4bit)
  localparam                      STAGE_BLOCKS            =       CAM_BLOCK_NUM/4 > 0 ? CAM_BLOCK_NUM/4 : CAM_BLOCK_NUM/4 + 1;//18                          ;   // 每一级流水线处理的CAM块数量
  localparam                      LOOKUP_PIPELINE_DEPTH   =       (CAM_BLOCK_NUM + STAGE_BLOCKS - 1) / STAGE_BLOCKS ;   // 计算流水线深度
  localparam                      WRITE_STATE_IDLE        =       4'b0000                     ;   // 写表状态：空闲
  localparam                      WRITE_STATE_COLLECT     =       4'b0001                     ;   // 写表状态：收集修改/删除表数据
  localparam                      WRITE_STATE_ADDR_GEN    =       4'b0010                     ;   // 写表状态：地址生成
  localparam                      WRITE_STATE_LOOKUP      =       4'b0011                     ;   // 写表状态：查表获取索引（修改/删除表用）
  localparam                      WRITE_STATE_DELETE_ALL  =       4'b0100                     ;   // 写表状态：删除指定索引的所有CAM数据
  localparam                      WRITE_STATE_READ_ORIG   =       4'b0101                     ;   // 写表状态：读取原始数据
  localparam                      WRITE_STATE_WRITE_PAIR  =       4'b0110                     ;   // 写表状态：同时写入高低4bit CAM块对
  localparam                      WRITE_STATE_NEXT_CNT    =       4'b0111                     ;   // 写表状态：下一个CAM块对
  localparam                      WRITE_STATE_DONE        =       4'b1000                     ;   // 写表状态：完成
  localparam                      OP_CONFIG               =       2'b00                       ;   // 操作类型：写表
  localparam                      OP_CHANGE               =       2'b01                       ;   // 操作类型：改表
  localparam                      OP_DELETE               =       2'b10                       ;   // 操作类型：删除表
  localparam                      CAM_BLOCKNUM_BITCNT     =       clog2(CAM_BLOCK_NUM/2)      ;   // 索引CAM对
  /*---------------------------------------- 输入信号打拍 ---------------------------------------------*/
  // 输入信号打拍
  reg     [LOOK_UP_DATA_WIDTH-1:0]                ri_look_up_data                         ;   // 查表数据打拍
  reg                                             ri_look_up_data_vld                     ;   // 查表有效信号打拍
  reg     [LOOK_UP_DATA_WIDTH-1:0]                ri_look_up_data_1d                      ;   // 查表数据打拍
  reg                                             ri_look_up_data_vld_1d                  ;   // 查表有效信号打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_config_data                          ;   // 写表数据打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_config_data_mask                     ;   // 写表掩码打拍
  reg     [DATA_CNT_WIDTH-1:0]                    ri_config_data_cnt                      ;   // 写表计数打拍
  reg                                             ri_config_data_vld                      ;   // 写表有效信号打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_change_data                          ;   // 改表数据打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_change_data_mask                     ;   // 改表掩码打拍
  reg     [DATA_CNT_WIDTH-1:0]                    ri_change_data_cnt                      ;   // 改表计数打拍
  reg                                             ri_change_data_vld                      ;   // 改表有效信号打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_delete_data                          ;   // 删除表数据打拍
  reg     [(PORT_MNG_DATA_WIDTH-1):0]             ri_delete_data_mask                     ;   // 删除表掩码打拍
  reg     [DATA_CNT_WIDTH-1:0]                    ri_delete_data_cnt                      ;   // 删除表计数打拍
  reg                                             ri_delete_data_vld                      ;   // 删除表有效信号打拍

  /*---------------------------------------- 内部寄存器信号 -------------------------------------------*/
  // 查表流水线寄存器 - 动态流水线深度
  reg     [LOOK_UP_DATA_WIDTH-1:0]                r_lookup_data_pipe     [LOOKUP_PIPELINE_DEPTH-1:0]    ;   // 查表数据流水线
  reg                                             r_lookup_vld_pipe      [LOOKUP_PIPELINE_DEPTH-1:0]    ;   // 查表有效信号流水线
  reg     [CAM_NUM-1:0]                           r_stage_and_result     [LOOKUP_PIPELINE_DEPTH-1:0]    ;   // 每级AND运算结果

  wire     [CAM_NUM-1:0]                           r_final_result                                        ;   // 最终AND运算结果
  // 写表状态机
  reg     [15:0]                                  r_state_cnt                             ;   // 状态计数器
  reg     [3:0]                                   r_fsm_cur_state                         ;   // 当前状态
  reg     [3:0]                                   r_fsm_nxt_state                         ;   // 下一状态
  reg     [CAM_BLOCKNUM_BITCNT:0]                 r_write_cnt_idx                         ;   // 写表计数索引(每次处理2个CAM块)
  reg     [3:0]                                   r_write_addr_h_idx                      ;   // 当前高4bit地址索引(0-15)
  reg     [3:0]                                   r_write_addr_l_idx                      ;   // 当前低4bit地址索引(0-15)
  reg     [1:0]                                   r_write_op_type                         ;   // 写表操作类型
  reg     [DATA_CNT_WIDTH-1:0]                    r_write_data_cnt                        ;   // 写表数据计数
  reg     [CAM_NUM_BITCNT-1:0]                    r_entry_index                           ;   // 当前处理的表项索引

  // 修改表和删除表专用信号
  reg     [CAM_NUM_BITCNT-1:0]                    r_lookup_target_index                   ;   // 查表获得的目标索引地址
  reg                                             r_lookup_target_valid                   ;   // 查表结果有效标志
  reg     [CAM_BLOCKNUM_BITCNT:0]                 r_delete_cnt_idx                        ;   // 删除操作计数索引
  reg     [CAM_BLOCKNUM_BITCNT:0]                 r_delete_cnt_idx_1d                     ;   // 删除操作计数索引
  reg     [3:0]                                   r_delete_addr_idx                       ;   // 删除操作地址索引(0-15)
  reg     [3:0]                                   r_delete_addr_idx_1d                    ;   // 删除操作地址索引打拍(用于写地址同步)
  reg                                             r_delete_phase                          ;   // 删除操作子状态: 0-读阶段, 1-写阶段
  reg                                             r_delete_complete                       ;   // 删除操作完成标志

  // 数据收集相关信号
  reg     [BUFFER_WIDTH - 1:0]                    r_collect_data_buffer                   ;   // 数据收集缓冲区
  reg     [BUFFER_WIDTH - 1:0]                    r_collect_mask_buffer                   ;   // 掩码收集缓冲区
  reg     [DATA_CNT_WIDTH-1:0]                    r_collect_byte_cnt                      ;   // 已收集的字节计数
  reg     [DATA_CNT_WIDTH-1:0]                    r_collect_total_cnt                     ;   // 总共需要收集的字节数
  reg                                             r_collect_complete                      ;   // 数据收集完成标志
  reg     [DATA_CNT_WIDTH-1:0]                    r_current_byte_idx                      ;   // 当前处理的字节索引

  // 地址展开相关
  reg     [3:0]                                   r_current_data_h                        ;   // 当前处理的高4bit数据
  reg     [3:0]                                   r_current_data_l                        ;   // 当前处理的低4bit数据
  reg     [3:0]                                   r_current_mask_h                        ;   // 当前处理的高4bit掩码
  reg     [3:0]                                   r_current_mask_l                        ;   // 当前处理的低4bit掩码
  wire     [3:0]                                   r_addr_list_h        [15:0]             ;   // 高4bit展开地址列表
  wire     [3:0]                                   r_addr_list_l        [15:0]             ;   // 低4bit展开地址列表
  wire     [4:0]                                   r_addr_count_h                          ;   // 高4bit地址数量
  wire     [4:0]                                   r_addr_count_l                          ;   // 低4bit地址数量

  // CAM块控制信号
  reg     [1:0]                                   r_cam_wea                               ;   // CAM块写使能(低高4bit)
  reg     [CAM_ADDR_WIDTH-1:0]                    r_cam_addra_low4                        ;   // CAM块写地址(低4bit块用)
  reg     [CAM_ADDR_WIDTH-1:0]                    r_cam_addra_high4                       ;   // CAM块写地址(高4bit块用)
  reg     [CAM_ADDR_WIDTH-1:0]                    r_cam_addrb   [CAM_BLOCK_NUM-1:0]       ;   // CAM块B通道读地址(查表用) - 打拍缓冲
  reg     [CAM_ADDR_WIDTH-1:0]                    r_cam_addrc   [CAM_BLOCK_NUM-1:0]       ;   // CAM块C通道读地址(写表读-修改-写用) - 打拍缓冲
  reg     [CAM_NUM-1:0]                           r_cam_dina_low4                         ;   // CAM块写数据(低4bit块用)
  reg     [CAM_NUM-1:0]                           r_cam_dina_high4                        ;   // CAM块写数据(高4bit块用)
  reg                                             r_cam_enb     [CAM_BLOCK_NUM-1:0]       ;   // CAM块B通道读使能(查表用) - 打拍缓冲
  reg                                             r_cam_enc     [CAM_BLOCK_NUM-1:0]       ;   // CAM块C通道读使能(写表读-修改-写用) - 打拍缓冲

  // 时序优化中间信号
  reg                                             r_mask_match_low                        ;   // 低4bit mask匹配结果
  reg                                             r_mask_match_high                       ;   // 高4bit mask匹配结果
  reg     [CAM_NUM-1:0]                           r_base_data_low                         ;   // 基础数据缓存(低4bit)
  reg     [CAM_NUM-1:0]                           r_base_data_high                        ;   // 基础数据缓存(高4bit)

  // 循环变量声明
  integer                                         wea_i                                   ;   // 写使能循环变量

  // 读-修改-写支持信号
  reg                                             r_read_valid                            ;   // 读取数据有效信号
  reg     [1:0]                                   r_delete_phase_cnt                      ;   // 删除阶段时序计数器

  // Action表控制
  reg     [CAM_NUM_BITCNT-1:0]                    r_action_addr                           ;   // Action表地址
  reg     [23:0]                                  r_action_data                           ;   // Action表数据
  reg                                             r_action_wea                            ;   // Action表写使能
  reg     [1:0]                                   r_action_cnt                            ;   // 动作数据接收计数器(0-2表示接收3个8位数据)

  // 控制信号
  reg                                             r_module_busy                           ;   // 模块忙标志

  /*---------------------------------------- 输出寄存器信号 -------------------------------------------*/
  reg     [CAM_NUM_BITCNT-1:0]                    ro_acl_addr                             ;   // 输出查表结果
  reg                                             ro_acl_addr_vld                         ;   // 查表结果有效
  wire                                             ro_busy                                 ;   // 输出忙信号
  reg     [1:0]                                   r_current_op_type                       ;   // 当前操作类型
  /*---------------------------------------- CAM块输出信号 --------------------------------------------*/
  wire    [CAM_NUM-1:0]                           w_cam_doutb   [CAM_BLOCK_NUM-1:0]      ;   // CAM块读数据B通道(查表用)
  wire    [CAM_NUM-1:0]                           w_cam_doutc   [CAM_BLOCK_NUM-1:0]      ;   // CAM块读数据C通道(写表读-修改-写用)

  /*---------------------------------------- 组合逻辑信号 ---------------------------------------------*/
  wire                                            w_any_write_req                         ;   // 任意写请求
  wire                                            w_input_write_req                       ;   // 原始输入写请求
  wire    [1:0]                                   w_current_op_type                       ;   // 当前操作类型
  wire    [(PORT_MNG_DATA_WIDTH-1):0]             w_current_data                          ;   // 当前数据
  wire    [(PORT_MNG_DATA_WIDTH-1):0]             w_current_mask                          ;   // 当前掩码
  wire    [DATA_CNT_WIDTH-1:0]                    w_current_cnt                           ;   // 当前计数
  wire    [LOOK_UP_DATA_WIDTH-1:0]                w_lookup_data_mux                       ;   // 查表数据多路选择
  wire                                            w_lookup_data_vld_mux                   ;   // 查表有效信号多路选择
  wire    [CAM_NUM-1:0]                           w_final_and_array [LOOKUP_PIPELINE_DEPTH-1:0];
  // 查表数据多路选择 - 正常查表或修改/删除表查表
  assign w_lookup_data_mux = (r_fsm_cur_state == WRITE_STATE_LOOKUP) ?
         r_collect_data_buffer[BUFFER_WIDTH-1:ACTION_WIDTH] :  // 修改/删除表查表使用收集完成的数据
         i_look_up_data;  // 正常查表使用输入数据

  assign w_lookup_data_vld_mux = (r_fsm_cur_state == WRITE_STATE_LOOKUP && r_state_cnt == 1'd0) ? 1'd1 :  // 修改/删除表查表阶段有效
         i_look_up_data_vld;  // 正常查表使用输入有效信号


  // 写请求检测
  assign w_any_write_req = ri_config_data_vld | ri_change_data_vld | ri_delete_data_vld;

  // 原始输入写请求检测
  assign w_input_write_req = i_config_data_vld ;//| i_change_data_vld | i_delete_data_vld;

  // 当前操作选择
  assign w_current_op_type =  i_config_data_vld ? OP_CONFIG :
         i_change_data_vld ? OP_CHANGE :
         i_delete_data_vld ? OP_DELETE : 2'd3;

  assign w_current_data = ri_config_data_vld ? ri_config_data :
         ri_change_data_vld ? ri_change_data :
         ri_delete_data_vld ? ri_delete_data : {(PORT_MNG_DATA_WIDTH){1'd0}};

  assign w_current_mask = ri_config_data_vld ? ri_config_data_mask :
         ri_change_data_vld ? ri_change_data_mask :
         ri_delete_data_vld ? ri_delete_data_mask : {(PORT_MNG_DATA_WIDTH){1'd0}};

  assign w_current_cnt = ri_config_data_vld ? ri_config_data_cnt :
         ri_change_data_vld ? ri_change_data_cnt :
         ri_delete_data_vld ? ri_delete_data_cnt : {DATA_CNT_WIDTH{1'd0}};

  /*---------------------------------------- 地址展开Generate逻辑 -----------------------------------------*/
  // 状态判断信号
  wire w_is_active_state;
  // 匹配信号数组
  wire [15:0] w_match_h, w_match_l;
  // 累计匹配计数器
  wire [4:0] w_cum_count_h [15:0];
  wire [4:0] w_cum_count_l [15:0];

  assign w_is_active_state = (r_fsm_cur_state == WRITE_STATE_ADDR_GEN) ||
         (r_fsm_cur_state == WRITE_STATE_READ_ORIG) ||
         (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR) ||
         (r_fsm_cur_state == WRITE_STATE_NEXT_CNT);



  // Generate: 生成16个匹配检测器
  genvar addr_i;
  generate
    for (addr_i = 0; addr_i < 16; addr_i = addr_i + 1)
    begin : gen_match_detect
      assign w_match_h[addr_i] = w_is_active_state &&
             ((addr_i[3:0] & r_current_mask_h) == (r_current_data_h & r_current_mask_h));
      assign w_match_l[addr_i] = w_is_active_state &&
             ((addr_i[3:0] & r_current_mask_l) == (r_current_data_l & r_current_mask_l));
    end
  endgenerate



  generate
    for (addr_i = 0; addr_i < 16; addr_i = addr_i + 1)
    begin : gen_cumulative_count
      if (addr_i == 0)
      begin
        assign w_cum_count_h[0] = w_match_h[0] ? 5'd1 : 5'd0;
        assign w_cum_count_l[0] = w_match_l[0] ? 5'd1 : 5'd0;
      end
      else
      begin
        assign w_cum_count_h[addr_i] = w_cum_count_h[addr_i-1] + (w_match_h[addr_i] ? 5'd1 : 5'd0);
        assign w_cum_count_l[addr_i] = w_cum_count_l[addr_i-1] + (w_match_l[addr_i] ? 5'd1 : 5'd0);
      end
    end
  endgenerate

  // 地址压缩存储逻辑
  generate
    for (addr_i = 0; addr_i < 16; addr_i = addr_i + 1)
    begin : gen_addr_compression

      // 高4bit优先级选择器
      wire [3:0] w_selected_addr_h;
      wire w_found_h;

      assign {w_found_h, w_selected_addr_h} =
             (w_match_h[0] && w_cum_count_h[0] == (addr_i + 1)) ? {1'b1, 4'd0} :
             (w_match_h[1] && w_cum_count_h[1] == (addr_i + 1)) ? {1'b1, 4'd1} :
             (w_match_h[2] && w_cum_count_h[2] == (addr_i + 1)) ? {1'b1, 4'd2} :
             (w_match_h[3] && w_cum_count_h[3] == (addr_i + 1)) ? {1'b1, 4'd3} :
             (w_match_h[4] && w_cum_count_h[4] == (addr_i + 1)) ? {1'b1, 4'd4} :
             (w_match_h[5] && w_cum_count_h[5] == (addr_i + 1)) ? {1'b1, 4'd5} :
             (w_match_h[6] && w_cum_count_h[6] == (addr_i + 1)) ? {1'b1, 4'd6} :
             (w_match_h[7] && w_cum_count_h[7] == (addr_i + 1)) ? {1'b1, 4'd7} :
             (w_match_h[8] && w_cum_count_h[8] == (addr_i + 1)) ? {1'b1, 4'd8} :
             (w_match_h[9] && w_cum_count_h[9] == (addr_i + 1)) ? {1'b1, 4'd9} :
             (w_match_h[10] && w_cum_count_h[10] == (addr_i + 1)) ? {1'b1, 4'd10} :
             (w_match_h[11] && w_cum_count_h[11] == (addr_i + 1)) ? {1'b1, 4'd11} :
             (w_match_h[12] && w_cum_count_h[12] == (addr_i + 1)) ? {1'b1, 4'd12} :
             (w_match_h[13] && w_cum_count_h[13] == (addr_i + 1)) ? {1'b1, 4'd13} :
             (w_match_h[14] && w_cum_count_h[14] == (addr_i + 1)) ? {1'b1, 4'd14} :
             (w_match_h[15] && w_cum_count_h[15] == (addr_i + 1)) ? {1'b1, 4'd15} :
             {1'b0, 4'd0};

      // 低4bit优先级选择器
      wire [3:0] w_selected_addr_l;
      wire w_found_l;

      assign {w_found_l, w_selected_addr_l} =
             (w_match_l[0] && w_cum_count_l[0] == (addr_i + 1)) ? {1'b1, 4'd0} :
             (w_match_l[1] && w_cum_count_l[1] == (addr_i + 1)) ? {1'b1, 4'd1} :
             (w_match_l[2] && w_cum_count_l[2] == (addr_i + 1)) ? {1'b1, 4'd2} :
             (w_match_l[3] && w_cum_count_l[3] == (addr_i + 1)) ? {1'b1, 4'd3} :
             (w_match_l[4] && w_cum_count_l[4] == (addr_i + 1)) ? {1'b1, 4'd4} :
             (w_match_l[5] && w_cum_count_l[5] == (addr_i + 1)) ? {1'b1, 4'd5} :
             (w_match_l[6] && w_cum_count_l[6] == (addr_i + 1)) ? {1'b1, 4'd6} :
             (w_match_l[7] && w_cum_count_l[7] == (addr_i + 1)) ? {1'b1, 4'd7} :
             (w_match_l[8] && w_cum_count_l[8] == (addr_i + 1)) ? {1'b1, 4'd8} :
             (w_match_l[9] && w_cum_count_l[9] == (addr_i + 1)) ? {1'b1, 4'd9} :
             (w_match_l[10] && w_cum_count_l[10] == (addr_i + 1)) ? {1'b1, 4'd10} :
             (w_match_l[11] && w_cum_count_l[11] == (addr_i + 1)) ? {1'b1, 4'd11} :
             (w_match_l[12] && w_cum_count_l[12] == (addr_i + 1)) ? {1'b1, 4'd12} :
             (w_match_l[13] && w_cum_count_l[13] == (addr_i + 1)) ? {1'b1, 4'd13} :
             (w_match_l[14] && w_cum_count_l[14] == (addr_i + 1)) ? {1'b1, 4'd14} :
             (w_match_l[15] && w_cum_count_l[15] == (addr_i + 1)) ? {1'b1, 4'd15} :
             {1'b0, 4'd0};

      // 地址列表赋值
      assign r_addr_list_h[addr_i] = w_found_h ? w_selected_addr_h : 4'd0;
      assign r_addr_list_l[addr_i] = w_found_l ? w_selected_addr_l : 4'd0;
    end
  endgenerate

  // 地址计数输出
  assign r_addr_count_h = w_cum_count_h[15];
  assign r_addr_count_l = w_cum_count_l[15];

  //////////////////////////////////////////////////////////////////

  // 输入信号打拍
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      ri_look_up_data      <= {LOOK_UP_DATA_WIDTH{1'd0}};
      ri_look_up_data_vld  <= 1'd0;
      ri_config_data       <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_config_data_mask  <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_config_data_cnt   <= {DATA_CNT_WIDTH{1'd0}};
      ri_config_data_vld   <= 1'd0;
      ri_change_data       <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_change_data_mask  <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_change_data_cnt   <= {DATA_CNT_WIDTH{1'd0}};
      ri_change_data_vld   <= 1'd0;
      ri_delete_data       <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_delete_data_mask  <= {(PORT_MNG_DATA_WIDTH){1'd0}};
      ri_delete_data_cnt   <= {DATA_CNT_WIDTH{1'd0}};
      ri_delete_data_vld   <= 1'd0;
      r_delete_cnt_idx_1d  <= 1'd0;
    end
    else
    begin
      ri_look_up_data      <= w_lookup_data_mux;
      ri_look_up_data_vld  <= w_lookup_data_vld_mux;
      ri_look_up_data_1d      <= ri_look_up_data;
      ri_look_up_data_vld_1d  <= ri_look_up_data_vld;
      ri_config_data       <= i_config_data;
      ri_config_data_mask  <= i_config_data_mask;
      ri_config_data_cnt   <= i_config_data_cnt;
      ri_config_data_vld   <= i_config_data_vld;
      ri_change_data       <= i_change_data;
      ri_change_data_mask  <= i_change_data_mask;
      ri_change_data_cnt   <= i_change_data_cnt;
      ri_change_data_vld   <= i_change_data_vld;
      ri_delete_data       <= i_delete_data;
      ri_delete_data_mask  <= i_delete_data_mask;
      ri_delete_data_cnt   <= i_delete_data_cnt;
      ri_delete_data_vld   <= i_delete_data_vld;
      r_delete_cnt_idx_1d  <= r_delete_cnt_idx;
    end
  end

  /*---------------------------------------- 查表流水线逻辑 -------------------------------------------*/
  // 流水线逻辑
  genvar stage_i , block_idx;
  generate
    for (stage_i = 0; stage_i < LOOKUP_PIPELINE_DEPTH; stage_i = stage_i + 1)
    begin : gen_lookup_pipeline
      localparam START_BLOCK = stage_i * STAGE_BLOCKS;
      localparam END_BLOCK = ((START_BLOCK + STAGE_BLOCKS) > CAM_BLOCK_NUM) ? CAM_BLOCK_NUM : (START_BLOCK + STAGE_BLOCKS);
      localparam BLOCKS_IN_STAGE = END_BLOCK - START_BLOCK;

      // 生成该级AND结果的中间信号数组
      wire [CAM_NUM-1:0] w_stage_and_array [STAGE_BLOCKS-1:0];

      for (block_idx = 0; block_idx < STAGE_BLOCKS; block_idx = block_idx + 1)
      begin : gen_stage_and_chain
        if (block_idx == 0)
        begin
          // 第一个块：如果在有效范围内则使用CAM输出，否则使用全1
          assign w_stage_and_array[0] = ((START_BLOCK + block_idx) < CAM_BLOCK_NUM) ?
                 w_cam_doutb[START_BLOCK + block_idx] :
                 {CAM_NUM{1'd1}};
        end
        else
        begin
          // 后续块：与前一个结果进行AND运算
          assign w_stage_and_array[block_idx] = ((START_BLOCK + block_idx) < CAM_BLOCK_NUM) ?
                 (w_stage_and_array[block_idx-1] & w_cam_doutb[START_BLOCK + block_idx]) :
                 w_stage_and_array[block_idx-1];
        end
      end


      // 该级的最终AND结果
      wire [CAM_NUM-1:0] w_stage_and_temp;
      assign w_stage_and_temp = (BLOCKS_IN_STAGE > 0) ? w_stage_and_array[STAGE_BLOCKS-1] : {CAM_NUM{1'd1}};

      // 流水线寄存器
      always @(posedge i_clk or posedge i_rst)
      begin
        if (i_rst)
        begin
          r_lookup_data_pipe[stage_i] <= {LOOK_UP_DATA_WIDTH{1'd0}};
          r_lookup_vld_pipe[stage_i]  <= 1'd0;
          r_stage_and_result[stage_i] <= {CAM_NUM{1'd0}};
        end
        else
        begin
          r_lookup_data_pipe[stage_i] <= (stage_i == 0) ? ri_look_up_data_1d :
                            r_lookup_data_pipe[stage_i-1];
          r_lookup_vld_pipe[stage_i]  <= (stage_i == 0) ? ri_look_up_data_vld_1d :
                           r_lookup_vld_pipe[stage_i-1];
          // 锁存AND运算结果
          r_stage_and_result[stage_i] <= ri_look_up_data_vld_1d ? w_stage_and_temp :
                            r_stage_and_result[stage_i];
        end
      end
    end
  endgenerate

  // 全局AND运算 - 将所有流水线级的AND结果进行最终AND
  // 生成全局AND结果的中间信号数组


  genvar final_and_i;
  generate
    for (final_and_i = 0; final_and_i < LOOKUP_PIPELINE_DEPTH; final_and_i = final_and_i + 1)
    begin : gen_final_and_chain
      if (final_and_i == 0)
      begin
        // 第一级：直接使用第一个流水线级的结果
        assign w_final_and_array[0] = r_stage_and_result[0];
      end
      else
      begin
        // 后续级：与前一个结果进行AND运算
        assign w_final_and_array[final_and_i] = w_final_and_array[final_and_i-1] & r_stage_and_result[final_and_i];
      end
    end
  endgenerate

  // 最终AND结果赋值
  assign r_final_result = w_final_and_array[LOOKUP_PIPELINE_DEPTH-1];

  /*---------------------------------------- 写表状态机逻辑 -------------------------------------------*/
  // 模块忙信号
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_module_busy <= 1'd0;
    end
    else
    begin
      // 在WRITE_STATE_COLLECT期间保持busy为高，直到数据收集完成
      if (r_fsm_nxt_state == WRITE_STATE_COLLECT && !(r_collect_byte_cnt <= (r_collect_total_cnt - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 }) && (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)))
      begin
        r_module_busy <= 1'd0;
      end
      else
      begin
        r_module_busy <= (w_input_write_req == 1'd1 && r_module_busy == 1'd0 || r_fsm_nxt_state != WRITE_STATE_IDLE ) ? 1'd1 :
                      (r_fsm_nxt_state == WRITE_STATE_IDLE) ? 1'd0 :  // 只有真正回到IDLE状态才清除busy
                      r_module_busy;
      end
    end
  end


  // 写表状态机 - 修改/删除表操作增加查表和删除阶段
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_state_cnt <= 16'd0;
    end
    else
    begin
      r_state_cnt <= (r_fsm_cur_state != r_fsm_nxt_state) ? 16'd0 :
                  r_state_cnt + 16'd1;
    end
  end

  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_fsm_cur_state <= WRITE_STATE_IDLE;
    end
    else
    begin
      r_fsm_cur_state <= r_fsm_nxt_state;
    end
  end

  always @(*)
  begin
    r_fsm_nxt_state = r_fsm_cur_state;
    case (r_fsm_cur_state)
      WRITE_STATE_IDLE:
        r_fsm_nxt_state = w_any_write_req ?
        (r_write_op_type == OP_CONFIG) ? WRITE_STATE_ADDR_GEN : WRITE_STATE_COLLECT :
            WRITE_STATE_IDLE;

      WRITE_STATE_COLLECT:
        r_fsm_nxt_state = r_collect_complete ? WRITE_STATE_LOOKUP :
          WRITE_STATE_COLLECT;  // 等待数据收集完成

      WRITE_STATE_ADDR_GEN:
        r_fsm_nxt_state =  WRITE_STATE_READ_ORIG ;  // 修改/删除表先查表

      WRITE_STATE_LOOKUP:
        r_fsm_nxt_state = r_state_cnt >= 16'd3 ? WRITE_STATE_DELETE_ALL :
          WRITE_STATE_LOOKUP;  // 等待查表完成（3个时钟周期）

      WRITE_STATE_DELETE_ALL:
        r_fsm_nxt_state = r_delete_complete ?
        WRITE_STATE_DONE : WRITE_STATE_DELETE_ALL;  // 完成所有字节和CAM块的删除处理后转换状态

      WRITE_STATE_READ_ORIG:
        r_fsm_nxt_state = WRITE_STATE_WRITE_PAIR;  // 读取原始数据后进行写入

      WRITE_STATE_WRITE_PAIR:
        r_fsm_nxt_state = r_state_cnt >= 16'd3 ?
        (r_write_addr_h_idx >= (r_addr_count_h - 5'd1)) && (r_write_addr_l_idx >= (r_addr_count_l - 5'd1)) ?
        WRITE_STATE_NEXT_CNT : WRITE_STATE_READ_ORIG :
            WRITE_STATE_WRITE_PAIR;

      WRITE_STATE_NEXT_CNT:
        r_fsm_nxt_state = r_write_data_cnt == ((CAM_BLOCK_NUM>>1) - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 }) ?
        WRITE_STATE_DONE :
          WRITE_STATE_IDLE;

      WRITE_STATE_DONE:
        r_fsm_nxt_state =  r_current_op_type == OP_CONFIG ?
        (r_action_cnt >= 2'd2 && w_any_write_req ) ? WRITE_STATE_IDLE : WRITE_STATE_DONE
          : WRITE_STATE_IDLE;  // 等待接收完3个8位数据(24位)后跳转到IDLE

      default:
        r_fsm_nxt_state = WRITE_STATE_IDLE;
    endcase
  end

  // 数据收集缓冲区控制 - 收集修改/删除表的完整数据
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_collect_data_buffer <= {BUFFER_WIDTH{1'd0}};
    end
    else
    begin
      r_collect_data_buffer <= ((r_fsm_cur_state == WRITE_STATE_IDLE || r_fsm_cur_state == WRITE_STATE_COLLECT )&& (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)) ?
                            {r_collect_data_buffer[BUFFER_WIDTH-1-PORT_MNG_DATA_WIDTH:0], w_current_data} :  // 左移并添加新数据到低位
                            r_collect_data_buffer;
    end
  end

  // 掩码收集缓冲区控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_collect_mask_buffer <= {BUFFER_WIDTH{1'd0}};
    end
    else
    begin
      r_collect_mask_buffer <= ((r_fsm_cur_state == WRITE_STATE_IDLE || r_fsm_cur_state == WRITE_STATE_COLLECT )&& (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)) ?
                            {r_collect_mask_buffer[BUFFER_WIDTH-1-PORT_MNG_DATA_WIDTH:0], w_current_mask} :   // 左移并添加新掩码到低位
                            r_collect_mask_buffer;
    end
  end

  // 已收集字节计数控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_collect_byte_cnt <= {DATA_CNT_WIDTH{1'd0}};
    end
    else
    begin
      r_collect_byte_cnt <= ((r_fsm_cur_state == WRITE_STATE_IDLE || r_fsm_cur_state == WRITE_STATE_COLLECT )&& (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)) ?
                         r_collect_byte_cnt + {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 }:  r_fsm_cur_state != WRITE_STATE_COLLECT ? {DATA_CNT_WIDTH{1'd0}}:  r_collect_byte_cnt;
    end
  end

  // 总共需要收集的字节数控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_collect_total_cnt <= {DATA_CNT_WIDTH{1'd0}};
    end
    else
    begin
      r_collect_total_cnt <= ((r_fsm_cur_state == WRITE_STATE_IDLE || r_fsm_cur_state == WRITE_STATE_COLLECT )&& (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)) ? (BUFFER_WIDTH >> DATA_BITCNT) :
                          r_collect_total_cnt;
    end
  end

  // 数据收集完成标志控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_collect_complete <= 1'd0;
    end
    else
    begin
      r_collect_complete <= (r_fsm_cur_state == WRITE_STATE_COLLECT && r_collect_byte_cnt >= (r_collect_total_cnt - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 })&& (ri_change_data_vld == 1'd1 || ri_delete_data_vld == 1'd1)) ? 1'd1 :
                         (r_fsm_cur_state == WRITE_STATE_IDLE) ? 1'd0 :
                         r_collect_complete;
    end
  end

  // 当前字节索引控制 - 指示当前从缓冲区取第几个字节数据
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_byte_idx <= {DATA_CNT_WIDTH{1'd0}};
    end
    else
    begin
      r_current_byte_idx <= (r_fsm_cur_state == WRITE_STATE_DONE && r_fsm_nxt_state == WRITE_STATE_IDLE) ? {DATA_CNT_WIDTH{1'd0}} :  // DONE状态完成后复位
                         (r_fsm_cur_state == WRITE_STATE_ADDR_GEN && r_write_op_type != OP_CONFIG) ? {DATA_CNT_WIDTH{1'd0}} :
                         (r_fsm_cur_state == WRITE_STATE_LOOKUP && r_write_op_type != OP_CONFIG) ? {DATA_CNT_WIDTH{1'd0}} :  // 删除状态开始时重置字节索引
                         (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2 && r_delete_addr_idx >= 4'd15 && r_current_byte_idx < ((LOOK_UP_DATA_WIDTH >> DATA_BITCNT) - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 })) ? r_current_byte_idx + {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 }:  // 删除状态完成一对CAM块后递增字节索引
                         (r_fsm_cur_state == WRITE_STATE_NEXT_CNT && r_write_op_type != OP_CONFIG) ? r_current_byte_idx + {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 } :
                         r_current_byte_idx;
    end
  end

  // 查表目标索引地址获取
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_lookup_target_index <= {CAM_NUM_BITCNT{1'd0}};
    end
    else
    begin
      r_lookup_target_index <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_state_cnt == 16'd0) ? ro_acl_addr :
                            r_lookup_target_index;
    end
  end

  // 查表结果有效标志
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_lookup_target_valid <= 1'd0;
    end
    else
    begin
      r_lookup_target_valid <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_state_cnt == 16'd0) ? 1'd1 :
                            (r_fsm_cur_state == WRITE_STATE_DELETE_ALL) ? 1'd1 :
                            (r_fsm_cur_state == WRITE_STATE_IDLE) ? 1'd0 :
                            r_lookup_target_valid;
    end
  end

  // 删除操作计数索引 - 按CAM块对递增
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_cnt_idx <= {CAM_BLOCKNUM_BITCNT{1'd0}};
    end
    else
    begin
      r_delete_cnt_idx <= (r_fsm_cur_state == WRITE_STATE_LOOKUP) ? {CAM_BLOCKNUM_BITCNT{1'd0}} :
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2 && r_delete_addr_idx >= 4'd15 && r_current_byte_idx < ((LOOK_UP_DATA_WIDTH >> DATA_BITCNT) - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 })) ? r_current_byte_idx + {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 } :  // 完成一对CAM块后，切换到下一个字节对应的CAM块对
                       r_delete_cnt_idx;
    end
  end



  // 删除操作地址索引控制 - 遍历所有16个地址
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_addr_idx <= 4'd0;
    end
    else
    begin
      r_delete_addr_idx <= (r_fsm_cur_state == WRITE_STATE_LOOKUP) ? 4'd0 :
                        (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2 && r_delete_addr_idx < 4'd15) ? r_delete_addr_idx + 4'd1 :  // 写完成后递增地址（小于15时）
                        (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2 && r_delete_addr_idx >= 4'd15 && r_current_byte_idx < ((LOOK_UP_DATA_WIDTH >> DATA_BITCNT) - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 })) ? 4'd0 :  // 完成当前字节处理后重置（还有更多字节时）
                        r_delete_addr_idx;
    end
  end

  // 删除地址索引打拍 - 用于写地址同步
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_addr_idx_1d <= 4'd0;
    end
    else
    begin
      r_delete_addr_idx_1d <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd1) ? r_delete_addr_idx :  // 在写使能拉高的时钟周期更新写地址
                           r_delete_addr_idx_1d;
    end
  end

  // 删除操作子状态控制 - 控制读写时序
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_phase <= 1'd0;
    end
    else
    begin
      r_delete_phase <= (r_fsm_cur_state != WRITE_STATE_DELETE_ALL) ? 1'd0 :  // 非删除状态重置为读阶段
                     (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2) ? ~r_delete_phase :  // 写阶段延迟后切换
                     (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd0) ? ~r_delete_phase :  // 读阶段立即切换到写阶段
                     r_delete_phase;
    end
  end

  // 删除阶段时序计数器 - 控制CAM读取到数据可用的时序
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_phase_cnt <= 2'd0;
    end
    else
    begin
      r_delete_phase_cnt <= (r_fsm_cur_state != WRITE_STATE_DELETE_ALL) ? 2'd0 :  // 非删除状态重置
                         (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd0) ? 2'd0 :  // 读阶段重置计数器
                         (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt < 2'd2) ? r_delete_phase_cnt + 2'd1 :  // 写阶段计数
                         (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2) ? 2'd0 :  // 计数完成后重置
                         r_delete_phase_cnt;
    end
  end

  // 删除完成标志控制 - 用于延迟状态转换
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_delete_complete <= 1'd0;
    end
    else
    begin
      r_delete_complete <= (r_fsm_cur_state != WRITE_STATE_DELETE_ALL) ? 1'd0 :  // 非删除状态清零
                        (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt >= 2'd2 && r_delete_addr_idx_1d >= 4'd15 && r_current_byte_idx >= ((LOOK_UP_DATA_WIDTH >> DATA_BITCNT) - {{DATA_CNT_WIDTH-1{1'd0}}, 1'd1 })) ? 1'd1 :  // 检测到删除条件完成：处理完最后一个字节
                        r_delete_complete;
    end
  end

  // 写表计数索引控制 - 控制当前处理哪个CAM块对
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_write_cnt_idx <= {CAM_BLOCKNUM_BITCNT{1'd0}};
    end
    else
    begin
      r_write_cnt_idx <= (r_fsm_cur_state == WRITE_STATE_DONE && r_fsm_nxt_state == WRITE_STATE_IDLE) ? {CAM_BLOCKNUM_BITCNT{1'd0}} :  // DONE状态完成后复位
                      (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req) ? w_current_cnt[CAM_BLOCKNUM_BITCNT-1:0] :
                      (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type != OP_CONFIG) ? r_delete_cnt_idx :  // 删除/修改表阶段使用删除计数
                      (r_fsm_cur_state == WRITE_STATE_NEXT_CNT && r_write_cnt_idx < (CAM_BLOCK_NUM>>1 - {{CAM_BLOCKNUM_BITCNT-1{1'd0}}, 1'd1 })) ? r_write_cnt_idx + {{CAM_BLOCKNUM_BITCNT-1{1'd0}}, 1'd1 } :
                      r_write_cnt_idx;
    end
  end

  // 地址索引控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_write_addr_h_idx <= 4'd0;
    end
    else
    begin
      r_write_addr_h_idx <= (r_fsm_cur_state == WRITE_STATE_ADDR_GEN || r_fsm_cur_state == WRITE_STATE_NEXT_CNT) ? 4'd0 :
                         (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_state_cnt >= 16'd3 && !(r_write_addr_h_idx >= (r_addr_count_h - 5'd1))) ? r_write_addr_h_idx + 4'd1 :
                         (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_state_cnt >= 16'd3 && (r_write_addr_h_idx >= (r_addr_count_h - 5'd1))) ? 4'd0 :
                         r_write_addr_h_idx;
    end
  end

  // 地址索引控制 - 低4bit索引
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_write_addr_l_idx <= 4'd0;
    end
    else
    begin
      r_write_addr_l_idx <= (r_fsm_cur_state == WRITE_STATE_ADDR_GEN || r_fsm_cur_state == WRITE_STATE_NEXT_CNT) ? 4'd0 :
                         (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_state_cnt >= 16'd3 && !(r_write_addr_l_idx >= (r_addr_count_l - 5'd1))) ? r_write_addr_l_idx + 4'd1 :
                         (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_state_cnt >= 16'd3 && (r_write_addr_l_idx >= (r_addr_count_l - 5'd1))) ? 4'd0 :
                         r_write_addr_l_idx;
    end
  end

  // 写表操作类型锁存
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_write_op_type <= 2'd3;
    end
    else
    begin
      r_write_op_type <= (r_fsm_cur_state == WRITE_STATE_IDLE && (i_config_data_vld==1'd1 || i_change_data_vld==1'd1 || i_delete_data_vld==1'd1)) ? w_current_op_type : //i_config_data_vld | i_change_data_vld | i_delete_data_vld
                      r_write_op_type;
    end
  end

  // 当前处理数据锁存 - 根据字节索引从缓冲区取对应的8bit数据
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_data_h <= 4'd0;
    end
    else
    begin
      r_current_data_h <= (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req == 1'd1 && r_write_op_type == OP_CONFIG) ? w_current_data[7:4] :
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_DELETE) ? r_collect_data_buffer[BUFFER_WIDTH-1-(r_current_byte_idx<<3) -: 4] :  // 删除状态从高位开始取高4bit
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_CHANGE) ? r_collect_data_buffer[BUFFER_WIDTH-1-(r_current_byte_idx<<3) -: 4] :  // 修改表从高位开始取高4bit
                       r_current_data_h;
    end
  end

  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_data_l <= 4'd0;
    end
    else
    begin
      r_current_data_l <= (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req && r_write_op_type == OP_CONFIG) ? w_current_data[3:0] :
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_DELETE) ? r_collect_data_buffer[BUFFER_WIDTH-5-(r_current_byte_idx<<3) -: 4] :  // 删除状态从高位开始取低4bit
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_CHANGE) ? r_collect_data_buffer[BUFFER_WIDTH-5-(r_current_byte_idx<<3) -: 4] :  // 修改表从高位开始取低4bit
                       r_current_data_l;
    end
  end

  // 当前处理掩码锁存 - 根据字节索引从缓冲区取对应的8bit掩码
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_mask_h <= 4'd0;
    end
    else
    begin
      r_current_mask_h <= (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req && r_write_op_type == OP_CONFIG) ? w_current_mask[7:4] :
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_DELETE) ? r_collect_mask_buffer[BUFFER_WIDTH-1-(r_current_byte_idx<<3) -: 4] :  // 删除状态从高位开始取高4bit掩码
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_CHANGE) ? r_collect_mask_buffer[BUFFER_WIDTH-1-(r_current_byte_idx<<3) -: 4] :  // 修改表从高位开始取高4bit掩码
                       r_current_mask_h;
    end
  end

  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_mask_l <= 4'd0;
    end
    else
    begin
      r_current_mask_l <= (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req && r_write_op_type == OP_CONFIG) ? w_current_mask[3:0] :
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_DELETE) ? r_collect_mask_buffer[BUFFER_WIDTH-5-(r_current_byte_idx<<3) -: 4] :  // 删除状态从高位开始取低4bit掩码
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_CHANGE) ? r_collect_mask_buffer[BUFFER_WIDTH-5-(r_current_byte_idx<<3) -: 4] :  // 修改表从高位开始取低4bit掩码
                       r_current_mask_l;
    end
  end

  // 写表数据计数锁存
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_write_data_cnt <= {DATA_CNT_WIDTH{1'd0}};
    end
    else
    begin
      r_write_data_cnt <= (r_fsm_cur_state == WRITE_STATE_DONE && r_fsm_nxt_state == WRITE_STATE_IDLE) ? {DATA_CNT_WIDTH{1'd0}} :  // DONE状态完成后复位
                       (r_fsm_cur_state == WRITE_STATE_IDLE && w_any_write_req && r_write_op_type == OP_CONFIG) ? w_current_cnt :
                       (r_fsm_cur_state == WRITE_STATE_COLLECT && r_collect_complete && r_write_op_type != OP_CONFIG) ? r_collect_total_cnt :  // 使用收集的计数
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_write_op_type == OP_CHANGE) ? r_collect_total_cnt :  // 修改表使用收集的计数
                       r_write_data_cnt;
    end
  end

  // 表项索引管理 - 删除/修改表使用查表获得的索引，写表按顺序递增分配
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_entry_index <= {CAM_NUM_BITCNT{1'd0}};
    end
    else
    begin
      r_entry_index <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_lookup_target_valid) ? r_lookup_target_index :  // 删除/修改表使用查表索引
                    (r_fsm_cur_state == WRITE_STATE_DONE && r_action_cnt >= 2'd2 && w_any_write_req && r_write_op_type == OP_CONFIG && r_entry_index < (CAM_NUM - {{CAM_NUM_BITCNT-1{1'd0}}, 1'd1 })) ? r_entry_index + {{CAM_NUM_BITCNT-1{1'd0}}, 1'd1 } :  // 写表递增分配
                    r_entry_index;
    end
  end

  /*---------------------------------------- Action表控制逻辑 -----------------------------------------*/
  // 动作数据计数器控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_action_cnt <= 2'd0;
    end
    else
    begin
      if (r_fsm_cur_state == WRITE_STATE_DONE && w_any_write_req)
      begin
        r_action_cnt <= (r_action_cnt >= 2'd2 ) ? 2'd0 : r_action_cnt + 2'd1;  // 接收3个8位数据
      end
      else if (r_fsm_cur_state != WRITE_STATE_DONE)
      begin
        r_action_cnt <= 2'd0;  // 非DONE状态时复位计数器
      end
    end
  end

  // Action表地址控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_action_addr <= {CAM_NUM_BITCNT{1'd0}};
    end
    else
    begin
      r_action_addr <= (r_fsm_cur_state == WRITE_STATE_DONE) ? r_entry_index :
                    (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_state_cnt == 16'd0) ?
                    ro_acl_addr : r_action_addr;
    end
  end

  // Action表数据控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_action_data <= {ACTION_WIDTH{1'd0}};
    end
    else
    begin
      if (r_fsm_cur_state == WRITE_STATE_DONE && w_any_write_req == 1'd1)
      begin
        case (r_action_cnt)
          2'd0:
            r_action_data[23:16] <= w_current_data;
          2'd1:
            r_action_data[15:8]  <= w_current_data;
          2'd2:
            r_action_data[7:0]   <= w_current_data;
          default:
            r_action_data <= r_action_data;
        endcase
      end
      else if (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_state_cnt == 16'd0)
      begin
        // 修改表和删除表时，从缓存中提取Action数据（高24位，因为Action数据最后传输）
        r_action_data <= r_collect_data_buffer[ACTION_WIDTH-1:0];
      end
    end
  end

  // Action表写使能控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_action_wea <= 1'd0;
    end
    else
    begin
      // 在接收完第3个8位数据时写入Action表（写表操作）
      // 或在修改表和删除表时直接写入Action表
      r_action_wea <= ((r_fsm_cur_state == WRITE_STATE_DONE && w_any_write_req && r_action_cnt == 2'd2) ||
                       (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_state_cnt == 16'd0)) ? 1'd1 : 1'd0;
    end
  end

  /*---------------------------------------- 输出寄存器逻辑 -------------------------------------------*/
  // 查表结果输出 - 流水线第4级的下一个周期输出结果

  integer rlt_i;
  reg [CAM_NUM_BITCNT-1:0] result_decimal; // 存储十进制结果

  always @(*)
  begin
    result_decimal = {CAM_NUM_BITCNT{1'd0}};
    for (rlt_i = CAM_NUM-1; rlt_i >= 0; rlt_i = rlt_i - 1)
    begin
      if (r_final_result[rlt_i] == 1'd1)
      begin
        result_decimal = rlt_i;
      end
    end
  end

  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      ro_acl_addr <= {CAM_NUM_BITCNT{1'd0}};
      ro_acl_addr_vld <= 1'd0;
    end
    else
    begin
      ro_acl_addr <= r_lookup_vld_pipe[0] ? result_decimal : {CAM_NUM_BITCNT{1'd0}};
      ro_acl_addr_vld <= r_lookup_vld_pipe[0];
    end
  end

  // 输出忙信号逻辑
  assign ro_busy = (r_fsm_cur_state == WRITE_STATE_DONE) ?
         (i_config_data_vld | i_change_data_vld | i_delete_data_vld) :
         r_module_busy;

  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_current_op_type <= 2'd3;
    end
    else
    begin
      r_current_op_type <= i_config_data_vld ? OP_CONFIG :
                        i_change_data_vld ? OP_CHANGE :
                        i_delete_data_vld ? OP_DELETE : r_current_op_type;
    end
  end

  /*---------------------------------------- 输出信号连接 ---------------------------------------------*/
  assign o_acl_addr      = ro_acl_addr;
  assign o_acl_addr_vld  = r_final_result == {CAM_NUM{1'd0}} ? 1'd0 : ro_acl_addr_vld;
  assign o_action_addra  = r_action_addr;
  assign o_action_din    = r_action_data;
  assign o_action_wea    = r_action_wea;
  assign o_busy          = ro_busy;
  assign o_fsm_state     = r_fsm_cur_state;  // 输出当前状态机状态

  /*---------------------------------------- CAM块控制逻辑 -----------------------------------------------*/
  // CAM块B通道(查表用)读地址和使能信号的时序控制 - 支持修改/删除表查表
  genvar ctrl_i;
  generate
    for (ctrl_i = 0; ctrl_i < CAM_BLOCK_NUM; ctrl_i = ctrl_i + 1)
    begin : gen_cam_ctrl_b
      always @(posedge i_clk or posedge i_rst)
      begin
        if (i_rst)
        begin
          r_cam_addrb[ctrl_i] <= {CAM_ADDR_WIDTH{1'd0}};
          r_cam_enb[ctrl_i]   <= 1'd0;
        end
        else
        begin
          if (ctrl_i % 2 == 0)
          begin  // 偶数索引：低4bit
            r_cam_addrb[ctrl_i] <= w_lookup_data_vld_mux ?
                       w_lookup_data_mux[(LOOK_UP_DATA_WIDTH - ((ctrl_i/2)<<3) - 5) : (LOOK_UP_DATA_WIDTH - ((ctrl_i/2)<<3) - 8)] :
                       r_cam_addrb[ctrl_i];
          end
          else
          begin  // 奇数索引：高4bit
            r_cam_addrb[ctrl_i] <= w_lookup_data_vld_mux ?
                       w_lookup_data_mux[(LOOK_UP_DATA_WIDTH - ((ctrl_i/2)<<3) - 1) : (LOOK_UP_DATA_WIDTH - ((ctrl_i/2)<<3) - 4)] :
                       r_cam_addrb[ctrl_i];
          end
          r_cam_enb[ctrl_i]   <= w_lookup_data_vld_mux ? 1'd1 :
                   1'd0;
        end
      end
    end
  endgenerate

  // CAM块C通道(写表读-修改-写用)读地址和使能信号的时序控制 - 支持删除所有CAM数据
  generate
    for (ctrl_i = 0; ctrl_i < CAM_BLOCK_NUM; ctrl_i = ctrl_i + 1)
    begin : gen_cam_ctrl_c
      always @(posedge i_clk or posedge i_rst)
      begin
        if (i_rst)
        begin
          r_cam_addrc[ctrl_i] <= {CAM_ADDR_WIDTH{1'd0}};
          r_cam_enc[ctrl_i]   <= 1'd0;
        end
        else
        begin
          r_cam_addrc[ctrl_i] <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && (ctrl_i/2 == r_delete_cnt_idx) && r_delete_phase == 1'd0) ? r_delete_addr_idx :  // 删除状态读阶段更新地址
                     (r_fsm_cur_state == WRITE_STATE_READ_ORIG && (ctrl_i/2 == r_write_cnt_idx) && (ctrl_i % 2 == 0)) ? r_addr_list_l[r_write_addr_l_idx] :
                     (r_fsm_cur_state == WRITE_STATE_READ_ORIG && (ctrl_i/2 == r_write_cnt_idx) && (ctrl_i % 2 == 1)) ? r_addr_list_h[r_write_addr_h_idx] :
                     r_cam_addrc[ctrl_i];  // 其他情况保持地址不变
          r_cam_enc[ctrl_i]   <= (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && (ctrl_i/2 == r_delete_cnt_idx) && r_delete_phase == 1'd0 ) ? 1'd1 :  // 删除状态读阶段读使能
                   (r_fsm_cur_state == WRITE_STATE_READ_ORIG && (ctrl_i/2 == r_write_cnt_idx)) ? 1'd1 :
                   1'd0;
        end
      end
    end
  endgenerate

  /*---------------------------------------- CAM块写控制逻辑 ---------------------------------------------*/
  // 读取原始数据的控制逻辑
  // r_read_valid 时序控制
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_read_valid <= 1'd0;
    end
    else
    begin
      r_read_valid <= (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_read_valid == 1'd0 && r_state_cnt == 16'd0) ? 1'd1 :
                   (r_fsm_cur_state == WRITE_STATE_DELETE_ALL && r_delete_phase == 1'd1 && r_delete_phase_cnt == 2'd0) ? 1'd1 :  // 删除状态读使能拉高后第3个时钟周期数据有效
                   (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && r_read_valid == 1'd1 && r_state_cnt == 16'd1) ? 1'd1 :
                   1'd0;
    end
  end

  // 增加 r_read_valid 打拍信号
  reg r_read_valid_1d;
  always @(posedge i_clk )
  begin

    r_read_valid_1d <= r_read_valid;
  end

  // CAM块写使能和地址控制
  /*---------------------------------------- 预计算控制信号 ---------------------------------*/
  // 预计算使能信号，减少组合逻辑深度
  wire w_delete_write_enable;
  wire w_pair_write_enable;
  wire w_delete_state_active;
  wire w_read_orig_state_active;
  wire w_write_pair_state_active;

  assign w_delete_write_enable = w_delete_state_active == 1'd1 && r_delete_phase_cnt == 2'd2;
  assign w_pair_write_enable = w_write_pair_state_active == 1'd1 && (r_read_valid_1d == 1'd1 && r_read_valid == 1'd1) ;
  assign w_delete_state_active = (r_fsm_cur_state == WRITE_STATE_DELETE_ALL);
  assign w_read_orig_state_active = (r_fsm_cur_state == WRITE_STATE_READ_ORIG);
  assign w_write_pair_state_active = (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR);

  /*---------------------------------------- 时序控制逻辑 ---------------------------------*/
  // 将复杂的组合逻辑转换为时序逻辑，使用流水线降低逻辑深度

  // 第一级：地址和使能信号生成
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_cam_wea[0] <= 1'b0;
      r_cam_wea[1] <= 1'b0;
      r_cam_addra_low4 <= 4'd0;
      r_cam_addra_high4 <= 4'd0;
    end
    else
    begin
      // 写使能控制 - 简化为基础使能
      r_cam_wea[0] <= w_delete_write_enable || w_pair_write_enable;
      r_cam_wea[1] <= w_delete_write_enable || w_pair_write_enable;

      // 地址控制 - 基于状态的多路选择器
      if (w_delete_state_active)
      begin
        r_cam_addra_low4 <= r_delete_addr_idx_1d;
        r_cam_addra_high4 <= r_delete_addr_idx_1d;
      end
      else if (w_read_orig_state_active || w_write_pair_state_active)
      begin
        r_cam_addra_low4 <= r_addr_list_l[r_write_addr_l_idx];
        r_cam_addra_high4 <= r_addr_list_h[r_write_addr_h_idx];
      end
      else
      begin
        r_cam_addra_low4 <= 4'd0;
        r_cam_addra_high4 <= 4'd0;
      end
    end
  end

  /*---------------------------------------- 数据路径控制 ---------------------------------*/

  // 第二级：mask匹配计算
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_mask_match_low <= 1'b0;
      r_mask_match_high <= 1'b0;
    end
    else
    begin
      // 预计算mask匹配，减少后续组合逻辑复杂度
      r_mask_match_low  <= r_delete_phase_cnt >= 2'd1 && ((r_delete_addr_idx & r_current_mask_l) == (r_current_data_l & r_current_mask_l))  ;
      r_mask_match_high <= r_delete_phase_cnt >= 2'd1 && ((r_delete_addr_idx & r_current_mask_h) == (r_current_data_h & r_current_mask_h));
    end
  end

  // 第二级：基础数据预加载
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_base_data_low <= {CAM_NUM{1'd0}};
      r_base_data_high <= {CAM_NUM{1'd0}};
    end
    else
    begin
      // 预加载基础数据
      if (w_delete_state_active)
      begin
        r_base_data_low <= w_cam_doutc[(r_delete_cnt_idx_1d << 1)];
        r_base_data_high <= w_cam_doutc[(r_delete_cnt_idx_1d << 1) + 1'd1];
      end
      else if (w_write_pair_state_active == 1'd1 && r_read_valid == 1'd1)
      begin
        r_base_data_low <= w_cam_doutc[(r_write_cnt_idx << 1)];
        r_base_data_high <= w_cam_doutc[(r_write_cnt_idx << 1) + 1'd1];
      end
      else
      begin
        r_base_data_low <= r_base_data_low ;
        r_base_data_high <=r_base_data_high;
      end
    end
  end

  // 第三级：最终数据组装
  always @(posedge i_clk or posedge i_rst)
  begin
    if (i_rst)
    begin
      r_cam_dina_low4 <= {CAM_NUM{1'd0}};
      r_cam_dina_high4 <= {CAM_NUM{1'd0}};
    end
    else
    begin
      // 默认值
      r_cam_dina_low4 <= r_base_data_low;
      r_cam_dina_high4 <= r_base_data_high;

      // 基于操作类型的简化逻辑
      if (w_delete_state_active == 1'd1 && r_delete_phase_cnt == 2'd2)
      begin
        case (r_write_op_type)
          OP_DELETE:
          begin
            r_cam_dina_low4[r_lookup_target_index] <= 1'b0;
            r_cam_dina_high4[r_lookup_target_index] <= 1'b0;
          end
          OP_CHANGE:
          begin
            r_cam_dina_low4[r_lookup_target_index] <= r_mask_match_low;
            r_cam_dina_high4[r_lookup_target_index] <= r_mask_match_high;
          end
          default:
          begin
            // 保持基础数据不变
          end
        endcase
      end
      else if (w_write_pair_state_active && w_pair_write_enable)
      begin
        r_cam_dina_low4[r_entry_index] <= 1'b1;
        r_cam_dina_high4[r_entry_index] <= 1'b1;
      end
    end
  end

  /*---------------------------------------- CAM块例化 -----------------------------------------------*/
  genvar gen_i;
  generate
    for (gen_i = 0; gen_i < CAM_BLOCK_NUM; gen_i = gen_i + 1)
    begin : gen_cam_blocks
      // CAM块例化 - 支持双读通道
      wire w_wea ;
      assign w_wea = ((gen_i % 2 == 0) ? r_cam_wea[0] : r_cam_wea[1]) &&
             ((r_fsm_cur_state == WRITE_STATE_DELETE_ALL && (r_delete_cnt_idx_1d == (gen_i >> 1))) ||
              (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && (r_write_cnt_idx == (gen_i >> 1))));
      ram_simple2port #(
                        .RAM_WIDTH          ( CAM_NUM               ),
                        .RAM_DEPTH          ( 16                    ),  // 4bit地址，16深度
                        .RAM_PERFORMANCE    ("LOW_LATENCY"          ),
                        .INIT_FILE          ()
                      ) cam_bram_inst (
                        .addra              ( (gen_i % 2 == 0) ? r_cam_addra_low4 : r_cam_addra_high4 ),   // 偶数块用低4bit地址，奇数块用高4bit地址
                        .addrb              ( r_cam_addrb[gen_i]    ),                                       // B通道：查表用读地址
                        .addrc              ( r_cam_addrc[gen_i]    ),                                       // C通道：写表读-修改-写用读地址
                        .dina               ( (gen_i % 2 == 0) ? r_cam_dina_low4  : r_cam_dina_high4  ),   // 偶数块用低4bit数据，奇数块用高4bit数据
                        .clka               ( i_clk                 ),
                        .clkb               ( i_clk                 ),                                       // B通道时钟
                        .clkc               ( i_clk                 ),                                       // C通道时钟
                        .wea                ( ((gen_i % 2 == 0) ? r_cam_wea[0] : r_cam_wea[1]) &&
                                              ((r_fsm_cur_state == WRITE_STATE_DELETE_ALL && (r_delete_cnt_idx_1d == (gen_i >> 1))) ||
                                               (r_fsm_cur_state == WRITE_STATE_WRITE_PAIR && (r_write_cnt_idx == (gen_i >> 1)))) ), // 删除状态或写入状态且对应CAM块对才使能写
                        .enb                ( r_cam_enb[gen_i]      ),                                       // B通道读使能：查表用
                        .enc                ( r_cam_enc[gen_i]      ),                                       // C通道读使能：写表读-修改-写用
                        .rstb               ( i_rst                 ),                                       // B通道复位
                        .rstc               ( i_rst                 ),                                       // C通道复位
                        .regceb             ( 1'd1                  ),                                       // B通道输出寄存器使能
                        .regcec             ( 1'd1                  ),                                       // C通道输出寄存器使能
                        .doutb              ( w_cam_doutb[gen_i]    ),                                       // B通道输出：查表用
                        .doutc              ( w_cam_doutc[gen_i]    )                                        // C通道输出：写表读-修改-写用
                      );
    end
  endgenerate

endmodule
