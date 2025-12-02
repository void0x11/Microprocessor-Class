@ ====================================================================================== @
@                                 KEYPAD DRIVER DEFINITIONS
@ ====================================================================================== @
@ This file contains the Pin Definitions and Configuration Masks
@ needed to interface a 4x4 Keypad with the STM32 Microcontroller.
@
@ The Keypad is connected as follows:
@ - Rows    (Outputs): Driven High/Low to scan the keypad.
@ - Columns (Inputs) : Read to detect key presses.
@ ====================================================================================== @


@ ====================================================================================== @
@ 1. PIN DEFINITIONS (Mapping to CN9 Connector)
@ ====================================================================================== @
@ The Keypad pins are connected to the Nucleo board's CN9 connector (Arduino Headers).
@ We map these "D" pins to the actual STM32 GPIO pins.
@
@ NEW MAPPING (D2 - D9):
@ Col 3 = D2 (PA10), Col 2 = D3 (PB3), Col 1 = D4 (PB5), Col 0 = D5 (PB4)
@ Row 3 = D6 (PB10), Row 2 = D7 (PA8), Row 1 = D8 (PA9), Row 0 = D9 (PC7)
@

@ -------------------------------------------------------------------------------------- @
@ Rows (Outputs) - Connected to pins 8,7,6,5 on keypad
@ -------------------------------------------------------------------------------------- @
.equ ROW0_PIN, 				7 	@ D9 = PC7  (Row 0)
.equ ROW1_PIN, 				9   @ D8 = PA9  (Row 1)
.equ ROW2_PIN, 				8	@ D7 = PA8  (Row 2)
.equ ROW3_PIN, 				10	@ D6 = PB10 (Row 3)

@ -------------------------------------------------------------------------------------- @
@ Columns (Inputs) - Connected to pins 4,3,2,1 on keypad
@ -------------------------------------------------------------------------------------- @
.equ COL0_PIN, 				4   @ D5 = PB4  (Col 0)
.equ COL1_PIN, 				5   @ D4 = PB5  (Col 1)
.equ COL2_PIN, 				3   @ D3 = PB3  (Col 2)
.equ COL3_PIN, 				10  @ D2 = PA10 (Col 3)


@ ====================================================================================== @
@ 2. MODER (Mode Register) CONFIGURATION MASKS
@ ====================================================================================== @

@ -------------------------------------------------------------------------------------- @
@ Rows (Outputs)
@ -------------------------------------------------------------------------------------- @
@ PC7 (Row 0)
.equ GPIO_MODER_C7_MASK,    (0b11 << 14)
.equ GPIO_MODER_C7_OUTPUT,  (0b01 << 14)

@ PA9 (Row 1)
.equ GPIO_MODER_A9_MASK,    (0b11 << 18)
.equ GPIO_MODER_A9_OUTPUT,  (0b01 << 18)

@ PA8 (Row 2)
.equ GPIO_MODER_A8_MASK,    (0b11 << 16)
.equ GPIO_MODER_A8_OUTPUT,  (0b01 << 16)

@ PB10 (Row 3)
.equ GPIO_MODER_B10_MASK,   (0b11 << 20)
.equ GPIO_MODER_B10_OUTPUT, (0b01 << 20)

@ -------------------------------------------------------------------------------------- @
@ Columns (Inputs)
@ -------------------------------------------------------------------------------------- @
@ PB4 (Col 0)
.equ GPIO_MODER_B4_MASK,    (0b11 << 8)

@ PB5 (Col 1)
.equ GPIO_MODER_B5_MASK,    (0b11 << 10)

@ PB3 (Col 2)
.equ GPIO_MODER_B3_MASK,    (0b11 << 6)

@ PA10 (Col 3)
.equ GPIO_MODER_A10_MASK,   (0b11 << 20)


@ ====================================================================================== @
@ 3. PUPDR (Pull-up/Pull-down Register) CONFIGURATION MASKS
@ ====================================================================================== @

@ PB4 (Col 0)
.equ GPIO_PUPDR_B4_MASK,    (0b11 << 8)
.equ GPIO_PUPDR_B4_PULLUP,  (0b01 << 8)

@ PB5 (Col 1)
.equ GPIO_PUPDR_B5_MASK,    (0b11 << 10)
.equ GPIO_PUPDR_B5_PULLUP,  (0b01 << 10)

@ PB3 (Col 2)
.equ GPIO_PUPDR_B3_MASK,    (0b11 << 6)
.equ GPIO_PUPDR_B3_PULLUP,  (0b01 << 6)

@ PA10 (Col 3)
.equ GPIO_PUPDR_A10_MASK,   (0b11 << 20)
.equ GPIO_PUPDR_A10_PULLUP, (0b01 << 20)


@ ====================================================================================== @
@ 4. KEYPAD MAPPING AND ENCODING
@ ====================================================================================== @

@ -------------------------------------------------------------------------------------- @
@ One-Hot Encoding Bit Values
@ -------------------------------------------------------------------------------------- @
.equ ROW0_BIT,              0b0001
.equ ROW1_BIT,              0b0010
.equ ROW2_BIT,              0b0100
.equ ROW3_BIT,              0b1000

.equ COL0_BIT,              0b0001
.equ COL1_BIT,              0b0010
.equ COL2_BIT,              0b0100
.equ COL3_BIT,              0b1000

.equ NO_KEY,                0x00
