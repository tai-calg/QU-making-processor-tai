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
   input wire [31:0] inst,
   input wire [31:0] DDT_from_mem,


   output wire [31:0] pc, // for IAD 
   output wire [31:0] rd2_forMem, // to DDT //これ含む以下2行って,タイミング合わせなきゃいけないよね？つまりrd2_output みたいに新たな変数にして、それにpipe**.rs2Dataを代入する形という意味。
   output wire [31:0] alu_out_forMem, // to DAD
   output wire WRITE, mreq_M,
   output wire [1:0] BYTE_SIZE
 );

   wire [31:0] result, pc_next, pcplus4, pcplusOffset;
   wire [31:0] rd1_out_D, rd2_out_D, srcB, immExt_D, pcplusImm;

   // hazard forward
   wire [1:0] forward_rs1, forward_rs2;
   hazard hzd(
      .rs1_IdEx(rs1_IdEx), .rs2_IdEx(rs2_IdEx), 
      .rd_ExMem(rd_ExMem) ,.rd_MemWB(rd_MemWB),
      .reg_write_ExMem(reg_write_ExMem), .reg_write_MemWB(reg_write_MemWB),

      .forward_rs1(forward_rs1) , .forward_rs2(forward_rs2) 
   );
   wire [31:0] srcA_E;
   mux3 rs1fowarder (
       .A(rs1Data_IdEx), .B(fwd_out_ExMem), .C(result),
      .sel(forward_rs1), .X(srcA_E)
   );
   wire [31:0] rs2Data_IdEx_fwded;
   
   wire [31:0] fwd_out_ExMem ;
   assign fwd_out_ExMem = (IS_lui_ExMem) ? u_out_Exmem : alu_out_ExMem;
   mux3 rs2fowarder (
       .A(rs2Data_IdEx), .B(fwd_out_ExMem), .C(result),
      .sel(forward_rs2), .X(rs2Data_IdEx_fwded)
   );

   // hazard stall
   wire lw_stall , stall_if, stall_id;
   assign lw_stall = result_src_IdEx == 2'b01 &&
       (inst_IfId[19:15] == rd_IdEx   |  inst_IfId[24:20] == rd_IdEx); //ストールは一つ前までしか見ない。1cycle差のlw依存の時だけしか使わないので。
   assign stall_if = lw_stall;
   assign stall_id = lw_stall;

   //hazard flush 
   wire flush_IfId , flush_IdEx;
   assign flush_IfId = pc_src;
   assign flush_IdEx = pc_src | lw_stall;


   //============= FETCH STAGE =============//
   adder add4(pc,4,pcplus4); //生のpc, pc+4 は 一番初め(IFステージ)のpc, pc+4
   dp_reg #(
      .WIDTH(32),
      .INIT_VALUE(32'h1_0000)
   ) 
   pc_ff ( 
      .clk(clk), .rst(rst),
      .stall(stall_if), .flush(1'b0), //flushはない
      .d(pc_next), //feed back 

      .q(pc) 
   );

   wire [31:0] pc_IfId, pc4_IfId, inst_IfId;  
   dp_reg #(
      .WIDTH(96),
      .INIT_VALUE({32'h0, 32'h0, 32'h13}) // 32'h13 は nop(addi x0, x0, 0)
   ) regIfId (
      .clk(clk), .rst(rst), .stall(stall_id), .flush(flush_IfId),
      .d({pc, pcplus4, inst}),

      .q({pc_IfId, pc4_IfId, inst_IfId})
   );



      //============= DEC STAGE =============//
      wire mem_write_D , reg_write_D, mreq_D, is_branch_D, Jump_D, IS_Utype_D, IS_lui_D, IS_jalr_D, rd2ext_src_D;
      wire [1:0] result_src_D, byte_size_D, sgn_ext_src_D;
      wire [2:0] imm_src_D;
      wire [3:0] alu_ctrl_D;
      decoder dec(
      .inst(inst_IfId),

      .result_src(result_src_D),
      .mem_write(mem_write_D),
      .alu_ctrl(alu_ctrl_D),
      .alu_src(alu_src_D),
      .imm_src(imm_src_D),
      .reg_write(reg_write_D),
      .IS_Utype(IS_Utype_D),
      .IS_lui(IS_lui_D),
      .IS_jalr(IS_jalr_D),
      .is_branch(is_branch_D),
      .Jump(Jump_D),
      .byte_size(byte_size_D),
      .sgn_ext_src(sgn_ext_src_D),
      .mreq(mreq_D), // 3 , 35だけload,store.
      .rd2ext_src(rd2ext_src_D) // for sll, srl, sra (shamt)
   ); 

   extend extend(inst_IfId[31:7], imm_src_D, immExt_D);

   rf32x32 rf(
      .clk(clk), .reset(rst),
      .wr_n(~reg_write_MemWB),// wr_n はLowで書き込み！
      .rd1_addr(inst_IfId[19:15]), .rd2_addr(inst_IfId[24:20]), .wr_addr(rd_MemWB),
      .data_in(result), //feed back
      
      .data1_out(rd1_out_D),.data2_out(rd2_out_D)
   );

   wire [31:0] pc_IdEx, pc4_IdEx, rs1Data_IdEx, rs2Data_IdEx, immExt_IdEx;
   wire [4:0] rs1_IdEx, rs2_IdEx, rd_IdEx;
   wire alu_src_IdEx, rd2ext_src_IdEx, IS_jalr_IdEx, IS_Utype_IdEx, IS_lui_IdEx, Jump_IdEx, is_branch_IdEx,
        mem_write_IdEx, mreq_IdEx, reg_write_IdEx;
   wire [3:0] alu_ctrl_IdEx;
   wire [1:0] result_src_IdEx, sgn_ext_src_IdEx, byte_size_IdEx;
   dp_reg #(
      .WIDTH(195),
      .INIT_VALUE(195'b0)
   ) regIdEx (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(flush_IdEx),
      .d({pc_IfId, pc4_IfId, inst_IfId[19:15], inst_IfId[24:20], inst_IfId[11:7], rd1_out_D, rd2_out_D, immExt_D, //175
         alu_src_D, rd2ext_src_D, IS_jalr_D, IS_Utype_D, IS_lui_D, Jump_D, is_branch_D, alu_ctrl_D, // EX // 11bit 186
         mem_write_D, mreq_D, sgn_ext_src_D, byte_size_D ,// MEM //6bit , 192
         reg_write_D, result_src_D}), //WB 3bit 

      .q({pc_IdEx, pc4_IdEx, rs1_IdEx, rs2_IdEx, rd_IdEx, rs1Data_IdEx, rs2Data_IdEx, immExt_IdEx, 
         alu_src_IdEx, rd2ext_src_IdEx, IS_jalr_IdEx, IS_Utype_IdEx, IS_lui_IdEx, Jump_IdEx, is_branch_IdEx, alu_ctrl_IdEx, // EX 
         mem_write_IdEx, mreq_IdEx, sgn_ext_src_IdEx, byte_size_IdEx, // MEM
         reg_write_IdEx, result_src_IdEx}) //WB
   );



      //============= EXE STAGE =============//
   wire [31:0] pc4_ExMem, rs2Data_ExMem, alu_out_ExMem,u_out_Exmem;
   wire [4:0] rd_ExMem;
   wire mem_write_ExMem, mreq_ExMem, IS_lui_ExMem; // MEM
   wire [1:0] sgn_ext_src_ExMem, byte_size_ExMem; // MEM
   wire reg_write_ExMem; // WB
   wire [1:0] result_src_ExMem; // WB
   dp_reg #(
      .WIDTH(143),
      .INIT_VALUE(143'b0)
   ) regExMem (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(1'b0),
      .d({pc4_IdEx, alu_out, rs2Data_IdEx_fwded, rd_IdEx,// 101
         mem_write_IdEx, mreq_IdEx, sgn_ext_src_IdEx, byte_size_IdEx, IS_lui_IdEx, // MEM
         reg_write_IdEx, result_src_IdEx, u_out}), //WB

      .q({pc4_ExMem, alu_out_ExMem, rs2Data_ExMem, rd_ExMem, 
         mem_write_ExMem, mreq_ExMem, sgn_ext_src_ExMem, byte_size_ExMem, IS_lui_ExMem, // MEM
         reg_write_ExMem, result_src_ExMem, u_out_Exmem}) // WB
   );

   wire pc_src;
   assign pc_src = is_branch_IdEx & ZERO | Jump_IdEx; // for branch judge
   wire [31:0] alu_out;
   adder addimm(pc_IdEx, immExt_IdEx , pcplusImm);
   mux pcoffsetmux(pcplusImm, alu_out, IS_jalr_IdEx, pcplusOffset); //~~ pipeExMem.alu_out. 
   //おそらくこれでExステージからPCsrcが確定して次のPCの判定に使われる
   
   mux pcmux(pcplus4,pcplusOffset, pc_src, pc_next);


   wire [31:0] rd2ext;
   rd2ext_4to0 rdext(rs2Data_IdEx_fwded, rd2ext_src_IdEx, rd2ext);
   mux mux_src(rd2ext, immExt_IdEx , alu_src_IdEx , srcB);

   ALU alu(srcA_E , srcB, alu_ctrl_IdEx, alu_out, ZERO);

   wire [31:0] u_out ;
   utype_alu u_alu(.imm20(immExt_IdEx), .pc(pc_IdEx), .IS_lui(IS_lui_IdEx), .IS_Utype(IS_Utype_IdEx)
   , .result(u_out)); 


   //============= MEM STAGE =============//
   wire [31:0] pc4_MemWB, alu_out_MemWB, R_DDT_MemWB, uout_MemWB;
   wire [4:0] rd_MemWB;
   wire  reg_write_MemWB; // WB
   wire [1:0] result_src_MemWB; // WB
   dp_reg #(
      .WIDTH(136),
      .INIT_VALUE(136'b0)
   ) regMemWb (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(1'b0),
      .d({pc4_ExMem, alu_out_ExMem, ReadDDT, u_out_Exmem, rd_ExMem, 
         reg_write_ExMem, result_src_ExMem}), // WB

      .q({pc4_MemWB, alu_out_MemWB, R_DDT_MemWB, uout_MemWB, rd_MemWB, 
         reg_write_MemWB, result_src_MemWB}) // WB
   );

   //   ---   MEM stage   ---
   assign rd2_forMem = rs2Data_ExMem;
   assign alu_out_forMem = alu_out_ExMem;
   assign mreq_M = mreq_ExMem;
   assign WRITE = mem_write_ExMem;
   assign BYTE_SIZE = byte_size_ExMem;
   wire [31:0] ReadDDT;
   sgn_extend sgnext(DDT_from_mem, sgn_ext_src_ExMem, ReadDDT);// in DDT, out ReadDDT 


            // assign alu_out = pipeExMem.alu_out;  //~~      

            // srcをpipelineのソースに変更（シングルとの変更点）
            /* モジュールの場所によって"いつのステージのsrcか"が決まる。
            基本的に次のステージでなくなるpipelineレジスターはそのステージで消費する */

   //============= WB STAGE =============//
   mux4 mux_result(alu_out_MemWB, R_DDT_MemWB, pc4_MemWB, uout_MemWB, result_src_MemWB, result);








   // waiting mechanism
   /* maybe not need as pipeline.
      wire reg_write_load;
      wire pc_enable;

      
      load_wait lw(
         .clk(clk),
         .opcode(inst[6:0]),

         .pc_enable(pc_enable),
         .reg_write_load(reg_write_load)
      );
      assign reg_write_and = reg_write_load && reg_write;
      */

endmodule


