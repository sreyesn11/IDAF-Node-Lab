# IDAF Node Lab - Environment

## Purpose

This document records the software and hardware environment used to build,
flash, test, and reproduce the IDAF Node Observability laboratory.

The goal is to make the experiments reproducible across different computers
and ESP32-C6 boards.

## Host Environment

Operating System:

- Windows with WSL2
- Ubuntu 24.04 LTS

Project path:

```text
~/Universidad/IDAF-Node-Lab
```

## Current Tools

- Git
- Python 3
- pip
- GCC
- GNU Make
- CMake
- picocom
- esptool
- RISC-V GCC toolchain

## ESP32-C6 Toolchain

Architecture:

```text
RISC-V
```

Compiler:

```text
riscv-none-elf-gcc
```

Current version:

```text
13.2.0
```

## Python Environment

Virtual environment:

```text
.venv/
```

Activate with:

```bash
source scripts/env.sh
```

## Future NuttX Environment

Apache NuttX and nuttx-apps will be added later.

Expected directories:

```text
nuttx/
apps/
```

## IDAF Node Goal

The laboratory will progressively implement:

```text
ESP32-C6
|
+-- Apache NuttX
|
+-- IDAF Node Agent
|
+-- Virtual Sensor
|   +-- NORMAL
|   +-- SPIKE
|   +-- BIAS
|   +-- STUCK
|   +-- NO_DATA
|   +-- NOISY
|   +-- SLOW
|
+-- Future physical sensors
```
