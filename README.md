# RISC-V Single-Cycle CPU – FPGA Implementation (DE1-SoC)

This project contains a custom RISC-V single-cycle CPU written in SystemVerilog, along with an FPGA integration targeting the DE1-SoC (Cyclone V).  
The repository is organized into two main parts: the original CPU implementation and a separate branch containing the FPGA integration layer.

## Features
- Full RV32I instruction support (R, I, S, B, U, and J types)
- Synchronous data memory with byte, halfword, and word access
- Load operations with correct sign or zero extension
- Seven-segment display output for visualizing CPU execution on hardware
- Button-based step execution (manual clocking) with debouncing
- Modular design: the CPU core remains untouched; the FPGA wrapper manages IO
- The instruction are provided by with `program.hex` file.

## Repository Structure
- `src/` — Source files for the CPU (SystemVerilog) and FPGA wrapper modules, pin assignments, and hardware-specific files (only in the `FPGA_Implementation` branch)  
- `tb/` — Testbenches for simulation  
- `docs/notes.md` — Design decisions, observations, and implementation details  
- `README.md` — Project-level documentation

## FPGA Implementation (DE1-SoC)
The FPGA integration includes:
- A top-level wrapper that instantiates the CPU
- Debounce logic for push-buttons
- Seven-segment display controller for showing:
  - Register write-back values (R, I, U, and J instructions)
  - Store data for S-type instructions
  - Branch target addresses for B-type instructions

### Running on the FPGA
1. Create a Quartus project (e.g., inside `fpga_cpu/`).
2. Add all files from the `src/` directory.
3. Assign the pins according to the DE1-SoC documentation, or use the provided `.qsf` pin assignment file.
4. Compile the project.
5. Program the board with the generated `.sof` file.
6. Use `KEY[0]` to step the CPU one cycle at a time.  
   Use `KEY[1]` to toggle between lower and upper 24/32 bits when the result exceeds the display capacity.
7. Observe outputs on the seven-segment displays.

## Simulation
All testbenches are located in the `tb/` directory.  
You can run them using ModelSim, Questa, or Icarus Verilog.

## Requirements
- A SystemVerilog-compatible simulator  
- Quartus Prime Lite or Standard  
- A DE1-SoC board (Cyclone V)

## Using Icarus Verilog
This project was developed using Icarus Verilog.  
You can install it for Windows here:  
https://bleyer.org/icarus/

There is also a VSCode extension for waveform viewing called **WaveTracer**.

## Compile and Run (ICARUS)
- Example commands: `iverilog -g2012 -o sim/output.out tb/testbench.sv src/module.sv`
- Compile full CPU: `iverilog -g2012 -o sim/CPU_top_tb.out tb/CPU_top_tb.sv src/*.sv`
- Run: `vvp sim/CPU_top_tb.out`


**Note:** Commands may vary depending on your Icarus version (this project was developed with Icarus Verilog 12.0).

## License
MIT License.

