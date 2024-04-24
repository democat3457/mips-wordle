.data
buffer:     .space  6       # Buffer to store the word (including null terminator)
filename:   .asciiz "dictionary.txt"   # Name of the input file

.text
main:
    

    # Open the file
    li $v0, 13          # syscall code for open
    la $a0, filename    # load filename into $a0
    li $a1, 0           # flag for read
    li $a2, 0           # mode for read
    syscall
    
    move $s0, $v0       # save file descriptor
    

    
    # Load the minimum and maximum values from memory
    li $t0, 1              # Set min of range to 1
    li $a0, 0		   # Set seed to default
    li $a1, 14855          # Set maximum value
    li $v0, 42             # syscall 42: get random val
    syscall
    
    add $t1, $a0, $t0      # Set min range

    
ReadToCorrectWord:
    # Read from the file
    li $v0, 14          # syscall code for read
    move $a0, $s0       # file descriptor
    la $a1, buffer      # buffer to read into
    li $a2, 6           # number of bytes to read (5 characters + null terminator)
    syscall
    
     # Print the word
    li $v0, 4           # syscall code for print_string
    la $a0, buffer      # buffer containing the word
    syscall
    
    # for loop ReadCorrectWord
    sub $t1, $t1, 1
    bne $t1, 0, ReadToCorrectWord
    
   
 
    
    # Close the file
    li $v0, 16          # syscall code for close
    move $a0, $s0       # file descriptor
    syscall
    
    # Exit
    li $v0, 10          # syscall code for exit
    syscall
