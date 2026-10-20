# Adaptive Multi-Junction Traffic Controller (AMTGC)

A parameterized Verilog HDL project for intelligent traffic signal coordination across multiple junctions, developed and verified using AMD Xilinx Vivado 2022.2.

## Project Overview

The Adaptive Multi-Junction Traffic Controller (AMTGC) is designed to manage traffic signals at two four-way junctions. It integrates adaptive signal timing, pedestrian request arbitration, green-wave coordination, and emergency vehicle priority to improve traffic flow and maintain safe signal operation.

## Key Features

- **Multi-Junction Control:** Independent signal control for two traffic junctions.
- **Parameterized RTL:** Reusable FSM-based junction controllers and generic timers.
- **Adaptive Green Timing:** Green duration adjusts according to traffic density within defined limits.
- **Pedestrian Arbitration:** Shared arbitration logic manages pedestrian requests.
- **Green-Wave Coordination:** Coordinates signal timing between junctions.
- **Emergency Override:** Forces both junctions into an all-red safety state during emergency activation.

## Repository Structure

- `rtl/` — Verilog RTL design modules.
- `tb/` — Testbench files for functional verification.
- `sim/` — Simulation waveforms and verification evidence.
- `docs/` — Technical documentation, architecture diagrams, and reports.

## Development Tools

- AMD Xilinx Vivado 2022.2
- Verilog HDL
- Vivado Behavioral Simulation

## Verification and Testing

The supplied Task 5 testbench report records 361 checks, zero detected errors, and a PASS result for the enabled checks. Verification scenarios cover reset behavior, adaptive timing, green-wave coordination, pedestrian arbitration, emergency override, and additional functional checks.

For reproducible results, run the supplied testbench against the final RTL files and verify the simulation log and waveform outputs.

## Running the Simulation

1. Clone or download this repository.
2. Open AMD Xilinx Vivado 2022.2.
3. Create or open a Vivado project.
4. Add the required design files from `rtl/`.
5. Add the required testbench files from `tb/`.
6. Set the intended testbench as the simulation top module.
7. Select **Run Behavioral Simulation**.
8. Run the simulation to completion and inspect the waveform and Tcl Console for results.

## Documentation and Simulation Evidence

Refer to `docs/` for design documentation and architecture diagrams. Refer to `sim/` for saved simulation waveforms and verification evidence.

## Project Status

The project includes parameterized RTL modules, simulation testbenches, technical documentation, and verification evidence. Final verification should be performed using the exact RTL and testbench versions committed to this repository.

---

**Project:** Adaptive Multi-Junction Traffic Controller (AMTGC)  
**Domain:** Digital Design and Verilog HDL  
**Simulation Platform:** AMD Xilinx Vivado 2022.2
