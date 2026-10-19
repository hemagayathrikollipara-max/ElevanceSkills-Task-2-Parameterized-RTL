# ElevanceSkills-Task-2-Parameterized-RTL
Parameterized RTL design of an adaptive traffic controller using Verilog HDL, reusable FSM-based junction controllers, generic timers, pedestrian handling, and Vivado simulation.

# Adaptive Multi-Junction Traffic Controller (AMTGC)

## Project Overview
The Adaptive Multi-Junction Traffic Controller (AMTGC) is a Verilog-based digital system designed to coordinate traffic signals at two four-way junctions. It supports adaptive green timing, pedestrian request arbitration, green-wave coordination, and emergency override.

## Features
- Independent control of two traffic junctions.
- Parameterized junction controller and reusable generic timer.
- Traffic-density-based adaptive green duration with safety limits.
- Shared pedestrian arbiter designed to provide fair access.
- Green-wave coordination between Junction A and Junction B.
- Emergency override to force both junctions to an all-red condition.

## Project Structure
- `rtl/` — RTL source modules.
- `tb/` — Simulation testbenches.
- `sim/` — Simulation waveforms and verification evidence.
- `docs/` — Technical documentation and diagrams.

## Tools
- AMD Xilinx Vivado 2022.2
- Verilog HDL
- Vivado behavioral simulation

## Verification
The Task 5 testbench reported 361 checks performed, zero detected errors, and PASS for all enabled checks. Re-run the supplied testbench using the final RTL files to reproduce the results.

## Running the Simulation
1. Clone or download this repository.
2. Open Vivado 2022.2 and create or open a project.
3. Add the Verilog files from `rtl/` as Design Sources.
4. Add the testbench files from `tb/` as Simulation Sources.
5. Set the appropriate testbench as the simulation top.
6. Run **Run Behavioral Simulation**.
7. Run the simulation to completion and inspect the Tcl Console and waveform.

## Documentation and Evidence
See `docs/` for architecture documentation and design diagrams, and `sim/` for saved simulation evidence.

## Note
Use the final RTL version associated with the passing verification testbench. The generic timer should remain unchanged from the verified version.
