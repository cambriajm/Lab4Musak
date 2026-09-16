//Cambria Morgan
//RCET3373
//Musak
//git
//-Wl,-presetVect=0000h,-pcode=0008h
    
; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
  count EQU 0x20 ; use data memory address 0x20 as part of an 8 bit counter 
 countout EQU 0x21
 incount EQU 0x22
 ButtonValue EQU 0x23
 ;Reset Vector at 0000h. Execution starts here after reset 
PSECT resetVect,class=CODE,delta=2
ResetVector:
    NOP
    NOP
    goto Setup
    
;Main code section starts at 0008h. User code goes here.
PSECT code,class=CODE,delta=2 //after PSECT everything is grouped until the next PSECT

Setup:
   ; add device setup here 
    BCF 0x03,6 ;set bank 0 active
    BCF 0x03,5;set bank 0
    CLRF 0x06 ;setting portb reset low
    CLRF 0x05 ; setting porta on reset low 
    
    BCF 0x03,6
    BSF 0x03,5 ;set bank 1 active 
    MOVLW 0x00
    MOVWF 0x85  ;TRISA set PortA as outputs
    MOVLW 0xFF
    MOVWF 0x86  ;TRISB set RB0 as input
    
    BSF 0x03,6
    BCF 0x03,5 ;set bank 2
    BSF 0x09,1 ;turn TTG function off
    
    BSF 0x03,6 
    BSF 0x03,5 ;set bank 3 
  // CLRF 0x89 ;anselh turn off
   // CLRF 0x88
      CLRF 0x188   ; Clear ANSEL (Turns PORTA pins into digital I/O)
    CLRF 0x189   ; Clear ANSELH (Turns PORTB pins into digital I/O)
    
    BCF 0x03,6 ;set bank 0 active
    BCF 0x03,5 ;set bank 0

    goto Main
Main: 
   //main code goes here. Repeats forever because setup goes once 
   call ButtonTest
   call LookupTable
   MOVWF countout
    
   call OuterDelay
   MOVLW 0x01
   XORWF 0x05,1
  
   //BTFSC 0x06, 0 ;testing if there is the button on rb0 being pressed 
   //goto NoButton
   
   goto Main 
   


ButtonTest:
    BTFSS 0x06,0 ;testing if there is the button on rb7 being pressed  
    goto ButtonOne
    MOVLW 0
    MOVWF ButtonValue 
    Return
    ButtonOne:
    BTFSS 0x06,1 ;testing if there is the button on rb6 being pressed 
    goto ButtonTwo
    MOVLW 1
    MOVWF ButtonValue 
Return
    ButtonTwo:
    BTFSS 0x06,2 ;testing if there is the button on rb5 being pressed
    goto ButtonThree
    MOVLW 2
    MOVWF ButtonValue 
    Return
    ButtonThree:
    BTFSS 0x06,3 ;testing if there is the button on rb4 being pressed 
    goto ButtonFour
    MOVLW 3
    MOVWF ButtonValue
Return
    ButtonFour:  
    BTFSS 0x06,4 ;testing if there is the button on rb3 being pressed 
    goto ButtonFive
    MOVLW 4
    MOVWF ButtonValue
Return
    ButtonFive:
    BTFSS 0x06,5 ;testing if there is the button on rb2 being pressed 
    goto ButtonSix
    MOVLW 5
    MOVWF ButtonValue
Return
    ButtonSix:
    BTFSS 0x06,6 ;testing if there is the button on rb1 being pressed 
    goto ButtonSeven
    MOVLW 6
    MOVWF ButtonValue
Return
    ButtonSeven:
    BTFSS 0x06,7 ;testing if there is the button on rb0 being pressed 
    goto NoButton
    MOVLW 7
    MOVWF ButtonValue
    return
    NoButton:
    BCF 0x05,0 
    CLRF ButtonValue
    return

    
OuterDelay: 
MOVLW 0X04
MOVWF incount 
    
InDelay: 

DECFSZ incount,1 
GOTO InDelay

DECFSZ countout,1 
GOTO OuterDelay 

Return
               ;1(2) 1 TCY if not zero, 2 TCY if zero
                 ;2 TCY
 
   
LookupTable: 
    MOVF ButtonValue,W
    ADDWF PCL,1
    RETLW 0x00
    RETLW 0xEE	    ;note C3, RB0
    RETLW 0xD4	    ;note B3, RB1
    RETLW 0xBD	    ;note A3, RB2
    RETLW 0xB2	    ;note G3, RB3 
    RETLW 0x9F	    ;note F3, RB4 
    RETLW 0x8E	    ;note E3, RB5
    RETLW 0x7E	    ;note D3, RB6
    RETLW 0x77	    ;note C3, RB7
 
 End

