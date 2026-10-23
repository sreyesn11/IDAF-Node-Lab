# IDAF Node Lab — Diseño del Sensor Virtual

**Plataforma:** Seeed Studio XIAO ESP32-C6 + Apache NuttX  
**Proyecto:** IDAF Node Lab  
**Objetivo:** construir un sensor virtual controlable y reproducible que permita generar datos normales y fallas conocidas para validar observabilidad y diagnóstico.

---

## 1. Propósito

El sensor virtual será el primer componente funcional propio de IDAF ejecutándose sobre NuttX.

La idea no es únicamente generar una temperatura falsa. El objetivo es disponer de una fuente de datos controlada que permita:

- producir una señal normal;
- introducir fallas conocidas de forma deliberada;
- conocer exactamente cuándo comienza y termina una falla;
- observar cómo cambia el comportamiento del nodo;
- validar posteriormente algoritmos de diagnóstico;
- servir como reemplazo temporal de un sensor físico;
- mantener la misma interfaz cuando luego se conecte un sensor real.

Esto permite crear **ground truth** experimental: si nosotros provocamos una falla en un instante conocido, podremos comprobar posteriormente si IDAF la detecta correctamente.

---

## 2. Primer sensor

El primer sensor virtual representará:

```text
Temperatura
```

Unidad:

```text
°C
```

Rango inicial de operación normal propuesto:

```text
20 °C – 30 °C
```

Valor nominal inicial:

```text
25 °C
```

El rango podrá ajustarse posteriormente durante los experimentos.

---

## 3. Arquitectura

```text
IDAF Node
|
+-- Virtual Sensor
|   |
|   +-- Sensor State
|   +-- Sample Generator
|   +-- Fault Injector
|   +-- Statistics
|   +-- Read API
|
+-- Future Physical Sensor
```

La aplicación IDAF no debería depender de si el dato viene de:

```text
Virtual Sensor
```

o de:

```text
Physical Sensor
```

Por eso se utilizará una abstracción común de proveedor de sensor.

Conceptualmente:

```text
sensor_read()
sensor_get_status()
sensor_set_mode()
```

---

## 4. Modos de operación

### NORMAL

Genera valores realistas alrededor de una temperatura nominal.

Ejemplo:

```text
24.9
25.1
25.0
25.2
24.8
```

Objetivo:

- establecer el comportamiento normal;
- crear baseline;
- validar que IDAF no genere falsos positivos.

---

### SPIKE

Genera un cambio brusco y aislado.

Ejemplo:

```text
25.0
25.1
25.0
43.8   <- spike
25.1
24.9
```

Objetivo:

- simular una lectura anómala puntual;
- probar detección de outliers.

---

### BIAS

Introduce un desplazamiento persistente.

Ejemplo:

```text
Normal:
25.0
25.1
24.9

Bias +8 °C:
33.0
33.1
32.9
```

Objetivo:

- simular descalibración;
- probar detección de deriva/desplazamiento sistemático.

---

### STUCK

El sensor deja de variar.

Ejemplo:

```text
25.0
25.2
25.1
27.4
27.4
27.4
27.4
```

Objetivo:

- simular un sensor congelado;
- detectar ausencia de variabilidad.

---

### NO_DATA

El sensor deja de producir una muestra válida.

Ejemplo conceptual:

```text
value = invalid
status = no_data
```

Objetivo:

- simular desconexión;
- simular lectura fallida;
- probar timeouts y ausencia de datos.

---

### NOISY

Aumenta artificialmente la variabilidad.

Ejemplo:

```text
25.0
21.8
28.9
23.1
30.2
```

Objetivo:

- simular interferencia;
- simular sensor degradado;
- analizar estabilidad y dispersión.

---

### SLOW

La lectura tarda más de lo esperado.

Ejemplo:

```text
Normal read latency: 5 ms
Fault read latency: 500 ms
```

Objetivo:

- simular un sensor lento;
- observar latencia;
- estudiar impacto sobre tareas y diagnóstico.

---

## 5. Estado interno mínimo

El sensor deberá mantener como mínimo:

```text
mode
current_value
sample_sequence
last_timestamp
read_count
error_count
timeout_count
last_read_latency
```

Ejemplo conceptual:

```text
mode=normal
value=25.1
sequence=42
read_count=42
error_count=0
timeout_count=0
```

---

## 6. Estructura de una muestra

Cada lectura debería poder representarse internamente como:

```text
sequence
timestamp
value
valid
mode
read_latency
status
```

Ejemplo:

```text
sequence=18
timestamp_ms=18342
value=25.18
valid=true
mode=normal
read_latency_us=120
status=ok
```

---

## 7. Interfaz prevista en NSH

Más adelante se pretende disponer de comandos similares a:

```bash
idaf sensor status
idaf sensor read
idaf sensor mode normal
idaf sensor mode spike
idaf sensor mode bias
idaf sensor mode stuck
idaf sensor mode no_data
idaf sensor mode noisy
idaf sensor mode slow
```

Ejemplo esperado:

```text
nsh> idaf sensor status

Sensor: virtual_temperature
Mode: NORMAL
Value: 25.14 C
Reads: 25
Errors: 0
Timeouts: 0
```

---

## 8. Primera versión del MVP

La primera implementación NO necesita todavía:

- MQTT;
- gateway;
- Wi-Fi;
- backend;
- almacenamiento persistente;
- sensor físico;
- inteligencia de diagnóstico.

La primera versión solamente debe lograr:

```text
1. ejecutar el sensor virtual;
2. generar temperaturas;
3. leerlas desde NSH;
4. cambiar el modo de operación;
5. observar el estado interno.
```

---

## 9. Criterios de aceptación iniciales

La primera versión se considerará funcional cuando:

1. NuttX compile sin errores.
2. La XIAO ESP32-C6 arranque correctamente.
3. Exista un comando de IDAF accesible desde NSH.
4. Se pueda obtener una lectura de temperatura.
5. El modo NORMAL produzca valores razonables.
6. Se pueda consultar el estado del sensor.
7. Se pueda cambiar al menos entre NORMAL y SPIKE.
8. El cambio de modo sea observable desde consola.
9. No se rompa la consola NSH.
10. Se pueda medir el incremento de ROM y RAM respecto al baseline existente.

---

## 10. Estrategia incremental

El desarrollo se realizará en incrementos pequeños:

```text
Fase A
Comando mínimo IDAF funcionando

Fase B
Sensor virtual NORMAL

Fase C
Estado y estadísticas

Fase D
SPIKE

Fase E
BIAS / STUCK

Fase F
NO_DATA / NOISY / SLOW

Fase G
Observabilidad del sensor

Fase H
Abstracción para sensor físico
```

El siguiente paso inmediato será únicamente la **Fase A: crear el comando mínimo de IDAF y conseguir que aparezca y se ejecute desde NuttShell**.

---

## 11. Principio de diseño

El sensor virtual no debe convertirse en una implementación descartable.

Debe actuar como una implementación del mismo contrato que utilizarán futuros sensores físicos:

```text
IDAF
 |
 +-- Sensor Provider API
       |
       +-- Virtual Temperature Provider
       |
       +-- Future Physical Sensor Provider
```

Así, el diagnóstico y la observabilidad podrán mantenerse independientes del hardware específico del sensor.
