@ ====================================================================================== @
@                                 LEDS DRIVER DEFINITIONS
@ ====================================================================================== @
@ This file contains the Pin Definitions and Configuration Masks for the 4 LEDs
@ used to display the binary value of the pressed key.
@
@ Connections (Arduino Headers):
@ - LED Bit 0 (LSB): D10 = PB6
@ - LED Bit 1      : D11 = PA7
@ - LED Bit 2      : D12 = PA6
@ - LED Bit 3 (MSB): D13 = PA5 (Also On-Board LED)
@ ====================================================================================== @

@ -------------------------------------------------------------------------------------- @
@ Pin Definitions
@ -------------------------------------------------------------------------------------- @
.equ LED_BIT0_PIN,          6   @ PB6
.equ LED_BIT1_PIN,          7   @ PA7
.equ LED_BIT2_PIN,          6   @ PA6
.equ LED_BIT3_PIN,          5   @ PA5

@ -------------------------------------------------------------------------------------- @
@ MODER (Mode Register) Configuration Masks
@ -------------------------------------------------------------------------------------- @
@ We need to configure these pins as OUTPUTS (01).

@ --- GPIOB (PB6) ---
.equ GPIO_MODER_B6_MASK,    (0b11 << 12)      @ Mask for PB6
.equ GPIO_MODER_B6_OUTPUT,  (0b01 << 12)      @ Set PB6 to Output

@ --- GPIOA (PA7, PA6, PA5) ---
.equ GPIO_MODER_A7_MASK,    (0b11 << 14)      @ Mask for PA7
.equ GPIO_MODER_A7_OUTPUT,  (0b01 << 14)      @ Set PA7 to Output

.equ GPIO_MODER_A6_MASK,    (0b11 << 12)      @ Mask for PA6
.equ GPIO_MODER_A6_OUTPUT,  (0b01 << 12)      @ Set PA6 to Output

.equ GPIO_MODER_A5_MASK,    (0b11 << 10)      @ Mask for PA5
.equ GPIO_MODER_A5_OUTPUT,  (0b01 << 10)      @ Set PA5 to Output
