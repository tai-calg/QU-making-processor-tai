\`
// mlt_dp_reg_IFID mltIfId();みたいな形でtopで宣言（インスタンス化）してtopでalways(@posedge clk) をやる。
// mltIdEx.PC <= mltIfId.PC;みたいにシフトさせていく。
module mlt_dp_reg_IFID;
    reg [31:0] inst, PC4, PC;
endmodule

module mlt_dp_reg_IDEX;
    reg [31:0] rs1Data, rs2Data,imm_ext,PC,PC4;
    reg [4:0] rs1, rs2, rd_D; //rs1,rs2 is for hazard
    // EX
    reg alu_src,rd2ext_src,IS_jalr,IS_Utype,IS_lui,Jump,is_branch;
    reg [3:0] alu_ctrl;
    reg [2:0] imm_src;
    // MEM
    reg mem_write, mreq, sgn_ext_src;
    // WB
    reg reg_write, result_src;
endmodule

module mlt_dp_reg_EXMEM;
    reg [31:0] alu_out, WD_mem, PC4, u_out;
    reg [4:0] rd_E ;
    // MEM
    reg mem_write, mreq, sgn_ext_src;
    // WB
    reg reg_write, result_src;
endmodule

module mlt_dp_reg_MEMWB;
    reg [31:0] R_DDT, alu_out, PC4, u_out;
    reg [4:0] rd_M;
    // WB
    reg reg_write, result_src;
endmodule

