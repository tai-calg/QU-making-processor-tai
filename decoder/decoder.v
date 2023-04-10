/*
decoderといってもメインデコーダーとALUデコーダーにわけられる。
メインでopを消費して、ALUでfunct3, funct7を消費する。

*/

module decoder(
    input [31:0] inst,

    output pc_src ,
    output result_src,
    output mem_write,
    output [2:0] alu_ctrl,
    output alu_src,
    output [1:0] imm_src,
    output reg_write,
    output ZERO); // ZERO : for branch judge
    // alu_ctrl = mode of ALU32

    // --- //

    // opcode で形式（分割の仕方を判定）
    singnal_controller asig(
        .opcode(inst[6:0]),
        .pc_src(pc_src),
        .result_src(result_src),
        .mem_write(mem_write),
        .alu_ctrl(alu_ctrl),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write)
        .ZERO(ZERO)
    );

    inst_decoder idec(
        .opcode(inst[6:0]),
        .funct3(inst[14:12]),
        .funct7b5(inst[30]),
        .alu_ctrl(alu_ctrl),
    ); // ret : alu_ctrl

    // どの命令においてもfunct7 はinst[30]のビットしか違いがない。
    // opcode = inst[6:0];
    // begin
    //     case (opcode)
    //     // 形式I //  opcode is 3, 19, 103 , 27;
    //         7'b0000011 : 
    //             funct3 = inst[14:12];
    //             begin
    //                 case(funct3)
    //                     3'b000 : imm_src = 2'b00; // lb
    //                     3'b001 : imm_src = 2'b01; // lh
    //                     3'b010 : imm_src = 2'b00; // lw
    //                     3'b011 : imm_src = 2'b00; // sltiu
    //                     3'b100 : imm_src = 2'b00; // xori
    //                     3'b101 : imm_src = 2'b00; // srli or srai
    //                     3'b110 : imm_src = 2'b00; // ori
    //                     3'b111 : imm_src = 2'b00; // andi
