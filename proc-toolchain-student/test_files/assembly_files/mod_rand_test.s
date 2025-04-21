addi $11, $0, 0
addi $10, $0, 0
loop:
blt $11, $10, quit_loop
addi $10, $10, 1
lw $1, 0($0)
bne $1, $0, non_zero_seed
addi $1, $1, 1
nop
nop
nop
non_zero_seed: rand $1, $1, 0
nop
nop
sw $1, 0($0)
addi $2, $0, 52
div $3, $1, $2
j loop
quit_loop:
nop
nop
nop