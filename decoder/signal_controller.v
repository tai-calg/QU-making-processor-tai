/*
import load_wait;
*/


module signal_controller(
    input [6:0] opcode,
    input [2:0] funct3 , //for shamt judge.
    input flush,

    output wire [1:0] result_src, 
    output wire mem_write,
    output wire alu_src, 
    output wire [2:0] imm_src,
    output wire reg_write,
    output wire [1:0] alu_op,
    output wire mreq,
    output wire is_branch, 
    output wire Jump,
    output wire IS_Utype,
    output wire IS_lui,
    output wire IS_jalr
    ); 
    
    // ZERO : for branch judge
    /*
    alu_opの説明：
    00 ... ロード系のaddsub
    01 ... 分岐用のaddsub
    10 ... functのビットで判断 
    */

        
   function [15:0] main_decoder(
        input [6:0] opcode,
        input [2:0] funct3
    );

        case (opcode) 
        //16b'resultsrc_memwrite_alusrc_immsrc_regwrite_aluop_mreq_Branch_Jump_Utype_Lui_Jalr
            7'b0000011 : main_decoder = 16'b01_0_1_000_1_00_1_0_0_0_0_0; // 3: I-type: load d,w,h,b
            7'b0010011 : begin 
                //main_decoder = 16'b00_0_1_000_1_11_0_0_0_0_0_0; // 19: I-type: immidiate 
                case (funct3) 
                    3'b001 : main_decoder = 16'b00_0_1_101_1_11_0_0_0_0_0_0; // 19: I-type: slli only
                    3'b101 : main_decoder = 16'b00_0_1_101_1_11_0_0_0_0_0_0; // 19: I-type: srai,srli. immsrc is 101
                    default: main_decoder = 16'b00_0_1_000_1_11_0_0_0_0_0_0; // 19: I-type: immidiate
                endcase
            end
            7'b1100111 : main_decoder = 16'b00_0_1_000_1_10_0_1_1_0_0_1; // 103: I-type: jalr
            7'b0100011 : main_decoder = 16'b00_1_1_001_0_00_1_0_0_0_0_0; // 35: S-type: store d,w,h,b // resultsrc xx into 00
            7'b0110011 : main_decoder = 16'b00_0_0_xxx_1_10_0_0_0_0_0_0; // 51: R-type: algebraic op of word(,which mean 32bit). add,sub,sll,slt,sltu,xor,srl,sra,or,and
            7'b1100011 : main_decoder = 16'b00_0_0_010_0_01_0_1_0_0_0_0; // 99: B-type: branch // resultsrc xx into 00
            7'b1101111 : main_decoder = 16'b10_0_x_011_1_xx_0_0_1_0_0_0; // 111: J-type: jal
            7'b0010111 : main_decoder = 16'b11_0_1_100_1_xx_0_0_0_1_0_0; // 23: U-type: auipc
            7'b0110111 : main_decoder = 16'b11_0_1_100_1_xx_0_0_0_1_1_0; // 55: U-type: lui
            default: main_decoder = 16'b00_0_0_000_0_00_0_0_0_0_0_0; // 未定義動作！
        endcase
    endfunction



    assign {result_src, mem_write, alu_src, imm_src, reg_write, alu_op, mreq, 
        is_branch, Jump, IS_Utype, IS_lui, IS_jalr} = main_decoder(opcode,funct3);
    
   assign mem_write = flush ? 1'b0 : mem_write;//(35)
   assign reg_write = flush ? 1'b0 : reg_write;


endmodule

/*
    always @(opcode) begin 
        case(opcode)
            7'b0000011: begin // 3: I-type: load 
                result_src <= 2'b01; // read data from ram (0: not read ram , but from alu result)
                mem_write <= 1'b0;
                alu_src <= 1'b1; // select immExt
                imm_src <= 3'b000; // I-type, 12bit extend
                reg_write <= 1'b1; 
                alu_op <= 2'b00;
                mreq <= 1'b1;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
            end
            7'b0010011: begin // 19: I-type: immidiate
                result_src <= 2'b00; // read data from alu result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm
                imm_src <= 3'b000; // I-type, 12bit extend
                reg_write <= 1'b1; 
                alu_op <= 2'b11; // funct3 and funct7
                mreq <= 1'b0;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
            end
            // 7'b0011011: begin // 27: I-type, immidiate word(only "addiw")
            //     result_src <= 2'b00; // read data from alu result
            //     mem_write <= 1'b0;
            //     alu_src <= 1'b1; // imm
            //     imm_src <= 3'b000; // I-type, 12bit extend ...??
            //     reg_write <= 1'b1; 
            //     alu_op <= 2'b10; 
            //     is_branch <= 1'b0; // next is pc+4
            //     Jump <= 1'b0;
            // end // ...RV64I命令のみ
            7'b1100111: begin //! ERROR 103: I-type, jalr
                result_src <= 2'b00; 
                mem_write <= 1'b0; 
                alu_src <= 1'b1; // imm
                imm_src <= 3'b000; // I-type
                reg_write <= 1'b1;  //rd <= pc + 4 (return address) ; WD ← PC + 4
                alu_op <= 2'b10; // 加算だが、lwsw系ではないので。でもどうせadd確定だし00でいいじゃん
                mreq <= 1'b0;
                is_branch <= 1'b1; //pc next! 
                Jump <= 1'b1; // next is rs1 + signext(imm) 
                IS_jalr <= 1'b1;
            end
            7'b0100011: begin // 35: S-type: store d,w,h,b
                result_src <= 2'bxx; // don't care (any)
                mem_write <= 1'b1;
                alu_src <= 1'b1; // immExt
                imm_src <= 3'b001; // S-type, 12bit extend
                reg_write <= 1'b0; 
                alu_op <= 2'b00;
                mreq <= 1'b1;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
            end
            7'b0110011: begin // 51: R-type: algebraic op. add,sub,and,or,xor,sll,srl,sra,slt,sltu
                result_src <= 2'b00; // read data from alu result
                mem_write <= 1'b0;
                alu_src <= 1'b0; // rs2
                imm_src <= 3'bxxx; // R-type, don't care
                reg_write <= 1'b1; 
                alu_op <= 2'b10; // funct3 and funct7
                mreq <= 1'b0;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
            end
            // 7'b0111011: begin // 59: R-type: algebraic op of word(,which mean 32bit). addw,subw,sllw,srlw,sraw
            //     result_src <= 2'b00; // read data from alu result
            //     mem_write <= 1'b0;
            //     alu_src <= 1'b0; // rs2
            //     imm_src <= 3'bxxx; // R-type, don't care
            //     reg_write <= 1'b1; 
            //     alu_op <= 2'b10; 
            //     is_branch <= 1'b0; // next is pc+4
            //     Jump <= 1'b0;
            // end //...RV64I命令のみ
            7'b1100011: begin // 99: B-type: branch
                result_src <= 2'bxx; // don't care 
                mem_write <= 1'b0;
                alu_src <= 1'b0; // rs2
                imm_src <= 3'b010; // B-type, 13bit extend
                reg_write <= 1'b0; 
                alu_op <= 2'b01; // branch addsub
                mreq <= 1'b0;
                is_branch <= 1'b1; // next is pc+offset
                Jump <= 1'b0;
            end
            7'b1101111: begin // 111: J-type: jal
                result_src <= 2'b10; // x[rd] = pc + 4
                mem_write <= 1'b0;
                alu_src <= 1'bx;
                imm_src <= 3'b011; // 21bit extend 
                reg_write <= 1'b1;  // rd <= pc + 4 (return address) ; WD ← PC + 4
                alu_op <= 2'bxx; // don't use ALU
                mreq <= 1'b0;
                is_branch <= 1'b0; 
                Jump <= 1'b1; // next is JTA ( address ; immidiate ) pc<=0 + address
            end
            7'b0010111: begin // 23: U-type: auipc :rd <= pc + {upimm , 12'b0}
                result_src <= 2'b11; //use Utype-ALU result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm
                imm_src <= 3'b100; // U-type, <<12bit extend ... READMEに議論書いてある。
                reg_write <= 1'b1; 
                alu_op <= 2'bxx; 
                mreq <= 1'b0;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
                IS_Utype <= 1'b1; 
                IS_lui <= 1'b0;
                // Utype is 本来のALU使わない
            end 
            7'b0110111: begin // 55: U-type: lui :rd <= {upimm , 12'b0}
                result_src <= 2'b11; //use ALU result
                mem_write <= 1'b0;
                alu_src <= 1'b1; // imm (not use rs2)
                imm_src <= 3'b100; 
                reg_write <= 1'b1; 
                alu_op <= 2'bxx; 
                mreq <= 1'b0;
                is_branch <= 1'b0; // next is pc+4
                Jump <= 1'b0;
                IS_Utype <= 1'b1;
                IS_lui <= 1'b1;
            end 
            default: begin
                result_src <= 2'b00; 
                mem_write <= 1'b0;
                alu_src <= 1'b0;
                imm_src <= 3'b000; 
                reg_write <= 1'b0; 
                mreq <= 1'b0;
                is_branch <= 1'b0; 
                Jump <= 1'b0; // 未定義動作！
            end
        endcase

    end
    */

 



