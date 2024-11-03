;******************************************************************************
;                   TAREA #5: MANEJO DE PANTALLAS
;******************************************************************************
;Version: 1.0
;Autor: Roger Daniel Piovet García 
;Fecha de entrega: 2024-11-08
;Descripción: ....
;******************************************************************************

#include registers.inc

;******************************************************************************
;                                ENCABEZADO
;******************************************************************************
; --- Aquí se colocan los valores asociados a Tarea_Teclado --- 
tSuprRebTCL	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para los botones del teclado

; --- Aquí se colocan los valores asociados a Tarea_PantallaMUX ---
tTimerDigito	EQU	2	;Valor de carga de Timer_Digito para multiplexación de displays
MaxCountTicks	EQU	100
DIG1		EQU	$01
DIG2		EQU	$02
DIG3		EQU	$04	
DIG4		EQU	$08

; --- Aquí se colocan los valores asociados a Tarea_LCD ---
; --- Aquí se colocan los valores asociados a Tarea_LeerPB1 ---
PortPB		EQU	PTIH	;Puerto en donde se ubican los botones en la Dragon12+2
MaskPB       	EQU    	$01    	;Se define el bit del PB en el puerto
tSupRebPB	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para el PB
tShortP     	EQU    	10     	;Tiempo mínimo ShortPress x 10mS
tLongP		EQU   	2     	;Tiempo mínimo LongPress en segundos
RTIF      	EQU   	$80    	;RTIF = CRGFLG.7. Para habilitar/deshabilitar RTI

; --- Aquí se colocan los valores asociados a Tarea_TCM ---
; --- Aquí se colocan los valores utilizado por las variables bandera del programa ---
ShortP		EQU	$01	;ShortP  = Banderas_PB.0
LongP		EQU    	$02	;LongP   = Banderas_PB.1
ArrayOK		EQU	$04	;ArrayOK = Banderas_PB.2

; --- Aquí se colocan los valores asociados a Tarea_Led_Testigo---
tTimerLDTst    	EQU	5    	;Tiempo de parpadeo de LED testigo en segundos
LD_Red		EQU	$10	;Máscara para encender LED rojo del LED RGB en PTP
LD_Green	EQU	$40	;Máscara para encender LED verde del LED RGB en PTP
LD_Blue		EQU	$20	;Máscara para encender LED azul del LED RGB en PTP

; --- Aquí se colocan los valores generales del programa ---

;--- Aqui se colocan los valores de carga para los timers baseT  ----
tTimer1mS    	EQU	1	;Base de tiempo de 1 mS (1 ms x 1)
tTimer10mS    	EQU	10	;Base de tiempo de 10 mS (1 mS x 10)
tTimer100mS   	EQU	100	;Base de tiempo de 100 mS (10 mS x 100)
tTimer1S       	EQU	1000	;Base de tiempo de 1 segundo (100 mS x 10)

;******************************************************************************
;                    		ENCABEZADO ADICIONAL
;******************************************************************************

; --- Aquí se colocan las direcciones de inicio de las estructuras de datos del programa ---
INIT_TECLADO	EQU	$1000	;Inicio de estructuras de datos asociadas a Tarea_Teclado
INIT_NUM_ARRAY	EQU	$1010	;Inicio de Num_Array
INIT_P_MUX	EQU	$1020	;Inicio de estructuras de datos asociadas a Tarea_PantallaMUX
INIT_LCD	EQU	$102F	;Inicio de estructuras de datos asociadas a Tarea_LCD
INIT_LEERPB1	EQU	$103F	;Inicio de estructuras de datos asociadas a Tarea_Leer_PB1
INIT_TCM	EQU	$1041	;Inicio de estructuras de datos asociadas a Tarea_TCM
INIT_BANDERAS	EQU	$1070	;Inicio de las banderas utilizadas en el programa
INIT_LD_TST	EQU	$1080	;Inicio de estructuras de datos asociadas a LDTst
INIT_TABLAS	EQU	$1100 	;Inicio de las tablas de 7 segmentos, y teclas
INIT_MSGS	EQU	$1200	;Inicio de los mensajes asociados a la pantalla LCD
INIT_T_TIMERS 	EQU   	$1500 	;Inicio de la tabla de timers

; --- Aquí se colocan estructuras de datos misceláneas --- 
INIT_PILA	EQU	$3BFF	;Valor inicial de la pila 
INIT_PROG    	EQU    	$2000	;Inicio del programa principal
VEC_OC		EQU	$3E66	;Vector de interrupción Output Compare

;******************************************************************************
;                    DECLARACION DE LAS ESTRUCTURAS DE DATOS
;******************************************************************************
; --- Aquí se colocan las estructuras de datos asociadas a Tarea_Teclado ---
	ORG INIT_TECLADO
MAX_TCL		DS	1	;Tamaño máximo del arreglo Num_Array	
Tecla		DS	1	;Variable de resultado de la subrutina LEER_TECLADO
Tecla_IN	DS	1	;Variable temporal para almacenar Tecla
Cont_TCL	DS	1	;Offset para tabla Teclas a partir de la lectura del teclado
Patron		DS	1	;Máscara para lectura del teclado en el PORTA
Est_Pres_TCL	DS	2	;Variable de próximo estado de la ME Tarea_Teclado
	ORG INIT_NUM_ARRAY
Num_Array	DS	5	;Arreglo para almacenar secuencia de teclas válida

; --- Aquí se colocan las estructuras de datos asociadas a Tarea_PantallaMUX ---
	ORG INIT_P_MUX
EstPres_PantallaMUX	DS	2	;Variable de próximo estado de la ME Tarea_PantallaMUX
DSP1		DS	1
DSP2		DS	1
DSP3		DS	1
DSP4		DS	1
LEDS		DS	1
Cont_Dig	DS	1
Brillo		DS	1
BIN1		DS	1
BIN2		DS	1
BCD		DS	1
Cont_BCD	DS	1
BCD1		DS	1
BCD2		DS	1
TEMP 		DS	1

; --- Aquí se colocan las estructuras de datos asociadas a Tarea_LCD --- 
	ORG INIT_LCD

; --- Aquí se colocan las estructuras de datos asociadas a Tarea_Leer_PB1 --- 
	ORG INIT_LEERPB1
EstPres_LeerPB1	DS	2	;Variable de estado para la ME Leer_PB

; --- Aquí se colocan las estructuras de datos asociadas a Tarea_TCM
	ORG INIT_TCM

; --- Aquí se colocan las variables bandera utilizadas en el programa ---
	ORG INIT_BANDERAS
Banderas         	DS	1	;Banderas = X:X:X:X:X:Array_OK:LongP:ShortP

; --- Aquí se colocan las estructuras de datos asociadas a Tarea_Led_Testigo ---
	ORG INIT_LD_TST
Est_Pres_LDTst		DS	2

;===============================================================================
;                              TABLA DE TECLAS
;===============================================================================
	ORG INIT_TABLAS
Segment		DB	$3F	;'0' en 7 segmentos
		DB	$06	;'1' en 7 segmentos
		DB	$5B	;'2' en 7 segmentos
		DB	$4F	;'3' en 7 segmentos
		DB	$66	;'4' en 7 segmentos
		DB	$6D	;'5' en 7 segmentos
		DB	$7D	;'6' en 7 segmentos
		DB	$07	;'7' en 7 segmentos
		DB	$7F	;'8' en 7 segmentos
		DB	$6F	;'9' en 7 segmentos
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
;                              	 MENSAJES
;===============================================================================
	ORG INIT_MSGS
MSG	FCC "Microprocesadores IE0623"

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
Timer_Digito		ds	1	;Timer para manejar la multiplexación de los displays
Timer_Reb_PB  		ds    	1	;Timer para manejar los rebotes de los botones pulsadores
Timer_RebTCL		ds	1	;Timer para manejar los rebotes de los botones del teclado
Fin_Base1mS     	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base10mS
Timer_SHP 		ds   	1	;Timer para identificar un short press
Fin_Base10ms    	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base100mS
Timer_LED_Testigo	ds	1	;Timer para parpadeo de led testigo
Fin_Base100mS   	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base1S
Timer_LP            	ds    	1	;Timer para identificar un long press	
Fin_Base1S   		dB 	$FF	;Indicador de fin de tabla

CONT_OC			ds	1	;Contador para llamadas a la ISR
Counter_Ticks		DS	1	;Contador de ticks para multiplexción de displays
;******************************************************************************
;                 RELOCALIZACION DE VECTOR DE INTERRUPCION
;******************************************************************************
	ORG VEC_OC
    	DW Maquina_Tiempos
;===============================================================================
;                     	CONFIGURACION DE HARDWARE
;===============================================================================
	ORG INIT_PROG
	BSET DDRP,$7F		;Definir puertos para el LED Testigo RGB y EN para displays
        ;Bset DDRB,$81         	;Habilitacion del LED Testigo
        Bset DDRJ,$02          	;como comprobacion del timer de 1 segundo
        BClr PTJ,$02         	;haciendo toogle
	MOVB #$F0,DDRA		;Parte alta de PORTA como salidas, parte baja como entradas
	Bset PUCR,$01		;Habilitar pullups en PORTA
	MOVB #480,TC4		;Cargar timer de comparación para Output Compare
	BSET TSCR1,$90		;Habilitar módulo TIMER
	BCLR TSCR2,$07		;Definir preescalador PRS = 1
	BSET TIOS,$10		;Habilitar salida por comparación para el canal 4
	BSET TIE,$10		;Habilitar interrupción por salida por comparación para el canal 4
	BCLR PTP,$0F		;Habilitar displays de 7 segmentos
	MOVB #$FF,DDRB		;Definir puertos para desplegar números en los displays 

;===============================================================================
;                           PROGRAMA PRINCIPAL
;===============================================================================
	;Inicializar variables utilizadas en Tarea_Teclado
	MOVB #$FF,Tecla				;Inicializar variable para almacenar tecla presionada
	MOVB #$FF,Tecla_IN			;Inicializar variable para almacenar tecla presionada
	CLR CONT_TCL				;Inicializar offset para agregar teclas a Num_Array
	CLR Patron				;Inicilizar máscara para leer las teclas de PORTA
	MOVB #$05,MAX_TCL			;Cargar la cantidad máxima de teclas por leer
	MOVW #TareaTCL_Est1,Est_Pres_TCL	;Cargar estado inicial para la ME Teclado
	JSR BORRAR_NUM_ARRAY			;Saltar a subrutina para borrar Num_Array
	
	;Inicializar variables utilizadas en Tarea_PantallaMUX
	MOVW #PantallaMUX_Est1,EstPres_PantallaMUX	;Cargar estado inicial para la ME PantallaMUX
	MOVB #$01,Cont_Dig			;Cargar primer display por ser desplegado
	MOVB #80,Brillo				;Definir brillo de los displays
	CLR Timer_Digito			;Limpiar timer para desplegar dígitos en los displays
	CLR Counter_Ticks			;Limpiar timer para definir brillo de los displays
	MOVB #$3F,DSP1				;Desplegar '0' en el display 1
	MOVB #$06,DSP2				;Desplegar '1' en el display 2
	MOVB #$5B,DSP3				;Desplegar '2' en el display 3
	MOVB #$4F,DSP4				;Desplegar '3' en el display 4
	MOVB #$AA,LEDS				;Encender LEDs impares en PORTB
	MOVB #$0F,BIN1				;Desplegar '15' en los displays 1 y 2
	MOVB #$0F,BIN2				;Desplegar '15' en los displays 3 y 4

	;Inicializar banderas
        CLR Banderas				;Limpia las banderas

	;Inicializar variables utilizadas en Leer_PB
        MOVW #LeerPB_Est1,EstPres_LeerPB1	;Carga estado inicial para la ME Leer_PB
	
	;Inicializar variables utilizadas en LDTst
	MOVW #LDTst_Est1,Est_Pres_LDTst		;Cargar estado inicial para parpadear el LED azul

	;Inicializar timers baseT
        Movw #tTimer1mS,Timer1mS		;Inicializar timer para la base de tiempo de 1ms
        Movw #tTimer10mS,Timer10mS		;Inicializar timer para la base de tiempo de 10ms
        Movw #tTimer100mS,Timer100mS		;Inicializar timer para la base de tiempo de 100ms
        Movw #tTimer1S,Timer1S			;Inicializar timer para la base de tiempo de 1000ms (1S)

	;Limpiar los timers por usar
        CLR Timer_LED_Testigo 			;Limpiar timer para el LED testigo RGB
        CLR Timer_SHP				;Limpiar timer para detectar short press
        CLR Timer_LP				;Limpiar timer para detectar long press
        CLR Timer_Reb_PB			;Limpiar timer para suprimir rebotes en los PB
	CLR Timer_RebTCL			;Limpiar timer para suprimir rebotes en el TCL
	
	; Inicialización para el uso de la salida por comparación
	LDD TCNT				;Cargar valor actual del timer
	ADDD #480				;Cargar el valor inicial de comparación para el canal 4
	STD TC4					;Guardar el nuevo valor de comparación
	MOVB #50,CONT_OC			;Cargar contador de llamadas a ISR

	;Inicialización para uso de interrupciones y subrutinas
        LDS #INIT_PILA				;Inicializa la pila
        CLI					;Habilitar interrupciones no mascarables
Despachador_Tareas
        JSR Tarea_Led_Testigo			;Despacha Tarea_Led_Testigo
	JSR Tarea_Conversion			;Despacha la Tarea_Conversion
	JSR Tarea_PantallaMUX			;Despacha Tarea_PantallaMUX
	;JSR Tarea_Teclado			;Despacha Tarea_Teclado
        ;JSR Tarea_Leer_PB			;Despacha Tarea_Leer_PB
	;JSR Tarea_Borrar_TCL			;Despacha Tarea_Borrar_TCL
        Bra Despachador_Tareas			;Saltar para seguir despachando

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
	BRCLR PORTA,$01,COPIE`		;Saltar si la tecla presionada está en la columna 0
	INCB 				;Incrementar contador para verificar si está en la columna 1
	BRCLR PORTA,$02,COPIE`		;Saltar si la tecla presionada está en la columna 1
	INCB				;Incrementar contador para verificar si está en la columna 2
	BRCLR PORTA,$04,COPIE`		;Saltar si la tecla presionada está en la columna 2
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
;                       	TAREA CONVERSIÓN
;******************************************************************************
Tarea_Conversion
	LDAA BIN1		;Cargar parte alta de valor binario a convertir
	JSR BIN_BCD_MUXP	;Saltar a subrutina para convertir parte baja de valor BIN a BCD
	MOVB BCD,BCD1		;Guardar resultado de la conversión a BCD en BCD1
	LDAA BIN2		;Cargar parte baja del valor binario a convertir
	JSR BIN_BCD_MUXP	;Saltar a subrutina para convertir parte alta del valor BIN a BCD
	MOVB BCD,BCD2		;Guardar resultado de la conversión a BCD en BCD2
	JSR BCD_7SEG		;Saltar a subrutina para convertir valor BCD a 7Seg
	RTS 			;Retornar de la subrutina

;******************************************************************************
;                       	SUBRUTINA BIN_BCD_MUXP
;******************************************************************************
BIN_BCD_MUXP
	MOVB #$07,Cont_BCD	;Cargar contador de desplazamientos menos uno
	CLR BCD			;Limpiar variable de resultado
	loc
SIGA`	LSLA			;Desplazar valor binario, de acuerdo al algoritmo XS3	
	ROL BCD			;Rotar variable de resultado, de acuerdo al algoritmo XS3
	PSHA			;Apilar temporalmente el valor binario
	;STAA TEMP
	LDAA BCD		;Cargar variable de resultado hasta el momento
	ANDA #$0F		;Obtener nibble inferior de la variable de resultado
	CMPA #5			;Verificar si el nibble es mayor o igual que 5
	BHS SUME3`		;Saltar si el nibble es mayor o igual que 5
	BRA SIGA3`		;Saltar si el nibble es menor que 5
SUME3`	ADDA #3			;Sumar 3 al nibble inferior, de acuerdo al algoritmo XS3
SIGA3`	TFR A,B			;Guardar temporalmente el resultado del nibble inferior
	LDAA BCD		;Cargar variable de resultado hasta el momento
	ANDA #$F0		;Obtener nibble superior de la variable de resultado
	CMPA #$50		;Verificar si el nibble es mayor o igual que 5
	BHS SUME30`		;Saltar si el nibble es mayor o igual que 5
	BRA SIGA30`		;Saltar si el nibble es menor que 5
SUME30`	ADDA #$30		;Sumar 3 al nibble superior, de acuerdo al algoritmo XS3
SIGA30`	ABA			;Sumar el resultado de ambos nibbles
	STAA BCD		;Guardar suma de nibbles en la variable de resultado
	PULA 			;Desapilar el valor binario apilado temporalmente
	;LDAA TEMP
	DEC Cont_BCD		;Decrementar contador de desplazamientos
	BNE SIGA`		;Saltar si la cantidad de desplazamientos no ha llegado a cero
	LSLA			;Desplazar por última vez el valor binario
	ROL BCD			;Desplazar por última vez la variable de resultado
	RTS			;Retornar de la subrutina

;******************************************************************************
;                       	SUBRUTINA BCD_7SEG
;******************************************************************************
BCD_7SEG
	loc
	RTS				;Retornar de las subrutina

;******************************************************************************
;                       	TAREA PANTALLA MUX
;******************************************************************************
Tarea_PantallaMUX
	LDX EstPres_PantallaMUX		;Cargar dirección de la subrutina para el próximo estado
	JSR 0,X				;Saltar a la subrutina del próximo estado
	RTS				;Retornar de la subrutina 

;============================== TECLADO ESTADO 1 =============================
PantallaMUX_Est1
	TST Timer_Digito		;Verificar si el timer de dígito ha llegado a cero
	loc 
	BNE FIN`			;Saltar si el timer ya llegó a cero
	MOVB #tTimerDigito,Timer_Digito	;Recargar timer de digito
	LDAA Cont_Dig			;Cargar contador de digito
	CMPA #1				;Verificar si se va desplegar el dígito 1
	BEQ DIGITO1			;Saltar si se va desplegar el digito 1
	CMPA #2				;Verificar si se va desplegar el dígito 2
	BEQ DIGITO2			;Saltar si se va desplegar el digito 2
	CMPA #3				;Verificar si se va desplegar el dígito 3
	BEQ DIGITO3			;Saltar si se va desplegar el digito 3
	CMPA #4				;Verificar si se va desplegar el dígito 4
	BEQ DIGITO4			;Saltar si se va desplegar el digito 4
	BRA DIGITO5			;Como caso por defecto, se va desplegar el digito 5 (LEDs)
DIGITO1	BCLR PTP,DIG1			;Habilitar primer dígito
	MOVB DSP1,PORTB			;Desplegar valor en el primer dígito
	BRA INCRE`			;Saltar para incrementar el contador de dígito
DIGITO2 BCLR PTP,DIG2			;Habilitar segundo dígito
	MOVB DSP2,PORTB			;Desplegar valor en el segundo dígito
	BRA INCRE`			;Saltar para incrementar el contador de dígito
DIGITO3	BCLR PTP,DIG3			;Habilitar tercer dígito
	MOVB DSP3,PORTB			;Desplegar valor del tercer dígito
	BRA INCRE`			;Saltar para incrementar el contador de dígito
DIGITO4 BCLR PTP,DIG4			;Habilitar cuarto dígito
	MOVB DSP4,PORTB			;Desplegar valor del cuarto dígito
	BRA INCRE`			;Saltar para incrementar el contador de dígito
DIGITO5	BCLR PTJ,$02			;Habilitar quinto dígito (ánodo de los LEDs)
	MOVB LEDS,PORTB			;Desplegar valor del quinto dígito
	MOVB #1,Cont_Dig		;Reiniciar el contador de dígito
	BRA TICKS`			;Saltar para iniciar el contador de ticks
INCRE`	INC Cont_Dig			;Incrementar el contador de dígito
TICKS`	MOVB #MaxCountTicks,Counter_Ticks		;Iniciar el contador de ticks
	MOVW #PantallaMUX_Est2,EstPres_PantallaMUX	;Actualizar la variable de estado para saltar al estado 2
FIN`	RTS				;Retornar de la subrutina

;============================== TECLADO ESTADO 2 =============================
PantallaMUX_Est2
	LDAA Counter_Ticks		;Cargar contador de ticks
	CMPA Brillo			;Verificar si el contador de ticks ya alcanzó el valor de brillo
	loc
	BNE FIN` 			;Saltar si ya se llegó al valor de brillo
	BSET PTP,$0F			;Deshabilitar displays de 7 segmentos 
	BSET PTJ,$02			;Deshabilitar LEDs
	MOVW #PantallaMUX_Est1,EstPres_PantallaMUX	;Actualizar la variable de estado para saltar al estado 1
FIN`	RTS						;Retornar de la subrutina

;******************************************************************************
;                      		TAREA LED TESTIGO
;******************************************************************************
Tarea_Led_Testigo
	LDX Est_Pres_LDTst			;Cargar prox estado para la ME LDTst
	JSR 0,X					;Saltar al prox estado
	RTS					;Retornar de la subrutina

;============================== LED TESTIGO ESTADO 1 ==========================
LDTst_Est1
	TST Timer_LED_Testigo			;Verificar si el timer de led testigo llegó a cero
	loc
	BNE FIN`				;Saltar si el timer aun no ha llegado a cero
	BCLR PTP,LD_Green			;Apagar LED verde
	BSET PTP,LD_Blue			;Encender LED RGB Azul
	MOVW #LDTst_Est2,Est_Pres_LDTst		;Cargar prox estado para parpadear el LED verde
	MOVB #tTimerLDTst,Timer_LED_Testigo	;Recargar el timer de led testigo
FIN`	RTS					;Retornar de la subrutina

;============================== LED TESTIGO ESTADO 2 ==========================
LDTst_Est2
	TST Timer_LED_Testigo			;Verificar si el timer de led testigo llegó a cero
	loc
	BNE FIN`				;Saltar si el timer aun no ha llegado a cero
	BCLR PTP,LD_Blue			;Apagar LED RGB Azul
	BSET PTP,LD_Red				;Encender LED RGB Rojo
	MOVW #LDTst_Est3,Est_Pres_LDTst		;Cargar prox estado para parpadear el LED verde
	MOVB #tTimerLDTst,Timer_LED_Testigo	;Recargar el timer de led testigo
FIN`	RTS
;============================== LED TESTIGO ESTADO 3 ==========================
LDTst_Est3
	TST Timer_LED_Testigo			;Verificar si el timer de led testigo llegó a cero
	loc
	BNE FIN`				;Saltar si el timer aun no ha llegado a cero
	BCLR PTP,LD_Red				;Apagar LED RGB Rojo
	BSET PTP,LD_Green			;Encender LED RGB Verde
	MOVW #LDTst_Est1,Est_Pres_LDTst		;Cargar prox estado para parpadear el LED verde
	MOVB #tTimerLDTst,Timer_LED_Testigo	;Recargar el timer de led testigo
FIN`	RTS

;******************************************************************************
;                               TAREA LEER PB
;******************************************************************************
Tarea_Leer_PB
        LDX EstPres_LeerPB1		;Cargar dirección de la subrutina asociada al estado presente
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
        MOVW #LeerPB_Est2,EstPres_LeerPB1    	;Actualizar el próximo estado
FIN1	RTS                                	;Retornar de subrutina

;============================== LEER PB ESTADO 2 =============================
LeerPB_Est2
        TST Timer_Reb_PB                 	;Verificar si el timer de rebotes ya llegó a cero
	loc
        BNE FIN2                          	;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,MaskPB,N_FALSO             ;Salte si no se detectó una falsa lectura
        MOVW #LeerPB_Est1,EstPres_LeerPB1    	;Como la lectura es inválido, vuelva al estado inicial
        BRA FIN2	                      	;Saltar para terminar la subrutina
N_FALSO	MOVW #LeerPB_Est3,EstPres_LeerPB1    	;Como la lectura es válida, pase al estado 3 para verificar si es SHP
FIN2	RTS                                    	;Fin de la subrutina

;============================== LEER PB ESTADO 3 =============================
LeerPB_Est3
        TST Timer_SHP                      	;Verificar si el timer de short press llegó a cero
	loc
        BNE FIN3                          	;Saltar si el timer ya llegó a cero
        BRCLR PortPB,MaskPB,NO_SHP             	;Saltar si el botón sigue presionado
        BSET Banderas,ShortP             	;Habilitar bandera de short press 
        MOVW #LeerPB_Est1,EstPres_LeerPB1    	;Cambiar al estado inicial, ya que fue short press
        BRA FIN3                        	;Saltar para terminar la subrutina
NO_SHP  MOVW #LeerPB_Est4,EstPres_LeerPB1    	;Cambiar al estado 4, para verificar si es long press
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
I_EST   MOVW #LeerPB_Est1,EstPres_LeerPB1    	;Cambiar al estado inicial
FIN4	RTS					;Retornar de la subrutina
       
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
;                       SUBRUTINA DE ATENCION A OUTPUT COMPARE
;******************************************************************************
Maquina_Tiempos:
	LDAA Counter_Ticks		;Cargar contador de ticks para el manejo del brillo
	CMPA Brillo			;Verificar si ya se llegó al valor de Brillo deseado
	loc
	BEQ SIGA`			;Saltar si ya se llegó al valor de Brillo deseado
	DEC Counter_Ticks		;Decrementar contador de Ticks
SIGA` 	DEC CONT_OC			;Decrementar contador de llamadas a la ISR
	BNE NODECRE			;Saltar si el contador aun no es cero
	MOVB #50,CONT_OC		;Recargar contador de llamadas a la ISR
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
NOCERO` loc
NODECRE	LDD TCNT			;Cargar valor actual del timer
	ADDD #480			;Cargar el valor inicial de comparación para el canal 4
	STD TC4				;Guardar el nuevo valor de comparación
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
