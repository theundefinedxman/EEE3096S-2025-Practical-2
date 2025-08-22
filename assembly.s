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
	@ Enabling clock for GPIOA AND GPIOB
	LDR R0, RCC_BASE  		@ Load the base address of Reset and clock control module from memory to the register R0.
	LDR R1, [R0, #0x14]     @ Load AHBENR peripheral clock enable register from memory to the register R1.
	LDR R2, AHBENR_GPIOAB	@ Load AHBENR peripheral clock enable register for GPIOA and GPIOB from memory to the register R2.
	ORRS R1, R1, R2         @ Logical OR on R1 = R2 + R1 which sets Bit 17 and 18 which enables the clock for port A and B.
	STR R1, [R0, #0x14]     @ Store register R1 back to memory at memory address 0x40021014.

    @ Enabling Pull up resistors for GPIO A.
	LDR R0, GPIOA_BASE		@ Load GPIOA_BASE from memory to register R0.
	MOVS R1, #0b01010101    @ Put 85 on register R1.
	STR R1, [R0, #0x0C]     @ Store register R1 back to memory at memory address 0x4800000C.

	@ Configuring the mode for GPIO B.
	LDR R1, GPIOB_BASE  	@ Load GPIOB_BASE from memory to register R1
	LDR R2, MODER_OUTPUT    @ Load MODER_OUTPUT memory address from memory to register R2
	STR R2, [R1, #0]        @ Store register R2 on R1 at #0 memory address which is just 0101 0101 0101 0101 the sets PB0 - PB7 to output mode.
	MOVS R2, #0         	@ Put #0 memory address to register R2 as R2 will be dedicated to holding the value on the LEDs
    SUBS R2, R2 ,#1         @ Bug Fix

@ TODO: Add code, labels and logic for button checks and LED patterns
SW0_Pressed:
	LDR R4, [R0, #0x10]     @ Load input data register again.

	ADDS R2, R2, #2
	BL delay_loader_1
	BL delay_0_7s
	STR R2, [R1 , #0x14]

	MOVS R5, #0x01
	TST R4, R5
    BNE main_loop           @ Branch to main if z flag is not set.
    B SW0_Pressed           @ Branch to conditon SW0_Pressed if z flag is not set.

SW1_Pressed:
	LDR R4, [R0, #0x10]

	ADDS R2, R2, #1
	BL delay_loader_2
	BL delay_0_3s
	STR R2, [R1 , #0x14]

	MOVS R5, #0x01
    TST R4, R5
    BNE main_loop
    B SW1_Pressed

SW2_Pressed:
    LDR R4, [R0, #0x10]

    MOVS R2, #0xAA
    STR R2, [R1 , #0x14]

    MOVS R5, #0x04
    TST R4, R5
    BNE main_loop
    B SW2_Pressed

SW3_Pressed:
    LDR R4, [R0, #0x10]

    MOVS R5, #0x08
    TST R4, R5
    BNE main_loop
    B SW3_Pressed

main_loop:
	 LDR R4, [R0, #0x10]    @ Load input data register from GPIOA to register R4.
     
	 MOVS R5, #0x03
	 TST R4, R5
	 BEQ SW0_SW1_Pressed
  
	 MOVS R5, #0x01         @ Put #0x01 to register R5 which is just a bit mask for PB0.
	 TST R4, R5             @ Checks whether bit 0 of R4 is 0 if so z flag is set else cleared due to pull up resistors enabled.
	 BEQ SW0_Pressed        @ if z flag is set the program will branch to label SWO condition else sequence follows.

	 MOVS R5, #0x02
	 TST R4, R5
	 BEQ SW1_Pressed

	 MOVS R5, #0x04
	 TST R4, R5
	 BEQ SW2_Pressed

	 MOVS R5, #0x08
	 TST R4, R5
	 BEQ SW3_Pressed

	 ADDS R2, R2, #1       @ Increments Register R2 ,where R2 = R2+1.
	 BL delay_loader_1     @ Function Call delay_loader_1.
	 BL delay_0_7s         @ Function Call delay_0_7s.
	 B write_leds          @ Store register R2 on R1 at memory address #0x14.
	 B main_loop           @ Branch back to main.

write_leds:
	STR R2, [R1, #0x14]
	B main_loop
delay_loader_1:             @ Function to Load LONG_DELAY_CNT memory address to register.
	LDR R3, =LONG_DELAY_CNT @ Load LONG_DELAY_CNT memory address from memory to register R3.
	LDR R3, [R3]            @ Actual value of LONG_DELAY_CNT Loaded to R1
	BX LR                   @ Links the program back to register.

delay_0_7s:                 @ Delay function which delays program for 0.7s.
	SUBS R3,R3 ,#1          @ Decrements register R3,where R3 = R3-1.
	BNE delay_0_7s          @ Checks if register R3 has not reached zero if not branches back to function else program execution continues.
	BX LR

delay_loader_2:             @ Function to Load SHORT_DELAY_CNT memory address to register.
	LDR R3, =SHORT_DELAY_CNT
	LDR R3, [R3]
	BX LR

delay_0_3s:                 @ Delay function which delays program by 0.3s
	SUBS R3,R3 ,#1
	BNE delay_0_3s
	BX LR

clear_LEDs:
	BL clear
	B main_loop

clear:
	MOVS R2, #0x0           @ Put 0x0 on R2
	STR R2, [R1 , #0x14]

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 5600000
SHORT_DELAY_CNT: 	.word 2400000
