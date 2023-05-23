module ALU(    
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] mode,
    output wire [31:0] X, //alwaysにしたせいでregになった…
    output wire ZERO
    );





    // always @( mode ) begin
    //     case(mode)
    //         4'b0000: X = $signed(A) + $signed(B);           // Add overflow無視 // ここsignedだよね。でもunsignedな加算をしたい時はないのかな
    //         4'b0001: begin               // Subtract overflow無視
    //             X = $signed(A) - $signed(B);
    //             ZERO = (X == 0) ;
    //         end         // Subtract
    //         4'b0010: X = A & B;           // Bitwise AND
    //         4'b0011: X = A | B;           // Bitwise OR
    //         4'b0100: X = A ^ B;           // Bitwise XOR
    //         4'b0101: X = A << B;     // logical Shift left 
    //         4'b0110: X = A >> B;     // logical Shift right
    //         4'b0111: X = $signed(A) >>> $signed(B) ;  // arithmetic Shift right
    //         //--------------ここまでおｋ----------//
    //         4'b1000: begin 
    //             X = (A < B);    //sltu , bltu , sltiu
    //             ZERO = X; // pc_src = is_branch & ZERO | Jump;より。
    //         end
    //         4'b1001: begin //bgeu
    //             X = (A >= B);
    //             ZERO = X;
    //         end
    //         // 4'b1010: X = A == B;
    //         4'b1011: begin//bne 違えばゼロフラグが１になる。
    //             X = (A != B);
    //             ZERO = X;
    //         end
    //         4'b1100: begin //blt, slt , slti
    //             X = ($signed(A) < $signed(B));
    //             ZERO = X;
    //         end
    //         4'b1101: begin//bge
    //             X = ($signed(A) >= $signed(B));
    //             ZERO = X;
    //         end

    //     endcase

    // end
    
    function [31:0] operation(
        input [3:0] mode,
        input [31:0] A,B
    );
        begin 
            case(mode)
                4'b0000: operation = $signed(A) + $signed(B);           // Add overflow無視 // ここsignedだよね。でもunsignedな加算をしたい時はないのかな
                4'b0001: begin               // Subtract overflow無視
                    operation = $signed(A) - $signed(B);
                end         // Subtract
                4'b0010: operation = A & B;           // Bitwise AND
                4'b0011: operation = A | B;           // Bitwise OR
                4'b0100: operation = A ^ B;           // Bitwise XOR
                4'b0101: operation = A << B;     // logical Shift left 
                4'b0110: operation = A >> B;     // logical Shift right
                4'b0111: operation = $signed(A) >>> $signed(B) ;  // arithmetic Shift right
                4'b1000: begin 
                    operation = (A < B);    // slt, bltu, sltiu
                end
                4'b1001: operation = (A >= B);  //bgeu
                // 4'b1010: operation = A == B;
                4'b1011: begin//bne 違えばゼロフラグが１になる。
                    operation =  (A != B); 
                end
                4'b1100: begin //blt
                    operation = ($signed(A) < $signed(B)); 
                end
                4'b1101: begin//bge
                    operation = ($signed(A) >= $signed(B)); 
                end
            endcase
        end
        
    endfunction

    function zero_process(
        input [3:0] mode,
        input [31:0] X
    );
        begin 
            case(mode)
                4'b0000: zero_process = (X == 0) ;
                4'b0001: zero_process = (X == 0) ;
                4'b0010: zero_process = (X == 0) ;
                4'b0011: zero_process = (X == 0) ;
                4'b0100: zero_process = (X == 0) ;
                4'b0101: zero_process = (X == 0) ;
                4'b0110: zero_process = (X == 0) ;
                4'b0111: zero_process = (X == 0) ;
                4'b1000: zero_process = (X == 1) ; // ここから全部比較なのでX={0,1}
                4'b1001: zero_process = (X == 1) ;
                4'b1010: zero_process = (X == 1) ;
                4'b1011: zero_process = (X == 1) ;
                4'b1100: zero_process = (X == 1) ;
                4'b1101: zero_process = (X == 1) ;
            endcase
        end
    endfunction
    /*
    bltだと、A<B ならば X = 1
    この時、ZERO = 1 としなければ pc_src = is_branch & ZERO | Jump;でジャンプできない
    */

    assign X = operation(mode,A,B);
    assign ZERO = zero_process(mode,X); 

endmodule


