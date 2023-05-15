#!/bin/bash
make clean 
make 
cd test && vvp top_test.vvp
# open dump.vcd test.gtkw 