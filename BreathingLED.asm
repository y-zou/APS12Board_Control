************************************
* Title: BreathingLED
*
* Programmer: Yiyue Zou
*
* Company: The Pennsylvania State University
* Electrical Engineering and Computer Science
*
* Algorithm: Parallel I/O in a nested delay-loop,subroutinee,looping,and timing
*
* Register use: A: light level counter
*               B: multiple usages
*               X  delay30ms loop counter
*               Y: delay10us loop counter
*              
*
* Memory use: RAM Locations from $3000 for data
*                           from $3100 for program
*
* Input: Parameters hard coded in the program
*  
*
* Output: LED 1,3 at PORTB bit 4,6
*
* Observation:  For every 6 seconds, LED 1 goes from 0% light level to 100% in 3 seconds,
*               then goes from 100% to 0% in the rest 3 seconds
*             
* 
* Comments: This program is developed and simulated using CodeWarrior 
*           development sofware and targeted for 
*           Axion Manufacturing's APS12C128 board(CSM-12C128board running
*           at 24MHz bus clock
*               
*     LIGHT LEVEL CHANGE 1% PER 30MS
************************************ 
 
 
                   * Parameter Delearation Section
*
* Export Symbols
            XDEF      pgstart         ; export 'pgstart' symbol
            ABSENTRY  pgstart         ; for assembly entry point
*                                
*

* Symbols and Macros
PORTA       EQU       $0000           ; i/o port addresses(port A not used)
DDRA        EQU       $0002           ; 

PORTB       EQU       $0001           ; PORT B is connected with LEDs
DDRB        EQU       $0003         
PUCR        EQU       $000C           ; to enable pull-up for PORT A,B,E,K

PTP         EQU       $0258           ; PORTP data register, used for Push Switch
PTIP        EQU       $0259           ; PORTP input register <<=======
DDRP        EQU       $025A           ; PORTP data direction register
PERP        EQU       $025C           ; PORTP pull up/down enable
PPSP        EQU       $025D           ; PORTP pull up/down selection

*********************************
* Data Section
            ORG       $3000           ; reserved RAM memory starting address
                                      ; Memory $3000 to $30FF are for Data, 
Count30ms   DC.W      30              ; Counter for Counter30ms loop

LEVEL       DC.B      0               ; Light level percentage
ONN         DS.B      1               ; The time for LED1 light keeps on within 1ms
OFF         DS.B      1               ; The time for LED1 light keeps off within 1ms


StackSpace                            ; remaining memory space for stack data
                                      ; initial stack pointer position set to $3100(pgstart)
*
**********************************************************************************************
*
            ORG       $3100           ; Program start address in RAM
pgstart     LDS       #pgstart        ; initialize the stack pointer

            
            LDAA      #%11110000      ; set PORTB bit 7,6,5,4 as output, 3,2,1,0 as input
            STAA      DDRB            ; LED 1,2,3,4 on PORTB bit 4,5,6,7
                                        
                                    
            LDAA      #%10110000      ; Turn off LED 1,2,4 at PORTB bit 4,5,7('1':off),turn on LED3
            STAA      PORTB           ; Note: LED numbers and PORTB bit numbers are different



DIMUP
           LDAA       #0
           STAA       LEVEL           ; LEVEL = 0
DIMUP_Loop           
           LDAB       #101
           SUBB       LEVEL           ; the value inside B is "101 - LEVEL"
           BEQ        DIMDOWN         ; If LEVEL=101, then jump to DIMDOWN
           JSR        delay30ms       ; goto delay30ms subroutine

           INCA       
           STAA       LEVEL           ; LEVEL = LEVEL + 1
           BRA        DIMUP_Loop      ; go back to DIMUP_Loop

           
DIMDOWN    LDAA       #100
           STAA       LEVEL           ; LEVEL = 100
DIMDOWN_Loop
           BEQ        DIMUP           ; if LEVEL=0, then jump to DIMUP
           
           JSR        delay30ms       ; goto delay30ms subroutine
           DECA     
           STAA       LEVEL           ; LEVEL = LEVEL - 1
          
           BRA        DIMDOWN_Loop    ; go back to DIMDOWN_Loop
          
          
          
          

          
******************************
* Subroutine Section

;****************************
; delay30ms subroutine
; This subroutine repeat the delay1ms loop for 30 times
; Output: time deley, 30*1ms = 30ms
; Register in use: X register, as counter

delay30ms    

          LDX         Count30ms       ; Let Count be the value inside X. Count = 30
delay30ms_Loop                        
          BEQ         back            ; if Count = 0, end this subroutine
          
          
          JSR         delay1ms        ; goto delay1ms subroutine
               
          DEX                         ; Count = Count - 1
         
          BRA         delay30ms_Loop  ; go back to delay30ms_Loop
         
back      RTS
          
            
          
          
******************************
;*****************************
; delay1ms subroutine                                  
;
; This subroutine cause 1ms delay in total
; Output: Within 1ms, LED 1 is on for ONN% of the total time, 
;         and is off for OFF%.
; Registers in use: B accumulator, taking track of the decrease of ON and OFF
;          

delay1ms                              ; initialize ON and OFF
            LDAB       LEVEL
            STAB       ONN            ; ONN = LEVEL
            LDAB       #100
            SUBB       LEVEL
            STAB       OFF            ; OFF = 100-LEVEL
            
            
                        
            
            BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4  
turnon_Loop
            LDAB      ONN             
            BEQ       turnoff         ; if ONN=0, jump to turnoff
            
            JSR       delay10us       ; goto delay10us subroutine
            
            DECB
            STAB      ONN             ; ONN = ONN - 1
            BRA       turnon_Loop     ; go back to turnon_Loop
          
          
turnoff     
            BSET       PORTB,%00010000 ; Turn on LED 1 at PORTB4 
    
            
turnoff_Loop
            LDAB      OFF              
            BEQ       end_delay1ms     ; if OFF=0, then end this delay1ms subroutine
           
            JSR        delay10us       ; goto delay10us subroutine
            DECB
            STAB       OFF             ; OFF = OFF - 1
            BRA        turnoff_Loop    ; go back to turnoff_Loop
                        
end_delay1ms
            RTS        
          
;*****************************
; delay10us subroutine                                  
;
; This subroutine cause 10 usec delay
; Output: time delay, cpu cycle wasted
; Registers in use: Y register, as counter
; 
             
delay10us  
            LDY      #59           
                      
delay10us_Loop   
            DEY                        ; value in Y decreased by one
            
            BNE       delay10us_Loop                      
        
            RTS
            
            end
           
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                                          