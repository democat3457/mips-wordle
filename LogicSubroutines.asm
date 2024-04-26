.data
char_counts: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0



.text
#main:
#la $a0, targetWord
#la $a1, guessWord
#la $a2, guessWordMatches

#jal wordle_compare_words

#j exit


#todo, use $a1 to pass in guessWordMatches
#no args, $v0 returns 1 if win, 0 if no win. 
#Checks guessWordMatches for 4 consecutive 2's
checkWin:
	add $t3, $0, $0
	foreachinguessWordMatches:
		lb $t0, guessWordMatches($t3)
		beq, $t0, 2, isTwo
			li $v0, 0
			jr $ra
		isTwo:
	addi $t3, $t3, 1
	bne $t3, 5, foreachinguessWordMatches
	li $v0, 1
	jr $ra


wordle_compare_words:
    # Initialize variables
    li $t0, 0      # Counter for current letter position
    li $t1, 5      # Max number of letters (5)
    
init_char_counts:
    beq $t0, $t1, count_complete
    lb $t6, 0($a0)        # Load current letter of the target word
    addi $t6, $t6, -97   # Calculate the index for the character count array
    sll $t6, $t6, 2	# World align the index
    lw $t7, char_counts($t6)  # Load current count of the character
    addi $t7, $t7, 1      # Increment the count
    sw $t7, char_counts($t6)  # Store the updated count
    addi $a0, $a0, 1      # Move to the next letter in the target word
    addi $t0, $t0, 1      # Increment the letter position counter
    j init_char_counts
    
    
count_complete:
    # Loop through the guess word to find perfect matches and decrease counts
    li $t0, 0      # Reset letter position counter
    addi $a0, $a0, -5 #Reset pointer to target word
perfect_match_loop:
    beq $t0, $t1, indirect_match_loop  # Check if all letters have been compared
    lb $t6, 0($a0)        # Load current letter of the target word
    lb $t7, 0($a1)        # Load current letter of the guess word
    beq $t6, $t7, perfect_match_found  # Check for a perfect match
    addi $a0, $a0, 1      # Move to the next letter in the target word
    addi $a1, $a1, 1      # Move to the next letter in the guess word
    addi $a2, $a2, 1      # Move to the next letter in the output array
    addi $t0, $t0, 1      # Increment the letter position counter
    j perfect_match_loop


perfect_match_found:
    # Update output array for a perfect match and decrease the corresponding count
    lb $t6, 0($a1)        # Load current letter of the guess word
    addi $t6, $t6, -97   # Calculate the index for the character count array
    sll $t6, $t6, 2	# World align the index
    lw $t7, char_counts($t6)  # Load current count of the character
    addi $t7, $t7, -1      # Decrement the count
    sw $t7, char_counts($t6)  # Store the updated count
    li $t6, 2
    sb $t6, 0($a2)      # Store '2' for perfect match
    addi $a0, $a0, 1      # Move to the next letter in the target word
    addi $a1, $a1, 1      # Move to the next letter in the guess word
    addi $a2, $a2, 1      # Move to the next index in the output array
    addi $t0, $t0, 1      # Increment the letter position counter
    j perfect_match_loop
    
indirect_match_loop:
    # Loop through the guess word to find indirect matches and decrease counts
    li $t0, 0      # Reset letter position counter
    addi $a0, $a0, -5 #Reset pointer to target word
    addi $a1, $a1, -5 #Reset pointer to Guess word
    addi $a2, $a2, -5 #Reset pointer to output array
indirect_match_loop_start:
    beq $t0, $t1, end_comparison  # Check if all letters have been compared
    lb $t6, 0($a0)        # Load current letter of the target word
    lb $t7, 0($a1)        # Load current letter of the guess word
    beq $t6, $t7, indirect_match_loop_continue  # Check for a perfect match and skip
    addi $t7, $t7, -97   # Calculate the index for the character count array
    sll $t7, $t7, 2	# World align the index
    lw $t8, char_counts($t7)  # Load current count of the character
    blez $t8, no_indirect_match  # If count is zero or less, no indirect match possible
    li $t6, 1
    sb $t6, 0($a2)        # Store '1' for indirect match
    addi $t8, $t8, -1      # Decrement the count
    sw $t8, char_counts($t7)  # Store the updated count
indirect_match_loop_continue:
    addi $a0, $a0, 1      # Move to the next letter in the target word
    addi $a1, $a1, 1      # Move to the next letter in the guess word
    addi $a2, $a2, 1      # Move to the next index in the output array
    addi $t0, $t0, 1      # Increment the letter position counter
    j indirect_match_loop_start
    
no_indirect_match:
    sb $zero, 0($a2)        # Store '0' for no match
    j indirect_match_loop_continue
    
end_comparison:
    addi $a0, $a0, -5 #Reset pointer to target word
    addi $a1, $a1, -5 #Reset pointer to Guess word
    addi $a2, $a2, -5 #Reset pointer to output array
    # Return the updated pointer to the output array
    jr $ra  # Return to caller

