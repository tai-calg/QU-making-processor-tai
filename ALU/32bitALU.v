module ALU32(A,B,mode,X);

    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] mode;
    output[31:0] X;

    function [32:0] operation;
        input [3:0] mode; // max16 命令
        input signed [31:0] A;
        input signed [31:0] B;

        begin
            case(mode)
                4'd0: operation = 32'h0000_0000;     // NOP
                4'd1: operation = A + B;           // Add
                4'd2: operation = A - B;           // Subtract
                4'd3: operation = A & B;           // Bitwise AND
                4'd4: operation = A | B;           // Bitwise OR
                4'd5: operation = A ^ B;           // Bitwise XOR
                4'd6: operation = A << B;     // logical Shift left 
                4'd7: operation = A >> B;     // logical Shift right
                4'd8: operation = A >>> B ;  // arithmetic Shift right
                // ...

            endcase
        end
    endfunction

    assign X = operation(mode, A, B);


        
        

    // ALU16 alu16_0 (.A(A[15:0]), .B(B[15:0]), .cin(cin), .X(X[15:0]), .cout(C[0]));
    // ALU16 alu16_1 (.A(A[31:16]), .B(B[31:16]), .cin(C[0]), .X(X[31:16]), .cout(cout));
    
endmodule


