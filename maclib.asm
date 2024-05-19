PRINT_MSG MACRO MSG_ADR
    MOV AH, 09h    
    MOV DX, MSG_ADR
    INT 21h        
ENDM

READCHAR MACRO DST
    ; This is a macro that reads a character

    PUSH AX

    MOV AH, 01H
    INT 21H
    MOV DST, AL

    POP AX

ENDM

PRINTCHAR MACRO CHAR
    ; This is a macro that prints a character

    MOV DL, CHAR
    MOV AH, 02H
    INT 21H

ENDM