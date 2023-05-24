/*
import singnal_controller
import inst_decoder

being imported by top.v

decoderといってもメインデコーダーとALUデコーダーにわけられる。
メインでopを消費して、ALUでfunct3, funct7を消費する。
*/



module decoder(
    // input clk, rst, 
    input [31:0] inst,
    input ZERO, // ZERO : for branch judge

    output pc_src ,
    output [1:0] result_src,
    output mem_write,
    output [3:0] alu_ctrl,
    output alu_src,
    output [2:0] imm_src, 
    output reg_write,
    output IS_Utype,
    output IS_lui,
    output IS_jalr,
    output [1:0] byte_size,
    output mreq
    ); 
    // alu_ctrl = mode in ALU32

    // --- def wire --- //

    wire Jump ; //ここのモジュールで生成するのを明示するためにwireと書いてる。書かなくてもどっちでも良い。
    wire is_branch;
    wire [1:0] alu_op;

    

    // opcode で形式（分割の仕方を判定）



    signal_controller asig(
        .opcode(inst[6:0]),

        .Jump(Jump),
        .result_src(result_src),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .mreq(mreq),
        .is_branch(is_branch),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
        .IS_jalr(IS_jalr)
    );


    inst_decoder idec(
        .alu_op(alu_op),
        .funct3(inst[14:12]),
        .funct7b5(inst[30]),

        .alu_ctrl(alu_ctrl),
        .byte_size(byte_size)
    ); 

    assign pc_src = is_branch & ZERO | Jump; // for branch judge

endmodule

