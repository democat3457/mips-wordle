# Dictionary module
# Handles dictionary loading, caching, and indexing.

# Methods:
# - getWordList
#   Takes no arguments.
#   Returns word list address in $v0, word list size in $v1.
# - getWordAtIndex
#   Takes an index between 0 and wordListSize-1, inclusive, in $a0.
#   Returns word address in $v0.
# - getDictionarySize
#   Takes no arguments.
#   Returns word list size in $v0.

.data
WORD_LENGTH:	.word 5		# Length of word
wordByteSize:	.word 6		# Size of word to read in bytes: set to length + 1 (null terminator)
FILENAME:		.asciiz "dictionary.txt"					# Name of the input file
msgErrOpenFile:	.asciiz "Could not open dictionary file"	# Message if opening file gives error
msgErrReadFile:	.asciiz "Encountered error when reading dictionary"	# Message if reading file gives error

wordListPtr:	.word 0		# Address of beginning of word list array
wordListSize:	.word -1	# Word list size

.text
getWordList:
	lw $v0, wordListPtr
	lw $v1, wordListSize
	beqz $v0, loadWordList	# if wordListPtr is unset, load word list
	jr $ra
loadWordList:
	addi $sp, $sp, -4		# put $ra onto stack
	sw $ra, 0($sp)
	jal getDictionarySize
	move $t1, $v0			# put word list size in $t1
	jal openValidDictionaryFile
	move $t0, $v0			# load file descriptor into $t0
	li $t2, 0				# index into word list
	lw $ra, 0($sp)
	addi $sp, $sp, 4		# load $ra from stack
	
	lw $t8, wordByteSize	# load word byte size into $t8
	
	# Allocate heap memory for storing the word list
	li $v0, 9				# initialize buffer of wordByteSize * dictionarySize
	lw $a0, wordByteSize
	mul $a0, $a0, $t1
	syscall
	sw $v0, wordListPtr
populateFromFile:
	# Read WORD_LENGTH+1 bytes from the file
	mul $t6, $t2, $t8		# multiply index by word byte size and store into $t6
	
	li $v0, 14				# syscall code for read
	move $a0, $t0			# file descriptor
	lw $a1, wordListPtr		# word list array start
	add $a1, $a1, $t6		# add multiplied index to array start
	move $t5, $a1			# copy word start to temp register to re-assign null terminator in place of new line
	move $a2, $t8			# read number of word bytes
	syscall
	move $t7, $v0			# $t7 contains number of characters read
	
	bne $t7, $t8, exitPopulateLoop
	# if number of read characters is expected
	addi $t2, $t2, 1		# increment index by 1
	add $t5, $t5, $t8
	addi $t5, $t5, -1
	sb $zero, ($t5)	# replace new line with null terminator at the end of the word
	j populateFromFile
exitPopulateLoop:
	li $v0, 16				# syscall code for close file
	move $a0, $t0			# file descriptor
	syscall
	
	blt $t7, $zero, errorPopulatingFile
	# if number of read characters is 0 (end-of-file)
	#   or between 0 and expected (ignore extra characters)
	lw $v0, wordListPtr		# return word list array start
	lw $v1, wordListSize	# return word list size
	jr $ra
errorPopulatingFile:
	# if number of read characters is negative (error)
	li $v0, 4				# print error message
	la $a0, msgErrReadFile
	syscall
	
	li $v0, 17				# exit with error
	li $a0, 1				# error code non-zero
	syscall


getWordAtIndex:
	addi $sp, $sp, -8		# store $ra and $a0 on stack
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	jal getWordList			# get word list array start
	move $t0, $v0
	move $t1, $v1
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8		# load $ra and $a0 from the stack
	
	tlt $a0, $zero			# check if index is at least zero
	tge $a0, $t1			# check if index is less than word list length
	
	lw $t9, wordByteSize
	mul $a0, $a0, $t9		# mutliply index by word byte size
	add $t0, $t0, $a0		# add multiplied index to word array start
	move $v0, $t0			# return address of word in array at index
	jr $ra


getDictionarySize:
	lw $v0, wordListSize
	beq $v0, -1, loadDictionarySize	# if wordListPtr is unset, load word list
	jr $ra
loadDictionarySize:
	addi $sp, $sp, -4		# store $ra on stack
	sw $ra, 0($sp)
	jal openValidDictionaryFile
	move $t0, $v0			# load file descriptor into $t0
	li $t1, 0				# initialize word count
	lw $ra, 0($sp)
	addi $sp, $sp, 4		# load $ra from stack
	
	lw $t8, wordByteSize	# load word byte size into $t8
	
	# Allocate heap memory for storing temporary words
	li $v0, 9				# initialize buffer of WORD_LENGTH + 1
	move $a0, $t8
	syscall
	move $t9, $v0			# store address to buffer in $t9
readFromFile:
	# Read WORD_LENGTH+1 bytes from the file
	li $v0, 14				# syscall code for read
	move $a0, $t0			# file descriptor
	move $a1, $t9			# buffer to read into
	lw $a2, wordByteSize
	syscall
	move $t7, $v0			# $t7 contains number of characters read
	
	bne $t7, $t8, exitReadLoop
	# if number of read characters is expected
	addi $t1, $t1, 1		# increment word count by 1
	j readFromFile
exitReadLoop:
	li $v0, 16				# syscall code for close file
	move $a0, $t0			# file descriptor
	syscall
	
	blt $t7, $zero, errorReadingFile
	# if number of read characters is 0 (end-of-file)
	#   or between 0 and expected (ignore extra characters)
	sw $t1, wordListSize
	move $v0, $t1			# return word count
	jr $ra
errorReadingFile:
	# if number of read characters is negative (error)
	li $v0, 4				# print error message
	la $a0, msgErrReadFile
	syscall
	
	li $v0, 17				# exit with error
	li $a0, 1				# error code non-zero
	syscall
	

openValidDictionaryFile:
	# Open the file
	li $v0, 13				# syscall code for open
	la $a0, FILENAME		# load filename into $a0
	li $a1, 0				# flag for read
	li $a2, 0				# mode for read (ignored)
	syscall
	
	beq $v0, -1, errorOpeningFile	# if file descriptor is -1, error happened
	jr $ra					# return with $v0 containing valid file descriptor
errorOpeningFile:
	li $v0, 4				# print error message
	la $a0, msgErrOpenFile
	syscall
	
	li $v0, 17				# exit with error
	li $a0, 1				# error code non-zero
	syscall
