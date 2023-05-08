module utype_alu(
    input [31:0] imm20, //extendですでに拡張済み
    input [31:0] pc,
    input IS_lui,
    input IS_Utype,
    output reg [31:0] result
);

    always @(posedge IS_Utype ) begin
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
    end
endmodule
