.syntax unified
.cpu cortex-m4
.fpu softvfp
.thumb

@ ====================================================================================== @
@                                 MAIN APPLICATION
@ ====================================================================================== @
@ Project:      4x4 Keypad Scanner with Binary LED Output
@ Platform:     STM32F4xx (Nucleo-F401RE / F446RE)
@ Language:     ARM Assembly (GNU Syntax)
@ Description:  This program demonstrates how to scan a keypad and control LEDs.
@
@               KEYPAD MAPPING (D2 - D9):
@               - Cols: D2(PA10), D3(PB3), D4(PB5), D5(PB4)
@               - Rows: D6(PB10), D7(PA8), D8(PA9), D9(PC7)
@
@               LED MAPPING (D10 - D13):
@               - Bit 0: D10 (PB6)
@               - Bit 1: D11 (PA7)
@               - Bit 2: D12 (PA6)
@               - Bit 3: D13 (PA5)
@
@ ====================================================================================== @

@ Include Definitions (Register Addresses and Pin Mappings)
#include "board_setup.h"
#include "keypad.h"
#include "leds.h"

.global main

@ ====================================================================================== @
@                                 MAIN ENTRY POINT
@ ====================================================================================== @
main:
    @ ==================================================================================
    @ STEP 1: SYSTEM INITIALIZATION
    @ ==================================================================================
    @ Before we can use any pins, we must ENABLE their clocks and CONFIGURE their modes.

    @ ----------------------------------------------------------------------------------
    @ 1.1 Enable Peripheral Clocks
    @ ----------------------------------------------------------------------------------
    @ STUDENT NOTE:
    @ The STM32 saves power by turning off clocks to peripherals by default.
    @ We must manually enable the clocks for GPIOA, GPIOB, and GPIOC in the RCC register.
    
    ldr r0, =RCC_AHB1ENR            @ Load Address of RCC Clock Register
    ldr r1, [r0]                    @ Read current value
    orr r1, r1, #RCC_AHB1ENR_GPIOAEN  @ Enable GPIOA
    orr r1, r1, #RCC_AHB1ENR_GPIOBEN  @ Enable GPIOB
    orr r1, r1, #RCC_AHB1ENR_GPIOCEN  @ Enable GPIOC
    str r1, [r0]                    @ Write back to register

    @ ----------------------------------------------------------------------------------
    @ 1.2 Configure GPIO Modes (Input vs Output)
    @ ----------------------------------------------------------------------------------
    @ STUDENT NOTE:
    @ Each pin can be an Input (00) or Output (01).
    @ - Keypad Rows are OUTPUTS because we "drive" them Low.
    @ - Keypad Columns are INPUTS because we "read" them.
    @ - LEDs are OUTPUTS.
    
    @ --- Configure GPIOA ---
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]

    @ Rows: PA8, PA9 (Output)
    and r1, r1, #~GPIO_MODER_A8_MASK    @ Clear bits
    orr r1, r1, #GPIO_MODER_A8_OUTPUT   @ Set to Output (01)
    and r1, r1, #~GPIO_MODER_A9_MASK
    orr r1, r1, #GPIO_MODER_A9_OUTPUT

    @ Cols: PA10 (Input)
    and r1, r1, #~GPIO_MODER_A10_MASK   @ Clear bits (00 = Input)

    @ LEDs: PA7, PA6, PA5 (Output)
    and r1, r1, #~GPIO_MODER_A7_MASK
    orr r1, r1, #GPIO_MODER_A7_OUTPUT
    and r1, r1, #~GPIO_MODER_A6_MASK
    orr r1, r1, #GPIO_MODER_A6_OUTPUT
    and r1, r1, #~GPIO_MODER_A5_MASK
    orr r1, r1, #GPIO_MODER_A5_OUTPUT
    
    str r1, [r0]                    @ Save changes to GPIOA_MODER

    @ --- Configure GPIOB ---
    ldr r0, =GPIOB_MODER
    ldr r1, [r0]

    @ Rows: PB10 (Output)
    and r1, r1, #~GPIO_MODER_B10_MASK
    orr r1, r1, #GPIO_MODER_B10_OUTPUT

    @ Cols: PB3, PB5, PB4 (Input)
    and r1, r1, #~GPIO_MODER_B3_MASK
    and r1, r1, #~GPIO_MODER_B5_MASK
    and r1, r1, #~GPIO_MODER_B4_MASK

    @ LEDs: PB6 (Output)
    and r1, r1, #~GPIO_MODER_B6_MASK
    orr r1, r1, #GPIO_MODER_B6_OUTPUT
    
    str r1, [r0]                    @ Save changes to GPIOB_MODER

    @ --- Configure GPIOC ---
    ldr r0, =GPIOC_MODER
    ldr r1, [r0]

    @ Rows: PC7 (Output)
    and r1, r1, #~GPIO_MODER_C7_MASK
    orr r1, r1, #GPIO_MODER_C7_OUTPUT
    
    str r1, [r0]                    @ Save changes to GPIOC_MODER

    @ ----------------------------------------------------------------------------------
    @ 1.3 Configure Pull-Up Resistors
    @ ----------------------------------------------------------------------------------
    @ STUDENT NOTE:
    @ When a button is NOT pressed, the input pin is "floating" (unconnected).
    @ We enable PULL-UP resistors to force the pin to HIGH (1) by default.
    @ When we press a button, it connects to a LOW Row, pulling the pin to LOW (0).
    
    ldr r0, =GPIOA_PUPDR
    ldr r1, [r0]
    and r1, r1, #~GPIO_PUPDR_A10_MASK
    orr r1, r1, #GPIO_PUPDR_A10_PULLUP
    str r1, [r0]

    ldr r0, =GPIOB_PUPDR
    ldr r1, [r0]
    and r1, r1, #~GPIO_PUPDR_B3_MASK
    orr r1, r1, #GPIO_PUPDR_B3_PULLUP
    and r1, r1, #~GPIO_PUPDR_B5_MASK
    orr r1, r1, #GPIO_PUPDR_B5_PULLUP
    and r1, r1, #~GPIO_PUPDR_B4_MASK
    orr r1, r1, #GPIO_PUPDR_B4_PULLUP
    str r1, [r0]

    @ ----------------------------------------------------------------------------------
    @ 1.4 Initialize Variables
    @ ----------------------------------------------------------------------------------
    mov r4, #NO_KEY                 @ R4 will store the "Last Key Pressed"

@ ====================================================================================== @
@ STEP 2: MAIN LOOP
@ ====================================================================================== @
loop:
    @ ----------------------------------------------------------------------------------
    @ 2.1 Keypad Scanning Routine
    @ ----------------------------------------------------------------------------------
    @ STUDENT NOTE:
    @ We scan the keypad by activating ONE Row at a time (driving it LOW).
    @ Then we check if any Column reads LOW.
    @ If Row 0 is LOW and Column 1 reads LOW, we know Button (0,1) is pressed.
    
    mov r5, #0                      @ R5 = Current Row Index (0 to 3)

scan_loop:
    @ ------------------------------------------------------------------------------
    @ A) Reset ALL Rows to HIGH (Inactive)
    @ ------------------------------------------------------------------------------
    @ We start by turning OFF all rows (setting them HIGH).
    
    ldr r0, =GPIOC_BSRR
    mov r1, #(1 << ROW0_PIN)        @ Set PC7 High
    str r1, [r0]
    
    ldr r0, =GPIOA_BSRR
    mov r1, #((1 << ROW1_PIN) | (1 << ROW2_PIN)) @ Set PA9, PA8 High
    str r1, [r0]
    
    ldr r0, =GPIOB_BSRR
    mov r1, #(1 << ROW3_PIN)        @ Set PB10 High
    str r1, [r0]

    @ ------------------------------------------------------------------------------
    @ B) Drive the CURRENT Row LOW (Active)
    @ ------------------------------------------------------------------------------
    @ We check R5 to see which row to activate.
    cmp r5, #0
    beq set_row0_low
    cmp r5, #1
    beq set_row1_low
    cmp r5, #2
    beq set_row2_low
    cmp r5, #3
    beq set_row3_low
    b scan_next

set_row0_low:
    ldr r0, =GPIOC_BSRR
    mov r1, #(1 << (ROW0_PIN + 16)) @ Reset PC7 (Low)
    str r1, [r0]
    b row_set_done
set_row1_low:
    ldr r0, =GPIOA_BSRR
    mov r1, #(1 << (ROW1_PIN + 16)) @ Reset PA9 (Low)
    str r1, [r0]
    b row_set_done
set_row2_low:
    ldr r0, =GPIOA_BSRR
    mov r1, #(1 << (ROW2_PIN + 16)) @ Reset PA8 (Low)
    str r1, [r0]
    b row_set_done
set_row3_low:
    ldr r0, =GPIOB_BSRR
    mov r1, #(1 << (ROW3_PIN + 16)) @ Reset PB10 (Low)
    str r1, [r0]

row_set_done:
    @ ------------------------------------------------------------------------------
    @ C) Wait for Signal to Settle
    @ ------------------------------------------------------------------------------
    @ It takes a tiny amount of time for the voltage to drop to 0V.
    mov r0, #100
    bl delay_cycles

    @ ------------------------------------------------------------------------------
    @ D) Read Columns
    @ ------------------------------------------------------------------------------
    bl read_columns_optimized       @ Check if any column is LOW

    @ ------------------------------------------------------------------------------
    @ E) Check if Key Found
    @ ------------------------------------------------------------------------------
    cmp r0, #NO_KEY
    bne key_found_optimized         @ If R0 != 0, a key is pressed!

    @ ------------------------------------------------------------------------------
    @ F) Move to Next Row
    @ ------------------------------------------------------------------------------
    add r5, r5, #1                  @ Increment Row Index
    cmp r5, #4                      @ Done all 4 rows?
    blt scan_loop                   @ If not, repeat

    @ If we finish loop and find nothing:
    mov r0, #NO_KEY
    b handle_no_key_press

scan_next:
    b scan_loop

@ ====================================================================================== @
@ STEP 3: KEY PROCESSING
@ ====================================================================================== @

key_found_optimized:
    @ A key is currently being pressed!
    
    @ 1. Calculate Scan Code
    @    We combine the Row Index (R5) and Column Bit (R0) to make a unique ID.
    @    Scan Code = (Row Index << 4) | Column Bit
    mov r1, #1
    lsl r1, r1, r5                  @ R1 = 1 << Row Index
    lsl r1, r1, #4                  @ Shift to upper nibble (e.g., 0x10, 0x20)
    orr r0, r0, r1                  @ Combine with Column Bit

    @ 2. Check for State Change (Debouncing)
    cmp r0, r4                      @ Is it the same key as before?
    beq loop                        @ If yes, do nothing (wait for release)

    @ New Key Pressed!
    mov r4, r0                      @ Update Last Key

    @ 3. Update Binary LEDs
    bl decode_key_lookup            @ Convert Scan Code to Number (0-15)
    bl display_binary_leds          @ Show on D10-D13

    @ 4. Debounce Delay
    @    Wait a bit to ignore mechanical "bouncing" of the switch.
    ldr r0, =200000
    bl delay_cycles

    b loop

handle_no_key_press:
    @ No key is currently pressed.
    @ Reset Last Key State so we can detect the next press.
    mov r4, #NO_KEY
    b loop

@ ====================================================================================== @
@ STEP 4: HELPER FUNCTIONS
@ ====================================================================================== @

@ --------------------------------------------------------------------------------------
@ Function: display_binary_leds
@ --------------------------------------------------------------------------------------
@ Purpose:     Displays a 4-bit value on the external LEDs.
@ Input:       R0 = Value (0-15)
@ Description: Checks each bit of R0 (0, 1, 2, 3) and sets the corresponding pin.
@ --------------------------------------------------------------------------------------
display_binary_leds:
    push {r1, r2, lr}

    @ --- Bit 0 (LSB) -> PB6 ---
    ldr r1, =GPIOB_BSRR
    tst r0, #1                      @ Is Bit 0 set?
    beq bit0_low
    mov r2, #(1 << LED_BIT0_PIN)    @ Yes -> Set Pin High
    b bit0_done
bit0_low:
    mov r2, #(1 << (LED_BIT0_PIN + 16)) @ No -> Set Pin Low
bit0_done:
    str r2, [r1]

    @ --- Bits 1, 2, 3 -> PA7, PA6, PA5 ---
    @ Optimization: Load GPIOA Base Address ONCE for efficiency
    ldr r1, =GPIOA_BSRR
    
    @ Bit 1 (PA7)
    tst r0, #2
    beq bit1_low
    mov r2, #(1 << LED_BIT1_PIN)
    b bit1_done
bit1_low:
    mov r2, #(1 << (LED_BIT1_PIN + 16))
bit1_done:
    str r2, [r1]

    @ Bit 2 (PA6)
    tst r0, #4
    beq bit2_low
    mov r2, #(1 << LED_BIT2_PIN)
    b bit2_done
bit2_low:
    mov r2, #(1 << (LED_BIT2_PIN + 16))
bit2_done:
    str r2, [r1]

    @ Bit 3 (PA5)
    tst r0, #8
    beq bit3_low
    mov r2, #(1 << LED_BIT3_PIN)
    b bit3_done
bit3_low:
    mov r2, #(1 << (LED_BIT3_PIN + 16))
bit3_done:
    str r2, [r1]

    pop {r1, r2, pc}

@ --------------------------------------------------------------------------------------
@ Function: read_columns_optimized
@ --------------------------------------------------------------------------------------
@ Purpose: Checks all 4 Column Pins to see if any are LOW.
@ Returns: R0 = Column Bit (if pressed) or NO_KEY (0).
@ --------------------------------------------------------------------------------------
read_columns_optimized:
    @ Check Col 0 (PB4), Col 1 (PB5), Col 2 (PB3) -> GPIOB
    ldr r1, =GPIOB_IDR
    ldr r2, [r1]

    tst r2, #(1 << COL0_PIN)
    beq ret_col0
    tst r2, #(1 << COL1_PIN)
    beq ret_col1
    tst r2, #(1 << COL2_PIN)
    beq ret_col2

    @ Check Col 3 (PA10) -> GPIOA
    ldr r1, =GPIOA_IDR
    ldr r2, [r1]
    tst r2, #(1 << COL3_PIN)
    beq ret_col3

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
ret_col3: 
        mov r0, #COL3_BIT
        bx lr

@ --------------------------------------------------------------------------------------
@ Function: decode_key_lookup
@ --------------------------------------------------------------------------------------
@ Purpose: Converts Scan Code to Numeric Value using a Lookup Table.
@ --------------------------------------------------------------------------------------
decode_key_lookup:
    push {r1, r2, lr}
    ldr r1, =Keypad_Lookup_Table
    mov r2, #0

decode_loop:
    ldrb r3, [r1, r2]
    cmp r3, #0
    beq decode_fail                 @ End of table reached

    cmp r3, r0
    beq decode_match                @ Found match!

    add r2, r2, #2                  @ Move to next entry (2 bytes per entry)
    b decode_loop

decode_match:
    add r2, r2, #1                  @ Value is in the next byte
    ldrb r0, [r1, r2]
    pop {r1, r2, pc}

decode_fail:
    mov r0, #0xFF
    pop {r1, r2, pc}

@ --------------------------------------------------------------------------------------
@ Function: delay_cycles
@ --------------------------------------------------------------------------------------
@ Purpose: Simple delay loop.
@ Input:   R0 = Number of cycles to wait
@ --------------------------------------------------------------------------------------
delay_cycles:
    subs r0, r0, #1
    bne delay_cycles
    bx lr

@ ====================================================================================== @
@ STEP 5: DATA SECTION
@ ====================================================================================== @
.section .data
.align 2

Keypad_Lookup_Table:
    @ Format: .byte SCAN_CODE, NUMERIC_VALUE
    @ Row 0
    .byte 0x11, 1
    .byte 0x12, 2
    .byte 0x14, 3
    .byte 0x18, 10
    @ Row 1
    .byte 0x21, 4
    .byte 0x22, 5
    .byte 0x24, 6
    .byte 0x28, 11
    @ Row 2
    .byte 0x41, 7
    .byte 0x42, 8
    .byte 0x44, 9
    .byte 0x48, 12
    @ Row 3
    .byte 0x81, 14
    .byte 0x82, 0
    .byte 0x84, 15
    .byte 0x88, 13

    .byte 0, 0      @ Null Terminator

.end