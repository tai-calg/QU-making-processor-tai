module ALU16(A,B,cin,X,cout);

    input [15:0] A;
    input [15:0] B;
    input cin;
    output[15:0] X;
    output cout;

    wire [14:0] C;

    ALU4 alu4_0 (.A(A[3:0]), .B(B[3:0]), .cin(cin), .X(X[3:0]), .cout(C[0]));
    ALU4 alu4_1 (.A(A[7:4]), .B(B[7:4]), .cin(C[0]), .X(X[7:4]), .cout(C[1]));
    ALU4 alu4_2 (.A(A[11:8]), .B(B[11:8]), .cin(C[1]), .X(X[11:8]), .cout(C[2]));
    ALU4 alu4_3 (.A(A[15:12]), .B(B[15:12]), .cin(C[2]), .X(X[15:12]), .cout(cout));

endmodule