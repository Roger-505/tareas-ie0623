;*******************************************************************************
;                                PROGRAMA: TABLA_XOR
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripción: Este programa realiza las XOR entre los datos en la tabla DATOS
;y las máscaras en la tabla MÁSCARAS de forma inversa (la primera máscara con
;el último dato, la segundo máscara con el penúltimo dato, etc.). Además, copia
;el resultado de aquellas XORs que resultaron ser negativo a partir de la 
;dirección NEGAT
;*******************************************************************************

;*******************************************************************************
;                        DECLARACIÓN DE ESTRUCTURAS DE DATOS
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
        LDS #$3BFF                ;Definir la pila a partir de la primera dirección disponible para esta
        LDX #DATOS                ;Cargar dirección de la tabla DATOS
        LDY #NEGAT                ;Cargar dirección NEGAT para utilizarla posteriormente
        PSHY                        ;Apilar dirección NEGAT
        LDY #MASCARAS                 ;Cargar dirección de la tabla MASCARAS
SIGA        LDAA 1,X+                ;Cargar el siguiente dato de la tabla DATOS
        CMPA #$80                ;Verificar si el dato cargado es el indicador de fin de tabla para el tabla DATOS
        BEQ PROC1                 ;Saltar si ya se barrió la tabla DATOS
        BRA SIGA                ;Saltar si aun no se ha llegado al final de la tabla DATOS
PROC1        DEX                        ;Decrementar índice que apunta a la tabla DATOS para que apunte al próximo dato a procesar y no el indicador de fin de tabla
        DEX
PROCESE        LDAA 1,X-                ;Cargar el dato anterior de la tabla DATOS
        EORA 0,Y                 ;Realizar la XOR entre el dato de la tabla DATOS y la máscara de la tabla MÁSCARAS de forma inversa
        loc
        BLT XOR_NEG                ;Saltar si el resultado de la XOR fue negativo
        BRA SIGA`                 ;Saltar si el resutado de la XOR fue positivo o cero
XOR_NEG        PSHY                         ;Apilar dirección del siguiente dato a procesar de la tabla MASCARAS
        LEAS 2,SP                ;Ajustar el puntero de pila para que apunte a la dirección del próximo dato a cargar a partir de la dirección NEGAT
        PULY                        ;Desapilar la dirección del próximo dato a cargar a partir de la dirección NEGAT
        STAA 1,Y+                ;Guardar el resultado de la XOR que fue negativo
        PSHY                         ;Apilar la dirección del próximo dato a cargar a partir de la dirección NEGAT
        LEAS -2,SP                ;Ajustar el puntero de pila para que apunte a la dirección del próximo dato a procesar en la tabla MÁSCARAS
        PULY                         ;Cargar la dirección del próximo dato a procesar en la tabla MASCARAS
SIGA`        INY                        ;Incrementar índice que apunta a la tabla MÁSCARAS para que apunte al próximo dato a procesar en la tabla
        LDAA 0,Y                ;Cargar el próximo dato a procesar en la tabla MÁSCARAS
        CMPA #$FE                ;Verificar si el dato cargado es el indicador de fin de tabla para la tabla MASCARAS
        BEQ FIN                        ;Saltar si ya se procesaron todos los datos de la tabla MÁSCARAS
        CPX #DATOS                ;Verificar si ya se procesaron todos los datos de la tabla DATOS
        BLT FIN                        ;Saltar si ya se procesaron todos los datos de la tabla DATOS
        BRA PROCESE                ;Saltar si aun quedan datos por procesar
FIN        BRA *                        ;Fin del programa
;*******************************************************************************