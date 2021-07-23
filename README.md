# Labyrinth

## Instrucciones de compilacion:

En la terminal, sobre la carpeta Laberinto ejecutar el comando "make"
Luego ejecutar la sig. linea de comando:
qemu-system-aarch64 -s -S -machine virt -cpu cortex-a53 -machine type=virt -nographic -smp 1 -m 64 -kernel kernel.img

Abriendo una pestaña nueva desde la terminal, ejecutar:
gdb-multiarch -ex "set architecture aarch64" \-ex "target remote localhost:1234" \-ex "add-symbol-file main.o 0x40080000" \-ex "stepi 11"

Al iniciar el qemu aceptar la carga de los simbolos del main apretando "y" seguido de "enter"

Despues ejecutar los siguientes comandos:

dashboard memory watch 0x400802d0 112		// Para ver el laberinto
dashboard memory watch 0x40080340 16		// Para ver el status
b 40
b 44
b 48
b 52
b 67
continue
Luego presionar "enter" repetidas veces hasta llegar al tesoro #.
