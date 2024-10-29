;******************************************************************************
;                   TAREA #4: LECTURA DE UN TECLADO MATRICIAL
;******************************************************************************
;Version: 1.0
;Autor: Roger Daniel Piovet García 
;Fecha de entrega: 2024-10-29
;Descripción: ....
;******************************************************************************

#include registers.inc

;******************************************************************************
;                                ENCABEZADO
;******************************************************************************

;--- Aqui se colocan los valores de carga para los timers baseT  ----
tTimer1mS    	EQU	1	;Base de tiempo de 1 mS (1 ms x 1)
tTimer10mS    	EQU	10	;Base de tiempo de 10 mS (1 mS x 10)
tTimer100mS   	EQU	100	;Base de tiempo de 100 mS (10 mS x 100)
tTimer1S       	EQU	1000	;Base de tiempo de 1 segundo (100 mS x 10)

; -- Aquí se colocan los valores de carga para los timers utilizados en el programa ---
tSuprRebTCL	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para los botones del teclado
tTimerLDTst    	EQU	1    	;Tiempo de parpadeo de LED testigo en segundos

;--- Aqui se colocan los valores utilizados por Leer_PB
PortPB		EQU	PTIH	;Puerto en donde se ubican los botones en la Dragon12+2
MaskPB       	EQU    	$01    	;Se define el bit del PB en el puerto
tSupRebPB	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para el PB
tShortP     	EQU    	10     	;Tiempo mínimo ShortPress x 10mS
tLongP		EQU   	2     	;Tiempo mínimo LongPress en segundos
RTIF      	EQU   	$80    	;RTIF = CRGFLG.7. Para habilitar/deshabilitar RTI

; --- Aquí se colocan los valores utilizado por las variables bandera del programa ---
ShortP		EQU	$01	;ShortP  = Banderas_PB.0
LongP		EQU    	$02	;LongP   = Banderas_PB.1
ArrayOK		EQU	$04	;ArrayOK = Banderas_PB.2

; --- Aquí se colocan las máscaras para los bits de PORTA ---
PA0		EQU	$01	;PA0 = PORTA.0
PA1		EQU	$02	;PA1 = PORTA.1
PA2		EQU	$04	;PA2 = PORTA.2
PA3		EQU	$08	;PA3 = PORTA.3
PA4		EQU	$10	;PA4 = PORTA.4
PA5		EQU	$20	;PA5 = PORTA.5
PA6		EQU	$40	;PA6 = PORTA.6
PA7		EQU	$80	;PA7 = PORTA.7

; --- Aquí se colocan las direcciones de inicio de las estructuras de datos del programa ---
INIT_TECLADO	EQU	$1000	;Inicio de estructuras de datos asociadas a Tarea_Teclado
INIT_NUM_ARRAY	EQU	$1010	;Inicio de Num_Array
INIT_BANDERAS	EQU	$100C	;Inicio de las banderas utilizadas en el programa
INIT_LEERPB	EQU	$100D	;Inicio de estructuras de datos asociadas a LeerPB
INIT_T_TIMERS 	EQU   	$1040	;Inicio de la tabla de timers
INIT_T_TECLAS	EQU	$1020	;Inicio de tabla de teclas válidas

; --- Aquí se colocan estructuras de datos misceláneas --- 
INIT_PILA	EQU	$3BFF	;Valor inicial de la pila 
INIT_PROG    	EQU    	$2000	;Inicio del programa principal
VEC_RTI		EQU	$3E70	;Vector de interrupción RTI

;******************************************************************************
;                    DECLARACION DE LAS ESTRUCTURAS DE DATOS
;******************************************************************************
; --- Aquí se colocan las estructuras de datos asociadas a Tarea_Teclado ---
	ORG INIT_TECLADO
MAX_TCL		DS	1
Tecla		DS	1
Tecla_IN	DS	1
Cont_TCL	DS	1
Patron		DS	1
Est_Pres_TCL	DS	2
	ORG INIT_NUM_ARRAY
Num_Array	DS	5

; --- Aquí se colocan las variables bandera utilizadas en el programa ---
	ORG INIT_BANDERAS
Banderas         	DS        1	;Banderas = X:X:X:X:X:Array_OK:LongP:ShortP

; --- Aquí se colocan las estructuras de datos asociadas a Leer_PB --- 
	ORG INIT_LEERPB
Est_Press_LeerPB	DS        2	;Variable de estado para la ME Leer_PB

;===============================================================================
;                              TABLA DE TECLAS
;===============================================================================
	ORG INIT_T_TECLAS
Teclas		DB	$01	;(PA0 = 0) && (PA4 = 0) -> '1'
		DB	$02	;(PA0 = 0) && (PA5 = 0) -> '2'
		DB	$03	;(PA0 = 0) && (PA6 = 0) -> '3'
		DB	$04	;(PA1 = 0) && (PA4 = 0) -> '4'
		DB	$05	;(PA1 = 0) && (PA5 = 0) -> '5'
		DB	$06	;(PA1 = 0) && (PA6 = 0) -> '6'
		DB	$07	;(PA2 = 0) && (PA4 = 0) -> '7'
		DB	$08	;(PA2 = 0) && (PA5 = 0) -> '8'
		DB	$09	;(PA2 = 0) && (PA6 = 0) -> '9'
		DB 	$0B	;(PA3 = 0) && (PA4 = 0) -> '*' -> Borrar
		DB	$00	;(PA3 = 0) && (PA5 = 0) -> '0'	
             	DB	$0E	;(PA3 = 0) && (PA6 = 0) -> '#' -> Enter

;===============================================================================
;                              TABLA DE TIMERS
;===============================================================================
    	Org INIT_T_TIMERS
Tabla_Timers_BaseT		
Timer1mS 		ds 	2       ;Timer 1 ms con base a tiempo de interrupcion
Timer10mS		ds 	2       ;Timer para generar la base de tiempo 10 mS
Timer100mS		ds 	2       ;Timer para generar la base de tiempo de 100 mS
Timer1S			ds	2       ;Timer para generar la base de tiempo de 1 Seg.
Fin_BaseT       	dW 	$FFFF	;Indicador de fin de tabla

Tabla_Timers_Base1mS
Timer_Reb_PB  		ds    	1	;Timer para manejar los rebotes de los botones pulsadores
Timer_RebTCL		ds	1	;Timer para manejar los rebotes de los botones del teclado
Fin_Base1mS     	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base10mS
Timer_SHP 		ds   	1	;Timer para identificar un short press
Fin_Base10ms    	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base100mS
Timer1_100mS  		ds   	1	;Timer default (sin utilizarse)
Fin_Base100mS   	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base1S
Timer_LP            	ds    	1	;Timer para identificar un long press	
Timer_LED_Testigo	ds	1	;Timer para parpadeo de led testigo
Fin_Base1S   		dB 	$FF	;Indicador de fin de tabla

;******************************************************************************
;                 RELOCALIZACION DE VECTOR DE INTERRUPCION
;******************************************************************************
	ORG VEC_RTI
    	DW Maquina_Tiempos

;===============================================================================
;                     	CONFIGURACION DE HARDWARE
;===============================================================================
	ORG INIT_PROG
        Bset DDRB,$81         	;Habilitacion del LED Testigo
        Bset DDRJ,$02          	;como comprobacion del timer de 1 segundo
        BClr PTJ,$02         	;haciendo toogle
        Movb #$0F,DDRP      	;bloquea los display de 7 Segmentos
        Movb #$0F,PTP
        Movb #$17,RTICTL	;Se configura RTI con un periodo de 1 mS
        Bset CRGINT,$80
	MOVB #$F0,DDRA		;Parte alta de PORTA como salidas, parte baja como entradas
	Bset PUCR,$01		;Habilitar pullups en PORTA

;===============================================================================
;                           PROGRAMA PRINCIPAL
;===============================================================================
	;Inicializar variables utilizadas en Tarea_Teclado
	MOVB #$FF,Tecla				;Inicializar variable para almacenar tecla presionada
	MOVB #$FF,Tecla_IN			;Inicializar variable para almacenar tecla presionada
	MOVB #$00,CONT_TCL			;Inicializar offset para agregar teclas a Num_Array
	MOVB #$00,Patron			;Inicilizar máscara para leer las teclas de PORTA
	MOVB #$05,MAX_TCL			;Cargar la cantidad máxima de teclas por leer
	MOVW #TareaTCL_Est1,Est_Pres_TCL	;Cargar estado inicial para la ME Teclado
	JSR BORRAR_NUM_ARRAY			;Saltar a subrutina para borrar Num_Array

	;Inicializar banderas
        CLR Banderas				;Limpia las banderas

	;Inicializar variables utilizadas en Leer_PB
        MOVW #LeerPB_Est1,Est_Press_LeerPB	;Carga estado inicial para la ME Leer_PB

	;Inicializar timers baseT
        Movw #tTimer1mS,Timer1mS
        Movw #tTimer10mS,Timer10mS
        Movw #tTimer100mS,Timer100mS
        Movw #tTimer1S,Timer1S

	;Limpiar los timers por usar
        Movb #tTimerLDTst,Timer_LED_Testigo 
        MOVB #$00,Timer_SHP
        MOVB #$00,Timer_LP			
        MOVB #$00,Timer_Reb_PB
	MOVB #$00,Timer_RebTCL

	;Inicialización para uso de interrupciones y subrutinas
        LDS #INIT_PILA				;Inicializa la pila
        CLI					;Habilitar interrupciones no mascarables
Despachador_Tareas
        JSR Tarea_Led_Testigo			;Despacha Tarea_Led_Testigo
	JSR Tarea_Teclado			;Despacha Tarea_Teclado
        JSR Tarea_Leer_PB			;Despacha Tarea_Leer_PB
	JSR Tarea_Borrar_TCL			;Despacha Tarea_Borrar_TCL
        Bra Despachador_Tareas			;Saltar para seguir despachando

;******************************************************************************
;                      		TAREA LED TESTIGO
;******************************************************************************
Tarea_Led_Testigo
	TST Timer_LED_Testigo			;Verificar si el timer de led testigo llegó a cero
	loc
	BNE FIN`				;Saltar si el timer aun no ha llegado a cero
	MOVB #tTimerLDTst,Timer_LED_Testigo	;Recargar el timer de led testigo
	LDAA PORTB				;Cargar valor actual de los LEDs
	EORA #$80				;Hacer toggle al LED PB7
	STAA PORTB				;Actualizar el valor de los LEDs
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	TAREA TECLADO
;******************************************************************************
Tarea_Teclado
	LDX Est_Pres_TCL		;Cargar dirección de la subrutina para el estado presente
	JSR 0,X				;Saltar a la subrutina del estado presente	
	RTS				;Retornar de la subrutina 

;============================== TECLADO ESTADO 1 =============================
TareaTCL_Est1
	JSR LEER_TECLADO			;Saltar a subrutina para leer teclado
	MOVB Tecla,Tecla_IN			;Guardar valor de tecla leída temporalmente
	LDAA Tecla				;Cargar valor de tecla leído
	CMPA #$FF				;Verificar si se presionó una tecla
	loc
	BEQ FIN`				;Saltar si no se ha presionado una tecla, mantenerse en el estado 1
	MOVB #tSuprRebTCL,Timer_RebTCL		;Cargar timer de rebotes
	MOVW #TareaTCL_Est2,Est_Pres_TCL	;Cambiar al estado 2, para suprimir rebotes
	BRA FIN`				;Saltar para terminar la subrutina
FIN`	RTS					;Fin de la subrutina

;============================== TECLADO ESTADO 2 =============================
TareaTCL_Est2
	TST Timer_RebTCL			;Verificar si el timer de rebotes ya llegó a cero
	loc
	BNE FIN`				;Saltar si el timer de rebotes no ha terminado
	JSR LEER_TECLADO			;Saltar a la subrutina para leer nuevamente el teclado
	LDAA Tecla				;Cargar valor de tecla leído
	CMPA Tecla_IN				;Verificar si la tecla sigue presionada
	BNE N_PRES`				;Saltar si no se sigue presionando la tecla
	MOVW #TareaTCL_Est3,Est_Pres_TCL	;Cambiar al estado 3, para considerar la retención de la tecla
	BRA FIN`				;Saltar para terminar la subrutina
N_PRES`	MOVW #TareaTCL_Est1,Est_Pres_TCL	;Cambiar al estado 1, ya que se realizó una lectura invalida
FIN`	RTS					;Retornar de la subrutina

;============================== TECLADO ESTADO 3 =============================
TareaTCL_Est3
	JSR LEER_TECLADO			;Saltar a subrutina para leer teclado
	LDAA Tecla				;Cargar valor de tecla leído
	CMPA Tecla_IN				;Verificar si se retiene la tecla presionada
	loc
	BEQ FIN`				;Saltar si la tecla sigue presionando, quedandose en este estado
	MOVW #TareaTCL_Est4,Est_Pres_TCL	;Cambiar al estado 4, ya que no se sigue retiendo la tecla
FIN`	RTS					;Saltar de la subrutina

;============================== TECLADO ESTADO 4 =============================
TareaTCL_Est4
	LDAA CONT_TCL		;Cargar offset para indexar Num_Array
	LDAB Tecla_IN		;Cargar valor de tecla de entrada
	LDX #NUM_ARRAY		;Cargar dirección base de arreglo para teclas
	CMPA MAX_TCL		;Verificar si se alcanzó la secuencia de longitud máxima
	loc
	BEQ MAX`		;Saltar si se alcanzó la secuencia de longitud máxima
	TST CONT_TCL		;Verificar si es la primera tecla presionada
	BEQ FIRST`		;Saltar si es la primera tecla presionada
	CMPB #$0B		;Verificar si la tecla presionada fue Borrar
	BEQ BOR_T`		;Saltar si la tecla presionada fue Borrar
	CMPB #$0E		;Verificar si la tecla presionada fue Enter
	BEQ ENT`		;Saltar si la tecla presionada fue Enter
GUARDE` STAB A,X		;Almacenar la tecla presionada en Num_Array
	INC CONT_TCL		;Incrementar offset para indexar a Num_Array
	BRA FIN`		;Saltar para finalizar el estado
MAX`	CMPB #$0B		;Verificar si la tecla presionada es Borrar
	BEQ BOR`		;Saltar para borrar la tecla presionada
	CMPB #$0E		;Verificar si la teclra presionada es Enter
	BEQ ENT`		;Saltar para finalizar la secuencia de teclas válida
	BRA FIN`		;Saltar para finalizar el estado
FIRST`	CMPB #$0B		;Verificar si la tecla presionada es Borrar
	BEQ FIN`		;Saltar para finalizar el estado
	CMPB #$0E		;Verificar si la tecla presionada es Enter
	BEQ FIN`		;Saltar para finalizar el estado
	BRA GUARDE`		;Saltar para añadir una tecla a Num_Array
BOR_T`	TST CONT_TCL		;Verificar si es la primera tecla presionada
	BEQ FIN`		;Saltar para finalizar el estado
BOR`	DECA			;Decrementar offset
	MOVB #$FF,A,X		;Borrar última tecla añadaida a Num_Array
	STAA CONT_TCL		;Actualizar offset en memoria
	BRA FIN`		;Saltar para finalizar el estado
ENT`	CLR CONT_TCL		;Borrar offset para indexar Num_Array
	BSET Banderas,ArrayOK	;Indicar que se ha generado un arreglo de teclas válido
	BRA FIN`		;Saltar para finalizar el estado
FIN`	MOVB #$FF,Tecla_IN			;Borrar valor de tecla de entrada
EST1`	MOVW #TareaTCL_Est1,Est_Pres_TCL	;Cambiar al estado 1 para procesar otra tecla
	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	SUBRUTINA LEER_TECLADO
;*****************************************************************************
LEER_TECLADO
	CLRB				;Limpiar contador de tecla
	MOVB #$EF,Patron		;Cargar valor inicial para desplazar las teclas
	loc
SIGA`	MOVB Patron,PORTA		;Cargar patron al puerto A, para accesar al teclado 
	BRCLR PORTA,PA0,COPIE`		;Saltar si la tecla presionada está en la columna 0
	INCB 				;Incrementar contador para verificar si está en la columna 1
	BRCLR PORTA,PA1,COPIE`		;Saltar si la tecla presionada está en la columna 1
	INCB				;Incrementar contador para verificar si está en la columna 2
	BRCLR PORTA,PA2,COPIE`		;Saltar si la tecla presionada está en la columna 2
	INCB				;Incrementar contador para verificar las teclas en el próximo ciclo
	LDAA Patron			;Cargar máscara para desplazar 0 en la parte alta de PORTA
	CMPA #$7F			;Verificar si ya se llegó a la última fila
	BNE SHIFT`			;Saltar si aun faltan filas por procesar
	MOVB #$FF,Tecla			;No se encontró una tecla presionada
	BRA FIN`			;Saltar para terminar la subrutina
SHIFT`	SEC				;Poner C=1 para que solo se roten 1s a Patron
	ROL Patron			;Desplazar 0 para acceder a la siguiente fila
	BRA SIGA`			;Saltar para seguir procesando filas
COPIE`	LDX #Teclas			;Cargar dirección base de tabla con teclas
	MOVB B,X,Tecla			;Actualizar tecla presionada
FIN`	RTS				;Retornar de la subrutina

;******************************************************************************
;                               TAREA LEER PB
;******************************************************************************
Tarea_Leer_PB
        LDX Est_Press_LeerPB		;Cargar dirección de la subrutina asociada al estado presente
        JSR 0,X				;Ejecutar subrutina asociada al estado presente
        RTS				;Retornar de la subrutina

;============================== LEER PB ESTADO 1 =============================
LeerPB_Est1
        BRCLR PortPB,MaskPB,LD_PB		;Salte si no se ha presionado el botón
	loc
        BRA FIN1                    		;Salte si ya se presionó el botón
LD_PB   MOVB #tSupRebPB,Timer_Reb_PB        	;Cargar timer de rebotes
        MOVB #tShortP,Timer_SHP        		;Cargar timer de short press
        MOVB #tLongP,Timer_LP        		;Cargar timer de long press
        MOVW #LeerPB_Est2,Est_Press_LeerPB    	;Actualizar el próximo estado
FIN1	RTS                                	;Retornar de subrutina

;============================== LEER PB ESTADO 2 =============================
LeerPB_Est2
        TST Timer_Reb_PB                 	;Verificar si el timer de rebotes ya llegó a cero
	loc
        BNE FIN2                          	;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,MaskPB,N_FALSO             ;Salte si no se detectó una falsa lectura
        MOVW #LeerPB_Est1,Est_Press_LeerPB    	;Como la lectura es inválido, vuelva al estado inicial
        BRA FIN2	                      	;Saltar para terminar la subrutina
N_FALSO	MOVW #LeerPB_Est3,Est_Press_LeerPB    	;Como la lectura es válida, pase al estado 3 para verificar si es SHP
FIN2	RTS                                    	;Fin de la subrutina

;============================== LEER PB ESTADO 3 =============================
LeerPB_Est3
        TST Timer_SHP                      	;Verificar si el timer de short press llegó a cero
	loc
        BNE FIN3                          	;Saltar si el timer ya llegó a cero
        BRCLR PortPB,MaskPB,NO_SHP             	;Saltar si el botón sigue presionado
        BSET Banderas,ShortP             	;Habilitar bandera de short press 
        MOVW #LeerPB_Est1,Est_Press_LeerPB    	;Cambiar al estado inicial, ya que fue short press
        BRA FIN3                        	;Saltar para terminar la subrutina
NO_SHP  MOVW #LeerPB_Est4,Est_Press_LeerPB    	;Cambiar al estado 4, para verificar si es long press
FIN3	RTS					;Retornar de la subrutina

;============================== LEER PB ESTADO 4 =============================
LeerPB_Est4
        TST Timer_LP                    	;Verificar si el timer de long press llegó a cero
        BNE T_NO_Z                             	;Saltar si el timer no ha llegado a cero
	loc
        BRCLR PortPB,MaskPB,FIN4          	;Saltar si el botón sigue presionado
        BSET Banderas,LongP             	;El botón se presionó antes que el timer acabara. Habilitar bandera SHP
        BRA I_EST                             	;Saltar para transicionar al estado inicial
T_NO_Z  BRCLR PortPB,MaskPB,FIN4          	;Saltar si el botón sigue presionado
        BSET Banderas,ShortP            	;Habilitar bandera de long press, ya que se verificó que sí es
I_EST   MOVW #LeerPB_Est1,Est_Press_LeerPB    	;Cambiar al estado inicial
FIN4	RTS					;Retornar de la subrutina
       
;******************************************************************************
;                               TAREA BORRAR_TCL
;******************************************************************************
Tarea_Borrar_TCL
        BRSET Banderas,ShortP,ON 	;Saltar si hubo un short press
        BRSET Banderas,LongP,OFF	;Saltar si hubo un long press
	loc
        BRA FIN`			;Saltar para finalizar la subrutina
ON      BCLR Banderas,ShortP   		;Borrar la bandera de short press
	BSET PORTB,$01          	;Encender el LED conectado a PB0
        BRA FIN`			;Saltar para finalizar la subrutina
OFF     BCLR Banderas,LongP		;Borrar la bandera de long press
	BCLR Banderas,ArrayOK		;Borrar la bandera de secuencia de teclas válidas
        BCLR PORTB,$01			;Apagar el LED conectado a PB0
	JSR BORRAR_NUM_ARRAY		;Saltar a subrutina para borrar Num_Array
FIN`	RTS				;Retornar de la subrutina

;******************************************************************************
;                       SUBRUTINA BORRAR_NUM_ARRAY
;******************************************************************************
BORRAR_NUM_ARRAY
	LDX #Num_Array			;Cargar dirección base del arreglo a borrar
	LDAA MAX_TCL			;Cargar cantidad máxima de teclas válidas
	loc
SIGA`	MOVB #$FF,1,X+			;Borrar una tecla de Num_Array
	DBNE A,SIGA`			;Decrementar y saltar si no se ha barrido el arreglo completo
	RTS				;Retornar de la subrutina

;******************************************************************************
;                       SUBRUTINA DE ATENCION A RTI
;******************************************************************************
Maquina_Tiempos:
        LDX #Tabla_Timers_BaseT         ;Cargar direcciÃ³n base de tabla base T
        JSR Decre_Timers_BaseT          ;Llamar a subrutina para decrementar timers
        LDD Timer1mS               	;Verificar si el timer de 1mS llegÃ³ a 0
        loc
        BNE NOCERO`                     ;Saltar si el timer aun no ha llegado a 0
        MOVW #tTimer1mS,Timer1mS        ;Reiniciar timer de 1mS
        LDX #Tabla_Timers_Base1mS       ;Cargar direcciÃ³n base de tabla base 1mS
        JSR Decre_Timers                ;Llamar a subrutina para decrementar timers
NOCERO` LDD Timer10mS                 	;Verificar si el timer de 10mS llegÃ³ a 0
        loc
        BNE NOCERO`                     ;Saltar si el timer aun no ha llegado a 0
        MOVW #tTimer10mS,Timer10mS      ;Reiniciar timer de 10mS
        LDX #Tabla_Timers_Base10mS      ;Cargar direcciÃ³n base de tabla base 10mS
        JSR Decre_Timers                ;Llamar a subrutina para decrementar timers
NOCERO`	LDD Timer100mS        		;Verificar si el timer de 100mS llegÃ³ a 0
        loc
        BNE NOCERO`                     ;Saltar si el timer aun no ha llegado a 0
        MOVW #tTimer100mS,Timer100mS    ;Reiniciar timer de 100mS
        LDX #Tabla_Timers_Base100mS     ;Cargar direcciÃ³n base de tabla base 100mS
        JSR Decre_Timers                ;Llamar a subrutina para decrementar timers
NOCERO` LDD Timer1S                     ;Verificar si el timer de 1S llegÃ³ a 0
        loc
        BNE NOCERO`                     ;Saltar si el timer aun no ha llegado a 0
        MOVW #tTimer1S,Timer1S          ;Reiniciar timer de 1S
        LDX #Tabla_Timers_Base1S        ;Cargar direcciÃ³n base de tabla base 1S
        JSR Decre_Timers                ;Llamar a subrutina para decrementar timers
NOCERO` BSET CRGFLG,RTIF                ;Deshabilitar solicitud de interrupciÃ³n
        loc
        RTI				;Retornar de la ISR

;******************************************************************************
;                       SUBRUTINA DECRE_TIMERS_BASET
;******************************************************************************
Decre_Timers_BaseT
        LDY 2,X+                        ;Cargar primer timer baseT y apuntar al siguiente timer
        BEQ Decre_Timers_BaseT          ;Saltar si el timer cargado ya llegÃ³ a cero
        CPY #$FFFF                      ;Verificar si se cargÃ³ el indicador de fin de tabla
        loc
        BNE DECRE`                      ;Saltar para decrementar el timer
        BRA FIN`                        ;Saltar para retornar de la subrutina
DECRE`  DEY                            	;Decrementar timer
        STY -2,X                        ;Guardar el timer decrementado
        BRA Decre_Timers_BaseT          ;Saltar para seguir barriendo la tabla de timers
FIN`    RTS                             ;Retornar de la subrutina

******************************************************************************
;                       SUBRUTINA DECRE_TIMERS
;******************************************************************************
Decre_Timers
        TST 0,X                         ;Verificar si el timer apuntado por el índice ya llegó a 0
        loc
        BEQ NEXT_T                      ;Saltar para avanzar al siguiente timer
        LDAA 0,X                        ;Cargar dato de la tabla de timers
        CMPA #$FF                       ;Verificar si ya se llegó al fin de tabla
        BEQ FIN`                        ;Saltar si ya se llegó al fin de tabla
        DEC 0,X                         ;Decrementar el timer
NEXT_T  INX                             ;Incrementar Ã­ndice para apuntar al siguiente timer
        BRA Decre_Timers                ;Saltar para procesar el siguiente timer
FIN`    RTS                             ;Retornar de la subrutina
        loc
