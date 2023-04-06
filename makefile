LIBRARY := ALU/32bitALU.v 

TEST := test/32bitAdder_test.vvp \
		test/32bitALU_test.vvp \
		test/main_sim.vvp


all : $(TEST)

clean: 
	rm -rf test/*.vvp
	rm -f *.vcd

%.vvp :$(LIBRARY) %.v
	iverilog -o $@ $(LIBRARY) -s TEST $^
