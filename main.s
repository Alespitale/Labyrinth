.data	
	laberinto: .dword 0x2b2d2d2d2d2b2d2b, 0x2b2d2d2d2d2d2d2d, 0x20202020207c587c, 0x7c2d20202020207c, 0x202b2d2d207c207c, 0x7c20202d2d2b207c, 0x207c2020207c207c, 0x7c202020207c207c, 0x207c202d2d2b207c, 0x2b2d2d20207c207c, 0x207c2020207c207c, 0x7c232020207c2020, 0x202b2d2d2d2d207c, 0x7c2d2d202020207c, 0x20207c202020207c, 0x7c2d2d2d2d2d207c, 0x7c2020207c20207c, 0x7c20202020207c20, 0x2d2b2d2d2d2d2d2b, 0x2b2d2d2d2d2b2d2d
	estado: .dword 0x4e45204f4745554a, 0x21214f5352554320
	_stack_ptr: .dword _stack_end   // Get the stack pointer value from memmap definition

.text	// Configuracion del Stack Pointer
	ldr     X1, _stack_ptr  
        mov     sp, X1          

	// Limpiar X0 y X4 siempre de comenzar el programa
	MOV X0, XZR
	MOV X4, XZR
	
	LDR X0, =laberinto	 //X0 = Dirección base del arreglo "laberinto"
main:
    MOV X9, #0x20       // Copio el caracter espacio en X9
 	bl busca		    // Salto a busca
    b p0
loop: b loop

/* Implemente una idea similar al algoritmo de mano izquierda incorporando p0...p3 como las 4 perspectivas
que podria tener el personaje dentro del laberinto. */

// La funcion busca encuentra la posicion del personaje X en el laberinto
busca:  MOV X5, X0      	    // Copio en X5 la direccion base del laberinto	    
        MOV X2, #0			    // i=0		
   for: ADD X5, X0, X2			// Voy recorriendo el arreglo del laberinto en busca de la "X"
		LDURB W12, 5[X, #0]		// Cargo en X12 el byte que estoy mirando del arreglo
		CMP W12, #0x58			// Lo comparo con el caracter "X"
		b.ne skip				// Si no son iguales salto a skip
		br x30					// Si es la X vuelvo al lugar desde donde llame a busca (breakpoint)
  skip: ADD X2, X2, #1			// ++i
		b for					// Vuelvo a ejecutar el ciclo

/* Esta funcion mueve el personaje una posicion arriba. Las 3 funciones de movimiento que restan hacen
lo mismo, pero moviendose a la direccion respectiva al nombre de cada funcion */

arriba: STURB W12, [X5, #-16]           // Muevo la X una posicion arriba de donde esta	
		STURB W9, [X5, #0]              // Pongo un espacio en la posicion donde estaba antes de moverla
        br X30                          //(breakpoint)

abajo: 	STURB W12, [X5, #16]
		STURB W9, [X5, #0]
        br X30                          //(breakpoint)

derecha:STURB W12, [X5, #1]
		STURB W9, [X5, #0]
        br X30                          //(breakpoint)

izquierda:STURB W12, [X5, #-1]
		  STURB W9, [X5, #0]
          br X30                        //(breakpoint)

// En esta funcion cargo el arreglo de estado para modificarlo por "GANASTE! B-)"
ganaste: LDR X4, =estado
		 MOV X6, X4
		 MOVK X10, #0x2145, LSL 48
		 MOVK X10, #0x5453, LSL 32
		 MOVK X10, #0x414e, LSL 16
		 MOVK X10, #0x4147, LSL 0
		 STUR X10, [X6, #0]
		 MOVK X10, #0x2020, LSL 48
		 MOVK X10, #0x2020, LSL 32
		 MOVK X10, #0x292d, LSL 16
		 MOVK X10, #0x4220, LSL 0
		 STUR X10, [X6, #8]
		 b loop							//(breakpoint)
/* 
Implemento las 4 perspectivas que puede tener el personaje, dependiendo hacia donde este "mirando".
De esta forma siempre en cada una de las perspectivas me pregunto si puedo girar hacia mi izquierda,
si puedo, lo hago y avanzo, cambiando asi de perspectiva. 
Si no puedo ir hacia mi izquierda, me pregunto si puedo ir hacia el frente, si es asi, avanzo 
quedandome en la misma perspectiva (es lo que hariamos normalmente al avanzar).
Si no puedo ir hacia mi izquierda, ni hacia adelante, me pregunto si puedo avanzar hacia mi derecha,
si es asi avanzo, cambiando a otra perspectiva. Y si no puedo ninguna de las 3 la opcion restante es
darme la vuelta y avanzar, cambiando tambien de perspectiva.
Luego en todas las perspectivas me voy a preguntar si encontre el tesoro (0x23), si es asi salto a la
funcion "ganaste" finalizando el juego.
*/

//izquierda a la izquierda
p0:		LDURB W7, [X5, #-1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq left0
		LDURB W7, [X5, #-16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq up0
		LDURB W7, [X5, #1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq right0
		LDURB W7, [X5, #16]
		CMP W7, #0x23
		b.eq ganaste
		bl abajo
        bl busca
		b p2
 right0:bl derecha
        bl busca
		b p3
	up0:bl arriba
        bl busca
		b p0
  left0:bl izquierda
        bl busca
		b p1

//izquierda abajo
p1:		LDURB W7, [X5, #16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq down1
		LDURB W7, [X5, #-1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq left1
		LDURB W7, [X5, #-16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq up1
		LDURB W7, [X5, #1]
		CMP W7, #0x23
		b.eq ganaste
		bl derecha
        bl busca
		b p3
  down1:bl abajo
        bl busca
		b p2
	up1:bl arriba
        bl busca
		b p0
  left1:bl izquierda
        bl busca
		b p1
//izquierda a la derecha
p2:		LDURB W7, [X5, #1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq right2
		LDURB W7, [X5, #16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq down2
		LDURB W7, [X5, #-1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq left2
		LDURB W7, [X5, #-16]
		CMP W7, #0x23
		b.eq ganaste
		bl arriba
        bl busca
		b p0
  down2:bl abajo
        bl busca
		b p2
 right2:bl derecha
        bl busca
		b p3
  left2:bl izquierda
        bl busca
		b p1

//izquierda arriba
p3:		LDURB W7, [X5, #-16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq up3
		LDURB W7, [X5, #1]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq right3
		LDURB W7, [X5, #16]
		CMP W7, #0x23
		b.eq ganaste
		CMP W7, #0x20
		b.eq down3
		LDURB W7, [X5, #-1]
		CMP W7, #0x23
		b.eq ganaste
		bl izquierda
        bl busca
		b p1
  down3:bl abajo
        bl busca
		b p2
 right3:bl derecha
        bl busca
		b p3
	up3:bl arriba
        bl busca
		b p0

/* Dado que voy a encontrarme con el tesoro en algun momento, no voy a llamar a la funcion
perdiste en ningun momento, pero la dejo por si acaso. */

// En esta funcion cargo el arreglo de estado para modificarlo por "perdiste :("
perdiste:LDR X4, =estado
		 MOV X6, X4
		 MOVK X10, #0x4554, LSL 48
		 MOVK X10, #0x5349, LSL 32
		 MOVK X10, #0x4452, LSL 16
		 MOVK X10, #0x4550, LSL 0
		 STUR X10, [X6, #0]
		 MOVK X10, #0x2020, LSL 48
		 MOVK X10, #0x2020, LSL 32
		 MOVK X10, #0x2028, LSL 16
		 MOVK X10, #0x3a20, LSL 0
		 STUR X10, [X6, #8]
		 b loop	
         