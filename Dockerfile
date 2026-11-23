# Entorno canonico del Trabajo Final de SSI (grupo SSI20).
# Contenedor amd64 reproducible en Windows y Mac (en Apple Silicon corre emulado).
# Ver docs/DECISIONES.md para el porque de cada herramienta.
#
# Construir:  docker build --platform linux/amd64 -t ssi20 .
# Usar:       docker run --platform linux/amd64 -it --rm -v "$PWD":/work ssi20
#
# El contenedor corre como root. En la maquina Linux del laboratorio (donde se monta
# el repo con -v) los ficheros generados quedarian propiedad de root; para evitarlo,
# ejecutar mapeando el usuario del host:
#   docker run --platform linux/amd64 -it --rm -u "$(id -u):$(id -g)" -v "$PWD":/work ssi20
#
# --platform fuerza amd64 para poder compilar y depurar ELF x86 aunque el host sea ARM.

# Base fijada a un tag datado (reproducible entre equipos y en el tiempo).
FROM --platform=linux/amd64 debian:bookworm-20241223-slim

# Evita prompts interactivos de apt durante el build.
ENV DEBIAN_FRONTEND=noninteractive

# Cadena de compilacion (32 y 64 bits), depuracion, red y utilidades.
#   build-essential  -> gcc, make, libc de 64 bits
#   gcc-multilib     -> soporte -m32 (ELF de 32 bits)
#   gdb              -> depurador (pwndbg se instala aparte, mas abajo)
#   python3 + pip    -> exploits con pwntools
#   socat            -> exponer el binario por red (make serve)
#   sudo             -> el setup.sh de pwndbg lo invoca; como root actua de passthrough
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
        sudo \
        ca-certificates \
        file \
        xxd \
        ltrace \
        strace \
        procps \
        less \
        vim-tiny \
    && rm -rf /var/lib/apt/lists/*

# Entorno virtual de Python para pwntools: en Debian bookworm pip esta
# "externally managed"; el venv evita romper el Python del sistema y fija la version.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir pwntools==4.15.1

# pwndbg: extension de gdb para explotacion. No se publica en PyPI, asi que la via
# soportada es clonar una version fijada e instalarla con su propio setup.sh (crea su
# venv dedicado para la Python embebida de gdb). El setup.sh usa `sudo`, por eso se
# instala arriba; al correr como root durante el build, `sudo` es un passthrough.
# Paso fragil por diseno: si una version de setup.sh cambia su comportamiento, aqui
# es donde habra que ajustar (pinear otro tag).
RUN git clone --depth 1 --branch 2024.02.14 \
        https://github.com/pwndbg/pwndbg /opt/pwndbg \
    && cd /opt/pwndbg \
    && ./setup.sh

# gdbinit del sistema (aplica a cualquier usuario, no solo root): desactiva la
# aleatorizacion del proceso depurado para trabajar con direcciones estables.
# `disable-randomization` ya es el valor por defecto de gdb; se deja explicito como
# documentacion. Actua via personality(ADDR_NO_RANDOMIZE) sobre el hijo depurado,
# no desactiva el ASLR global del sistema, por lo que no necesita privilegios extra.
RUN mkdir -p /etc/gdb \
    && echo 'set disable-randomization on' >> /etc/gdb/gdbinit \
    && echo 'source /opt/pwndbg/gdbinit.py' >> /etc/gdb/gdbinit \
    # setup.sh ya anade el `source` de pwndbg al ~/.gdbinit del usuario de build
    # (root). Al tenerlo tambien en el gdbinit del sistema, correr como root cargaria
    # pwndbg dos veces (gdb protesta al arrancar). Se elimina la copia de root para
    # que la unica fuente sea /etc/gdb/gdbinit (vale para root y para UID mapeado).
    && sed -i '/pwndbg\/gdbinit.py/d' /root/.gdbinit 2>/dev/null || true

WORKDIR /work

CMD ["/bin/bash"]
