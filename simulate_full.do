# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in part1.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns main.v

# Load simulation using mux as the top level simulation module.
vsim main

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# First test case - loading x,y -> drawing -> pause -> simulate -> stop -> loading x,y -> drawing
# to understand what's going on see how the state changes based on the input.
# Set input values using the force command, signal names need to be in {} brackets.
force { SW[7:0] } 2#01, 2#10 16 ns, 2#01 26 ns, 2#11 36 ns, 2#01 42 ns  
force { KEY[1] } 0, 1 3 ns
#force { KEY[2] } 1, 0 5 ns, 1 7 ns, 0 9 ns, 1 11 ns, 0 41 ns, 1 43 ns, 0 45 ns, 1 47 ns
force { KEY[0] } 1, 0 5 ns, 1 7 ns, 0 9 ns, 1 11 ns, 0 21 ns, 1 23 ns, 0 25 ns, 1 27 ns, 0 37 ns, 1 39 ns, 0 41 ns, 1 43 ns
force { KEY[2] } 1, 0 60 ns, 1 201 ns
# force { KEY[3] } 0, 1 21 ns, 0 25 ns, 1 37 ns, 0 39 ns
force {CLOCK_50} 0, 1 1 ns -r 2 ns
# Run simulation for a few ns.
run 210 ns