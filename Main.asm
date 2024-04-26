

.data
#testingTarget: .asciiz "zabba"
guessWord: .asciiz "bbbaa"
guessWordMatches: .asciiz "00000"

beforeNoMatch: .byte ' '
afterNoMatch: .byte ' '
beforeIndirectMatch: .byte '('
afterIndirectMatch: .byte ')'
beforeDirectMatch: .byte '['
afterDirectMatch: .byte ']'

preBoard: .asciiz 	"\t\t\t\t\t-----------------\t\t"
postBoard: .asciiz   	"\t\t\t\t\t-----------------"
betweenRow: .asciiz "\t\t\t\t\t|--+--+---+--+--|\t\t"
preRow: .asciiz "\t\t\t\t\t|"
postRow: .asciiz 	"|\n"

winMessage: .asciiz "\nWinner Winner Chicken Dinner!!"



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

# Print the word for testing purposes
move $a0, $s1 
li $v0, 4       
syscall

#draw board
#jal drawBoard
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
	
	#print newline
	li $v0, 11
	li $a0, 10
	syscall
	
	#calculate matchTypes
	move $a0, $s1
	la $a1, guessWord
	#jal printMatchTypes
	la $a2, guessWordMatches
	jal wordle_compare_words
	
	jal asciiPrint
	
	#here for DEBUGGING POURPOSes
	#li $v0, 4
	#la $a0, guessWordMatches
	#syscall

	#check for win
	jal checkWin
	beq $v0, 0, noWin
		#winning sequence
		li $v0, 4
		la $a0, postBoard
		syscall
		la $a0, winMessage
		syscall
		
		#ADD A "THE WORD WAS BLANKKK"
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

j exit

.globl exit
exit:
    li $v0, 10          # syscall for close
    syscall

#prints the current values of guessWord and guessWordMatches in a user friendly format
asciiPrint:
	li $v0, 4
	la $a0, preRow
	syscall

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
.include "Display.asm"
.include "LogicSubroutines.asm"
.include "Dictionary.asm"
