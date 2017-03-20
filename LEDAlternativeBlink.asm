************************************
* Title: LED Alternative Blinking
*
*
* Programmer: Yiyue Zou
*
* Company: The Pennsylvania State University
* Electrical Engineering and Computer Science
*
* Algorithm: Parallel I/O in a nested delay-loop,subroutinee,looping,and timing
*
* Register use: A: Light on/off state and Switch SW1 on/off state
*               B: 10 usecond loop counter
*               Y: Delay loop counter
*              
*
* Memory use: RAM Locations from $3000 for data
*                           from $3100 for program
*
* Input: Parameters hard coded in the program,
*        Switch SW1 at PORTB bit 4,5,6,7
*
* Output: LED 1,2,3,4 at PORTB bit 4,5,6,7
*
* Observation: The LED 1 is dim with light level 7%, 
*               and it get brighter when pressed the switch1. 
*             
* 
* Comments: This program is developed and simulated using CodeWarrior 
*           development sofware and targeted for 
*           Axion Manufacturing's APS12C128 board(CSM-12C128board running
*           at 24MHz bus clock
*               
*
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

Push_on     DC.W      17              ; inital Y register count number, 45
Push_off    DC.W      83
NotPush_on  DC.W      7
NotPush_off DC.W      93

StackSpace                            ; remaining memory space for stack data
                                      ; initial stack pointer position set to $3100(pgstart)
*
**********************************************************************************************
*
            ORG       $3100           ; Program start address in RAM
pgstart     LDS       #pgstart        ; initialize the stack pointer

            
            LDAA      #%11110000      ; set PORTB bit 7,6,5,4 as output, 3,2,1,0 as input
            STAA      DDRB            ; LED 1,2,3,4 on PORTB bit 4,5,6,7
            
            BSET      PUCR,%00000010  ; enable PORTB pull up/down feature for the
                                      ; DIP switch 1,2,3,4 on the bits 0,1,2,3      
            BCLR      DDRP,%00000011  ; enable the pull up/down feature at PORTP bit 0 and 1
                                      ; set PORTP bit 0 and 1 as input
            
            BSET      PERP,%00000011  ; enable the pull up/down feature at PORTP bit 0 and 1
            BCLR      PPSP,%00000011  ; select pull up feature at PORTP bit 0 and 1 for the
                                      ; Push Button Switch 1 and 2.
                                    
            LDAA      #%10110000      ; Turn off LED 1,2,4 at PORTB bit 4,5,7('1':off),turn on LED3
            STAA      PORTB           ; Note: LED numbers and PORTB bit numbers are different

mainLoop    
            LDAA      PTIP            ; read push button SW1 at PORTB4, if pressed,ptip = 00000001
            ANDA      #%00000001      ; check the bit 0 only
            BEQ       sw1pushed       ; if equal 0, then jump to sw1pushed

sw1notpsh                             ; 7% light level
                    
            BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4
            LDY       NotPush_on      ; set counter2=7       
            JSR       delay_Loop      ; go to delay_Loop subroutine
                        
           
            BSET      PORTB,%00010000 ; Turn off LED 1 at PORTB4
            LDY       NotPush_off     ; set counter2=93
            
            JSR       delay_Loop                        
            BRA       mainLoop
            
           
                     
sw1pushed                             ; 17% light level
            BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4
            LDY       Push_on         ; set counter2=7       
            JSR       delay_Loop      ; go to delay_Loop subroutine
                        
           
            BSET      PORTB,%00010000 ; Turn off LED 1 at PORTB4
            LDY       Push_off        ; set counter2=93
            
            JSR       delay_Loop      ; go to delay_Loop subroutine           
            BRA       mainLoop        ; go back to mainLoop

            
*************************************************************************
* Subroutine Section

;****************************
; delay_on subroutine
; This subroutine repeat the 10 usec delay for several times
; Output: time deley
; Register in use: Y register, as counter

        
                       
delay_Loop  JSR       delay10us        ; Y*delay10us
            DEY                        ; value in Y decreased by one
            BNE       delay_Loop
            
            RTS
            
;*****************************
; delay1ms subroutine                                  
;
; This subroutine cause 10 usec delay
; Output: time delay, cpu cycle wasted
; Registers in use: B accumulater, as counter
; 

delay10us
                       
            LDAB      #59      ; short delay
                      
delay10us_Loop   
            
            SUBB      #$01     ; value in B decreased by one
            BNE       delay10us_Loop            
         
            RTS
            
            end
           
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                                          