;*******************************************************************************
;				PROGRAMA: DIVISIBLE_4
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripci�n: Este programa copia aquellos valores del arreglo DATOS al arreglo
;DIV4 que son divisibles por 4. Adicionalmente, calcula la cantidad de n�meros 
;divisibles por 4 y se almacena en la variable CANT4
;*******************************************************************************

;*******************************************************************************
;			DECLARACI�N DE ESTRUCTURAS DE DATOS
;*******************************************************************************
	ORG 	$1000
L	DB	$04
CANT4	DS	1
OFF_DAT	DS	1
OFF_4	DS 	1
	ORG 	$1100
DATOS	DB 	$05, $08, $10, $20
	ORG 	$1200
DIV4	DS 	255
;*******************************************************************************
;                       	PROGRAMA DIVISIBLE_4
;*******************************************************************************
	ORG $2000
	LDX #DATOS		;Cargar direcci�n base del arreglo DATOS
	LDY #DIV4		;Cargar direcci�n base del arreglo DIV4
	CLR OFF_DAT		;Limpiar offset para indexar el arreglo DATOS
	CLR OFF_4		;Limpiar offset para indexar el arreglo DIV4
	CLR CANT4		;Limpiar contador de n�meros divisibles por 4
SIGA	LDAB OFF_DAT		;Cargar offset para indexar el arreglo DATOS
	LDAA B,X		;Cargar dato del arreglo DATOS
	INC OFF_DAT		;Incrementar offset 
	BITA #$03		;Verificar los dos bits menos significativos para verificar si es divisible por 4
	BEQ COPIE		;Saltar si el dato es divisible por 4
	loc
	BRA SIGA`		;Saltar si el dato no es divisible por 4
COPIE	INC CANT4		;Incrementar contador de datos divisibles por 4
	LDAB OFF_4		;Cargar offset para indexar el arreglo DIV4
	STAA B,Y		;Guardar dato divisble por 4 en el arreglo DIV4
	INC OFF_4		;Incrementar offset 
SIGA`	LDAB OFF_DAT		;Cargar la cantidad de datos procesados hasta el momento 
	LDAA L			;Cargar el n�mero de datos del arreglo DATOS
	CBA			;Verificar si ya se termin� de barrer el arreglo DATOS
	BEQ FIN			;Saltar si ya se termin� de barrer el arreglo DATOS
	BRA SIGA		;Saltar si aun faltan datos por procesar en el arreglo DATOS
FIN	BRA *			;Fin del programa
;*******************************************************************************
