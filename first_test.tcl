set search_path [concat "/usr/local/lib/hit18-lib/kyoto_lib/synopsys/" $search_path]
set LIB_MAX_FILE {HIT018.db}
set link_library $LIB_MAX_FILE
set target_library $LIB_MAX_FILE

##read_verilog module
read_verilog ALU/ALU.v
read_verilog ALU/extend.v
read_verilog ALU/utype_alu.v 
read_verilog ALU/sgn_extend.v
read_verilog ALU/rd2ext_4to0.v
read_verilog multicycle_dp/hazard.v 
read_verilog multicycle_dp/mlt_ctrl_datapath.v 
read_verilog multicycle_dp/mlt_dp_regs.v 
read_verilog multicycle_dp/mlt_top.v
read_verilog decoder/mlt_decoder.v 
read_verilog decoder/inst_decoder.v 
read_verilog decoder/signal_controller.v
read_verilog modules/rf32x32.v 
read_verilog modules/DW_ram_2r_w_s_dff.v 
read_verilog other/mux.v 
read_verilog test/top_test.v

current_design "top" 
#read_verilog topmodule
##current_design "TOP_MODULE_NAME"
set_max_area 0
set_max_fanout 64 [current_design]

create_clock -period 10.00 clk
set_clock_uncertainty -setup 0.0 [get_clock clk]
set_clock_uncertainty -hold 0.0 [get_clock clk]
set_input_delay  0.0 -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay 0.0 -clock clk [remove_from_collection [all_outputs] clk]

compile -map_effort medium -area_effort high -incremental_mapping

report_timing -max_paths 1
report_area
report_power

write -hier -format verilog -output HOGEHOGE_PROC.vnet
write -hier -output HOGEHOGE_PROC.db

quit