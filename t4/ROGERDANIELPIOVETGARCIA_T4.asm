;******************************************************************************
;                              	TAREA #4
;******************************************************************************

#include registers.inc

;******************************************************************************
;                 RELOCALIZACION DE VECTOR DE INTERRUPCION
;******************************************************************************
	ORG VEC_RTI
    	DW Maquina_Tiempos

;******************************************************************************
;                                ENCABEZADO
;******************************************************************************

;--- Aqui se colocan los valores de carga para los timers baseT  ----

tTimer1mS    	EQU	1	;Base de tiempo de 1 mS (1 ms x 1)
tTimer10mS    	EQU	10	;Base de tiempo de 10 mS (1 mS x 10)
tTimer100mS   	EQU	100	;Base de tiempo de 100 mS (10 mS x 100)
tTimer1S       	EQU	1000	;Base de tiempo de 1 segundo (100 mS x 10)
tSupReb_PB	EQU    	10     	;Tiempo de supresión de rebotes x 1mS
tShortP_PB     	EQU    	30     	;Tiempo mínimo ShortPress x 10mS
tLongP_PB	EQU   	3     	;Tiempo mínimo LongPress en segundos
tTimerLDTst    	EQU	1    	;Tiempo de parpadeo de LED testigo en segundos

;--- Aqui se colocan el resto de valores del programa ----

PortPB        	EQU   	PTIH   	;Se define el puerto donde se ubica el PB
MaskPB       	EQU    	$01    	;Se define el bit del PB en el puerto
RTIF      	EQU   	$80    	;RTIF = CRGFLG.7. Habilita/Deshabilita RTI
ShortP_PB	EQU	$01	;ShortP_PB = Banderas_PB.0
LongP_PB	EQU    	$02	;LongP_PB = Banderas_PB.1
INIT_EST_DATOS	EQU    	$1000	;Incio de las estructuras de datos
INIT_PILA	EQU	$3BFF	;Valor inicial de la pila 
INIT_T_TIMERS 	EQU   	$1040	;Inicio de la tabla de timers
INIT_PROG    	EQU    	$2000	;Inicio del programa principal
VEC_RTI		EQU	$3E70	;Vector de interrupción RTI

;******************************************************************************
;                       DECLARACION DE LAS ESTRUCTURAS DE DATOS
;******************************************************************************

	ORG INIT_EST_DATOS
Est_Press_Leer_PB	DS        2	;Variable de estado para la ME Leer_PB
Banderas_PB         	DS        1	;Variable bandera X:X:X:X:X:X:LongP_PB:ShortP_PB
                                
;===============================================================================
;                              TABLA DE TIMERS
;===============================================================================

    	Org INIT_T_TIMERS
Tabla_Timers_BaseT		
Timer1mS 	ds 	2       ;Timer 1 ms con base a tiempo de interrupcion
Timer10mS	ds 	2       ;Timer para generar la base de tiempo 10 mS
Timer100mS	ds 	2       ;Timer para generar la base de tiempo de 100 mS
Timer1S		ds	2       ;Timer para generar la base de tiempo de 1 Seg.
Fin_BaseT       dW $FFFF	;Indicador de fin de tabla

Tabla_Timers_Base1mS
Timer_Reb_PB  	ds    	1	;Timer para manejar los rebotes de los botones pulsadores
Fin_Base1mS:    dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base10mS
Timer_SHP_PB 	ds   	1	;Timer para identificar un short press
Fin_Base10ms    dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base100mS
Timer1_100mS  	ds   	1	;Timer default (sin utilizarse)
Fin_Base100mS   dB 	$FF	;Indicador de fin de tabla

Tabla_Timers_Base1S
Timer_LED_Testigo	ds	1	;Timer para parpadeo de led testigo
Timer_LP_PB            	ds    	1	;Timer para identificar un long press	
Fin_Base1S   		dB 	$FF	;Indicador de fin de tabla

;===============================================================================
;                              CONFIGURACION DE HARDWARE
;===============================================================================
	ORG INIT_PROG
        Bset DDRB,$81         	;Habilitacion del LED Testigo
        Bset DDRJ,$02          	;como comprobacion del timer de 1 segundo
        BClr PTJ,$02         	;haciendo toogle
        Movb #$0F,DDRP      	;bloquea los display de 7 Segmentos
        Movb #$0F,PTP
        Movb #$17,RTICTL	;Se configura RTI con un periodo de 1 mS
        Bset CRGINT,$80

;===============================================================================
;                           PROGRAMA PRINCIPAL
;===============================================================================
        Movw #tTimer1mS,Timer1mS
        Movw #tTimer10mS,Timer10mS         	;Inicia los timers de bases de tiempo
        Movw #tTimer100mS,Timer100mS
        Movw #tTimer1S,Timer1S
        Movb #tTimerLDTst,Timer_LED_Testigo  	;inicia timer parpadeo led testigo
        MOVB #$00,Timer_SHP_PB
        MOVB #$00,Timer_LP_PB			;Limpia los timers por usar
        MOVB #$00,Timer_Reb_PB
        Lds #INIT_PILA				;Inicializa la pila
        Cli					;Habilitar interrupciones no mascarables
        Clr Banderas_PB				;Limpia las banderas
        MOVW #LeerPB_Est1,Est_Press_Leer_PB	;Carga estado inicial para la ME Leer_PB
Despachador_Tareas
        Jsr Tarea_Led_Testigo			;Despacha Tarea_Led_Testigo
        Jsr Tarea_Leer_PB			;Despacha Tarea_Leer_PB
        Jsr Tarea_LED_PB			;Despacha Tarea_LED_PB
	;Jsr Tarea_Teclado			;Despacha Tarea_Teclado
	;Jsr Tarea_Borrar_TCL			;Despacha Tarea_Borrar_TCL
        Bra Despachador_Tareas			;Saltar para seguir despachando
       
;******************************************************************************
;                               TAREA LED_PB
;******************************************************************************

Tarea_LED_PB
        BRSET Banderas_PB,ShortP_PB,ON 	;Si es un short press, enciende LED
        BRSET Banderas_PB,LongP_PB,OFF	;Si es un long press, apaga LED
        BRA FIN_LED
ON      BCLR Banderas_PB,ShortP_PB   	;Borra las banderas asociadas y
        BSET PORTB,$01                	;ejecuta la acción
        BRA FIN_LED
OFF     BCLR Banderas_PB,LongP_PB
        BCLR PORTB,$01
FIN_LED	RTS

;******************************************************************************
;                               TAREA LED TESTIGO
;******************************************************************************

Tarea_Led_Testigo
	Tst Timer_LED_Testigo
	Bne FinLedTest
	Movb #tTimerLDTst,Timer_LED_Testigo
	Ldaa PORTB
	Eora #$80
	Staa PORTB
FinLedTest    	
	Rts

;******************************************************************************
;                               TAREA LEER PB
;******************************************************************************
;        Método par la implementación de la máquina de estados Leer_PB
;
;El estado de partida  se iniciaiza en la variable Est_Press_Leer_PB
;en el programa principal
;
;En cada estado, se actualiza Est_Press_Leer_PB cargando la dirección del 
;próximo estado
;******************************************************************************

Tarea_Leer_PB
        LDX Est_Press_Leer_PB
        JSR 0,X
FinTareaPB
        RTS

;============================== LEER PB ESTADO 1 =============================

LeerPB_Est1
        BRCLR PortPB,MaskPB,LD_PB		;Salte si no se ha presionado el botón
        BRA FIN_PBEs1                    	;Salte si ya se presionó el botón
LD_PB   MOVB #tSupReb_PB,Timer_Reb_PB        	;Cargar timer de rebotes
        MOVB #tShortP_PB,Timer_SHP_PB        	;Cargar timer de short press
        MOVB #tLongP_PB,Timer_LP_PB        	;Cargar timer de long press
        MOVW #LeerPB_Est2,Est_Press_Leer_PB    	;Actualizar el próximo estado
FIN_PBEs1
	RTS                                	;Retornar de subrutina

;============================== LEER PB ESTADO 2 =============================

LeerPB_Est2
        TST Timer_Reb_PB                 	;Verificar si el timer de rebotes ya llegó a cero
        BNE FIN_PBEs2                          	;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,MaskPB,FALSO               ;Salte si se detectó una falsa lectura
        MOVW #LeerPB_Est1,Est_Press_Leer_PB    	;Como la lectura es válida, saltar al estado para verificar si es un short press
        BRA FIN_PBEs2                       	;Saltar para terminar la subrutina
FALSO  	MOVW #LeerPB_Est3,Est_Press_Leer_PB    	;Como la lectura no es válida, saltar al estado inicial
FIN_PBEs2
	RTS                                    	;Fin de la subrutina

;============================== LEER PB ESTADO 3 =============================

LeerPB_Est3
        TST Timer_SHP_PB                      	;Verificar si el timer de short press llegó a cero
        BNE FIN_PBEs3                          	;Saltar si el timer ya llegó a cero
        BRCLR PortPB,MaskPB,NO_SHP             	;Saltar si el botón sigue presionado
        BSET Banderas_PB,ShortP_PB             	;Habilitar bandera de short press 
        MOVW #LeerPB_Est1,Est_Press_Leer_PB    	;Cambiar al estado inicial, ya que fue short press
        BRA FIN_PBEs3                         	;Saltar para terminar la subrutina
NO_SHP  MOVW #LeerPB_Est4,Est_Press_Leer_PB    	;Cambiar al estado 4, para verificar si es long press
FIN_PBEs3
	RTS

;============================== LEER PB ESTADO 4 =============================
LeerPB_Est4
        TST Timer_LP_PB                    	;Verificar si el timer de long press llegó a cero
        BNE T_NO_Z                             	;Saltar si el timer no ha llegado a cero
        BRCLR PortPB,MaskPB,FIN_PBEs4          	;Saltar si el botón sigue presionado
        BSET Banderas_PB,LongP_PB             	;El botón se presionó antes que el timer acabara. Habilitar bandera SHP
        BRA I_EST                             	;Saltar para transicionar al estado inicial
T_NO_Z  BRCLR PortPB,MaskPB,FIN_PBEs4          	;Saltar si el botón sigue presionado
        BSET Banderas_PB,ShortP_PB            	;Habilitar bandera de long press, ya que se verificó que sí es
I_EST   MOVW #LeerPB_Est1,Est_Press_Leer_PB    	;Cambiar al estado inicial
FIN_PBEs4
	RTS
	
;******************************************************************************
;                       	TAREA TECLADO
;******************************************************************************
Tarea_Teclado

;******************************************************************************
;                       	TAREA Borrar Tecla
;******************************************************************************
Tarea_Borrar_TCL
	
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
        RTI

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
