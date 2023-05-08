LIBRARY :=  ALU/ALU.v  ALU/adder.v  ALU/extend.v  ALU/utype_alu.v \
	data_path/ctrl_datapath.v data_path/pc_ff.v data_path/top.v \
	decoder/decoder.v decoder/inst_decoder.v decoder/signal_controller.v \
	modules/rf32x32.v modules/DW_ram_2r_w_s_dff.v other/mux.v

TEST := test/32bitALU_test.vvp \


all : $(TEST)

clean: 
	rm -rf test/*.vvp
	rm -f *.vcd

%.vvp : %.v
	iverilog -o $@ $^ $(LIBRARY) 
