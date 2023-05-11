module ALU(    
    input wire [31:0] A,
    input wire [31:0] B,
    input wire [3:0] mode,
    output reg [31:0] X, //alwaysにしたせいでregになった…
    output reg ZERO
    );




    // wire ZERO;

    always @(mode) begin
        case(mode)
            4'b0000: X = $signed(A) + $signed(B);           // Add overflow無視 // ここsignedだよね。でもunsignedな加算をしたい時はないのかな
            4'b0001: begin               // Subtract overflow無視
                X = $signed(A) - $signed(B);
                assign ZERO = (X == 0) ;
            end         // Subtract
            4'b0010: X = A & B;           // Bitwise AND
            4'b0011: X = A | B;           // Bitwise OR
            4'b0100: X = A ^ B;           // Bitwise XOR
            4'b0101: X = A << B;     // logical Shift left 
            4'b0110: X = A >> B;     // logical Shift right
            4'b0111: X = $signed(A) >>> $signed(B) ;  // arithmetic Shift right
            4'b1000: begin 
                X = (A < B);     // Set on less than
                assign ZERO = X; // assign pc_src = is_branch & ZERO | Jump;より。
            end
            4'b1001: X = (A >= B);
            // 4'b1010: X = A == B;
            4'b1011: begin//bne 違えばゼロフラグが１になる。
                X = (A != B);
                assign ZERO = X;
            end
            4'b1100: begin //
                X = ($signed(A) < $signed(B));//blt
                assign ZERO = X;
            end
            4'b1101: begin//
                X = ($signed(A) >= $signed(B));
                assign ZERO = X;
            end

        endcase

    end
    

endmodule


