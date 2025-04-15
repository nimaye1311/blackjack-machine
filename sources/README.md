# Processor
## NAME (NETID)
Nimaye Garodia (ng215)
## Description of Design
1. 5 Stage MIPS-pipelined processor
2. Supports basic arithmetic ops, comparisons to zero as well as comparing two registers, setting and branching on exceptions as well as jumps and branches
3. Supports 50 MHz clock
## Bypassing
1. W/M, M/X, W/X bypassing all available to minimize stalls
2. Data hazards only stall when `lw $rd, N($rs)` is followed by some `func $rt($rd, $rk)` where we need `$rd` but the earliest this value exists is in the writeback stage
## Stalling
1. Control loops and branches use stalls when evaluated and flushing (branches are assumed to be not taken by default, if taken then flushed)
## Optimizations
1. Quine-McCluskey applied at every stage possible to simplify logic
2. Enhanced Booth's multiplication algorithm to reduce number of cycles for mult by a factor of two
3. Carry-lookahead adder to reduce gate delays vs a regular ripple carry adder
4. Minimal stalling and bypassing through smart logic, optimized gates
## Bugs
1. None known.