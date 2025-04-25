### REGISTERS ###
# $1: CPU # cards drawn
# $2: CPU total
# $3: total # cards drawn
# $4: player # cards drawn
# $5: player total
# $6: const. value 13
# $7: const. value 52
# $29: const. value 21
# Mem[15]: Random seed location
# Mem[16] - Mem[25]: All cards modulo 13, first 5 are player cards
# Mem[26] - Mem[35]: All cards from 0-51 that are drawn

reset:
	addi $1, $0, 0 # CPU # cards drawn
	addi $2, $0, 0 # CPU total
	addi $3, $0, 0 # total # cards drawn
	addi $4, $0, 0 # player # cards drawn
	addi $5, $0, 0 # player total
	addi $6, $0, 13 # const. value 13
	addi $7, $0, 52 # const. value 52
	addi $29, $0, 21 # const. value 21
	addi $10, $0, 0 # index for all cards array
	addi $11, $0, 8
	sw $0, 4097($0) # reset player loss flag in mem location 4097
clear_mem:
	sw $1, 16($10) # clear cards arr
	sw $1, 26($10) # clear cards arr
	blt $11, $10, draw_2_for_player
	addi $10, $10, 1
	j clear_mem

# JUMPS HERE WHEN RESET OVER TO DRAW INIT CARDS FOR PLAYER
draw_2_for_player:
	jal draw_card # draws a random card and saves in $11
	addi $22, $0, 10
	blt $11, $22, less_than_10
	sub $5, $5, $11 # subtract drawn card from player total
	addi $5, $5, 10 # add 10 to player total
less_than_10:
	add $5, $5, $11
	sw $11, 16($4) # save drawn card in player cards array	
	addi $4, $4, 1 # increment player # cards drawn
	jal draw_card # draws a random card and saves in $11
	addi $22, $0, 10
	blt $11, $22, less_than_10_2
	sub $5, $5, $11 # subtract drawn card from player total
	addi $5, $5, 10 # add 10 to player total
less_than_10_2:
	add $5, $5, $11
	sw $11, 16($4)
	addi $4, $4, 1 # increment player # cards drawn
	j main

draw_card:
	lw $11, 15($0) # load random seed
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
	nop
	nop
	nop
	nop
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
	nop
	nop
	nop
	nop
	nop
	addi $11, $11, 1 # increment drawn card bc we need 1-13, not 0-12
	jr $ra

read_mem:
	lw $20, 4096($0)
	jr $ra

main:
	jal read_mem
	addi $21, $0, 1	
	bne $20, $21, no_BTNU_pressed
	jal draw_card # draws a random card and saves in $11
	addi $22, $0, 10
	blt $11, $22, less_than_10_3
	sub $5, $5, $11 # subtract drawn card from player total
	addi $5, $5, 10 # add 10 to player total
less_than_10_3:
	add $5, $5, $11
	sw $11, 16($4) # save drawn card in player cards array	
	addi $4, $4, 1 # increment player # cards drawn
	addi $22, $0, 1 
	sll $22, $22, 23 # get 2^23 cycles of stall (approx 1 sec) (number of cyces in $22)
	jal delay # delay for 1 sec
	blt $29, $5, player_loss
no_BTNU_pressed:
	addi $21, $0, 2
	bne $20, $21, no_BTND_pressed
## LOGIC FOR CPU TURN ##
	addi $21, $0, 0 
	addi $1, $1, 0
CPU_turn:
	jal draw_card # draws a random card and saves in $11
	addi $22, $0, 10
	blt $11, $22, less_than_10_4
	sub $2, $2, $11 # subtract drawn card from CPU total
	addi $2, $2, 10 # add 10 to CPU total
less_than_10_4:
	add $2, $2, $11 # add to CPU total
	sw $11, 21($1) # save drawn card in CPU cards array
	addi $1, $1, 1 # increment CPU # cards drawn
	addi $22, $0, 1
	sll $22, $22, 24 # get 2^24 cycles of stall (approx 1 sec) (number of cyces in $22)
	jal delay # delay for 1 sec
	addi $25, $0, 17
	blt $2, $25, CPU_turn # if CPU total < 17, draw again
	blt $2, $5, player_win
	blt $29, $2, player_win
	j player_loss
no_BTND_pressed:	
	j main

delay:
	addi $23, $0, 0
loop_2:
	addi $23, $23, 1
	blt $23, $22, loop_2
	jr $ra

player_loss:
	addi $22, $0, 1
	sw $22, 4097($0) # set player loss flag in mem location 4097 as 01 (binary)
	addi $22, $0, 1
	sll $22, $22, 24 # get 2^26 cycles of stall (approx 1 sec) (number of cyces in $22)
	jal delay # delay for 1 sec
	j reset

player_win:
	addi $22, $0, 2
	sw $22, 4097($0) # set player loss flag in mem location 4097 as 10 (binary)
	addi $22, $0, 1
	sll $22, $22, 24 # get 2^26 cycles of stall (approx 1 sec) (number of cyces in $22)
	jal delay # delay for 1 sec
	j reset