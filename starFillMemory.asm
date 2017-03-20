************************************
* Title: StarFill (in Memory Lane)
*
* Programmer: Yiyue Zou
*
* Company: The Pennsylvania State University
* Electrical Engineering and Computer Science
*
* Algorithm: Simple while-loop demo of HCS12 assembly program
*
* Register use: A accumulator: character data to be filled
*               B accumulator: counter, number of filled locations
*               X register:    memory address pointer
*
* Memory use: RAM Locations from $3000 to $300D
*
* Input: Parameters hard coded in the program
*
* Output: Data filled in memory locations,
* from $3000 to $300D changed
* 
* Comments: This program is developed and simulated using CodeWarrior 
* development sofware.                
*
************************************
*
* Parameter Declearation Section
*
* Export Symbols
            XDEF      pgstart   ;export 'pgstart' symbol
            ABSENTRY  pgstart   ;for assembly entry point
* Symbols and Macros
PORTA   EQU   $0000   ;i/o port addresses
PORTB   EQU   $0001   
DDRA    EQU   $0002
DDRB    EQU   $0003
*
************************************
* Data Section
*
        ORG   $3000   ;reserved memory starting address
here    DS.B  $0E     ;10 memory locations reserved
count   DC.B  $0E     ;constant, star count = 10
*
*************************************
*Program Section
*

        ORG   $3100
pgstart ldaa  #'k'    ;Program start address, in RAM
        ldab  count   ;load star counter into B
        ldx   #here   ;load address pointer into X
loop    staa  0,x     ;put a start
        inx           ;point to next location
        decb          ;decrease counter
        bne   loop    ;if not done, repeat
done    bra   done    ;do nothing

*
* Add any subrountines here
*

        END           ;last line of a file
            
   
