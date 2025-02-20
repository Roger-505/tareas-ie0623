;******************************************************************************
;                   PROYECTO FINAL: SELECTOR 623
;******************************************************************************
;Version: 1.0
;Autor: Roger Daniel Piovet García 
;Fecha de entrega: 2024-11-08
;******************************************************************************

#include registers.inc

;******************************************************************************
;                                ENCABEZADO
;******************************************************************************

;============================== TAREA TECLADO =================================
tSuprRebTCL	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para los botones del teclado

;============================ TAREA PANTALLA MUX ===============================

tTimerDigito	EQU	2	;Valor de carga de Timer_Digito para multiplexación de displays
MaxCountTicks	EQU	100	;Valor máximo de ticks al desplegar un dígito en los displays
DIG1		EQU	$01	;Habilitación en PTP del display 1
DIG2		EQU	$02	;Habilitación en PTP del display 2
DIG3		EQU	$04	;Habilitación en PTP del display 3
DIG4		EQU	$08	;Habilitación en PTP del display 4
OFF		EQU	$0B	;Valor para desplegar un guión en los displays
GUIONES		EQU	$0A	;Valor para apagar un display

;============================ TAREA LCD =========================================
tTimer2mS	EQU	2	;Retardo de 2mS
tTimer260uS	EQU	13	;Retardo de 260uS
tTimer40uS	EQU	2	;Retardo de 40uS
EOB		EQU	$FF	;Indicador de fin de tabla/mensaje
Clear_LCD	EQU	$01	;Comando CLEAR para LCD
ADD_L1		EQU	$80	;Dirección de línea 1 en LCD
ADD_L2		EQU	$C0	;Dirección de línea 2 en LCD

;============================ TAREA LEER PB1/2 ====================================

PortPB		EQU	PTIH	;Puerto en donde se ubican los botones en la Dragon12+2
tSupRebPB1	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para el PB
tShortP1     	EQU    	10     	;Tiempo mínimo ShortPress x 10mS
tLongP1		EQU   	2     	;Tiempo mínimo LongPress en segundos
tSupRebPB2	EQU    	50     	;Tiempo de supresión de rebotes x 1mS para el PB
tShortP2    	EQU    	10     	;Tiempo mínimo ShortPress x 10mS
tLongP2		EQU   	2     	;Tiempo mínimo LongPress en segundos

;============================ TAREA CONFIGURAR ====================================
LDConfig	EQU	$01	;Patrón de LEDs cuando el selector 623 se encuentra en el modo configurar
Lmin		EQU	70	;Valor mínimo de una barra de aluminio bruto
Lmax		EQU	99	;Valor máximo de una barra de aluminio bruto

;============================ TAREA STOP ==========================================
LDStop		EQU	$04	;Patrón de LEDs cuando el selector 623 se encuentra en el modo stop

;============================ TAREA SELECCIONAR ===================================
LDSelect	EQU	$02	;Patrón de LEDs cuando el selector 623 se encuentra en el modo seleccionar
tTimerCal	EQU	100	;Valor de carga de TimerCal para medir velocidad/longitud de una barra
tTimerError	EQU	20	;Valor de carga de TimerError para desplegar un mensaje de error en la LCD/displays
tTimerShot	EQU	2	;Valor de carga de TimerShot para marcar con pintura el centro longitudinal de las barras
VelocMin	EQU	10	;Velocidad mínima de una barra en cm/seg
VelocMax	EQU	50	;Velocidad máxima de una barra en cm/seg
DeltaX_S	EQU	50	;Distancia entre sensores S1 y S2 en cm
DeltaX_R	EQU	150	;Distancia entre sensor S2 y rociador R
PortRele	EQU	PORTE	;Puerto en donde se ubica el microrelé
MaskRele	EQU	$04	;Pad en donde se encuentra conectado el microrele

;============================ TAREA BRILLO ========================================
tTimerBrillo	EQU	4	;Tiempo para generar conversiones ADC del trimmer 
MaskSCF		EQU	$80	;SCF = ATD0STAT0.7

;============================ TAREA LEER DS =======================================
tTimerRebDS	EQU	20 	;Tiempo de supresión de rebotes x 1ms para el DS

;============================ BANDERAS ============================================

ShortP1		EQU	$01	;ShortP0  = Banderas_1.0
LongP1		EQU	$02	;LongP0   = Banderas_1.1
ShortP2		EQU	$04	;ShortP1  = Banderas_1.2
LongP2		EQU	$08	;LongP1   = Banderas_1.3
Array_OK	EQU	$10	;Array_OK = Banderas_1.4
RS		EQU	$01	;RS          = Banderas_2.0
LCD_Ok		EQU	$02	;LCD_Ok      = Banderas_2.1
FinSendLCD	EQU	$04	;FinSendLCD  = Banderas_2.2
Second_Line	EQU	$08	;Second_Line = Banderas_2.3

;============================ GENERALES ============================================
tTimerLDTst    	EQU	5    	;Tiempo de parpadeo de LED testigo en segundos
Carga_TC4	EQU	480	;Valor de carga a TC4 para configurar OC a 50kHz para Maquina_Tiempos

; QUITAR ESTOS VALORES
LD_Red		EQU	$10	;Máscara para encender LED rojo del LED RGB en PTP
LD_Green	EQU	$40	;Máscara para encender LED verde del LED RGB en PTP
LD_Blue		EQU	$20	;Máscara para encender LED azul del LED RGB en PTP

;============================ TABLA DE TIMERS =======================================
tTimer1mS    	EQU	50	;Base de tiempo de 1 mS (20uS x 50)
tTimer10mS    	EQU	500	;Base de tiempo de 10 mS (20uS x 500)
tTimer100mS   	EQU	5000	;Base de tiempo de 100 mS (20uS x 5000)
tTimer1S       	EQU	50000	;Base de tiempo de 1 segundo (20uS x 50000)

;******************************************************************************
;                    DECLARACION DE LAS ESTRUCTURAS DE DATOS
;******************************************************************************

;============================== TAREA TECLADO =================================

	ORG $1000
MAX_TCL		DS	1	;Tamaño máximo del arreglo Num_Array	
Tecla		DS	1	;Variable de resultado de la subrutina LEER_TECLADO
Tecla_IN	DS	1	;Variable temporal para almacenar Tecla
Cont_TCL	DS	1	;Offset para tabla Teclas a partir de la lectura del teclado
Patron		DS	1	;Máscara para lectura del teclado en el PORTA
Est_Pres_TCL	DS	2	;Variable de próximo estado de la ME Tarea_Teclado
	ORG $1010
Num_Array	DS	5	;Arreglo para almacenar secuencia de teclas válida

;============================ TAREA PANTALLA MUX ===============================

	ORG $1020
EstPres_PantallaMUX	DS	2	;Variable de próximo estado de la ME Tarea_PantallaMUX
DSP1			DS	1	;Variable que contiene el dígito a desplegar en DSP1
DSP2			DS	1	;Variable que contiene el dígito a desplegar en DSP2
DSP3			DS	1	;Variable que contiene el dígito a desplegar en DSP3
DSP4			DS	1	;Variable que contiene el dígito a desplegar en DSP4
LEDS			DS	1	;Variable que contiene el estado de los LEDs
Cont_Dig		DS	1	;Variable contadora para desplegar los dígitos en los displays
Brillo			DS	1	;Variable que contiene el nivel de brillo de los displays (0-100)

;================= VARIABLES PARA SUBRUTINAS DE CONVERSIÓN ======================

BCD			DS	1
BCD1			DS	1
BCD2			DS	1
Cont_BCD		DS	1

;============================ TAREA LCD =========================================

IniDsp					;Tabla con comandos para la inicialización de la pantalla LCD
	DB	$28 			;FunctionSet1: Modo 4 bits, 2 líneas, fuente 5x8 puntos
	DB	$06			;Entry Mode Set. Incremento del cursor, sin shift del display
	DB	$0C			;Display ON/OFF Control. Display encendido, cursor apagado, sin parpadeo
	DW	$FFFF			;Indicador de fin de tabla (EOB)
Punt_LCD		DS	2	;Puntero para barrer arreglos de datos a enviar a LCD
CharLCD			DS	1	;Variable que contiene dato a transferir al LCD
MSG_L1			DS	2	;Dirección del mensaje a desplegar en la primera línea de la pantalla LCD
MSG_L2			DS	2	;Dirección del mensaje a desplegar en la segunda línea de la pantalla LCD
EstPres_SendLCD		DS	2	;Variable de estado para la ME SendLCD
EstPres_TareaLCD	DS	2	;Variable de estado para la ME TareaLCD

;============================ TAREA LEER PB1/2 ====================================
EstPres_LeerPB1		DS	2	;Variable de estado para la ME Leer_PB1
EstPres_LeerPB2		DS	2	;Variable de estado para la ME Leer_PB2

;============================ TAREA CONFIGURAR ====================================
Est_Pres_TConfig	DS	2	;Variable de estado para la ME TConfig
ValorLong		DS	1
LongOK			DS	1

;============================ TAREA STOP ==========================================

;============================ TAREA SELECCIONAR ===================================
Est_Pres_TSelec		DS	2	;Variable de estado para la ME TSelec
Longitud		DS	1	;Variable que almacena la longitud de una barra
DeltaT			DS	1	;Variable para medir intervalos temporales
Velocidad		DS	1	;Variable que almacena la velocidad de una barra

;============================ TAREA BRILLO ========================================
Est_Pres_TBrillo	DS	2	;Variable de estado para la ME Brillo

;============================ TAREA LEER DS =======================================
Est_Pres_LeerDS		DS	2	;Variable de estado para la ME Leer_DS
Temp_DS			DS	1	;Variable temporal para suprimir los rebotes generados por los DS
Valor_DS		DS	1	;Variable que almacena el estado de los DS

;============================ BANDERAS ============================================

	ORG $1070
Banderas_1         	DS	1	;Banderas_1 = X:X:X:Array_OK:LongP1:ShortP1:LongP0:ShortP0
Banderas_2		DS	1	;Banderas_2 = X:X:X:X:Second_Line:FinSendLCD:LCD_Ok:RS

;============================ GENERALES ============================================
	ORG $1080
Est_Pres_LDTst		DS	2	;Variable de estado para la ME Led_Testigo

;===============================================================================
;                              TABLA DE TECLAS
;===============================================================================
	ORG $1100
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
		DB	$40	;'-' en 7 segmentos
		DB	$00	;' ' en 7 segmentos (dígito apagado)

	ORG $1110
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
	ORG $1200
MSG_BIENVENIDA_L1	FCC     "  SELECTOR 623  "
			DB	EOB
MSG_BIENVENIDA_L2	FCC     "    MODO STOP   "
			DB	EOB
MSG_CONFIGURAR_L1	FCC     "MODO CONFIGURAR "
			DB	EOB
MSG_CONFIGURAR_L2	FCC     "INGRESE  LongOK "
			DB	EOB
MSG_SELECCIONAR_L1	FCC     "MODO SELECCIONAR"
			DB	EOB
MSG_SELECCIONAR_S1	FCC     " ESPERANDO S1..."
			DB	EOB
MSG_SELECCIONAR_S2	FCC     " ESPERANDO S2..."
			DB	EOB
MSG_SELECCIONAR_BARRA	FCC     "ESPERA FIN BARRA"
			DB	EOB
MSG_SELECCIONAR_CALCULE	FCC	" CALCULANDO ... "
			DB	EOB	
MSG_SELECCIONAR_VL	FCC	"VELOC       LONG"
			DB	EOB
MSG_VELOCIDAD		FCC	"** VELOCIDAD ** "
			DB	EOB	
MSG_LONGITUD		FCC	" ** LONGITUD ** "
			DB	EOB
MSG_RANGO		FCC	"*FUERA DE RANGO*"
			DB	EOB

;===============================================================================
;                              TABLA DE TIMERS
;===============================================================================
    	ORG $1500
Tabla_Timers_BaseT		
Timer1mS 		ds 	2       ;Timer 1 ms con base a tiempo de interrupcion
Timer10mS		ds 	2       ;Timer para generar la base de tiempo 10 mS
Timer100mS		ds 	2       ;Timer para generar la base de tiempo de 100 mS
Timer1S			ds	2       ;Timer para generar la base de tiempo de 1 Seg.
Counter_Ticks		ds	2	;Timer para generar la base de tiempo 20uS
Timer260uS		ds	2	;Timer para generar un retardo de 260uS
Timer40uS		ds	2	;Timer para generar un retardo de 40uS
Fin_BaseT       	dW 	$FFFF	;Indicador de fin de tabla

Tabla_Timers_Base1mS
Timer_Reb_PB1  		ds    	1	;Timer para manejar los rebotes de los botones pulsadores
Timer_Reb_PB2  		ds    	1	;Timer para manejar los rebotes de los botones pulsadores
Timer_RebTCL		ds	1	;Timer para manejar los rebotes de los botones del teclado
Timer_RebDS		ds	1	;Timer para manejar los rebotes de los dip-switches
Timer_Digito		ds	1	;Timer para manejar la multiplexación de los displays
Timer2mS		ds	1
Fin_Base1mS     	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base10mS
Timer_SHP1 		ds   	1	;Timer para identificar un short press
Timer_SHP2 		ds   	1	;Timer para identificar un short press
Fin_Base10ms    	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base100mS
TimerCal		ds	1	;Timer para medir la velocidad/longitud de una barra
TimerError		ds	1	;Timer para desplegar mensajes de error en la LCD/Displays
TimerPant		ds	1	;Timer para desplegar resultados en la pantalla cuando se están procesando barras
TimerFinPant		ds	1	;Timer para parar de desplegar resultados en la pantalla cuando se están procesando barras
TimerRociador		ds	1	;Timer para habilitar rociador cuando se están procesando barras
TimerShot		ds	1	;Timer para deshabilitar rociador cuando se están procesando barras
TimerBrillo		ds	1	;Timer para generar conversiones ADC para ajustar Brillo
Timer_LED_Testigo	ds	1	;Timer para parpadeo de led testigo
Fin_Base100mS   	dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base1S
Timer_LP1            	ds    	1	;Timer para identificar un long press	
Timer_LP2            	ds    	1	;Timer para identificar un long press	
Fin_Base1S   		dB 	$FF	;Indicador de fin de tabla

;******************************************************************************
;                 RELOCALIZACION DE VECTOR DE INTERRUPCION
;******************************************************************************
	ORG $3E66
    	DW Maquina_Tiempos

;******************************************************************************
;                 		PROGRAMA PRINCIPAL
;******************************************************************************
	ORG $2000
;===============================================================================
;                     	CONFIGURACION DE PERIFÉRICOS
;===============================================================================

;==================================== PIM ======================================
	BSET DDRP,$7F			;Definir puertos para el LED Testigo RGB y EN para displays
	BSET DDRE,MaskRele		;Definir puerto para relé 
	BCLR PTP,$0F			;Habilitar displays de 7 segmentos
	MOVB #$FF,DDRB			;Definir puertos para desplegar números en los displays 
        ;Bset DDRB,$81         		;Habilitacion del LED Testigo
        Bset DDRJ,$02          		;Declarar como salida habilitador de LEDs
        BClr PTJ,$02         		;Habilitar LEDs

;======================== TECLADO MATRICIAL =====================================
	MOVB #$F0,DDRA			;Parte alta de PORTA como salidas, parte baja como entradas
	Bset PUCR,$01			;Habilitar pullups en PORTA

;======================== OUTPUT COMPARE ========================================
	MOVB #Carga_TC4,TC4		;Cargar timer de comparación para Output Compare
	BSET TSCR1,$90			;Habilitar módulo TIMER
	BCLR TSCR2,$07			;Definir preescalador PRS = 1
	BSET TIOS,$10			;Habilitar salida por comparación para el canal 4
	BSET TIE,$10			;Habilitar interrupción por salida por comparación para el canal 4

;=============================== ATD ============================================
	MOVB #$C0,ATD0CTL2		;Enceder módulo ATD 
	LDAA #160			;Cargar valor para generar retardo de 10uS
ESPERE	DBNE A,ESPERE			;Generar retardo para encender ATD de 10uS
	MOVB #$20,ATD0CTL3		;Definir un ciclo de converión por ciclo
	MOVB #$90,ATD0CTL4		;Definir divisor, 2 ciclos de reloj/muestra, resolución de 8 bits, fs=700kHz

;===============================================================================
;                  INICIALIZACIÓN DE ESTRUCTURAS DE DATOS
;===============================================================================

;========================== TABLA DE TIMERS ========================================
        Movw #tTimer1mS,Timer1mS		;Inicializar timer para la base de tiempo de 1ms
        Movw #tTimer10mS,Timer10mS		;Inicializar timer para la base de tiempo de 10ms
        Movw #tTimer100mS,Timer100mS		;Inicializar timer para la base de tiempo de 100ms
        Movw #tTimer1S,Timer1S			;Inicializar timer para la base de tiempo de 1000ms (1S)

;============================== TAREA TECLADO =================================
	CLR CONT_TCL				;Inicializar offset para agregar teclas a Num_Array
	CLR Patron				;Inicilizar máscara para leer las teclas de PORTA
	CLR Timer_RebTCL			;Limpiar timer para suprimir rebotes en el TCL
	MOVB #$FF,Tecla				;Inicializar variable para almacenar tecla presionada
	MOVB #$FF,Tecla_IN			;Inicializar variable para almacenar tecla presionada
	MOVB #$02,MAX_TCL			;Cargar la cantidad máxima de teclas por leer
	JSR BORRAR_NUM_ARRAY			;Saltar a subrutina para borrar Num_Array

;============================ TAREA PANTALLA MUX ===============================
	CLR Timer_Digito			;Limpiar timer para desplegar dígitos en los displays
	CLR Counter_Ticks			;Limpiar timer para definir brillo de los displays
	MOVB #$01,Cont_Dig			;Cargar primer display por ser desplegado

;================= VARIABLES PARA SUBRUTINAS DE CONVERSIÓN ======================

;============================ TAREA LEER PB1/2 ====================================
	;PB1
        CLR Timer_SHP1				;Limpiar timer para detectar short press
        CLR Timer_LP1				;Limpiar timer para detectar long press
        CLR Timer_Reb_PB1			;Limpiar timer para suprimir rebotes en los PB

	;PB2
        CLR Timer_SHP2				;Limpiar timer para detectar short press
        CLR Timer_LP2				;Limpiar timer para detectar long press
        CLR Timer_Reb_PB2			;Limpiar timer para suprimir rebotes en los PB

;============================ TAREA CONFIGURAR ====================================
	MOVB #85,LongOK			;Cargar valor inicial para LongOK

;============================ TAREA STOP ==========================================
;============================ TAREA SELECCIONAR ===================================
;============================ TAREA BRILLO ========================================
	MOVB #70,Brillo				;Definir valor inicial de Brillo
	CLR TimerBrillo				;Limpiar timer para realizar conversiones

;============================ TAREA LEER DS =======================================
	CLR Valor_DS				;Iniciar en el modo STOP

;============================ BANDERAS ============================================
        CLR Banderas_1				;Limpia Banderas_1
        CLR Banderas_2				;Limpia Banderas_2

;============================ GENERALES ============================================
        CLR Timer_LED_Testigo 			;Limpiar timer para el LED testigo RGB
	LDD TCNT				;Cargar valor actual del timer
	ADDD #Carga_TC4				;Cargar el valor inicial de comparación para el canal 4
	STD TC4					;Guardar el nuevo valor de comparación
	
;===============================================================================
;                    INICIALIZACIÓN DE MÁQUINAS DE ESTADO
;===============================================================================
	MOVW #TConfig_Est1,Est_Pres_TConfig		;Cargar estado inicial para la ME TConfig
	MOVW #TComp_Est1,Est_Pres_TSelec		;Cargar estado inicial para la ME TSelec
	MOVW #TareaBrillo_Est1,Est_Pres_TBrillo		;Cargar estado inciial para la ME Tarea_Brillo
	MOVW #TareaTCL_Est1,Est_Pres_TCL		;Cargar estado inicial para la ME Teclado
	MOVW #LDTst_Est1,Est_Pres_LDTst			;Cargar estado inicial para la ME Tarea_Led_Testigo
        MOVW #LeerPB1_Est1,EstPres_LeerPB1		;Cargar estado inicial para la ME Leer_PB1
        MOVW #LeerPB2_Est1,EstPres_LeerPB2		;Cargar estado inicial para la ME Leer_PB2
	MOVW #LeerDS_Est1,Est_Pres_LeerDS		;Cargar estado inicial para la ME Leer_DS
	MOVW #PantallaMUX_Est1,EstPres_PantallaMUX	;Cargar estado inicial para la ME PantallaMUX
	MOVW #TareaLCD_Est1,EstPres_TareaLCD		;Cargar estado inicial para la ME Tarea_LCD
	
;======================= PILA E INTERRUPCIONES MASCARABLES ========================
        LDS #$3BFF				;Inicializa la pila
        CLI					;Habilitar interrupciones mascarables

;===============================================================================
;                    RUTINA DE INICIALIZACIÓN DE LCD 
;===============================================================================
	MOVW #MSG_BIENVENIDA_L1,MSG_L1		;Cargar dirección de la primera línea del mensaje a enviar
	MOVW #MSG_BIENVENIDA_L2,MSG_L2		;Cargar dirección de la segunda línea del mensaje a enviar
	MOVW #SendLCD_Est1,EstPres_SendLCD	;Cargar estado inicial en ME SEND_LCD
	MOVW #tTimer260uS,Timer260us		;Inicializar timer para lectura de datos LCD
	MOVW #tTImer40uS,Timer40uS		;Inicializar timer para procesamiento en LCD
	BSET DDRK,$3F				;Declarar como salida PORTK[5:0]
	CLR Banderas_2				;Limpiar banderas para LCD
	MOVW #IniDsp,Punt_LCD			;Inicializar puntero con tabla de inicialización LCD
	loc
SIGA`	LDX Punt_LCD				;Cargar dirección de tabla con datos de inicialización
	MOVB 1,X+,CharLCD			;Cargar dato de inicialización en CharLCD
	STX Punt_LCD				;Guardar puntero actualizado
	LDAA CharLCD				;Cargar CharLCD
	CMPA #$FF				;Verificar si se llegó al EOB
	;BSET Banderas_2,LCD_Ok			;Habilitar bandera de LCD_Ok para no correr la subrutina innecesareamente
	BEQ CLRLCD				;Saltar si ya se llegó al EOB
SIGLCD`	JSR Tarea_SendLCD			;Saltar a subrutina para implementar algoritmo estroboscópico para LCD
	BRCLR Banderas_2,FinSendLCD,SIGLCD`	;Saltar si aun no se ha enviado el dato
	BCLR Banderas_2,FinSendLCD		;Limpiar bandera de envío de dato
	BRA SIGA`				;Saltar para seguir barriendo tabla IniDsp
CLRLCD	MOVB #Clear_LCD,CharLCD			;Cargar comando para limpiar LCD
	loc
SIGLCD`	JSR Tarea_SendLCD			;Saltar a subrutina para implementar algoritmo estroboscópico para LCD
	BRCLR Banderas_2,FinSendLCD,SIGLCD`	;Saltar si aun no se ha enviado el dato
	MOVB #tTimer2mS,Timer2mS		;Cargar timer de 2mS para limpiar pantalla
NOCERO`	TST Timer2mS				;Verificar si el timer ha llegado a cero
	BNE NOCERO`				;Saltar si el timer no ha llegado a cero
	loc

;===============================================================================
;                    	DESPACHADOR DE TAREAS
;===============================================================================
Despachador_Tareas
	JSR Tarea_Modo_STOP			;Despacha Tarea_Modo_STOP
	JSR Tarea_Configurar			;Despacha Tarea_Configurar
	JSR Tarea_Modo_SELECCIONAR		;Despacha Tarea_Modo_SELECCIONAR
	JSR Tarea_Brillo			;Despacha Tarea_Brillo
	JSR Tarea_Teclado			;Despacha Tarea_Teclado
        JSR Tarea_Led_Testigo			;Despacha Tarea_Led_Testigo
        JSR Tarea_Leer_PB1			;Despacha Tarea_Leer_PB1
        JSR Tarea_Leer_PB2			;Despacha Tarea_Leer_PB0
	JSR Tarea_Leer_DS			;Despacha Tarea_Leer_DS
	JSR Tarea_PantallaMUX			;Despacha Tarea_PantallaMUX
	JSR Tarea_LCD				;Despacha Tarea_SendLCD
	JSR BCD_7SEG				;Despacha BCD_7SEG
        Bra Despachador_Tareas			;Saltar para seguir despachando

;******************************************************************************
;                       	TAREA MODO STOP
;******************************************************************************
Tarea_Modo_STOP
	LDAA Valor_DS				;Cargar valor actual de los dipswitches
	CMPA #$C0				;Verificar si se seleccionó el modo STOP
	loc
	BNE FIN`				;Saltar si no se seleccionó el modo STOP
	MOVB #LDStop,LEDS			;Actualizar el patrón desplegado en los LEDs para el modo actual
	MOVW #MSG_BIENVENIDA_L1,MSG_L1		;Cargar primera línea del mensaje de bienvenida
	MOVW #MSG_BIENVENIDA_L2,MSG_L2		;Cargar segunda línea del mensaje de bienvenida
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	MOVB #17*OFF,BCD1			;Cargar valor de DSP1:DSP2 para pantalla apgada
	MOVB #17*OFF,BCD2			;Cargar valor de DSP3:DSP4 para pantalla apagada
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	SUBRUTINA CALCULA
;******************************************************************************
CALCULA
	LDAA #DeltaX_S				;Cargar distancia entre sensores para calcular velocidad
	LDAB #10				;Cargar 1 década
	MUL					;Multiplicar distancia por una década debido a la base de tiempo del timer
	LDX DeltaT				;Cargar valor intervalo de tiempo entre pulsos de sensores
	XGDX					;Intercambiar índice y acumulador para realizar operación aritmética
	TAB					;Poner DeltaT en la parte baja del acumulador
	CLRA					;Limpiar parte alta del acumulador, ya que se cargó un valor a 16 bits y DeltaT es de 8 bits
	XGDX					;Actualizar valor de DeltaT cargado
	IDIV					;Calcular la velocidad
	TFR X,B					;Devoler resultado a acumulador
	STAB Velocidad				;Actualizar valor de velocidad
	LDAA #tTimerCal				;Cargar valor de carga de temporizador para obtener DeltaT asociado a la longitud de la barra
	SUBA DeltaT				;Restar DeltaT anterior para obtener longitud de la barra
	SUBA TimerCal				;Restar valor actual de timer para obtener DeltaT asociado a la longitud de la barra
	STAA DeltaT				;Actualizar valor de DeltaT
	LDAB Velocidad				;Cargar velocidad de la barra
	MUL					;Longitud = DeltaT * Velocidad (Con timer base 100mS)
	LDX #10					;Cargar década para corregir valor de longitud calculado
	IDIV					;Corregir valor de longitud, ya que fue calculado con una base de tiempo de 100mS y no de 1S
	TFR X,B					;Obtener parte baja del índice para guardar longitud
	STAB Longitud				;Guardar valor de longitud calculado
	LDAA #10				;Cargar década para realizar cálculo de TimerPant
	LDAB #DeltaX_R				;Cargar distancia entre el sensor S2 y el rociador R
	MUL					;Obtener 10*DeltaX_R para calcular TimerPant con una base de tiempo de 100mS
	TFR D,X					;Guardar temporalmente acumulador en índice
	CLRA					;Limpiar parte alta de acumulador
	LDAB Velocidad				;Cargar valor de velocidad para calcular TimerPant
	XGDX 					;Intercambiar índice y acumulador para realizar división con IDIV
	IDIV					;TimerPant = 10*DeltaX_R/Velocidad
	XGDX					;Obtener resultado de TimerPant en acumulador
	STAB TimerPant				;Guardar valor calculado de TimerPant
	LDAA #10				;Cargar década para calcular TimerFinPant
	LDAB Longitud				;Cargar longitud de la barra
	MUL					;Obtener 10*Longitud para calcular TimerFinPant con una base de tiempo de 100mS
	TFR D,X					;Guardar temporalmente acumulador en índice
	CLRA					;Limpiar parte alta de acumulador
	LDAB Velocidad				;Cargar valor de velocidad para calcular TimerFinPant
	XGDX 					;Intercambiar índice y acumulador para realizar división con IDIV
	IDIV					;T_barra = 10*Longitud/Velocidad
	XGDX					;Obtener resultado de T_barra en acumulador
	LDAA TimerPant				;Cargar valor de TimerPant calculado previamente
	ABA					;TimerFinPant = TimerPant + T_barra
	STAA TimerFinPant			;Guardar valor de TimerFinPant calculado
	LDAB TimerPant				;Cargar valor de TimerPant calculado previamente para calcular TimerRociador
	SBA					;Restar TimerPant y TimerFinPant para calcular TimerRociador
	LSRA					;T_barra/2 = (TimerPant + TimerFinPant)/2
	ABA					;TimerRociador = T_barra/2 + TimerPant
	STAA TimerRociador			;Guardar valor calculado de TimerRociador
	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	TAREA CONFIGURAR
;******************************************************************************
Tarea_Configurar
	LDAA Valor_DS				;Cargar valor de DS actualmente
	CMPA #$80				;Verificar si el Selector 623 se encuentra en el modo configurar
	loc
	BNE NO_CONFIGURE			;Saltar si no se encuentra en el modo configurar
	MOVB #LDConfig,LEDS			;Actualizar el patrón desplegado en los LEDs para el modo actual
	LDX Est_Pres_TConfig			;Cargar estado presente de la ME TConfig
	JSR 0,X					;Saltar al próximo estado de la ME TConfig
	BRA FIN`
NO_CONFIGURE
	MOVW #TConfig_Est1,Est_Pres_TConfig	;Actualizar estado para desplegar de nuevo mensaje en pantalla
FIN`	RTS					;Retornar de la subrutina

;============================== TCONFIG ESTADO 1 ==============================
TConfig_Est1
	MOVW #MSG_CONFIGURAR_L1,MSG_L1		;Cargar primera línea del mensaje Configurar
	MOVW #MSG_CONFIGURAR_L2,MSG_L2		;Cargar segunda línea del mensaje Configurar
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	LDAA LongOK				;Cargar último valor guardado de longitud de barra
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir LongOK a BCD
	MOVB #17*OFF,BCD2			;Cargar valor de DSP3:DSP4 para pantalla apagada
	MOVB BCD,BCD1				;Cargar LongOK a la parte baja de los displays
	JSR BORRAR_NUM_ARRAY			;Saltar a subrutina para borrar secuencia de teclas válida
	MOVW #TConfig_Est2,Est_Pres_TConfig	;Saltar al estado 2 para obtener una secuencia de teclas váldia
	RTS					;Retornar de la subrutina

;============================== TCONFIG ESTADO 2 ==============================
TConfig_Est2
	loc
	BRCLR Banderas_1,Array_OK,FIN`		;Saltar si aun no se tiene una secuencia de teclas lista
	BCLR Banderas_1,Array_OK		;Limpiar Array_OK para recibir de forma iterante un valor para LongOK
	LDD Num_Array				;Cargar valor leído del teclado
	JSR BCD_BIN				;Saltar para convertir ValorLong a binario
	LDAA ValorLong				;Cargar valor leído del teclado convertido a binario
	CMPA #Lmin				;Verificar si el valor leído del teclado es mayor que la longitud mínima
	BLO BORRAR_NUM				;Saltar si el valor leido del teclado matricial es menor que la longitud mínima
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir valor binario a BCD
	MOVB #17*OFF,BCD2			;Cargar valor de DSP3:DSP4 para pantalla apagada
	MOVB BCD,BCD1				;Cargar LongOK a la parte baja de los displays
	MOVB ValorLong,LongOK			;Actualizar LongOK con el valor leído del teclado matricial
BORRAR_NUM
	JSR BORRAR_NUM_ARRAY			;Saltar a subrutina para borrar secuencia de teclas válida ingresada
FIN`	RTS					;Retornar de la subrutina
	loc
;******************************************************************************
;                       	TAREA MODO SELECCIONAR
;******************************************************************************
Tarea_Modo_SELECCIONAR
	LDAA Valor_DS				;Cargar valor actual de los dipswitch
	CMPA #$00				;Verificar si el selector 623 se encuentra en el modo seleccionar
	loc
	BNE NO_SELECCIONE			;Saltar si el selector 623 no se encuentra en el modo seleccionar
	MOVB #LDSelect,LEDS			;Actualizar el patrón desplegado en los LEDs para el modo actual
	LDX Est_Pres_TSelec			;Cargar el próximo estado de la ME TSelec
	JSR 0,X					;Saltar al próximo estado de la ME TSelec
	BRA FIN`				;Saltar para finalizar la subrutina
NO_SELECCIONE
	MOVW #TComp_Est1,Est_Pres_TSelec	;Actualizar estado para desplegar de nuevo mensaje en pantalla
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 1 ===============================
TComp_Est1
	MOVW #MSG_SELECCIONAR_L1,MSG_L1		;Cargar primera línea del mensaje del modo seleccionar
	MOVW #MSG_SELECCIONAR_S1,MSG_L2		;Cargar segunda línea del mensaje para denotar la espera del pulso del sensor S1
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	MOVB #17*OFF,BCD1			;Cargar valor de DSP3:DSP4 para pantalla apagada
	MOVB #17*OFF,BCD2			;Cargar valor de DSP3:DSP4 para pantalla apagada
	MOVW #TComp_Est2,Est_Pres_TSelec	;Cargar el estado 2 para esperar la activación de S1
	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 2 ===============================
TComp_Est2
	loc
	BRCLR Banderas_1,ShortP1,FIN`		;Saltar si aun no se ha activado el sensor S1
	BCLR Banderas_1,ShortP1			;Limpiar bandera de activación del sensor S1
	MOVW #MSG_SELECCIONAR_L1,MSG_L1		;Cargar primera línea del mensaje del modo seleccionar
	MOVW #MSG_SELECCIONAR_S2,MSG_L2		;Cargar segunda línea del mensaje para denotar la espera del pulso del sensor S2
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	MOVW #TComp_Est3,Est_Pres_TSelec	;Cargar el estado 3 para esperar la activación de S2
	MOVB #tTimerCal,TimerCal		;Cargar timer para calcular el intervalo temporal entre activaciones de S1 y S2
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 3 ===============================
TComp_Est3
	BRCLR Banderas_1,ShortP2,FIN`		;Saltar si aun no se ha activado el sensor S2
	BCLR Banderas_1,ShortP2			;Limpiar bandera de activación del sensor S2
	LDAA #tTimerCal				;Cargar valor que fue cargado inicialmente a TimerCal
	SUBA TimerCal				;Calcular intervalo temporal entre activaciones de S1 y S2
	STAA DeltaT				;Guardar intervalo temporal calculado
	MOVW #MSG_SELECCIONAR_L1,MSG_L1		;Cargar primera línea del mensaje del modo seleccionar
	MOVW #MSG_SELECCIONAR_BARRA,MSG_L2	;Cargar segunda línea del mensaje para denotar el paso del fin de la barra por S2
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	MOVW #TComp_Est4,Est_Pres_TSelec	;Cargar el estado 4 para esperarel fin de la barra
	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 4 ===============================
TComp_Est4
	BRCLR Banderas_1,ShortP2,FIN`		;Saltar si aun no se ha activado el sensor S2
	BCLR Banderas_1,ShortP2			;Limpiar bandera de activación de S2
	JSR CALCULA				;Saltar a subrutina para calcular parámetros cinemáticos de la barra
	LDAA Velocidad				;Cargar valor calculado de velocidad
	CMPA #VelocMin				;Verificar si el valor calculado de velocidad es mayor a Vmin
	BLO AlertaVelocidad			;Saltar si la velocidad es inválida (<Vmin)
	CMPA #VelocMax				;Verificar si el valor calculado de velocidad es menor a Vmax
	BHI AlertaVelocidad			;Saltar si la velocidad es inválida (>Vmax)
	LDAA Longitud				;Cargar valor calculado de longitud
	CMPA LongOK				;Verificar si el valor calculado de longitud es mayor o igual a LongOK
	BLO AlertaLongitud			;Saltar si el valor calculado de longitud es menor que LongOK
	CMPA #Lmax				;Verificar si el valor calculado de longitud es menor o igual que Lmax
	BHI AlertaLongitud			;Saltar si el valor calculado de longitud es mayor que Lmax
	MOVW #MSG_SELECCIONAR_L1,MSG_L1		;Cargar primera línea del mensaje para calcular parámetros cinemáticos
	MOVW #MSG_SELECCIONAR_CALCULE,MSG_L2	;Cargar segunda línea del para calcular parámetros cinemáticos
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	MOVW #TComp_Est5,Est_Pres_TSelec	;Cargar el estado 5 para retener el mensaje de error
	loc
	BRA FIN`				;Saltar para finalizar subrutina
AlertaVelocidad
	MOVW #MSG_VELOCIDAD,MSG_L1		;Cargar primera línea del mensaje de alerta de velocidad
	MOVW #MSG_RANGO,MSG_L2			;Cargar segunda línea del mensaje de alerta de velocidad
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	BRA AlertaDisplays			;Saltar para actualizar displays para este caso de error
AlertaLongitud
	MOVW #MSG_LONGITUD,MSG_L1		;Cargar primera línea del mensaje de alerta de longitud
	MOVW #MSG_RANGO,MSG_L2			;Cargar segunda línea del mensaje de alerta de longitud
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
AlertaDisplays
	;Limpieza de variables en caso de parámetro inválido
	LDAA Velocidad				;Cargar valor de velocidad calculado
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir velocidad a BCD
	MOVB BCD,BCD2				;Poner velocidad en la parte alta de los displays
	LDAA Longitud				;Cargar valor de longitud calculado
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir longitud a BCD
	MOVB BCD,BCD1				;Poner longitud en la parte baja de los displays
	CLR DeltaT				;Limpiar DeltaT
	CLR TimerRociador			;Limpiar TimerRociador
	CLR TimerPant				;Limpiar TimerPant
	CLR TimerFinPant			;Limpiar TimerFinPant
	CLR Velocidad				;Limpiar Velocidad
	CLR Longitud				;Limpiar Longitud
	;MOVB #17*GUIONES,BCD1			;Actualizar parte baja de los displays para que muestre ----
	;MOVB #17*GUIONES,BCD2			;Actualizar parte alta de los displays para que muestre ----
	MOVB #tTimerError,TimerError		;Cargar timer para retener el mensaje de error
	MOVW #TComp_Est6,Est_Pres_TSelec	;Cargar el estado 6 para retener el mensaje de error
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 5 ===============================
TComp_Est5
	TST TimerPant				;Verificar si ya es hora de desplegar la velocidad y longitud en la LCD
	loc
	BNE FIN`				;Saltar si aun no es hora de desplegar la velocidad y longitud en la LCD
	MOVW #MSG_SELECCIONAR_L1,MSG_L1		;Cargar primera línea del mensaje para calcular parámetros cinemáticos
	MOVW #MSG_SELECCIONAR_VL,MSG_L2		;Cargar segunda línea del para calcular parámetros cinemáticos
	BCLR Banderas_2,LCD_Ok			;Solicitar el despliegue del mensaje en la pantalla LCD
	LDAA Velocidad				;Cargar valor de velocidad calculado
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir velocidad a BCD
	MOVB BCD,BCD2				;Poner velocidad en la parte alta de los displays
	LDAA Longitud				;Cargar valor de longitud calculado
	JSR BIN_BCD_MUXP			;Saltar a subrutina para convertir longitud a BCD
	MOVB BCD,BCD1				;Poner longitud en la parte baja de los displays
	MOVW #TComp_Est7,Est_Pres_TSelec	;Saltar al estado 7 para esperar a TimerRociador y activar rociador
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 6 ===============================
TComp_Est6
	TST TimerError				;Verificar si ya se acabó el tiempo de desplegar el mensaje de error
	loc
	BNE FIN`				;Saltar si aun no es momento de quitar el mensaje de error
	MOVW #TComp_Est1,Est_Pres_TSelec	;Cargar el estado 1 para volver a esperar una barra
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 7 ===============================
TComp_Est7
	TST TimerRociador			;Verificar si ya es hora de activar el rociador
	loc
	BNE FIN`				;Saltar si aun no es hora de activar el rociador
	MOVB #tTimerShot,TimerShot		;Cargar timer para desactivar el rociador
	BSET PortRele,MaskRele			;Activar rele que habilita el rociador
	MOVW #TComp_Est8,Est_Pres_TSelec	;Saltar al estado 8 para esperar TimerShot y apagar relé
FIN`	RTS					;Retornar de la subrutina

;============================== TSelec ESTADO 8 ===============================
TComp_Est8
	TST TimerShot				;Verificar si ya es hora de desactivar el relé
	loc
	BNE FIN`				;Saltar si aun no es hora de desactivar el relé 
	BCLR PortRele,MaskRele			;Desactivar relé que habilita el rociador
	TST TimerFinPant			;Verificar si ya es hora de parar de desplegar resultados
	BNE FIN`				;Saltar si aun no es horar de parar de desplegar resultados 
	MOVW #TComp_Est1,Est_Pres_TSelec	;Saltar al estado 1 para reiniciar la ME TSelec
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	TAREA BRILLO
;******************************************************************************
Tarea_Brillo
	LDX Est_Pres_TBrillo				;Cargar estado presente de la ME Brillo
	JSR 0,X						;Saltar al próximo estado de la ME Brillo
	RTS						;Retornar de la subrutina

;============================== BRILLO ESTADO 1 =============================
TareaBrillo_Est1
	MOVB #tTimerBrillo,TimerBrillo			;Cargar timer para generar un ciclo de conversión del ATD
	MOVW #TareaBrillo_Est2,Est_Pres_TBrillo		;Saltar al estado 2 para generar una conversión dentro de tTimerBrillo segundos
	RTS						;Retornar de la subrutina

;============================== BRILLO ESTADO 2 =============================
TareaBrillo_Est2
	loc
	TST TimerBrillo					;Verificar si ya es hora de realizar la próxima conversión del ATD
	BNE FIN`					;Saltar si aun no es hora de realizar la próxima conversión del ATD
	MOVB #$87,ATD0CTL5				;Iniciar un ciclo de conversión del PAD7 del ATD0 con justificación derecha
	MOVW #TareaBrillo_Est3,Est_Pres_TBrillo		;Saltar al estado 3 para calcular Brillo a partir del resultado de la conversión
FIN`	RTS						;Retornar de la subrutina

;============================== BRILLO ESTADO 3 =============================
TareaBrillo_Est3
	loc
	BRCLR ATD0STAT0,MaskSCF,FIN`			;Saltar si aun no ha terminado el ciclo de conversión actual
	LDD ADR00H					;Cargar resultado de la primera conversión
	ADDD ADR01H					;Sumar resultado de la segunda conversión para obtener el promedio
	ADDD ADR02H					;Sumar resultado de la tercera conversión para obtener el promedio
	ADDD ADR03H					;Sumar resultado de la cuarta conversión para obtener el promedio
	LSRD						;Dividir entre 2 para obtener el promedio de los cuatro resultados
	LSRD						;Dividir entre 2 para obtener el promedio de los cuatro resultados (ya se dividió entre 4)
	LDX #255					;Cargar divisor para realizar progresión lineal
	FDIV						;(Valor promedio de conversión)/255
	TFR X,D						;Transferir resultado al registro D para multiplicarlo por 100
	LDY #100					;Cargar múltiplo para realizar progresión lineal
	EMUL						;100* (Valor promedio de conversión)/1024
	LDX #65535					;Cargar valor para corregir valor referido generado por FDIV
	EDIV						;Corregir valor referido a 2^16 generado por FDIV
	TFR Y,A						;Obtener parte baja del resultado
	STAA Brillo					;Guardar valor actualizado de brillo
	MOVW #TareaBrillo_Est1,Est_Pres_TBrillo		;Saltar al primer estado para iniciar una nueva conversión
FIN`	RTS						;Retornar de la subrutina

;******************************************************************************
;                       	TAREA TECLADO
;******************************************************************************
Tarea_Teclado
	loc
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
	LDAA CONT_TCL				;Cargar offset para indexar Num_Array
	LDAB Tecla_IN				;Cargar valor de tecla de entrada
	LDX #NUM_ARRAY				;Cargar dirección base de arreglo para teclas
	CMPA MAX_TCL				;Verificar si se alcanzó la secuencia de longitud máxima
	loc
	BEQ MAX`				;Saltar si se alcanzó la secuencia de longitud máxima
	TST CONT_TCL				;Verificar si es la primera tecla presionada
	BEQ FIRST`				;Saltar si es la primera tecla presionada
	CMPB #$0B				;Verificar si la tecla presionada fue Borrar
	BEQ BOR_T`				;Saltar si la tecla presionada fue Borrar
	CMPB #$0E				;Verificar si la tecla presionada fue Enter
	BEQ ENT`				;Saltar si la tecla presionada fue Enter
GUARDE` STAB A,X				;Almacenar la tecla presionada en Num_Array
	INC CONT_TCL				;Incrementar offset para indexar a Num_Array
	BRA FIN`				;Saltar para finalizar el estado
MAX`	CMPB #$0B				;Verificar si la tecla presionada es Borrar
	BEQ BOR`				;Saltar para borrar la tecla presionada
	CMPB #$0E				;Verificar si la teclra presionada es Enter
	BEQ ENT`				;Saltar para finalizar la secuencia de teclas válida
	BRA FIN`				;Saltar para finalizar el estado
FIRST`	CMPB #$0B				;Verificar si la tecla presionada es Borrar
	BEQ FIN`				;Saltar para finalizar el estado
	CMPB #$0E				;Verificar si la tecla presionada es Enter
	BEQ FIN`				;Saltar para finalizar el estado
	BRA GUARDE`				;Saltar para añadir una tecla a Num_Array
BOR_T`	TST CONT_TCL				;Verificar si es la primera tecla presionada
	BEQ FIN`				;Saltar para finalizar el estado
BOR`	DECA					;Decrementar offset
	MOVB #$FF,A,X				;Borrar última tecla añadaida a Num_Array
	STAA CONT_TCL				;Actualizar offset en memoria
	BRA FIN`				;Saltar para finalizar el estado
ENT`	CLR CONT_TCL				;Borrar offset para indexar Num_Array
	BSET Banderas_1,Array_OK		;Indicar que se ha generado un arreglo de teclas válido
	BRA FIN`				;Saltar para finalizar el estado
FIN`	MOVB #$FF,Tecla_IN			;Borrar valor de tecla de entrada
EST1`	MOVW #TareaTCL_Est1,Est_Pres_TCL	;Cambiar al estado 1 para procesar otra tecla
	RTS					;Retornar de la subrutina

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
;                               TAREA LEER PB1
;******************************************************************************
Tarea_Leer_PB1
        LDX EstPres_LeerPB1	;Cargar dirección de la subrutina asociada al estado presente en Est_Press_Leer_PB
        JSR 0,X			;Saltar a subrutina asociada al estado presente
	RTS			;Fin de la subrutina

;============================== LEER PB1 ESTADO 1 =============================
LeerPB1_Est1
	loc
        BRCLR PortPB,$08,LD_PB`        		;Salte si no se ha presionado el botón
        BRA FIN` 	                   	;Salte si ya se presionó el botón
LD_PB`  MOVB #tSupRebPB1,Timer_Reb_PB1        	;Cargar timer de rebotes
        MOVB #tShortP1,Timer_SHP1        	;Cargar timer de short press
        MOVB #tLongP1,Timer_LP1        		;Cargar timer de long press
        MOVW #LeerPB1_Est2,EstPres_LeerPB1 	;Actualizar el próximo estado
FIN`	RTS                             	;Retornar de subrutina

;============================== LEER PB1 ESTADO 2 =============================
LeerPB1_Est2
        TST Timer_Reb_PB1                	;Verificar si el timer de rebotes ya llegó a cero
	loc
        BNE FIN`                 		;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,$08,FALSO`              	;Salte si se detectó una falsa lectura
        MOVW #LeerPB1_Est1,EstPres_LeerPB1   	;Como la lectura es válida, saltar al estado para verificar si es un short press
        BRA FIN`	                      	;Saltar para terminar la subrutina
FALSO`  MOVW #LeerPB1_Est3,EstPres_LeerPB1   	;Como la lectura no es válida, saltar al estado inicial
FIN`	RTS                                  	;Fin de la subrutina

;============================== LEER PB1 ESTADO 3 =============================
LeerPB1_Est3
        TST Timer_SHP1               		;Verificar si el timer de short press llegó a cero
	loc
        BNE FIN`	                       	;Saltar si el timer ya llegó a cero
        BRCLR PortPB,$08,NO_SHP`              	;Saltar si el botón sigue presionado
        BSET Banderas_1,ShortP1              	;Habilitar bandera de short press 
        MOVW #LeerPB1_Est1,EstPres_LeerPB1   	;Cambiar al estado inicial, ya que fue short press
        BRA FIN` 	                        ;Saltar para terminar la subrutina
NO_SHP` MOVW #LeerPB1_Est4,EstPres_LeerPB1   	;Cambiar al estado 4, para verificar si es long press
FIN`	RTS					;Fin de la subrutina

;============================== LEER PB1 ESTADO 4 =============================
LeerPB1_Est4
        TST Timer_LP1          			;Verificar si el timer de long press llegó a cero
	loc
        BNE T_NO_Z`                 		;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,$08,FIN` 			;Saltar si el botón sigue presionado
        BSET Banderas_1,LongP1  		;El botón se presionó antes del timer acabara. Es short press, habilitar bandera
        BRA I_EST`                     		;Saltar para transicionar al estado inicial
T_NO_Z` BRCLR PortPB,$08,FIN` 			;Saltar si el botón sigue presionado
        BSET Banderas_1,ShortP1   		;Habilitar bandera de long press, ya que se verificó que sí es
I_EST`  MOVW #LeerPB1_Est1,EstPres_LeerPB1  	;Cambiar al estado inicial
FIN`	RTS					;Fin de la subrutina

;******************************************************************************
;                               TAREA LEER PB2
;******************************************************************************
Tarea_Leer_PB2
	loc
        LDX EstPres_LeerPB2	;Cargar dirección de la subrutina asociada al estado presente en Est_Press_Leer_PB
        JSR 0,X			;Saltar a subrutina asociada al estado presente
	RTS			;Fin de la subrutina

;============================== LEER PB2 ESTADO 1 =============================
LeerPB2_Est1
	loc
        BRCLR PortPB,$01,LD_PB`        		;Salte si no se ha presionado el botón
        BRA FIN` 	                   	;Salte si ya se presionó el botón
LD_PB`  MOVB #tSupRebPB2,Timer_Reb_PB2        	;Cargar timer de rebotes
        MOVB #tShortP2,Timer_SHP2        	;Cargar timer de short press
        MOVB #tLongP2,Timer_LP2        		;Cargar timer de long press
        MOVW #LeerPB2_Est2,EstPres_LeerPB2 	;Actualizar el próximo estado
FIN`	RTS                             	;Retornar de subrutina

;============================== LEER PB2 ESTADO 2 =============================
LeerPB2_Est2
        TST Timer_Reb_PB2                	;Verificar si el timer de rebotes ya llegó a cero
	loc
        BNE FIN`                 		;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,$01,FALSO`              	;Salte si se detectó una falsa lectura
        MOVW #LeerPB2_Est2,EstPres_LeerPB2   	;Como la lectura es válida, saltar al estado para verificar si es un short press
        BRA FIN`	                      	;Saltar para terminar la subrutina
FALSO`  MOVW #LeerPB2_Est3,EstPres_LeerPB2   	;Como la lectura no es válida, saltar al estado inicial
FIN`	RTS                                  	;Fin de la subrutina

;============================== LEER PB2 ESTADO 3 =============================
LeerPB2_Est3
        TST Timer_SHP2               		;Verificar si el timer de short press llegó a cero
	loc
        BNE FIN`	                       	;Saltar si el timer ya llegó a cero
        BRCLR PortPB,$01,NO_SHP`              	;Saltar si el botón sigue presionado
        BSET Banderas_1,ShortP2              	;Habilitar bandera de short press 
        MOVW #LeerPB2_Est1,EstPres_LeerPB2   	;Cambiar al estado inicial, ya que fue short press
        BRA FIN` 	                        ;Saltar para terminar la subrutina
NO_SHP` MOVW #LeerPB2_Est4,EstPres_LeerPB2   	;Cambiar al estado 4, para verificar si es long press
FIN`	RTS					;Fin de la subrutina

;============================== LEER PB2 ESTADO 4 =============================
LeerPB2_Est4
        TST Timer_LP2          			;Verificar si el timer de long press llegó a cero
	loc
        BNE T_NO_Z`                 		;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,$01,FIN` 			;Saltar si el botón sigue presionado
        BSET Banderas_1,LongP2  		;El botón se presionó antes del timer acabara. Es short press, habilitar bandera
        BRA I_EST`                     		;Saltar para transicionar al estado inicial
T_NO_Z` BRCLR PortPB,$01,FIN` 			;Saltar si el botón sigue presionado
        BSET Banderas_1,ShortP2   		;Habilitar bandera de long press, ya que se verificó que sí es
I_EST`  MOVW #LeerPB2_Est1,EstPres_LeerPB2  	;Cambiar al estado inicial
FIN`	RTS					;Fin de la subrutina

;******************************************************************************
;                       	TAREA LEER DS
;******************************************************************************
Tarea_Leer_DS
	LDX Est_Pres_LeerDS			;Cargar próximo estado de la ME Leer_DS
	JSR 0,X					;Saltar al próximo estado de la ME Leer_DS
	RTS					;Retornar de la subrutina

;============================== LEER DS ESTADO 1 =============================
LeerDS_Est1
	LDAA PortPB				;Cargar el estado actual del puerto H
	ANDA #$C0				;Obtener valor de PH[7:6]
	STAA Temp_DS				;Guardar temporalmente el valor de PH[7:6]
	MOVB #tTimerRebDS,Timer_RebDS		;Cargar timer para suprimir rebotes del DS
	MOVW #LeerDS_Est2,Est_Pres_LeerDS	;Saltar al estado 2 para suprimir rebotes del DS
	RTS					;Retornar de la subrutina

;============================== LEER DS ESTADO 2 =============================
LeerDS_Est2
	TST Timer_RebDS				;Verificar si el timer de supresión de rebotes del DS ya llegó a cero
	loc
	BNE FIN`				;Saltar si el timer de supresión de rebotes del DS aun no ha llegado a cero
	LDAA PortPB				;Cargar el estado actual del puerto H
	ANDA #$C0				;Obtener el valor de PH[7:6]
	CMPA Temp_DS				;Verificar si el valor de los DS es el que se guardó temporalmente en el estado 1
	BNE NO_DS				;Saltar si el valor de los DS leído no es el que se guardó temporalmente en el estado 1
	STAA Valor_DS				;Actualizar valor leído de los DS
NO_DS	MOVW #LeerDS_Est1,Est_Pres_LeerDS	;Saltar al estado 1 para leer nuevamente los DS
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	TAREA PANTALLA MUX
;******************************************************************************
Tarea_PantallaMUX
	LDX EstPres_PantallaMUX		;Cargar dirección de la subrutina para el próximo estado
	JSR 0,X				;Saltar a la subrutina del próximo estado
	RTS				;Retornar de la subrutina 

;============================== PANTALLA MUX ESTADO 1 =========================
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
TICKS`	MOVW #MaxCountTicks,Counter_Ticks		;Iniciar el contador de ticks
	MOVW #PantallaMUX_Est2,EstPres_PantallaMUX	;Actualizar la variable de estado para saltar al estado 2
FIN`	RTS				;Retornar de la subrutina

;============================== PANTALLA MUX ESTADO 2 =========================
PantallaMUX_Est2
	LDD Counter_Ticks		;Cargar contador de ticks
	NEGB				;Invertir orden de conteo para comparar con Brillo
	ADDB #100			;Sumar 100 para invertir el orden de conteo
	CMPB Brillo			;Verificar si el contador de ticks ya alcanzó el valor de brillo
	loc
	BLO FIN` 			;Saltar si aun no se llegó al valor de brillo
	BSET PTP,$0F			;Deshabilitar displays de 7 segmentos 
	BSET PTJ,$02			;Deshabilitar LEDs
	MOVW #PantallaMUX_Est1,EstPres_PantallaMUX	;Actualizar la variable de estado para saltar al estado 1
FIN`	RTS						;Retornar de la subrutina

;******************************************************************************
;                       	TAREA LCD
;******************************************************************************
Tarea_LCD
	loc
	BRSET Banderas_2,LCD_Ok,FIN`	;Saltar si aun no se ha solicitado el envío de un mensaje al LCD
	LDX EstPres_TareaLCD		;Cargar estado presente para la ME LCD
	JSR 0,X				;Saltar a subrutina del estado presente
FIN`	RTS				;Retornar de la subrutina

;============================== LCD ESTADO 1 ==================================
TareaLCD_Est1
	BCLR Banderas_2,FinSendLCD		;Borrar bandera de fin de envío de Char
	BCLR Banderas_2,RS			;Borrar bandera RS para enviar un comando
	loc
	BRSET Banderas_2,Second_Line,SI_MSG1	;Saltar si aun no se ha terminado de enviar el mensaje a partir de MSG_L1
	MOVB #ADD_L1,CharLCD			;Cargar dirección de la primera línea del mensaje en la pantalla LCD
	MOVW MSG_L1,Punt_LCD			;Cargar dirección de la primera línea del mensaje en el MCU
	BRA SIGA`				;Saltar para enviar CharLCD
SI_MSG1	MOVB #ADD_L2,CharLCD			;Cargar dirección de la segunda línea del mensaje en la pantalla LCD
	MOVW MSG_L2,Punt_LCD			;Cargar dirección de la segunda línea del mensaje en el MCU
SIGA`	JSR Tarea_SendLCD			;Saltar a subrutina para enviar CharLCD
	MOVW #TareaLCD_Est2,EstPres_TareaLCD	;Cambiar al estado 2, para enviar el mensaje
	RTS					;Retornar de la subrutina

;============================== LCD ESTADO 2 ==================================
TareaLCD_Est2
	loc
	BRCLR Banderas_2,FinSendLCD,SIGA`	;Saltar si ya se envió el comando con la dirección del mensaje
	BCLR Banderas_2,FinSendLCD		;Limpiar bandera para enviar un nuevo Char
	BSET Banderas_2,RS			;Habilitar RS para enviar un dato
	LDX Punt_LCD				;Cargar dirección del mensaje por enviar
	LDAA 1,X+				;Cargar char del mensaje y ajustar índice para que apunte al siguiente char por enviar
	STX Punt_LCD				;Actualizar puntero en memoria, apuntando al siguiente char por enviar
	STAA CharLCD
	CMPA #$FF				;Verificar si ya se alcanzó el indicador de fin de mensaje
	BEQ FINMSG				;Saltar para verificar el estado de envío de los mensajes
SIGA`	JSR Tarea_SendLCD			;Saltar a subrutina para el envío de un char con el protocolo estroboscópico
	BRA FIN`				;Saltar para finalizar subrutina, manteniendose en el estado 2
FINMSG	BRCLR Banderas_2,Second_Line,NO_MSG2	;Saltar si aun no se ha enviado el mensaje 2
	BCLR Banderas_2,Second_Line		;Limpiar bandera de Second_Line, ya que el mensaje 2 fue enviado correctamente
	BSET Banderas_2,LCD_Ok			;Habilitar bandera para indicar que ya fueron enviadas ambas líneas del mensaje
	BRA FIN_EST				;Saltar para cargar el estado inicial de la máquina de estados
NO_MSG2	BSET Banderas_2,Second_Line		;Habilitar bandera para enviar el mensaje 2
FIN_EST	MOVW #TareaLCD_Est1,EstPres_TareaLCD	;Cambiar al estado 1, para cargar las direcciones correspondientes al mensaje 2
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	TAREA SEND_LCD
;******************************************************************************
Tarea_SendLCD
	loc
	LDX EstPres_SendLCD			;Cargar estado inicial de la ME Send_LCD
	JSR 0,X					;Saltar a la subrutina del estado presente
	RTS					;Retornar de la subrutina

;============================== SEND_LCD ESTADO 1 ============================
SendLCD_Est1
	LDAA CharLCD				;Cargar caracter por enviar a la pantalla LCD
	ANDA #$F0				;Obtener nibble superior de CharLCD
	LSRA					;Desplazar nibble por primera vez para que quede en A[5:2]
	LSRA					;Desplazar nibble por segunda vez para que quede en A[5:2]
	STAA PORTK				;Cargar nibble superior de CharLCD en PORTK[5:2]
	loc
	BRCLR Banderas_2,RS,CMD`		;Saltar si CharLCD es un comando
	BSET PORTK,$01				;Habilitar RS, ya que CharLCD es un dato
	BRA SIGA`				;Saltar para escribir dato a LCD
CMD`	BCLR PORTK,$01				;Deshabilitar RS, ya que CharLCD es un comando
SIGA`	BSET PORTK,$02				;Habilitar EN para escribir CharLCD a LCD
	MOVW #tTimer260uS,Timer260uS		;Cargar timer de 260uS para que LCD procese CharLCD
	MOVW #SendLCD_Est2,EstPres_SendLCD	;Cargar estado 2, para mandar parte baja de CharLCD
	RTS					;Retornar de la subrutina

;============================== SEND_LCD ESTADO 2 =============================
SendLCD_Est2
	LDD Timer260uS				;Verificar si el timer de 260uS llegó a cero
	loc 
	BNE FIN`				;Saltar si el timer no ha llegado a cero
	BCLR PORTK,$01				;Deshabilitar EN para mandar parte baja de CharLCD
	LDAA CharLCD				;Cargar caracter por enviar a la pantalla LCD
	ANDA #$0F				;Obtener nibble inferior de CharLCD
	LSLA					;Desplazar nibble por primera vez para que quede en A[5:2]
	LSLA					;Desplazar nibble por segunda vez para que quede en A[5:2]
	STAA PORTK				;Cargar nibble inferior de CharLDC en PORTK[5:2]
	BRCLR Banderas_2,RS,CMD`		;Saltar si CharLCD es un comando
	BSET PORTK,$01				;Habilitar RS, ya que CharLCD es un dato
	BRA SIGA`				;Saltar para escribir dato a LCD
CMD`	BCLR PORTK,$01				;Deshabilitar RS, ya que CharLCD es un comando
SIGA`	BSET PORTK,$02				;Habilitar EN para escribir CharLCD a LCD
	MOVW #tTimer260uS,Timer260uS		;Cargar timer de 260uS para que LCD procese CharLCD
	MOVW #SendLCD_Est3,EstPres_SendLCD	;Cargar estado 3, para esperar a que se cargue y procese el dato/comando
FIN`	RTS					;Retornar de la subrutina

;============================== SEND_LCD ESTADO 3 =============================
SendLCD_Est3
	LDD Timer260uS				;Verificar si el timer de 260uS llegó a cero
	loc
	BNE FIN`				;Saltar si el timer ya llegó a cero
	BCLR PORTK,$02				;Deshabilitar EN, debido a que el dato ya fue enviado a LCD
	MOVW #tTimer40uS,Timer40uS		;Cargar timer de 40uS para que se procese el dato/comando en LCD
	MOVW #SendLCD_Est4,EstPres_SendLCD	;Cambiar al estado 4 para terminar protocolo estroboscópico
FIN`	RTS					;Retornar de la subrutina

;============================== SEND_LCD ESTADO 4 =============================
SendLCD_Est4
	LDD Timer40uS				;Verificar si el timer de 40uS llegó a cero
	loc 
	BNE FIN`				;Saltar si el timer aun no ha llegado a cero 
	BSET Banderas_2,FinSendLCD		;Levantar bandera para indicar el envío y procesamiento de CharLCD
	MOVW #SendLCD_Est1,EstPres_SendLCD	;Cambiar al estado 1 para enviar otro dato
FIN`	RTS					;Retornar de la subrutina

;******************************************************************************
;                       	SUBRUTINA BCD_BIN
;******************************************************************************
BCD_BIN
	STAB ValorLong				;Guardar dígito de las unidades temporalmente
	TAB					;Mover decenas a la parte baja del acumulador D para multiplicar por decada
	LDAA #10				;Cargar decada para obtener valor binario
	MUL					;Multiplicar por decada dígito de las decenas
	LDAA ValorLong				;Cargar dígito de las unidades que fue guardado temporalmente
	ABA					;Sumar unidades y década multiplicada
	STAA ValorLong				;Guardar valor actualizado
	RTS					;Retronar de la subrutina 

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
	LDX #Segment		;Cargar dirección base de tabla con códigos de 7 Segmentos
	LDAA BCD2		;Cargar valor superior de los displays
	ANDA #$F0		;Obtener nibble superior (DSP1)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/2)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/4)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/8)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/16)
	MOVB A,X,DSP1		;Actualizar valor desplegado en el display DSP2
	LDAA BCD2		;Cargar valor superior de los displays
	ANDA #$0F		;Obtener nibble inferior (DSP2)
	MOVB A,X,DSP2		;Actualizar valor desplegado en el display DSP2
	LDAA BCD1		;Cargar valor inferior de los displays
	ANDA #$F0		;Obtener nibble superior (DSP3)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/2)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/4)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/8)
	LSRA			;Dividir valor entre dos para que quede justificado a la derecha (/16)
	MOVB A,X,DSP3		;Actualizar valor desplegado en el display DSP3
	LDAA BCD1		;Cargar valor superior de los displays
	ANDA #$0F		;Obtener nibble inferior (DSP4)
	MOVB A,X,DSP4		;Actualizar valor desplegado en el display DSP4
	RTS			;Retornar de las subrutina
	loc

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
;                       	SUBRUTINA LEER_TECLADO
;*****************************************************************************
LEER_TECLADO
	LDAB #3				;Cargar valor de primera tecla por leerse
	MOVB #$EF,Patron		;Cargar valor inicial para desplazar las teclas
	loc
SIGA`	MOVB Patron,PORTA		;Cargar patron al puerto A, para accesar al teclado 
	BRCLR PORTA,$04,COPIE`		;Saltar si la tecla presionada está en la columna 2
	DECB				;Decrementar contador para verificar las teclas en el próximo ciclo
	BRCLR PORTA,$02,COPIE`		;Saltar si la tecla presionada está en la columna 1
	DECB				;Decrementar contador para verificar si está en la columna 2
	BRCLR PORTA,$01,COPIE`		;Saltar si la tecla presionada está en la columna 0
	DECB				;Decrementar contador para verificar si está en la columna 1
	LDAA Patron			;Cargar máscara para desplazar 0 en la parte alta de PORTA
	CMPA #$7F			;Verificar si ya se llegó a la última fila
	BNE SHIFT`			;Saltar si aun faltan filas por procesar
	MOVB #$FF,Tecla			;No se encontró una tecla presionada
	BRA FIN`			;Saltar para terminar la subrutina
SHIFT`	SEC				;Poner C=1 para que solo se roten 1s a Patron
	ROL Patron			;Desplazar 0 para acceder a la siguiente fila
	ADDB #6				;Sumar 3 a la cuenta de B para seguir con la siguiente fila
	BRA SIGA`			;Saltar para seguir procesando filas
COPIE`	LDX #Teclas			;Cargar dirección base de tabla con teclas
	DECB				;Decrementar contador para que empiece en cero
	MOVB B,X,Tecla			;Actualizar tecla presionada
FIN`	RTS				;Retornar de la subrutina

;******************************************************************************
;                       SUBRUTINA DE ATENCION A OUTPUT COMPARE
;******************************************************************************
Maquina_Tiempos:
	LDD TCNT			;Cargar valor actual del timer
	ADDD #Carga_TC4			;Cargar el valor inicial de comparación para el canal 4
	STD TC4				;Guardar el nuevo valor de comparación
	LDX #Tabla_Timers_BaseT         ;Cargar direcciÃ³n base de tabla base T
        JSR Decre_Timers_BaseT          ;Llamar a subrutina para decrementar timers
NOCERO`	LDD Timer1mS               	;Verificar si el timer de 1mS llegÃ³ a 0
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
NOCERO`	RTI				;Retornar de la ISR

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
