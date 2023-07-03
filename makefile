# LIBRARY :=  multicycle_dp/mlt_top.v  
LIBRARY := singlecycle_dp/top.v 
	


TEST :=  test/top_test.vvp 


all : $(TEST)
	

clean: 
	rm  test/*.vvp
	rm  test/*.vcd

%.vvp : %.v
	iverilog -o $@ $^ $(LIBRARY) 


