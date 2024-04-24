.data
targetWord: .asciiz "aabbb"
guessWord: .asciiz "bbbaa"

beforeNoMatch: .byte ' '
afterNoMatch: .byte ' '
beforeIndirectMatch: .byte '('
afterIndirectMatch: .byte ')'
beforeDirectMatch: .byte '['
afterDirectMatch: .byte ']'
.text
main:
la $a0, targetWord
#lb  $a1, letter
la $a1, guessWord

jal printMatchTypes

j exit


#subroutines

#todo, maybe use stack pointer to save arguments, instead of doing scuffed shit with temp registers
#todo, maybe implement jump table
#todo, only restore $a1 once at the end of the function, and use $t5 instead of $a1 for line 43

#non-leaf function (as it calls typeOfMatch), However, stack not needed
#a0 contains the address of targetWord, $a1 contains the address of guessWord, no return value
#function prints the targetWord, where each letter is one of 3 options
# brackets if direct match [x],  parenthese (x) if indirect match,  lowercase if no match
printMatchTypes:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	addi $sp, $sp, -26
	addi $sp, $sp, -1
	addi $sp, $sp, -5
	add $t3, $0, $0
	add $t5, $a1, $0
	add $t2, $a0, $0
	li $t3, 5
	addi $sp, $sp, 1
	addi $sp, $sp, 5
	SetTable:
	    	lb $t7, ($t2)
	    	add $t7, $t7, -97
	    	add $sp, $sp, $t7
		lb $t4, ($sp) 
		addi $t4, $t4, 1
		sb $t4, ($sp)
		sub $sp, $sp, $t7
		addi $t3, $t3, -1
		addi $t2, $t2, 1
		bne $t3, $zero, SetTable
		
		addi $sp, $sp, -1
		addi $sp, $sp, -5
		add $t2, $a0, $0
		li $t4, 0
		li $t3, 0
		li $t7, 0
		
	foreachinguessWord:
		add $a2, $t3, $0
		add $t6, $t5, $t3
		lb $a1, ($t6)
		
		li $v0, 0
		jal typeOfMatch
		j OtherExit
		#i'm not doing a jump table
		printWord:
		add $sp, $sp, $t3
		lb $v0, ($sp)
		sub $sp, $sp, $t3
		la $a1, guessWord
		add $a1, $a1, $t3
		lb $a1, ($a1)
		beq $v0, 0, returned0
		beq $v0, 1, returned1
		beq $v0, 2, returned2
		
		
		returned0:
		li $v0, 11
		lb $a0, beforeNoMatch
		syscall
		
		add $a0, $a1, $0
		syscall
		
		lb $a0, afterNoMatch
		syscall
		j exitConditionals
		returned1:
		li $v0, 11
		lb $a0, beforeIndirectMatch
		syscall
		
		add $a0, $a1, $0
		syscall
		
		lb $a0, afterIndirectMatch
		syscall
		j exitConditionals
		returned2:
		li $v0, 11
		lb $a0, beforeDirectMatch
		syscall
		
		add $a0, $a1, $0
		syscall
		
		lb $a0, afterDirectMatch
		syscall
		j exitConditionals
		
		exitConditionals:
		add $a0, $t2, $0 #restore $a0
		add $a1, $t5, $0 #restore $a1
		
		addi $t3, $t3, 1
		addi $a1, $a1, 1
		bne $t3, 5, printWord
		
	OtherExit:		
	addi $t3, $t3, 1
	bne $t3, 5, foreachinguessWord
	addi $sp, $sp, 5
	lb $t7, ($sp)
	
	beq $t7, $0, SecondLoop
	addi $sp, $sp, -5
	li $t3, 0
	la $a1, guessWord
	jal printWord
	addi $sp, $sp, 1
	addi $sp, $sp, 26
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	SecondLoop:
	li $t7, 1
	sb $t7, ($sp)
	addi $sp, $sp, -5
	li $t7, 0
	li $t3, 0
	la $a0, targetWord
	la $a1, guessWord
	add $t3, $0, $0
	add $t5, $a1, $0
	add $t2, $a0, $0
	j foreachinguessWord
	


#$a0 contains address of targetWord, $a1 contains letter, $a2 contains index of letter
#returns (in $v0) 0 if no match, 1 if indirectmatch (position not same), 2 if direct match (position matches)
typeOfMatch:
	la $a0, targetWord
	la $a1, guessWord
	
	add $t0, $a0, $t3
	lb $t1, ($t0)
	add $a1, $a1, $t3
	lb $a1, ($a1)
	
	bne $t1, $a1,notDirectMatch
		addi $sp, $sp, 5
		lb $t7, ($sp)
		addi $sp, $sp, -5
		bne $t7, $0, DirectMatchSkip
		
		addi $sp, $sp, 1
		addi $sp, $sp, 5
		addi $a1, $a1, -97
		add $sp, $sp, $a1
		lb $t7, ($sp)
		sub $t7, $t7, 1
		sb $t7, ($sp)
		sub $sp, $sp, $a1
		addi $sp, $sp, -1
		addi $sp, $sp, -5
		

	DirectMatchSkip:
		addi $v0, $0, 2
		add $sp, $sp, $t3
		sb $v0, ($sp)
		sub $sp, $sp, $t3
		jr $ra
	notDirectMatch:
	addi $sp, $sp, 5
	lb $t7, ($sp)
	addi $sp, $sp, -5
	bne $t7, $0, nonDirectSkip
	jr $ra
	nonDirectSkip:
	
	
	addi $sp, $sp, 1
	addi $sp, $sp, 5
	addi $a1, $a1, -97
	add $sp, $sp, $a1
	lb $t4, ($sp)
	addi $t4, $t4, -1
	sb $t4, ($sp)
	blt $t4, $0, notIndirectMatch
	sub $sp, $sp, $a1
	addi $sp, $sp, -1
	addi $sp, $sp, -5
	addi $v0, $0, 1
	add $sp, $sp, $t3
	sb $v0, ($sp)
	sub $sp, $sp, $t3
	jr $ra	
	
	notIndirectMatch:
	sub $sp, $sp, $a1
	addi $sp, $sp, -1
	addi $sp, $sp, -5
	addi $v0, $0, 0
	add $sp, $sp, $t3
	sb $v0, ($sp)
	sub $sp, $sp, $t3
	jr $ra
exit:
    li $v0, 10          # syscall for close
    syscall
