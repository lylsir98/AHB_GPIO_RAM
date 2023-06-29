module mux_s2m (
    input  wire HSELx0,
    input  wire HSELx1,  
    input  wire HSELx2,
    input  wire HSELx3, 
    input  wire HREADY0,
    input  wire [1:0] HRESP0,
    input  wire [31:0] HRDATA0,
    input  wire [3:0] HSPLITx0,//to arbiter
    input  wire HREADY1,
    input  wire [1:0] HRESP1,
    input  wire [31:0] HRDATA1,
    input  wire [3:0] HSPLITx1,//to arbiter
    input  wire HREADY2,
    input  wire [1:0] HRESP2,
    input  wire [31:0] HRDATA2,
    input  wire [3:0] HSPLITx2,//to arbiter
    input  wire HREADY3,
    input  wire [1:0] HRESP3,
    input  wire [31:0] HRDATA3,
    input  wire [3:0] HSPLITx3,//to arbiter

    output  reg HREADY,
    output  reg [1:0] HRESP,
    output  reg [31:0] HRDATA,
    output  reg [3:0] HSPLITx//to arbiter
);

wire [3:0] HSELx;
assign HSELx={HSELx3,HSELx2,HSELx1,HSELx0};
always @(*) begin
    case (HSELx)
        4'b1000:begin
            HREADY=HREADY3;
            HRESP=HRESP3;
            HRDATA=HRDATA3;
            HSPLITx=HSPLITx3;
        end
        4'b0100:begin
            HREADY=HREADY2;
            HRESP=HRESP2;
            HRDATA=HRDATA2;
            HSPLITx=HSPLITx2;
        end
        4'b0010:begin
            HREADY=HREADY1;
            HRESP=HRESP1;
            HRDATA=HRDATA1;
            HSPLITx=HSPLITx1;
        end
        4'b0001:begin
            HREADY=HREADY0;
            HRESP=HRESP0;
            HRDATA=HRDATA0;
            HSPLITx=HSPLITx0;
        end
        default: begin
            HREADY=HREADY1;
            HRESP=HRESP1;
            HRDATA=HRDATA1;
            HSPLITx=HSPLITx1;
        end
    endcase
end

endmodule //mux_s2m