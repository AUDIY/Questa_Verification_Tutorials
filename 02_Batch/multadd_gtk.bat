vlib work

vmap work work

vlog multadd.v 
vlog -sv multadd_tb.sv

vsim -t ns -c work.multadd_tb -voptargs=+acc -do "do run_gtk.do"

gtkwave multadd_tb.vcd