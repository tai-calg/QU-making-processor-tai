// being imported by ctrl_datapath.v

module pc_ff (
    input clk, rst,
    input [31:0] d,

    output reg [31:0] q // for IAD
);
    // reg q;
    always @(posedge clk or negedge rst) begin
        if(!rst) begin // negativeでリセット
            q <= 32'h1_0000; // Imam.dat記載のpcの初期値
        end
        else begin
            q <= d;
        end
    end
endmodule
