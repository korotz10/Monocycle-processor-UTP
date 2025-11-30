# Design Notes – RISC-V Single-Cycle CPU & FPGA Integration

## Overview

These notes summarize the key design decisions, implementation details, and constraints encountered during the development of the RISC-V single-cycle CPU in SystemVerilog and its integration into the DE1-SoC FPGA board.

---

## CPU Core Notes

### Architecture

* Full **RV32I** support (R, I, S, B, U, J).
* Single-cycle architecture: all stages (fetch, decode, execute, memory, write-back) occur in one clock cycle.
* The CPU core is kept **hardware-agnostic**, meaning:

  * No FPGA-specific logic inside the CPU.
  * No buttons, seven-segment logic, or debouncers are included.
  * FPGA integration is done through a wrapper module.

### Memory Design

* The data memory uses a parameterizable depth (`ADDR_WIDTH = 8 → 256 words = 1 KB`).
* **Synchronous write** on positive clock edge.
* **Combinational read** to satisfy single-cycle requirements.
* Supports:

  * `SB`, `SH`, `SW`
  * `LB`, `LBU`, `LH`, `LHU`, `LW`
* Correct sign extension and zero extension for all loads.

---

## FPGA Integration Notes

### Rationale for Wrapper

A wrapper module (`FPGA_top` or similar) is used to:

* Avoid modifying the CPU core.
* Add DE1-SoC-specific IO:

  * Push-button clock stepping
  * Debouncing module
  * Seven-segment display controller
  * Pin assignments (KEY, HEX displays, LEDs)

### Clock Stepping

* A push button (KEY0) manually advances the CPU one cycle.
* A **debouncer** is required to prevent mechanical noise from producing multiple unintended clock pulses.

### Values Displayed on Seven-Segment Displays

The system shows different values depending on instruction type:

* **R, I, U, J**: the **write-back value** written into `rd`.
* **S-type**: the **data being written** to memory.
* **B-type**: the **branch target address** (PC + immediate).
* Since DE1-SoC has **6 seven-segment displays**, values are shown in **hexadecimal**.
* Additional button (KEY1) used to switch between high and low 6-hex-digit halves if needed.

---

## Resource & Fitting Notes

### Original Fitter Failure

A Fitter error appeared:

```
Error (11802): Can't fit design in device.
```

This occurred due to:

* High **Adaptive LUT** usage, especially inside the DataMemory.
* Device resource limits being exceeded.

### Fix

Reducing memory usage solved the issue:

* Lowered DataMemory size (`ADDR_WIDTH=8` → 256 words).
* This reduces LUT and register usage significantly on Cyclone V.

---

## Repository Structure Decisions

* A separate branch (`FPGA_Implementation`) was created to isolate FPGA-specific code.

---

## Git & Project Organization Notes

### `.gitignore`

Used to exclude:

* Quartus output files ( `.sof`, `.smsg`, `.rpt`)
* Simulation artifacts (`*.out`, `*.vcd`)
* Backup/temporary files.

### README

Contains:

* Project summary
* Setup instructions
* Compilation commands for Icarus Verilog
* FPGA usage instructions
* Repository structure

---

## Tools Used

* **Icarus Verilog 12.0** for simulation.
* **Quartus Prime Lite / Standard** for synthesis.
* **WaveTracer extension** for waveform visualization in VS Code.
* **DE1-SoC** (Cyclone V) board for hardware execution.

---

## Additional Notes

* The seven-segment module expects **hex input**; binary-to-7seg decoding is handled in the wrapper.
* Manual stepping makes debugging pipeline-less CPU execution extremely intuitive.
* This structure enables future expansion (pipelined CPU, memory-mapped IO, etc.) without modifying the main CPU core.
