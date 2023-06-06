
// mlt_dp_reg_IFID mltIfId();みたいな形でtopで宣言（インスタンス化）してtopでalways(@posedge clk) をやる。
// mltIdEx.PC <= mltIfId.PC;みたいにシフトさせていく。


module dp_reg #(
    parameter WIDTH = 32,
    parameter INIT_VALUE = 32'b0
) (
    input clk, rst , enable, flush,
    input [WIDTH-1:0] d,

    output reg [WIDTH-1:0] q
);

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            q <= INIT_VALUE;
        end
        else if (enable) begin //~~ stall, flush : 1,1 \ 1,0 \ 0,1 \ 0,0 それぞれどんなqを返す？
            if (flush) begin
                q <= INIT_VALUE; //not stall , flush
            end
            else begin
                q <= d; // pcnext : not stall, not flush
            end
        end //今のままだとストールしたら確定でqが変わらない。 ... stall , flushの時は0にしないのか？
    end
    
endmodule

/*
module mlt_dp_reg_IFID;
    reg [31:0] inst, PC4, PC;
endmodule

module mlt_dp_reg_IDEX;
    reg [31:0] rs1Data, rs2Data,imm_ext,PC,PC4;
    reg [4:0] rs1, rs2, rd_D; //rs1,rs2 is for hazard
    // EX
    reg alu_src,rd2ext_src,IS_jalr,IS_Utype,IS_lui,Jump,is_branch;
    reg [3:0] alu_ctrl;
    reg [2:0] imm_src;
    // MEM
    reg mem_write, mreq, sgn_ext_src;
    // WB
    reg reg_write, result_src;
endmodule

module mlt_dp_reg_EXMEM;
    reg [31:0] alu_out, WD_mem, PC4, u_out;
    reg [4:0] rd_E ;
    // MEM
    reg mem_write, mreq, sgn_ext_src;
    // WB
    reg reg_write, result_src;
endmodule

module mlt_dp_reg_MEMWB;
    reg [31:0] R_DDT, alu_out, PC4, u_out;
    reg [4:0] rd_M;
    // WB
    reg reg_write, result_src;
endmodule
*/
