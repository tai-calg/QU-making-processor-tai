#!/bin/bash
make clean 
make 
vvp test/top_test.vvp
# open dump.vcd test.gtkw 