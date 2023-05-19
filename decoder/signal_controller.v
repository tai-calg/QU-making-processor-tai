/*
import load_wait;
*/


module signal_controller(
    input [6:0] opcode,

    output reg Jump,
    output reg [1:0] result_src, 
    output reg mem_write,
    output reg alu_src, 
    output reg [2:0] imm_src,
    output reg reg_write,
    output reg [1:0] alu_op,
    output reg mreq,
    output reg is_branch, 
    output reg IS_Utype,
    output reg IS_lui
    ); 
    
    // ZERO : for branch judge
    /*
    alu_opの説明：
    00 ... ロード系のaddsub
    01 ... 分岐用のaddsub
    10 ... functのビットで判断 
    */

        



    always @(opcode) begin 
        case(opcode)
            7'b0000011: begin // 3: I-type: load 
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'b01; // read data from ram (0: not read ram , but from alu result)
                mem_write <= 1'b0;
                alu_src <= 1'b1; // select immExt
                imm_src <= 3'b000; // I-type, 12bit extend
                reg_write <= 1'b1; 
                Jump <= 1'b0;
                alu_op <= 2'b00;
                mreq <= 1'b1;
            end
            7'b0010011: begin // 19: I-type: immidiate
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'b00; // read data from alu result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm
                imm_src <= 3'b000; // I-type, 12bit extend
                reg_write <= 1'b1; 
                Jump <= 1'b0;
                alu_op <= 2'b11; // funct3 and funct7
                mreq <= 1'b0;
            end
            // 7'b0011011: begin // 27: I-type, immidiate word(only "addiw")
            //     is_branch <= 1'b0; // next is pc+4
            //     result_src <= 2'b00; // read data from alu result
            //     mem_write <= 1'b0;
            //     alu_src <= 1'b1; // imm
            //     imm_src <= 3'b000; // I-type, 12bit extend ...??
            //     reg_write <= 1'b1; 
            //     Jump <= 1'b0;
            //     alu_op <= 2'b10; 
            // end // ...RV64I命令のみ
            7'b1100111: begin // 103: I-type, jalr
                is_branch <= 1'b0; 
                result_src <= 2'b00; 
                mem_write <= 1'b0; 
                alu_src <= 1'b1; // imm
                imm_src <= 3'b000; // I-type, 12bit extend ...??
                reg_write <= 1'b1;  //rd <= pc + 4 (return address) ; WD ← PC + 4
                Jump <= 1'b1; // next is rs1 + signext(imm) 
                alu_op <= 2'b10; // 加算だが、lwsw系ではないので。でもどうせadd確定だし00でいいじゃん
                mreq <= 1'b0;
            end
            7'b0100011: begin // 35: S-type: store d,w,h,b
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'bxx; // don't care (any)
                mem_write <= 1'b1;
                alu_src <= 1'b1; // immExt
                imm_src <= 3'b001; // S-type, 12bit extend
                reg_write <= 1'b0; 
                Jump <= 1'b0;
                alu_op <= 2'b00;
                mreq <= 1'b1;
            end
            7'b0110011: begin // 51: R-type: algebraic op. add,sub,and,or,xor,sll,srl,sra,slt,sltu
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'b00; // read data from alu result
                mem_write <= 1'b0;
                alu_src <= 1'b0; // rs2
                imm_src <= 3'bxxx; // R-type, don't care
                reg_write <= 1'b1; 
                Jump <= 1'b0;
                alu_op <= 2'b10; // funct3 and funct7
                mreq <= 1'b0;
            end
            // 7'b0111011: begin // 59: R-type: algebraic op of word(,which mean 32bit). addw,subw,sllw,srlw,sraw
            //     is_branch <= 1'b0; // next is pc+4
            //     result_src <= 2'b00; // read data from alu result
            //     mem_write <= 1'b0;
            //     alu_src <= 1'b0; // rs2
            //     imm_src <= 3'bxxx; // R-type, don't care
            //     reg_write <= 1'b1; 
            //     Jump <= 1'b0;
            //     alu_op <= 2'b10; 
            // end //...RV64I命令のみ
            7'b1100011: begin // 99: B-type: branch
                is_branch <= 1'b1; // next is pc+offset
                result_src <= 2'bxx; // don't care 
                mem_write <= 1'b0;
                alu_src <= 1'b0; // rs2
                imm_src <= 3'b010; // B-type, 13bit extend
                reg_write <= 1'b0; 
                Jump <= 1'b0;
                alu_op <= 2'b01; // branch addsub
                mreq <= 1'b0;
            end
            7'b1101111: begin // 111: J-type: jal
                is_branch <= 1'b0; 
                result_src <= 2'b10; // x[rd] = pc + 4
                mem_write <= 1'b0;
                alu_src <= 1'bx;
                imm_src <= 3'b011; // 21bit extend 
                reg_write <= 1'b1;  // rd <= pc + 4 (return address) ; WD ← PC + 4
                Jump <= 1'b1; // next is JTA ( address ; immidiate ) pc<=0 + address
                alu_op <= 2'bxx; // don't use ALU
                mreq <= 1'b0;
            end
            7'b0010111: begin // 23: U-type: auipc :rd <= pc + {upimm , 12'b0}
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'b11; //use Utype-ALU result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm
                imm_src <= 3'b100; // U-type, <<12bit extend ... READMEに議論書いてある。
                reg_write <= 1'b1; 
                Jump <= 1'b0;
                alu_op <= 2'bxx; 
                IS_Utype <= 1'b1; 
                IS_lui <= 1'b0;
                // Utype is 本来のALU使わない
                mreq <= 1'b0;
            end 
            7'b0110111: begin // 55: U-type: lui :rd <= {upimm , 12'b0}
                is_branch <= 1'b0; // next is pc+4
                result_src <= 2'b11; //use ALU result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm (not use rs2)
                imm_src <= 3'b100; 
                reg_write <= 1'b1; 
                Jump <= 1'b0;
                alu_op <= 2'bxx; 
                IS_Utype <= 1'b1;
                IS_lui <= 1'b1;
                mreq <= 1'b0;
            end 
            default: begin
                is_branch <= 1'b0; 
                result_src <= 2'b00; 
                mem_write <= 1'b0;
                alu_src <= 1'b0;
                imm_src <= 3'b000; 
                reg_write <= 1'b0; 
                Jump <= 1'b0; // 未定義動作！
                mreq <= 1'b0;
            end
        endcase

    end


endmodule