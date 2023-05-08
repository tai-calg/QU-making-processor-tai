module pc_ff (
    input clk, rst,
    input [31:0] d,

    output reg [31:0] q // for IAD
);
    // reg q;
    always @(posedge clk ) begin
        if(rst == 1'b0) begin // negativeでリセット
            q <= 32'h10000; // Imam.dat記載のpcの初期値
        end
        else begin
            q <= d;
        end
    end
endmodule
