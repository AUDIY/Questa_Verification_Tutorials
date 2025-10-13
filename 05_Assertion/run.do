add log -r *

atv log -asserts -enable /altpll_ctrl_sva_tb/assert_1
atv log -asserts -enable /altpll_ctrl_sva_tb/assert_2
atv log -asserts -enable /altpll_ctrl_sva_tb/assert_3
atv log -asserts -enable /altpll_ctrl_sva_tb/assert_4
atv log -asserts -enable /altpll_ctrl_sva_tb/assert_5

add wave /altpll_ctrl_sva_tb/assert_1 \
/altpll_ctrl_sva_tb/assert_2 \
/altpll_ctrl_sva_tb/assert_3 \
/altpll_ctrl_sva_tb/assert_4 \
/altpll_ctrl_sva_tb/assert_5

add wave -position insertpoint  \
sim:/altpll_ctrl_sva_tb/dut/clk \
sim:/altpll_ctrl_sva_tb/dut/clksel \
sim:/altpll_ctrl_sva_tb/dut/activeclk \
sim:/altpll_ctrl_sva_tb/dut/locked \
sim:/altpll_ctrl_sva_tb/dut/clkswitch \
sim:/altpll_ctrl_sva_tb/dut/areset \
sim:/altpll_ctrl_sva_tb/dut/state \
sim:/altpll_ctrl_sva_tb/pll_sim/inclk0 \
sim:/altpll_ctrl_sva_tb/pll_sim/inclk1 \
sim:/altpll_ctrl_sva_tb/pll_sim/c0

onfinish stop

run -all

coverage report -output altpll_ctrl_coverage_report.txt -srcfile=* -assert -directive -cvg -codeAll