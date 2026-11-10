MaskCore – Side-Channel-Aware CNN Accelerator

An RTL-based CNN accelerator exploring hardware-level protection against side-channel leakage through arithmetic masking.

«Project Status: In Progress»

Overview

MaskCore explores the design and evaluation of a hardware-accelerated Convolutional Neural Network (CNN) architecture with side-channel-aware protection mechanisms.

The project investigates arithmetic masking techniques for protecting intermediate computations, including weights, activations and partial sums, while studying their impact on functional correctness, hardware area and timing.

Key Features

- CNN Hardware Architecture: RTL implementation of a CNN accelerator with processing elements and systolic-array-based computation.
- Arithmetic Masking: Protected computation using masking and mask recombination mechanisms.
- Protected Datapath: Masked partial-sum accumulation and requantization.
- Functional Verification: Testbench-based comparison of protected and unprotected accelerator outputs.
- Security Evaluation: Investigation of potential side-channel leakage using simulation-based analysis.
- PPA Evaluation: Area, timing and implementation analysis using digital design and physical-design tools.

Architecture Components

The design explores the following hardware components:

- CNN accelerator datapath
- Systolic array and processing elements
- Weight and activation masking
- Masked partial-sum accumulation
- Masked requantization
- Mask generation and recombination logic
- Functional verification environment

Verification and Evaluation

The project includes a functional verification environment to compare the outputs of protected and unprotected implementations.

It also investigates the hardware overhead introduced by masking, including standard-cell area and timing, alongside simulation-based side-channel analysis.

Tools and Technologies

- SystemVerilog
- Verilog HDL
- RTL Simulation
- Yosys
- OpenROAD
- OpenSTA
- Python

Current Development Goals

- Study the complete protected accelerator architecture.
- Understand the masking mechanisms and their limitations.
- Reproduce and validate functional simulation results.
- Evaluate area and timing overhead.
- Investigate improvements to the protection architecture.
- Document security assumptions and implementation limitations.

Limitations and Security Considerations

Hardware masking does not automatically guarantee resistance against all side-channel attacks. Random-number generation, mask reuse, unprotected datapath components and higher-order leakage require careful consideration.

Simulation-based leakage analysis should not be interpreted as proof of resistance against physical hardware attacks.

Project Status

This repository is under active development. Verification, implementation analysis and documentation will be updated as the design progresses.
