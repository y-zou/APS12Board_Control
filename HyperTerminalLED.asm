************************************
* Title: HyperTerminalLED
*
*
* Programmer: Yiyue Zou
*
* Company: The Pennsylvania State University
* Electrical Engineering and Computer Science
*
* Algorithm: serial port, subroutine, looping, and user interaction.
*             arithmetic instructions, 
*             Parallel I/O in a nested delay-loop,subroutinee,looping,and timing
*
* Register use: A: load charactor for subroutine getchar and putchar 
*               B: Command Length Counter
*               X  Buffer Location Pointer, delay30ms loop counter
*               Y: delay10us loop counter
*              
*
* Memory use: RAM Locations from $3000 for data
*                           from $3100 for program
*
* Input:      SCI port (terminal/keyboard)
*             Parameters hard coded in the program
*  
*
* Output:     SCI port (terminal)
*             LED 1,2,3,4 at PORTB bit 4,5,6,7
*
* Observation: when a user enters a number between 0 and 100,
*              the LED 3 light dim to that level
*             
* 
* Comments: This program is developed and simulated using CodeWarrior 
*           development sofware and targeted for 
*           Axion Manufacturing's APS12C128 board(CSM-12C128board running
*           at 24MHz bus clock
*               
*     
************************************ 

; REGISTER A: getchar, putchar


******

;export symbols
              XDEF      Entry          ; export 'Entry' symbol
              ABSENTRY  Entry          ; for assembly entry point

;include derivative specific macros
PORTB         EQU     $0001
DDRB          EQU     $0003
;add more for the ones you need

SCISR1        EQU     $00cc            ; Serial port (SCI) Status Register 1
SCIDRL        EQU     $00cf            ; Serial port (SCI) Data Register

;following is for the TestTerm debugger simulation only
;SCISR1        EQU     $0203            ; Serial port (SCI) Status Register 1
;SCIDRL        EQU     $0204            ; Serial port (SCI) Data Register

CR            equ     $0d              ; carriage return, ASCII 'Return' key
LF            equ     $0a              ; line feed, ASCII 'next line' character
NULL          equ     $00


*************  variable/data section below  ****************

              ORG     $3000            ; RAMStart defined as $3000
                                       ; in MC9S12C128 chip ($3000 - $3FFF)
                                       
              DS.B     6               ; Buffer for the input command
              
count         DC.B     0               ; Count the input data length

LEVEL         DC.B     100             ; Light level percentage
ONN           DS.B     1               ; The time for LED1 light keeps on within 1ms
OFF           DS.B     1               ; The time for LED1 light keeps off within 1ms
Count30ms     DC.W     30              ; counter for Counter30ms loop
         
              
              

; Each message ends with $00 (NULL ASCII character) for your program.
;
; There are 256 bytes from $3000 to $3100.  If you need more bytes for
; your messages, you can put more messages 'msg3' and 'msg4' at the end of 
; the program.
                                  
StackSP                                ; Stack space reserved from here to
                                       ; StackST

              ORG  $3100
              

*********************  code section below   *********************

* Command buffer initialize

Entry
              LDS        #Entry             ; initialize the stack pointer

              LDAA       #%11110000    ; add PORTB initialization code here
                                       ; set PORTB bit 7,6,5,4 as output, 3,2,1,0 as input
              STAA       DDRB          ; LED 1,2,3,4 on PORTB bit 4,5,6,7
                                       ; DIP switch 1,2,3,4 on PORTB bit 0,1,2,3.
              LDAA       #%11110000    ; Turn off LED 1,2,4 at PORTB bit 4,5,7. Turn on LED 3
              STAA       PORTB         ; Note: LED numbers and PORTB bit numbers are different
              
              LDX        #msg1         ; print the welcome message
              JSR        printmsg

   
              LDX        #$3000        ; initialize the "buffer pointer" at $3000
              
            

mainLoop           
             JSR        delay30ms           
             JSR        getchar              ; get one character from SCI port
             
             CMPA       #NULL                ; check if character=NULL
             BEQ        mainLoop
             
             STAA       1,X+                 ; put the character into buffer, and 
                                             ; move "the buffer pointer" one byte
             LDAB       count                
             INCB                            ; 
             CMPB       #5                   ; check if there're 6 characters get from SCI
             BEQ        errorLen             ; if true, then the input commend length is wrong
             STAB       count                ; if false, count++
             
             JSR        putchar              ; send this character to SCI port, terminal
             
                                      
             CMPA       #CR                  ; check if char = CR      
             BEQ        inputEnd             ; if true, then the input string is at its end
             
             CMPA       #48                  ; if the input digit is less than 0, false
             LBLO       invalidInput_1
             
             CMPA       #57                  ; if the input digit is more than 9, false
             LBHI        invalidInput_1
                                             
             BRA        mainLoop             ; if char != CR and is valid, go to fetch the next char
inputEnd             
             LDAA       #LF                  ; move the cursor to the next line
             JSR        putchar
             
             ;check the buffer               ; number started with 0 is not allowed
             
                         
             LDAA       count
             CMPA       #4
             BEQ        threeDigit      ; three digit input 
             CMPA       #3
             BEQ        twoDigit        ; two digit input
             CMPA       #2
             BEQ        oneDigit        ; one digit input
             
             LBRA       invalidInput
             

cleanBuffer             
             LDAB       #0
             STAB       count                ; set Buffer Length counter to 0
             LDX        #$3000               ; initialize the buffer pointer
             BRA        mainLoop


             
**********************************************************************************
* subroutines


threeDigit
; for three digits input, the only valid input is 100, just check if the input is 100
             LDAA       $3000
             
             CMPA       #49                
             BNE        invalidInput
             LDAA       $3001
             CMPA       #48
             BNE        invalidInput
             LDAA       $3002
             CMPA       #48
             BNE        invalidInput
             LDAA       #100
             STAA       LEVEL
             BRA        cleanBuffer
 
twoDigit
; for two digits input, the tens is in address $3000, the units is in address $3001

            LDAA       $3000
            SUBA       #48
            BEQ        invalidInput     ; two digit input starts with 0 is invalid 
            
            LDAB       #10               
            MUL                          ; after mulplication, register B contains the tens value
            
            LDAA       $3001             
            SUBA       #48               ; register A contains the units value
            ABA                          ; add A B together into A
            STAA       LEVEL
            BRA        cleanBuffer
            
oneDigit
; for one digit input, the units is in address $3000
            LDAA      $3000
            SUBA      #48
            STAA      LEVEL
            BRA       cleanBuffer
            
             
          
            


***********************************************************************************
;* errorLen: print out msg_errorLen to the serial port
errorLen
             ldaa       #CR
             JSR        putchar
             LDAA       #LF
             JSR        putchar
             LDX        #msg_errorLen  ; input data length too long
             JSR        printmsg
             BRA        cleanBuffer
************************************************************************************
invalidInput_1
            ldaa       #CR
            JSR        putchar
            LDAA       #LF
            JSR        putchar
            BRA        invalidInput



;* errorLen: print out msg_invalid to the serial port

invalidInput
             LDX         #msg_invalid  ;invalid input command
             JSR         printmsg 
             LBRA         cleanBuffer            


*******************************************



***********     printmsg   ***************************
;* Program: Output character string to SCI port, print message
;* Input:   Register X points to ASCII characters in memory
;* Output:  message printed on the terminal connected to SCI port
;* 
;* Registers modified: CCR
;* Algorithm:
;     Pick up 1 byte from memory where X register is pointing
;     Send it out to SCI port
;     Update X register to point to the next byte
;     Repeat until the byte data $00 is encountered
;       (String is terminated with NULL=$00)
;**********************************************

printmsg       psha                   ;Save registers
               pshx
               
               
printmsgloop   
              ldaa    1,X+           ;pick up an ASCII character from string
                                       ;   pointed by X register
                                       ;then update the X register to point to
                                       ;   the next byte
               cmpa    #NULL
               beq     printmsgdone   ;end of string yet?
               cmpa    #CR
               beq     printmsgdone
               jsr     putchar        ;if not, print character and do next
               bra     printmsgloop

printmsgdone  
               ldaa       #CR
               JSR        putchar
               LDAA       #LF
               JSR        putchar
               pulx 
               pula
               
               rts


***************  putchar subroutine  ************************
;* Program: Send one character to SCI port, terminal
;* Input:   Accumulator A contains an ASCII character, 8bit
;* Output:  Send one character to SCI port, terminal
;* Registers modified: CCR
;* Algorithm:
;    Wait for transmit buffer become empty
;      Transmit buffer empty is indicated by TDRE bit
;      TDRE = 1 : empty - Transmit Data Register Empty, ready to transmit
;      TDRE = 0 : not empty, transmission in progress
;**********************************************

putchar        brclr SCISR1,#%10000000,putchar   ; wait for transmit buffer empty
               staa  SCIDRL                      ; send a character
               rts



****************   getchar    ***********************
;* Program: Input one character from SCI port (terminal/keyboard)
;*             if a character is received, other wise return NULL
;* Input:   none    
;* Output:  Accumulator A containing the received ASCII character
;*          if a character is received.
;*          Otherwise Accumulator A will contain a NULL character, $00.
;* Registers modified: CCR
;* Algorithm:
;    Check for receive buffer become full
;      Receive buffer full is indicated by RDRF bit
;      RDRF = 1 : full - Receive Data Register Full, 1 byte received
;      RDRF = 0 : not full, 0 byte received
;**********************************************

getchar        brclr SCISR1,#%00100000,getchar7
               ldaa  SCIDRL
               rts
getchar7       clra
               rts
               
         
                 

;**************************
; delay30ms subroutine
; This subroutine repeat the delay1ms loop for 30 times
; Output: time deley, 30*1ms = 30ms
; Register in use: X register, as counter

delay30ms  
          PSHX  

          LDX         Count30ms       ; Let Count be the value inside X. Count = 30
          
delay30ms_Loop                        
          BEQ         back            ; if Count = 0, end this subroutine
                    
          JSR         delay1ms        ; goto delay1ms subroutine
               
          DEX                         ; Count = Count - 1
         
          BRA         delay30ms_Loop  ; go back to delay30ms_Loop
         
back      PULX
          RTS
            

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
            
            
                        
            
            BCLR      PORTB,%01000000 ; Turn on LED 1 at PORTB4  
turnon_Loop
            LDAB      ONN             
            BEQ       turnoff         ; if ONN=0, jump to turnoff
            
            JSR       delay10us       ; goto delay10us subroutine
            
            DECB
            STAB      ONN             ; ONN = ONN - 1
            BRA       turnon_Loop     ; go back to turnon_Loop
          
          
turnoff     
            BSET       PORTB,%01000000 ; Turn on LED 1 at PORTB4 
    
            
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
            



 
 
;************************************************
 ************************************************
;more variable/data section below
; this is after the program code section
; of the RAM.  RAM ends at $3FFF
; in MC9S12C128 chip


msg1        DC.B     'Welcome',$00



msg_invalid     DC.B    '-->invalid input!',$00
msg_errorLen    DC.B    '-->error! Input too long', $00


               END               
