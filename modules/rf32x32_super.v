// import DW_ram_2r_w_s_dff
// imported by ctrl_datapath.v
`include "modules/DW_ram_2r_w_s_dff_super.v"

`define  ZERO           1'b0           // Rename to Zero
`define  LOW            1'b0           // Rename to Zero
`define  HIGH           1'b1           // Rename to High

// DW_ram_2r_w_s_dff ⊂ rf32x32
module rf32x32(
		// clock and reset
		clk,reset,
		// Inputs
		wr_n_alp, 
              wr_n_bta,
		
              rd1_addr_alp, rd2_addr_alp, wr_addr_alp,
              rd1_addr_bta, rd2_addr_bta, wr_addr_bta,

		data_in_alp, data_in_bta,

		// Outputs
		data1_out_alp , data2_out_alp , 
              data1_out_bta , data2_out_bta
		);
   
       parameter data_width      = 32;
       parameter depth           = 32;
       parameter bit_width_depth = 5;  // ceil(log2(depth))
       parameter rst_mode        = 0;  // 0: asynchronously initializes the RAM
                                   // 1: synchronously

       //*** I/O declarations ***//
       input                          clk;       // clock
       input 			  reset;
       input                          wr_n_alp;      // Write enable, //! active low!!!!
       input                          wr_n_bta;      // Write enable, //! active low!!!!
       input  [bit_width_depth-1 : 0] rd1_addr_alp;  // Read0 address bus  
       input  [bit_width_depth-1 : 0] rd2_addr_alp;  // Read1 address bus
       input  [bit_width_depth-1 : 0] rd1_addr_bta;  // Read0 address bus
       input  [bit_width_depth-1 : 0] rd2_addr_bta;  // Read1 address bus
       input  [bit_width_depth-1 : 0] wr_addr_alp;   // Write address bus
       input  [bit_width_depth-1 : 0] wr_addr_bta;   // Write address bus
       input       [data_width-1 : 0] data_in_alp;   // Input data bus
       input       [data_width-1 : 0] data_in_bta;   // Input data bus

       output      [data_width-1 : 0] data1_out_alp; // Output data bus for read0
       output      [data_width-1 : 0] data2_out_alp; // Output data bus for read1

       output      [data_width-1 : 0] data1_out_bta; // Output data bus for read0
       output      [data_width-1 : 0] data2_out_bta; // Output data bus for read1


       //*** wire declarations ***//
       wire 			  clk_inv;
       wire        [data_width-1 : 0] ram_data1_out_alp;
       wire        [data_width-1 : 0] ram_data1_out_bta;

       wire        [data_width-1 : 0] ram_data2_out_alp;
       wire        [data_width-1 : 0] ram_data2_out_bta;


       assign    clk_inv = ~clk;

       assign  data1_out_alp = (|rd1_addr_alp) ? ram_data1_out_alp : {data_width{`ZERO}};
       assign  data2_out_alp = (|rd2_addr_alp) ? ram_data2_out_alp : {data_width{`ZERO}};

       assign  data1_out_bta = (|rd1_addr_bta) ? ram_data1_out_bta : {data_width{`ZERO}};
       assign  data2_out_bta = (|rd2_addr_bta) ? ram_data2_out_bta : {data_width{`ZERO}};

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

endmodule // rf32x32


