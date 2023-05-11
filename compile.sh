#!/bin/bash
make clean 
make 
cd test && vvp utf_top_test.vvp
# open dump.vcd test.gtkw 