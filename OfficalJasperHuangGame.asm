# Author:	Jasper Huang, 827900483
# Date:		April 28, 2024
# Description:	Don't fall in the hole game.  Compe 271 Game project


#lines 10-22, 35-100 are from youtube, https://www.youtube.com/watch?v=CdctMQjk3JI
#each pixel is by numbers of 4, next closest to spawn would be 1912
#use 8x8 pixel unit width and height, 256x256 display width and height, base address (static data)

.data
frameBuffer: .space 0x80000
xVal: .word 0
yVal: .word 0
xPos: .word 50
yPos: .word 27
holeX:		.word	32		# hole x position
holeY:		.word	16		# hole y position
spawn: .word 1908		#1908
hole: .word 0x510600
up:	.word 0x00b500d1 
down:	.word 0x01978eeb
left:	.word 0x02978eeb
right:	.word 0x03978eeb
xConversion: .word 16
yConversion: .word 2
Intro: .asciiz "Welcome to Earthquake Simulator.  You are the purple character.  Your goal is to survive as long as possible without falling into a hole. \n  	Use w,a,s,d to move.\n"
Lose: .asciiz "That's unfortunate.  You ran out of space\n"
rounds: .asciiz "You survived a total of "
rounds_end: .asciiz " rounds"
askmove: .asciiz "Move your character using w, a, s, or d to go up, left, down, or right: "
newline: .asciiz "\n"



.text
main:

la $t0, frameBuffer
li $t1, 4096
li $t2, 0x46c639				#green grass

l1:
sw $t2, 0($t0)
addi $t0, $t0, 4
addi $t1, $t1, -1
bnez $t1, l1

la $t0, frameBuffer
addi $t1, $zero, 64
li $t2, 0x3f77f0

drawBorderTop:			#0-124
	sw	$t2, 0($t0)		# color Pixel blue
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -2		# decrease pixel count
	bnez	$t1, drawBorderTop	# repeat unitl pixel count == 0
	
	# Bottom wall section
	la	$t0, frameBuffer	# load frame buffer addres
	addi	$t0, $t0, 3968		# set pixel to be near the bottom left
	addi	$t1, $zero, 255		# t1 = 512 length of row

drawBorderBot:			#3968-4092
	sw	$t2, 0($t0)		# color Pixel blue
	addi	$t0, $t0, 4		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderBot	# repeat unitl pixel count == 0
	
	# left wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t1, $zero, 255		# t1 = 512 length of col

drawBorderLeft:			#starting at 0 add multplies of 128
	sw	$t2, 0($t0)		# color Pixel blue
	addi	$t0, $t0, 128		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderLeft	# repeat unitl pixel count == 0
	
	# Right wall section
	la	$t0, frameBuffer	# load frame buffer address
	addi	$t0, $t0, 252		# make starting pixel top right
	addi	$t1, $zero, 255		# t1 = 512 length of col

drawBorderRight:		#starting at 124 and multplies of 128
	sw	$t2, 0($t0)		# color Pixel blue
	addi	$t0, $t0, 128		# go to next pixel
	addi	$t1, $t1, -1		# decrease pixel count
	bnez	$t1, drawBorderRight	# repeat unitl pixel count == 0
	
	
characterspawn:

	la	$t0, frameBuffer	# load frame buffer address
	lw 	$t5, spawn	
	lw	$t3, up		# t3 = color of character
	
	add	$t1, $t5, $t0		# t1 = start on bit map display
	sw	$t3, 0($t1)		# draw pixel where character is
	
	addiu $sp, $sp, -20	#initializes 5 locations in stack
	sw $t5, 0($sp)		#stores spawn into first stack location
	

	
game:
	li $v0, 4		#prints intro line and directions
        la $a0, Intro
        syscall	
        

	sw $ra, 4($sp)		#stores return address 
character_movement:			
	lw $t1, 0($sp)		#character location written to $t1
	addi $t9, $t9, 1
        sw $t9, 8($sp)		#stores score of game
        
	li $v0, 4		#prints move each direction
        la $a0, askmove
        syscall

        # Read move input from user
        li $v0, 12
        syscall
        move $t8, $v0
        
        #print newline for looks
	li $v0, 4
	la $a0, newline
	syscall

	
	beq $t8, 119, move_up    # If w is pressed (ASCII code for w is 119)
        beq $t8, 97, move_left   # If a is pressed (ASCII code for a is 97)
        beq $t8, 115, move_down  # If s is pressed (ASCII code for s is 115)
        beq $t8, 100, move_right # If d is pressed (ASCII code for d is 100)
        beq $t8, 112 , end_game # If p is pressed (ASCII code for d is 100)

	move_up:			#have not checked if its in water or hole
    	addi $t1, $t1, -128
    	sw $t1, 12($sp)			#stores new location in 3rd stack
    	
    	jal collisions	#check if it hits hole or water before updating character
    	
    	sw $ra, 16($sp)		#stores return address
    	
    	jal update_character	#goes to update_character
    	
	j character_movement		#reruns character_movement

    	move_left:
    	addi $t1, $t1, -4	#same as move_up
    	sw $t1, 12($sp)
    	
    	jal collisions		#check if it hits hole or water before updating character
    	
    	jal update_character	
    	
	j character_movement

    	move_down:		#same as move_up
    	addi $t1, $t1, 128
    	sw $t1, 12($sp)
    	
    	jal collisions		#check if it hits hole or water before updating character
    	
    	jal update_character 	
    	
	j character_movement

    	move_right:		#same as move_up
   	addi $t1, $t1, 4
   	sw $t1, 12($sp)
   	
   	jal collisions		#check if it hits hole or water before updating character
   	
   	jal update_character	
   	
	j character_movement


 update_character:
        lw $t1, 0($sp)		#original needs to be updated green
        lw $t2, 12($sp)		#new needs to be updated purple
        la	$t0, frameBuffer	# load frame buffer address	
	lw	$t3, up		# t3 color of character
	li $t5, 0x46c639	#green
	#update new location
	add	$t4, $t2, $t0		# t1 = tail start on bit map display
	sw	$t3, 0($t4)		# draw pixel where character is
	#update old location
	add	$t4, $t1, $t0		# t1 = tail start on bit map display
	sw	$t5, 0($t4)		# draw pixel where character is
	sw $t2, 0($sp)
	
	j start_hole
end_move:
	jr $ra
            
collisions:			#need a way to check between holes and border
	lw $t1, 12($sp)
	la $t0, frameBuffer
	add $t2, $t0, $t1
	lw $t1, 0($t2)
	li $t3, 0x510600	#brown = 0x510600
	li $t4, 0x3f77f0	#blue = 0x3f77f0
	beq $t1, $t3, end_game		#checks if the new locations is alreayd brown
	beq $t1, $t4, end_game		#checks if the new locations is already blue/the border
	jr $ra
	
start_hole:
#start of random hole generator
	li $t3, 1
	li $t4, 0
generate_new_random_number:
	li $v0, 42          # System call code for random number generator (syscall 42)
    	addi $a1, $zero, 1024        # Set the upper bound (exclusive) for the random number range (0-4092)
    	syscall             # Generate a random number based on the seed and upper bound

    	# Result of random number generation is stored in $v0
    	# Apply filtering logic to get the desired random number
   	move $t0, $a0       # Move the random number to a temporary register for manipulation
	
    	# Check if the random number falls within the specified ranges to exclude
    	# Exclude range 0-124
    	li $t1, 31
    	bgt $t0, $t1, loop_exclude_bottom   # Branch if the number is less than 125 (0-124)
	j generate_new_random_number
    	# Exclude range 3968-4092
 	loop_exclude_bottom:
 	li $t1, 992
    	blt $t0, $t1, loop_exclude_multiples   # Branch if the number is greater than or equal to 3968 (3968-4092)
	j generate_new_random_number
    	# Exclude multiples of 128 starting from 128
	loop_exclude_multiples:
	li $t1, 32
    	div $t0, $t1
    	mfhi $t2
    	beq $t2, $zero, generate_new_random_number   # Branch if the number is equal to the current multiple
    	# Exclude numbers starting from 252, additions of 128
    	addi $t2, $t2, 1
    	beq $t2, $t1, generate_new_random_number   # Branch if the number matches the current addition start

	is_valid_number:
    	# If the number passes all checks, use it as the desired random number
    	sll $t0, $t0, 2
 
    	
    	for_hole:
    	lw $s1, 0($sp)			#makes sure the character is never replaced by hole
    	beq $t0, $s1 , generate_new_random_number
    	
    	j drawhole
    	#addi $sp, $sp, -4
    	#sw $t0, 0($sp)
drawhole:
	#addiu 	$sp, $sp, -4	# allocate 24 bytes for stack
	#sw 	$fp, 0($sp)	# store caller's frame pointer
	#sw 	$ra, 4($sp)	# store caller's return address
	
	#addi $t3, $zero, 0
	#bne $t3, 100, generate_new_random_number
	la	$t4, frameBuffer	# load frame buffer address
	lw	$s3, hole		
	
	add	$t1, $t0, $t4		# t1 = tail start on bit map display
	sw	$s3, 0($t1)		
	addi $t3, $t3, 1  #increase counter
	bne $t3, 30, generate_new_random_number
	j end_move
	
end_game:
    	li $v0, 4		#prints lose line
        la $a0, Lose
        syscall
        li $v0, 4		#prints rounds line
        la $a0, rounds
        syscall
        
        lw $t1, 8($sp)		#prints the stack counter for number of rounds played
        li $v0, 1
        la $a0, ($t1)
        syscall
        
        li $v0, 4
        la $a0, rounds_end
        syscall
        
        li $v0, 10                 # Exit program
        syscall

