module hazard (
    input [4:0] rs1_IdEx, rs2_IdEx, rd_ExMem, rd_MemWB,
    input reg_write_ExMem, reg_write_MemWB,

    output [1:0] forward_rs1, forward_rs2
);

    function [1:0] rs_hazarder (
        input [4:0] rs_IdEx, rd_ExMem, rd_MemWB,
        input reg_write_ExMem, reg_write_MemWB
    );
        if ( (reg_write_ExMem && (rs_IdEx == rd_ExMem)) && (rs_IdEx != 0) ) begin
            hazarder = 4'b01; //mem forward
        end else if ( (reg_write_MemWB && (rs_IdEx == rd_MemWB)) && (rs_IdEx != 0) ) begin
            hazarder = 4'b10; //wb forward
        end else begin
            hazarder = 4'b00; //no forward
        end
    endfunction

    function [3:0] hazarder (
        input [4:0] rs1_IdEx, rs2_IdEx, rd_ExMem, rd_MemWB,
        input reg_write_ExMem, reg_write_MemWB
    );
        hazarder = {rs_hazarder(rs1_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB), 
                    rs_hazarder(rs2_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB)};

    endfunction

    assign {forward_rs1, forward_rs2} = hazarder(rs1_IdEx, rs2_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB);

endmodule

