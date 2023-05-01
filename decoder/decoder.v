/*
decoderといってもメインデコーダーとALUデコーダーにわけられる。
メインでopを消費して、ALUでfunct3, funct7を消費する。

*/

module decoder(
    input [31:0] inst,
    input ZERO, // ZERO : for branch judge

    output pc_src ,
    output result_src,
    output mem_write,
    output [2:0] alu_ctrl,
    output alu_src,
    output [2:0] imm_src, 
    output reg_write,
    output IS_Utype,
    output IS_lui,
    ); 
    // alu_ctrl = mode in ALU32

    // --- def wire --- //

    wire Jump ; //ここのモジュールで生成するのを明示するためにwireと書いてる。書かなくてもどっちでも良い。
    wire IS_Utype;
    wire IS_lui;
    

    // opcode で形式（分割の仕方を判定）
    singnal_controller asig(
        .opcode(inst[6:0]),
        .Jump(Jump),
        .pc_src(pc_src),
        .read_ram_src(result_src),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
    );

    inst_decoder idec(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7b5(inst[30]),
        .alu_ctrl(alu_ctrl),
    ); // return : alu_ctrl

    assign pc_src = is_branch & ZERO | Jump; // for branch judge

endmodule

