;*******************************************************************************
;                                PROGRAMA: TABLA_XOR
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripci�n: Este programa realiza las XOR entre los datos en la tabla DATOS
;y las m�scaras en la tabla M�SCARAS de forma inversa (la primera m�scara con
;el �ltimo dato, la segundo m�scara con el pen�ltimo dato, etc.). Adem�s, copia
;el resultado de aquellas XORs que resultaron ser negativo a partir de la 
;direcci�n NEGAT
;*******************************************************************************

;*******************************************************************************
;                        DECLARACI�N DE ESTRUCTURAS DE DATOS
;*******************************************************************************
        ORG         $1050
DATOS                DB $00, $00, $00, $80
        ORG         $1150
MASCARAS        DB $FF, $FF, $FF, $FE
        ORG        $1300
NEGAT                DS 1000

;*******************************************************************************
;                               PROGRAMA TABLA_XOR
;*******************************************************************************
        ORG $2000
        LDS #$3BFF                ;Definir la pila a partir de la primera direcci�n disponible para esta
        LDX #DATOS                ;Cargar direcci�n de la tabla DATOS
        LDY #NEGAT                ;Cargar direcci�n NEGAT para utilizarla posteriormente
        PSHY                        ;Apilar direcci�n NEGAT
        LDY #MASCARAS                 ;Cargar direcci�n de la tabla MASCARAS
SIGA        LDAA 1,X+                ;Cargar el siguiente dato de la tabla DATOS
        CMPA #$80                ;Verificar si el dato cargado es el indicador de fin de tabla para el tabla DATOS
        BEQ PROC1                 ;Saltar si ya se barri� la tabla DATOS
        BRA SIGA                ;Saltar si aun no se ha llegado al final de la tabla DATOS
PROC1        DEX                        ;Decrementar �ndice que apunta a la tabla DATOS para que apunte al pr�ximo dato a procesar y no el indicador de fin de tabla
        DEX
PROCESE        LDAA 1,X-                ;Cargar el dato anterior de la tabla DATOS
        EORA 0,Y                 ;Realizar la XOR entre el dato de la tabla DATOS y la m�scara de la tabla M�SCARAS de forma inversa
        loc
        BLT XOR_NEG                ;Saltar si el resultado de la XOR fue negativo
        BRA SIGA`                 ;Saltar si el resutado de la XOR fue positivo o cero
XOR_NEG        PSHY                         ;Apilar direcci�n del siguiente dato a procesar de la tabla MASCARAS
        LEAS 2,SP                ;Ajustar el puntero de pila para que apunte a la direcci�n del pr�ximo dato a cargar a partir de la direcci�n NEGAT
        PULY                        ;Desapilar la direcci�n del pr�ximo dato a cargar a partir de la direcci�n NEGAT
        STAA 1,Y+                ;Guardar el resultado de la XOR que fue negativo
        PSHY                         ;Apilar la direcci�n del pr�ximo dato a cargar a partir de la direcci�n NEGAT
        LEAS -2,SP                ;Ajustar el puntero de pila para que apunte a la direcci�n del pr�ximo dato a procesar en la tabla M�SCARAS
        PULY                         ;Cargar la direcci�n del pr�ximo dato a procesar en la tabla MASCARAS
SIGA`        INY                        ;Incrementar �ndice que apunta a la tabla M�SCARAS para que apunte al pr�ximo dato a procesar en la tabla
        LDAA 0,Y                ;Cargar el pr�ximo dato a procesar en la tabla M�SCARAS
        CMPA #$FE                ;Verificar si el dato cargado es el indicador de fin de tabla para la tabla MASCARAS
        BEQ FIN                        ;Saltar si ya se procesaron todos los datos de la tabla M�SCARAS
        CPX #DATOS                ;Verificar si ya se procesaron todos los datos de la tabla DATOS
        BLT FIN                        ;Saltar si ya se procesaron todos los datos de la tabla DATOS
        BRA PROCESE                ;Saltar si aun quedan datos por procesar
FIN        BRA *                        ;Fin del programa
;*******************************************************************************