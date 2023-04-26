module ALU32(    input signed [31:0] A,
    input signed [31:0] B,
    input [2:0] mode,
    output[31:0] X,
    output ZERO,
    );




    wire ZERO;

    begin
        case(mode)
            3'b000: X = A + B;           // Add
            3'b001: begin               // Subtract
                X = A - B;
                assign ZERO = (X == 0) ? 1 : 0;
            end         // Subtract
            3'b010: X = A & B;           // Bitwise AND
            3'b011: X = A | B;           // Bitwise OR
            3'b100: X = A ^ B;           // Bitwise XOR
            3'b101: X = A << B;     // logical Shift left 
            3'b110: X = A >> B;     // logical Shift right
            3'b111: X = A >>> B ;  // arithmetic Shift right

        endcase
    end



          

        
        

    // ALU16 alu16_0 (.A(A[15:0]), .B(B[15:0]), .cin(cin), .X(X[15:0]), .cout(C[0]));
    // ALU16 alu16_1 (.A(A[31:16]), .B(B[31:16]), .cin(C[0]), .X(X[31:16]), .cout(cout));
    
endmodule


