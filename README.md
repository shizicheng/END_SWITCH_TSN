<!--
 * @Descripttion: 
 * @version: 
 * @Author: ShiZiCheng
 * @Date: 2025-07-27 21:51:39
 * @LastEditors: ShiZiCheng
 * @LastEditTime: 2025-07-27 22:26:18
-->
# END_SWITCH_TSN

7月25日
决策点：
1.关于直通转发和存储转发与Qbu的冲突问题，每个端口支持可以配置相关优先级队列进行直通转发还是存储转发，但是端口使能Qbu功能后，该端口只有关键帧能直通转发，其余帧存储转发。
2.存储转发metadata增加长度信息，直通不需要

7月27日
1、优先级队列需要输出两个队列数据输出给qbu的pmac和emac通道
