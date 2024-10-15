;*******************************************************************************
;                     		PROGRAMA         T
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripción:
;*******************************************************************************
;*******************************************************************************
;                                       ENCABEZADO
;*******************************************************************************
INIT_PROGRAMA   EQU     $2000
INIT_IOT        EQU     $1500
INIT_BIN        EQU     $1600
INIT_DATOS      EQU     $1000
INIT_NIBBLES    EQU     $1010
INIT_MSG        EQU     $1030
INIT_PILA       EQU     $3BFF
GETCHAR         EQU     $EE84
PUTCHAR         EQU     $EE86
PRINTF          EQU     $EE88
CR              EQU     $0D
LF              EQU     $0A
FINMSG          EQU     $0
CERO_ASCII      EQU     $30
NUEVE_ASCII     EQU     $39
CINCO_ASCII     EQU     $35
DIEZ_16         EQU     $000A
DIEZ            EQU     $0A
DOS             EQU     $02
CUATRO          EQU     $04
MAX_EXPONENTE   EQU     $03
NIBBLE_INF      EQU     $0F
NIBBLE_SUP      EQU     $F0

;*******************************************************************************
;                        DECLARACIÓN DE ESTRUCTURAS DE DATOS
;*******************************************************************************
        ORG INIT_IOT
DATOS_IOT       FCC "0129"
                FCC "0729"
                FCC "3954"
                FCC "1875"
                FCC "0075"
                FCC "1536"
                FCC "0534"
                FCC "2755"
                FCC "2021"
                FCC "0389"
                FCC "0000"
                FCC "1329"
                FCC "1783"
                FCC "0009"
                FCC "2804"
                FCC "0064"
                FCC "0128"
                FCC "0256"
                FCC "0512"
                FCC "4095"

        ORG INIT_BIN
DATOS_BIN       DS      200
        ORG INIT_DATOS
CANT            DS      1
CONT            DS      1
OFFSET          DS      1
ACC             DS      2
        ORG INIT_NIBBLES
NIBBLE_UP       DW      $1630
NIBBLE_MED      DW      $1660
NIBBLE_LOW      DW      $1690
        ORG INIT_MSG
MSG1            FCC     "INGRESE EL VALOR DE CANT (ENTRE 1 Y 50):"
                DB      CR,CR,LF
                DB      FINMSG
MSG2            DB      CR,CR,LF,CR,CR,LF
                FCC     "CANTIDAD DE VALORES PROCESADOS: %d"
                DB      FINMSG
MSG3            DB      CR,CR,LF,CR,CR,LF
                FCC     "Nibble_UP: "
                DB      FINMSG
MSG4                FCC     "%x, "
                DB      FINMSG
MSG5                FCC     "%x"
                DB      FINMSG
MSG6            DB      CR,CR,LF,CR,CR,LF
                FCC     "Nibble_MED: "
                DB      FINMSG
MSG7            DB      CR,CR,LF,CR,CR,LF
                FCC     "Nibble_LOW: "
                DB      FINMSG
;*******************************************************************************
;                               PROGRAMA PRINCIPAL
;*******************************************************************************
        ;LDY #$0000              ;Inicializar índice para imprimir MSG1
        ;LDD #MSG1               ;Cargar dirección de mensaje de solicitud al usuario de CANT
        ;JSR [PRINTF,Y]          ;Imprimir mensaje por medio de printf
        
        ORG INIT_PROGRAMA
        LDS #INIT_PILA          ;Definición de pila
        JSR GETCANT             ;Saltar a subrutina para obtener CANT del usuario
        LDX #DATOS_BIN          ;Cargar dirección base de Datos_BIN
        PSHX                    ;Apilar dirección base de Datos_BIN
        LDX #DATOS_IOT          ;Cargar dirección base de Datos_IoT
        PSHX                    ;Apilar dirección base de Datos_IoT
        JSR ASBIN               ;Saltar a subrutina para que Datos_IoT -> Datos_BIN convertiendo de ASCII a binario
        LDX #DATOS_BIN          ;Cargar dirección base del arreglo Datos_BIN
        JSR MOVER               ;Saltar a subrutina que pone los Datos_BIN en Nibbles a partir de los punteros especificados
        JSR IMPRIM              ;Saltar a subrutina para imprimir nibbles en la terminal
        BRA *

;*******************************************************************************
;                               SUBRUTINA GET_CANT
;Descripción: Esta subrutina recibe un valor entre 1 y 50 del usuario a través
;de la terminal. El valor 00 no es aceptado. El programa retorna hasta que un
;número válido sea digitado
;*******************************************************************************
GETCANT LDY #$0000              ;Inicializar índice para imprimir MSG1
        LDD #MSG1               ;Cargar dirección de mensaje de solicitud al usuario de CANT
        JSR [PRINTF,Y]          ;Imprimir mensaje por medio de printf
        loc
SIGA`        LDY #$0000              ;Inicializar índice para obtener un caracter del usuario
        JSR [GETCHAR,Y]         ;Obtener dígito de las decenas de CANT del usuario
        CMPB #CERO_ASCII        ;Comparar valor digitado por el usuario con el mínimo valor
        BLO SIGA`               ;Saltar si el valor digitado está fuera del valor ASCII admitido
        CMPB #CINCO_ASCII       ;Comparar valor digitado por el usuario con el máximo valor
        BHI SIGA`                      ;Saltar si el valor digitado está fuera del valor ASCII admitido
        PSHB                    ;Apilar primer valor ASCII válido digitado
        SEX B,D                 ;Limpiar parte alta del acumulador B para imprimir el valor digitado
        LDY #$0000              ;Inicializar índice para imprimir un caracter
        JSR [PUTCHAR,Y]         ;Imprimir el dígito de las decenas de CANT digitado por el usuari
        loc
SIGA`        LDY #$0000              ;Inicializar índice para obtener un caracter del usuario
        JSR [GETCHAR,Y]         ;Obtener dígito de las unidades de CANT del usuario
        CMPB #CERO_ASCII        ;Comparar valor digitado por el usuario con el mínimo valor
        BLO SIGA`               ;Saltar si el valor digitado está fuera del rango ASCII aceptado
        CMPB #NUEVE_ASCII       ;Comparar valor digitado por el usuario con el máximo valor
        BHI SIGA`               ;Saltar si el valor digitado está fuera del rango ASCII aceptado
        CMPB #CERO_ASCII        ;Verificar si el valor digitado fue un cero para capturar el caso CANT=00
        BEQ CHECK               ;Saltar para comprobar si el primer digito obtenido tambien fue un cero
        BRA FIN_OBT             ;Saltar para empezar con el parsing de CANT de ASCII a BIN
CHECK   LDAB 0,SP               ;Cargar el primer valor digitado por el usuario
        CMPB #CERO_ASCII        ;Comparar primer valor digitado con cero
        BEQ SIGA`               ;Saltar a obtener nuevamente el valor digitado si CANT=00
FIN_OBT PSHB                    ;Apilar segundo valor ASCII válido digitado
        SEX B,D                 ;Limpiar parte alta del acumulador B para imprimir el valor digitado
        LDY #$0000              ;Inicializar índice para imprimir un caracter
        JSR [PUTCHAR,Y]         ;Imprimir el digito de las unidades de CANT digitado por el usuario
        LEAS 1,SP               ;Ajustar puntero de pila para que apunte a la dirección de memoria que almacena el dígito de las decenas
        PULB                    ;Cargar el dígito de las decenas
        LDAA #DIEZ              ;Cargar un diez para la conversion de ASCII a BIN
        SUBB #CERO_ASCII        ;Convertir dígito de las decenas de ASCII a BIN
        MUL                        ;Multiplicar dígito de las decenas por 10 para obtener su magntidud correcta
        LEAS -2,SP              ;Ajustar puntero de pila para que apunte a la dirección de memoria que almacena el dígito de las unidades
        LDAA 0,SP               ;Cargar valor ASCII de las unidades
        SUBA #CERO_ASCII        ;Convertir dígito de las uniddades de ASCII a BIN
        ABA                       ;Sumar decenas con unidades
        STAA CANT               ;Almacenar valor de CANT convertido de ASCII a BIN
        LEAS 2,SP               ;Ajustar puntero de pila para que apunte a la dirección de retorno
        RTS                     ;Retornar de la subrutina
;*******************************************************************************
;                               SUBRUTINA ASCII_BIN
;Descripción: Esta subrutina convierte valores de 12 bits representados en ASCII
;contenidos en la tabla Datos_IoT a binario, y copia los datos a la tabla Datos_BIN
;*******************************************************************************
ASBIN   LEAS 2,SP               ;Ajustar puntero de pila para acceder a direcciones base de tablas
        PULX                    ;Desapilar direccion base de Datos_IoT
        PULY                    ;Desapilar direccion base de Datos_BIN
        LEAS -6,SP              ;Reajustar puntero de pila para que apunte a la direccion de retorno
        CLR ACC                 ;Limpiar parte alta de variable temporal
        CLR ACC+1               ;Limpiar parte baja de variable temporal
        CLR CONT                ;Limpiar variable temporal
        CLR OFFSET              ;Limpiar variable contadora
        CLRA                    ;Limpiar acumulador A para indexar Datos_BIN
        PSHA                    ;Apilar acumulador A para indexar Datos_BIN
CARGUES        LDAA CONT               ;Cargar cantidad de datos procesados hasta el momento
        LSLA                    ;Multiplicar por dos cantidad de datos procesados
        LSLA                    ;Se multiplicó por 4 los datos ya que cada uno es de 4 bytes
        ADDA OFFSET             ;Obtener índice del byte actual a procesar
        LDAB A,X                ;Cargar byte a procesar
        SUBB #CERO_ASCII        ;Convertir valor ASCII a binario
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar dato cargado de Datos_IoT a 16 bits
        LDAB #MAX_EXPONENTE     ;Cargar la máxima potencia de 10 utilizada por los datos en Datos_IoT
        SUBB OFFSET                    ;Obtener exponente del byte que se está procesando actualmente
MULTI   TSTB                    ;Verificar si el exponente del byte que está procesaando actualmente es 0
        BEQ COPIE               ;Saltar si el exponente es 0 y no hay que multiplicarlo por 10
        PSHB                    ;Apilar exponente del byte que está procesando actualmente
        PSHY                    ;Apilar índice para hacer multiplicación de decadas a 16 bits
        LDY #DIEZ_16            ;Cargar un diez para hacer la multiplicacion de decadas
        LEAS 3,SP               ;Ajustar puntero de pila para que apunte al número convertido de ASCII a binario anteriormente
        PULD                    ;Cargar número de 0 a 9 convertido de ASCII a binario anteriormente
        EMUL                    ;Multiplicar valor ASCII convertido a binario por una decada
        PSHD                    ;Apilar multiplicacion de decada calculada
        LEAS -3,SP              ;Ajustar puntero de pila para que apunte al exponente del byte que se está procesando
        PULY                    ;Desapilar índice para barrer Datos_BIN
        PULB                    ;Desapilar exponente del byte que se está procesando
        DECB                    ;Decrementar exponente del byte que se está procesando
        BRA MULTI               ;Saltar para seguir multiplicando decadas
COPIE   PULD                    ;Desapilar valor calculado en la multiplicacion de decadas
        ADDD ACC                ;Sumar valor calculado con el valor calculado hasta el momento en ACC
        STD ACC                 ;Guardar valor calculado hasta el momento en ACC
        INC OFFSET              ;Incrementar offset para que se procese el siguiente en byte en el siguiente ciclo
        LDAA OFFSET             ;Cargar offset
        CMPA #CUATRO            ;Comparar offset con cuatro para verificar si ya se procesó el dato actual
        BEQ GUARDE              ;Saltar si ya se procesó el byte actual
        BRA CARGUES             ;Saltar si aun quedan bytes por procesar en el dato actual
GUARDE  PULA                    ;Desapilar registro para indexar la tabla Datos_BIN
        MOVW ACC,A,Y            ;Mover dato binario calculado a Datos_BIN
        ADDA #DOS               ;Ajustar registro para que el proximo dato transferido a Datos_BIN esté alineado por words
        PSHA                    ;Apilar registro para indexar Datos_BIN
        INC CONT                ;Incrementar contador de datos procesados
        LDAA CONT               ;Cargar contador de datos procesados
        CMPA CANT               ;Comparar cantidad de datos procesados con cantidad de datos totales
        BEQ FIN_AS                ;Saltar si ya se procesaron todos los datos
        BRA CARGUE              ;Seguir procesando datos si aun no se ha terminado de barrer la tabla Datos_IoT
FIN_AS  LEAS 1,S                ;Ajustar puntero de pila para que apunte a la dirección de retorno de la subrutina
        RTS                     ;Retornar de la subrutina
CARGUE  CLR ACC                 ;Limpiar parte alta de variable temporal
        CLR ACC+1               ;Limpiar parte baja de variable temporal
        CLR OFFSET              ;Limpiar variable contadora
        BRA CARGUES             ;Saltar con un valor de ACC y OFFSET limpios para el siguiente dato
;*******************************************************************************
;                               SUBRUTINA MOVER
;Descripción: Esta subrutina mueve los datos en la tabla Datos_BIN a las posiciones
;dadas por los punteros Nibble_UP, Nibble_MED, Nibble_LOW, colocando cada uno de los nibbles
;correspondientes en un byte en las direcciones indicadas por estos punteros.
;*******************************************************************************
MOVER   CLRA                    ;Limpiar contador de datos
SIGMOV  LDY NIBBLE_UP           ;Cargar dirección base a partir de donde se colocaran los nibbles altos
        MOVB 0,X,1,Y+           ;Mover byte superior del dato
        BCLR -1,Y,$F0             ;Obtener nibble inferior en el byte copiado a Nibble_UP
        STY NIBBLE_UP           ;Guardar dirección del próximo dato a procesar de Datos_BIN
        LDY NIBBLE_MED          ;Cargar dirección base a partir de donde se colocaran los nibbles intermedios
        MOVB 1,X,1,Y+           ;Mover byte inferior del dato
        BCLR -1,Y,$0F                ;Obtener nibble superior en el byte copiado a Nibble_MED
        STY NIBBLE_MED          ;Guardar dirección del próximo dato a procesar de Datos_BIN
        LDY NIBBLE_LOW          ;Cargar dirección base a partir de donde se colocaran los nibbles menores
        MOVB 1,X,1,Y+           ;Mover byte inferior del dato
        BCLR -1,Y,$F0                ;Obtener nibble inferior en el byte copiado a Nibble_LOW
        STY NIBBLE_LOW          ;Guardar dirección del próximo dato a procesar de Datos_BIN
        LEAX 2,X                ;Incrementar índice para que apunte al próximo dato a procesar
        INCA                    ;Incrementar el contador de datos procesados
        CMPA CANT               ;Comparar contador de datos procesados con cantidad total de datos
        BEQ FIN_MOV             ;Saltar si ya terminaron de procesar los datos
        BRA SIGMOV              ;Saltar si aun quedan datos por procesar
FIN_MOV RTS                     ;Retornar de la subrutina
;*******************************************************************************
;                               SUBRUTINA IMPRIMIR
;Descripción: Esta subrutina imprime en la terminal los nibbles ubicados en las
;posiciones Nibble_UP, Nibble_MED, y Nibble_LOW
;*******************************************************************************
IMPRIM  LDD NIBBLE_UP           ;Cargar dirección de Nibble_UP después de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_UP           ;Guardar puntero restituido
        LDD NIBBLE_MED          ;Cargar dirección de Nibble_MED después de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_MED          ;Guardar puntero restituido
        LDD NIBBLE_LOW          ;Cargar dirección de Nibble_LOW después de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_LOW          ;Guardar puntero restituido
        LDAB CONT               ;Cargar cantidad de datos procesados
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG2               ;Cargar dirección del mensaje a imprimir con el valor de CONT
        LDX #$0000              ;Limpiar índice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG2
        LDD #MSG3               ;Cargar dirección del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar índice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
        ASL CONT                ;Multiplicar cantidad de valores procesados por 2
        ASL CONT                ;Multiplicar cantidad de valores procesados por 2 para obtener la cantidad de nibbles
NIBB    ADDA #4                 ;Incrementar contador para verificar si se llegó al último nibble
        CMPA CONT               ;Verificar si se llegó al último nibble
        BEQ LAST_NI             ;Saltar si se llegó al último nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_UP           ;Cargar dirección base del arreglo Nibble_UP
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG4                ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
        BRA SIGA_NI             ;Saltar si aun no se ha llegado al último nibble
LAST_NI SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_UP           ;Cargar dirección base del arreglo Nibble_UP
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG5                ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
SIGA_NI JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB1               ;Ir a imprimir la siguiente clasificación de nibbles
        BRA NIBB
NIBB1	LDD #MSG6               ;Cargar dirección del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar índice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
NIBB2   ADDA #4                 ;Incrementar contador para verificar si se llegó al último nibble
        CMPA CONT               ;Verificar si se llegó al último nibble
        BEQ LAST_N1             ;Saltar si se llegó al último nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_MED          ;Cargar dirección base del arreglo Nibble_UP
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG4               ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
        BRA SIGA_N1             ;Saltar si aun no se ha llegado al último nibble
LAST_N1 SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_MED          ;Cargar dirección base del arreglo Nibble_UP
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG5               ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
SIGA_N1 JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB3               ;Ir a imprimir la siguiente clasificación de nibbles
        BRA NIBB2
NIBB3
	LDD #MSG7               ;Cargar dirección del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar índice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
NIBB4   ADDA #4                 ;Incrementar contador para verificar si se llegó al último nibble
        CMPA CONT               ;Verificar si se llegó al último nibble
        BEQ LAST_N4             ;Saltar si se llegó al último nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_LOW          ;Cargar dirección base del arreglo Nibble_LOW
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG4                ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
        BRA SIGA_N4             ;Saltar si aun no se ha llegado al último nibble
LAST_N4 SUBA #4                 ;Decrementar contador debido a que previamente se incrementó para verificar
        PSHA                    ;Apilar contador para que sea conservado después de ejecutar printf
        LDX NIBBLE_LOW           ;Cargar dirección base del arreglo Nibble_LOW
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar parámetro para printf
        LDD #MSG5                ;Cargar dirección del mensaje a desplegar
        LDX #$0000              ;Limpiar índice para hacer llamado a printf
SIGA_N4 JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB5               ;Ir a imprimir la siguiente clasificación de nibbles
        BRA NIBB4
NIBB5   RTS
