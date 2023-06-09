/* 
import decoder.v
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
`include "decoder/decoder.v"
`include "singlecycle_dp/ctrl_datapath.v"
`include "ALU/sgn_extend.v"

module top (
    input clk, rst,
    input  ACKD_n, ACKI_n, //俺たちが使う時ある…？
    input [31:0] IDT,
    input [2:0] OINT_n,

    output [31:0] IAD, DAD,
    output MREQ, WRITE, // load or store
    output [1:0] SIZE,
    output IACK_n, //割り込みなので現時点では使わない。

    inout [31:0] DDT
);
//この中はもうデータパスも同然

    // def wire //
    wire [1:0] result_src, sgn_ext_src;
    wire [2:0] imm_src;
    wire [3:0] alu_ctrl;
    wire IS_lui,IS_Utype,IS_jalr,mem_write,reg_write,pc_src,alu_src,rd2ext_src;
    wire [31:0] rd2;
    wire pc_enable;
    wire [31:0] ReadDDT;

    decoder dec(
        // .clk(clk), .rst(rst), マルチだとデコーダーもタイミングを合わせるために同期する
        .inst(IDT),
        .ZERO(ZERO), //still not defined 

        .pc_src(pc_src),
        .result_src(result_src),
        .mem_write(WRITE),
        .alu_ctrl(alu_ctrl),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
        .IS_jalr(IS_jalr),
        .byte_size(SIZE),
        .sgn_ext_src(sgn_ext_src),
        .mreq(MREQ), // 3 , 35だけload,store.
        .rd2ext_src(rd2ext_src)
    );

    assign WRITE = mem_write;
    /*
    {signal_controller}------->{ctrl_datapath}
                         |
                         |---->WRITE wire
    */



    ctrl_datapath datapath(
        .clk(clk), .rst(rst),
        .inst(IDT),.ReadDDT(ReadDDT),
        .pc_src(pc_src),
        .alu_src(alu_src),
        .result_src(result_src),
        .alu_ctrl(alu_ctrl),
        .imm_src(imm_src),
        // .mem_write(mem_write),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
        .IS_jalr(IS_jalr),
        .rd2ext_src(rd2ext_src),

        .ZERO(ZERO),
        .pc(IAD),
        .rd2(rd2), //変更：(DDT) → (rd2)
        .alu_out(DAD)
    );
    
    sgn_extend sgnext(DDT, sgn_ext_src, ReadDDT);
    assign DDT = WRITE ? rd2 : 32'hz; 


endmodule

