module FULLADD32(A,B,cin,X,cout);

    input [31:0] A;
    input [31:0] B;
    input cin;
    output[31:0] X;
    output cout;
    wire [1:0] C;


        
        

    ALU16 alu16_0 (.A(A[15:0]), .B(B[15:0]), .cin(cin), .X(X[15:0]), .cout(C[0]));
    ALU16 alu16_1 (.A(A[31:16]), .B(B[31:16]), .cin(C[0]), .X(X[31:16]), .cout(cout));
    
endmodule

// module ALU_32bit(
//     input [31:0] A,
//     input [31:0] B,
//     input [2:0] opcode,
//     input cin,
//     output [31:0] Y,
//     output cout,
//     output Z
//     );

//     // Define temporary variables
//     wire [31:0] temp, temp_carry;
//     wire [32:0] temp_32bit;

//     // Perform the selected operation
//     always @*
//     begin
//         case(opcode)
//             3'b000: temp = A + B;           // Add
//             3'b001: temp = A - B;           // Subtract
//             3'b010: temp = A & B;           // Bitwise AND
//             3'b011: temp = A | B;           // Bitwise OR
//             3'b100: temp = A ^ B;           // Bitwise XOR
//             3'b101: temp = A << B[4:0];     // Shift left
//             3'b110: temp = A >> B[4:0];     // Shift right
//             3'b111: temp = A + B + cin;     // Add with carry
//         endcase
//     end

//     // Assign the outputs
//     assign Y = temp;
//     assign Z = (Y == 0);
//     assign cout = (temp_32bit[33] == 1);

// endmodule