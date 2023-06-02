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
   input wire rd2ext_src, sgn_ext_src,
   input wire [31:0] DDT_from_mem,


   output wire ZERO,
   output wire [31:0] pc, // for IAD 
   output wire [31:0] rd2_forMem, // to DDT //これ含む以下2行って,タイミング合わせなきゃいけないよね？つまりrd2_output みたいに新たな変数にして、それにpipe**.rs2Dataを代入する形という意味。
   output wire [31:0] alu_out_forMem, // to DAD
   output wire WRITE, mreq_M
 );

   wire [31:0] result, pc_next, pcplus4, pcplusOffset;
   wire [31:0] rd1, srcB, immExt, pcplusImm, u_out;

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

   // assign alu_out = pipeExMem.alu_out;  //~~      





   // srcをpipelineのソースに変更（シングルとの変更点）
   /* モジュールの場所によって"いつのステージのsrcか"が決まる。
   基本的に次のステージでなくなるpipelineレジスターはそのステージで消費する */

   //============= FETCH STAGE =============//
   adder add4(pc,4,pcplus4); //生のpc, pc+4 は 一番初め(IFステージ)のpc, pc+4
   pc_ff pcff( //#(CYCLE) サイクルいる？ここまでCYCLE持ってくるの？
      .clk(clk), .rst(rst),
      .d(pc_next), //feed back 
      // .pc_enable(pc_enable),

      .q(pc) //~~
   );


   //============= DEC STAGE =============//
   extend extend(pipeIfId.inst[31:7], pipeIfId.imm_src, immExt);

   rf32x32 rf(
      .clk(clk), .reset(rst),
      .wr_n(~pipeMemWb.reg_write),// wr_n はLowで書き込み！
      .rd1_addr(pipeIfId.inst[19:15]), .rd2_addr(pipeIfId.inst[24:20]), .wr_addr(pipeMemWb.rd_M),
      .data_in(result), //feed back
      
      .data1_out(rd1),.data2_out(rd2)
   );


   //============= EXE STAGE =============//
   wire pc_src;
   assign pc_src = pipeIdEx.is_branch & ZERO | pipeIdEx.Jump; // for branch judge
   adder addimm(pc, pipeIdEx.imm_ext ,pcplusImm);
   mux pcoffsetmux(pcplusImm, alu_out, pipeIdEx.IS_jalr,pcplusOffset); //~~ pipeExMem.alu_out. 
   //おそらくこれでExステージからPCsrcが確定して次のPCの判定に使われる
   
   mux pcmux(pcplus4,pcplusOffset, pc_src, pc_next);


   wire [31:0] rd2ext;
   rd2ext_4to0 rdext(pipeIdEx.rs2Data, pipeIdEx.rd2ext_src, rd2ext);
   mux mux_src(rd2ext, pipeIdEx.imm_ext , pipeIdEx.alu_src , srcB);

   ALU alu(pipeIdEx.rs1Data , srcB, pipeIdEx.alu_ctrl, alu_out, ZERO);

   utype_alu u_alu(.imm20(pipeIdEx.imm_ext), .pc(pipeIdEx.PC), .IS_lui(pipeIdEx.IS_lui), .IS_Utype(pipeIdEx.IS_Utype)
   , .result(u_out)); 

   //============= MEM STAGE =============//
   assign rd2_forMem = pipeExMem.WD_mem;
   assign alu_out_forMem = pipeExMem.alu_out;
   assign mreq_M = pipeExMem.mreq;
   assign WRITE = pipeExMem.mem_write;
   sgn_extend sgnext(DDT_from_mem, pipeExMem.sgn_ext_src, ReadDDT);// in DDT, out ReadDDT //~~ これRead間に合うのか？

   //============= WB STAGE =============//
   mux2 mux_result(pipeMemWb.alu_out, pipeMemWb.R_DDT, pipeMemWb.pcplus4, pipeMemWb.u_out, pipeMemWb.result_src, result);

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