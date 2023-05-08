 /*
 import modules/rf32x32
 import alu/ALU
 import alu/utype_alu
 import other/mux
 import alu/extend
 import data_path/pc_ff
 
 */
 
 // catch decoder output and connect to other components. then control all arthitecture.
 // all outputs are for memory.
 module ctrl_datapath (
   input wire clk, rst , 
   input wire [31:0] inst, ReadDDT,
   input wire pc_src,alu_src,
   input wire [1:0] result_src,
   input wire [2:0] alu_ctrl,imm_src,
   input wire mem_write,reg_write,
   input wire IS_Utype,IS_lui,


   output wire ZERO,
   output wire [31:0] pc, // for IAD
   output wire [31:0] rd2, // to DDT
   output wire [31:0] alu_out, // to DAD
 );

   wire [31:0] result, pc_next;
   wire [31:0] rd1, srcB, immExt, pcplusImm, u_out;


   pc_ff pcff( //#(CYCLE) サイクルいる？ここまでCYCLE持ってくるの？
      .clk(clk), .rst(rst),
      .d(pc_next) //feed back 

      .q(pc),
   );


   adder add4(pc,4,pcplus4);
   extend extend(inst[31:7], imm_src, immExt);
   adder addimm(pc,immExt,pcplusImm);
   mux pcmux(pcplus4,pcplusImm,pc_src,pc_next);

   rf32x32 rf(
      .clk(clk), .rst(rst),
      .wr_n(reg_write),
      .rd1_addr(inst[19:15]), .rd2_addr(inst[24:20]), .wr_addr(inst[11:7]),
      .data_in(result), //feed back
      
      .data1_out(rd1),.data2_out(rd2),
   );
   mux mux_src(rd2,immExt,alu_src,srcB);

   ALU alu(rd1, srcB, alu_ctrl, alu_out, ZERO);

   utype_alu u_alu(.imm20(immExt), .pc(pc), .IS_lui(IS_lui), .IS_Utype(IS_Utype)
   , .result(u_out)); //挙動が心配…
   mux2 mux_result(alu_out, ReadDDT, pcplus4, u_out, result_src, result);

endmodule