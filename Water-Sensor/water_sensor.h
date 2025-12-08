/*
 * water_sensor.h
 *
 *  Created on: Dec 8, 2024
 *      Author: Ahmed Amin
 *
 *  DESCRIPTION:
 *  This file contains the driver logic for the Water Sensor.
 *  
 *  WHAT IS AN ADC?
 *  - ADC stands for "Analog-to-Digital Converter".
 *  - Real World signals (like water level, temperature, sound) are ANALOG (continuous voltage).
 *  - Computers (like STM32) are DIGITAL (0s and 1s).
 *  - The ADC is a bridge: It measures the Voltage (0V to 3.3V) and gives us a Number (0 to 4095).
 *    * 0V   -> 0
 *    * 1.6V -> ~2048
 *    * 3.3V -> 4095
 */

@ ------------------------------------------------------------------------------
@ ADC REGISTERS ADDRESSES
@ We need to talk to specific hardware "registers" to control the ADC.
@ ------------------------------------------------------------------------------
.equ ADC1_BASE,        0x40012000

@ 1. Status Register (SR): Tells us "Status" information.
@    Check this to see if the conversion is finished (EOC bit).
.equ ADC_SR,           (ADC1_BASE + 0x00)

@ 2. Control Register 2 (CR2): The "On Switch" and "Start Button".
@    - ADON bit: Turns the ADC hardware ON.
@    - SWSTART bit: Tells ADC to "Start Measuring Now".
.equ ADC_CR2,          (ADC1_BASE + 0x08)

@ 3. Sequence Register 3 (SQR3): The "Channel Selector".
@    The ADC has many channels. We use this to say "Measure Channel 7 first".
.equ ADC_SQR3,         (ADC1_BASE + 0x34)

@ 4. Data Register (DR): The "Result Box".
@    Once conversion is done, the digital number (0-4095) is stored here.
.equ ADC_DR,           (ADC1_BASE + 0x4C)


@ ------------------------------------------------------------------------------
@ BIT DEFINITIONS (Masks)
@ ------------------------------------------------------------------------------
.equ ADC_ADON,         (1 << 0)   @ Enable bit (Power On)
.equ ADC_SWSTART,      (1 << 30)  @ Start Conversion bit
.equ ADC_EOC,          (1 << 1)   @ End Of Conversion flag (1 = Done)
.equ ADC_CH7,          7          @ The Water Sensor is on PA7, which maps to Channel 7


@ ------------------------------------------------------------------------------
@ Subroutine: SENSOR_INIT
@ Description: Prepares the hardware for reading.
@ 
@ STEPS EXPLAINED:
@ 1. Enable Clocks: You must give power/clock to the Peripherals (GPIOA and ADC1)
@    before you can talk to them.
@
@ 2. Set Analog Mode: Normal pins are "Digital" (0 or 1). We must tell the pin
@    to be "Analog" so it doesn't mess up the delicate voltage signal.
@ 3. Select Channel: Tell the ADC "I want to read Channel 7".
@
@ 4. Power On: Flip the "ADON" switch to turn the ADC circuitry ON.
@ ------------------------------------------------------------------------------
SENSOR_INIT:
    push {r0, r1, lr}

    @ 1. Enable Clocks for GPIO-A and ADC-1
    ldr r0, =RCC_AHB1ENR   @ GPIO Clock Control
    ldr r1, [r0]
    orr r1, r1, #GPIOA_EN  @ Turn on GPIO A
    str r1, [r0]

    ldr r0, =RCC_APB2ENR   @ ADC Clock Control
    ldr r1, [r0]
    orr r1, r1, #ADC1_EN   @ Turn on ADC 1
    str r1, [r0]

    @ 2. Configure Pin PA7 as ANALOG Mode (Binary: 11)
    @ This disconnects the digital logic so we can measure pure voltage.
    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    orr r1, r1, #(MODE_ANALOG << (SENSOR_PIN * 2))
    str r1, [r0]

    @ 3. Select Channel 7 in the Sequence Register (SQR3)
    ldr r0, =ADC_SQR3
    mov r1, #ADC_CH7       @ Channel 7
    str r1, [r0]

    @ 4. Turn ADC ON (Set ADON bit)
    ldr r0, =ADC_CR2
    ldr r1, [r0]
    orr r1, r1, #ADC_ADON
    str r1, [r0]

    @ 5. Stabilization Delay (~10us)
    @ The ADC needs a moment to wake up and stabilize its internal voltage.
    @ We spin in a small loop to wait.
    mov r0, #1000
Init_Delay_Loop:
    subs r0, r0, #1        @ Subtract 1
    bne Init_Delay_Loop    @ If not zero, go back

    pop {r0, r1, pc}


@ ------------------------------------------------------------------------------
@ Subroutine: READ_WATER_LEVEL
@ Description: Takes one measurement from the sensor.
@ 
@ THE PROCESS (Polling):
@ 1. "Go!": Set SWSTART bit to begin measuring.
@ 2. "Are you done yet?": The ADC takes time (cycles) to measure.
@     We check the EOC (End of Conversion) bit in a loop.
@     If EOC is 0 -> Not done. Wait.
@     If EOC is 1 -> Done! Proceed.
@ 3. "Give me the number": Read the result from the Data Register.
@ ------------------------------------------------------------------------------
READ_WATER_LEVEL:
    push {r1, r2, lr}      @ Save scratch registers

    @ 1. START CONVERSION (Set SWSTART bit)
    ldr r2, =ADC_CR2
    ldr r1, [r2]
    orr r1, r1, #ADC_SWSTART
    str r1, [r2]

    @ 2. WAIT FOR COMPLETION (Poll EOC bit)
    ldr r2, =ADC_SR        @ Status Register Address
Wait_EOC:
    ldr r1, [r2]           @ Read Status
    tst r1, #ADC_EOC       @ Check if Bit 1 (EOC) is set
    beq Wait_EOC           @ If 0 (Z flag set), NOT done. Loop back.

    @ 3. READ RESULT (From Data Register)
    ldr r2, =ADC_DR
    ldr r0, [r2]           @ Load measurement (0-4095) into R0

    pop {r1, r2, pc}       @ Return with R0 holding the value
