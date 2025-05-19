# Simon Game on FPGA

This project implements a classic **Simon Game** using Verilog for FPGA development. 
The game generates a sequence of LED flashes which the player must repeat using switches. 

## Features

- Random sequence generation.
- LED pattern display.
- User input via switches.
- Success/failure indication using a 7-segment display.

## Files

- `Simon_game.v`: Main Verilog module implementing the game logic.

## Requirements

- FPGA development board (e.g., Digilent Basys 3 or similar).
- Eight input switches (for user input).
- Eight LEDs (for sequence display).
- Optional 7-segment display for feedback.

## Usage

1. **Compile and program** the Verilog code onto the FPGA board using your preferred tool (Vivado, Quartus, etc.).
2. **Reset the game** using the designated reset button (if implemented).
3. The game **displays an LED pattern** randomly.
4. The player must **repeat the pattern** using the switches.

## Controls

| Component         | Purpose                             |

| LEDs              | Show the generated sequence         |
| Switches          | Used to repeat the pattern          |
| 7-Segment Display | Show correct or incorrect response  |

## How It Works

The system operates in a simple state machine:
1. **Idle** – Wait for user to start. (activate the code on the board)
2. **Generate** – random sequence of LEDs.
3. **Display** – Show the sequence to the user.
4. **Input** – Accept user input.
5. **Check** – Compare user input to the sequence.
6. **Win/Fail** – Update display based on input correctness.

## Options for further implementation

- Add levels to the game and display for it.
- Add scoring or high score tracking.
