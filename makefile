LIBRARY :=  ALU/ALU.v  ALU/adder.v  ALU/extend.v  ALU/utype_alu.v ALU/sgn_extend.v ALU/rd2ext_4to0.v \
	decoder/decoder.v decoder/inst_decoder.v decoder/signal_controller.v \
	decoder/load_wait.v \
	modules/rf32x32.v modules/DW_ram_2r_w_s_dff.v \
	other/mux.v \
	singlecycle_dp/ctrl_datapath.v singlecycle_dp/pc_ff.v singlecycle_dp/top.v 
	
# multicycle_dp/hazard.v multicycle_dp/mlt_ctrl_datapath.v multicycle_dp/mlt_dp_regs.v \
# multicycle_dp/mlt_top.v  decoder/mlt_decoder.v \

TEST :=  test/top_test.vvp 
# test/32bitALU_test.vvp


all : $(TEST)
	

clean: 
	rm  test/*.vvp
	rm  test/*.vcd

%.vvp : %.v
	iverilog -o $@ $^ $(LIBRARY) 


