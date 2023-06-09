`timescale 1ns/1ns
// test for 32bit Full Adder
module main ();

    reg [31:0] a;
    reg [31:0] b;
    wire [31:0] x;
    reg [3:0] mode;

    ALU alu32_0 (.A(a), .B(b), .mode(mode), .X(x));

    initial begin
        $dumpvars;
        a = 32'h00000001; //+
        b = 32'h00000002;
        mode = 0;
        #100;
        a = 32'h0000000A;
        b = 32'h00000020;
        mode = 1;
        #100;
        a = 32'b0000_0000_0000_0000_0000_0000_1100_1100;
        b = 32'b0000_0000_0000_0000_0000_0000_1100_1010;
        mode = 2;
        #100;
        mode = 3;
        #100;
        mode = 4;
        #100;
        b = 32'd2;
        mode = 5;
        #100;
        mode = 6;
        #100;
        mode = 7;
        #100;
        $finish;
    end


endmodule
