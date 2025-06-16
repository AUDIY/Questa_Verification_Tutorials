add log -r *

add wave -position insertpoint  \
sim:/multadd_tb/dut/clk \
sim:/multadd_tb/dut/add_a \
sim:/multadd_tb/dut/add_b \
sim:/multadd_tb/dut/mult_c \
sim:/multadd_tb/dut/aresetn \
sim:/multadd_tb/dut/y

onfinish stop

run -all