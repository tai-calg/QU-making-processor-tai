module utype_alu(
    input [31:0] imm20, //extendですでに拡張済み
    input [31:0] pc,
    input IS_lui,
    input IS_Utype,
    output wire [31:0] result
);

    // always @(posedge IS_Utype ) begin
    //     if(IS_Utype) begin
    //         if(IS_lui) begin
    //             result = imm20;
    //         end
    //         else begin
    //             result = imm20 + pc;
    //         end
    //     end
    //     else begin
    //         result = 32'hxxxx;
    //     end
    // end

    //上と同様の機構をfunctionで作る
    // alwaysだと、IS_Utypeが変化しないときは計算しない。ゆえに計算してほしいのにしない時もあるのがダメ。

    function [31:0] utypealu(
        input [31:0] imm20,
        input [31:0] pc,
        input IS_lui,
        input IS_Utype
    );
        if(IS_Utype) begin
            if(IS_lui) begin
                utypealu = imm20;
            end
            else begin
                utypealu = imm20 + pc;
            end
        end
        else begin
            utypealu = 32'hxxxx;
        end
    endfunction

    assign result = utypealu(imm20, pc, IS_lui, IS_Utype);


endmodule
