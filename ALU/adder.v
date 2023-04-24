module pc_plus4(
    input logic [31:0] pc,
    output logic [31:0] pc_plus4
);
    assign pc_plus4 = pc + 4;
endmodule

module pc_target(
    input logic [31:0] pc,
    input logic [31:0] immext,
    output logic [31:0] pc_target
);
    assign pc_target = pc + immext;
endmodule

