//Step 1: Enable GPIO clock
.equ RCC_BASE,				(0x40023800)		//Base address for RCC
.equ RCC_AHB1ENR,			(RCC_BASE + 0X30)	//Enables AHB1
.equ RCC_AHB1ENR_GPIOAEN,	(1 << 0)			//Enables clock for GPIOA
.equ RCC_AHB1ENR_GPIOBEN,	(1 << 1)			//Enables clock for GPIOB
.equ RCC_AHB1ENR_GPIOCEN,	(1 << 2)			//Enables clock for GPIOC


//Step 2: Configure I/O Moder
//Step 3: Configure PUPDR (for input only)
//Step 4: BSRR Set/Reset
//Port A:
.equ GPIOA_BASE,			(0x40020000)          //Base address for GPIOA
.equ GPIOA_MODER,			(GPIOA_BASE + 0x00)   //Moder for GPIOA
.equ GPIOA_PUPDR,			(GPIOA_BASE + 0x0C)   //Pullup/Pulldown resistor for GPIOA
.equ GPIOA_IDR, 			(GPIOA_BASE + 0x10)   //Enables input
.equ GPIOA_ODR, 			(GPIOA_BASE + 0x14)   //Enables output
.equ GPIOA_BSRR, 			(GPIOA_BASE + 0x18)   //Bit set/reset register

//Port B:
.equ GPIOB_BASE,			(0x40020400)          //Base address for GPIOB
.equ GPIOB_MODER,			(GPIOB_BASE + 0x00)   //Moder for GPIOB
.equ GPIOB_PUPDR,			(GPIOB_BASE + 0x0C)   //Pullup/Pulldown resistor for GPIOB
.equ GPIOB_IDR, 			(GPIOB_BASE + 0x10)   //Enables input
.equ GPIOB_ODR, 			(GPIOB_BASE + 0x14)   //Enables output
.equ GPIOB_BSRR, 			(GPIOB_BASE + 0x18)   //Bit set/reset register

//Port C (doesn't need PUPDR):
.equ GPIOC_BASE,			(0x40020800)          //Base address for GPIOC
.equ GPIOC_MODER,			(GPIOC_BASE + 0x00)   //Moder for GPIOC
.equ GPIOC_ODR, 			(GPIOC_BASE + 0x14)   //Enables output
.equ GPIOC_BSRR, 			(GPIOC_BASE + 0x18)   //Bit set/reset register
