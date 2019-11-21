vlib work
vlog -timescale 1ns/1ns simulating-life.v
vsim simulation
# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# force {clock} 0 0, 1 5 -repeat 10

force {load} 0 0, 1 5, 0 15, 1 50, 0 80

# force {start} 0 0, 1 25, 0 50, 1 80

force {start} 0 0, 1 10, 0 30, 1 31, 0 35, 0 40, 1 90, 0 95, 1 100

force {x_in[7:0]} 10#7 0, 10#50 50, 10#51 60, 10#50 70

force {y_in[7:0]} 10#14 0, 10#50 50, 10#51 70

force {reset_n} 0 0, 1 5

run 300 ns