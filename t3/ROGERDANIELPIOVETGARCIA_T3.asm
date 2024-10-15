;*******************************************************************************
;                     		PROGRAMA         T
;*******************************************************************************
;       V1.0
;       AUTOR: Roger Piovet
;
;Descripci�n:
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
;                        DECLARACI�N DE ESTRUCTURAS DE DATOS
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
        ;LDY #$0000              ;Inicializar �ndice para imprimir MSG1
        ;LDD #MSG1               ;Cargar direcci�n de mensaje de solicitud al usuario de CANT
        ;JSR [PRINTF,Y]          ;Imprimir mensaje por medio de printf
        
        ORG INIT_PROGRAMA
        LDS #INIT_PILA          ;Definici�n de pila
        JSR GETCANT             ;Saltar a subrutina para obtener CANT del usuario
        LDX #DATOS_BIN          ;Cargar direcci�n base de Datos_BIN
        PSHX                    ;Apilar direcci�n base de Datos_BIN
        LDX #DATOS_IOT          ;Cargar direcci�n base de Datos_IoT
        PSHX                    ;Apilar direcci�n base de Datos_IoT
        JSR ASBIN               ;Saltar a subrutina para que Datos_IoT -> Datos_BIN convertiendo de ASCII a binario
        LDX #DATOS_BIN          ;Cargar direcci�n base del arreglo Datos_BIN
        JSR MOVER               ;Saltar a subrutina que pone los Datos_BIN en Nibbles a partir de los punteros especificados
        JSR IMPRIM              ;Saltar a subrutina para imprimir nibbles en la terminal
        BRA *

;*******************************************************************************
;                               SUBRUTINA GET_CANT
;Descripci�n: Esta subrutina recibe un valor entre 1 y 50 del usuario a trav�s
;de la terminal. El valor 00 no es aceptado. El programa retorna hasta que un
;n�mero v�lido sea digitado
;*******************************************************************************
GETCANT LDY #$0000              ;Inicializar �ndice para imprimir MSG1
        LDD #MSG1               ;Cargar direcci�n de mensaje de solicitud al usuario de CANT
        JSR [PRINTF,Y]          ;Imprimir mensaje por medio de printf
        loc
SIGA`        LDY #$0000              ;Inicializar �ndice para obtener un caracter del usuario
        JSR [GETCHAR,Y]         ;Obtener d�gito de las decenas de CANT del usuario
        CMPB #CERO_ASCII        ;Comparar valor digitado por el usuario con el m�nimo valor
        BLO SIGA`               ;Saltar si el valor digitado est� fuera del valor ASCII admitido
        CMPB #CINCO_ASCII       ;Comparar valor digitado por el usuario con el m�ximo valor
        BHI SIGA`                      ;Saltar si el valor digitado est� fuera del valor ASCII admitido
        PSHB                    ;Apilar primer valor ASCII v�lido digitado
        SEX B,D                 ;Limpiar parte alta del acumulador B para imprimir el valor digitado
        LDY #$0000              ;Inicializar �ndice para imprimir un caracter
        JSR [PUTCHAR,Y]         ;Imprimir el d�gito de las decenas de CANT digitado por el usuari
        loc
SIGA`        LDY #$0000              ;Inicializar �ndice para obtener un caracter del usuario
        JSR [GETCHAR,Y]         ;Obtener d�gito de las unidades de CANT del usuario
        CMPB #CERO_ASCII        ;Comparar valor digitado por el usuario con el m�nimo valor
        BLO SIGA`               ;Saltar si el valor digitado est� fuera del rango ASCII aceptado
        CMPB #NUEVE_ASCII       ;Comparar valor digitado por el usuario con el m�ximo valor
        BHI SIGA`               ;Saltar si el valor digitado est� fuera del rango ASCII aceptado
        CMPB #CERO_ASCII        ;Verificar si el valor digitado fue un cero para capturar el caso CANT=00
        BEQ CHECK               ;Saltar para comprobar si el primer digito obtenido tambien fue un cero
        BRA FIN_OBT             ;Saltar para empezar con el parsing de CANT de ASCII a BIN
CHECK   LDAB 0,SP               ;Cargar el primer valor digitado por el usuario
        CMPB #CERO_ASCII        ;Comparar primer valor digitado con cero
        BEQ SIGA`               ;Saltar a obtener nuevamente el valor digitado si CANT=00
FIN_OBT PSHB                    ;Apilar segundo valor ASCII v�lido digitado
        SEX B,D                 ;Limpiar parte alta del acumulador B para imprimir el valor digitado
        LDY #$0000              ;Inicializar �ndice para imprimir un caracter
        JSR [PUTCHAR,Y]         ;Imprimir el digito de las unidades de CANT digitado por el usuario
        LEAS 1,SP               ;Ajustar puntero de pila para que apunte a la direcci�n de memoria que almacena el d�gito de las decenas
        PULB                    ;Cargar el d�gito de las decenas
        LDAA #DIEZ              ;Cargar un diez para la conversion de ASCII a BIN
        SUBB #CERO_ASCII        ;Convertir d�gito de las decenas de ASCII a BIN
        MUL                        ;Multiplicar d�gito de las decenas por 10 para obtener su magntidud correcta
        LEAS -2,SP              ;Ajustar puntero de pila para que apunte a la direcci�n de memoria que almacena el d�gito de las unidades
        LDAA 0,SP               ;Cargar valor ASCII de las unidades
        SUBA #CERO_ASCII        ;Convertir d�gito de las uniddades de ASCII a BIN
        ABA                       ;Sumar decenas con unidades
        STAA CANT               ;Almacenar valor de CANT convertido de ASCII a BIN
        LEAS 2,SP               ;Ajustar puntero de pila para que apunte a la direcci�n de retorno
        RTS                     ;Retornar de la subrutina
;*******************************************************************************
;                               SUBRUTINA ASCII_BIN
;Descripci�n: Esta subrutina convierte valores de 12 bits representados en ASCII
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
        LSLA                    ;Se multiplic� por 4 los datos ya que cada uno es de 4 bytes
        ADDA OFFSET             ;Obtener �ndice del byte actual a procesar
        LDAB A,X                ;Cargar byte a procesar
        SUBB #CERO_ASCII        ;Convertir valor ASCII a binario
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar dato cargado de Datos_IoT a 16 bits
        LDAB #MAX_EXPONENTE     ;Cargar la m�xima potencia de 10 utilizada por los datos en Datos_IoT
        SUBB OFFSET                    ;Obtener exponente del byte que se est� procesando actualmente
MULTI   TSTB                    ;Verificar si el exponente del byte que est� procesaando actualmente es 0
        BEQ COPIE               ;Saltar si el exponente es 0 y no hay que multiplicarlo por 10
        PSHB                    ;Apilar exponente del byte que est� procesando actualmente
        PSHY                    ;Apilar �ndice para hacer multiplicaci�n de decadas a 16 bits
        LDY #DIEZ_16            ;Cargar un diez para hacer la multiplicacion de decadas
        LEAS 3,SP               ;Ajustar puntero de pila para que apunte al n�mero convertido de ASCII a binario anteriormente
        PULD                    ;Cargar n�mero de 0 a 9 convertido de ASCII a binario anteriormente
        EMUL                    ;Multiplicar valor ASCII convertido a binario por una decada
        PSHD                    ;Apilar multiplicacion de decada calculada
        LEAS -3,SP              ;Ajustar puntero de pila para que apunte al exponente del byte que se est� procesando
        PULY                    ;Desapilar �ndice para barrer Datos_BIN
        PULB                    ;Desapilar exponente del byte que se est� procesando
        DECB                    ;Decrementar exponente del byte que se est� procesando
        BRA MULTI               ;Saltar para seguir multiplicando decadas
COPIE   PULD                    ;Desapilar valor calculado en la multiplicacion de decadas
        ADDD ACC                ;Sumar valor calculado con el valor calculado hasta el momento en ACC
        STD ACC                 ;Guardar valor calculado hasta el momento en ACC
        INC OFFSET              ;Incrementar offset para que se procese el siguiente en byte en el siguiente ciclo
        LDAA OFFSET             ;Cargar offset
        CMPA #CUATRO            ;Comparar offset con cuatro para verificar si ya se proces� el dato actual
        BEQ GUARDE              ;Saltar si ya se proces� el byte actual
        BRA CARGUES             ;Saltar si aun quedan bytes por procesar en el dato actual
GUARDE  PULA                    ;Desapilar registro para indexar la tabla Datos_BIN
        MOVW ACC,A,Y            ;Mover dato binario calculado a Datos_BIN
        ADDA #DOS               ;Ajustar registro para que el proximo dato transferido a Datos_BIN est� alineado por words
        PSHA                    ;Apilar registro para indexar Datos_BIN
        INC CONT                ;Incrementar contador de datos procesados
        LDAA CONT               ;Cargar contador de datos procesados
        CMPA CANT               ;Comparar cantidad de datos procesados con cantidad de datos totales
        BEQ FIN_AS                ;Saltar si ya se procesaron todos los datos
        BRA CARGUE              ;Seguir procesando datos si aun no se ha terminado de barrer la tabla Datos_IoT
FIN_AS  LEAS 1,S                ;Ajustar puntero de pila para que apunte a la direcci�n de retorno de la subrutina
        RTS                     ;Retornar de la subrutina
CARGUE  CLR ACC                 ;Limpiar parte alta de variable temporal
        CLR ACC+1               ;Limpiar parte baja de variable temporal
        CLR OFFSET              ;Limpiar variable contadora
        BRA CARGUES             ;Saltar con un valor de ACC y OFFSET limpios para el siguiente dato
;*******************************************************************************
;                               SUBRUTINA MOVER
;Descripci�n: Esta subrutina mueve los datos en la tabla Datos_BIN a las posiciones
;dadas por los punteros Nibble_UP, Nibble_MED, Nibble_LOW, colocando cada uno de los nibbles
;correspondientes en un byte en las direcciones indicadas por estos punteros.
;*******************************************************************************
MOVER   CLRA                    ;Limpiar contador de datos
SIGMOV  LDY NIBBLE_UP           ;Cargar direcci�n base a partir de donde se colocaran los nibbles altos
        MOVB 0,X,1,Y+           ;Mover byte superior del dato
        BCLR -1,Y,$F0             ;Obtener nibble inferior en el byte copiado a Nibble_UP
        STY NIBBLE_UP           ;Guardar direcci�n del pr�ximo dato a procesar de Datos_BIN
        LDY NIBBLE_MED          ;Cargar direcci�n base a partir de donde se colocaran los nibbles intermedios
        MOVB 1,X,1,Y+           ;Mover byte inferior del dato
        BCLR -1,Y,$0F                ;Obtener nibble superior en el byte copiado a Nibble_MED
        STY NIBBLE_MED          ;Guardar direcci�n del pr�ximo dato a procesar de Datos_BIN
        LDY NIBBLE_LOW          ;Cargar direcci�n base a partir de donde se colocaran los nibbles menores
        MOVB 1,X,1,Y+           ;Mover byte inferior del dato
        BCLR -1,Y,$F0                ;Obtener nibble inferior en el byte copiado a Nibble_LOW
        STY NIBBLE_LOW          ;Guardar direcci�n del pr�ximo dato a procesar de Datos_BIN
        LEAX 2,X                ;Incrementar �ndice para que apunte al pr�ximo dato a procesar
        INCA                    ;Incrementar el contador de datos procesados
        CMPA CANT               ;Comparar contador de datos procesados con cantidad total de datos
        BEQ FIN_MOV             ;Saltar si ya terminaron de procesar los datos
        BRA SIGMOV              ;Saltar si aun quedan datos por procesar
FIN_MOV RTS                     ;Retornar de la subrutina
;*******************************************************************************
;                               SUBRUTINA IMPRIMIR
;Descripci�n: Esta subrutina imprime en la terminal los nibbles ubicados en las
;posiciones Nibble_UP, Nibble_MED, y Nibble_LOW
;*******************************************************************************
IMPRIM  LDD NIBBLE_UP           ;Cargar direcci�n de Nibble_UP despu�s de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_UP           ;Guardar puntero restituido
        LDD NIBBLE_MED          ;Cargar direcci�n de Nibble_MED despu�s de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_MED          ;Guardar puntero restituido
        LDD NIBBLE_LOW          ;Cargar direcci�n de Nibble_LOW despu�s de colocar los nibbles
        SUBB CANT               ;Restituir el puntero, restando la cantidad de datos procesados
        STD NIBBLE_LOW          ;Guardar puntero restituido
        LDAB CONT               ;Cargar cantidad de datos procesados
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG2               ;Cargar direcci�n del mensaje a imprimir con el valor de CONT
        LDX #$0000              ;Limpiar �ndice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG2
        LDD #MSG3               ;Cargar direcci�n del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar �ndice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
        ASL CONT                ;Multiplicar cantidad de valores procesados por 2
        ASL CONT                ;Multiplicar cantidad de valores procesados por 2 para obtener la cantidad de nibbles
NIBB    ADDA #4                 ;Incrementar contador para verificar si se lleg� al �ltimo nibble
        CMPA CONT               ;Verificar si se lleg� al �ltimo nibble
        BEQ LAST_NI             ;Saltar si se lleg� al �ltimo nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_UP           ;Cargar direcci�n base del arreglo Nibble_UP
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG4                ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
        BRA SIGA_NI             ;Saltar si aun no se ha llegado al �ltimo nibble
LAST_NI SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_UP           ;Cargar direcci�n base del arreglo Nibble_UP
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG5                ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
SIGA_NI JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB1               ;Ir a imprimir la siguiente clasificaci�n de nibbles
        BRA NIBB
NIBB1	LDD #MSG6               ;Cargar direcci�n del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar �ndice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
NIBB2   ADDA #4                 ;Incrementar contador para verificar si se lleg� al �ltimo nibble
        CMPA CONT               ;Verificar si se lleg� al �ltimo nibble
        BEQ LAST_N1             ;Saltar si se lleg� al �ltimo nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_MED          ;Cargar direcci�n base del arreglo Nibble_UP
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG4               ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
        BRA SIGA_N1             ;Saltar si aun no se ha llegado al �ltimo nibble
LAST_N1 SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_MED          ;Cargar direcci�n base del arreglo Nibble_UP
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG5               ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
SIGA_N1 JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB3               ;Ir a imprimir la siguiente clasificaci�n de nibbles
        BRA NIBB2
NIBB3
	LDD #MSG7               ;Cargar direcci�n del mensaje a imprimir para Nibble_UP
        LDX #$0000              ;Limpiar �ndice para llamar subrutina printf
        JSR [PRINTF,X]          ;Llamar subrutina para imprimir MSG3
        CLRA                    ;Limpiar contador para imprimir nibbles
NIBB4   ADDA #4                 ;Incrementar contador para verificar si se lleg� al �ltimo nibble
        CMPA CONT               ;Verificar si se lleg� al �ltimo nibble
        BEQ LAST_N4             ;Saltar si se lleg� al �ltimo nibble
        SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_LOW          ;Cargar direcci�n base del arreglo Nibble_LOW
        LDAB A,X                ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG4                ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
        BRA SIGA_N4             ;Saltar si aun no se ha llegado al �ltimo nibble
LAST_N4 SUBA #4                 ;Decrementar contador debido a que previamente se increment� para verificar
        PSHA                    ;Apilar contador para que sea conservado despu�s de ejecutar printf
        LDX NIBBLE_LOW           ;Cargar direcci�n base del arreglo Nibble_LOW
        LDAB A,X                 ;Cargar nibble
        CLRA                    ;Limpiar parte alta del acumulador D
        PSHD                    ;Apilar par�metro para printf
        LDD #MSG5                ;Cargar direcci�n del mensaje a desplegar
        LDX #$0000              ;Limpiar �ndice para hacer llamado a printf
SIGA_N4 JSR [PRINTF,X]          ;Hacer llamado a printf para imprimir nibble
        LEAS 2,SP               ;Ajustar puntero de pila para acceder a contador
        PULA                    ;Desapilar contador
        INCA                    ;Incrementar contador
        CMPA CONT               ;Verificar si ya se procesaron todos los nibbles
        BEQ NIBB5               ;Ir a imprimir la siguiente clasificaci�n de nibbles
        BRA NIBB4
NIBB5   RTS
