################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Jing Yu, 1007758437
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    512
# - Display height in pixels:   256
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
brick_x:		.word 	6,20,34,48,9,25,41,4,19,34,49,11,26,41,5,19,33,47		# set brick location
brick_y:		.word 	4,4,4,4,6,6,6,8,8,8,8,10,10,10,12,12,12,12
##############################################################################
# Mutable Data
##############################################################################
life:			.word	3
ball_x:			.word	32
ball_y:			.word	25
vdirection:		.word	-1
hdirection:		.word	0
paddle_x:		.word	30
paddle_y:		.word	26
paddle2_x:		.word	30
paddle2_y:		.word	29
##############################################################################
# Code
##############################################################################
	.text
	.globl main

	# Run the Brick Breaker game.
main:
	# Initialize the game
    	lw $t0, ADDR_DSPL		# $t0 stores the base address for display
    	li $t4, 0x808080		# $t4 stores colour grey
	jal draw_wall			# call draw_wall function
	# Draw first paddle
	la $t6, paddle_x		# $t6 has the address of paddle_x
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t6, 0($sp)			# push $t6 onto the stack
	la $t7, paddle_y		# $t7 has the address of paddle_y
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t7, 0($sp)			# push $t6 onto the stack
	jal draw_paddle			# call draw_paddle function
	# Draw second paddle
	la $t6, paddle2_x		# $t6 has the address of paddle2_x
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t6, 0($sp)			# push $t6 onto the stack
	la $t7, paddle2_y		# $t7 has the address of paddle2_y
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t7, 0($sp)			# push $t6 onto the stack
	jal draw_paddle			# call draw_paddle function
	
	jal draw_ball			# call draw_ball function
	
	la $t6, brick_x			# $t6 has the address of array brick_x
	la $t7, brick_y			# $t7 has the address of array brick_y
	li $t8, 0x0000ff 		# $t8 stores the colour code
	addi $t5, $t6, 72		# $t5 holds the address after 18 units in array brick_x
	j draw_bricks_loop		# call draw_bricks_loop function

end_brick_loop:
	j game_loop
	
draw_ball:
	lw $t0, ADDR_DSPL		# $t0 stores the base address for display
	# Save any register values we'll need after calling draw_ball ($ra)
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $ra, 0($sp)			# push $ra onto the stack.
	
	la $t6, ball_x			# $t6 has the address of ball_x
	lw $t9, 0($t6)			# Fetch x position of the ball
	sll $t9, $t9, 2			# Multiply $t9 by 4
	add $t0, $t0, $t9		# Add x offset to $t0
	la $t7, ball_y			# $t7 has the address of ball_y
	lw $t9, 0($t7)			# Fetch y position of the ball
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t0, $t0, $t9		# Add y offset to $t0
	
	add $a0, $t0, $zero		# store the drawing location
	addi $a1, $zero, 1		# store the height of the ball in $a1
	addi $a2, $zero, 1		# store the width of the ball in $a2
	li $a3, 0xff0000		# $a3 stores colour red
	
	jal draw_rect			# draw the paddle

	lw $ra, 0($sp)			# Pop $ra from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	jr $ra

draw_paddle:
	lw $t0, ADDR_DSPL		# $t0 stores the base address for display
	lw $t7, 0($sp)			# Pop y location of the paddle from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	lw $t6, 0($sp)			# Pop x location of the paddle from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	
	# Save any register values we'll need after calling draw_paddle ($ra)
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $ra, 0($sp)			# push $ra onto the stack.
	
	lw $t9, 0($t6)			# Fetch x position of the paddle
	sll $t9, $t9, 2			# Multiply $t9 by 4
	add $t0, $t0, $t9		# Add x offset to $t0
	lw $t9, 0($t7)			# Fetch y position of the paddle
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t0, $t0, $t9		# Add y offset to $t0
	
	add $a0, $t0, $zero		# store the drawing location
	addi $a1, $zero, 1		# store the height of the paddle in $a1
	addi $a2, $zero, 5		# store the width of the paddle in $a2
	li $a3, 0xffffff		# $a3 stores colour white
	
	jal draw_rect			# draw the paddle

	lw $ra, 0($sp)			# Pop $ra from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	jr $ra
	
draw_bricks_loop:   # A loop to draw bricks with different colours and initial locations
	lw $t0, ADDR_DSPL 		# $t0 stores the base address for display
	beq $t5, $t6, end_brick_loop	# exit loop when after 18 times
	lw $t9, 0($t6)			# Fetch x position of the brick, $t9 = brick_x[i]
	sll $t9, $t9, 2			# Multiply $t9 by 4
	add $t0, $t0, $t9		# Add x offset to $t0
	lw $t9, 0($t7)			# Fetch y position of the brick, $t9 = brick_y[i]
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t0, $t0, $t9		# Add y offset to $t0
	# Save the drawing location and the colour
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t0, 0($sp)			# Push the drawing location to the stack	
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t8, 0($sp)			# Push the colour to the stack
	
	jal draw_bricks			# call draw_bricks function
	addi $t6, $t6, 4		# Increment the address of x location
	addi $t7, $t7, 4		# Increment the address of y location
	# Change the colour
	addi $t9, $zero, 13
	mult $t8, $t9
	mflo $t8
	j draw_bricks_loop
		
draw_bricks:   # draw three bricks with the same colour
	addi $a1, $zero, 1		# $a1 = height of each brick = 1
	addi $a2, $zero, 3		# $a2 = width of each brick = 3
	lw $a3, 0($sp)			# Pop the colour of bricks from the stack and store in $a3
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	lw $a0, 0($sp)			# Pop the drawing location of bricks from the stack and store in $a0
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	
	# Save any register values we'll need after calling draw_bricks ($ra)
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $ra, 0($sp)			# push $ra onto the stack.
	
	jal draw_rect			# draw the first brick
	addi $a0, $a0, 16		# move the drawing location to one unit to the right of the last brick
	jal draw_rect			# draw the second brick
	addi $a0, $a0, 16		# move the drawing location to one unit to the right of the last brick
	jal draw_rect			# draw the third brick

	lw $ra, 0($sp)			# Pop $ra from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	jr $ra
	
draw_wall:
	# Save any register values we'll need after calling draw_wall ($ra)
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $ra, 0($sp)			# push $ra onto the stack.
	
	add $a0, $t0, $zero		# store the drawing location at the top left corner in $a0
	addi $a1, $zero, 2		# store the height of the top wall in $a1
	addi $a2, $zero, 64		# store the width of the top wall in $a2
	add $a3, $t4, $zero		# store the colour gray in $a3
	jal draw_rect			# draw the top wall
	addi $a1, $zero, 32		# store the height of the left wall in $a1
	addi $a2, $zero, 2		# store the width of the left wall in $a2
	jal draw_rect			# draw the left wall
	addi $a0, $a0, 248		# move the drawing location to the second last column
	jal draw_rect			# draw the right wall

	lw $ra, 0($sp)			# Pop $ra from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	jr $ra

#######################################################
# The rectangle drawing function
# Before adding stack code, this took in the following:
# - $a0 : Starting location for drawing the rectangle
# - $a1 : The height of the rectangle
# - $a2 : The width of the rectangle
# - #a3 : The colour of the rectangle
#######################################################
draw_rect:
	add $t0, $zero, $a0		# Put drawing location into $t0
	add $t1, $zero, $a1		# Put the height into $t1
	add $t2, $zero, $a2		# Put the width into $t2
	add $t3, $zero, $a3		# Put the colour into $t3

outer_loop:
	beq $t1, $zero, end_outer_loop	# if the height variable is zero, then jump to the end.

# draw a line
inner_loop:
	beq $t2, $zero, end_inner_loop	# if the width variable is zero, jump to the end of the inner loop
	sw $t3, 0($t0)			# draw a pixel at the current location.
	addi $t0, $t0, 4		# move the current drawing location to the right
	addi $t2, $t2, -1		# decrement the width variable
	j inner_loop			# repeat the inner loop

end_inner_loop:

	addi $t1, $t1, -1		# decrement the height variable
	add $t2, $zero, $a2		# reset the width variable to $a1
	addi $t0, $t0, 256		# move $t0 to the next line
	sll $t4, $t2, 2			# multiply the width by 4 to convert $t2 to bytes
	sub $t0, $t0, $t4		# move $t0 to the first pixel to draw in this line
	j outer_loop			# jump to the beginning of the outer loop

end_outer_loop:			# the end of the rectangle drawing
	jr $ra			# return to the calling program

###########################################################################
game_loop:	
	# initialize some addresses
	lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    	lw $t1, ADDR_DSPL		# $t1 = the base address for display
	li $v0, 32			# Sleep
	li $a0, 100
	syscall
	
# 1. Check for keyboard input
    	lw $t8, 0($t0)                  # Load first word from keyboard
    	beq $t8, 1, keyboard_input      # Check if key has been pressed. If first word 1, key is pressed
	b check_collision		# No keyboard input, jump to check collision 

	# Check which key has been pressed
keyboard_input:                     	
    	lw $a0, 4($t0)                  # Load second word from keyboard
    	beq $a0, 0x71, respond_to_Q     # Check if the key q was pressed
	beq $a0, 0x61, move_left	# Check if the key a was pressed
	beq $a0, 0x64, move_right       # Check if the key d was pressed
	beq $a0, 0x6A, move_left2	# Check if the key j was pressed
	beq $a0, 0x6C, move_right2      # Check if the key l was pressed
	beq $a0, 0x70, pause	        # Check if the key p was pressed
	beq $a0, 0x72, reset	        # Check if the key r was pressed
	b check_collision		# No valid key pressed, jump to check collision

	# Update the paddle
move_right2:
	# $t2 = the paddle address
    	la $t6, paddle2_x		# $t6 has the address of paddle_x
	lw $t8, 0($t6)			# Fetch x position of the paddle
	add $t9, $zero, 57		# The right bound of the paddle
	beq $t8, $t9, check_collision   # Check if the paddle already reached the right bound. If so, do nothing.
	addi $t8, $t8, 1		# If not, update the location of the paddle
	sw $t8, 0($t6)
	sll $t8, $t8, 2			# Multiply $t8 by 4
	la $t7, paddle2_y		# $t7 has the address of paddle_y
	lw $t9, 0($t7)			# Fetch y position of the paddle
	sll $t9, $t9, 8 		# Multiply $t9 by 256
	add $t2, $t1, $t8		# Add x offset to $t2
	add $t2, $t2, $t9		# Add y offset to $t2
	li $t8, 0xffffff		# $t8 stores colour white
	li $t9, 0x000000		# $t9 stores colour black
	sw $t9, -4($t2)			# Change the colour of the first unit of the paddle to be black
	sw $t8, 16($t2)			# Change the colour of the last unit of the paddle to be white
	b check_collision		# Jump to check collision

move_left2:
	# $t2 = the paddle address
    	la $t6, paddle2_x		# $t6 has the address of paddle_x
	lw $t8, 0($t6)			# Fetch x position of the paddle
	add $t9, $zero, 2		# The left bound of the paddle
	beq $t8, $t9, check_collision   # Check if the paddle already reached the left bound. If so, do nothing.
	addi $t8, $t8, -1		# If not, update the location of the paddle
	sw $t8, 0($t6)
	sll $t8, $t8, 2			# Multiply $t8 by 4
	la $t7, paddle2_y		# $t7 has the address of paddle_y
	lw $t9, 0($t7)			# Fetch y position of the paddle
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t2, $t1, $t8		# Add x offset to $t2
	add $t2, $t2, $t9		# Add y offset to $t2
	li $t8, 0xffffff		# $t8 stores colour white
	li $t9, 0x000000		# $t9 stores colour black
	sw $t8, 0($t2)			# Change the colour of the first unit of the paddle to be white
	sw $t9, 20($t2)			# Change the colour of the last unit of the paddle to be black
	b check_collision		# Jump to check collision

move_right:
	# $t2 = the paddle address
    	la $t6, paddle_x		# $t6 has the address of paddle_x
	lw $t8, 0($t6)			# Fetch x position of the paddle
	add $t9, $zero, 57		# The right bound of the paddle
	beq $t8, $t9, check_collision   # Check if the paddle already reached the right bound. If so, do nothing.
	addi $t8, $t8, 1		# If not, update the location of the paddle
	sw $t8, 0($t6)
	sll $t8, $t8, 2			# Multiply $t8 by 4
	la $t7, paddle_y		# $t7 has the address of paddle_y
	lw $t9, 0($t7)			# Fetch y position of the paddle
	sll $t9, $t9, 8 		# Multiply $t9 by 256
	add $t2, $t1, $t8		# Add x offset to $t2
	add $t2, $t2, $t9		# Add y offset to $t2
	li $t8, 0xffffff		# $t8 stores colour white
	li $t9, 0x000000		# $t9 stores colour black
	sw $t9, -4($t2)			# Change the colour of the first unit of the paddle to be black
	sw $t8, 16($t2)			# Change the colour of the last unit of the paddle to be white
	b check_collision		# Jump to check collision

move_left:
	# $t2 = the paddle address
    	la $t6, paddle_x		# $t6 has the address of paddle_x
	lw $t8, 0($t6)			# Fetch x position of the paddle
	add $t9, $zero, 2		# The left bound of the paddle
	beq $t8, $t9, check_collision   # Check if the paddle already reached the left bound. If so, do nothing.
	addi $t8, $t8, -1		# If not, update the location of the paddle
	sw $t8, 0($t6)
	sll $t8, $t8, 2			# Multiply $t8 by 4
	la $t7, paddle_y		# $t7 has the address of paddle_y
	lw $t9, 0($t7)			# Fetch y position of the paddle
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t2, $t1, $t8		# Add x offset to $t2
	add $t2, $t2, $t9		# Add y offset to $t2
	li $t8, 0xffffff		# $t8 stores colour white
	li $t9, 0x000000		# $t9 stores colour black
	sw $t8, 0($t2)			# Change the colour of the first unit of the paddle to be white
	sw $t9, 20($t2)			# Change the colour of the last unit of the paddle to be black
	b check_collision		# Jump to check collision

# 2. Check for collision events
#######################################
# $t2 = the origial ball address
# $t3 = the new ball address
#######################################
check_collision:
	# Find current address of the ball
	la $t6, ball_x			# $t6 has the address of ball_x
	lw $t8, 0($t6)			# Fetch x position of the ball
	sll $t8, $t8, 2			# Multiply $t8 by 4
	la $t7, ball_y			# $t7 has the address of ball_y
	lw $t9, 0($t7)			# Fetch y position of the ball
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t2, $t1, $t8		# Add x offset to $t2
	add $t2, $t2, $t9		# Add y offset to $t2
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t2, 0($sp)			# Push the original position of the ball to the stack
	# Find next address of the ball
	la $t4, hdirection		# $t4 has the address of horizontal direction
	lw $t8, 0($t4)			# Fetch horizontal direction of movement
	addi $t9, $zero, 4		# Figure out the position movement in horizontal direction
	mult $t8, $t9
	mflo $t8			# get the result of multipication
	add $t3, $t8, $t2		# update the position for the vertical movement
	la $t5, vdirection		# $t5 has the address of vertical direction
	lw $t8, 0($t5)			# Fetch vertical direction of movement
	addi $t9, $zero, 256		# Figure out the position movement in vertical direction
	mult $t8, $t9
	mflo $t8			# get the result of multipication
	add $t3, $t8, $t3		# update the position for the horizontal movement
	# check if the next position of the ball doesn't hit anything
	li $t4, 0x000000		# $t4 stores colour black
	lw $t5, 0($t3)			# load the colour at $t3
	beq $t4, $t5, update_ball	# If no collision occurs, update the position of the ball
	# If collision occurs, check which side the ball hits, then update direction.
	lw $t5, 4($t3)			# load the colour at 4($t3)
	beq $t4, $t5, hit_right_side	# check if the ball hits the right side
	lw $t5, -4($t3)			# load the colour at -4($t3)
	beq $t4, $t5, hit_left_side	# check if the ball hits the left side
	# Check special case when hitting the paddle
	li $t4, 0xffffff		# $t4 stores colour white
	lw $t5, 0($t3)			# load the colour at -8($t3)
	beq $t4, $t5, check_spec_paddle # Check if the ball hits the paddle
	# Otherwise, do regular collision: horizontal direction changes to 0 and change vertical direction
	la $t8, hdirection		# $t8 has the address of horizontal direction
	add $t9, $zero, $zero		# set to be zero
	sw $t9, 0($t8)			# Store new hdirection
	j change_vdirection
	
check_spec_paddle:
	li $t4, 0x000000		# $t4 stores colour black
	lw $t5, -8($t3)			# load the colour at 8($t3)	
	beq $t4, $t5, hit_left_2  	# Check if the ball hits the second unit of the paddle
	lw $t5, 8($t3)			# load the colour at 8($t3)
	beq $t4, $t5, hit_right_2 	# Check if the ball hits the second last unit of the paddle
	# Otherwise, do regular collision: horizontal direction changes to 0 and change vertical direction
	la $t8, hdirection		# $t8 has the address of horizontal direction
	add $t9, $zero, $zero		# set to be zero
	sw $t9, 0($t8)			# Store new hdirection
	j change_vdirection
	
hit_left_2:	# Change direction to be (-1,2) or (-1,-2)
	la $t8, hdirection		# $t8 has the address of horizontal direction
	lw $t9, 0($t8)			# Fetch horizontal direction of movement
	addi $t9, $zero, -1		# change direction to move to left
	sw $t9, 0($t8)			# Store new hdirection
	la $t8, vdirection		# $t8 has the address of vertical direction
	lw $t9, 0($t8)			# Fetch vertical direction of movement
	slt $t6, $zero, $t9  		# set $t6 to 1 if the number is negative, 0 otherwise
    	slt $t7, $t9, $zero  		# set $t6 to 1 if the number is positive, 0 otherwise
    	sub $t9, $t7, $t6  		# subtract $t6 from $t7 to get 1 if negative, -1 if positive, 0 if 0
	sll $t9, $t9, 1			# multiply $t9 by 2
	sw $t9, 0($t8)			# Store new vdirection
	j update_ball			# next step
	
hit_right_2:	# Change direction to be (1,2) or (1,-2)
	la $t8, hdirection		# $t8 has the address of horizontal direction
	lw $t9, 0($t8)			# Fetch horizontal direction of movement
	addi $t9, $zero, 1		# change direction to move to right
	sw $t9, 0($t8)			# Store new hdirection
	la $t8, vdirection		# $t8 has the address of vertical direction
	lw $t9, 0($t8)			# Fetch vertical direction of movement
	slt $t6, $zero, $t9  		# set $t6 to 1 if the number is negative, 0 otherwise
    	slt $t7, $t9, $zero  		# set $t6 to 1 if the number is positive, 0 otherwise
    	sub $t9, $t7, $t6  		# subtract $t6 from $t7 to get 1 if negative, -1 if positive, 0 if 0
	sll $t9, $t9, 1			# multiply $t9 by 2
	sw $t9, 0($t8)			# Store new vdirection
	j update_ball			# next step
	
change_vdirection:    # update the vdirection
	la $t8, vdirection		# $t8 has the address of vertical direction
	lw $t9, 0($t8)			# Fetch vertical direction of movement
	slt $t6, $zero, $t9  		# set $t6 to 1 if the number is negative, 0 otherwise
    	slt $t7, $t9, $zero  		# set $t6 to 1 if the number is positive, 0 otherwise
    	sub $t9, $t7, $t6  		# subtract $t6 from $t7 to get 1 if negative, -1 if positive, 0 if 0
	sw $t9, 0($t8)			# Store new vdirection
	
	li $t4, 0xffffff		# $t4 stores colour white
	lw $t5, 0($t3)			# load the colour at $t3
	beq $t4, $t5, update_ball	# Hit the paddle, update position of the ball
	li $t4, 0x808080		# $t4 stores colour gray
	lw $t5, 0($t3)			# load the colour at $t3
	beq $t4, $t5, update_ball	# Hit the top wall, update position of the ball
	
	# Hit a brick, brick broken
	j redraw_brick
	
hit_right_side:		# set horizontal direction to be 1
	la $t8, hdirection		# $t8 has the address of horizontal direction
	lw $t9, 0($t8)			# Fetch horizontal direction of movement
	addi $t9, $zero, 1		# change direction to move to right
	sw $t9, 0($t8)			# Store new hdirection
	# If it hit to side walls, already changed direction, so just update location of ball
	li $t4, 0x808080		# $t4 stores colour gray
	lw $t5, 0($t3)			# load the colour at $t3
	beq $t4, $t5, update_ball	# Hit a wall, update position of the ball
	j change_vdirection
	
hit_left_side:		# set horizontal direction to be -1
	la $t8, hdirection		# $t8 has the address of horizontal direction
	lw $t9, 0($t8)			# Fetch horizontal direction of movement
	addi $t9, $zero, -1		# change direction to move to left
	sw $t9, 0($t8)			# Store new hdirection
	# If it hit to side walls, already changed direction, so just update location of ball
	li $t4, 0x808080		# $t4 stores colour gray
	lw $t5, 0($t3)			# load the colour at $t3
	beq $t4, $t5, update_ball	# Hit a wall, update position of the ball
	j change_vdirection

	# 3. Update locations and redraw
update_ball:
	lw $t2, 0($sp)			# Pop the original location of the ball from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack

	# update the new location
	la $t6, ball_x			# $t6 has the address of ball_x
	lw $t8, 0($t6)			# Fetch x position of the ball
	la $t7, hdirection		# $t7 has the address of horizontal direction
	lw $t5, 0($t7)			# Fetch horizontal direction of movement
	add $t8, $t8, $t5		# Compute the new x position of the ball
	sw $t8, 0($t6)			# Store new location of ball_x
	
	la $t6, ball_y			# $t6 has the address of ball_y
	lw $t9, 0($t6)			# Fetch y position of the ball
	la $t7, vdirection		# $t7 has the address of vertical direction
	lw $t5, 0($t7)			# Fetch vertical direction of movement
	add $t9, $t5, $t9		# Compute the new y position of the ball
	sw $t9, 0($t6)			# Store new location of ball_y
	addi $sp, $sp, -4		# move $sp to the next available location.
	sw $t9, 0($sp)			# push $t9 onto the stack.
	# Redraw
	sll $t8, $t8, 2			# Multiply $t8 by 4
	sll $t9, $t9, 8			# Multiply $t9 by 256
	add $t3, $t1, $t8		# Add x offset to $t3
	add $t3, $t3, $t9		# Add y offset to $t3
	li $t8, 0xff0000		# Store colour red into $t3
	li $t9, 0x000000		# $t9 stores colour black
	sw $t8, 0($t3)			# Colour the new position of the ball red
	sw $t9, 0($t2)			# Colour the old position of the ball black
	
	lw $t8, 0($sp)			# Pop $t9 from the stack
	addi $sp, $sp, 4		# Move $sp to the top of the stack
	addi $t6, $zero, 33		# Check whether the ball is out of screen
	beq $t8, $t6, check_game_over	# If out of screen, check game over
	j sleep
	
check_game_over:	# Check whether game over or not
	sw $t9, 0($t3)			# Colour the new position of the ball black
	la $t6, life			# $t8 has the address of life
	lw $t7, 0($t6)			# $t7 is the number of life left
	addi $t7, $t7, -1		# decrement by 1
	beqz $t7, game_over		# no life left, game over
	sw $t7, 0($t6)			# store $t7 in life
	# Reset
	la $t7, ball_x			# $t7 has the address of ball_x
	addi $t6, $zero, 32		# Reset ball_x
	sw $t6, 0($t7)
	la $t7, ball_y			# $t7 has the address of ball_y
	addi $t6, $zero, 25		# Reset ball_y
	sw $t6, 0($t7)
	la $t7, vdirection		# $t7 has the address of vdirection
	addi $t6, $zero, -1		# Reset vdirection
	sw $t6, 0($t7)
	la $t7, hdirection		# $t7 has the address of hdirection
	addi $t6, $zero, 0		# Reset hdirection
	sw $t6, 0($t7)
	j sleep

# Redraw the brick
redraw_brick: 
	lw $t6, 0($t3)			# load the colour at 0($t3)
	srl $t6, $t6, 8			# logically Shift to right by 4 bits
	li $t4, 0x000000		# $t4 stores colour black
	lw $t5, 4($t3)			# load the colour at 4($t3)
	beq $t4, $t5, right_side	# hit the right side
	lw $t5, -4($t3)			# load the colour at -4($t3)
	beq $t4, $t5, left_side		# hit the left side
	sw $t6, 0($t3)			# Otherwise
	sw $t6, 4($t3)
	sw $t6, -4($t3)
	b check_collision
	
right_side: 
	sw $t6, 0($t3)
	sw $t6, -4($t3)
	sw $t6, -8($t3)
	b check_collision
	
left_side: 
	sw $t6, 0($t3)
	sw $t6, 4($t3)
	sw $t6, 8($t3)
	b check_collision

	# 4. Sleep
sleep:
	li $v0, 32
	li $a0, 10
	syscall
	
	# 5. Back to step 1
	b game_loop
	
respond_to_Q:
	li $v0, 10                      # Quit gracefully
	syscall

pause: 
	li $v0, 32			# Sleep for 10 seconds
	li $a0, 10000
	syscall
	b game_loop
	
reset:
	li $t2, 0x000000		# colour black
	lw $t0, ADDR_DSPL		# base address
	addi $t1, $zero, 2048		# end of screen

loop:	sw $t2, 0($t0)			# colour black
	addi $t0, $t0, 4		# set location to next pixel
	addi $t1, $t1, -1		# decrement by 1
	bne $t1, $zero, loop		# not end, continue looping
	
	la $t7, ball_x			# $t7 has the address of ball_x
	addi $t6, $zero, 32		# Reset ball_x
	sw $t6, 0($t7)
	la $t7, ball_y			# $t7 has the address of ball_y
	addi $t6, $zero, 25		# Reset ball_y
	sw $t6, 0($t7)
	la $t7, paddle_x		# $t7 has the address of paddle_x
	addi $t6, $zero, 30		# Reset paddle_x
	sw $t6, 0($t7)
	la $t7, paddle_y		# $t7 has the address of paddle_y
	addi $t6, $zero, 26		# Reset paddle_y
	sw $t6, 0($t7)
	la $t7, paddle2_x		# $t7 has the address of paddle2_x
	addi $t6, $zero, 30		# Reset paddle2_x
	sw $t6, 0($t7)
	la $t7, paddle2_y		# $t7 has the address of paddle2_y
	addi $t6, $zero, 29		# Reset paddle2_y
	sw $t6, 0($t7)
	la $t7, vdirection		# $t7 has the address of vdirection
	addi $t6, $zero, -1		# Reset vdirection
	sw $t6, 0($t7)
	la $t7, hdirection		# $t7 has the address of hdirection
	addi $t6, $zero, 0		# Reset hdirection
	sw $t6, 0($t7)
	la $t7, life			# $t7 has the address of life
	addi $t6, $zero, 3		# Reset life
	sw $t6, 0($t7)
	j main
	
game_over:
	li $v0, 10
	syscall
