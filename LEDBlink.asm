************************************
* Title: LED Blinking
*
* Programmer: Yiyue Zou
*
* Company: The Pennsylvania State University
* Electrical Engineering and Computer Science
*
* Algorithm: Simple Parallel I/O in a nested delay-loop, demo
*
* Register use: A: Light on/off state and Switch SW1 on/off state
*               X,Y: Delay loop counters
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
* Observation: This is a program that blinks LEDs and blinking period 
*              be changed with the delay loop counter value.
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
                                      ; Memory $3000 to $30FF are for Data
Counter1    DC.W      $4fff           ; inital X register count number, 20479
Counter2    DC.W      $0020           ; inital Y register count number, 45

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
                                    
            LDAA      #%11110000      ; Turn off LED 1,2,3,4 at PORTB bit 4,5,6,7('1' is off)
            STAA      PORTB           ; Note: LED numbers and PORTB bit numbers are different

mainLoop           
            BCLR      PORTB,%00010000 ; Turn on LED 1 at PORTB4
            JSR       delay1sec       ; Wait for 1 second
            
            BCLR      PORTB,%10000000 ; Turn on LED 4 at PORTB7
            BSET      PORTB,%00010000 ; Turn off LED 1 at PORTB4
            JSR       delay1sec       ; Wait for 1 second
            BSET      PORTB,%10000000 ; Turn off LED 4 at PORTB7
                                      ; Currently all LED are off 
            
            LDAA      PTIP            ; read push button SW1 at PORTB4
            ANDA      #%00000001      ; check the bit 0 only
            BNE       sw1pushed   
                     
sw1notpsh              
            BRA       mainLoop        ; loop forever!

            
*************************************************************************
* Subroutine Section
*
;*************************
; sw1pushed subroutine
; after pushed sw1 
sw1pushed                  
            BCLR      PORTB,%01000000 ; Turn on LED 3 on PORT 6
            JSR       delay1sec
            BSET      PORTB,%01000000 ; Turn off LED 3
            
            BCLR      PORTB,%00100000 ; Turn on LED 2           
            JSR       delay1sec 
            BSET      PORTB,%00100000 ; Turn off LED2             
            BRA       mainLoop        ; loop forever!
            
;****************************
; delay1sec subroutine
;
; Please be sure to include your comments here!
;

delay1sec
            PSHY
            LDY       Counter2         ; long delay 
            
dly1sLoop   JSR       delay1ms         ; X*Y*delay1ms
            DEY
            BNE       dly1sLoop
            
            PULY
            RTS
            
;*****************************
; delay1ms subroutine
;
; This subroutine cause a few msec delay
;
; Input: a 16bit count number in 'Counter1'
; Output: time delay, cpu cycle waisted
; Registers in use: X register, as counter
; Memory location in use: a 16bit input number in 'Counter1'
;
; Comments: one can add more NOP instructions to lengthen the deley time

delay1ms
            PSHX            
            LDX     Counter1      ; short dely
                      
dlymsLoop   NOP

            DEX
            BNE     dlymsLoop
            
            PULX
            RTS
            
            end
           
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                                          