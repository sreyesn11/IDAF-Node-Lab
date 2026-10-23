#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLCHAIN_DIR="$PROJECT_ROOT/toolchains/riscv-none-elf-gcc"
VENV_DIR="$PROJECT_ROOT/.venv"

echo "=========================================="
echo " IDAF Node Lab - Environment Setup"
echo "=========================================="

echo
echo "[1/5] Installing Ubuntu dependencies..."

sudo apt update

sudo apt install -y \
build-essential \
cmake \
python3-pip \
python3-venv \
bison \
flex \
gettext \
texinfo \
libncurses5-dev \
libncursesw5-dev \
xxd \
gperf \
automake \
libtool \
pkg-config \
genromfs \
kconfig-frontends \
libgmp-dev \
libmpc-dev \
libmpfr-dev \
libisl-dev \
binutils-dev \
libelf-dev \
libexpat1-dev \
gcc-multilib \
g++-multilib \
picocom \
u-boot-tools \
util-linux \
curl \
git

echo
echo "[2/5] Creating Python virtual environment..."

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

python -m pip install --upgrade pip
pip install "esptool>=4.8.1"

echo
echo "[3/5] Installing RISC-V toolchain..."

if [ ! -x "$TOOLCHAIN_DIR/bin/riscv-none-elf-gcc" ]; then
    mkdir -p "$TOOLCHAIN_DIR"

    curl -s -L \
    "https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v13.2.0-2/xpack-riscv-none-elf-gcc-13.2.0-2-linux-x64.tar.gz" \
    | tar -C "$TOOLCHAIN_DIR" \
    --strip-components 1 -xz
else
    echo "RISC-V toolchain already installed."
fi

echo
echo "[4/5] Initializing Git submodules if available..."

cd "$PROJECT_ROOT"

if [ -f ".gitmodules" ]; then
    git submodule update --init --recursive
else
    echo "No Git submodules configured yet."
fi

echo
echo "[5/5] Verifying environment..."

source "$PROJECT_ROOT/scripts/env.sh"

echo
echo "Project root:"
echo "$IDAF_NODE_LAB"

echo
echo "Python:"
python3 --version

echo
echo "esptool:"
esptool version

echo
echo "RISC-V compiler:"
riscv-none-elf-gcc --version | head -n 1

echo
echo "=========================================="
echo " Setup completed successfully"
echo "=========================================="
echo
echo "Next steps:"
echo "  ./scripts/configure_nuttx.sh"
echo "  source scripts/env.sh"
echo "  make -C nuttx -j\$(nproc)"
