module super_hazard (
    input [4:0] rs1_IdEx, rs2_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta,
    input reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta,

    output [2:0] forward_rs1, forward_rs2
);

    function [2:0] rs_hazarder (
        input [4:0] rs_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta,
        input reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta
    );
        if ( (reg_write_ExMem_bta && (rs_IdEx == rd_ExMem_bta)) &&  rd_ExMem_bta != 5'b0) begin
            rs_hazarder = 3'b001; //mem beta forward
        end else if ( (reg_write_ExMem_alp && (rs_IdEx == rd_ExMem_alp)) &&  rd_ExMem_alp != 5'b0 ) begin
            rs_hazarder = 3'b010; //mem alpha forward
        end else if ( (reg_write_MemWB_bta && (rs_IdEx == rd_MemWB_bta)) &&  rd_MemWB_bta != 5'b0 ) begin
            rs_hazarder = 3'b011; //wb beta forward
        end else if ( (reg_write_MemWB_alp && (rs_IdEx == rd_MemWB_alp)) &&  rd_MemWB_alp != 5'b0 ) begin
            rs_hazarder = 3'b100; //wb alpha forward
        end else begin
            rs_hazarder = 3'b000; //no forward
        end
    endfunction

    function [5:0] hazarder(
        input [4:0] rs1_IdEx, rs2_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta,
        input reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta
    );
        hazarder = {rs_hazarder(rs1_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta, reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta), 
                    rs_hazarder(rs2_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta, reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta)};
    endfunction

    assign {forward_rs1, forward_rs2} = hazarder(rs1_IdEx, rs2_IdEx, rd_ExMem_alp, rd_ExMem_bta, rd_MemWB_alp, rd_MemWB_bta,
         reg_write_ExMem_alp, reg_write_ExMem_bta, reg_write_MemWB_alp, reg_write_MemWB_bta);
    

    // function [3:0] hazarder (
    //     input [4:0] rs1_IdEx, rs2_IdEx, rd_ExMem, rd_MemWB,
    //     input reg_write_ExMem, reg_write_MemWB
    // );
    //     hazarder = {rs_hazarder(rs1_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB), 
    //                 rs_hazarder(rs2_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB)};

    // endfunction

    // assign {forward_rs1, forward_rs2} = hazarder(rs1_IdEx, rs2_IdEx, rd_ExMem, rd_MemWB, reg_write_ExMem, reg_write_MemWB);

endmodule

