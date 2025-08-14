vlib work

vmap work work

vlog +cover=bcsef ./altpll_ctrl.v
vlog -sv ./altpll_ctrl_tb.sv

vsim -t ns -coverage -voptargs=+acc -debugdb=+acc work.altpll_ctrl_tb -do "do run.do"