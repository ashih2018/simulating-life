# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in part1.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ns/1ns control.v

# Load simulation using mux as the top level simulation module.
vsim control

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

# First test case
# Set input values using the force command, signal names need to be in {} brackets.
force { loadVal } 2#1111
force {reset} 1, 0 3 ns
force { set } 0, 1 5 ns, 0 7 ns, 1 9 ns, 0 11 ns
force { go } 0, 1 13 ns, 0 21 ns, 1 27 ns
force { stop } 1 21 ns, 0 25 ns
force {clock} 0, 1 1 ns -r 2 ns
# Run simulation for a few ns.
run 70 ns