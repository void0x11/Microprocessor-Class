.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

#include "board_setup.h"
#include "keypad.h"
#include "7segment.h"

.global main

main:
	//First, enable clocks and configure modes for pins
	ldr r0, =RCC_AHB1ENR
    ldr r1, [r0]
    orr r1, r1, #RCC_AHB1ENR_GPIOAEN
    orr r1, r1, #RCC_AHB1ENR_GPIOBEN
    orr r1, r1, #RCC_AHB1ENR_GPIOCEN
    str r1, [r0]

    //Each pin can be input (00) or output (01)
    //Columns are inputs because we read from them
    //Rows are outputs because we send a singal to them all the time

    //Configuring GPIOA:
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    //Rows Output
    and r1, r1, #~GPIO_MODER_A8_MASK
    orr r1, r1, #GPIO_MODER_A8_OUTPUT
    and r1, r1, #~GPIO_MODER_A9_MASK
    orr r1, r1, #GPIO_MODER_A9_OUTPUT
    //7-Segment Output
    and r1, r1, #~GPIO_MODER_A7_MASK
    orr r1, r1, #GPIO_MODER_A7_OUTPUT
    and r1, r1, #~GPIO_MODER_A6_MASK
    orr r1, r1, #GPIO_MODER_A6_OUTPUT
    and r1, r1, #~GPIO_MODER_A5_MASK
    orr r1, r1, #GPIO_MODER_A5_OUTPUT
    and r1, r1, #~GPIO_MODER_A10_MASK
    orr r1, r1, #GPIO_MODER_A10_OUTPUT
    str r1, [r0]

    //Configuring GPIOB:
    ldr r0, =GPIOB_MODER
    ldr r1, [r0]
    //Columns Input
    and r1, r1, #~GPIO_MODER_B3_MASK
    and r1, r1, #~GPIO_MODER_B5_MASK
    and r1, r1, #~GPIO_MODER_B4_MASK
    // Output
    and r1, r1, #~GPIO_MODER_B6_MASK
    orr r1, r1, #GPIO_MODER_B6_OUTPUT
    and r1, r1, #~GPIO_MODER_B9_MASK
    orr r1, r1, #GPIO_MODER_B9_OUTPUT
    and r1, r1, #~GPIO_MODER_B10_MASK
    orr r1, r1, #GPIO_MODER_B10_OUTPUT
    str r1, [r0]

    //Configuring GPIOC
    ldr r0, =GPIOC_MODER
    ldr r1, [r0]
    //Rows Output
    and r1, r1, #~GPIO_MODER_C7_MASK
    orr r1, r1, #GPIO_MODER_C7_OUTPUT
    str r1, [r0]

    //Configuring Pull-Up Resistors:
    //GPIOB
    ldr r0, =GPIOB_PUPDR
    ldr r1, [r0]
    and r1, r1, #~GPIO_PUPDR_B3_MASK
    orr r1, r1,	#GPIO_PUPDR_B3_PULLUP
    and r1, r1, #~GPIO_PUPDR_B5_MASK
    orr r1, r1,	#GPIO_PUPDR_B5_PULLUP
    and r1, r1, #~GPIO_PUPDR_B4_MASK
    orr r1, r1,	#GPIO_PUPDR_B4_PULLUP
    str r1, [r0]

    //For when no key is pressed:
    mov r4, #NO_KEY

loop:
    mov r5, #0

scan_loop:
	//Start by setting all rows to HIGH
	ldr r0, =GPIOC_BSRR
	mov r1, #(1 << ROW0_PIN)
	str r1, [r0]

	ldr r0, =GPIOA_BSRR
	mov r1, #(1 << ROW1_PIN)
	orr r1, r1, #(1 << ROW2_PIN)
	str r1, [r0]

	//check R5 to see which row to activate.
	cmp r5, #0
	beq set_row0_low
	cmp r5, #1
	beq set_row1_low
	cmp r5, #2
	beq set_row2_low
	b scan_next

set_row0_low:
    ldr r0, =GPIOC_BSRR
    mov r1, #(1 << (ROW0_PIN + 16)) //Reset PC7 (Low)
    str r1, [r0]
    b row_set_done
set_row1_low:
    ldr r0, =GPIOA_BSRR
    mov r1, #(1 << (ROW1_PIN + 16)) //Reset PA9 (Low)
    str r1, [r0]
    b row_set_done
set_row2_low:
    ldr r0, =GPIOA_BSRR
    mov r1, #(1 << (ROW2_PIN + 16)) //Reset PA8 (Low)
    str r1, [r0]
    b row_set_done

row_set_done:
   //Delay cycles because it takes a small amount of time for voltage to drop to 0
    mov r0, #100
    bl delay_cycles

    //Check if any column is LOW
    bl read_columns

	//If R0 != 0, a key has been pressed
    cmp r0, #NO_KEY
    bne key_found

	//Loops if key has not been found
    add r5, r5, #1
    cmp r5, #3
    blt scan_loop

    //If no key has been found to be pressed:
    mov r0, #NO_KEY
    b handle_no_key_press

scan_next:
	b scan_loop

	//Key processing:
key_found:
	//Combine R5 and R0 to make a unique ID for key pressed
	mov r1, #1
	lsl r1, r1, r5
	lsl	r1, r1, #4
	orr r0, r0, r1
	//If the key pressed was a previous key pressed, do nothing
	cmp r0, r4
	beq loop
	//If they key pressed is a new key
	mov r4, r0
	beq loop

	mov r4, r0		//Update Last Key

	//Update 7-Segment Display
	bl decode_key_lookup
	bl display_7segment

	//Delay cycle to avoid bouncing of the switch
	ldr r0, =200000
	bl delay_cycles

	b loop

handle_no_key_press:
	mov r4, #NO_KEY
	b loop

display_7segment:
    push {r1, r2, r3, lr}         // Save registers

    // r0 = number 1–9
    subs r0, r0, #1               // convert to index 0–8

    ldr r1, =Segment_Lookup_Table
    add r1, r1, r0
    ldrb r0, [r1]                 // r0 = 7-segment bit pattern

    // Load GPIO BSRR addresses
    ldr r1, =GPIOA_BSRR
    ldr r2, =GPIOB_BSRR

    // -----------------------------
    //  Segment A  (bit0) → PB6
    // -----------------------------
    tst r0, #(1 << 0)
    beq segA_off
    mov r3, #(1 << SEGMENT_A_PIN)
    b segA_done
segA_off:
    mov r3, #(1 << (SEGMENT_A_PIN + 16))
segA_done:
    str r3, [r2]

    // -----------------------------
    //  Segment B  (bit1) → PA7
    // -----------------------------
    tst r0, #(1 << 1)
    beq segB_off
    mov r3, #(1 << SEGMENT_B_PIN)
    b segB_done
segB_off:
    mov r3, #(1 << (SEGMENT_B_PIN + 16))
segB_done:
    str r3, [r1]

    // -----------------------------
    //  Segment C  (bit2) → PA6
    // -----------------------------
    tst r0, #(1 << 2)
    beq segC_off
    mov r3, #(1 << SEGMENT_C_PIN)
    b segC_done
segC_off:
    mov r3, #(1 << (SEGMENT_C_PIN + 16))
segC_done:
    str r3, [r1]

    // -----------------------------
    //  Segment D  (bit3) → PA5
    // -----------------------------
    tst r0, #(1 << 3)
    beq segD_off
    mov r3, #(1 << SEGMENT_D_PIN)
    b segD_done
segD_off:
    mov r3, #(1 << (SEGMENT_D_PIN + 16))
segD_done:
    str r3, [r1]

    // -----------------------------
    //  Segment E  (bit4) → PA10
    // -----------------------------
    tst r0, #(1 << 4)
    beq segE_off
    mov r3, #(1 << SEGMENT_E_PIN)
    b segE_done
segE_off:
    mov r3, #(1 << (SEGMENT_E_PIN + 16))
segE_done:
    str r3, [r1]

    // -----------------------------
    //  Segment F  (bit5) → PB10
    // -----------------------------
    tst r0, #(1 << 5)
    beq segF_off
    mov r3, #(1 << SEGMENT_F_PIN)
    b segF_done
segF_off:
    mov r3, #(1 << (SEGMENT_F_PIN + 16))
segF_done:
    str r3, [r2]

    // -----------------------------
    //  Segment G  (bit6) → PB9
    // -----------------------------
    tst r0, #(1 << 6)
    beq segG_off
    mov r3, #(1 << SEGMENT_G_PIN)
    b segG_done
segG_off:
    mov r3, #(1 << (SEGMENT_G_PIN + 16))
segG_done:
    str r3, [r2]

    pop {r1, r2, r3, pc}

read_columns:
	ldr r1, =GPIOB_IDR
	ldr r2, [r1]

	tst r2, #(1 << COL0_PIN)
    beq ret_col0
    tst r2, #(1 << COL1_PIN)
    beq ret_col1
    tst r2, #(1 << COL2_PIN)
    beq ret_col2

//No Key:
    mov r0, #NO_KEY
    bx lr

ret_col0:
    mov r0, #COL0_BIT
    bx lr
ret_col1:
    mov r0, #COL1_BIT
    bx lr
ret_col2:
    mov r0, #COL2_BIT
    bx lr

decode_key_lookup:
    push {r1, r2, lr}
    ldr r1, =Keypad_Lookup_Table
    mov r2, #0

decode_loop:
    ldrb r3, [r1, r2]
    cmp r3, #0
    beq decode_fail                 //Reached the end of the table

    cmp r3, r0
    beq decode_match                //Match in table was found

    add r2, r2, #1                  //Move to next entry in table
    b decode_loop

decode_match:
    add r2, r2, #1                  //Value is in the next byte
    ldrb r0, [r1, r2]
    pop {r1, r2, pc}

decode_fail:
    mov r0, #0xFF
    pop {r1, r2, pc}

delay_cycles:
    subs r0, r0, #1
    bne delay_cycles
    bx lr

//-----------------------------------------------------------------------------------------*
//DATA SECTION   																		   *
//-----------------------------------------------------------------------------------------*
.section .data
.align 2

Keypad_Lookup_Table:
	//Format: .byte SCAN_CODE, NUMBERIC_VALUE
	//Row 0
	.byte 0x11, 1
    .byte 0x12, 2
    .byte 0x14, 3
     //Row 1
    .byte 0x21, 4
    .byte 0x22, 5
    .byte 0x24, 6
    //Row 2
    .byte 0x41, 7
    .byte 0x42, 8
    .byte 0x44, 9

    .byte 0, 0      //Null Terminator

Segment_Lookup_Table:
	.byte 0b00000110  // 1
    .byte 0b01011011  // 2
    .byte 0b01001111  // 3
    .byte 0b01100110  // 4
    .byte 0b01101101  // 5
    .byte 0b01111101  // 6
    .byte 0b00000111  // 7
    .byte 0b01111111  // 8
    .byte 0b01101111  // 9

.end
