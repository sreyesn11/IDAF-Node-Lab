#!/usr/bin/env bash
# Integra idaf-node/ en nuttx-apps creando el symlink apps/idaf -> ../idaf-node.
#
# - Idempotente: si el symlink correcto ya existe, no hace nada.
# - Nunca sobrescribe archivos/directorios reales ni symlinks con otro destino.
# - Registra "/idaf" en el exclude LOCAL del submódulo apps (no versionado),
#   para que `git -C apps status` siga limpio sin tocar el repo upstream.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPS_DIR="$ROOT_DIR/apps"
IDAF_DIR="$ROOT_DIR/idaf-node"
LINK_PATH="$APPS_DIR/idaf"
LINK_TARGET="../idaf-node"

if [ ! -f "$APPS_DIR/Makefile" ]; then
    echo "ERROR: $APPS_DIR no existe o está vacío." >&2
    echo "       Ejecuta: git submodule update --init --recursive" >&2
    exit 1
fi

if [ ! -f "$IDAF_DIR/Makefile" ] || [ ! -f "$IDAF_DIR/Kconfig" ]; then
    echo "ERROR: $IDAF_DIR no existe o le faltan Makefile/Kconfig." >&2
    exit 1
fi

if [ -L "$LINK_PATH" ]; then
    current="$(readlink "$LINK_PATH")"
    if [ "$current" != "$LINK_TARGET" ]; then
        echo "CONFLICTO: $LINK_PATH ya es un symlink hacia '$current'" >&2
        echo "           (se esperaba '$LINK_TARGET'). Revísalo y bórralo a mano si corresponde." >&2
        exit 1
    fi
    echo "OK: apps/idaf -> $LINK_TARGET ya existe."
elif [ -e "$LINK_PATH" ]; then
    echo "CONFLICTO: $LINK_PATH existe y es un archivo/directorio real." >&2
    echo "           No se sobrescribe. Muévelo o bórralo a mano y vuelve a ejecutar." >&2
    exit 1
else
    ln -s "$LINK_TARGET" "$LINK_PATH"
    echo "Creado: apps/idaf -> $LINK_TARGET"
fi

if [ ! -f "$LINK_PATH/Kconfig" ]; then
    echo "ERROR: el symlink apps/idaf no resuelve a idaf-node/." >&2
    exit 1
fi

EXCLUDE_FILE="$(git -C "$APPS_DIR" rev-parse --path-format=absolute --git-path info/exclude)"
mkdir -p "$(dirname "$EXCLUDE_FILE")"
if ! grep -qxF "/idaf" "$EXCLUDE_FILE" 2>/dev/null; then
    printf '\n# IDAF-Node-Lab: symlink local creado por scripts/integrate_idaf.sh\n/idaf\n' >> "$EXCLUDE_FILE"
    echo "Registrado /idaf en el exclude local del submódulo apps."
fi
