`ifndef AHB_DEFINES_V
`define AHB_DEFINES_V

`define TRANS_IDLE   2'b00
`define TRANS_BUSY   2'b01
`define TRANS_NONSEQ 2'b10
`define TRANS_SEQ    2'b11

`define HBURST_SINGLE 3'b000
`define HBURST_INCR   3'b001
`define HBURST_WRAP4  3'b010
`define HBURST_INCR4  3'b011
`define HBURST_WRAP8  3'b100
`define HBURST_INCR8  3'b101
`define HBURST_WRAP16 3'b110
`define HBURST_INCR16 3'b111

`define HSIZE_8    3'b000
`define HSIZE_16   3'b001
`define HSIZE_32   3'b010
`define HSIZE_64   3'b011
`define HSIZE_128  3'b100
`define HSIZE_256  3'b101
`define HSIZE_512  3'b110
`define HSIZE_1024 3'b111

`define DUMMY_MASTER        2'b00
`define DEFAULT_MASTER      2'b01
`define MIDULE_MASTER       2'b10
`define HIGHEST_MASTER      2'b11

`define HRESP_OKAY     2'b00
`define HRESP_ERROR    2'b01
`define HRESP_RETRY    2'b10
`define HRESP_SPLIT    2'b11


`endif
 