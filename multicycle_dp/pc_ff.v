// being imported by ctrl_datapath.v

module pc_ff (
    input clk, rst,
    input [31:0] d,
    input pc_enable,

    output reg [31:0] q // for IAD
);

    always @(posedge clk or negedge rst) begin
        if(!rst) begin // negativeでリセット
            q <= 32'h1_0000; // Imam.dat記載のpcの初期値
        end
        else if (pc_enable) begin //pc_enableはload_waitアリの時。
            q <= d;
        end // ここでpc_enableが0の時はq(pcnext or pc+4)を更新しない
    end
endmodule
