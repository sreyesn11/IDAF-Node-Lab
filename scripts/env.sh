#!/usr/bin/env bash

# Uso: source scripts/env.sh  (la raíz se deduce de la ubicación de este archivo)
export IDAF_NODE_LAB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TOOLCHAIN_DIR="$IDAF_NODE_LAB/toolchains/riscv-none-elf-gcc"
VENV_DIR="$IDAF_NODE_LAB/.venv"

if [ -d "$TOOLCHAIN_DIR/bin" ]; then
    export PATH="$TOOLCHAIN_DIR/bin:$PATH"
fi

if [ -f "$VENV_DIR/bin/activate" ]; then
    source "$VENV_DIR/bin/activate"
fi
