module mux(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic  sel,
    output logic [31:0] X
);


    // always @ (sel) begin  
    //     case (sel)  
    //         1'b0 : out <= a;  
    //         1'b1 : out <= b;  
    //     endcase  
    // end

    assign X = (sel == 1'b0) ? A : B; 
    //上記と意味は同じだが、alwaysを使う時はクロックの同期回路として認識したいので、非同期とみなしたくassignを採用。

endmodule

module mux2(
    input logic [31:0] A,
    input logic [31:0] B,
    input logic [31:0] C,
    input logic [31:0] D,
    input logic [1:0] sel,     
    output logic [31:0] X
);
    
    always @ (sel) begin  
        case (sel)  
            2'b00 : out <= a;  
            2'b01 : out <= b;  
            2'b10 : out <= c;  
            2'b11 : out <= d;  
        endcase  
    end  
endmodule



