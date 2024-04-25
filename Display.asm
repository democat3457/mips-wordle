.data
frameBuffer: .space 0x100000
numPixels: .word 0x20000
green: .word 0x0000FF00
yellow: .word 0x00FFFF00
gray: .word 0x00D3D3D3
black: .word 0x00000000
white: .word 0x00FFFFFF
input: .asciiz "hello"
word1: .asciiz "abcde"
word2: .asciiz "fghij"
word3: .asciiz "klmno"
word4: .asciiz "pqrst"
word5: .asciiz "uvwxy"
word6: .asciiz "zzzzz"
tlc: .word 0
#Letters are represented as an array of displacements starting with the top left pixel of the letter and are terminated with -1.
#1 represents one pixel shifted to the right, and 64 represents one pixel down. These must be multiplied by 4 since each pixel is represented by a word.
a: .word 1, 1, 62, 3, 61, 1, 1, 1, 61, 3, 61, 3, -1
b: .word 0, 1, 1, 62, 3, 61, 1, 1, 62, 3, 61, 1, 1, -1
c: .word 1, 1, 1, 61, 64, 64, 65, 1, 1, -1
d: .word 0, 1, 1, 62, 3, 61, 3, 61, 3, 61, 1, 1, -1
e: .word 0, 1, 1, 1, 61, 64, 1, 1, 1, 61, 64, 1, 1, 1, -1
f: .word 0, 1, 1, 1, 61, 64, 1, 1, 1, 61, 64, -1
g: .word 1, 1, 1, 61, 64, 2, 1, 61, 3, 62, 1, 1, -1
h: .word 0, 3, 61, 3, 61, 1, 1, 1, 61, 3, 61, 3, -1
i: .word 1, 1, 1, 63, 64, 64, 63, 1, 1, -1
j: .word 3, 64, 64, 62, 2, 63, -1
k: .word 0, 3, 61, 2, 62, 1, 63, 2, 62, 3, -1
l: .word 0, 64, 64, 64, 64, 1, 1, 1, -1
m: .word 0, 4, 60, 1, 2, 1, 60, 2, 2, 60, 4, 60, 4, -1
n: .word 0, 3, 61, 1, 2, 61, 2, 1, 61, 3, 61, 3, -1
o: .word 1, 1, 62, 3, 61, 3, 61, 3, 62, 1, -1
p: .word 0, 1, 1, 62, 3, 61, 1, 1, 62, 64, -1
q: .word 1, 1, 62, 3, 61, 3, 61, 2, 1, 62, 1, 1, -1
r: .word 0, 1, 1, 62, 3, 61, 1, 1, 62, 2, 62, 3, -1
s: .word 1, 1, 1, 61, 65, 1, 65, 61, 1, 1, -1
t: .word 0, 1, 1, 1, 1, 62, 64, 64, 64, -1
u: .word 0, 3, 61, 3, 61, 3, 61, 3, 61, 1, 1, 1, -1
v: .word 1, 2, 62, 2, 62, 2, 62, 2, 63, -1
w: .word 0, 4, 60, 4, 60, 4, 60, 2, 2, 61, 2, -1
x: .word 1, 2, 62, 2, 63, 63, 2, 62, 2, -1
y: .word 1, 2, 62, 2, 62, 1, 1, 63, 64, -1
z: .word 0, 1, 1, 1, 64, 63, 63, 63, 1, 1, 1, -1
exclam: .word 2, 64, 64, 128, -1

.text
main:
#Draws background
	la $t0, frameBuffer	#Load frame buffer address
	li $t1, 4096		#Number of pixels
	lw $t2, gray		#Load light gray color for background
bg:
	sw $t2, 0($t0)		#Sets the pixel to gray
	addi $t0, $t0, 4	#Increment to the next pixel
	addi $t1, $t1, -1	#Decrease number of pixels remaining by 1
	bnez $t1, bg		#Loop until no pixels remaining (all pixels set to gray)

#Draws rows of game board
	la $t0, frameBuffer	#Load frame buffer address
	li $t1, 0		#Start at row 0:
	lw $t2, white		#Load black color for borders
	li $t3, 41		#Number of pixels per row
	li $t4, 7		#Number of rows
	li $t6, 11		#Change this number to move grid up or down
	sll $t6, $t6, 8
	li $t7, 11		#Change this number to move grid left or right
	sll $t7, $t7 2
	add $s0, $t6, $t7	#Saves the starting pixel (relative to frame buffer address)
	add $t0, $t0, $s0	#Finds the pixel to start drawing grid (top left corner)

row:
	sw $t2, 0($t0)		#Sets the pixel to black
	addi $t0, $t0, 4	#Increment to the next pixel
	addi $t3, $t3, -1	#Decrease number of pixels remaining by 1
	bnez $t3, row		#Loop until no pixels remaining (all pixels set to black)
	la $t0, frameBuffer	#Load frame buffer address
	add $t0, $t0, $s0	#Finds the pixel to start drawing grid (top left corner)
	addi $t1, $t1, 1	#Go to next row
	li $t3, 41		#Pixels per row
	li $t5, 8		#Row every 8 pixels
	sll $t5, $t5, 8		#Multiply by 64 * 4
	mul $t5, $t5, $t1	#Find row position
	add $t0, $t0, $t5	#Set frame buffer to first pixel in row
	bne $t1, $t4, row	#Repeat until all rows drawn
	
#Draws columns of game board
	la $t0, frameBuffer	#Load frame buffer address
	li $t1, 0		#Start at column 0
	lw $t2, white		#Load black color for borders
	li $t3, 49		#Number of pixels per column
	li $t4, 6		#Number of columns
	add $t0, $t0, $s0	#Finds the pixel to start drawing grid (top left corner)

col:
	sw $t2, 0($t0)		#Sets the pixel to black
	addi $t0, $t0, 256	#Increment to the next pixel
	addi $t3, $t3, -1	#Decrease number of pixels remaining by 1
	bnez $t3, col		#Loop until no pixels remaining (all pixels set to black)
	la $t0, frameBuffer	#Load frame buffer address
	add $t0, $t0, $s0	#Finds the pixel to start drawing grid (top left corner)
	addi $t1, $t1, 1	#Go to next column
	li $t3, 49		#Number of pixels per column
	li $t5, 8		#Column every 8 pixels
	sll $t5, $t5, 2		#Multiply by 4
	mul $t5, $t5, $t1	#Find column position
	add $t0, $t0, $t5	#Set frame buffer to first pixel in column
	bne $t1, $t4, col	#Repeat until all columns drawn
	
#Finds the top left corner of the board (top left pixel of letter in top left square) and stores it for future use
	la $t0, frameBuffer	#Load frame buffer address
	add $t0, $t0, $s0	#Finds the top left corner of the grid
	li $t2, 2
	sll $t2, $t2, 8		#Moves two pixels down
	addi $t2, $t2, 8	#Moves two pixels right
	add $t0, $t0, $t2	#Gets location where first letter should be drawn
	sw $t0, tlc		#Store pixel location
	
#Draws hello as the first guess
	la $a0, word1	#Load address of the word that was guessed
	li $a1, 1	#Guess number (1-6)
	jal drawWord
	la $a0, word2	#Load address of the word that was guessed
	li $a1, 2	#Guess number (1-6)
	jal drawWord
	la $a0, word3	#Load address of the word that was guessed
	li $a1, 3	#Guess number (1-6)
	jal drawWord
	la $a0, word4	#Load address of the word that was guessed
	li $a1, 4	#Guess number (1-6)
	jal drawWord
	la $a0, word5	#Load address of the word that was guessed
	li $a1, 5	#Guess number (1-6)
	jal drawWord
	la $a0, word6	#Load address of the word that was guessed
	li $a1, 6	#Guess number (1-6)
	jal drawWord
	j exit
	
drawWord:
	move $t3, $zero		#Position of letter in row (starts at position 0)
	addi $a1, $a1, -1	#Guess number - 1 to get row #
	addi $sp, $sp, -4	#Update stack pointer
	sw $ra, 0($sp)		#Save return address to stack

drawLoop:
	lw $s0, tlc		#Top left corner of first letter in row 0 (top row)
	li $t4, 8		#8 pixels per row and per column
	sll $t4, $t4, 8		#To move down 8 pixels
	mul $t5, $t4, $a1	#Multiply by number of rows to move down
	add $s0, $s0, $t5	#Move down by the necessary number of rows
	srl $t4, $t4, 6		#To move right 8 pixels
	mul $t5, $t4, $t3	#Multiply by number of spaces to move right
	add $s0, $s0, $t5	#Move right by necessary number of spaces
	move $t1, $a0		#Move argument to $t1 since we are about to call another subroutine
	lb $a0, 0($t1)		#Load char as argument
	jal letter		#Call subroutine to draw letter
	addi $a0, $t1, 1	#Increment address we're reading char from by 1
	addi $t3, $t3, 1	#Increment position of letter in row by 1 (shift 1 position right)
	bne $t3, 5, drawLoop	#Loop until we get to position 5 (all letters should be drawn by this point)
	lw $ra, 0($sp)		#Load return address from stack
	addi $sp, $sp, 4	#Update stack pointer
	jr $ra			#Return

#The letter that needs to be drawn based on the ASCII value in $a0
letter:
	beq $a0, 97, drawA
	beq $a0, 98, drawB
	beq $a0, 99, drawC
	beq $a0, 100, drawD
	beq $a0, 101, drawE
	beq $a0, 102, drawF
	beq $a0, 103, drawG
	beq $a0, 104, drawH
	beq $a0, 105, drawI
	beq $a0, 106, drawJ
	beq $a0, 107, drawK
	beq $a0, 108, drawL
	beq $a0, 109, drawM
	beq $a0, 110, drawN
	beq $a0, 111, drawO
	beq $a0, 112, drawP
	beq $a0, 113, drawQ
	beq $a0, 114, drawR
	beq $a0, 115, drawS
	beq $a0, 116, drawT
	beq $a0, 117, drawU
	beq $a0, 118, drawV
	beq $a0, 119, drawW
	beq $a0, 120, drawX
	beq $a0, 121, drawY
	beq $a0, 122, drawZ
	j exit

#These all load the necessary letter into register $t2 and jump to draw letter
drawA:
	la $t2, a
	j drawLetter
	
drawB:
	la $t2, b
	j drawLetter

drawC:
	la $t2, c
	j drawLetter

drawD:
	la $t2, d
	j drawLetter
	
drawE:
	la $t2, e
	j drawLetter

drawF:
	la $t2, f
	j drawLetter

drawG:
	la $t2, g
	j drawLetter

drawH:
	la $t2, h
	j drawLetter

drawI:
	la $t2, i
	j drawLetter
		
drawJ:
	la $t2, j
	j drawLetter
	
drawK:
	la $t2, k
	j drawLetter
	
drawL:
	la $t2, l
	j drawLetter
	
drawM:
	la $t2, m
	j drawLetter
	
drawN:
	la $t2, n
	j drawLetter
	
drawO:
	la $t2, o
	j drawLetter
	
drawP:
	la $t2, p
	j drawLetter
	
drawQ:
	la $t2, q
	j drawLetter
	
drawR:
	la $t2, r
	j drawLetter
	
drawS:
	la $t2, s
	j drawLetter
	
drawT:
	la $t2, t
	j drawLetter
	
drawU:
	la $t2, u
	j drawLetter
	
drawV:
	la $t2, v
	j drawLetter
	
drawW:
	la $t2, w
	j drawLetter
	
drawX:
	la $t2, x
	j drawLetter
	
drawY:
	la $t2, y
	j drawLetter
	
drawZ:
	la $t2, z
	j drawLetter

#Draws the specified letter	
drawLetter:
	lw $t6, ($t2)		#Load the number of pixels to shift by
	lw $t4, black		#Load the color to draw the letter with (black)
	addi $t2, $t2, 4	#Increment address by 4 to go to the next word
	sll $t6, $t6, 2		#Multiply number of pixels by 4 (word align)
	add $s0, $s0, $t6	#Shift by the necessary number of pixels
	sw $t4, ($s0)		#Set destination pixel to black
	lw $t6, ($t2)		#Load next pixel (damn this is redundant, I should fix this at some point)
	bne $t6, -1, drawLetter	#Loop until -1 is reached signifying the end of the array
	jr $ra			#Return

#Terminates the program
exit:
	li $v0, 10
	syscall		#Syscall to exit
