### REGISTERS ###
# $1: currently drawn card
# $2: CPU total
# $3: total # cards drawn
# $4: player # cards drawn
# $5: player total
# $6: const. value 13
# $7: const. value 52
# Mem[15]: Random seed location
# Mem[16] - Mem[25]: All cards modulo 13, first 5 are player cards
# Mem[26] - Mem[35]: All cards from 0-51

reset:
	addi $1, $0, 0 # current card
	addi $2, $0, 0 # CPU total
	addi $3, $0, 0 # total # cards drawn
	addi $4, $0, 0 # player # cards drawn
	addi $5, $0, 0 # player total
	addi $6, $0, 13 # const. value 13
	addi $7, $0, 52 # const. value 52
	addi $10, $0, 0 # index for all cards array
	addi $11, $0, 8
clear_mem:
	addi $8, $10, 16
	addi $9, $10, 26
	sw $1, 0($8) # clear cards arr
	sw $1, 0($9) # clear cards arr
	blt $11, $10, draw_2_for_player
	addi $10, $10, 1
	j clear_mem

# JUMPS HERE WHEN RESET OVER TO DRAW INIT CARDS FOR PLAYER
draw_2_for_player:
	jal draw_card # draws a random card and saves in $11
	add $5, $5, $11
	sw $11, 16($4) # save drawn card in player cards array	
	addi $4, $4, 1 # increment player # cards drawn
	jal draw_card # draws a random card and saves in $11
	add $5, $5, $11
	sw $11, 17($0)
	addi $4, $4, 1 # increment player # cards drawn
	j main

main:
	lw $12, 16($0)
    lw $13, 17($0)

draw_card:
	lw $11, 15($0) # load random seed
	addi $28, $0, 1
	bne $11, $0, non_zero_seed
	addi $11, $0, 1 # if seed is 0, set it to 1
non_zero_seed:
	nop
	nop
	nop
	rand $11, $11, 0
	nop
	nop
	nop
	sw $11, 15($0) # save random seed
	div $11, $11, $7 # take modulo with respect to $7 = 52
	addi $17, $0, -1
	addi $19, $0, 35
loop_1:
	addi $17, $17, 1 # increment index
	addi $16, $17, 26 # get address of all cards array
	blt $19, $16, done_loop 
	lw $18, 0($16) # load card from all cards array
	bne $18, $11, loop_1 # if card != drawn card, continue
	j draw_card # else draw again
done_loop:
	sw $11, 26($3) # save drawn card in cards array
	addi $3, $3, 1 # increment total # cards drawn
	div $11, $11, $6 # take modulo with respect to $6 = 13
	addi $11, $11, 1 # increment drawn card bc we need 1-13, not 0-12
	jr $ra
