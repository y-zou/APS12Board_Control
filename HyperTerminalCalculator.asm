************************************
* Title: An elementary calculator
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
*	      two numbers and one operater
*  
*
* Output:     terminal shows the result 
*
*             
* 
* Comments: This program is developed and simulated using CodeWarrior 
*           development sofware and targeted for 
*           Axion Manufacturing's APS12C128 board(CSM-12C128board running
*           at 24MHz bus clock
*               
*     
************************************ 


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
                         DS.B      7                ; Buffer for the input command
output_buffer            DS.B      8                ; Buffer for the output ASCII char
output_end               DC.B      32             ; this is a space sign to indicates the end of output

pos_output               DC.W       $300E          ;this is the address for output

count                    DC.B       0                 ; Count the input data length
                                     
operater                 DC.B       0                 ; store the valid operator

Negtive                  DC.B       0                 ; negtive = 1 if the result has a minus sign

Sum                      DC.W       0                 ; used for ASCII char to numerical number conversion                
   
num_1                    DS.W       1                 ; the first input number
num_2                    DS.W       1                 ; the second input number
num_temp                 DS.W       1

result                   DS.W       1                 ; the numerical result
result_hi                DC.W       $0                ; the result part that exceed #$FFFF
output                   DS.W       1                 

temp                     DS.B       1
units                    DS.W       1                 ; used for the InputConvert subroutine

StackSP                                ; Stack space reserved from here to
                                       ; StackST

              ORG  $3100
              

*********************  code section below   *********************

* Command buffer initialize

Entry
              LDS        #Entry             ; initialize the stack pointer
              
              LDX        #msg1         ; print the welcome message
              JSR        printmsg
              ldaa       #CR           ; change line
              JSR        putchar
              LDAA       #LF
              JSR        putchar
              LDX        #msg_ecal     ; print ">ecal"
              JSR        printmsg
              LDX        #$3000        ; initialize the "buffer pointer" at $3000
              
             
mainLoop                  
              JSR         getchar              ; get one character from SCI port
             
              CMPA        #NULL                ; check if character=NULL
              BEQ         mainLoop
             
              STAA        1,X+                 ; put the character into buffer, and 
                                              ; move "the buffer pointer" one byte
             
              LDAB        count                ; count the input
              INCB
              CMPB        #5                   ; if the input count reaches 5, then error length.
              LBEQ         errorLen
              STAB        count                ; if not, update the count
             
             
              JSR         putchar              ; send this character to SCI port, terminal
              
              ; if input is + - * / , go to InputOperater subroutine
              CMPA        #42
              LBEQ         InputOperater
              CMPA        #43
              LBEQ         InputOperater
              CMPA        #45
              LBEQ         InputOperater
              CMPA        #47
              LBEQ         InputOperater 
             
              CMPA        #CR                 ; check if char = CR, if true, go to inputEnd
              BEQ         inputEnd
              
              CMPA       #48                  ; if the input digit is less than 0, false
              LBLO       invalidInput_1
             
              CMPA       #57                  ; if the input digit is more than 9, false
              LBHI        invalidInput_1
              BRA         mainLoop             ; if true, then the input string is at its end
;___________________________________________________________________________________________
             
inputEnd             
             LDAA           #LF                  ; move the cursor to the next line
             JSR            putchar
             
             LDAA           count               ; if only type in CR without any other input: invalid
             CMPA           #1
             LBEQ            invalidInput

             LDAA           #0
             LDX            #$3000
             JSR            InputConvert        ;convert num_1 fron ASCII to number
             STD            num_1
             
             LDD            #0
             STD            Sum
             ;Now X exactly points at the highest bit of num_2
             
             JSR            InputConvert
             STD            num_2                ;convert num_2 from ASCII to number
             
             LDAA       operater
             CMPA       #42
             LBEQ        Multi
             CMPA       #43
             LBEQ        Add
             CMPA       #45
             LBEQ         Minus
             CMPA       #47  
             LBEQ        Divide
                                      
                                                    
             
InputConvert             
             LDAB           1,X+
             
             CMPB           #CR      ;num_2 is followed by #CR
             BEQ            IC_end
             
             CMPB           operater  ;num_1 is followed by an operater
             BEQ            IC_end
             
             SUBB           #48        ; 0 is #48 in ASCII
             
             STD           units       ; copy the units to memory
             
             LDD            Sum        ; the Sum of previous input
             
             LDY            #10         
             
             EMUL                      ; Sum times 10
             
             ADDD           units      ; add the new nits to Sum
             STD            Sum
             
             BRA            InputConvert
IC_end             
             LDD            Sum             
             RTS          
;_______________         
InputOperater
            
            LDAB        count
            CMPB        #1                  ;if the first input is an operator: invalid
            LBEQ        invalidInput_1
            
            LDAB        #0                  ;reset the count to zero for num_2
            STAB        count
            
            STAA        operater            ; store the operater
            
            
            LBRA        mainLoop

;_________________________________________________________________________________________             
             
cleanBuffer 
             ;reset parameters for the next calculation            
             LDAB       #0
             STAB       count                ; set Buffer Length counter to 0
             STAB       Negtive
             STAB       operater
             LDD        #0
             STD        Sum
             STD        result

             ldaa       #CR
             JSR        putchar
             LDAA       #LF
             JSR        putchar
             LDX        #msg_ecal            ; print ">ecal"
             JSR        printmsg
             LDX        #$3000               ; initialize the buffer pointer
             LBRA        mainLoop
;___________________________________________________________
             
outputConvert
;  convert numerical result to ASCII output
             LDY        pos_output
             LDD        result
             CPD        #0
             BNE        OC_Loop
             ADDD       #48
             STAB       1,Y-
             JSR        print
             
                          
OC_Loop             
             LDD          result 
             CPD          #0 
             BEQ          print
             
             LDX          #10
             IDIV                             ;D/X=>X, remainder=>D
             
             ADDD         #48
             
             STAB         1,Y-
             STX          result 
             
             BRA          OC_Loop
print
             LDAA         Negtive           
             BEQ          J2                 ; if Negtive=0, then no need to print "-" sign
             LDAA         #45                ; print out -" sign for the result
             JSR          putchar
J2                                           ; J2 is used to print out the ASCII result            
             LDAA         1,+Y
             JSR          putchar
             CMPA         #32
             BNE          J2
                                                    
             LBRA         cleanBuffer
             
;______________________________________
                        
Add
             LDD        num_1
             ADDD       num_2
             STD        result
             
             LBRA            outputConvert
;______________________________________
Multi
              LDD       num_1
              LDY       num_2
                                       
              EMUL                  ;D*Y=>Y:D
              STD       result
              STY       result_hi
              LDD       result_hi      ; if the result is greater than $FFFF
              
              BNE       largeResult    ; then go to largeResult
              LBRA      outputConvert
              
;_____________________________________
Minus
              LDD       num_1
              CPD       num_2
              LBHI      J1
               
              LDD       num_2
              SUBD      num_1
              
              STD       result
              LDAA      #1
              STAA      Negtive
              
              LBRA      outputConvert
J1              
              SUBD      num_2
              STD       result
              LBRA      outputConvert              
;______________________________________
Divide
             LDD        num_1
             LDX        num_2
             CPX        #0             ;divisor cannot be zero
             BEQ        invalidInput
             IDIV                     ;D/X=>X
             STX        result
             LBRA        outputConvert   
             
;_______________________________________
largeResult
              LDX     #msgLarge
              JSR     printmsg
              
              LBRA    cleanBuffer
                                    
             
**********************************************************************************
* subroutines

; errorLen: print out msg_errorLen to the serial port
errorLen
             ldaa       #CR
             JSR        putchar
             LDAA       #LF
             JSR        putchar
             LDX        #msg_errorLen  ; input data length too long
             JSR        printmsg
             LBRA        cleanBuffer
************************************************************************************
invalidInput_1
            ldaa       #CR
            JSR        putchar
            LDAA       #LF
            JSR        putchar
            LBRA        invalidInput 
invalidInput
             LDX         #msg_invalid  ;invalid input command
             JSR         printmsg 
             LBRA         cleanBuffer            


***********     printmsg   ***************************


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
               

 ************************************************
;more variable/data section below
; this is after the program code section
; of the RAM.  RAM ends at $3FFF
; in MC9S12C128 chip


msg1        DC.B     'Welcome',$00

msg_invalid     DC.B    '-->invalid input!',$00
msg_errorLen    DC.B    '-->error! Input too long', $00
msgLarge        DC.B    '-->Overflow error. the result is larger than 16bits',$00
msg_ecal        DC.B    'ecal>',$00

               END               
