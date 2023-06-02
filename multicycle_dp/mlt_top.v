
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
    wire IS_lui,IS_Utype,IS_jalr,mem_write,reg_write,alu_src,rd2ext_src;
    wire [31:0] rd2;
    wire pc_enable;
    wire Jump, is_branch;
    wire mreq_M, mreq_temp;

    assign MREQ = mreq_M;


    decoder dec(
        // .clk(clk), .rst(rst), マルチだとデコーダーもタイミングを合わせるために同期する
        .inst(IDT),
        .ZERO(ZERO), //still not defined 

        .result_src(result_src),
        .mem_write(WRITE),
        .alu_ctrl(alu_ctrl),
        .alu_src(alu_src),
        .imm_src(imm_src),
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
        .IS_jalr(IS_jalr),
        .is_branch(is_branch),
        .Jump(Jump),
        .byte_size(SIZE),
        .sgn_ext_src(sgn_ext_src),
        .mreq(mreq_temp), // 3 , 35だけload,store.
        .rd2ext_src(rd2ext_src) // for sll, srl, sra (shamt)
    ); 
    /*
    decoder means emitting control src wire.
    so pipeline registor should be deployed in datapath
     */

    // assign WRITE = mem_write;　// moved to datapath
    /*
    {signal_controller}------->{ctrl_datapath}
                         |
                         |---->WRITE wire
    */



    ctrl_datapath datapath(
        .clk(clk), .rst(rst),
        .inst(IDT),
        .alu_src(alu_src),
        .result_src(result_src),
        .alu_ctrl(alu_ctrl),
        .imm_src(imm_src),
        .mem_write(mem_write), //pipeline で使うのでdatapathに入れる
        .mreq(mreq_temp), //pipeline で使うのでdatapathに入れる
        .reg_write(reg_write),
        .IS_Utype(IS_Utype),
        .IS_lui(IS_lui),
        .IS_jalr(IS_jalr),
        .is_branch(is_branch),
        .Jump(Jump),
        .rd2ext_src(rd2ext_src),
        .sgn_ext_src(sgn_ext_src), // for pipeline
        .DDT_from_mem(DDT),

        .ZERO(ZERO),
        .pc(IAD),
        .rd2_forMem(rd2), //変更：(DDT) → (rd2)
        .alu_out_forMem(DAD),
        .write(WRITE),
        .mreq_M(mreq_M), 
    );
    wire [31:0] ReadDDT;
    assign DDT = WRITE ? rd2 : 32'hz; //!... WRITE ? からMREQ ? に変更。


endmodule

