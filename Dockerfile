# Entorno canonico del Trabajo Final de SSI (grupo SSI20).
# Contenedor amd64 reproducible en Windows y Mac (en Apple Silicon corre emulado).
# Ver docs/DECISIONES.md para el porque de cada herramienta.
#
# Construir:  docker build --platform linux/amd64 -t ssi20 .
# Usar:       docker run --platform linux/amd64 -it --rm -v "$PWD":/work ssi20
#
# Nota: --platform fuerza amd64 para poder compilar y depurar ELF x86 aunque
# el host sea ARM (Mac Apple Silicon).
FROM --platform=linux/amd64 debian:bookworm-slim

# Evita prompts interactivos de apt durante el build.
ENV DEBIAN_FRONTEND=noninteractive

# Cadena de compilacion (32 y 64 bits), depuracion, red y utilidades.
#   build-essential  -> gcc, make, libc de 64 bits
#   gcc-multilib     -> soporte -m32 (ELF de 32 bits)
#   gdb              -> depurador (pwndbg se instala aparte)
#   python3 + pip    -> exploits con pwntools
#   socat            -> exponer el binario por red (make serve)
#   file, xxd, etc.  -> analisis basico del binario
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc-multilib \
        gdb \
        python3 \
        python3-pip \
        python3-venv \
        socat \
        git \
        ca-certificates \
        file \
        xxd \
        ltrace \
        strace \
        procps \
        less \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

# Entorno virtual de Python: en Debian bookworm pip esta "externally managed",
# un venv evita romper el Python del sistema y mantiene la instalacion reproducible.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir pwntools

# pwndbg: extension de gdb para explotacion. Se clona una version fijada
# para que el entorno sea reproducible entre equipos.
RUN git clone --depth 1 --branch 2024.02.14 \
        https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg \
    && ./setup.sh

# Desactiva ASLR dentro del contenedor por defecto para depurar la vuln
# con direcciones estables. (Requiere ejecutar con --privileged o
# --cap-add=SYS_ADMIN; si no esta disponible, no falla el build.)
RUN echo 'set disable-randomization on' >> /root/.gdbinit

WORKDIR /work

CMD ["/bin/bash"]
