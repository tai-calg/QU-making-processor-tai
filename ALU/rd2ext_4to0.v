module rd2ext_4to0 (
    input wire [31:0] rd2,
    input wire rd2ext_src,
    output wire [31:0] rd2ext
);

    function [31:0] rd2extender (
        input rd2ext_src,
        input [31:0] rd2
    );
        if(rd2ext_src == 1'b0) begin
            rd2extender = rd2;
        end
        else if(rd2ext_src == 1'b1) begin //sra , sll , srl
            rd2extender = { {27'b0}, rd2[4:0] };
        end
        else begin
            rd2extender = 32'bx;
        end
    endfunction

    assign rd2ext = rd2extender(rd2ext_src, rd2);

endmodule