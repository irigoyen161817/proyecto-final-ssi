# CLAUDE.md

Guia operativa para Claude Code en este repositorio: como trabajar aqui.

- El **QUE** (enunciado del Trabajo Final de SSI, UPNA) esta en `README.md`.
- Las **DECISIONES de diseno** y el **ESTADO** del proyecto estan en `docs/DECISIONES.md`.

Este fichero no reproduce ni resume esos dos; remite a ellos.

## Entorno de trabajo

- Todo build / run / debug ocurre **dentro del contenedor Docker `amd64`** compartido, nunca en el host.
- El host es Windows + Mac; en Mac Apple Silicon el contenedor corre emulado. **Compilar ELF x86 directamente en el host (sobre todo Mac ARM) no es valido.**
- El contenedor lleva `gcc`, `gcc-multilib` (32 bits), `gdb`+`pwndbg`, `python3`+`pwntools`, `socat` (Metasploit se anade para la Parte 3). Ver `Dockerfile` (por crear) y `docs/DECISIONES.md`.
- **Validacion final:** maquina Linux del laboratorio.

## Comandos

Via oficial a traves del Makefile (aun por crear; targets ya acordados):

- `make all` — compila el binario.
- `make clean` — limpia artefactos.
- `make run` — lanza la TUI.
- `make serve` — expone el binario por red con socat en el puerto `4220`.
- `make exploit` — ejecuta el exploit (Python + pwntools).

Variable `ARCH` del Makefile: `64` por defecto (`-m64`), `32` para `-m32`.

## Estructura del codigo

- Codigo modular: un par `.c`/`.h` por modulo; el codigo nuevo cae en el modulo que le corresponde por responsabilidad.
- **Idioma del codigo:** identificadores y comentarios en espanol **sin acentos** (p. ej. `buscar_producto`); las cadenas de la TUI van en espanol con acentos.
- Mapa completo de modulos (`main`, `ui`, `auth`, `inventory`, `storage`, `stats`, `vuln`, `sha256`) y modelo de datos: ver `docs/DECISIONES.md`.

## Invariantes (no romper al refactorizar)

- La **vulnerabilidad es intencionada**: la busqueda de producto lee con `scanf("%s", buf)` sobre `char buf[64]` sin limite. No "arreglarla".
- `win()` **no se llama nunca** desde el flujo normal; solo se alcanza via el overflow.
- Mantener los flags de compilacion de la vuln: `-fno-stack-protector -no-pie -g`.
- TUI y documentacion en **espanol**.
- **Arquitectura inversa:** si el binario del profesor (Parte 2) es de 32 bits, nuestra app se compila en 64 bits; y viceversa.

## Punteros

- `README.md` — enunciado (el que).
- `docs/DECISIONES.md` — decisiones de diseno y estado por partes (el porque y el progreso).
