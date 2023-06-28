`include "multicycle_dp/mlt_ctrl_datapath.v"

module mlt_top (
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

    // def wire //
    wire [31:0] rd2;
    wire mreq_M;



    ctrl_datapath datapath(
        .clk(clk), .rst(rst),
        .inst(IDT),
        .DDT_from_mem(DDT),

        .pc(IAD),
        .rd2_forMem(rd2), //変更：(DDT) → (rd2)
        .alu_out_forMem(DAD),
        .WRITE(WRITE),
        .mreq_M(mreq_M),
        .BYTE_SIZE(SIZE)
    );
    assign DDT = WRITE ? rd2 : 32'hz; //!... WRITE ? からMREQ ? に変更。
    assign MREQ = mreq_M;


endmodule
