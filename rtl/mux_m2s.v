module mux_m2s (
    input  wire HGRANTx0,
    input  wire HGRANTx1,
    input  wire HGRANTx2,
    input  wire HGRANTx3,
    input  wire [31:0] HADDR0,
    input  wire [31:0] HADDR1,
    input  wire [31:0] HADDR2,
    input  wire [31:0] HADDR3,  
    input  wire [31:0] HWDATA0,
    input  wire [31:0] HWDATA1,
    input  wire [31:0] HWDATA2,
    input  wire [31:0] HWDATA3,
    input  wire [1:0] HTRANS0,
    input  wire [1:0] HTRANS1,
    input  wire [1:0] HTRANS2,
    input  wire [1:0] HTRANS3,
    input  wire [2:0] HBURST0,
    input  wire [2:0] HBURST1,
    input  wire [2:0] HBURST2,
    input  wire [2:0] HBURST3, 
    input  wire [2:0] HSIZE0,
    input  wire [2:0] HSIZE1,
    input  wire [2:0] HSIZE2,
    input  wire [2:0] HSIZE3, 
    input  wire HWRITE0,
    input  wire HWRITE1,
    input  wire HWRITE2,
    input  wire HWRITE3,
    input  wire HBUSREQx0,
    input  wire HBUSREQx1,
    input  wire HBUSREQx2,
    input  wire HBUSREQx3,
    input  wire HLOCKx0,
    input  wire HLOCKx1,
    input  wire HLOCKx2,
    input  wire HLOCKx3,

    output reg [31:0] HADDR,
    output reg [31:0] HWDATA,
    output reg [1:0] HTRANS,
    output reg [2:0] HBURST,
    output reg [2:0] HSIZE,
    output reg HWRITE,
    output reg HBUSREQx,
    output reg HLOCKx

);

wire [3:0] GRANTx;
assign GRANTx={HGRANTx3,HGRANTx2,HGRANTx1,HGRANTx0};

always @(*) begin
    case (GRANTx)
        4'b1000:begin
            HADDR   = HADDR3;
            HWDATA  = HWDATA3;
            HTRANS  = HTRANS3;
            HBURST  = HBURST3;
            HSIZE   = HSIZE3;
            HWRITE  = HWRITE3;
            HBUSREQx= HBUSREQx3;
            HLOCKx  = HLOCKx3;
        end 
        4'b0100:begin
            HADDR   = HADDR2;
            HWDATA  = HWDATA2;
            HTRANS  = HTRANS2;
            HBURST  = HBURST2;
            HSIZE   = HSIZE2;
            HWRITE  = HWRITE2;
            HBUSREQx= HBUSREQx2;
            HLOCKx  = HLOCKx2;
        end
        4'b0010:begin
            HADDR   = HADDR1;
            HWDATA  = HWDATA1;
            HTRANS  = HTRANS1;
            HBURST  = HBURST1;
            HSIZE   = HSIZE1;
            HWRITE  = HWRITE1;
            HBUSREQx= HBUSREQx1;
            HLOCKx  = HLOCKx1;
        end
        4'b0001:begin
            HADDR   = HADDR0;
            HWDATA  = HWDATA0;
            HTRANS  = HTRANS0;
            HBURST  = HBURST0;
            HSIZE   = HSIZE0;
            HWRITE  = HWRITE0;
            HBUSREQx= HBUSREQx0;
            HLOCKx  = HLOCKx0;
        end
        default: begin
            HADDR   = HADDR1;
            HWDATA  = HWDATA1;
            HTRANS  = HTRANS1;
            HBURST  = HBURST1;
            HSIZE   = HSIZE1;
            HWRITE  = HWRITE1;
            HBUSREQx= HBUSREQx1;
            HLOCKx  = HLOCKx1;
        end
    endcase
end

endmodule //mux_m2s