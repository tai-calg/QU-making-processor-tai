module mux(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire  sel,
    output wire [31:0] X
);


    // always @ (sel) begin  
    //     case (sel)  
    //         1'b0 : out <= a;  
    //         1'b1 : out <= b;  
    //     endcase  
    // end

    assign X = (sel == 1'b0) ? A : B; 
    //上記と意味は同じだが、alwaysを使う時はクロックの同期回路として認識したいので、非同期とみなしたくassignを採用。
    // 追記：意味すら同じではない。レジスタを配置するという時点で同期回路を意味する。
    // もしselが動かなかったらこの回路は動かないということである。
    // それはA、Bが次の命令になって変わっているのに、selが変わらないとXは前回の命令の結果のままになっているということを意味する！

endmodule

module mux2(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [31:0] C,
    input wire [31:0] D,
    input wire [1:0] sel,     
    output wire [31:0] X
);
    
    // always @ (sel) begin  
    //     case (sel)  
    //         2'b00 : out <= a;  
    //         2'b01 : out <= b;  
    //         2'b10 : out <= c;  
    //         2'b11 : out <= d;  
    //     endcase  
    // end  
    assign X = (sel == 2'b00) ? A : (sel == 2'b01) ? B : (sel == 2'b10) ? C : D;
endmodule



