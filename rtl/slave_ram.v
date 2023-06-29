`include "defines.v"
/*地址后四位判断是哪个寄存器

ctrl:0x0
data:0x4
*/
module slave_ram (
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
    output reg [3:0] HSPLITx
    //GPIOA信号，当访问的地址超出GPIO的地址寄存器范围时返回error信号，
    //当接收数据完成返回ok信号 
);


reg [31:0] ram[31:0]; // 128KB RAM organized as 32K x 32 bits 
localparam IDLE=4'b0001,W_DATA=4'b0010,R_DATA=4'b0100,NON_VALUE=3'b1000;
reg [3:0] state,next_state; 
reg [31:0] HADDR_r1;
wire is_value;
assign is_value=((HSIZE==`HSIZE_32)&&(HADDR[15:0]<=32767));
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        state<=IDLE;
        HADDR_r1    <=32'd0;
    end else begin
        HADDR_r1    <=  HADDR;
        state<=next_state;
    end
end
always @(*) begin
    if (HSELx) begin
        case (state)
            IDLE: next_state = is_value ? (HWRITE?W_DATA:R_DATA):NON_VALUE;
            W_DATA:next_state=(HWRITE?W_DATA:R_DATA);
            R_DATA:next_state=(HWRITE?W_DATA:R_DATA);
            NON_VALUE:next_state=IDLE;
            default: next_state=IDLE;
        endcase
    end else begin
        next_state=IDLE;
    end
end

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
            HREADY   =1'b1;
            HRDATA   =32'd0;
            HRESP =`HRESP_OKAY;
    end else begin
        case (next_state)
        IDLE:begin
            HREADY   <=1'b1;
            HRDATA   <=32'd0;
            if(is_value)begin
                HRESP <=`HRESP_OKAY;
            end else begin
                HRESP <=`HRESP_ERROR;
            end
        end
        W_DATA:begin
            ram[HADDR_r1] <= HWDATA;
            HREADY <= 1'b1;
            HRDATA <= 32'd0;
            HRESP  <= `HRESP_OKAY;
        end
        R_DATA:begin
            HRDATA <= ram[HADDR_r1]; 
            HREADY <= 1'b1;
            HRESP  <= `HRESP_OKAY;    
        end
        NON_VALUE:begin
            HREADY <=1'b1;
            HRDATA <=32'd0;
            HRESP  <=`HRESP_ERROR;
        end
        default: begin
            HREADY <= 1'b1;
            HRDATA <= 32'd0;
            HRESP  <= `HRESP_OKAY;
        end
        endcase
    end
    
end

endmodule //slave::