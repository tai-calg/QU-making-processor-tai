module load_wait(
  input clk,
  input [6:0] opcode,

  output reg pc_enable,
  output reg reg_write_load = 1'b0
);
  reg r_loadCount = 1'b0;

  always @(negedge clk) begin 
    if (opcode[6:2] == 5'b00000) begin // Load type
      if (r_loadCount) begin
      // Load count 1
        // r_prevLoad      <= 1'b1;
        r_loadCount     <= 1'b0; // count 0
        pc_enable      <= 1'b1;
        reg_write_load  <= 1'b1;
      end else begin
      // Load !count (0)
        // r_prevLoad     <= 1'b1;
        r_loadCount     <= 1'b1; // count++
        pc_enable      <= 1'b0;
        reg_write_load  <= 1'b0;
      end
    end else begin
      // if (r_prevLoad) begin
      // notLoad prev (!count)
        // r_prevLoad     <= 1'b0;
        r_loadCount     <= 1'b0;
        pc_enable      <= 1'b1;
        reg_write_load  <= 1'b1;
      // end else begin
      // notLoad !prev (!count)
        // r_prevLoad  <= 1'b0;
        // r_loadCount <= 1'b0;
        // o_PCEnable  <= 1'b1;
        // o_regWriteLoad <= 1'b1;
      // end
    end
  end
  
endmodule