add log -r *

add wave -position insertpoint  \
sim:/altpll_ctrl_tb/seq_now

add wave -position insertpoint  \
sim:/altpll_ctrl_tb/dut/clk \
sim:/altpll_ctrl_tb/dut/clksel \
sim:/altpll_ctrl_tb/dut/activeclk \
sim:/altpll_ctrl_tb/dut/locked \
sim:/altpll_ctrl_tb/dut/clkswitch \
sim:/altpll_ctrl_tb/dut/areset \
sim:/altpll_ctrl_tb/dut/state

onfinish stop

run -all

coverage report -output altpll_ctrl_coverage_report.txt -srcfile=* -assert -directive -cvg -codeAll