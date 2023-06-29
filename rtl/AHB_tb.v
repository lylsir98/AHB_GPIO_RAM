`timescale 1ns/1ns
module master_tb;

  // Parameters

  // Ports
  reg  HRESETn = 0;
  reg  HCLK = 0;
  reg [1:0] io_pin_i=2'b11;
  wire [3:0] HPROT;


  wire [3:0] HMASTER;
  wire [3:0] HMASTERD;
  wire HMASTERLOCK;

  wire HSELx0;
  wire HSELx1;
  wire HSELx2;
  wire HSELx3;

  wire HGRANTx0;
  wire HGRANTx1;
  wire HGRANTx2;
  wire HGRANTx3;
  wire [31:0] HADDR0;
  wire [31:0] HADDR1;
  wire [31:0] HADDR2;
  wire [31:0] HADDR3;
  wire [31:0] HWDATA0;
  wire [31:0] HWDATA1;
  wire [31:0] HWDATA2;
  wire [31:0] HWDATA3;
  wire [1:0] HTRANS0;
  wire [1:0] HTRANS1;
  wire [1:0] HTRANS2;
  wire [1:0] HTRANS3;
  wire [2:0] HBURST0;
  wire [2:0] HBURST1;
  wire [2:0] HBURST2;
  wire [2:0] HBURST3;
  wire [2:0] HSIZE0;
  wire [2:0] HSIZE1;
  wire [2:0] HSIZE2;
  wire [2:0] HSIZE3;
  wire HWRITE0;
  wire HWRITE1;
  wire HWRITE2;
  wire HWRITE3;
  wire HBUSREQx0;
  reg HBUSREQx1;
  wire HBUSREQx2;
  wire HBUSREQx3;
  wire HLOCKx0;
  wire HLOCKx1;
  wire HLOCKx2;
  wire HLOCKx3;
  wire [31:0] HADDR;
  wire [31:0] HWDATA;
  wire [1:0] HTRANS;
  wire [2:0] HBURST;
  wire [2:0] HSIZE;
  wire HWRITE;
  wire HBUSREQx;
  wire HLOCKx;


  wire HREADY0;
  wire [1:0] HRESP0;
  wire [31:0] HRDATA0;
  wire [3:0] HSPLITx0;//to arbiter
  wire HREADY1;
  wire [1:0] HRESP1;
  wire [31:0] HRDATA1;
  wire [3:0] HSPLITx1;//to arbiter
  wire HREADY2;
  wire [1:0] HRESP2;
  wire [31:0] HRDATA2;
  wire [3:0] HSPLITx2;//to arbiter
  wire HREADY3;
  wire [1:0] HRESP3;
  wire [31:0] HRDATA3;
  wire [3:0] HSPLITx3;//to arbiter
  wire HREADY;
  wire [1:0] HRESP;
  wire [31:0] HRDATA;
  wire [3:0] HSPLITx;//to arbi


  master master_dut (
    .HCLK (HCLK),
    .HRESETn (HRESETn ),
    .HREADY (HREADY ),
    .HRDATA (HRDATA ),
    .HRESP (HRESP ),
    .HGRANTx (HGRANTx3 ),
    .HADDR (HADDR3 ),
    .HWDATA (HWDATA3 ),
    .HTRANS (HTRANS3 ),
    .HWRITE (HWRITE3 ),
    .HSIZE (HSIZE3 ),
    .HBURST (HBURST3 ),
    .HPROT ( ),
    .HBUSREQx (HBUSREQx3 ),
    .HLOCKx  ( HLOCKx3)
  );
  
  master2 master_dut2 (
    .HCLK (HCLK),
    .HRESETn (HRESETn ),
    .HREADY (HREADY ),
    .HRDATA (HRDATA ),
    .HRESP (HRESP ),
    .HGRANTx (HGRANTx2 ),
    .HADDR (HADDR2 ),
    .HWDATA (HWDATA2 ),
    .HTRANS (HTRANS2 ),
    .HWRITE (HWRITE2 ),
    .HSIZE (HSIZE2 ),
    .HBURST (HBURST2 ),
    .HPROT ( ),
    .HBUSREQx (HBUSREQx2 ),
    .HLOCKx  ( HLOCKx2)
  );
  
  mux_m2s mux_m2s_dut (
    .HGRANTx0 (HGRANTx0 ),
    .HGRANTx1 (HGRANTx1 ),
    .HGRANTx2 (HGRANTx2 ),
    .HGRANTx3 (HGRANTx3 ),
    .HADDR0 (HADDR0 ),
    .HADDR1 (HADDR1 ),
    .HADDR2 (HADDR2 ),
    .HADDR3 (HADDR3 ),
    .HWDATA0 (HWDATA0 ),
    .HWDATA1 (HWDATA1 ),
    .HWDATA2 (HWDATA2 ),
    .HWDATA3 (HWDATA3 ),
    .HTRANS0 (HTRANS0 ),
    .HTRANS1 (HTRANS1 ),
    .HTRANS2 (HTRANS2 ),
    .HTRANS3 (HTRANS3 ),
    .HBURST0 (HBURST0 ),
    .HBURST1 (HBURST1 ),
    .HBURST2 (HBURST2 ),
    .HBURST3 (HBURST3 ),
    .HSIZE0 (HSIZE0 ),
    .HSIZE1 (HSIZE1 ),
    .HSIZE2 (HSIZE2 ),
    .HSIZE3 (HSIZE3 ),
    .HWRITE0 (HWRITE0 ),
    .HWRITE1 (HWRITE1 ),
    .HWRITE2 (HWRITE2 ),
    .HWRITE3 (HWRITE3 ),
    .HBUSREQx0 (HBUSREQx0 ),
    .HBUSREQx1 (HBUSREQx1 ),
    .HBUSREQx2 (HBUSREQx2 ),
    .HBUSREQx3 (HBUSREQx3 ),
    .HLOCKx0 (HLOCKx0 ),
    .HLOCKx1 (HLOCKx1 ),
    .HLOCKx2 (HLOCKx2 ),
    .HLOCKx3 (HLOCKx3 ),
    .HADDR (HADDR ),
    .HWDATA (HWDATA ),
    .HTRANS (HTRANS ),
    .HBURST (HBURST ),
    .HSIZE (HSIZE ),
    .HWRITE (HWRITE ),
    .HBUSREQx (HBUSREQx ),
    .HLOCKx  (HLOCKx)
  );

  arbiter arbiter_dut (
    .HRESETn (HRESETn ),
    .HCLK (HCLK ),
    .HBUSREQx0 (HBUSREQx0 ),
    .HLOCKx0 (HLOCKx0 ),
    .HBUSREQx1 (HBUSREQx1 ),
    .HLOCKx1 (HLOCKx1 ),
    .HBUSREQx2 (HBUSREQx2 ),
    .HLOCKx2 (HLOCKx2 ),
    .HBUSREQx3 (HBUSREQx3 ),
    .HLOCKx3 (HLOCKx3 ),
    .HADDR (HADDR ),
    .HTRANS (HTRANS ),
    .HSPLIT (HSPLIT ),
    .HBURST (HBURST ),
    .HRESP (HRESP ),
    .HREADY (HREADY ),
    .HGRANTx0 (HGRANTx0 ),
    .HGRANTx1 (HGRANTx1 ),
    .HGRANTx2 (HGRANTx2 ),
    .HGRANTx3 (HGRANTx3 ),
    .HMASTER (HMASTER ),
    .HMASTERD (HMASTERD ),
    .HMASTERLOCK  ( HMASTERLOCK)
  );




  slave slave_dut (
    .HRESETn (HRESETn ),
    .HCLK (HCLK ),
    .HMASTER ( ),
    .HMASTLOCK ( ),
    .HSELx (HSELx3 ),
    .HADDR (HADDR ),
    .HWRITE (HWRITE ),
    .HTRANS (HTRANS ),
    .HSIZE (HSIZE ),
    .HBURST (HBURST ),
    .HWDATA (HWDATA ),
    .HREADY (HREADY3 ),
    .HRESP (HRESP3 ),
    .HRDATA (HRDATA3 ),
    .HSPLITx ( ),
    .io_pin_i  ( io_pin_i)
  );
  
  slave_ram slave_ram_dut (
    .HRESETn (HRESETn ),
    .HCLK (HCLK ),
    .HMASTER (HMASTER ),
    .HMASTLOCK (HMASTLOCK ),
    .HSELx (HSELx2 ),
    .HADDR (HADDR ),
    .HWRITE (HWRITE ),
    .HTRANS (HTRANS ),
    .HSIZE (HSIZE ),
    .HBURST (HBURST ),
    .HWDATA (HWDATA ),
    .HREADY (HREADY2 ),
    .HRESP (HRESP2 ),
    .HRDATA (HRDATA2),
    .HSPLITx  ()
  );
  
  mux_s2m mux_s2m_dut (
    .HSELx0 (HSELx0 ),
    .HSELx1 (HSELx1 ),
    .HSELx2 (HSELx2 ),
    .HSELx3 (HSELx3 ),
    .HREADY0 (HREADY0 ),
    .HRESP0 (HRESP0 ),
    .HRDATA0 (HRDATA0 ),
    .HSPLITx0 (HSPLITx0 ),
    .HREADY1 (HREADY1 ),
    .HRESP1 (HRESP1 ),
    .HRDATA1 (HRDATA1 ),
    .HSPLITx1 (HSPLITx1 ),
    .HREADY2 (HREADY2 ),
    .HRESP2 (HRESP2 ),
    .HRDATA2 (HRDATA2 ),
    .HSPLITx2 (HSPLITx2 ),
    .HREADY3 (HREADY3 ),
    .HRESP3 (HRESP3 ),
    .HRDATA3 (HRDATA3 ),
    .HSPLITx3 (HSPLITx3 ),
    .HREADY (HREADY ),
    .HRESP (HRESP ),
    .HRDATA (HRDATA ),
    .HSPLITx  ()
  );
  


  decoder decoder_dut (
    .HADDR (HADDR ),
    .HSELx0 (HSELx0 ),
    .HSELx1 (HSELx1 ),
    .HSELx2 (HSELx2 ),
    .HSELx3  ( HSELx3)
  );

  initial begin
    
      HCLK   <=1'b0;
      HRESETn<=1'b0;
      //HREADY <=1'b1;
      //HRDATA <=32'd0;
      //HRESP  <=2'b00;
      //HGRANTx       <= 1'b0;
     
      #20 HRESETn<= 1'b1;
      HBUSREQx1<=1'b0;
      //#50 HREADY   <= 1'b1;
      //#60 HGRANTx<=1'b1;

      //#1000 $stop;
    
  end

 always #10 HCLK = ~HCLK;
 // always #10 HREADY = ~HREADY;
endmodule

