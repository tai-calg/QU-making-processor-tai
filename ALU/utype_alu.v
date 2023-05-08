module utype_alu(
    input [31:0] imm20,
    input [31:0] pc,
    input IS_lui,
    input IS_Utype,
    output [31:0] result,
);

    if(IS_Utype) begin
        if(IS_lui) begin
            result = imm20;
        end
        else begin
            result = imm20 + pc;
        end
    end
    else begin
        result = 32'hxxxx;
    end
endmodule
