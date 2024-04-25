.data

.text
main:
	# Initialize and fetch word list
	jal getWordList
	move $t0, $v0
	move $t1, $v1
	
	# Print first word in dictionary
	li $a0, 0
	jal getWordAtIndex
	move $t3, $v0		# word
	li $v0, 4			# syscall code for print_string
	move $a0, $t3		# buffer containing the word
	syscall
	
	# Print last word in dictionary
	move $a0, $t1
	addi $a0, $a0, -1
	jal getWordAtIndex
	move $t3, $v0		# word
	li $v0, 4			# syscall code for print_string
	move $a0, $t3		# buffer containing the word
	syscall
	
	# Generate random number
	li $a0, 0			# Set seed to default
	move $a1, $t1		# Set maximum value to word list length
	li $v0, 42			# syscall 42: get random val
	syscall
	move $t2, $a0
	
	move $a0, $t2
	jal getWordAtIndex
	move $t3, $v0		# word
	
	# Print the word
	li $v0, 4			# syscall code for print_string
	move $a0, $t3		# buffer containing the word
	syscall
	
	# Exit
	li $v0, 10			# syscall code for exit
	syscall

# Includes
.include "Dictionary.asm"
