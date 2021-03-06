# 串口格式定义

## 注意

- 串口符号格式为 `8N1`
- 字节的低位在前，高位在后

## 数据包格式

- 帧头255
- 模式(高位补零，补齐为一个字节，**低位在前高位在后传输**)
  - 测频 `2'b10`
  - 测时间差 `2'b01`
  - 测占空比 `2'b11`
- 数据（`int` 表示 32 位整数，**按照先低后高的顺序传输其 4 个字节**，每个字节仍然遵守先低位后高位的规则）
  - 测频：2 个 `int`
  - 测时间差： 5 个 `int`
  - 测占空比：2（测频）+5（测时间差）共 7 个 `int`

## 计算频率的方法

记先后收到的两个 `int` 分别为 `a` 和 `b`，
则待测频率 = `100MHz * (b/a)`.

## 计算时间差的方法

将收到的 5 个 `int` 加起来，设相加的结果为S，
则待测时间差 = `S * 1ns`.

## 计算占空比的方法

按上述方法算出方波的频率和正脉宽之后可直接计算。
