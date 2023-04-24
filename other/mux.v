module mux(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic  sel,
    output logic [31:0] X
);

    always_comb
        case(sel)
            2'b0: X = A;
            2'b1: X = B;
        endcase
endmodule

module mux2(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic [31:0] C,
    input logic [1:0] sel,     
    output logic [31:0] X
);
    
    always_comb
        case(sel)
            2'b00: X = A;
            2'b01: X = B;
            2'b10: X = C;
            default: X = 32'bx;
        endcase
endmodule



