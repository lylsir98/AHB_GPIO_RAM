`include "defines.v"
/*地址后四位判断是哪个寄存器

ctrl:0x0
data:0x4
*/
module slave (
    //
    input  wire HRESETn,
    input  wire HCLK,
    //总线接口信号
    input  wire [3:0] HMASTER,
    input  wire HMASTLOCK,

    input  wire HSELx,

    input  wire [31:0] HADDR,
    input  wire HWRITE,
    input  wire [1:0] HTRANS,
    input  wire [2:0] HSIZE,
    input  wire [2:0] HBURST,

    input  wire [31:0] HWDATA,

    output reg HREADY,
    output reg [1:0] HRESP,
    output reg [31:0] HRDATA, 
    output reg [3:0] HSPLITx,
    //GPIOA信号，当访问的地址超出GPIO的地址寄存器范围时返回error信号，
    //当接收数据完成返回ok信号
    input  wire [1:0] io_pin_i// io引脚输入可连开关上测试



);
//控制寄存器
localparam GPIO_CTRL = 4'h0;
//数据寄存器
localparam GPIO_DATA = 4'h4;
//每两位控制一个IO模式，最多支持16个IO
//0：高阻；1：输出；2：输入
reg [31:0] gpio_ctrl=32'd0;
//输入输出数据
reg [31:0] gpio_data=32'd0;
//根据仲裁结果主机号，根据译码HSELx信号来决定是否接收数据->写->根据地址写进寄存器->根据HBURST和HSIZE决定有多少个需要接收->初始化计数count，一共两个周期
//或读->从地址读出，
//第一个周期判断控制信号，做出第二个周期的寄存结果，第二个周期根据寄存结果来决定如何收数据给出回应
//主设备第一个时钟周期发出地址信号和控制信号
//从设备在第二个时钟周期数据阶段响应主设备请求，包括数据传输和响应状态
//从设备第一个时钟周期对地址进行解码和判断，并确定是否响应主设备
//在第二个时钟周期，从设备准备好数据传输给主设备，同时还需发出响应状态信号，告知主设备是否成功

//限制IO设备只收单次发送无需等待的32bits的数据，如果不是则判定为无效数据回馈ERROR
reg [31:0] HADDR_r1=32'd0; 
//reg [31:0] HADDR_r2;
//reg [31:0] HADDR_r3; 
//reg [1:0] HTRANS_r1;
//reg [1:0] HTRANS_r2;
//reg [1:0] HTRANS_r3;
//reg [2:0]HSIZE_r1; 
//reg [2:0]HSIZE_r2; 
//reg [2:0]HSIZE_r3;
//reg [1:0]HBURST_r1;
//reg [1:0]HBURST_r2;
//reg [1:0]HBURST_r3;
//reg [31:0]HWDATA_r1;
//reg [31:0]HWDATA_r2;
//reg HWRITE_r1;
//reg HWRITE_r2;
//reg HWRITE_r3;
wire is_value;
localparam IDLE=4'b0001,REV_DATA2=4'b0010,SENDor_REV_DATA2=4'b0100,NON_VALUE=4'b1000;//四个状态：等待；收数据；发数据或被读或被io写；无效值
reg [3:0] state,next_state;
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state<=IDLE;
        HADDR_r1    <=32'd0;
    end else begin
        HADDR_r1    <=  HADDR;
        state<=next_state;
    end
end

assign is_value=(HTRANS==`TRANS_NONSEQ&&HBURST==`HBURST_SINGLE&&HSIZE==`HSIZE_32);
always @(*) begin
    //next_state=IDLE;
    if (HSELx) begin
        case (state)
            IDLE: next_state = is_value ? (HWRITE?REV_DATA2:SENDor_REV_DATA2):NON_VALUE;
            REV_DATA2:next_state=(HWRITE?REV_DATA2:SENDor_REV_DATA2);
            SENDor_REV_DATA2:next_state=(HWRITE?REV_DATA2:SENDor_REV_DATA2);
            NON_VALUE:next_state=IDLE;
            default: next_state=IDLE;
        endcase
    end else begin
        next_state=IDLE;
    end
end

always @(*) begin
    if(!HRESETn)begin
            HREADY   =1'b1;
            HRDATA   =32'd0;
            gpio_ctrl=32'd0;
            gpio_data=32'd0;
            HRESP =`HRESP_OKAY;
    end else begin
        case (state)
        IDLE:begin
            HREADY   =1'b1;
            HRDATA   =32'd0;
            //gpio_ctrl=32'd0;
            //gpio_data=32'd0;
            if(is_value)begin
                HRESP =`HRESP_OKAY;
            end else begin
                HRESP =`HRESP_ERROR;
            end
        end
        REV_DATA2:begin
            case (HADDR_r1[3:0])
                GPIO_CTRL: begin
                    gpio_ctrl=HWDATA;
                    HRESP    =`HRESP_OKAY;
                    HREADY   =1'b1;
                end
                GPIO_DATA: begin
                    gpio_data = HWDATA;
                    HRESP     = `HRESP_OKAY;
                    HREADY    =1'b1;
                end
                default:begin
                    gpio_ctrl=gpio_ctrl;
                    gpio_data=gpio_data;
                    HRESP    = `HRESP_ERROR;
                    HREADY   =1'b1;
                end
            endcase
        end
        SENDor_REV_DATA2:begin
            if ((gpio_ctrl[1:0]==2'b10)&&(gpio_ctrl[3:2] == 2'b10)) begin
                HREADY       =1'b1;
                gpio_data[0] =io_pin_i[0];
                gpio_data[1] = io_pin_i[1];
                HRESP        =`HRESP_OKAY;
            end else begin
                case (HADDR_r1[3:0])
                    GPIO_CTRL: begin
                        HRDATA = gpio_ctrl;
                        HRESP  =`HRESP_OKAY;
                        HREADY =1'b1;
                    end
                    GPIO_DATA: begin
                        HRDATA = gpio_data;
                        HRESP  =`HRESP_OKAY;
                        HREADY =1'b1;
                    end
                    default: begin
                        HRDATA = 32'h0;
                        HRESP  =`HRESP_ERROR;
                        HREADY =1'b1;
                    end
                endcase
            end
        end
        NON_VALUE:begin
           // HADDR_r<=HADDR;
            HREADY =1'b1;
            HRDATA =32'd0;
            HRESP  =`HRESP_ERROR;
        end
        default: begin
            //HADDR_r<=HADDR;
            HREADY = 1'b1;
            HRDATA = 32'd0;
            HRESP  = `HRESP_OKAY;
        end
        endcase
    end
    
end

/*
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
            HREADY   =1'b1;
            HRDATA   =32'd0;
            gpio_ctrl=32'd0;
            gpio_data=32'd0;
            HRESP =`HRESP_OKAY;
    end else begin
        case (state)
        IDLE:begin
            HREADY   <=1'b1;
            HRDATA   <=32'd0;
            //gpio_ctrl=32'd0;
            //gpio_data=32'd0;
            if(is_value)begin
                HRESP <=`HRESP_OKAY;
            end else begin
                HRESP <=`HRESP_ERROR;
            end
        end
        REV_DATA2:begin
            case (HADDR_r1[3:0])
                GPIO_CTRL: begin
                    gpio_ctrl<=HWDATA;
                    HRESP    <=`HRESP_OKAY;
                    HREADY   <=1'b1;
                end
                GPIO_DATA: begin
                    gpio_data <= HWDATA;
                    HRESP     <= `HRESP_OKAY;
                    HREADY    <=1'b1;
                end
                default:begin
                    gpio_ctrl<=gpio_ctrl;
                    gpio_data<=gpio_data;
                    HRESP    <= `HRESP_ERROR;
                    HREADY   <=1'b1;
                end
            endcase
        end
        SENDor_REV_DATA2:begin
            if ((gpio_ctrl[1:0]==2'b10)&&(gpio_ctrl[3:2] == 2'b10)) begin
                HREADY       <=1'b1;
                gpio_data[0] <=io_pin_i[0];
                gpio_data[1] <= io_pin_i[1];
                HRESP        <=`HRESP_OKAY;
            end else begin
                case (HADDR_r1[3:0])
                    GPIO_CTRL: begin
                        HRDATA <= gpio_ctrl;
                        HRESP  <=`HRESP_OKAY;
                        HREADY <=1'b1;
                    end
                    GPIO_DATA: begin
                        HRDATA <= gpio_data;
                        HRESP  <=`HRESP_OKAY;
                        HREADY <=1'b1;
                    end
                    default: begin
                        HRDATA <= 32'h0;
                        HRESP  <=`HRESP_ERROR;
                        HREADY <=1'b1;
                    end
                endcase
            end
        end
        NON_VALUE:begin
           // HADDR_r<=HADDR;
            HREADY <=1'b1;
            HRDATA <=32'd0;
            HRESP  <=`HRESP_ERROR;
        end
        default: begin
            //HADDR_r<=HADDR;
            HREADY <= 1'b1;
            HRDATA <= 32'd0;
            HRESP  <= `HRESP_OKAY;
        end
        endcase
    end
    
end
*/
endmodule //slave::