addi $1, $0, 1 # $1 = 1
sw $1, 0($0) # store 1 in memory address 0
nop
nop
nop
nop
lw $2, 0($0) # load 1 from memory address 0 into $2
add $1, $1, $1
sw $1, 0($0) # store 2 in memory address 0
nop
nop 
nop
nop
lw $3, 0($0) # load 2 from memory address 0 into $3