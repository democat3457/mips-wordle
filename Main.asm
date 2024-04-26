

.data
frameBuffer: .space 0x100000

#testingTarget: .asciiz "zabba"
guessWord: .asciiz "bbbaa"
guessWordMatches: .asciiz "00000"

beforeNoMatch: .byte ' '
afterNoMatch: .byte ' '
beforeIndirectMatch: .byte '('
afterIndirectMatch: .byte ')'
beforeDirectMatch: .byte '['
afterDirectMatch: .byte ']'

preBoard: .asciiz 	"Enter 5 long word with only lowercase letters\n(x) represent an indirect match. [x] represent a direct match. 6 strikes or you're out!\n\n\t\t\t\t\t     _board_     \t\t_guesses_\n\t\t\t\t\t-----------------\t\t"
postBoard: .asciiz   	"\t\t\t\t\t-----------------"
betweenRow: .asciiz "\t\t\t\t\t|--+--+---+--+--|\t\t"
preRow: .asciiz "\t\t\t\t\t|"
postRow: .asciiz 	"|\n"

loseMessage: .asciiz "\nBummer! The word was: "
winMessage: .asciiz "\nWinner Winner Chicken Dinner!!"

errorInvalidLength: .asciiz "length of 5 needed, try again\t\t\t\t\t\t"
errorInvalidChars: .asciiz "\nOnly lowercase a-z, try again\t\t\t\t\t\t"
errorInvalidWord: .asciiz "\nWord not found, try again\t\t\t\t\t\t"

.text
main:
#load WordList into memory, and dictionary size
jal getWordList
jal getDictionarySize
move $s0, $v0

#find random value from 0 to dictionarySize - 1
li $a0, 0
li $v0, 42
move $a1, $s0
addi $a1, $a1, -1
syscall

#get word at randomly generated index
jal getWordAtIndex
move $s1, $v0

#draw board
jal drawBoard

#print preboard
li $v0, 4
la $a0, preBoard
syscall

addi $s5, $0, 0
loopWhileTries:
	
	
	#read in user string
	li $v0, 8 					#system call code for read string
	la $a0, guessWord				#address of buffer
	li $a1, 6					#size of input, 5 + 1 null byte
	syscall 					#reads said integer into $v0
	
	#validate user input
	jal isValidInput
	beq $v0, 1, inputWasValid
		j loopWhileTries
	inputWasValid:
	
	#print newline
	li $v0, 11
	li $a0, 10
	syscall
	
	#calculate matchTypes
	move $a0, $s1
	la $a1, guessWord
	la $a2, guessWordMatches
	jal wordle_compare_words
	
	#draw ascii
	jal asciiPrint
	
	#draw gui
	la $a0, guessWordMatches
	move $a1, $s5
	jal drawMatch
	la $a0, guessWord
	move $a1, $s5
	jal drawWord
	
	#check for win
	jal checkWin
	beq $v0, 0, noWin
		#winning sequence
		li $v0, 4
		la $a0, postBoard
		syscall
		la $a0, winMessage
		syscall
		
		j exit
	
	noWin:
	beq $s5, 5, skipPrint
	#print between row
	li $v0, 4
	la $a0, betweenRow
	syscall
	skipPrint:
addi $s5, $s5, 1
bne $s5, 6, loopWhileTries

#print postboard
li $v0, 4
la $a0, postBoard
syscall

la $a0, loseMessage
syscall
move $a0, $s1
syscall
j exit

exit:
    li $v0, 10          # syscall for close
    syscall

#prints the current values of guessWord and guessWordMatches in a user friendly format
asciiPrint:
	li $v0, 4
	la $a0, preRow
	syscall
	#print according to match type for each char in guessWord
	add $t0, $0, $0
	asciiPrintLoop:
		lb $t1, guessWordMatches($t0)
		beq $t1, 0, noMatch
		beq $t1, 1, indirectMatch
		beq $t1, 2, directMatch
		returnToLoop:
		addi $t0, $t0, 1
	bne $t0, 5, asciiPrintLoop
	
	li $v0, 4
	la $a0, postRow
	syscall
	jr $ra
	
	noMatch:
	li $v0, 11
	lb $a0, beforeNoMatch
	syscall
	
	lb $a0, guessWord($t0)
	syscall
	
	lb $a0, afterNoMatch
	syscall
	j returnToLoop
	indirectMatch:
	li $v0, 11
	lb $a0, beforeIndirectMatch
	syscall
	
	lb $a0, guessWord($t0)
	syscall
	
	lb $a0, afterIndirectMatch
	syscall
	j returnToLoop
	directMatch:
	li $v0, 11
	lb $a0, beforeDirectMatch
	syscall
	
	lb $a0, guessWord($t0)
	syscall
	
	lb $a0, afterDirectMatch
	syscall
	j returnToLoop

isValidInput:
	#scan for 	newline character in guessWord (less than 5 letter input)
	#		not using lowercase letters	
	li $t2, 10	#newline character
	li $t3, 97	#'a', lower bound of lowercase alpha characters
	li $t4, 122	#'z', upper bound of lowercase alpha characters
	addi $t0, $0, 0
	validateInputLoop:
		lb $t1, guessWord($t0)
		beq $t1, $t2, invalidLength
		blt $t1, $t3, invalidChars
		bgt $t1, $t4, invalidChars
		addi $t0, $t0, 1
	bne $t0, 5, validateInputLoop
	
	#check if guessWord is in dictionary
	la $a0, guessWord
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal isWordInDictionary
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	beq $v0, 0, invalidWord
	
	#return valid if no violations found
	li $v0, 1
	jr $ra
	
	invalidChars:
	li $v0, 4
	la $a0, errorInvalidChars
	syscall
	li $v0, 0
	jr $ra
	invalidLength:
	li $v0, 4
	la $a0, errorInvalidLength
	syscall
	li $v0, 0
	jr $ra
	invalidWord:
	li $v0, 4
	la $a0, errorInvalidWord
	syscall
	li $v0, 0
	jr $ra
.include "Display.asm"
.include "LogicSubroutines.asm"
.include "Dictionary.asm"
