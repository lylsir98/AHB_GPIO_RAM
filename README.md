# AHB_GPIO_RAM
AHB总线控制GPIO与RAM
# AHB总线 
## 知识点总结 
1. AHB总线协议中，AHB从设备两个周期响应是指从设备需要在两个时钟周期内响应主设备的请求。具体来说，主设备在第一个时钟周期（地址阶段）发出地址信号和控制信号，并等待从设备的响应。从设备在第二个时钟周期（数据阶段）响应主设备的请求，包括数据传输和响应状态等。

这种两个周期的响应机制可以提高系统的可靠性和灵活性，同时也可以降低系统的复杂度。对于从设备而言，需要在第一个时钟周期内对地址信号进行解码和判断，并确定是否响应主设备的请求。在第二个时钟周期内，从设备需要准备好数据并将其传输给主设备，同时还需要发出响应状态信号，以告知主设备操作是否成功。

总之，AHB从设备两个周期响应是AHB总线协议中的一种常见机制，它可以使得从设备和主设备之间的通信更加可靠和高效。
## 综述 
此项目完成了AHB总线控制GPIO与RAM外设
包括：主机的编写，流水线传输；从机的流水线接收；仲裁机制:译码机制
## 主机 
### 主机六个状态 
+ 1:发送总线控制请求HSEQ及hlock锁定请求
+ 得到授权grant转换到下一状态
+ 2:发送地址及控制信息，等待从机响应，从机回复hready及Okay，到下一状态
+ 3:发送数据及下一数据地址形成流水
+ 4:发送数据及地址
+ 5:读取地址
## 从机（GPIO） 
### 寄存器 
+ ctrl:4'h0x0 控制寄存器
  - 每两位控制一个IO模式，最多支持16个IO
  - 0：高阻；1：输出；2：输入
+ data:4'h0x4 数据寄存器
### 过程 
1. 根据仲裁结果主机号，根据译码HSELx信号来决定是否接收数据->写->根据地址写进寄存器->根据HBURST和HSIZE决定有多少个需要接收->初始化计数count，一共两个周期；或读->从地址读出，
2. 第一个周期判断控制信号，做出第二个周期的寄存结果，第二个周期根据寄存结果来决定如何收数据给出回应
3. 主设备第一个时钟周期发出地址信号和控制信号
4. 从设备在第二个时钟周期数据阶段响应主设备请求，包括数据传输和响应状态
5. 从设备第一个时钟周期对地址进行解码和判断，并确定是否响应主设备
6. 在第二个时钟周期，从设备准备好数据传输给主设备，同时还需发出响应状态信号，告知主设备是否成功
### 从机反馈错误 
1. 限制IO设备只收单次发送无需等待的32bits的数据，如果不是则判定为无效数据回馈ERROR
### 从机状态 
1.  四个状态：等待；收数据；发数据或被读或被io写；无效值
2.  从机数据有效
 + 地址范围正确，传输类型，大小正确 
 + ```verilog
    assign is_value=(HTRANS==`TRANS_NONSEQ&&HBURST==`HBURST_SINGLE&&HSIZE==`HSIZE_32);
   ```
3. 写有效则跳转接受数据状态，否则为读状态，数据无效的话继续等待状态
4. 接收数据写状态，若写继续有效，则状态不变，否则跳转到，读状态即发送数据状态
5. 错误状态即跳转到等待状态
6. 读写状态看地址后四位，将数据写入寄存器或读出寄存器，并给出主机响应
## 多路选择器 
### 主机到从机 
1. 根据授权，将获得仲裁的主机想要传输的数据路由到总线上
### 从机到主机 
1. 根据译码地址结果，选择将被选中从机的数据路由到总线上
## 从机（RAM） 
实现单数据的流水线传输
### 寄存器 
```verilog
    reg [31:0] ram[31:0]; // 128KB RAM organized as 32K x 32 bits 
```
### 过程 
1. 判断数据是否有效
+ 地址范围是否正确，是否超出最大地址，传输方式burst是否正确，传输大小size是否正确。
+ 四个状态，如上GPIO，进行数据的写入读取
## 仲裁器 
### 主要思路 
1. 根据主机的申请和数据传输类型burst及从机的响应类型进行仲裁
2. 复位 默认主机
3. 锁定传输与分割传输或分割传输，其他无申请，或申请全部屏蔽，则默认DUMMY 主机
4. 下一个主机
5. 锁定传输未结束不能切换主机
6. 释放总线再切换
   + 传输状态为等待状态
   + 固定长度，锁定传输，最后一个数据时，可释放总线
   + 分割传输
   + 重传 
7. 根据burst传输类型来确定是否为固定传输
### 仲裁优先级顺序 
1. 3 2 1 0 
2. 默认是default master,最高级为3，次高级为2，默认为1，出现分割传输则为主机0 
## 译码器 
1. 根据地址判断使能哪个从机 
