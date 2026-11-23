# Decisiones del proyecto — SSI20

Acuerdos de diseño del Trabajo Final (SSI, UPNA). Documento vivo y compartido por el
equipo. Si una decisión cambia, edítala aquí y avisa al resto.

- **Grupo:** SSI20
- **Objetivo remoto:** `10.6.31.40:4220` (puerto `42XX`, XX = 20)
- **Idioma:** TUI y documentación en español.

## Estado

- **Parte 1** — en desarrollo (empezamos por aquí).
- **Partes 2, 3 y 4** — bloqueadas hasta disponer del binario del profesor
  (empieza a dar servicio "la próxima semana"). No se deciden offsets ni arquitectura
  definitiva hasta analizarlo.

## Entorno de trabajo (equipo Windows + Mac)

- **Entorno canónico:** contenedor **Docker `amd64`** compartido (reproducible en los dos
  equipos; en Mac Apple Silicon corre emulado). Evita divergencias de gcc/glibc y problemas
  de ejecutar ELF x86 en ARM.
- El `Dockerfile` (en el repo) lleva: `gcc`, `gcc-multilib` (para 32 bits), `gdb`+`pwndbg`,
  `python3`+`pwntools`, `socat`. Metasploit se añade para la Parte 3.
- **Validación final:** máquina Linux del laboratorio (donde corre de verdad el binario).

## Parte 1 — App en C con overflow a `win()`

### Arquitectura
- **64 bits provisional** (suponiendo binario del profesor de 32 bits, caso habitual).
- Makefile conmutable con variable `ARCH` (`64` por defecto → `-m64`; `32` → `-m32`).
- La arquitectura **definitiva** se confirma al analizar el binario del profesor
  (regla del enunciado: si el suyo es 32 → la nuestra 64, y viceversa).

### Temática
- **Inventario / almacén.**

### Modelo de datos
- `struct Producto` de tamaño fijo + **array estático** `Producto inventario[128]` + contador.

```c
typedef struct {
    int    id;
    char   nombre[64];
    char   sku[16];
    int    cantidad;
    double precio;
    char   proveedor[64];
} Producto;
```

### Persistencia
- Fichero **binario** `inventario.dat` con `fwrite`/`fread` del array de structs.
- **Export CSV opcional** para informes legibles.
- Usuarios en `usuarios.dat`, aparte.

### Gestión de usuarios
- Registro, login, validación, control de duplicados, logout, persistencia.
- Contraseñas con **SHA-256 propio** (`sha256.c`, dominio público) — sin OpenSSL/libcrypto.
- `struct Usuario { char user[32]; char hash[65]; }`.

### Procesamiento (≥3 operaciones)
1. **Valor total** del inventario (Σ `cantidad × precio`) y valor por producto.
2. **Productos bajo mínimos** (filtro `cantidad < umbral` configurable).
3. **Ordenación** por precio / cantidad / nombre, con listado/informe formateado.
4. (extra) **Estadísticas por proveedor** (nº de productos y valor agregado).

### Vulnerabilidad (intencionada — NO arreglar al refactorizar)
- Técnica: **ret2win clásico**.
- Punto vulnerable: la **búsqueda de producto**, que lee con `scanf("%s", buf)` sobre
  `char buf[64]` (sin límite → desborda con cadena larga).
- El overflow sobrescribe la dirección de retorno guardada y salta a `win()`.
- `win()` vive en `vuln.c`, **aislada**, lee `./flag.txt` y lo imprime. **No se llama**
  desde ningún punto del flujo normal.
- Flags de compilación: `-fno-stack-protector -no-pie -g` (NX activado; no inyectamos
  shellcode, saltamos a función existente, dirección fija por `-no-pie`).

### Exploit (Parte 1)
- **Python + pwntools.**
- Automatiza la navegación de menús por stdin (registro/login → submenú búsqueda → payload).
- Payload: `padding + ret_gadget(alineación 16B) + &win`.
- Soporta `process('./inventario')` local y modo red con
  `socat TCP-LISTEN:4220,reuseaddr,fork EXEC:./inventario`.

### Estructura de módulos

```
src/
  main.c          # bucle principal + navegación de menús
  ui.c/.h         # TUI: menús, colores ANSI, marcos, mensajes
  auth.c/.h       # registro, login, logout, usuarios.dat
  inventory.c/.h  # CRUD de productos
  storage.c/.h    # fwrite/fread, export CSV, gestión errores E/S
  stats.c/.h      # ordenación, filtros, estadísticas, informes
  vuln.c/.h       # búsqueda con el buffer vulnerable + win()
  sha256.c/.h     # SHA-256 propio (dominio público, sin dependencias)
Makefile
```

### Makefile
- Variable `ARCH` (64/32).
- `CFLAGS` vulnerabilidad: `-fno-stack-protector -no-pie -g`.
- Targets: `all`, `clean`, `run` (TUI), `serve` (socat en 4220), `exploit` (pwntools).
- `flag.txt` de ejemplo en el repo para probar `win()` en local.

### Entregables Parte 1
- Código fuente C, Makefile, binario compilado, exploit (Python/pwntools).

## Parte 2 — Exploit del binario del profesor (bloqueada)
- Redirigir a `execute_cmd` (ejecuta `/bin/bash` vía `system()`); leer `/flag/flag.txt`.
- Exploit: arg1 = IP, arg2 = puerto.
- Pendiente: `file`/`checksec` del binario, arquitectura, offsets, protecciones.

## Parte 3 — Módulo Metasploit (bloqueada)
- Ruby, payload-agnóstico, probado con Meterpreter, validado en instalación limpia/estándar.

## Parte 4 — Documento técnico (al final)
- Markdown, ≤6 páginas, sin imágenes. Problemas, metodología, análisis, decisiones, explotación.
