#!/usr/bin/env bash

export IDAF_NODE_LAB="$HOME/Universidad/IDAF-Node-Lab"

TOOLCHAIN_DIR="$IDAF_NODE_LAB/toolchains/riscv-none-elf-gcc"
VENV_DIR="$IDAF_NODE_LAB/.venv"

if [ -d "$TOOLCHAIN_DIR/bin" ]; then
    export PATH="$TOOLCHAIN_DIR/bin:$PATH"
fi

if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
fi
