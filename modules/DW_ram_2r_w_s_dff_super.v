////////////////////////////////////////////////////////////////////////////////
//
//       This confidential and proprietary software may be used only
//     as authorized by a licensing agreement from Synopsys Inc.
//     In the event of publication, the following notice is applicable:
//
//                    (C) COPYRIGHT 1999 - 2013 SYNOPSYS INC.
//                           ALL RIGHTS RESERVED
//
//       The entire notice above must be reproduced on all authorized
//     copies.
//
// AUTHOR:    Jay Zhu	Sept 22, 1999
//
// VERSION:   Simulation Architecture
//
// DesignWare_version: e321906e
// DesignWare_release: H-2013.03-DWBB_201303.4
//
////////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------
// ABSTRACT:  Synch Write, Asynch Dual Read RAM (Flip-Flop Based)
//            (flip flop memory array)
//            legal range:  depth        [ 2 to 2048 ]
//            legal range:  data_width   [ 1 to 1024 ]
//            Input data: data_in_alp[data_width-1:0]
//            Output data from read1: data_rd1_out_alp[data_width-1:0]
//            Output data from read2: data_rd2_out[data_width-1:0]
//            Read1 Address: rd1_addr_alp[addr_width-1:0]
//            Read2 Address: rd2_addr[addr_width-1:0]
//            Write Address: wr_addr_alp[addr_width-1:0]
//            write enable (active low): wr_n_alp | wr_n_bta
//            chip select (active low): cs_n
//            reset (active low): rst_n
//            clock:clk
//
//	MODIFIED:
//		092299	Jay Zhu		Rewrote for STAR91151
//              10/18/00  RPH       Rewrote accoding to new guidelines 
//                                  STAR 111067   
//              05/25/01  RJK       Rewritten again
//              2/18/09   RJK       Corrected default value for rst_mode
//				    STAR 9000294457
//----------------------------------------------------------------------

/*
   // Instance of DW_ram_2r_w_s_lat
   DW_ram_2r_w_s_dff #(data_width, depth, rst_mode)
      u_DW_ram_2r_w_s_dff(
             .clk(clk_inv), .rst_n(reset),
             .cs_n(`LOW), 
             .wr_n_alp(wr_n_alp), .wr_n_bta(wr_n_bta),
             .rd1_addr_alp(rd1_addr_alp), .rd2_addr_alp(rd2_addr_alp),
              .rd1_addr_bta(rd1_addr_bta), .rd2_addr_bta(rd2_addr_bta),
             .wr_addr_alp(wr_addr_alp), .wr_addr_bta(wr_addr_bta),
             .data_in_alp(data_in_alp), .data_in_bta(data_in_bta),
             .data_rd1_out_alp(ram_data1_out_alp), .data_rd2_out_alp(ram_data2_out_alp), 
             .data_rd1_out_bta(ram_data1_out_bta), .data_rd2_out_bta(ram_data2_out_bta),
      );
*/
module DW_ram_2r_w_s_dff (clk, rst_n, cs_n, 
         wr_n_alp, wr_n_bta, rd1_addr_alp, rd2_addr_alp, rd1_addr_bta, rd2_addr_bta,
         wr_addr_alp, wr_addr_bta, data_in_alp, data_in_bta,

         data_rd1_out_alp, data_rd2_out_alp, data_rd1_out_bta, data_rd2_out_bta);

   parameter data_width = 4;
   parameter depth = 8;
   parameter rst_mode = 1;

`define DW_addr_width ((depth>256)?((depth>4096)?((depth>16384)?((depth>32768)?16:15):((depth>8192)?14:13)):((depth>1024)?((depth>2048)?12:11):((depth>512)?10:9))):((depth>16)?((depth>64)?((depth>128)?8:7):((depth>32)?6:5)):((depth>4)?((depth>8)?4:3):((depth>2)?2:1))))

   input [data_width-1:0] data_in_alp;
   input [data_width-1:0] data_in_bta;
   input [`DW_addr_width-1:0] rd1_addr_alp;
   input [`DW_addr_width-1:0] rd2_addr_alp;
   input [`DW_addr_width-1:0] rd1_addr_bta;
   input [`DW_addr_width-1:0] rd2_addr_bta;
   input [`DW_addr_width-1:0] wr_addr_alp;
   input [`DW_addr_width-1:0] wr_addr_bta;
   input 		      wr_n_alp;
   input 		      wr_n_bta;
   input 		   rst_n;
   input 		   cs_n;
   input 		   clk;

   output [data_width-1:0] data_rd1_out_alp;
   output [data_width-1:0] data_rd2_out_alp;
   output [data_width-1:0] data_rd1_out_bta;
   output [data_width-1:0] data_rd2_out_bta;

// synopsys translate_off
   wire [data_width-1:0]   data_in_alp;
   wire [data_width-1:0]   data_in_bta;
   reg [depth*data_width-1:0]    next_mem;
   reg [depth*data_width-1:0]    mem;
   wire [depth*data_width-1:0]   mem_mux1_alp;
   wire [depth*data_width-1:0]   mem_mux2_alp;
   wire [depth*data_width-1:0]   mem_mux1_bta;
   wire [depth*data_width-1:0]   mem_mux2_bta;
   
   wire 		   a_rst_n;
   

   
  
  initial begin : parameter_check
    integer param_err_flg;

    param_err_flg = 0;
    
	    
  
    if ( (data_width < 1) || (data_width > 2048) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 2048)",
	data_width );
    end
  
    if ( (depth < 2) || (depth > 1024 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter depth (legal range: 2 to 1024 )",
	depth );
    end
  
    if ( (rst_mode < 0) || (rst_mode > 1 ) ) begin
      param_err_flg = 1;
      $display(
	"ERROR: %m :\n  Invalid value (%d) for parameter rst_mode (legal range: 0 to 1 )",
	rst_mode );
    end

  
    if ( param_err_flg == 1) begin
      $display(
        "%m :\n  Simulation aborted due to invalid parameter value(s)");
      $finish;
    end

  end // parameter_check
   
   assign mem_mux1_alp = mem >> (rd1_addr_alp * data_width);
   assign mem_mux2_alp = mem >> (rd2_addr_alp * data_width);

   assign mem_mux1_bta = mem >> (rd1_addr_bta * data_width);
   assign mem_mux2_bta = mem >> (rd2_addr_bta * data_width);


   assign data_rd1_out_alp = ((rd1_addr_alp ^ rd1_addr_alp) !== {`DW_addr_width{1'b0}})? {data_width{1'bx}} : (
				(rd1_addr_alp >= depth)? {data_width{1'b0}} :
				   mem_mux1_alp[data_width-1 : 0] );
   assign data_rd2_out_alp = ((rd2_addr_alp ^ rd2_addr_alp) !== {`DW_addr_width{1'b0}})? {data_width{1'bx}} : (
            (rd2_addr_alp >= depth)? {data_width{1'b0}} :
               mem_mux2_alp[data_width-1 : 0] );

   assign data_rd1_out_bta = ((rd1_addr_bta ^ rd1_addr_bta) !== {`DW_addr_width{1'b0}})? {data_width{1'bx}} : (
            (rd1_addr_bta >= depth)? {data_width{1'b0}} :
               mem_mux1_bta[data_width-1 : 0] );
   assign data_rd2_out_bta = ((rd2_addr_bta ^ rd2_addr_bta) !== {`DW_addr_width{1'b0}})? {data_width{1'bx}} : (
            (rd2_addr_bta >= depth)? {data_width{1'b0}} :
               mem_mux2_bta[data_width-1 : 0] );


   


   
   assign a_rst_n = (rst_mode == 0)? rst_n : 1'b1;


  
   always @ (posedge clk or negedge a_rst_n) begin : registers
      integer i, j;
      
   
      next_mem = mem;

      if ((cs_n | wr_n_alp | wr_n_bta) !== 1'b1) begin
      
         if ((wr_addr_alp ^ wr_addr_alp) !== {`DW_addr_width{1'b0}}) begin
            next_mem = {depth*data_width{1'bx}};	

            end else begin  
               if ((wr_addr_alp < depth) && ((wr_n_alp | cs_n) !== 1'b1)) begin
                  for (i=0 ; i < data_width ; i=i+1) begin
                     j = wr_addr_alp*data_width + i;
                     next_mem[j] = ((wr_n_alp | cs_n) == 1'b0)? data_in_alp[i] | 1'b0
                              : mem[j];
                        end // for
                     end // if
                  end // if-else

         if ((wr_addr_bta ^ wr_addr_bta) !== {`DW_addr_width{1'b0}}) begin
            next_mem = {depth*data_width{1'bx}};
            end else begin
               if ((wr_addr_bta < depth) && (( wr_n_bta | cs_n) !== 1'b1)) begin
                  for (i=0 ; i < data_width ; i=i+1) begin
                     j = wr_addr_bta*data_width + i;
                     next_mem[j] = (( wr_n_bta | cs_n) == 1'b0)? data_in_bta[i] | 1'b0
                                    : mem[j];
                  end // for
               end // if
            end // if-else
         
      end // if   
   
   
   
      if (rst_n === 1'b0) begin
         mem <= {depth*data_width{1'b0}};
      end else begin
         if ( rst_n === 1'b1) begin
	    mem <= next_mem;
	 end else begin
	    mem <= {depth*data_width{1'bX}};
	 end
      end
   end // registers
   
    
  always @ (clk) begin : clk_monitor 
    if ( (clk !== 1'b0) && (clk !== 1'b1) && ($time > 0) )
      $display( "WARNING: %m :\n  at time = %t, detected unknown value, %b, on clk input.",
                $time, clk );
    end // clk_monitor 

// synopsys translate_on

`undef DW_addr_width
endmodule // DW_ram_2r_w_s_dff
