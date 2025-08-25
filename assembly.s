/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
	@ Write current LED pattern to the LEDs first
	MOVS R6, #0xFF        @ Create mask for lower 8 bits
	ANDS R2, R2, R6       @ Keep only lower 8 bits
	STR R2, [R1, #0x14]   @ Write to GPIOB_ODR
	LDR R4, [R0, #0x10] @GPIOA_IDR is at offset 0x10


	@ CHECK FOR SWITCH 4 FIRST (both buttons 0 and 1 pressed)
	MOVS R5, #0b00000011
	ANDS R5, R4, R5
	CMP R5, #0b00000000 @ Check if BOTH bits are set
	BEQ switch_four @ Branch if both switches pressed

	@ we are checking if switch 0 is being pressed
	MOVS R5,#0b00000001
	ANDS R5, R4, R5 @ Mask bits 0
	@CMP R5, #0x00
	BEQ switch_zero

	@ we are checking if switch 1 is being pressed
	MOVS R5,#0b00000010
	ANDS R5, R4, R5 @ Mask bits 1
	@CMP R5, #0x00
	BEQ switch_one

	@ we are checking if switch 2 is being pressed
	MOVS R5,#0b00000100
	ANDS R5, R4, R5 @ Mask bits 2
	@CMP R5, #0x00
	BEQ switch_two

	@ we are checking if switch 3 is being pressed
	MOVS R5,#0b00001000
	ANDS R5, R4, R5 @ Mask bits 3
	@CMP R5, #0x00
	BEQ switch_three


@ we should increment the LED pattern by 1 every 0.7 seconds as long as no button is being pressed
default:
	LDR R3, LONG_DELAY_CNT
	BL Delay_Loop
	B case_1

@ Increment LED pattern by 1
case_1:
	ADDS R2, R2, #1
	B main_loop

@ Increment LED pattern by 2
case_2:
	ADDS R2, R2, #2
	B main_loop

@ We should increment the LED pattern by 2 while button 0 is being held down
switch_zero:
	LDR R3, LONG_DELAY_CNT
	BL Delay_Loop
	B case_2

@ change the delay to 0.3 seconds instead of 0.7 seconds while button 1 is being held down
switch_one:
	LDR R3, SHORT_DELAY_CNT
	BL Delay_Loop
	B case_1

@ change the LED pattern to 0xAA while button 2 is being held down
switch_two:
	MOVS R2, #0xAA
	B main_loop

@ freeze the LED pattern while button 3 is being held down
switch_three:
	B main_loop

@ Both buttons 0 and 1 pressed: 0.3 second delay, increment by 2
switch_four:
	LDR R3, SHORT_DELAY_CNT
	BL Delay_Loop
	ADDS R2, R2, #2    @ Increment by 2 only
	B main_loop

Delay_Loop:
	SUBS R3, R3, #1
	BNE Delay_Loop
	BX LR @ Return from subroutine

@write_leds:
@	STR R2, [R1, #0x14]
@	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 600000
