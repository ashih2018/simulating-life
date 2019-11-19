# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in part1.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns rateDivider.v

# Load simulation using mux as the top level simulation module.
vsim rateDivider

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# First test case - loading x,y -> drawing -> pause -> drawing -> stop -> loading x,y -> drawing
# to understand what's going on see how the state changes based on the input.
# Set input values using the force command, signal names need to be in {} brackets.
force {reset} 0, 1 3 ns
force {clock} 0, 1 1 ns -r 2 ns
force { d } 10#5
# Run simulation for a few ns.
run 70 ns