LIBRARY := ALU/32bitALU.v \
		   ALU/1bitFA.v \
		   ALU/4bitFA.v \
		   ALU/16bitFA.v \
		   ALU/32bitFullAdder.v \

TEST := test/32bitAdder_test.vvp \
		test/32bitALU_test.vvp \


all : $(TEST)

clean: 
	rm -rf test/*.vvp
	rm -f *.vcd

%.vvp : %.v
	iverilog -o $@ $^ $(LIBRARY) 
