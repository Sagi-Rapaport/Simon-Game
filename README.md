# Simon Game on FPGA (DE10-Lite)

This project implements a classic **Simon Game** using SystemVerilog for FPGA development. 

The game generates a sequence of LED flashes and display them to the player which need to repeat the sequence accurately by using switches. 

## Features

- Random LED sequence generation (LFSR).
- LED pattern display.
- User input via switches.
- Success/failure indication using a 7-segment display (feedback).

## Files

- `Simon_game.sv`: Main SystemVerilog module implementing the game logic by FSM, sequence comparison, and input synchronization.
- `LFSR.sv`: A secondery module that intantiate in the main Simon_Game module implementing random LED sequence generation by using LFSR.

## Controls

| Component <---> Purpose |

| reset (switch)    <---> Start or restart the game           |

| LEDs              <---> Show the random generated sequence  |

| Switches          <---> Used to repeat the LED pattern      |

| 7-Segment Display <---> Show correct or incorrect feedback  |

## How It Works

The system operates in a Finite State Machine:
1. **START** – Wait for the player to start. (reset switch need to turn on and then turn off)
2. **GENERATE_LED** – generate a random sequence of LEDs.
3. **DISPLAY** – Show the LED sequence to the player.
4. **INPUT** – Accept player input by using switches.
5. **CHECK** – Compare player input (sw_sequence) to the random LED sequence.
6. **DONE** – Update feedback display based on input correctness. (waiting for reset to restart the game)

## Requirements for implementation

- FPGA development board (e.g., Digilent Basys 3 or similar).
- Eight LEDs (for sequence display).
- Eight input switches (for user input).
- Optional: 7-segment display for feedback.

## Usage

1. **Compile and program** the SystemVerilog code onto the FPGA board using your preferred tool (Vivado, Quartus, etc.).
2. **Reset the game** using the designated reset button (if implemented).
3. The game **displays an LED pattern** randomly.
4. The player need to **repeat the pattern** by using the switches.
5. The FPGA board will **display feedback** as a result of moving the switches (1- correct / 0- incorrect).

## Options for further implementation

- Add levels to the game and display for it.
- Add scoring or high score tracking.
- Add display for number of errors.
