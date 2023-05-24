module sgn_extend (
    input wire [31:0] DDT_from_mem,
    input wire [1:0] read_ext_src,
    output wire [31:0] R_DDT
);

    function [31:0] sgn_extender(
        input [31:0] DDT_from_mem,
        input [1:0] read_ext_src
    );
        begin
            if (read_ext_src == 2'b00 ) begin
                sgn_extender = DDT_from_mem;
            end
            else if(read_ext_src == 2'b01  )begin //lb
                sgn_extender = { {24{DDT_from_mem[7]}}, DDT_from_mem[7:0] };
            end
            else if(read_ext_src == 2'b10  )begin //lh
                sgn_extender = { {16{DDT_from_mem[15]}}, DDT_from_mem[15:0] };
            end
            else begin 
                sgn_extender = 32'bx;
            end
        end
    endfunction

    assign R_DDT = sgn_extender(DDT_from_mem, read_ext_src);

endmodule
