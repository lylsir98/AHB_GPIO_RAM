
`include "defines.v"

module decoder (
    input  wire [31:0] HADDR,

    output reg HSELx0,
    output reg HSELx1,
    output reg HSELx2,
    output reg HSELx3

);
  // Decode based on most significant bits of the address
localparam SLAVE_RAM=16'h0000 ;   //64KROM  at 0x00000000 - 0x0000FFFF
localparam SLAVE_ROM=16'h0001;  // 128KB RAM at 0x00010000 - 0x003FFFFF
localparam SLAVE_GPIO=28'h2020000;//GPIO   at 0x20200000 - 0x2020000F
localparam SLAVE_TIMER=24'h200030;// Timer  at 0x20003000 - 0x2000301B

always @(*) begin
    HSELx0=(HADDR[31:16] ==SLAVE_ROM);
    HSELx1=(HADDR[31:8]  == SLAVE_TIMER);
    HSELx2=(HADDR[31:16] == SLAVE_RAM);
    HSELx3=(HADDR[31:4]  == SLAVE_GPIO);
end
endmodule
