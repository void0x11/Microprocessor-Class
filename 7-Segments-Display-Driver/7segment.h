//7segment output drivers
//Segment A (top): 			D10=PB6
//Segment B (top right):	D11 = PA7
//Segment C (bottom right): D12 = PA6
//Segmend D (bottom):		D13 = PA5
//Segment E (bottom left):	D2 = PA10
//Segment F (top left):		D6 = PB10
//Segment G (middle):		D14 = PB9

//A (Orange, D10), B (Brown, D11), C (Yellow, D12), D (Green, D13), E (Blue, D2), F(Purple, D6), G(Black, D14), Ground (Grey)

//Pin definitions:
.equ SEGMENT_A_PIN,			6
.equ SEGMENT_B_PIN,			7
.equ SEGMENT_C_PIN,			6
.equ SEGMENT_D_PIN,			5
.equ SEGMENT_E_PIN,			10
.equ SEGMENT_F_PIN,			10
.equ SEGMENT_G_PIN,			9

//Moder Configuration Masks
//Segment A
.equ GPIO_MODER_B6_MASK,		(0b11 << 12)
.equ GPIO_MODER_B6_OUTPUT,		(0b01 << 12)
//Segment B
.equ GPIO_MODER_A7_MASK,		(0b11 << 14)
.equ GPIO_MODER_A7_OUTPUT,		(0b01 << 14)
//Segment C
.equ GPIO_MODER_A6_MASK,		(0b11 << 12)
.equ GPIO_MODER_A6_OUTPUT,		(0b01 << 12)
//Segment D
.equ GPIO_MODER_A5_MASK,		(0b11 << 10)
.equ GPIO_MODER_A5_OUTPUT,		(0b01 << 10)
//Segment E
.equ GPIO_MODER_A10_MASK,		(0b11 << 20)
.equ GPIO_MODER_A10_OUTPUT,		(0b01 << 20)
//Segment F
.equ GPIO_MODER_B10_MASK,		(0b11 << 20)
.equ GPIO_MODER_B10_OUTPUT,		(0b01 << 20)
//Segment G
.equ GPIO_MODER_B9_MASK,		(0b11 << 18)
.equ GPIO_MODER_B9_OUTPUT,		(0b01 << 18)
