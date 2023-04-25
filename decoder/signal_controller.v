/*
    singnal_controller asig(
        .opcode(inst[6:0]),
        .pc_src(pc_src),
        .read_ram_src(result_src),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write)
    )
*/

module singnal_controller(
    input [6:0] opcode,
    input ZERO, // ZERO : for branch judge
    input Jump,
    output pc_src, 
    output read_ram_src, // = result_src
    output mem_write,
    output alu_src, 
    output [2:0] imm_src,
    output reg_write,
    output [1:0] alu_op,
    ); // ZERO : for branch judge
    /*
    alu_opの説明：
    00 ... ロード系のaddsub
    01 ... 分岐用のaddsub
    10 ... functのビットで判断 
    */
    begin 
        case(opcode)
            7'b0000011: begin // 3: I-type: load 
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b1; // read data from ram (0: not read ram , but from alu result)
                mem_write = 1'b0;
                alu_src = 1'b1; // select immExt
                imm_src = 3'b000; // I-type, 12bit extend
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b00;
            end
            7'b0010011: begin // 19: I-type: immidiate
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; // read data from alu result
                mem_write = 1'b0;
                alu_src = 1'b1; // imm
                imm_src = 3'b000; // I-type, 12bit extend
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b10; // funct3 and funct7
            end
            7'b0011011: begin // 27: I-type, immidiate word(only "addiw")
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; // read data from alu result
                mem_write = 1'b0;
                alu_src = 1'b1; // imm
                imm_src = 3'b000; // I-type, 12bit extend ...??
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b10; 
            end
            7'b1100111: begin // 103: I-type, jalr
                is_branch = 1'b0; 
                read_ram_src = 1'b0; 
                mem_write = 1'b0; 
                alu_src = 1'b1; // imm
                imm_src = 3'b000; // I-type, 12bit extend ...??
                reg_write = 1'b1;  //rd = pc + 4 (return address) ; WD ← PC + 4
                Jump = 1'b1; // next is rs1 + signext(imm) 
                alu_op = 2'b10; // 加算だが、lwsw系ではないので。でもどうせadd確定だし00でいいじゃん
            end
            7'b0100011: begin // 35: S-type: store d,w,h,b
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'bx; // don't care (any)
                mem_write = 1'b1;
                alu_src = 1'b1; // immExt
                imm_src = 3'b001; // S-type, 12bit extend
                reg_write = 1'b0; 
                Jump = 1'b0;
                alu_op = 2'b00;
            end
            7'b0110011: begin // 51: R-type: algebraic op. add,sub,and,or,xor,sll,srl,sra,slt,sltu
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; // read data from alu result
                mem_write = 1'b0;
                alu_src = 1'b0; // rs2
                imm_src = 3'bxxx; // R-type, don't care
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b10; // funct3 and funct7
            end
            7'b0111011: begin // 59: R-type: algebraic op of word(,which mean 32bit). addw,subw,sllw,srlw,sraw
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; // read data from alu result
                mem_write = 1'b0;
                alu_src = 1'b0; // rs2
                imm_src = 3'bxxx; // R-type, don't care
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b10; 
            end
            7'b1100011: begin // 99: B-type: branch
                is_branch = 1'b1; // next is pc+offset
                read_ram_src = 1'bx; // don't care 
                mem_write = 1'b0;
                alu_src = 1'b0; // rs2
                imm_src = 3'b010; // B-type, 13bit extend
                reg_write = 1'b0; 
                Jump = 1'b0;
                alu_op = 2'b01; // branch addsub
            end
            7'b1101111: begin // 111: J-type: jal
                is_branch = 1'b0; 
                read_ram_src = 1'bx; // don't care. becase don't use ALU
                mem_write = 1'b0;
                alu_src = 1'bx;
                imm_src = 3'b011; // 21bit extend 
                reg_write = 1'b1;  // rd = pc + 4 (return address) ; WD ← PC + 4
                Jump = 1'b1; // next is JTA ( address ; immidiate ) pc=0 + address
                alu_op = 2'bxx; // don't use ALU
            end
            7'b0010111: begin // 23: U-type: auipc :rd = pc + {upimm , 12'b0}
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; //use ALU result
                mem_write = 1'b0;
                alu_src = 1'b1; // imm
                imm_src = 3'b100; // U-type, <<12bit extend ... READMEに議論書いてある。
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b00; // loadタイプ
                //! U形式funct3すらないからどうするんだ？00渡してもfunct3ないから+-判定できないぞ
                // わんちゃんALU使わないパターン
            end 
            7'b0110111: begin // 55: U-type: lui :rd = {upimm , 12'b0}
                is_branch = 1'b0; // next is pc+4
                read_ram_src = 1'b0; //use ALU result
                mem_write = 1'b0;
                alu_src = 1'b1; // imm (not use rs2)
                imm_src = 3'b100; 
                reg_write = 1'b1; 
                Jump = 1'b0;
                alu_op = 2'b00; // loadタイプ
            end 
            default: begin
                is_branch = 1'bx; 
                read_ram_src = 1'bx; // don't care 
                mem_write = 1'bx;
                alu_src = 1'bx;
                imm_src = 3'bxxx; // don't care
                reg_write = 1'bx; 
                Jump = 1'bx; // 未定義動作！
            end
        endcase
        assign pc_src = is_branch & ZERO | Jump; // beginの内？外？
    end
endmodule