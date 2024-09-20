;*******************************************************************************
;				PROGRAMA: CONVERSIONES
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripción: Este programa copia el valor de BIN al acumulador D e implementa
;el código de la rutina BIN_BCD, luego el programa copia el valor de BCD en el
;acumulador D y se implementa el código de la ruitna BCD_BIN.
;*******************************************************************************

;*******************************************************************************
;			DECLARACIÓN DE ESTRUCTURAS DE DATOS
;*******************************************************************************

;*******************************************************************************
;                       	PROGRAMA PRINCIPAL
;*******************************************************************************


;*******************************************************************************
;                       	RUTINA: BIN_BCD
;
;Descripción: Esta rutina realiza la conversión de un número binario de 12 bits 
;a BCD utilizando el algoritmo XS3. El número binario está en el acumulador D.
;La rutina coloca el resultado en la variable NUM_BCD ubiccada en la memoria a 
;partir de la posición $1010
;*******************************************************************************


;*******************************************************************************
;				RUTINA: BCD_BIN
;
;Descripción: Esta rutina realiza la conversión de un número BCD a binario uti-
;lizando el método de mutliplicación de décadas y suma. El número en BCD es me-
;nor o igual a 9999 y está ubicado en el acumulador D. La subrutina guarda el 
;resultado en las posiciones de memoria NUM_BIN ubicadas a partir de la dire-
;cción $1020
;*******************************************************************************

;*******************************************************************************

