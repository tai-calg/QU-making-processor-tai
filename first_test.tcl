set search_path [concat "/usr/local/lib/hit18-lib/kyoto_lib/synopsys/" $search_path]
set LIB_MAX_FILE {HIT018.db}
set link_library $LIB_MAX_FILE
set target_library $LIB_MAX_FILE

##read_verilog module
read_verilog control.v
read_verilog IAR.v
read_verilog SR.v
read_verilog ALUflow.v
read_verilog Intfunc.v
read_verilog snexl.v
read_verilog ALU.v
read_verilog ALUcontrol.v
read_verilog brALU.v
read_verilog snex.v
read_verilog Branch.v
read_verilog pc.v
read_verilog DW_ram_2r_w_s_dff.v
read_verilog rf32x32.v
read_verilog Interruptctrl.v
read_verilog hazardcontrol.v
read_verilog fwrd.v
read_verilog plregifid.v
read_verilog plregidex.v
read_verilog plregexmem.v
read_verilog plregmemwb.v
read_verilog IFstage.v
read_verilog IDstage.v
read_verilog EXstage.v
read_verilog MEMstage.v
read_verilog WBstage.v
read_verilog top.v

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