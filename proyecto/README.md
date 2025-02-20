# Proyecto Final IE0623 - Selector 623

Este proyecto consiste en un programa escrito en lenguaje ensamblador para la tarjeta Dragon12 68HC12. El código implementa diversas funcionalidades utilizando interrupciones, máquinas de estado, y manejo de hardware para controlar un sistema basado en un selector con una interfaz LCD y teclado matricial.

## Estructura del Repositorio

El repositorio contiene los siguientes archivos:

- **Makefile**: Permite la compilación y carga del programa en la placa Dragon12, así como la simulación.
- **registers.inc**: Definiciones y configuraciones para el programa.
- **.asm (Archivo principal)**: El código en ensamblador.
- **Reporte del Proyecto (PDF)**: Un documento explicativo sobre el funcionamiento y estructura del programa.

## Descripción del Proyecto

El programa se encarga de gestionar las tareas y máquinas de estado de un Selector 623. Utiliza un teclado matricial para permitir al usuario ingresar datos, controla LEDs y visualiza información en una pantalla LCD. Las tareas incluyen modos de operación como "STOP", "CONFIGURAR" y "SELECCIONAR". Además, el código incluye funciones para interactuar con el hardware de la placa Dragon12, como timers y control de interrupciones.

## Requisitos

Para compilar y cargar el programa en la tarjeta Dragon12, asegúrate de tener instalados los siguientes componentes:

- **Assemble**: Herramienta de ensamblador `as12`.
- **Simulador**: `sim68cs12` para simular el programa en un entorno de prueba.
- **Puertos Seriales**: La placa Dragon12 debe estar conectada al puerto serial adecuado en tu sistema.

Estos deben ser agregados al `PATH` como ejecutables de bash a partir de los archivos proporcionados por el profesor, haciendo uso de un virtualizador como `wine`.

## Compilación y Carga

1. **Compilación**: Utiliza el siguiente comando para ensamblar el archivo:

   ```bash
   make
   ```

2. **Cargar a la placa**: Conecta la placa Dragon12 a tu computadora y utiliza el siguiente comando para cargar el programa a la memoria RAM de la placa:

   ```bash
   make load
   ```

3. **Ejecutar**: Una vez cargado el programa, se ejecutará automáticamente en la placa. Para iniciar la ejecución, puedes usar:

   ```bash
   make run
   ```

4. **Limpiar**: Para eliminar los archivos generados durante la compilación, utiliza el siguiente comando:

   ```bash
   make clean
   ```

## Documentación

La documentación completa del proyecto está disponible en el archivo PDF incluido en este repositorio. 
El documento detalla la estructura del programa, las máquinas de estado, la interacción con el hardware y las tareas implementadas.
