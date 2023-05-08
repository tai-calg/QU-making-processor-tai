// 教科書p192 and 262
module extend(input wire [31:7] instr , // ∀命令を覆うために31:7にしている ...この書き方やってもいいよね？
              input wire [2:0] immsrc,
              output reg [31:0] immext);

//always_combは組合せ回路；つまりフィードバックのない；マッピング関数を意味するとコンパイラに伝える文法
   always @ (immsrc) begin 
        case(immsrc)
        //signed拡張をしなきゃと思うが、20のように先頭ビットを連続させてるので、自動的にsigned拡張になる
            3'b000: immext = { {20{instr[31]}},instr[31:20]}; // I-type, 12bit extend, +-を判定して分岐できるようにinstr[31]
            3'b010: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // B-type, 20bit extend
            3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // S-type, 7bit extend
            3'b011: immext = {{12{instr[31]}},instr[19:12],instr[20],instr[30:21], 1'b0}; // J-type, 20bit extend
            3'b100: immext = {instr[31:12], 12'b0}; // U-type, 20bit extend
            default: immext = 32'bx; // undefined
        endcase
   end
endmodule
