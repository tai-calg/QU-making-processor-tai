module ALU1 (A, B, Cin, S, Cout);
    input A,B,Cin;
    output S,Cout;

    assign S = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B ));
endmodule

// module 1ALU #(
//     input wire [7:0] op_decode,
//     input A,
//     input B,
//     input C_in,
//     output X,
//     output C_out,
// );
// //mode 
// // 0x00 : 000 : +
// // 0x01 : 001 : -
// // 0x02 : 010 : &
// // 0x03 : 011 : |
// // 0x04 : 100 : ^ 
// // 0x05 : 101 : <<
// // 0x06 : 110 : >>
// // 0x07 : 111 : not ~

// // nand = ~ A & B
// // nor = ~ A | B
// // xor = A ^ B
   
// endmodule


