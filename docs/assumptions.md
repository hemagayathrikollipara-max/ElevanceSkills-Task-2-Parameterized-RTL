# AMTGC — Design Assumptions

**Task:** 6 Supporting Document  
**Project:** Adaptive Multi-Junction Traffic Controller (AMTGC)  
**Implementation:** Verilog HDL  
**Simulation environment used:** AMD Xilinx Vivado 2022.2

## 1. Purpose and Scope

This document states assumptions used to describe the AMTGC RTL. Confirm each item against the final source code and assignment specification before submission.

## 2. System-Level Assumptions

| ID | Assumption / statement to verify |
|---|---|
| A1 — Clock and reset | The design is synchronous to its configured clock and uses the reset behavior implemented in RTL. Exact clock period, reset polarity, and reset duration must be taken from the top module and testbench. |
| A2 — Junction model | The top-level design coordinates two junction controllers. Exact signal names, inter-controller coordination, and supported traffic directions are defined by the committed RTL. |
| A3 — FSM behavior | Project notes list `S_WAIT`, `S_NS_GREEN`, `S_NS_YELLOW`, `S_RED_NS_EW`, `S_EW_GREEN`, `S_EW_YELLOW`, `S_RED_EW_NS`, and `S_PED`. Confirm state encoding and exact transitions in the final source. |
| A4 — Adaptive green timing | Green duration is described as `MIN_GREEN_TIME + traffic_density × GREEN_EXTENSION`, clamped between minimum and maximum bounds. Confirm arithmetic width, density range, units, and saturation behavior. |
| A5 — Pedestrian requests | A pedestrian request may be retained as pending and serviced in the pedestrian phase after the applicable clearance sequence. Confirm edge/level behavior and latching in final RTL. |
| A6 — Emergency override | Intended safe behavior when emergency override is asserted is to deassert NS/EW green and yellow outputs, assert `all_red`, and deassert `ped_walk`. Verify priority, latency, and output names in RTL/waveform. |
| A7 — Green-wave coordination | The design includes coordination/delay between junctions. Exact delay units, threshold, and synchronization behavior must be taken from RTL/testbench and verified against simulation timescale. |
| A8 — Simulation scope | Behavioral simulation was performed in Vivado 2022.2 according to project notes. No FPGA hardware validation is claimed unless board-level testing was actually performed. |
| A9 — Tool portability | Results can depend on simulator semantics, compile settings, timescale, and testbench scheduling. A ModelSim run is not claimed unless it has actually been performed. |
| A10 — Safety and deployment | This is an academic RTL prototype, not a certified road-traffic control system. Real deployment requires hazard analysis, fail-safe review, timing validation, and hardware/system testing. |

## 3. Parameters and Units to Record

| Parameter | Value from final RTL | Unit / source |
|---|---|---|
| Clock period / timescale | Fill from RTL/testbench | Confirm in source |
| `MIN_GREEN_TIME` | Fill from RTL/testbench | Confirm in source |
| `GREEN_EXTENSION` | Fill from RTL/testbench | Confirm in source |
| Maximum green bound | Fill from RTL/testbench | Confirm in source |
| Traffic-density input range | Fill from RTL/testbench | Confirm in source |
| Yellow / all-red clearance durations | Fill from RTL/testbench | Confirm in source |
| Green-wave delay / threshold | Fill from RTL/testbench | Confirm in source |
| Emergency input polarity | Fill from RTL/testbench | Confirm in source |

## 4. Known Limitations

The document does not claim hardware operation or real-world traffic-safety certification.

All numeric timing values and green-wave acceptance thresholds must be confirmed from final code and logs.

The reported simulation PASS must be backed by the archived log for the exact committed revision.
