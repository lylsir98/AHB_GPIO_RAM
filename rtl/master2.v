
`include "defines.v"

module master2 (
    //module
    input  wire HCLK,
    input  wire HRESETn,
    //from slave 
    input  wire HREADY,
    input  wire [31:0] HRDATA,
    input  wire [1:0] HRESP,
    //from arbiter
    input  wire HGRANTx,

    //tO arbiter slave
    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg [1:0] HTRANS,
    output reg HWRITE,
    output reg [3:0] HSIZE,
    output reg [2:0] HBURST,
    output reg [3:0] HPROT,
    //to arbiter
    output reg HBUSREQx,
    output reg HLOCKx


);

//SLAVE_GPIO=28'h2020000;//GPIO   at 0x20200000 - 0x2020000F
reg [9:0] count;
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        HBUSREQx<=0;
        HLOCKx<=0;
    end else begin
        if (!HGRANTx) begin
            HBUSREQx<=1;
            HLOCKx<=1;
        end else if(count==100)begin
            HBUSREQx<=0;
            HLOCKx<=0;
            //count<=0;
        end else begin
            HBUSREQx<=HBUSREQx;
            HLOCKx<=HLOCKx;
        end
    end
end
//HGRANTx信号为高时 获取总线使用权，开始pipline数据传输
reg [2:0] pipline_state;
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        HADDR  <= 32'hffffffff;
        HWDATA <= 32'd0;
        HTRANS <= `TRANS_IDLE;
        HWRITE <= 1'b0;
        HSIZE  <= `HSIZE_32;
        HBURST <= `HBURST_SINGLE;
        HPROT  <= 3'b000;
        pipline_state<=0;
        count<=0;
    end else if (HGRANTx)begin
        case (pipline_state)
            0: begin
                //先送地址和控制信号
                    HADDR  <=  32'h00000001;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    //HWDATA <= 32'd0;
                    HBURST   <= `HBURST_SINGLE;
                    HPROT    <= 3'b000;
                    pipline_state <= 1; 
            end
            1:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h00000004;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    HWDATA <=  32'h5555;
                    pipline_state <= 2;
                end else begin
                    pipline_state <= 1;
                end 
            end
            2:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    //HADDR_r  <=  32'd0001_0000_0000_0002;
                    HADDR  <=  32'h00000008;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    HWDATA <=  32'h5;
                    HWRITE   <=  1'b1;
                    pipline_state <= 3;
                end else begin
                    pipline_state <= 2;                    
                end
            end
            3:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h000000012;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWDATA <=  32'h7866;
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 4;
                end else begin
                    pipline_state <= 0;
                end 
            end
            4:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h00000001;
                    HTRANS   <=  `TRANS_NONSEQ; 
                    HWDATA <=  32'h3; 
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 5;
                end else begin
                    pipline_state <= 0;
                end 
            end
            5:begin
                if(HREADY)begin
                    HADDR  <=  32'h00000004;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 0;
                    count<=count+1;
                end else begin
                    pipline_state <= 0;
                end 
            end
            default:begin
                pipline_state <= 0;
            end
        endcase
    end
end
//HREADY信号拉高时发送地址与控制信号

endmodule //Verilog1