`include "multicycle_dp/mlt_ctrl_datapath.v"

module top (
    input clk, rst,
    input  ACKD_n, ACKI_n, //俺たちが使う時ある…？
    input [31:0] IDT1,
    input [31:0] IDT2,
    input [2:0] OINT_n,

    output [31:0] IAD, DAD1, DAD2,
    output MREQ1, MREQ2, WRITE1, WRITE2, 
    output [1:0] SIZE1, SIZE2,
    output IACK_n, //割り込みなので現時点では使わない。

    inout [31:0] DDT1, DDT2
);

    // ### inst dependency checker ### //




    // ####### scaler 1 ####### //
    wire [31:0] rd2_1;
    wire mreq_M_1;

    ctrl_datapath datapath1(
        .clk(clk), .rst(rst),
        .inst(IDT1),
        .DDT_from_mem(DDT1),

        .pc(iadd1), //! ... pcチェッカーは一人でいいよね？→ ならpcffはここに出してきて、ここでpc checkすればいいのでは。
        .rd2_forMem(rd2_1), //変更：(DDT) → (rd2)
        .alu_out_forMem(DAD1),
        .WRITE(WRITE1),
        .mreq_M_1(mreq_M_1),
        .BYTE_SIZE(SIZE1)
    );
    assign DDT1 = WRITE1 ? rd2_1 : 32'hz;
    assign MREQ1 = mreq_M_1;
    // #######  ####### //




    // ####### scaler 2 ####### //
    wire [31:0] rd2_2;
    wire mreq_M_2;

    ctrl_datapath datapath2(
        .clk(clk), .rst(rst),
        .inst(IDT2),
        .DDT_from_mem(DDT2),

        .pc(iadd2), //! ... pcチェッカーは一人でいいよね？→ ならpcffはここに出してきて、ここでpc checkすればいいのでは。
        .rd2_forMem(rd2_2), //変更：(DDT) → (rd2)
        .alu_out_forMem(DAD2),
        .WRITE(WRITE2),
        .mreq_M_1(mreq_M_2),
        .BYTE_SIZE(SIZE2)
    );
    assign DDT2 = WRITE2 ? rd2_2 : 32'hz; 
    assign MREQ2 = mreq_M_2;
    // #######  ####### //



    // ### next pc checker ### //


    // #######  ####### //






endmodule
