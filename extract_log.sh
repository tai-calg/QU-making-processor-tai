echo “ === 消費電力 ===”  >> simple_mlt_log
cat log | grep -A 6 “Cell Internal Power” >> simple_mlt_log
echo “ === 面積 === ” >> simple_mlt_log
cat log | grep -A 8 “Combinational area” >> simple_mlt_log
echo “ === クリティカルパス ===” >> simple_mlt_log
cat log | grep -A 10 “clock clk (rise edge)” >> simple_mlt_log

