# SPI Protocol Implementation

[![Language](https://img.shields.io/badge/Language-SystemVerilog-blue.svg)](https://en.wikipedia.org/wiki/SystemVerilog)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)

A collection of synthesizable **SPI (Serial Peripheral Interface)** modules in SystemVerilog, covering fundamental master-slave setups and advanced configurations like CPOL/CPHA variants.

---

## 📖 The SPI Protocol

The Serial Peripheral Interface (SPI) is a synchronous serial communication protocol used for short-distance communication, primarily in embedded systems. It operates in full-duplex mode with a master-slave architecture using four main lines: SCLK, MOSI, MISO, and SS.

#### 🔗 Basic Block Diagram
This diagram shows a standard single-master, multiple-slave SPI configuration.

![Basic SPI Master-Slave Block Diagram](https://www.fpgakey.com/uploads/images/original/20200619/114040SIP.jpg)

#### 🕰️ Clocking and Data Timing
The clocking diagram illustrates the timing relationship between the **serial clock (SCLK)** and the **data lines (MOSI/MISO)**. This timing is defined by the Clock Polarity (CPOL) and Clock Phase (CPHA), which together determine the four operating modes of SPI.

![SPI Clocking Modes CPOL and CPHA](https://github.com/SumitSengar47/SPI-protocol-sv/blob/main/spi_timing_diagram.png?raw=true)

#### 📉 Typical Waveform
A typical SPI transaction showing the data being transmitted on the MOSI and MISO lines relative to the SCLK signal while the Slave Select (SS) line is active (low).

![Basic SPI Transaction Waveform](https://github.com/SumitSengar47/SPI-protocol-sv/blob/main/spi_waveform.png?raw=true)

---

## 🛠️ Implemented Modules

This repository provides the following Verilog modules:

-   **`1_SPI.sv`**: A comprehensive **SPI Master** module.
-   **`2_SPI_slave.sv`**: A standard **SPI Slave** module.
-   **`3_SPI_slave_alternate.sv`**: An alternative implementation of the SPI slave.
-   **`4_spi_cpol.sv`**: An example module demonstrating different **CPOL/CPHA modes**.
-   **`5_spi_dac.sv`**: A practical interface for a **SPI-based DAC**.
-   **`6_spi_daisy_chain.sv`**: An implementation of the **daisy-chain topology** for multiple slaves.

---

## 🧪 Verification

All modules in this repository have been **functionally verified**. For ease of use, each module file includes a **self-contained testbench**. This allows for quick, modular verification of each component.

To run a test, simply load the desired SystemVerilog file (e.g., `1_SPI.sv`) into a simulator and run it. The embedded testbench will instantiate the design and execute a basic stimulus to check its operation.

---

## 🚀 Future Work

-   [ ] **Advanced Verification**: Develop a UVM-based testbench with constrained-random stimulus and functional coverage to ensure more robust verification.
-   [ ] **AXI4-Stream Interface**: Add an AXI4-Stream interface to the master module for easier integration into modern SoC designs.
-   [ ] **FPGA Synthesis**: Provide synthesis scripts and document the process for implementing the SPI master/slave on an FPGA to validate it in hardware.
-   [ ] **Error Handling**: Implement more robust error detection and handling, such as timeout mechanisms.
