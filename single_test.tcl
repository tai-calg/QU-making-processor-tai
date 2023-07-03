set search_path [concat "/usr/local/lib/hit18-lib/kyoto_lib/synopsys/" $search_path]
set LIB_MAX_FILE {HIT018.db}
set link_library $LIB_MAX_FILE
set target_library $LIB_MAX_FILE

##read_verilog module
read_verilog singlecycle_dp/top.v
read_verilog singlecycle_dp/ctrl_datapath.v
read_verilog singlecycle_dp/pc_ff.v
read_verilog ALU/ALU.v
read_verilog ALU/extend.v
read_verilog ALU/adder.v
read_verilog ALU/utype_alu.v
read_verilog ALU/sgn_extend.v
read_verilog ALU/rd2ext_4to0.v
read_verilog decoder/decoder.v
read_verilog decoder/inst_decoder.v
read_verilog decoder/signal_controller.v
read_verilog decoder/load_wait.v
read_verilog modules/rf32x32.v
read_verilog modules/DW_ram_2r_w_s_dff.v
read_verilog other/mux.v

#read_verilog topmodule
analyze -format verilog ALU/ALU.v
analyze -format verilog ALU/extend.v
analyze -format verilog ALU/adder.v
analyze -format verilog ALU/utype_alu.v
analyze -format verilog ALU/sgn_extend.v
analyze -format verilog ALU/rd2ext_4to0.v
analyze -format verilog singlecycle_dp/pc_ff.v
analyze -format verilog singlecycle_dp/ctrl_datapath.v 
analyze -format verilog singlecycle_dp/top.v
analyze -format verilog decoder/decoder.v
analyze -format verilog decoder/inst_decoder.v
analyze -format verilog decoder/signal_controller.v
analyze -format verilog modules/rf32x32.v
analyze -format verilog modules/DW_ram_2r_w_s_dff.v
analyze -format verilog other/mux.v
elaborate top
current_design "top"
##current_design "TOP_MODULE_NAME"
set_max_area 0
set_max_fanout 64 [current_design]

create_clock -period 11.00 clk
set_clock_uncertainty -setup 0.0 [get_clock clk]
set_clock_uncertainty -hold 0.0 [get_clock clk]
set_input_delay   -clock clk [remove_from_collection [all_inputs] clk]
set_output_delay 0.0 -clock clk [remove_from_collection [all_outputs] clk]

compile -map_effort medium -area_effort high -incremental_mapping

report_timing -max_paths 2
report_area
report_power

write -hier -format verilog -output HOGEHOGE_PROC.vnet
write -hier -output HOGEHOGE_PROC.db

quit
