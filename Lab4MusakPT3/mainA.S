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
    CLRF 0x07 //sets portc low 
    
    BCF 0x03,6
    BSF 0x03,5 ;set bank 1 active 
    CLRF 0x85
    CLRF 0x87
    BSF 0x86,7//bit 7 input active 
    BSF 0x86,6//bit 6 input active 
    BSF 0x86,5//bit 5 input active 
    BSF 0x86,4//bit 4 input active 
    BCF 0x86,3//bit three is output 
    BCF 0x86,2//bit two is output 
    BCF 0x86,1//bit one is output 
    BCF 0x86,0//bit 0 is output
      //MOVLW 0xF0
      //MOVWF 0x95 //wpub enabled to allow the internal pull up resistors 
    //CLRF 0x95
   BCF 0x81,7
    
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
    ; Check if ButtonValue is 0 (No button pressed)
    MOVF ButtonValue, W
    BTFSC 0x03, 2         ; Check STATUS bit 2 (Z flag)
    GOTO Main 
   call LookupTable
   MOVWF countout
    
   call OuterDelay
   MOVLW 0x01
   XORWF 0x05,1
  
   //BTFSC 0x06, 0 ;testing if there is the button on rb0 being pressed 
   //goto NoButton
   
   goto Main 
   


ButtonTest:
    
    BCF 0x03,6 //sets bank 1
    BSF 0x03,5 ;set bank 1 active
    MOVLW 0xF0      ; 1111 0000 (1=Input, 0=Output)
    MOVWF 0x86      ; Update TRISB
    
    BCF 0x03,6 ;set bank 0 active
    BCF 0x03,5;set bank 0 
    MOVLW 0x00       
    MOVWF 0x06      ; Write directly to PORTB (0x06)
    BTFSS 0x06,4 //tests row , skips next command if false  
    goto TestR4 ;if there is something on row four then it goes to test the columns on row four 
    BTFSS 0x06,5//tests row , skips next command if false 
    goto TestR5 //nothing on R4 sends it to test row five  
    BTFSS 0x06,6//tests row , skips next command if false 
    goto TestR6//test row six, if row six is positive then it goes to test
    BTFSS 0x06,7//tests row , skips next command if false 
    goto TestR7//goes to test row seven if row seven is active 
    goto NoButton
   NoButton:
    BCF 0x05,0 
    CLRF ButtonValue
return


    
    TestR4: //looking at row four to test the columns 
	BSF 0x03,5
	MOVLW 0x0F
	MOVWF 0x86
	BCF 0x03,5
	MOVLW 0x00       
	MOVWF 0x06      ; Write directly to PORTB (0x06)
	goto TestR4C0
    TestR4C0:
	BTFSS 0x06,0
	goto DisplayD
	
    TestR4C1:
	BTFSS 0x06,1
	goto DisplayPound
	
    TestR4C2:
	BTFSS 0x06,2
	goto Display0
	
    TestR4C3:
	BTFSS 0x06,3
	goto DisplayStar
	goto TestR5
	
    	    
 TestR5:
    BSF 0x03,5
    MOVLW 0x0F
    MOVWF 0x86
    
    BCF 0x03,5
    MOVLW 0x00      
    MOVWF 0x06      ; Write directly to PORTB (0x06)
    goto TestR5C0
    TestR5C0:
	BTFSS 0x06,0
	goto DisplayC
	
    TestR5C1:
	BTFSS 0x06,1
	goto Display9 
	
    TestR5C2:
	BTFSS 0x06,2
	goto Display8
	
    TestR5C3: 
	BTFSS 0x06,3 
	goto Display7
	goto TestR6
	      
TestR6:
    BSF 0x03,5
    MOVLW 0x0F
    MOVWF 0x86
    
    BCF 0x03,5
    MOVLW 0x00       
    MOVWF 0x06      ; Write directly to PORTB (0x06)
    goto TestR6C0 
    TestR6C0:
	BTFSS 0x06,0
	goto DisplayB
	
    TestR6C1:
	BTFSS 0x06,1
	goto Display6
	 
    TestR6C2:
	BTFSS 0x06,2
	goto Display5
	
    TestR6C3: 
	BTFSS 0x06,3
	goto Display4
	goto TestR7
	
TestR7:
    BSF 0x03,5
    MOVLW 0x0F
    MOVWF 0x86
    
    BCF 0x03,5
    MOVLW 0x00      
    MOVWF 0x06      ; Write directly to PORTB (0x06)
    goto TestR7C0
    TestR7C0:
	    BTFSS 0x06,0
	    goto DisplayA
	   
    TestR7C1:
	    BTFSS 0x06,1
	    goto Display3
	
    TestR7C2:
	    BTFSS 0x06,2
	    goto Display2

    TestR7C3: 
	    BTFSS 0x06,3
	    goto Display1
	    goto ButtonTest
	   
	    
	     
    
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
    RETLW 0x00
    RETLW 0xEE	    ;note C3, RB0
    RETLW 0xD4	    ;note B3, RB1
    RETLW 0xBD	    ;note A3, RB2
    RETLW 0xB2	    ;note G3, RB3 
    RETLW 0x9F	    ;note F3, RB4 
    RETLW 0x8E	    ;note E3, RB5
    RETLW 0x7E	    ;note D3, RB6
    RETLW 0x77	    ;note C3, RB7
    RETLW 0x6A	    ;note D4, 
    RETLW 0x5E	    ;note E4
    RETLW 0x59	    ;note F4
    RETLW 0x4F	    ;note G4
    RETLW 0x47	    ;note A4
    RETLW 0x3F	    ;note B4
    RETLW 0x3B	    ;note C5
    RETLW 0x35	    ;note D5
    
    
    
 Display0:
  MOVLW 0x30
  MOVWF 0x07
  MOVLW 0x0F
  MOVWF ButtonValue
  return
 Display1:
  MOVLW 0x31
  MOVWF 0x07
  MOVLW 0x02
  MOVWF ButtonValue
  return
 Display2:
  MOVLW 0x32
  MOVWF 0x07
  MOVLW 0x03
  MOVWF ButtonValue
  return
 Display3:
  MOVLW 0x33
  MOVWF 0x07
  MOVLW 0x04
  MOVWF ButtonValue
 return
 Display4:
  MOVLW 0x34
  MOVWF 0x07
  MOVLW 0x06
  MOVWF ButtonValue
  return
 Display5:
  MOVLW 0x35
  MOVWF 0x07
  MOVLW 0x07
  MOVWF ButtonValue
 return
 Display6:
  MOVLW 0x36
  MOVWF 0x07
  MOVLW 0x08
  MOVWF ButtonValue
  return
 Display7:
  MOVLW 0x37
  MOVWF 0x07
  MOVLW 0x0A
  MOVWF ButtonValue
  return 
 Display8:
  MOVLW 0x38
  MOVWF 0x07
  MOVLW 0x0B
  MOVWF ButtonValue
  return
 Display9:
  MOVLW 0x39
  MOVWF 0x07
  MOVLW 0x0C
  MOVWF ButtonValue
  return
 DisplayA:
  MOVLW 0x41
  MOVWF 0x07
  MOVLW 0x05
  MOVWF ButtonValue
 return
 DisplayB:
  MOVLW 0x42
  MOVWF 0x07
  MOVLW 0x09
  MOVWF ButtonValue
  return
 DisplayC:
  MOVLW 0x43
  MOVWF 0x07
  MOVLW 0x0D
  MOVWF ButtonValue
  return
 DisplayD:
  MOVLW 0x44
  MOVWF 0x07
  MOVLW 0x11
  MOVWF ButtonValue
  return
 DisplayStar:
  MOVLW 0x2A
  MOVWF 0x07
  MOVLW 0x0E
  MOVWF ButtonValue
  return
 DisplayPound:
  MOVLW 0x23
  MOVWF 0x07
  MOVLW 0x10
  MOVWF ButtonValue
  return
 
 End

