vlib work

vmap work work

vlog +cover=bcsft ./altpll_ctrl_sva.v
vlog ./ALTPLL_10M50.v
vlog -sv ./altpll_ctrl_sva_tb.sv

vsim -t ps -coverage -voptargs=+acc -debugdb=+acc -assertdebug -L altera_mf_ver work.altpll_ctrl_sva_tb -do "do run.do"