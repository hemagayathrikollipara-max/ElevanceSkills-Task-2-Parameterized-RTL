# AMTGC — Bug Log

**Task:** 6 Supporting Document  
**Project:** Adaptive Multi-Junction Traffic Controller (AMTGC)  
**Implementation:** Verilog HDL  
**Simulation environment used:** AMD Xilinx Vivado 2022.2

## Purpose

This log records issues reported during development, simulation, and final-delivery preparation. Check each entry against the final RTL and archived logs before submission; do not present an unverified observation as a confirmed fix.

## Issue Register

| ID | Issue / Observation | Investigation / Resolution | Status | Evidence to verify |
|---|---|---|---|---|
| BUG-01 | A previous simulation run was reported to stall or time out during a traffic-density scenario. | Review testbench wait conditions, timeout guard, and phase-measurement logic. Record a fix only if supported by final source/log. | Verify against final testbench | Final testbench and run log |
| BUG-02 | Earlier notes showed possible inconsistency in green-wave delay units / acceptance threshold (e.g. ns versus stated minimum delay). | Check delay calculation, `timescale`, threshold, and printed units; ensure reported value and pass condition use the same unit and definition. | Open verification item | Waveform, assertion, console log |
| BUG-03 | A final simulation summary was previously reported as 361 checks, zero detected errors, and PASS. | Confirm exact count/result against the archived log for the committed RTL/testbench revision. | Reported PASS — evidence check required | Final console log / screenshot |
| BUG-04 | Pedestrian service and emergency override need clear final evidence. | Confirm pending pedestrian requests are serviced in the intended phase and emergency override drives the specified safe outputs. Capture waveform intervals. | Verification item | RTL, testbench, waveform |

## Reporting Rules

- Do not mark an issue fixed unless the final source and/or a successful test supports the conclusion.
- If an item was not actually observed, remove it or relabel it as a verification note rather than a bug.
- When confirmed, add date, affected file, reproduction steps, root cause, corrective change, and regression test.
- Keep this log consistent with the RTL and testbench committed to GitHub.
