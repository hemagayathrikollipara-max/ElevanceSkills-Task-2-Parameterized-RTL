# Adaptive Multi-Junction Traffic Controller (AMTGC)

A parameterized Verilog HDL project for intelligent traffic signal coordination across multiple junctions, developed and verified using AMD Xilinx Vivado 2022.2.

## 1. Project Overview

The Adaptive Multi-Junction Traffic Controller (AMTGC) is designed to coordinate traffic signals across two four-way junctions. The system uses Finite State Machines (FSMs), parameterized timing logic, pedestrian request arbitration, green-wave coordination, and emergency vehicle priority to improve traffic flow while maintaining safe signal operation.

The project demonstrates digital design principles, sequential control logic, simulation-based verification, and modular RTL development using Verilog HDL.

## 2. Key Features

- **Multi-Junction Control:** Controls traffic signals at two independent junctions.
- **Parameterized RTL:** Uses reusable FSM-based junction controllers and timing modules.
- **Adaptive Green Timing:** Adjusts green signal duration according to traffic density within defined limits.
- **Pedestrian Request Arbitration:** Coordinates pedestrian crossing requests between junctions.
- **Green-Wave Coordination:** Supports coordinated signal timing between junctions.
- **Emergency Override:** Activates an all-red safety condition during emergency operation.
- **Reset Handling:** Supports reset behavior to return the controllers to their defined initial states.
- **Simulation-Based Verification:** Uses dedicated testbenches to check functionality and controller behavior.

## 3. System Architecture

The AMTGC design consists of modular RTL components responsible for traffic signal sequencing, timing control, pedestrian request handling, junction coordination, and emergency response.

Each junction controller operates using a Finite State Machine (FSM). The controller transitions between defined traffic signal states according to timing conditions, control requests, and system-level coordination logic.

Architecture diagrams and related design documentation are available in the `docs/` directory.

## 4. Repository Structure

```text
amtgc/
├── rtl/
│   └── Verilog RTL design modules
├── tb/
│   └── Simulation testbenches
├── docs/
│   ├── Architecture diagrams
│   ├── FSM diagrams
│   ├── Technical reports
│   └── Documentation
├── sim/
│   ├── Waveform screenshots
│   ├── Verification
