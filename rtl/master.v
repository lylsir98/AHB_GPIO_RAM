
`include "defines.v"
//主机3
module master (
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

reg [10:0] count;
always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn)begin
        HBUSREQx<=0;
        HLOCKx<=0;
    end else begin
        if (!HGRANTx) begin//&&count==0
            HBUSREQx<=1;
            HLOCKx<=1;
        //end else if(count==2000)begin
           // HBUSREQx<=0;
           // HLOCKx<=0;
            //count<=0;
        end else begin
            HBUSREQx<=HBUSREQx;
            HLOCKx<=HLOCKx;
        end
    end
end
//HGRANTx信号为高时 获取总线使用权，开始pipline数据传输
reg [4:0] pipline_state;
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
                    HADDR  <=  32'h20200000;
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
                    HADDR  <=  32'h20200004;
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
                    HADDR  <=  32'h20200000;
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
                    HADDR  <=  32'h20200004;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWDATA <=  32'h7855;
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 4;
                end else begin
                    pipline_state <= 3;
                end 
            end
            4:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200000;
                    HTRANS   <=  `TRANS_NONSEQ; 
                    HWDATA <=  32'h3; 
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 5;
                end else begin
                    pipline_state <= 4;
                end 
            end
				5:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200004;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    HWDATA <=  32'h3255;
                    HWRITE   <=  1'b1;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 6;
                end else begin
                    pipline_state <= 5;
                end 
            end
            6:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200000;
                    HTRANS   <=  `TRANS_NONSEQ; 
                    HWDATA <=  32'hf; 
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 7;
                end else begin
                    pipline_state <= 6;
                end 
            end
				7:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200004;
                    HTRANS   <=  `TRANS_NONSEQ;  
                    //HWDATA <=  32'h7855;
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 8;
                end else begin
                    pipline_state <= 7;
                end 
            end
            8:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200000;
                    HTRANS   <=  `TRANS_NONSEQ; 
                   // HWDATA <=  32'h3; 
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 9;
                end else begin
                    pipline_state <= 8;
                end 
            end
            9:begin
                if(HREADY)begin
                    HADDR  <=  32'h20200004;
                    HTRANS   <=  `TRANS_NONSEQ; 
						 //HWDATA <=  32'h6955; 
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 10;
                    count<=count+1;
                end else begin
                    pipline_state <= 9;
                end 
            end
				 10:begin
                if(HREADY&&HRESP==`HRESP_OKAY)begin
                    HADDR  <=  32'h20200000;
                    HTRANS   <=  `TRANS_NONSEQ; 
                   // HWDATA <=  32'h3; 
                    HWRITE   <=  1'b0;
                    HSIZE    <=  `HSIZE_32;
                    HBURST   <= `HBURST_SINGLE; 
                    pipline_state <= 0;
                end else begin
                    pipline_state <= 10;
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