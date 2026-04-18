iverilog -o tea_sim.vvp tea_core_tb.v tea_core.v
vvp tea_sim.vvp
gtkwave tea_waves.vcd