#	The MIT License (MIT)
#
#	Copyright (c) 2014 Samuel Babalola
#
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#	THE SOFTWARE.
#
#
# Author:		Samuel Babalola
# Contributors:	P. White, W. Carithers, K. Reek
#
# Description: 	This program solves a skyscraper puzzle.
#
# Revisions:	$Log$


# CONSTANTS
#
# syscall codes
PRINT_INT = 	1
PRINT_STRING = 	4
READ_INT = 	5
EXIT = 		10


	.data
west_array:
	.word 	4,2,3,1
east_array:
	.word 	1,2,2,2
south_array:
	.word 	1,3,2,2
north_array:
	.word 	3,2,2,1
test_array:
	.word	north_array, east_array, south_array, west_array
board_array:
	.word 	0
list_1d_row_col_val:
	.word	0, 0
views:
	.word	0, 0, 0, 0
row_or_col:
	.word	1, 3, 4, 2, 4, 0, 0, 0
board:
	.word	1,2,3,4,3,4,1,2,2,3,4,1,0,0,0,0
#
# Memory for allocating up to 6400 words.
#
next:
	.word	pool
pool:
	.space	25600	# room for the "dynamic" memory allocation
pool_end:		# a marker for the end of the free space
	.word	0

	.align 	0

star:
	.asciiz		"*"
newline:
	.asciiz 	"\n"
plus:
	.asciiz 	"+"
dash:
	.asciiz 	"-"
vertical:
	.asciiz 	"|"
space:
	.asciiz		" "
skyscraper_text:
	.asciiz 	"**     SKYSCRAPERS     **\n"

illegal_board_text:
	.asciiz 	"Invalid board size, Skyscrapers terminating\n"

illegal_input_text:
	.asciiz 	"Illegal input value, Skyscrapers terminating\n"

illegal_num_fValue_text:
	.asciiz 	"Invalid number of fixed values, Skyscrapers terminating\n"

illegal_fValue_text:
	.asciiz 	"Illegal fixed input values, Skyscrapers terminating\n"

impossible_text:
	.asciiz		"Impossible Puzzle"

new_error:
	.asciiz		"Out of memory during memory allocating.\n"

init_puzzle_text:
	.asciiz		"Initial puzzle \n"

final_puzzle_text:
	.asciiz		"Final puzzle \n"


	.text					# this is program code
	#printing constant
	.align	2				# instructions must be on word boundaries
	.globl	main			# main is a global label

main:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)	# west array
    sw      $s4, 16($sp)	# south array
    sw      $s3, 12($sp)	# east array
    sw      $s2, 8($sp)		# north array
    sw      $s1, 4($sp)		# board array
    sw      $s0, 0($sp)		# board size


	#print welcome message
	la 		$a0, star
	li 		$a1, 25
	jal 	print_multiple
	jal 	make_newline

	la 		$a0, skyscraper_text
	jal 	print_text

	la 		$a0, star
	li 		$a1, 25
	jal 	print_multiple

	#end welcome message

	jal 	make_newline
	jal 	make_newline

	#Read board size
	jal		read_integer

	move	$s0, $v0

	#check if number is between 3 and 8 inclusively
	li		$a0, 3
	li		$a1, 8
	move	$a2, $s0

	jal		closed_interval

	beq		$v0, $zero, invalid_board

	la		$s2, views
valid_board:
	#make board array
	mult	$s0, $s0
	mflo	$t1

	move 	$a0, $t1
	jal 	allocate_mem
	la 		$s1, board_array
	sw 		$v0, 0($s1)

	#the board array
	move 	$s1, $v0

	#make north array
	move 	$a0, $s0
	jal 	allocate_mem
	sw 		$v0, 0($s2)

	#input into north array
	move 	$a0, $v0
	move	$a1, $s0

	jal		read_integer_toArray

	#make east array
	move 	$a0, $s0
	jal 	allocate_mem
	sw 		$v0, 4($s2)

	#input into east array
	move 	$a0, $v0
	move	$a1, $s0

	jal		read_integer_toArray

	#make south array
	move 	$a0, $s0
	jal 	allocate_mem
	sw 		$v0, 8($s2)

	#input into south array
	move 	$a0, $v0
	move	$a1, $s0

	jal		read_integer_toArray

	#make west array
	move 	$a0, $s0
	jal 	allocate_mem
	sw 		$v0, 12($s2)

	#input into west array
	move 	$a0, $v0
	move	$a1, $s0

	jal		read_integer_toArray

	#number of fixed value
	jal		read_integer

	move	$s3, $v0
	mult	$s0, $s0
	mflo	$a1

	li		$a0, 0
	move	$a2, $s3

	jal 	closed_interval

	beq		$v0, $zero, fixed_value_error

	move 	$a0, $s1
	move	$a1, $s0
	move	$a2, $s3

	jal		read_fixed_input_value

	la 		$a0, init_puzzle_text
	jal 	print_text

	jal		make_newline

	move	$a0, $s1
	move	$a1, $s0
	move	$a2, $s2
	jal		print_board

	jal 	make_newline

	move	$a0, $s1
	move	$a1, $s0
	li		$a2, 0
	move	$a3, $s2
	jal 	solve

	la		$a0, impossible_text
	jal		print_text
	jal 	make_newline
	j 		main_done

fixed_value_error:
	la 		$a0, illegal_num_fValue_text
	jal 	print_text
	j		main_done

invalid_board:
	la 		$a0, illegal_board_text
	jal 	print_text
	j		main_done
#
# All done -- exit the program!
#
main_done:
  	lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name: read_fixed_input_value
#
# Description:	Reads integer into specified array
#
# Arguments:	a0	the board
#				a1	size of array
#				a2	number of input
#
# Returns:		none
#
read_fixed_input_value:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2

	la		$s3, list_1d_row_col_val
read_fixed_input_value_loop:
	beq		$s2, $zero, read_fixed_input_value_done
	#row
	jal		read_integer
	sw		$v0, 0($s3)

	li		$a0, 0
	move	$a1, $s1
	addi	$a1, $a1, -1
	lw		$a2, 0($s3)

	jal		closed_interval

	beq		$v0, $zero, read_fixed_input_value_error

	#column
	jal		read_integer
	sw		$v0, 4($s3)

	li		$a0, 0
	move	$a1, $s1
	addi	$a1, $a1, -1
	lw		$a2, 4($s3)

	jal		closed_interval

	beq		$v0, $zero, read_fixed_input_value_error

	#convert to 1d
	lw		$a0, 0($s3)
	lw		$a1, 4($s3)
	move	$a2, $s1

	jal		twod_to_1d

	sw		$v0, 0($s3)

	#value
	jal		read_integer
	sw		$v0, 4($s3)

	li		$a0, 1
	move	$a1, $s1
	lw		$a2, 4($s3)

	jal		closed_interval

	beq		$v0, $zero, read_fixed_input_value_error

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s3
	jal 	insert_into_board

	addi	$s2, $s2, -1
	j 		read_fixed_input_value_loop

read_fixed_input_value_error:
	la 		$a0, illegal_fValue_text
	jal 	print_text
	j		main_done

read_fixed_input_value_done:

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name: 		insert_into_board
#
# Description:	Reads integer into specified array
#
# Arguments:	a0	the board array
#				a1	size of array
#				a2	array containing [1d location, value]
#
# Returns:		none
insert_into_board:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)	 # size of array
    sw      $s0, 0($sp)	 # array

	move	$s0, $a0
	move	$s1, $a1
	lw		$s2, 0($a2)
	lw		$s3, 4($a2)

	li		$t0, 4
	mult	$s2, $t0
	mflo	$s5

	add		$t1, $s0, $s5
	sw		$s3, 0($t1)

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra


#
# Name: Read Integer into array
#
# Description:	Reads integer into specified array
#
# Arguments:	a0	the array
#				a1	size of array
#
# Returns:		none
#
read_integer_toArray:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)	 # size of array
    sw      $s0, 0($sp)	 # array

    move	$s0, $a0
    move	$s1, $a1
    li 		$s2, 0

 read_integer_toArray_loop:
 	beq		$s2, $s1, read_integer_toArray_loopDone

	jal		read_integer

	sw		$v0, 0($s0)

	#check if number is between 0 and n inclusively
	li		$a0, 0
	move	$a1, $s1
	lw		$a2, 0($s0)

	jal		closed_interval

	beq		$v0, $zero, read_integer_toArray_error

	addi	$s2, $s2, 1
	addi 	$s0, $s0, 4
 	j 		read_integer_toArray_loop

read_integer_toArray_error:
	la 		$a0, illegal_input_text
	jal 	print_text
	li 		$v0, EXIT		# terminate program
	syscall

read_integer_toArray_loopDone:

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name: Print Integer from array
#
# Description:	Reads integer into specified array
#
# Arguments:	a0	the array
#				a1	size of array
#
# Returns:		none
#
print_integer_fromArray:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)	 # size of array
    sw      $s0, 0($sp)	 # array

    move	$s0, $a0
    move	$s1, $a1
    li 		$s2, 0

	la		$a0, space
	jal 	print_text
print_integer_fromArray_loop:
 	beq		$s2, $s1, print_integer_fromArray_loopDone

	la		$a0, space
	li		$a1, 3
	jal 	print_multiple

	lw		$a0, 0($s0)
	jal		print_integer

	addi	$s2, $s2, 1
	addi 	$s0, $s0, 4
 	j 		print_integer_fromArray_loop

print_integer_fromArray_loopDone:

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name: Read Integer
#
# Description:	prints out a string as much as specified next to each other
#				without spaces
#
# Arguments:	none
#
# Returns:		v0 The Integer read
#

read_integer:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	li 		$v0, READ_INT 	# read one int
	syscall

	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr $ra


#
# Name:					print_multiple
#
# Description:			prints out a string as much as specified next to each other
#						without spaces
#
# Arguments:			a0 	the address of the string
#						a1	the amount of times to print
#
# Temp Registers Used: 	$t8
#
# Returns:				none
#
print_multiple:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	li 		$t8, 0

print_multiple_loop:
	beq 	$t8, $a1, print_multiple_done

	li 		$v0, PRINT_STRING
	syscall

	addi 	$t8, $t8, 1
	j 		print_multiple_loop

print_multiple_done:
	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr $ra

#
# Name:		make_newline
#
# Description:	prints out a new line
#
#
# Returns:	none
#
make_newline:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	la 		$a0, newline
	li 		$v0, PRINT_STRING
	syscall

	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr 		$ra


#
# Name:		print_text
#
# Description:	prints a string
#
# Arguments:	a0 the address of the string
#
# Returns:	none
#
print_text:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	li 		$v0, PRINT_STRING
	syscall

	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr 		$ra

#
# Name:		print_integer
#
# Description:	prints a integer
#
# Arguments:	a0 integer to print
#
# Returns:	none
#
print_integer:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	#beq		$a0, $zero, empty
	li 		$v0, PRINT_INT
	syscall
	j		print_integer_done
empty:
	la		$a0, space
	jal 	print_text
print_integer_done:
	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr 		$ra


#
# Name: 		print_board
#
# Description:	Reads integer into specified array
#
# Arguments:	a0	the board array
#				a1	size of array
#				a2	array of north east south west views
#
# Returns:		none
print_board:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)	# east counter
    sw      $s6, 24($sp)	# west counter
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)	 # size of array
    sw      $s0, 0($sp)	 # array

	move	$s0, $a0
	move	$s1, $a1
	lw		$t6, 0($a2)
	lw		$t7, 4($a2)
	lw		$s2, 8($a2)
	lw		$t9, 12($a2)

	li		$s6, 0
	li		$s7, 0

	move	$a0, $t6
	move	$a1, $s1
	jal		print_integer_fromArray

	#total length of board
	mult	$s1, $s1
	mflo	$s3

	li		$s4, 0  #i = 0
print_board_loop:
	beq		$s4, $s3, print_board_loop_done

	div		$s4, $s1
	mfhi	$t4

	beq		$t4, $zero, first

print_board_loop_cont:
	la		$a0, space
	jal 	print_text

	lw		$a0, 0($s0)
	jal		print_integer

print_board_after_integer:
	la		$a0, space
	jal 	print_text

	la		$a0, vertical
	jal 	print_text


	addi	$s4, $s4, 1
	addi	$s0, $s0, 4
	j		print_board_loop

west_print:
	add		$t4, $s6, $t9
	lw		$a0, 0($t4)
	jal		print_integer
	la		$a0, space
	jal 	print_text
	addi	$s6, $s6, 4
	j		west_cont


east_print:
	add	$t4, $s7, $t7
	la		$a0, space
	jal 	print_text
	lw		$a0, 0($t4)
	jal		print_integer
	addi	$s7, $s7, 4
	beq		$s4, $s3, print_board_loop_done_cont
	j		east_cont

first:
	#east
	bne		$s4, $zero, east_print

east_cont:

	jal		make_newline

	move	$a0, $s1
	jal 	next_line

	#west
	bne		$s4, $s3, west_print

west_cont:
	la		$a0, vertical
	jal 	print_text

	j		print_board_loop_cont

print_board_loop_done:
	j		east_print
print_board_loop_done_cont:
	jal		make_newline
	move	$a0, $s1
	jal 	next_line
	move	$a0, $s2
	move	$a1, $s1
	jal		print_integer_fromArray
	jal		make_newline


	lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name:			next_line
#
# Description:	prints the line between the different number lines. e.g +---+---+
#
# Arguments:	a0	size of board
#
# Returns:		none
#

next_line:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0

	la		$a0, space
	li		$a1, 2
	jal 	print_multiple

	la		$a0, plus
	jal 	print_text

next_line_loop:
	beq 	$s0, $zero, next_line_back

	la		$a0, dash
	li		$a1, 3
	jal		print_multiple

	la		$a0, plus
	jal 	print_text

	addi	$s0, $s0, -1
	j 		next_line_loop

next_line_back:
	jal 	make_newline

	lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra


#
# Name:		closed_interval
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	low number
#				a1 	high number
#				a2 	number to check
#
# Returns:		v0	1 if number is between the interval, 0 otherwise
#
closed_interval:
	addi 	$sp, $sp, -4  	# allocate space for the return address
	sw 		$ra, 0($sp)		# store the ra on the stack

	addi	$a1, $a1, 1
	slt		$t1, $a2, $a0
	bne		$t1, $zero, closed_interval_error
	slt		$t1, $a2, $a1
	beq		$t1, $zero, closed_interval_error
	li		$v0, 1
	j		closed_interval_done

closed_interval_error:
	li		$v0, 0

closed_interval_done:
	lw 		$ra, 0($sp)
	addi 	$sp, $sp, 4

	jr 		$ra

#
# Name:		2d_to_1d
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	row
#				a1 	column
#				a2	size of board
#
# Returns:		v0	1d value
#
twod_to_1d:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	mult	$a2, $a0
	mflo	$s0
	add		$v0, $s0, $a1

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra


#
# Name:		allocate_mem:
#
# Description:	Allocate space from the pool of free memory.
#
# Arguments:	a0: the number of words to allocate
# Returns:	v0: the address of the newly allocated memory.
#

allocate_mem:
	#
	# See if there is any space left in the pool.
	#

	lw	$t0, next	# pointer to next available byte
	li	$t9, 4		# calculate number of bytes to allocate
	mult	$a0, $t9
	mflo	$t9
	add	$t8, $t0, $t9	# figure out where next would be if we
				# allocate the space
	la	$t1, pool_end

	slt	$t2, $t8, $t1	# Compare next addr to end of pool
	bne	$t2, $zero, new_mem_ok	#  if less then still have space

	#
	# No space left; write error message and exit.
	#

	li 	$v0, PRINT_STRING	# print error message
	la 	$a0, new_error
	syscall

	li 	$v0, EXIT		# terminate program
	syscall

new_mem_ok:
	#
	# There is space available.  Allocate the next chunk of mem
	#

	move	$v0, $t0	# set up to return spot for new mem block
	li	$t9, 4		# calculate number of bytes to allocate
	mult	$a0, $t9
	mflo	$t9
	add	$t0, $t0, $t9	# Adjust pointer for the allocated space
	sw	$t0, next

	jr	$ra


#
# Name:			solve
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	board
#				a1 	size
#				a2	start index
#				a3	views from different sides
#
# Returns:		v0	none
#

solve:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3

	mult	$s1, $s1
	mflo	$t0
	beq		$t0, $s2, loop_index_done

	li		$t0, 4
	mult	$s2, $t0
	mflo	$t0
	add		$t0, $s0, $t0

	lw		$t0, 0($t0)
	bne		$t0, $zero, no_inner

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3
	jal		loop_possible_numbers
	beq		$v0, $zero, solve_done
	j		no_inner_cont

no_inner:
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	addi	$a2, $a2, 1
	move	$a3, $s3
	beq		$s2, $t0, loop_index_done
	jal		solve

no_inner_cont:
	mult	$s1, $s1
	mflo	$t0
	bne		$s2, $t0, solve_done

loop_index_done:
	la		$a0, final_puzzle_text
	jal		print_text

	jal 	make_newline

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s3
	jal		print_board
	li 		$v0, EXIT		# terminate program
	syscall

solve_done:
	lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra



#
# Name:			loop_possible_numbers
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	board
#				a1 	size
#				a2	index
#				a3	views from different sides
#
# Returns:		$v0 1 - something is possible 0 otherwise
#

loop_possible_numbers:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3

	li		$s4, 0

loop_possible_numbers_loop:
	beq		$s4, $s1, track_back

	li		$t0, 4
	mult	$t0, $s2
	mflo	$t0

	add		$t0, $t0, $s0

	addi	$t1, $s4, 1
	sw		$t1, 0($t0)

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	move	$a3, $s3

	jal		validate_puzzle

	beq		$v0, $zero, next_spot_cont

next_spot:

	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	addi	$a2, $a2, 1
	move	$a3, $s3
	jal		solve
	j		next_spot_cont



next_spot_cont:
	addi	$s4, $s4, 1
	j		loop_possible_numbers_loop


track_back:
	li		$t0, 4
	mult	$t0, $s2
	mflo	$t0

	add		$t0, $t0, $s0
	sw		$zero, 0($t0)

loop_possible_numbers_loop_done:
    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra


#
# Name:			validate_puzzle
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	board
#				a1 	size
#				a2	index
#				a3	views from different sides
#
# Returns:		none
#
validate_puzzle:
	addi    $sp,$sp,-40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)    # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3

	#horizontal
	div		$s2, $s1
	mflo	$s7

	mult	$s1, $s7
	mflo	$s4

	la		$s5, row_or_col
	li		$s6, 0

horizontal_loop:
	beq		$s6, $s1, horizontal_loop_done

	li		$t0, 4
	move	$t1, $s4
	add		$t1, $t1, $s6

	mult	$t0, $t1
	mflo	$t0

	add		$t0, $s0, $t0
	lw		$t0, 0($t0)


	sw		$t0, 0($s5)

	addi	$s6, $s6, 1
	addi	$s5, $s5, 4
	j		horizontal_loop
horizontal_loop_done:
	#check repetition
	la		$a0, row_or_col
	move	$a1, $s1
	jal		check_repetition

	bne		$v0, $zero, bad_puzzle

	#check west
	la		$a0, row_or_col
	move	$a1, $s1
	lw		$a2, 12($s3)
	li		$t0, 4
	mult	$t0, $s7
	mflo	$t0
	add		$a2, $a2, $t0
	lw		$a2, 0($a2)

	jal		check_building_north_west
	beq		$v0, $zero, bad_puzzle


	#check east
	la		$a0, row_or_col
	move	$a1, $s1
	lw		$a2, 4($s3)
	li		$t0, 4
	mult	$t0, $s7
	mflo	$t0
	add		$a2, $a2, $t0
	lw		$a2, 0($a2)

	jal		check_building_south_east
	beq		$v0, $zero, bad_puzzle


	#vertical
	div		$s2, $s1
	mfhi	$s7

	move	$s4, $s7

	la		$s5, row_or_col
	li		$s6, 0

vertical_loop:
	beq		$s6, $s1, vertical_loop_done

	li		$t0, 4
	mult	$t0, $s4
	mflo	$t0


	add		$t0, $s0, $t0
	lw		$t0, 0($t0)

	sw		$t0, 0($s5)

	addi	$s6, $s6, 1
	addi	$s5, $s5, 4
	add		$s4, $s4, $s1
	j		vertical_loop
vertical_loop_done:
	#check repetition
	la		$a0, row_or_col
	move	$a1, $s1
	jal		check_repetition
	bne		$v0, $zero, bad_puzzle

	#check north
	la		$a0, row_or_col
	move	$a1, $s1
	lw		$a2, 0($s3)
	li		$t0, 4
	mult	$t0, $s7
	mflo	$t0
	add		$a2, $a2, $t0
	lw		$a2, 0($a2)

	jal		check_building_north_west
	beq		$v0, $zero, bad_puzzle

	#check south
	la		$a0, row_or_col
	move	$a1, $s1
	lw		$a2, 8($s3)
	li		$t0, 4
	mult	$t0, $s7
	mflo	$t0
	add		$a2, $a2, $t0
	lw		$a2, 0($a2)

	jal		check_building_south_east
	beq		$v0, $zero, bad_puzzle
good_puzzle:
	li		$v0, 1
	j		validate_puzzle_done

bad_puzzle:
	li		$v0, 0
	j		validate_puzzle_done

validate_puzzle_done:
    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name:			check_repetition
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	array
#				a1 	size
#
#
# Returns:	 	v0 	1- repetition occurred 0 otherwise
#
check_repetition:
	addi    $sp, $sp, -40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)      # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)

	move	$s0, $a0
	move	$s1, $a1

	li		$s2, 0
	li		$t6, 0
check_repetition_loop:
	beq		$s2, $s1, check_repetition_loop_done

	add		$t0, $t6, $s0		#counter for array locaton
	lw		$t0, 0($t0)

	beq		$t0, $zero, check_repetition_loop2_done
	addi	$t1, $s2, 1

	li		$t5, 4
	mult	$t5, $t1
	mflo	$t5
check_repetition_loop2:
	slt		$t2, $t1, $s1
	beq		$t2, $zero, check_repetition_loop2_done


	add		$t3, $s0, $t5
	lw		$t3, 0($t3)

	li		$s7, 1
	beq		$t3, $t0, check_repetition_loop_done

	addi	$t1, $t1, 1
	addi	$t5, $t5, 4
	j		check_repetition_loop2
check_repetition_loop2_done:

	li		$s7, 0
	addi	$s2, $s2, 1
	addi	$t6, $t6, 4

	j		check_repetition_loop

check_repetition_loop_done:
	move	$v0, $s7

    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name:			check_building
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	array - [north - south] or [west - east]
#				a1 	size
#				a2	north/west
#				a3	direction 0- north/west 1- south/east
#
# Returns:		v0	1 - if correct view is acquired or might be inconclusive 0 otherwise
#
check_building_north_west:
	addi    $sp, $sp, -40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)      # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)


	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2

	beq		$s2, $zero, true_north_west_building

	li		$s4, 0 			# number of building seen
	li		$s5, 0			# counter
	li		$s6, 0			# current highest building
	li		$s7, 0			# zero counter

check_building_north_west_loop:
	beq		$s5, $s1, check_building_north_west_loop_done

	li		$t0, 4
	mult	$s5, $t0
	mflo	$t0

	add		$t0, $s0, $t0
	lw		$t0, 0($t0)

	beq		$t0, $zero, true_north_west_building

	slt		$t1, $s6, $t0
	beq		$t1, $zero, check_building_north_west_loop_move

	move	$s6, $t0
	addi	$s4, $s4, 1

	j		check_building_north_west_loop_move

check_building_north_west_loop_move:
	addi	$s5, $s5, 1
	j		check_building_north_west_loop

check_building_north_west_loop_done:
	beq		$s4, $s2, true_north_west_building
	j		false_north_west_building

true_north_west_building:
	li		$v0, 1
	j		check_building_north_west_done

false_north_west_building:
	li		$v0, 0

check_building_north_west_done:
    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra

#
# Name:			check_building
#
# Description:	Checks if a number is within a closed interval of two different numbers.
#
# Arguments:	a0 	array - [north - south] or [west - east]
#				a1 	size
#				a2	south/east view number
#
# Returns:		none
#
check_building_south_east:
	addi    $sp, $sp, -40     # allocate stack frame (on doubleword boundary)
    sw      $ra, 32($sp)      # store the ra & s reg's on the stack
    sw      $s7, 28($sp)
    sw      $s6, 24($sp)
    sw      $s5, 20($sp)
    sw      $s4, 16($sp)
    sw      $s3, 12($sp)
    sw      $s2, 8($sp)
    sw      $s1, 4($sp)
    sw      $s0, 0($sp)


	move	$s0, $a0
	move	$s1, $a1
	move	$s2, $a2

	beq		$s2, $zero, true_south_east_building

	li		$s4, 0 			# number of building seen
	addi	$s5, $s1, -1	# counter
	li		$s6, 0			# current highest building
	li		$s7, 0			# zero counter
	li		$s3, -1

check_building_south_east_loop:
	beq		$s5, $s3, check_building_south_east_loop_done

	li		$t0, 4
	mult	$s5, $t0
	mflo	$t0

	add		$t0, $s0, $t0
	lw		$t0, 0($t0)

	beq		$t0, $zero, true_south_east_building

	slt		$t1, $s6, $t0
	beq		$t1, $zero, check_building_south_east_loop_move

	move	$s6, $t0
	addi	$s4, $s4, 1

	j		check_building_south_east_loop_move

check_building_south_east_loop_move:
	addi	$s5, $s5, -1
	j		check_building_south_east_loop

check_building_south_east_loop_done:
	beq		$s4, $s2, true_south_east_building
	j		false_south_east_building

true_south_east_building:
	li		$v0, 1
	j		check_building_south_east_done

false_south_east_building:
	li		$v0, 0

check_building_south_east_done:
    lw      $ra, 32($sp)    # restore the ra & s reg's from the stack
    lw      $s7, 28($sp)
    lw      $s6, 24($sp)
    lw      $s5, 20($sp)
    lw      $s4, 16($sp)
    lw      $s3, 12($sp)
    lw      $s2, 8($sp)
    lw      $s1, 4($sp)
    lw      $s0, 0($sp)
    addi    $sp,$sp,40      # clean up stack

    jr 		$ra
#***** END OF PROGRAM *****************************
