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
    
   assign mem_write = flush ? 1'b0 : opcode == 7'b0100011 ? 1'b1 : 1'b0;
   //reg write is opcode == 3,19, 103, 23, 51, 55, 111
   assign reg_write = flush ? 1'b0 : opcode == 7'b0000011 | opcode == 7'b0010011 | 
    opcode == 7'b1100111 | opcode == 7'b0010111 | opcode == 7'b0110011 | opcode == 7'b0110111 | 
    opcode == 7'b1101111 ? 1'b1 : 1'b0;


endmodule
