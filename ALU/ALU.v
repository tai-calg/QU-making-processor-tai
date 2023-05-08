module ALU(    
    input unsigned [31:0] A,
    input unsigned [31:0] B,
    input wire [2:0] mode,
    output wire [31:0] X,
    output wire ZERO,
    );




    wire ZERO;

    begin
        case(mode)
            4'b0000: X = A + B;           // Add overflow無視
            4'b0001: begin               // Subtract overflow無視
                X = A - B;
                assign ZERO = (X == 0) ? 1 : 0;
            end         // Subtract
            4'b0010: X = A & B;           // Bitwise AND
            4'b0011: X = A | B;           // Bitwise OR
            4'b0100: X = A ^ B;           // Bitwise XOR
            4'b0101: X = A << B;     // logical Shift left 
            4'b0110: X = A >> B;     // logical Shift right
            4'b0111: X = $signed(A) >>> $signed(B) ;  // arithmetic Shift right
            4'b1000: X = A < B;     // Set on less than
            4'b1001: X = A >= B;
            4'b1010: X = A == B;
            4'b1011: X = A != B;
            4'b1100: X = $signed(A) < $signed(B);
            4'b1101: X = $signed(A) >= $signed(B);

        endcase
    end



          

        
        

    // ALU16 alu16_0 (.A(A[15:0]), .B(B[15:0]), .cin(cin), .X(X[15:0]), .cout(C[0]));
    // ALU16 alu16_1 (.A(A[31:16]), .B(B[31:16]), .cin(C[0]), .X(X[31:16]), .cout(cout));
    
endmodule


