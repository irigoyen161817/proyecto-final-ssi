# Trabajo Final

## Descripción General

En este trabajo se pondrán en práctica los conceptos de Buffer Overflow estudiados durante las sesiones teóricas y prácticas de la asignatura. El objetivo es que el alumnado adquiera conocimientos básicos sobre explotación de binarios, así como sobre el desarrollo de exploits y módulos de explotación para la plataforma Metasploit.

Para ello, cada grupo dispondrá de un binario ubicado en su máquina de laboratorio (la máquina física asignada). Dicho binario comenzará a prestar servicio a partir de la próxima semana en la dirección `10.6.31.40` y en el puerto `42XX`, donde `XX` corresponderá al número de grupo asignado (por ejemplo, si pertenece al grupo SSI01 el puerto será el 4201).

## Primera Parte

Como primera tarea, se deberá desarrollar un programa en C que contenga una vulnerabilidad de tipo Buffer Overflow que permita redirigir la ejecución a una función específica.

Si el binario proporcionado al grupo es de 32 bits, el programa desarrollado deberá compilarse en 64 bits. En caso contrario, deberá compilarse en 32 bits.

Se deberá crear una aplicación en C con una interfaz de texto (TUI, Text User Interface) que incluya las siguientes funcionalidades. Se permite, e incluso se recomienda, el uso de herramientas de inteligencia artificial para asistir en el desarrollo del código.

### Interfaz TUI

- Menú principal con distintas opciones.
- Submenús para organizar las funcionalidades.
- Navegación entre menús con posibilidad de volver atrás.
- Pantalla de bienvenida y mensajes informativos.
- Gestión adecuada de opciones no válidas.
- Interfaz visualmente organizada mediante colores, marcos o caracteres ASCII.

### Gestión de Usuarios

- Registro de nuevos usuarios.
- Inicio de sesión (login).
- Validación de usuario y contraseña.
- Control de usuarios duplicados.
- Cierre de sesión (logout).
- Almacenamiento y recuperación de usuarios mediante ficheros locales.
- Acceso a la información asociada a cada usuario.

### Gestión de Datos

- Creación de nuevos registros.
- Consulta y listado de registros.
- Búsqueda utilizando diferentes criterios.
- Modificación de registros existentes.
- Eliminación de registros.
- Validación de los datos introducidos.

### Gestión de Ficheros

- Almacenamiento de información en ficheros locales.
- Lectura de datos al iniciar la aplicación.
- Escritura y actualización de la información.
- Persistencia de datos entre diferentes ejecuciones.
- Gestión de errores de lectura y escritura.

### Procesamiento de Información

- Implementación de, al menos, tres operaciones relacionadas con la temática elegida.
- Ordenación y filtrado de registros.
- Realización de cálculos, estadísticas o resúmenes.
- Generación de listados o informes.
- Operaciones que utilicen y procesen los datos almacenados.

### Organización y Funcionamiento

- División del programa en funciones independientes.
- Uso de variables locales, parámetros y valores de retorno.
- Utilización de estructuras (`struct`), arrays y punteros.
- Manipulación de cadenas de caracteres.
- Separación de la lógica del programa en diferentes funciones y módulos.
- Posibilidad de utilizar la aplicación durante diferentes sesiones conservando la información almacenada.

### Temática

La temática de la aplicación será completamente libre. No obstante, todas las funcionalidades implementadas deberán tener una utilidad real dentro de la aplicación desarrollada.

### Introducción de una Vulnerabilidad

- En lugar de buscar una vulnerabilidad en la aplicación desarrollada, se deberá introducir deliberadamente una vulnerabilidad explotable.
- Se modificará el código de forma que alguna de sus funcionalidades permita explotar un Buffer Overflow y redirigir la ejecución a una función denominada `win`.
- La función `win` deberá leer el contenido del fichero `./flag.txt` y mostrarlo por pantalla.
- Esta función no deberá ser invocada desde ninguna parte del flujo normal del programa. Únicamente estará presente en el conjunto de funciones compiladas dentro del binario.

### Explotación de la Vulnerabilidad

Se deberá desarrollar un exploit que permita alcanzar la función `win` y obtener el contenido de la flag.

### Entregables

- Código fuente completo del programa en C.
- Makefile necesario para compilar el binario.
- Binario compilado.
- Código del exploit desarrollado en Bash o Python.

Será obligatorio completar y entregar esta parte para poder realizar la segunda parte del trabajo.

## Segunda Parte

Se deberá desarrollar un exploit funcional para el binario proporcionado por el profesorado.

El objetivo consistirá en redirigir la ejecución hacia la función `execute_cmd`, la cual ejecuta un `/bin/bash` mediante una llamada a `system()`.

Para facilitar las pruebas en local, el servicio remoto puede emularse utilizando `socat` de la siguiente manera:

```bash
socat TCP-LISTEN:PUERTO,reuseaddr,fork EXEC:./binario
```

Se recomienda desarrollar y depurar el exploit en un entorno completamente controlado antes de utilizarlo contra el servicio remoto.

La explotación correcta permitirá recuperar la flag almacenada en `/flag/flag.txt`.

El sistema remoto utilizará el mismo binario que se ha proporcionado a cada grupo.

La flag obtenida deberá entregarse a través de la plataforma de envío de flags utilizada durante las prácticas.

### Entregables

- Código fuente del exploit desarrollado en Bash o Python.
- El exploit deberá aceptar como primer argumento la dirección IP y como segundo argumento el puerto del servicio objetivo.
- Entrega de la flag obtenida a través de la plataforma web de flags.

Será obligatorio completar y entregar esta parte para poder realizar la tercera parte del trabajo.

## Tercera Parte

Se deberá desarrollar un nuevo módulo de explotación para Metasploit que permita explotar remotamente la vulnerabilidad identificada.

El módulo deberá ser compatible con los payloads soportados por el sistema remoto y permitir la ejecución de cualquiera de ellos.

Se deberá verificar su funcionamiento utilizando, al menos, el payload Meterpreter.

Asimismo, el módulo deberá ser validado en un entorno limpio con una instalación estándar de Metasploit para comprobar que funciona correctamente y que no depende de configuraciones particulares del entorno de desarrollo.

### Entregables

- Código fuente en Ruby del módulo de explotación para Metasploit, listo para su utilización.

## Cuarta Parte

Se deberá elaborar un documento técnico describiendo el desarrollo realizado durante las distintas fases del proyecto.

El documento deberá incluir, entre otros aspectos:

- Problemas encontrados durante el desarrollo.
- Metodología seguida para localizar los errores o vulnerabilidades.
- Proceso de análisis realizado.
- Justificación técnica de las decisiones adoptadas.
- Explicación detallada del proceso de explotación realizado.

El documento deberá entregarse en formato Markdown (`.md`) y no podrá contener imágenes ni capturas de pantalla.

La extensión máxima del documento será de seis páginas.

### Entregables

- Documento técnico en formato Markdown.

Para entregar esta parte no será necesario haber completado las tres partes anteriores. El documento podrá describir únicamente aquellas partes del proyecto que se hayan realizado.
