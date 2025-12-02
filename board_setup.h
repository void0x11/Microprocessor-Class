@ ====================================================================================== @
@                                 STM32F4xx DEFINITIONS
@ ====================================================================================== @
@ This file contains the Register Addresses and Configuration Masks for the STM32F4xx.
@ ====================================================================================== @

@ ====================================================================================== @
@ 1. RCC (Reset and Clock Control) Register Definitions
@ ====================================================================================== @
@ We need to enable the clock for GPIO Port A and Port B before we can use them.
@ If the clock is not enabled, writing to GPIO registers will have no effect.

.equ RCC_BASE, 				(0x40023800)          @ Base Address of RCC
.equ RCC_AHB1ENR, 			(RCC_BASE + 0x30)     @ AHB1 Peripheral Clock Enable Register
.equ RCC_AHB1ENR_GPIOAEN, 	(1 << 0)              @ Bit 0: Enable Clock for GPIOA
.equ RCC_AHB1ENR_GPIOBEN, 	(1 << 1)              @ Bit 1: Enable Clock for GPIOB
.equ RCC_AHB1ENR_GPIOCEN, 	(1 << 2)              @ Bit 2: Enable Clock for GPIOC

@ ====================================================================================== @
@ 2. GPIOA (General Purpose I/O Port A) Register Definitions
@ ====================================================================================== @
@ Each GPIO Port has a set of registers to control its pins.

.equ GPIOA_BASE,			(0x40020000)          @ Base Address of GPIOA
.equ GPIOA_MODER,			(GPIOA_BASE + 0x00)   @ Mode Register (Input/Output/Alt Func)
.equ GPIOA_PUPDR,			(GPIOA_BASE + 0x0C)   @ Pull-up/Pull-down Register
.equ GPIOA_IDR, 			(GPIOA_BASE + 0x10)   @ Input Data Register (Read Pin State)
.equ GPIOA_ODR, 			(GPIOA_BASE + 0x14)   @ Output Data Register (Write Pin State)
.equ GPIOA_BSRR, 			(GPIOA_BASE + 0x18)   @ Bit Set/Reset Register (Write Pin State)

@ ====================================================================================== @
@ 3. GPIOB (General Purpose I/O Port B) Register Definitions
@ ====================================================================================== @

.equ GPIOB_BASE,			(0x40020400)          @ Base Address of GPIOB
.equ GPIOB_MODER,			(GPIOB_BASE + 0x00)   @ Mode Register
.equ GPIOB_PUPDR,			(GPIOB_BASE + 0x0C)   @ Pull-up/Pull-down Register
.equ GPIOB_IDR, 			(GPIOB_BASE + 0x10)   @ Input Data Register
.equ GPIOB_BSRR, 			(GPIOB_BASE + 0x18)   @ Bit Set/Reset Register

@ ====================================================================================== @
@ 4. GPIOC (General Purpose I/O Port C) Register Definitions
@ ====================================================================================== @

.equ GPIOC_BASE,			(0x40020800)          @ Base Address of GPIOC
.equ GPIOC_MODER,			(GPIOC_BASE + 0x00)   @ Mode Register
.equ GPIOC_ODR, 			(GPIOC_BASE + 0x14)   @ Output Data Register
.equ GPIOC_BSRR, 			(GPIOC_BASE + 0x18)   @ Bit Set/Reset Register

@ ====================================================================================== @
@ ====================================================================================== @
