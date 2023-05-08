/* 
import decoder.v
import rf32x32.v
import ctrl_datapath.v


   top u_top_1(//Inputs
               .clk(clk), .rst(rst), // clk , rst今回使うのか？
               .ACKD_n(ACKD_n), .ACKI_n(ACKI_n),// 読み込み（or書き込み）を知らせる信号 
               .IDT(IDT), .OINT_n(OINT_n), // inst , interupt
      
               //Outputs
               .IAD(IAD), .DAD(DAD), // inst addr , data addr 
               .MREQ(MREQ), .WRITE(WRITE),  // memoryへのリクエスト , memWrite signal
               .SIZE(SIZE), .IACK_n(IACK_n), // lw,lb,lh判定信号  interupt知らせる信号。今回はつかわない。組み込みやOSレベルで必要になる。
      
               //Inout
               .DDT(DDT) // data[31:0]
               );
*/

module top (
    input clk, rst,
    input [2:0] ACKD_n, ACKI_n,
    input [31:0] IDT,
    input [31:0] OINT_n,

    output [31:0] IAD, DAD,
    output MREQ, WRITE,
    output [1:0] SIZE,
    output IACK_n,

    inout [31:0] DDT,
);
//この中はもうデータパスも同然

    // def wire //
    wire [1:0] result_src;
    wire [2:0] imm_src,alu_ctrl;
    wire IS_lui,IS_Utype,mem_write,reg_write,pc_src,alu_src;

    decoder dec(
        // .clk(clk), .rst(rst), マルチだとデコーダーもタイミングを合わせるために同期する
        .inst(IDT),
        .ZERO(ZERO), //still not defined 

        .pc_src(pc_src),
        .result_src(result_src),
        .mem_write(mem_write),
        .alu_ctrl(alu_ctrl),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
    );

    ctrl_datapath datapath(
        .clk(clk), .rst(rst),
        .result_src(result_src),
        .pc_src(pc_src),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .imm_src(imm_src),
        .mem_write(mem_write),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),

        .ZERO(ZERO),
        .pc_next(IAD),
        .rd2(DDT),
        .alu_out(DAD),
    );


endmodule
