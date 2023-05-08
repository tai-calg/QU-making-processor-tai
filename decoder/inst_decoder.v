module inst_decoder(
    input [1:0] alu_op,
    input [2:0] funct3,
    input funct7_5,
    output [3:0] alu_ctrl,
    output [1:0] byte_size,
);
    // following code is generated by GPT4.
    //TODO: check the correctness of the code by human inspection.
    always @(*) begin
        // Initialize ALU control signal to 0
        alu_ctrl = 4'b0000;

        // Decode ALU operations
        case (alu_op) 
            2'b00: begin // Load/Store
                case (funct3)
                    3'b000: begin //1byte load/store(lb/sb)
                        alu_ctrl = 4'b0000; 
                        byte_size = 2'b10; // this is 1byte l/s
                    end
                    3'b001: begin //2byte load/store(lh/sh)
                        alu_ctrl = 4'b0000;
                        byte_size = 2'b01; // this is 2byte l/s
                    end
                    3'b010: begin // ADD (store/load)
                        alu_ctrl = 4'b0000;
                        byte_size = 2'b00; // this is 4byte l/s
                    end
                endcase
            end

            2'b01: begin // Branch
                case (funct3)
                    3'b000: alu_ctrl = 4'b1010; // BEQ 
                    3'b001: alu_ctrl = 4'b1011; // BNE 
                    3'b100: alu_ctrl = 4'b1100; // BLT 
                    3'b101: alu_ctrl = 4'b1101; // BGE 
                    3'b110: alu_ctrl = 4'b1000; // BLTU 
                    3'b111: alu_ctrl = 4'b1001; // BGEU 
                endcase
            end

            2'b10: begin // Arithmetic/Logic
                case (funct3)
                    3'b000: begin // ADD/SUB
                        if (funct7_5 == 1'b0)
                            alu_ctrl = 4'b0000; // ADD
                        else if (funct7_5 == 1'b1)
                            alu_ctrl = 4'b0001; // SUB
                    end

                    3'b001: alu_ctrl = 4'b0101; // SLL
                    3'b010: alu_ctrl = 4'b1100; // SLT signed <
                    3'b011: alu_ctrl = 4'b1100; // SLTU signed <
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    3'b101: begin // SRL/SRA
                        if (funct7_5 == 1'b0)
                            alu_ctrl = 4'b0110; // SRL (LSR)
                        else if (funct7_5 == 1'b1)
                            alu_ctrl = 4'b0111; // SRA (ASR)
                    end

                    3'b110: alu_ctrl = 4'b0011; // OR 
                    3'b111: alu_ctrl = 4'b0010; // AND 
                endcase
            end
            default: begin
                alu_ctrl = 4'bxxxx;
            end
        endcase
    end

endmodule
