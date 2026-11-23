# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Estado del repositorio

Solo contiene `README.md` (enunciado del trabajo final de Seguridad en Sistemas Informáticos, UPNA). Todavía no hay código, Makefile ni tests, así que no existen comandos de build/lint/test. Cuando se añadan, documentarlos aquí.

## Qué se va a construir (resumen del enunciado)

Trabajo en cuatro partes, cada una dependiente de la anterior (1 → 2 → 3; la 4 es independiente):

1. **App en C con TUI y Buffer Overflow deliberado**: gestión de usuarios, registros (CRUD, búsqueda, ordenación, estadísticas) y persistencia en ficheros locales. Una funcionalidad debe tener un overflow que permita redirigir la ejecución a `win()`, que lee `./flag.txt` y la muestra. `win()` no debe llamarse desde el flujo normal. Entregables: código C, Makefile, binario y exploit (Bash o Python).
2. **Exploit para el binario del profesorado**: redirigir a `execute_cmd` (ejecuta `/bin/bash` vía `system()`) y leer `/flag/flag.txt`. El exploit recibe IP como primer argumento y puerto como segundo. Servicio remoto: `10.6.31.40:42XX` (XX = nº de grupo). Prueba local: `socat TCP-LISTEN:PUERTO,reuseaddr,fork EXEC:./binario`.
3. **Módulo de Metasploit en Ruby** para la vulnerabilidad, compatible con cualquier payload del sistema remoto, probado al menos con Meterpreter y validado en una instalación limpia y estándar de Metasploit.
4. **Documento técnico en Markdown**: sin imágenes ni capturas, máximo 6 páginas (problemas, metodología, análisis, decisiones técnicas, explotación detallada).

## Restricciones a tener en cuenta

- **Arquitectura inversa en la parte 1**: si el binario del grupo (parte 2) es de 32 bits, la app propia se compila en 64 bits; si no, en 32 bits.
- La vulnerabilidad es intencionada y forma parte del trabajo académico; no "arreglarla" al refactorizar.
- Código modular: funciones independientes, `struct`, arrays, punteros, manipulación de cadenas, separación en módulos.
- El README está en español; mantener el idioma en documentación y mensajes de la TUI.
