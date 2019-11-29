vlib work
vlog -timescale 1ns/1ns main.v
vsim simulation
# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {clock} 0 0, 1 5 -repeat 10

force {load} 0 0, 1 5, 0 40

# force {start} 0 0, 1 25, 0 50, 1 80

force {start} 0 0, 1 50

force {x_in[7:0]} 10#1 10, 10#2 20, 10#3 30

force {y_in[7:0]} 10#2 0

force {reset_n} 0 0, 1 10

run 300 ns