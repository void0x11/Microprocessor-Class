# 4x4 Keypad Scanner - Project Documentation

## What Does This Project Do?

This project reads button presses from a 4x4 keypad and displays the number (0-15) on 4 LEDs using **binary representation**.

**Example:** When you press the "5" button, the LEDs will show: `0101` (which is 5 in binary).

---

## Hardware You Need

1. **STM32 Nucleo-64 Board** (F401RE or F446RE)
2. **4x4 Matrix Keypad**
3. **4 LEDs** (any color)
4. **4 Resistors** (220Ω - 330Ω for the LEDs)
5. **Jumper Wires**

---

## Wiring Guide

### Step 1: Connect the Keypad

Your keypad has 8 pins (4 for rows, 4 for columns). Connect them to the Nucleo board like this:

| Keypad Pin | Wire To | STM32 Pin | Type |
|------------|---------|-----------|------|
| **Column 3** | D2 | PA10 | Input |
| **Column 2** | D3 | PB3 | Input |
| **Column 1** | D4 | PB5 | Input |
| **Column 0** | D5 | PB4 | Input |
| **Row 3** | D6 | PB10 | Output |
| **Row 2** | D7 | PA8 | Output |
| **Row 1** | D8 | PA9 | Output |
| **Row 0** | D9 | PC7 | Output |

> **Important:** Do NOT use D0 or D1! These pins are used by the debugger and will not work correctly.

### Step 2: Connect the LEDs

Each LED needs a resistor (220Ω) in series. Connect them like this:

| LED Purpose | Wire To | STM32 Pin | Represents |
|-------------|---------|-----------|------------|
| **Bit 0 (Ones)** | D10 | PB6 | 1 |
| **Bit 1 (Twos)** | D11 | PA7 | 2 |
| **Bit 2 (Fours)** | D12 | PA6 | 4 |
| **Bit 3 (Eights)** | D13 | PA5 | 8 |

**LED Wiring:**
```
Nucleo Pin → Resistor (220Ω) → LED (+) → LED (-) → GND
```

> **💡 Note:** D13 is also the green LED on the Nucleo board. It will light up when you press keys 8-15.

---

## How Does It Work?

### The Keypad Scanning Process

A matrix keypad works like a grid. When you press a button, it connects a **row** to a **column**.

**Our Strategy:**
1. Turn ON one row at a time (make it LOW voltage)
2. Check all columns to see if any are LOW
3. If a column is LOW, we found which button is pressed!
4. Repeat for all 4 rows

**Example:**
- If Row 1 is LOW and Column 2 is LOW → Button "5" is pressed

### The Code Flow

```
START
  ↓
1. Setup (Turn on clocks, configure pins)
  ↓
2. LOOP FOREVER:
   ↓
   Scan Row 0 → Check Columns → Any key? → Yes → Show on LEDs
   Scan Row 1 → Check Columns → Any key? → Yes → Show on LEDs
   Scan Row 2 → Check Columns → Any key? → Yes → Show on LEDs
   Scan Row 3 → Check Columns → Any key? → Yes → Show on LEDs
   ↓
   Go back to start of loop
```

---

## Understanding the Code Files

### 1. `main.s` - The Main Program
This is where everything happens. It has 5 main sections:
- **STEP 1:** Turn on the hardware (clocks, pins)
- **STEP 2:** The scanning loop (checks for button presses)
- **STEP 3:** Process the key press (figure out which button)
- **STEP 4:** Helper functions (reusable code blocks)
- **STEP 5:** Data (the lookup table)

### 2. `keypad.h` - Keypad Pin Definitions
Defines which pins connect to which rows/columns.

### 3. `leds.h` - LED Pin Definitions
Defines which pins connect to the 4 LEDs.

### 4. `board_setup.h` - Hardware Addresses
Defines the memory addresses for GPIO registers.

---

## Testing Your Project

### Test 1: Basic Functionality
Press each button on the keypad. The LEDs should show the correct binary number.

| Button | Binary | LED Pattern (D13 D12 D11 D10) |
|--------|--------|-------------------------------|
| 0 | 0000 | OFF OFF OFF OFF |
| 1 | 0001 | OFF OFF OFF ON |
| 5 | 0101 | OFF ON OFF ON |
| 9 | 1001 | ON OFF OFF ON |
| 15 (F) | 1111 | ON ON ON ON |

### Test 2: Debouncing
Press and hold a button. The number should only appear once (not flicker).

---

## Common Problems & Solutions

### Problem 1: Some buttons don't work
- **Check your wiring** - Make sure all 8 keypad wires are connected correctly
- **Check for loose connections** - Push the wires firmly into the breadboard

### Problem 2: LEDs don't light up
- **Check LED polarity** - The long leg (+) should connect to the resistor
- **Check resistor values** - Should be 220Ω to 330Ω
- **Test with the on-board LED** - Press buttons 8-15, D13 should light up

### Problem 3: Wrong numbers appear
- **Check your lookup table** - Make sure the scan codes match the keypad layout
- **Check column order** - Columns might be reversed on your keypad

---

## Learning Objectives

By completing this project, you will learn:
- ✅ How to configure GPIO pins (Input vs Output)
- ✅ How to use Pull-Up resistors
- ✅ How matrix scanning works
- ✅ How to read hardware registers
- ✅ How to write bare-metal firmware in Assembly
- ✅ How to debug hardware conflicts

---

## Next Steps

Once you have this working, try these challenges:
1. **Add a 7-segment display** to show the number in decimal
2. **Add sound** - Make a beep when a button is pressed
3. **Implement a calculator** - Use the keypad for basic math
4. **Port to C** - Rewrite the same logic in C language
