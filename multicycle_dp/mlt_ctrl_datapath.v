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
   input wire alu_src,
   input wire [1:0] result_src,
   input wire [2:0] imm_src,
   input wire mem_write,mreq, //mreq 
   input wire [3:0] alu_ctrl,
   input wire reg_write,
   input wire IS_Utype,IS_lui,IS_jalr,is_branch,Jump,
   input wire rd2ext_src, 
   input wire [1:0] sgn_ext_src,
   input wire [31:0] DDT_from_mem,


   output wire ZERO,
   output wire [31:0] pc, // for IAD 
   output wire [31:0] rd2_forMem, // to DDT //これ含む以下2行って,タイミング合わせなきゃいけないよね？つまりrd2_output みたいに新たな変数にして、それにpipe**.rs2Dataを代入する形という意味。
   output wire [31:0] alu_out_forMem, // to DAD
   output wire WRITE, mreq_M
 );

   wire [31:0] result, pc_next, pcplus4, pcplusOffset;
   wire [31:0] rd1, rd2, srcB, immExt, pcplusImm, u_out;

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
       .A(rs1Data_IdEx), .B(alu_out_ExMem), .C(result),
      .sel(forward_rs1), .X(srcA_E)
   );
   wire [31:0] rs2Data_IdEx_fwded;
   mux3 rs2fowarder (
       .A(rs2Data_IdEx), .B(alu_out_ExMem), .C(result),
      .sel(forward_rs2), .X(rs2Data_IdEx_fwded)
   );

   // hazard stall
   wire lw_stall , stall_if, stall_id;
   assign lw_stall = result_src_IdEx == 2'b01 &&
       (rd_IdEx == inst_IfId[19:15] | rd_IdEx == inst_IfId[24:20]);
   assign stall_if = lw_stall;
   assign stall_id = lw_stall;

   //hazard flush 
   wire flush_IfId , flush_IdEx;
   assign flush_IfId = pc_src;
   assign flush_IdEx = pc_src | lw_stall;


   //   ---   IF stage   ---   
   wire [31:0] pc_IfId, pc4_IfId, inst_IfId;  
   dp_reg #(
      .WIDTH(96),
      .INIT_VALUE(32'h0)
   ) regIfId (
      .clk(clk), .rst(rst), .stall(stall_id), .flush(flush_IfId),
      .d({pc, pcplus4, inst}),

      .q({pc_IfId, pc4_IfId, inst_IfId})
   );

   //   ---   ID stage   ---
   wire [31:0] pc_IdEx, pc4_IdEx, rs1Data_IdEx, rs2Data_IdEx, immExt_IdEx;
   wire [4:0] rs1_IdEx, rs2_IdEx, rd_IdEx;
   wire alu_src_IdEx, rd2ext_src_IdEx, IS_jalr_IdEx, IS_Utype_IdEx, IS_lui_IdEx, Jump_IdEx, is_branch_IdEx,
        mem_write_IdEx, mreq_IdEx, reg_write_IdEx;
   wire [3:0] alu_ctrl_IdEx;
   wire [1:0] result_src_IdEx, sgn_ext_src_IdEx;
   dp_reg #(
      .WIDTH(193),
      .INIT_VALUE(32'h0)
   ) regIdEx (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(flush_IdEx),
      .d({pc_IfId, pc4_IfId, inst[19:15], inst[24:20], inst[11:7], rd1, rd2, immExt, //175
         alu_src, rd2ext_src, IS_jalr, IS_Utype, IS_lui, Jump, is_branch, alu_ctrl, // EX // 186
         mem_write, mreq, sgn_ext_src, // MEM
         reg_write, result_src}), //WB

      .q({pc_IdEx, pc4_IdEx, rs1_IdEx, rs2_IdEx, rd_IdEx, rs1Data_IdEx, rs2Data_IdEx, immExt_IdEx, 
         alu_src_IdEx, rd2ext_src_IdEx, IS_jalr_IdEx, IS_Utype_IdEx, IS_lui_IdEx, Jump_IdEx, is_branch_IdEx, alu_ctrl_IdEx, // EX 
         mem_write_IdEx, mreq_IdEx, sgn_ext_src_IdEx, // MEM
         reg_write_IdEx, result_src_IdEx}) //WB
   );

   //   ---   EX stage   ---
   wire [31:0] pc4_ExMem, WD_ForMem, alu_out_ExMem;
   wire [4:0] rd_ExMem;
   wire mem_write_ExMem, mreq_ExMem; // MEM
   wire [1:0] sgn_ext_src_ExMem; // MEM
   wire reg_write_ExMem; // WB
   wire [1:0] result_src_ExMem; // WB
   dp_reg #(
      .WIDTH(108),
      .INIT_VALUE(32'h0)
   ) regExMem (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(1'b0),
      .d({pc4_IdEx, alu_out, rs2Data_IdEx, rd_IdEx,// 101
         mem_write_IdEx, mreq_IdEx, sgn_ext_src_IdEx, // MEM
         reg_write_IdEx, result_src_IdEx}), //WB

      .q({pc4_ExMem, alu_out_ExMem, WD_ForMem, rd_ExMem, 
         mem_write_ExMem, mreq_ExMem, sgn_ext_src_ExMem, // MEM
         reg_write_ExMem, result_src_ExMem}) // WB
   );

   //   ---   MEM stage   ---
   wire [31:0] pc4_MemWB, alu_out_MemWB, R_DDT_MemWB, uout_MemWB;
   wire [4:0] rd_MemWB;
   wire  reg_write_MemWB; // WB
   wire [1:0] result_src_MemWB; // WB
   dp_reg #(
      .WIDTH(136),
      .INIT_VALUE(32'h0)
   ) regMemWb (
      .clk(clk), .rst(rst), .stall(1'b0), .flush(1'b0),
      .d({pc4_ExMem, alu_out_ExMem, ReadDDT, u_out, rd_ExMem, 
         reg_write_ExMem, result_src_ExMem}), // WB

      .q({pc4_MemWB, alu_out_MemWB, R_DDT_MemWB, uout_MemWB, rd_MemWB, 
         reg_write_MemWB, result_src_MemWB}) // WB
   );

   // assign alu_out = pipeExMem.alu_out;  //~~      

   // srcをpipelineのソースに変更（シングルとの変更点）
   /* モジュールの場所によって"いつのステージのsrcか"が決まる。
   基本的に次のステージでなくなるpipelineレジスターはそのステージで消費する */

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

      .q(pc) //~~
   );


   //============= DEC STAGE =============//
   extend extend(inst_IfId[31:7], imm_src, immExt);

   rf32x32 rf(
      .clk(clk), .reset(rst),
      .wr_n(~reg_write_MemWB),// wr_n はLowで書き込み！
      .rd1_addr(inst_IfId[19:15]), .rd2_addr(inst_IfId[24:20]), .wr_addr(rd_MemWB),
      .data_in(result), //feed back
      
      .data1_out(rd1),.data2_out(rd2)
   );


   //============= EXE STAGE =============//
   wire pc_src;
   assign pc_src = is_branch_IdEx & ZERO | Jump_IdEx; // for branch judge
   wire [31:0] alu_out;
   adder addimm(pc, immExt_IdEx ,pcplusImm);
   mux pcoffsetmux(pcplusImm, alu_out, IS_jalr_IdEx,pcplusOffset); //~~ pipeExMem.alu_out. 
   //おそらくこれでExステージからPCsrcが確定して次のPCの判定に使われる
   
   mux pcmux(pcplus4,pcplusOffset, pc_src, pc_next);


   wire [31:0] rd2ext;
   rd2ext_4to0 rdext(rs2Data_IdEx_fwded, rd2ext_src_IdEx, rd2ext);
   mux mux_src(rd2ext, immExt_IdEx , alu_src_IdEx , srcB);

   ALU alu(srcA_E , srcB, alu_ctrl_IdEx, alu_out, ZERO);

   utype_alu u_alu(.imm20(immExt_IdEx), .pc(pc_IdEx), .IS_lui(IS_lui_IdEx), .IS_Utype(IS_Utype_IdEx)
   , .result(u_out)); 

   //============= MEM STAGE =============//
   assign rd2_forMem = WD_ForMem;
   assign alu_out_forMem = alu_out_ExMem;
   assign mreq_M = mreq_ExMem;
   assign WRITE = mem_write_ExMem;
   wire [31:0] ReadDDT;
   sgn_extend sgnext(DDT_from_mem, sgn_ext_src_ExMem, ReadDDT);// in DDT, out ReadDDT //~~ これRead間に合うのか？

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


/*
    mlt_dp_reg_IFID pipeIfId();
    mlt_dp_reg_IDEX pipeIdEx();
    mlt_dp_reg_EXMEM pipeExMem();
    mlt_dp_reg_MEMWB pipeMemWb();

   always @(posedge clk ) begin


      pipeIfId.PC <= pc;
      pipeIfId.PC4 <= pcplus4;
      pipeIfId.inst <= inst;


      pipeIdEx.PC <= pipeIfId.PC;
      pipeIdEx.PC4 <= pipeIfId.PC4;
      pipeIdEx.rs1 <= inst[19:15]; 
      pipeIdEx.rs2 <= inst[24:20]; //正しい？
      pipeIdEx.rd_D <= inst[11:7];
      pipeIdEx.rs1Data <= rd1; //このrd1はrs1アドレスの中身のデータ
      pipeIdEx.rs2Data <= rd2; //同上
      pipeIdEx.imm_ext <= immExt;
      //for EX
      pipeIdEx.alu_src <= alu_src;
      pipeIdEx.rd2ext_src <= rd2ext_src;
      pipeIdEx.IS_jalr <= IS_jalr;
      pipeIdEx.IS_Utype <= IS_Utype;
      pipeIdEx.IS_lui <= IS_lui;
      pipeIdEx.Jump <= Jump;
      pipeIdEx.is_branch <= is_branch;
      pipeIdEx.alu_ctrl <= alu_ctrl;
      pipeIdEx.imm_src <= imm_src;
      //for MEM
      pipeIdEx.mem_write <= mem_write;
      pipeIdEx.mreq <= mreq;
      pipeIdEx.sgn_ext_src <= sgn_ext_src;
      //for WB
      pipeIdEx.reg_write <= reg_write;
      pipeIdEx.result_src <= result_src;


      pipeExMem.alu_out <= alu_out;
      pipeExMem.WD_mem <= pipeIdEx.rs2Data; //TODO あとでハザード挟むので変更予定
      pipeExMem.PC4 <= pipeIdEx.PC4;
      pipeExMem.rd_E <= pipeIdEx.rd_D;
      pipeExMem.u_out <= u_out;
      //for MEM 
      pipeExMem.mem_write <= pipeIdEx.mem_write;
      pipeExMem.mreq <= pipeIdEx.mreq;
      pipeExMem.sgn_ext_src <= pipeIdEx.sgn_ext_src;
      //for WB
      pipeExMem.reg_write <= pipeIdEx.reg_write;
      pipeExMem.result_src <= pipeIdEx.result_src;


      pipeMemWb.PC4 <= pipeExMem.PC4;
      pipeMemWb.alu_out <= pipeExMem.alu_out;
      pipeMemWb.R_DDT <= ReadDDT;
      pipeMemWb.u_out <= pipeExMem.u_out;
      pipeMemWb.rd_M <= pipeExMem.rd_E;
      //for WB 
      pipeMemWb.reg_write <= pipeExMem.reg_write;
      pipeMemWb.result_src <= pipeExMem.result_src;

   end
*/
