#!/usr/bin/env bash
# Configura NuttX para el IDAF Node sin modificar archivos versionados de nuttx/.
#
# Uso: ./scripts/configure_nuttx.sh [board:config]   (por defecto esp32c6-xiao:usbnsh)
#
# 1. Integra idaf-node en apps/ (scripts/integrate_idaf.sh).
# 2. Aplica el defconfig oficial con tools/configure.sh (hace distclean si ya
#    estaba configurado; la .config previa se respalda en build/).
# 3. Activa las opciones IDAF y LIBC_FLOATINGPOINT en nuttx/.config.
# 4. Ejecuta `make olddefconfig` y verifica el resultado.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NUTTX_DIR="$ROOT_DIR/nuttx"
BOARD_CONFIG="${1:-esp32c6-xiao:usbnsh}"

IDAF_OPTIONS=(
    'CONFIG_IDAF=y'
    'CONFIG_IDAF_PROGNAME="idaf"'
    'CONFIG_IDAF_PRIORITY=100'
    'CONFIG_IDAF_STACKSIZE=2048'
    'CONFIG_LIBC_FLOATINGPOINT=y'
)

if [ ! -x "$NUTTX_DIR/tools/configure.sh" ]; then
    echo "ERROR: $NUTTX_DIR no está inicializado." >&2
    echo "       Ejecuta: git submodule update --init --recursive" >&2
    exit 1
fi

"$ROOT_DIR/scripts/integrate_idaf.sh"

cd "$NUTTX_DIR"

if [ -f .config ]; then
    backup_dir="$ROOT_DIR/build/nuttx-config-backup"
    mkdir -p "$backup_dir"
    backup="$backup_dir/config.$(date +%Y%m%d-%H%M%S)"
    cp .config "$backup"
    echo "Respaldo de la .config anterior: ${backup#"$ROOT_DIR"/}"
fi

echo "Configurando $BOARD_CONFIG ..."
./tools/configure.sh -E -l -a ../apps "$BOARD_CONFIG"

for option in "${IDAF_OPTIONS[@]}"; do
    key="${option%%=*}"
    sed -i -e "/^${key}=/d" -e "/^# ${key} is not set/d" .config
    echo "$option" >> .config
done

make olddefconfig

missing=0
for option in "${IDAF_OPTIONS[@]}"; do
    if ! grep -qxF "$option" .config; then
        echo "ERROR: falta '$option' en nuttx/.config tras olddefconfig." >&2
        missing=1
    fi
done
[ "$missing" -eq 0 ] || exit 1

echo
echo "NuttX configurado ($BOARD_CONFIG) con IDAF habilitado."
echo "Siguiente paso: source scripts/env.sh && make -C nuttx -j\$(nproc)"
