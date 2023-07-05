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
    function [32:0] inst_dependency_checker(
        input [31:0] inst1, inst2
    ); //ret : {nop, is_plus8}. if dep: {nop,0}. if not dep: ret {inst2,1}. 
        // Default return value //!
        inst_dependency_checker = {inst2,1}; //関数が始まるとすぐに、戻り値inst_dependency_checkerにデフォルトの値 {inst2,1} を設定しています。その後の条件分岐によりこの値が上書きされない限り、このデフォルトの値が関数の戻り値となります。

        // if inst[6:0] == B,S形式(;35or99)以外(...つまりrdが存在する命令)
        if(inst1[6:0] != 7'b0100011 && inst1[6:0] != 7'b1100011) begin

            // if inst2 != U,J形式(;23,55,111)以外 (...つまりrs1orrs2が存在する命令)
            if(inst2[6:0] != 7'b0010111 && inst2[6:0] != 7'b0110111 && inst2[6:0] != 7'b1101111 ) begin

                // if inst1 == I形式(;3,19,103)のとき(...つまりrs2がなくて、rs1だけある命令)
                if(inst1[6:0] == 7'b0000011 || inst1[6:0] == 7'b0010011 || inst1[6:0] == 7'b1100111) begin
                    if(inst1[11:7] == inst2[19:15]) begin
                        inst_dependency_checker =  {32'h13,0}; // return nop,0
                    end
                else begin //rs1, rs2 どっちもある命令
                    if(inst1[11:7] == inst2[19:15] || inst1[11:7] == inst2[24:20]) begin
                        inst_dependency_checker =  {32'h13,0}; // return nop,0
                    end
                end

                end

            end
        end
        
    endfunction

    // ####### scaler 1 ####### //
    wire [31:0] rd2_1;
    wire mreq_M_1;
    // ####### scaler 2 ####### //
    wire [31:0] rd2_2;
    wire mreq_M_2;

    wire [31:0] iaddr_bta;
    wire is_plus8;
    assign {iaddr_bta, is_plus8} =  inst_dependency_checker(IDT1, IDT2);
    //TODO inst_dependency_checker だけののテストを書く。 depある命令をテスト。









    ctrl_datapath datapath1(
        .clk(clk), .rst(rst),
        .inst_alp(IDT1),
        .inst_bta(iaddr_bta),
        .DDT_from_mem_alp(DDT1),
        .DDT_from_mem_bta(DDT2),
        .is_plus8(is_plus8),

        .pc(IAD), 
        .rd2_forMem_alp(rd2_1), 
        .rd2_forMem_bta(rd2_2), 
        .alu_out_forMem_alp(DAD1),
        .alu_out_forMem_bta(DAD2),
        .WRITE_alp(WRITE1),
        .WRITE_bta(WRITE2),
        .mreq_M_alp(mreq_M_1),
        .mreq_M_bta(mreq_M_2),
        .BYTE_SIZE_alp(SIZE1),
        .BYTE_SIZE_bta(SIZE2)
    );

    assign DDT1 = WRITE1 ? rd2_1 : 32'hz;
    assign MREQ1 = mreq_M_1;

    assign DDT2 = WRITE2 ? rd2_2 : 32'hz; 
    assign MREQ2 = mreq_M_2;
    // #######  ####### //








    // ### next pc checker ### //


    // #######  ####### //






endmodule
/*
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
*/