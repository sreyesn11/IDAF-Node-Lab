# IDAF Node Lab

Laboratorio del **IDAF Node Agent** sobre Apache NuttX para la placa
Seeed **XIAO ESP32-C6** (`esp32c6-xiao:usbnsh`).

## Estructura

```text
IDAF-Node-Lab/
├── nuttx/        # submódulo: apache/nuttx       (no se modifica)
├── apps/         # submódulo: apache/nuttx-apps  (no se modifica)
├── idaf-node/    # código propio: aplicación NSH `idaf` + sensor virtual
├── scripts/      # setup, entorno, integración y configuración reproducibles
├── docs/         # documentación del proyecto / tesis
├── data/         # datos de experimentos (raw/ y processed/ ignorados)
└── experiments/
```

`idaf-node/` vive fuera del submódulo `apps`. Para compilarlo,
`scripts/integrate_idaf.sh` crea el symlink local `apps/idaf -> ../idaf-node`
y lo añade al *exclude* local del submódulo, de modo que `apps` sigue limpio.

## Puesta en marcha (Ubuntu / WSL2)

```bash
git clone --recurse-submodules https://github.com/sreyesn11/IDAF-Node-Lab.git
cd IDAF-Node-Lab

./scripts/setup.sh            # paquetes apt (sudo), .venv con esptool, toolchain RISC-V, submódulos
./scripts/configure_nuttx.sh  # integra idaf-node y configura esp32c6-xiao:usbnsh + opciones IDAF
source scripts/env.sh         # toolchain en PATH + activa .venv
make -C nuttx -j$(nproc)      # genera nuttx/nuttx.bin
```

El repositorio puede clonarse en cualquier ruta: los scripts deducen la raíz a
partir de su propia ubicación.

Si se clonó **sin** `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

(`scripts/setup.sh` también lo ejecuta.)

### Qué hace `configure_nuttx.sh`

1. Ejecuta `scripts/integrate_idaf.sh` (idempotente; no sobrescribe nada).
2. Aplica el defconfig oficial con `nuttx/tools/configure.sh -E -l esp32c6-xiao:usbnsh`.
   Si ya había una `nuttx/.config`, se respalda en `build/nuttx-config-backup/`
   y se hace `distclean`.
3. Activa:

   ```text
   CONFIG_IDAF=y
   CONFIG_IDAF_PROGNAME="idaf"
   CONFIG_IDAF_PRIORITY=100
   CONFIG_IDAF_STACKSIZE=2048
   CONFIG_LIBC_FLOATINGPOINT=y
   ```

4. Ejecuta `make olddefconfig` y verifica que las opciones quedaron aplicadas.

Acepta otro `board:config` como argumento: `./scripts/configure_nuttx.sh esp32c6-xiao:nsh`.

Para recompilar tras cambiar código en `idaf-node/` basta con
`source scripts/env.sh && make -C nuttx -j$(nproc)`; no hace falta reconfigurar.

## Flasheo desde Windows (PowerShell)

Con la placa conectada (en el ejemplo, `COM4`):

```powershell
python -m esptool --chip esp32c6 --port COM4 --baud 115200 write-flash 0x0000 "<ruta-al-proyecto>\nuttx\nuttx.bin"
```

`<ruta-al-proyecto>` puede ser la ruta WSL vista desde Windows, por ejemplo
`\\wsl.localhost\Ubuntu\home\<usuario>\<carpeta>\IDAF-Node-Lab`.

Consola serie:

```powershell
python -m serial.tools.miniterm COM4 115200 --raw
```

## Prueba funcional

```text
nsh> idaf
nsh> idaf sensor status
nsh> idaf sensor read
```

`idaf sensor read` devuelve una muestra del sensor virtual de temperatura
(`sequence`, `timestamp_ms`, `value=25.00`, `unit=C`, `valid=true`, `status=0`);
`idaf sensor status` muestra el modo actual (`mode=NORMAL`).

## Documentación

- [docs/environment.md](docs/environment.md): entorno de desarrollo.
- [docs/IDAF_Virtual_Sensor_Design.md](docs/IDAF_Virtual_Sensor_Design.md): diseño del sensor virtual.
