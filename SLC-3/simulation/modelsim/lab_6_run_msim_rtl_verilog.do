transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/tristate.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/test_memory.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/SLC3_2.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/Mem2IO.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/ISDU.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/HexDriver.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/slc3.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/memory_contents.sv}
vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/lab6_toplevel.sv}

vlog -sv -work work +incdir+U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018 {U:/ece385/SLC-3/Updated_ECE385_lab6_provided_Spring_2018/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 1000 ns
