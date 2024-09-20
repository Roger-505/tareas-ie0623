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

;*******************************************************************************
;                       	PROGRAMA PRINCIPAL
;*******************************************************************************


;*******************************************************************************
;                       	RUTINA: BIN_BCD
;
;Descripci�n: Esta rutina realiza la conversi�n de un n�mero binario de 12 bits 
;a BCD utilizando el algoritmo XS3. El n�mero binario est� en el acumulador D.
;La rutina coloca el resultado en la variable NUM_BCD ubiccada en la memoria a 
;partir de la posici�n $1010
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

;*******************************************************************************

