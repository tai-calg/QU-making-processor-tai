//TODO: ctrl_src(WB,M,Exブロック)を書いていない。

// mlt_dp_reg_IFID mltIfId();みたいな形でtopで宣言（インスタンス化）してtopでalways(@posedge clk) をやる。
// mltIdEx.PC <= mltIfId.PC;みたいにシフトさせていく。
module mlt_dp_reg_IFID;
    reg [31:0] inst, PC4, PC;
endmodule

module mlt_dp_reg_IDEX;
    reg [31:0] rs1D, rs2D,imm_ext,PC,PC4;
    reg [4:0] rs1, rs2, rdD; //rs1,rs2 is for hazard
endmodule

module mlt_dp_reg_EXMEM;
    reg [31:0] alu_out, WD_mem, PC4;
    reg [4:0] rdE ;
endmodule

module mlt_dp_reg_MEMWB;
    reg [31:0] R_DDT, alu_out, PC4;
    reg [4:0] rdM;
endmodule

