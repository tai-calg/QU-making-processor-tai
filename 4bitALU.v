module ALU4 (A,B,cin,X,cout);

    // input wire [3:0] mode,
    input [3:0] A;
    input [3:0] B;
    input cin;
    output[3:0] X;
    output cout;

    wire [2:0] Ctemp;

    //mode
    //TODO まだALU1が全加算機でしかないんで+しかできない
    // 0x00 : 0000 : +
    // 0x01 : 0001 : -
    // 0x02 : 0010 : &
    // 0x03 : 0011 : |
    // 0x04 : 0100 : ^
    // 0x05 : 0101 : not ~
    // 0x06 : 0110 : <<
    // 0x07 : 0111 : >>
    // 0x08 : 以降まだ未定義

    //関数モジュールは順番通りに処理される

    ALU1 alu1_0 (.A(A[0]), .B(B[0]), .Cin(cin), .S(X[0]), .Cout(Ctemp[0]));
    ALU1 alu1_1 (.A(A[1]), .B(B[1]), .Cin(Ctemp[0]), .S(X[1]), .Cout(Ctemp[1]));
    ALU1 alu1_2 (.A(A[2]), .B(B[2]), .Cin(Ctemp[1]), .S(X[2]), .Cout(Ctemp[2]));
    ALU1 alu1_3 (.A(A[3]), .B(B[3]), .Cin(Ctemp[2]), .S(X[3]), .Cout(cout));

endmodule