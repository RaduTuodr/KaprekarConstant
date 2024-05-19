INCLUDE maclib.asm

CODE SEGMENT PARA PUBLIC 'CODE'

    PUBLIC READ_DEC_NUMBER
    PUBLIC PRINT_DEC_NUMBER

    ASSUME CS:CODE
    
    READ_DEC_NUMBER PROC NEAR
        ; Write a procedure that reads a decimal number
        ; Use the READCHAR macro

        MOV CX, 1
        MOV AX, 0

        WHILE1:

            READCHAR DL

            CMP DL, 'S'
            JE TERMINATOR1

            CMP DL, '0'
            JB BELOW_BOUND1

            CMP DL, '9'
            JA ABOVE_BOUND1

            MOV BL, 10D
            MUL BL
            SUB DL, '0'
            ADD AL, DL

            INC CX

            BELOW_BOUND1:
            ABOVE_BOUND1:
            TERMINATOR1:

        LOOP WHILE1

        RET

    READ_DEC_NUMBER ENDP

    PRINT_DEC_NUMBER PROC near
        ; Write a procedure that prints a decimal number
        ; Use the PRINTCHAR macro

        CONVERT_LOOP:
            MOV DX, 0        
            MOV BX, 10D        
            DIV BX           
            ADD DL, '0'      
            PUSH DX            
            INC CX           
            CMP AX, 0         
            JNZ CONVERT_LOOP   
                
        PRINT_LOOP:
            POP DX          
            MOV AH, 02H    
            INT 21H      
            LOOP PRINT_LOOP  

        RET

    PRINT_DEC_NUMBER ENDP