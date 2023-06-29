`include "defines.v"

module arbiter (
    //系统信号
    input  wire HRESETn,
    input  wire HCLK,
    //来自主机的申请信号
    input  wire HBUSREQx0,
    input  wire HLOCKx0,
    input  wire HBUSREQx1,
    input  wire HLOCKx1,
    input  wire HBUSREQx2,
    input  wire HLOCKx2,
    input  wire HBUSREQx3,
    input  wire HLOCKx3,
    //控制信号 contral signal
    input  wire [31:0] HADDR,
    input  wire [1:0]  HTRANS,
    input  wire [3:0]  HSPLIT,//4个从机
    input  wire [2:0]  HBURST,
    input  wire [1:0]  HRESP,
    input  wire        HREADY,

    //输出信号
    output reg HGRANTx0,
    output reg HGRANTx1,
    output reg HGRANTx2,
    output reg HGRANTx3,

    output reg [3:0] HMASTER,
    output reg [3:0] HMASTERD,//流水线数据的发出主机号
    output HMASTERLOCK
    
);

//主要功能，做出仲裁
reg [1:0] grant;
reg [1:0] next_grant;

wire is_lock;
reg is_degrant;
reg [3:0] req_mask;//请求屏蔽位
reg [3:0] next_req_mask;//请求屏蔽位
//****************************授权切换状态转移********三段式状态机******************//
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        grant<=`DEFAULT_MASTER;
    end else if((is_lock&&HRESP==`HRESP_SPLIT)||(HGRANTx1 &&HRESP==`HRESP_SPLIT && !HBUSREQx2 && !HBUSREQx3)||(req_mask==4'b0000)) begin
        grant<=`DUMMY_MASTER;
    end else if(is_degrant)begin
        grant<=next_grant;
    end 
end
always@(*)begin
    if(HBUSREQx3&req_mask[3])begin
        next_grant=`HIGHEST_MASTER;
    end else if (HBUSREQx2&req_mask[2]) begin
        next_grant=`MIDULE_MASTER;
    end else begin
        next_grant=`DEFAULT_MASTER;
    end
end

always@(*)begin
    {HGRANTx3,HGRANTx2,HGRANTx1,HGRANTx0}=4'b0000;
   case (grant)
    `DUMMY_MASTER  : HGRANTx0=1'b1; 
    `DEFAULT_MASTER: HGRANTx1=1'b1;
    `MIDULE_MASTER : HGRANTx2=1'b1;
    `HIGHEST_MASTER: HGRANTx3=1'b1;
   endcase
end
//***************************产生满足状态转移的条件*******************//
//*****锁定条件******************************************************//
assign is_lock=(HGRANTx0&&HLOCKx0)||
               (HGRANTx1&&HLOCKx1)||
               (HGRANTx2&&HLOCKx2)||
               (HGRANTx3&&HLOCKx3);
assign HMASTERLOCK=is_lock;//锁定输出
//******屏蔽条件****************************

always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        req_mask <= 4'b1111;
    end else begin
        req_mask <= next_req_mask;
    end
end
always @(*) begin
    next_req_mask=req_mask|HSPLIT;
    if (HRESP==`HRESP_SPLIT) begin
        case (grant)
            4'b00: next_req_mask[0]=0;
            4'b01: next_req_mask[1]=0;
            4'b10: next_req_mask[2]=0;
            4'b11: next_req_mask[3]=0;
        endcase
    end
end
//*****释放总线切换主机***********************
reg is_fixed_lenth,is_split,is_retry;
reg [6:0] count ;
reg [6:0] next_count;
always @(*) begin
    if((HGRANTx0&&!HBUSREQx0)||
       (HGRANTx1&&!HBUSREQx1)||
       (HGRANTx2&&!HBUSREQx2)||
       (HGRANTx3&&!HBUSREQx3))begin
        is_degrant <=1'b1;
    end else if (HTRANS==`TRANS_IDLE) begin
        is_degrant <=1'b1;
    end else if (is_fixed_lenth&&(!is_lock)&&(next_count==1'b0||next_count==1'b1)) begin
        is_degrant <=1'b1;
    end else if(is_split)begin
        is_degrant <=1'b1;
    end else if (is_retry) begin
        is_degrant <=1'b1;
    end else begin
        is_degrant <=1'b0;
    end
end

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        is_fixed_lenth<=1'b0;
    end else begin
        case (HBURST)
            `HBURST_SINGLE : is_fixed_lenth<=1'b0;
            `HBURST_INCR   : is_fixed_lenth<=1'b0;    
            `HBURST_WRAP4  : is_fixed_lenth<=1'b1;   
            `HBURST_INCR4  : is_fixed_lenth<=1'b1;
            `HBURST_WRAP8  : is_fixed_lenth<=1'b1;
            `HBURST_INCR8  : is_fixed_lenth<=1'b1;
            `HBURST_WRAP16 : is_fixed_lenth<=1'b1;
            `HBURST_INCR16 : is_fixed_lenth<=1'b1; 
        endcase
    end
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        is_split<=1'b0;
    end else begin
       if(HRESP==`HRESP_SPLIT)begin
           is_split<=1'b1;
       end else begin
          is_split<=1'b0;
       end
    end
end
always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        is_retry<=1'b0;
    end else begin
       if(HRESP==`HRESP_RETRY)begin
           is_retry<=1'b1;
       end else begin
           is_retry<=1'b0;
       end
    end
end

always @(posedge HCLK or negedge HRESETn) begin
    if (!HRESETn) begin
        count<=0;
    end else begin
        count<=next_count;
    end
end
always @(*) begin
   next_count=6'b0;
   if (HTRANS==`TRANS_NONSEQ) begin
        if (HREADY) begin
            case (HBURST)
                `HBURST_SINGLE : next_count=6'd0;
                `HBURST_INCR   : next_count=6'd20;    
                `HBURST_WRAP4  : next_count=6'd3;   
                `HBURST_INCR4  : next_count=6'd3;
                `HBURST_WRAP8  : next_count=6'd7;
                `HBURST_INCR8  : next_count=6'd7;
                `HBURST_WRAP16 : next_count=6'd15;
                `HBURST_INCR16 : next_count=6'd15; 
                default: ;
            endcase
        end else begin
            case (HBURST)
                `HBURST_SINGLE : next_count=6'd1;
                `HBURST_INCR   : next_count=6'd20;    
                `HBURST_WRAP4  : next_count=6'd4;   
                `HBURST_INCR4  : next_count=6'd4;
                `HBURST_WRAP8  : next_count=6'd8;
                `HBURST_INCR8  : next_count=6'd8;
                `HBURST_WRAP16 : next_count=6'd16;
                `HBURST_INCR16 : next_count=6'd16; 
                default: ;
            endcase
        end
   end else if (HTRANS==`TRANS_BUSY) begin
        next_count=count;
   end else if(HTRANS==`TRANS_IDLE) begin
        next_count=6'd0;
   end else begin
        if (HREADY) begin
            if (count[5]) begin
                next_count=count;
            end else begin
                next_count=count-1'b1;
            end
        end else begin
            next_count=count;
        end
   end
end

endmodule //arbiter