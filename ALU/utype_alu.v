module utype_alu(
    input IS_lui,
    input IS_Utype,
    input [19:0] imm20,
    input [31:0] pc,
    output [31:0] result,
);

    if(IS_Utype) begin
        if(IS_lui) begin
            result = {imm20, 12'b0};
        end
        else begin
            result = {imm20, 12'b0} + pc;
        end
    end
    else begin
        result = 32'hxxxx;
    end
endmodule
