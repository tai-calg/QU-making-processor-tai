#!/bin/bash
make clean 
make 
mv top_test.vvp ./test/top_test.vvp
vvp test/top_test.vvp
mv top_test.vcd ./test/top_test.vcd
