LIBRARY :=  ALU/32bitALU.v \

TEST := test/32bitALU_test.vvp \


all : $(TEST)

clean: 
	rm -rf test/*.vvp
	rm -f *.vcd

%.vvp : %.v
	iverilog -o $@ $^ $(LIBRARY) 
