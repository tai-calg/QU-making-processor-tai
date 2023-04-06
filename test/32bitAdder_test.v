`timescale 1ns/1ns
// test for 32bit Full Adder
module main ();

    reg [31:0] a;
    reg [31:0] b;
    reg c;
    wire [31:0] x;
    wire cout;

    FULLADD32 alu32_0 (.A(a), .B(b), .cin(c), .X(x), .cout(cout));

    initial begin
        $dumpvars;
        a = 32'h00000001;
        b = 32'h00000002;
        c = 1;
        #10;
        a = 32'h0000000A;
        b = 32'h00000020;
        #10;
        a = 32'h12345678;
        b = 32'h87654321;
        #10;
        a = 32'hFFFFFFFF;
        b = 32'h08000000;
        c = 0;
        #10;
        $finish;
    end


endmodule
