;*******************************************************************************
;				PROGRAMA: CONVERSIONES
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripci�n: Este programa copia el valor de BIN al acumulador D e implementa
;el c�digo de la rutina BIN_BCD, luego el programa copia el valor de BCD en el
;acumulador D y se implementa el c�digo de la ruitna BCD_BIN.
;*******************************************************************************

;*******************************************************************************
;			DECLARACI�N DE ESTRUCTURAS DE DATOS
;*******************************************************************************
	ORG 	$1000
BIN	DW  	$0A8F
BCD	DS	2

	ORG $1010
NUM_BCD	DS	2
	ORG $1020
NUM_BIN	DS	2
SHIFTS	DS	1
TEMP	DS	2
LOW	DS	1
HIGH	DS	1
BCD_TEMP DS 2
;*******************************************************************************
;                       	PROGRAMA CONVERSIONES
;*******************************************************************************
	ORG $2000
	LDD BIN			;Cargar valor binario a convertir a BCD
	BRA BIN_BCD		;Implementar rutina BIN_BCD
SIGABCD	MOVW NUM_BCD,BCD	;Copiar el resultado de BIN_BCD a la variable BCD
	LDD BCD			;Cargar valor BCD a convertir a binario
	BRA BCD_BIN		;Implementar rutina BCD_BIN
SIGABIN BRA *			;Fin del programa

;*******************************************************************************
;                       	RUTINA: BIN_BCD
;
;Descripci�n: Esta rutina realiza la conversi�n de un n�mero binario de 12 bits 
;a BCD utilizando el algoritmo XS3. El n�mero binario est� en el acumulador D.
;La rutina coloca el resultado en la variable NUM_BCD ubiccada en la memoria a 
;partir de la posici�n $1010
;*******************************************************************************
BIN_BCD
	MOVB #11,SHIFTS		;Incializar canitdad de desplazamientos a realizar
	CLR NUM_BCD+1		;Limpiar parte baja del resultado
	CLR NUM_BCD		;Limpiar parte alta del resultado
	LDY #$0010		;Cargar valor para desplazar NUM_BCD un nibble a la izquierda
	EMUL			;Justificar 12 bits de NUM_BCD a la izquierda del acumulador D
SIGA	LSLB			;Desplazar a la izquierda la parte baja del valor binario
	ROLA			;Rotar a la izquierda la parte alta del valor binario
	ROL NUM_BCD+1		;Rotar a la izquierda la parte baja del resultado
	ROL NUM_BCD		;Rotar a la izquierda la parte alta del resultado	
	STD TEMP		;Almacenar temporalmente el valor binario
	loc
	LDAA NUM_BCD+1		;Cargar byte en la parte baja del resultado
	ANDA #$0F		;Obtener nibble en la parte baja del byte en la parte baja del resultado
	CMPA #$05		;Comparar el nibble con 5
	BHS SUME3`		;Si el nibble es mayor o igual que 5, ir a sumarle 3 
	BRA SIGA3`		;Si el nibble es menor que 5, no sumarle 3
SUME3`	ADDA #$03		;Sumarle 3 al nibble 
SIGA3`	STAA LOW		;Guardar temporalmente el nibble obtenido 
	LDAA NUM_BCD+1		;Cargar byte en la parte baja del resultado
	ANDA #$F0		;Obtener nibble en la parte alta del byte en la parte baja del resultado
	CMPA #$50		;Comparar el nibble con 5
	BHS SUME30		;Si el nibble es mayor o igual que 5, ir a sumarle 3
	BRA SIGA30		;Si el nibble es menor que 5, no sumarle 3
SUME30  ADDA #$30		;Sumarle 3 al nibble
SIGA30  ADDA LOW 		;Obtener byte en la parte baja del resultado al sumar ambos nibbles calculados
	STAA NUM_BCD+1		;Guardar el byte calculado en la parte baja del resultado
	loc
	LDAA NUM_BCD		;Cargar el byte en la parte alta del resultado
	ANDA #$0F		;Obtener nibble en la parte baja del byte en la parte alta del resultado
	CMPA #$05		;Comparar el nibble con 5
	BHS SUME3`		;Si el nibble es mayor o igual que 5, ir a sumarle 3
	BRA SIGA3`		;Si el nibble es menor que 5, no sumarle 3
SUME3`	ADDA #$03		;Sumarle 3 al nibble
SIGA3`	MOVB NUM_BCD,HIGH	;Mover byte en la parte alta del resultado a una variable temporal
	BCLR HIGH,$0F		;Obtener el �ltimo nibble del resultado 
	ADDA HIGH		;Obtener el byte en la parte alta del resultado al sumar ambos nibbles calculados
	STAA NUM_BCD		;Guardar el byte calculado en la parte alta del resultado
	LDD TEMP		;Cargar valor binario que hab�a sido guardado temporalmente
	DEC SHIFTS		;Decrementar la cantidad de desplazamientos a realizar
	BEQ SHIFT_F		;Si ya se realizaron 11 desplazamientos, hacer el �ltimo desplazamiento para terminar
	BRA SIGA		;Seguir con el algoritmo XS3
SHIFT_F	LSLB			;Desplazar a la izquierda la parte baja del valor binario
	ROLA			;Rotar a la izquierda la parte alta del valor binario
	ROL NUM_BCD+1		;Rotar a la izquierda la parte baja del resultado
	ROL NUM_BCD		;Rotar a la izquierda la parte alta del resultado	
	BRA SIGABCD		;Fin de la rutina
	loc
;*******************************************************************************

;*******************************************************************************
;				RUTINA: BCD_BIN
;
;Descripci�n: Esta rutina realiza la conversi�n de un n�mero BCD a binario uti-
;lizando el m�todo de mutliplicaci�n de d�cadas y suma. El n�mero en BCD es me-
;nor o igual a 9999 y est� ubicado en el acumulador D. La subrutina guarda el 
;resultado en las posiciones de memoria NUM_BIN ubicadas a partir de la dire-
;cci�n $1020
;*******************************************************************************
BCD_BIN
	CLR NUM_BIN		;Limpiar la parte alta del resultado
	CLR NUM_BIN+1		;Limpiar la parte baja del resultado
	STD BCD_TEMP		;Guardar el valor BCD a convertir temporalmente
	LDY #$0001		;Cargar la d�cada 1
	CLRA 			;Limpiar la parte alta del valor BCD
	ANDB #$0F		;Obtener el nibble en la posici�n 0 del valor BCD
	EMUL 			;Multiplicar nibble con la d�cada 1
	STD NUM_BIN		;Guardar el resultado de la multiplicaci�n
	LDY #$000A		;Cargar la d�cada 10
	LDD BCD_TEMP		;Cargar el valor BCD
	CLRA 			;Limpiar la parte alta del valor BCD
	ANDB #$F0		;Obtener el nibble en la posici�n 1 del valor BCD
	LSRB			;Justificar el nibble a la derecha del acumulador D
	LSRB
	LSRB
	LSRB
	EMUL			;Multiplicar nibble con la d�cada 10
	ADDD NUM_BIN		;Sumar la multiplicaci�n obtenida con el valor de NUM_BIN hasta el momento
	STD NUM_BIN		;Guardar el valor de NUM_BIN hasta el momento
	LDY #$0064		;Cargar la d�cada 100
	LDD BCD_TEMP		;Cargar el valor BCD
	ANDA #$0F		;Obtener el nibble en la posici�n 2 del valor BCD
	TFR A,B			;Colocar nibble en la parte baja del acumulador D
	CLRA			;Limpiar la parte alta del acumulador D
	EMUL			;Multiplicar nibble con la d�cada 100
	ADDD NUM_BIN		;Sumar la multiplicaci�n obtenida con el valor de NUM_BIN hasta el momento
	STD NUM_BIN		;Guardar el valor de NUM_BIN hasta el momento
	LDY #$03E8		;Cargar la d�cada 1000
	LDD BCD_TEMP		;Cargar el valor BCD
	ANDA #$F0		;Obtener el nibble en la posici�n 3 del valor BCD
	LSRA			;Justificar el nibble a la derecha del acumulador D
	LSRA
	LSRA
	LSRA
	TFR A,B			;Colocar nibble en la parte baja del acumulador D
	CLRA			;Limpiar la parte alta del acumulador D
	EMUL			;Multiplicar nibble con la d�cada 1000
	ADDD NUM_BIN		;Sumar la multiplicaci�n obtenida con el valor de NUM_BIN hasta el momento
	STD NUM_BIN		;Guardar el valor de NUM_BIN hasta el momento
	LBRA SIGABIN		;Fin de la rutina
;*******************************************************************************
