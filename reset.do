vlib work
vlog -timescale 1ns/1ns simulating-life.v
vsim datapath
# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

force {clock} 0 0, 1 5 -repeat 10

force {start} 1 0

force {x_in[7:0]} 10#7 0, 10#50 50

force {y_in[7:0]} 10#14 0, 10#13 50

force {reset_n} 0 0, 1 5

run 300 ns