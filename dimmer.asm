        ;; A dimmer switch program

        list      p=12f675      ; list directive to define processor
        #include <p12f675.inc>  ; processor specific variable definitions
        errorlevel  -302        ; suppress message 302 from list file

;************************** VARIABLE DEFINITIONS ******************************

        cblock      0x20        ; the first data memory location where variables can be put
        ON_OFF                  ; The last bit of this is 1 if the light was turned on last time
        BRIGHT                  ; stores the brightness to which the LED should be set
        endc                    ; end of variable declaration

;****************************** Start of Program ******************************
        org     0x000           ; processor reset vector
        goto    Program_Start

        org     0x004           ; This is where the microprocessor goes when an interrupt happens
        goto    Interrupt       ; so we tell it to jump to the interrupt routine

        org     0x005           ; Start of Program Memory Vector
Program_Start

        bsf     STATUS,RP0      ; Bank 1
	call    0x3ff           ; update factory calibrated oscillator: get the calibration value
        movwf   OSCCAL          ; update factory calibrated oscillator: store it in OSCCAL

        movlw   B'00111111'     ; Set all I/O pins as inputs
        movwf   TRISIO

        movlw   B'00000001'     ; only use AD0
        movwf   ANSEL

        movlw   B'10000010'     ; Weak pullups: disabled
        movwf   OPTION_REG      ; TMR0 prescaler: 1:8

        bsf     INTCON, GIE     ; General interrup enable
        bsf     INTCON, T0IE    ; enable Timer0 interrupt

        bcf     STATUS,RP0      ; Bank 0
        bsf     ADCON0, ADON    ; Turn the AD converter ON
        clrf    GPIO            ; clear all outputs


Main_Loop
        clrwdt                  ; clear Watch Dog Timer

        bcf     STATUS,RP0      ; Bank 0
        btfss   ADCON0,1        ; if it's not converting
        bsf     ADCON0,1        ; then tell it to start




        goto    Main_Loop       ; repeat these instructions forever (but interrupts happen)


Interrupt
        ;; sort out the interrupt flags
        bsf     STATUS, RP0     ; Bank 1
        bcf     INTCON, T0IF    ; Clear the Timer0 interrupt flag

        ;;  the interrupt was caused by Timer0
        btfsc   ON_OFF,0        ; if the LED is off don't goto Turn_Off, goto Turn_On instead
        goto    Turn_Off        ; then jump to LED off
