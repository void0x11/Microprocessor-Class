//Driver for keypad:
//Keypad is connected by rows and columns. This driver takes the input from the keypad and registers it as a 3x3 matrix

//The rows need constant output coming from the microcontroller into the keypad
//The circuit will short when a button is pushed and the microcontroller will recieve a signal from the columns
//Configuration mask maping:
//-------------------------------------------------------------------------------------------------*
//OUTPUTS (Rows):   D9 = PC7, D8 = PA9, D7 = PA8 	  											   *
//INPUTS (Columns): D5 = PB4, D4 = PB5, D3 = PB3								   				   *
//-------------------------------------------------------------------------------------------------*
//Rows (outputs):
.equ ROW0_PIN,		7
.equ ROW1_PIN,		9
.equ ROW2_PIN,		8

//Columns (inputs):
.equ COL0_PIN, 		4
.equ COL1_PIN, 		5
.equ COL2_PIN, 		3

//MODER Configuration Masks:
//Rows (outputs):
//PC7 (Row 0)
.equ GPIO_MODER_C7_MASK,	(0b11 << 14)
.equ GPIO_MODER_C7_OUTPUT,	(0b01 << 14)
//PA9 (Row 1)
.equ GPIO_MODER_A9_MASK,	(0b11 << 18)
.equ GPIO_MODER_A9_OUTPUT,	(0b01 << 18)
//PA8 (Row 2)
.equ GPIO_MODER_A8_MASK,	(0b11 << 16)
.equ GPIO_MODER_A8_OUTPUT,	(0b01 << 16)

//Columns (inputs):
//The columns do not need the output MODER configuration
//PB4 (Column 0)
.equ GPIO_MODER_B4_MASK,	(0b11 << 8)
//PB5 (Column 1)
.equ GPIO_MODER_B5_MASK,	(0b11 << 10)
//PB3 (Column 2)
.equ GPIO_MODER_B3_MASK,	(0b11 << 6)

//Pull-up/Pull-down Register config masks:
//PB4 (Col 0)
.equ GPIO_PUPDR_B4_MASK,    (0b11 << 8)
.equ GPIO_PUPDR_B4_PULLUP,  (0b01 << 8)

//PB5 (Col 1)
.equ GPIO_PUPDR_B5_MASK,    (0b11 << 10)
.equ GPIO_PUPDR_B5_PULLUP,  (0b01 << 10)

//PB3 (Col 2)
.equ GPIO_PUPDR_B3_MASK,    (0b11 << 6)
.equ GPIO_PUPDR_B3_PULLUP,  (0b01 << 6)

//Keypad Mapping
.equ ROW0_BIT,              0b0001
.equ ROW1_BIT,              0b0010
.equ ROW2_BIT,              0b0100

.equ COL0_BIT,              0b0001
.equ COL1_BIT,              0b0010
.equ COL2_BIT,              0b0100

.equ NO_KEY,                0x00
