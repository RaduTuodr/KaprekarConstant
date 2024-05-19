; * Data segment for messages/variables/constants

DATA SEGMENT PARA PUBLIC 'DATA'

    SORTED_DIGITS        DB ?,?,?,?,'$'
    SORTED_DIGITS_LEN    DB $-SORTED_DIGITS-1D
    ADR_SORTED_DIGITS    DW SORTED_DIGITS

    TOOL_NB              DB 4 DUP('0')
    ADR_TOOL_NB          DW TOOL_NB

    NEWLINE              DB 0AH
    ADR_NEWLINE          DW NEWLINE

    BLANKSPACE           DB 20H
    ADR_BLANKSPACE       DW BLANKSPACE

    HIGH_NB              DW 0D
    LOW_NB               DW 0D

    KAPREKAR_CNST        DW 6174D

    ATTR_NORMAL          DW  0000H
    FILE_NAME            DB  'test.txt',0
    ADR_FILE_NAME        DW  FILE_NAME
    READ_WRITE           DB  02H
    BUFFER_TO_WRITE      DB  'WOOOOW'
    ADR_BUFFER           DW  BUFFER_TO_WRITE

    HELLO_MSG            DB 'Hello, this is my Kaprekar-Constant Project$'
    ADR_HELLO_MSG        DW HELLO_MSG

    MODE_MSG             DB 'Choose Interactive[1]/Automatic[2] mode:$'
    ADR_MODE_MSG         DW MODE_MSG

    INVALID_MSG          DB 'Invalid input!$'
    ADR_INVALID_MSG      DW INVALID_MSG

    TRYAGAIN_MSG         DB 'Try again:$' 
    ADR_TRYAGAIN_MSG     DW TRYAGAIN_MSG

    INT_NB_MSG           DB 'Choose starting number:$'
    ADR_INT_NB_MSG       DW INT_NB_MSG

    RESP_MSG             DB 'Iterations: $'
    ADR_RESP_MSG         DW RESP_MSG

    SUB_TEXT             DB ' - $'
    ADR_SUB_TEXT         DW SUB_TEXT

    EQ_TEXT              DB ' = $'
    ADR_EQ_TEXT          DW EQ_TEXT

DATA ENDS

; * MACRO FOR PRINTING MESSAGES ON THE CONSOLE

PRINT_MSG MACRO MSG_ADR

    PUSH AX
    PUSH DX

    MOV AH, 09h    
    MOV DX, MSG_ADR
    INT 21h

    POP DX
    POP AX        
ENDM

; * MACRO FOR PRINTING MESSAGES IN FILE
; MSG_ADR - ADDRESS OF MSG IN DATA SEGMENT
; MSG_LEN - NUMBER OF BYTES THAT WE WANT TO PRINT FOR THE MESSAGE

PRINTF_MSG MACRO MSG_ADR, MSG_LEN

    PUSH AX
    PUSH DX
    PUSH CX
    
    MOV AH, 40H
    MOV CX, MSG_LEN
    MOV DX, MSG_ADR
    INT 21H

    POP CX
    POP DX
    POP AX

ENDM

; * MACRO FOR READING SINGLE CHAR FROM CONSOLE

READCHAR MACRO DST

    PUSH AX

    MOV AH, 01H
    INT 21H
    MOV DST, AL

    POP AX

ENDM

; * MACRO FOR PRINTING SINGLE CHAR ON CONSOLE

PRINTCHAR MACRO CHAR

    MOV DL, CHAR
    MOV AH, 02H
    INT 21H

ENDM

; * MACRO FOR PRINTING SINGLE CHAR IN FILE 
; ? could also be used for printing a new-line character in file

PRINTFCHAR MACRO CHAR

    PUSH AX
    PUSH CX

    XOR AX, AX
    MOV AH, 40H
    MOV CX, 1   ; CX only needs value 1 (we print a single byte(=char))

    MOV DL, CHAR
    MOV DH, 0
    INT 21H

    POP CX
    POP AX

ENDM

; * MACRO FOR QUICK NEW-LINE CHARACTER PRINTED ON CONSOLE

NEW_LINE MACRO

    PUSH AX
    PUSH DX

    MOV AH, 02H
    MOV DL, 0AH
    INT 21H
    MOV DL, 0DH
    INT 21H

    POP DX
    POP AX

ENDM

; * BUBBLE SORT MACRO FOR SORTING AN ARRAY OF 4 ELEMENTS POSITIONED AT A PREDEFINED 
; *                               LOCATION IN THE DATA SEGMENT (adr=0 in this case)

BUBBLE_SORT MACRO
    
    LOOP_OUTER:
        PUSH CX 
        MOV CX, 3D
        SUB CX, SI

        INC SI
        MOV DI, SI
        DEC SI

        LOOP_INNER:

            MOV AX, [BX + SI]
            MOV DX, [BX + DI]
            MOV AH, 0
            MOV DH, 0
            CMP AX, DX

            JBE DONT

                MOV AL, [BX + DI]
                PUSH AX
                MOV AL, [BX + SI]
                            
                MOV [BX + DI], AL
                POP AX
                MOV [BX + SI], AL

            DONT:
                    
            INC DI

            LOOP LOOP_INNER
            
            POP CX
            INC SI

    LOOP LOOP_OUTER

ENDM

CODE SEGMENT PARA PUBLIC 'CODE'

    ASSUME CS:CODE, DS:DATA

    START PROC FAR

        PUSH DS
        XOR AX, AX
        MOV DS, AX
        PUSH AX
        MOV AX, DATA
        MOV DS, AX

        ; Welcomes user to the project
         
        PRINT_MSG ADR_HELLO_MSG
        NEW_LINE

        ; Asks user for mode input

        PRINT_MSG ADR_MODE_MSG
        NEW_LINE

        ; Reads the seleted mode

        CALL READ_DEC_NUMBER

        MOV CX, 1

        ; ! Program goes into a validation process, st. input is only 1 (Interactive) or 2 (Automatic)

        VALID_MODE:

            CMP AX, 1
            JE EXIT_VALID_MODE

            CMP AX, 2
            JE EXIT_VALID_MODE

            INC CX

            PRINT_MSG ADR_INVALID_MSG
            NEW_LINE
            PRINT_MSG ADR_TRYAGAIN_MSG
            NEW_LINE

            CALL READ_DEC_NUMBER

            EXIT_VALID_MODE:

        LOOP VALID_MODE

        ; In case of automatic mode selected, it skips the interactive mode instructions

        CMP AX, 2
        JE AUTOMATIC_MODE

        MOV CX, 1

        ; ! Program goes into a validation process for the interactive-mode's starting number

        VALID_NUMBER:

            PRINT_MSG ADR_INT_NB_MSG
            NEW_LINE

            CALL READ_DEC_NUMBER

            CMP SI, 1
            JE EXIT_VALID_NUMBER

            ; Checks if its between the specified boundaries (number of 4 digits)

            CMP AX, 999D
            JBE EXIT_VALID_NUMBER

            CMP AX, 10000D
            JAE EXIT_VALID_NUMBER

            JMP EXIT_VALID_NUMBER2

            EXIT_VALID_NUMBER:

            INC CX

            PRINT_MSG ADR_INVALID_MSG
            NEW_LINE

            EXIT_VALID_NUMBER2:

        LOOP VALID_NUMBER

        ; Calls out the function an then accesses retrieved information, stored in the SI register
        CALL KAPREKAR_FUN
        MOV AX, SI

        ; Here, the final response is being printed to the screen (no. interactions)

        PRINT_MSG ADR_RESP_MSG        
        CALL PRINT_DEC_NUMBER
        NEW_LINE

        ; * Interactive mode ends here and so does the program

        JMP END_MAIN

        AUTOMATIC_MODE:

        ; Create file
        MOV AH, 3CH
        XOR CX, CX
        OR CX, ATTR_NORMAL
        
        MOV DX, ADR_FILE_NAME
        INT 21H

        ; Open file
        MOV AH, 3DH
        MOV AL, 0
        OR AL, READ_WRITE
        MOV DX, ADR_FILE_NAME
        INT 21H
        MOV BX, AX ; get file handle

        ; Program calls out the function that prints the wanted information in the file created above
        CALL FILE_LOOP

        END_MAIN:

        RET

    START ENDP

CODE ENDS

; * CODE2, CODE SEGMENT DEDICATED TO PROCEDURES CALLED IN THE CODE1 SEGMENT
CODE2 SEGMENT PARA PUBLIC 'CODE'

    PUBLIC READ_DEC_NUMBER
    PUBLIC PRINT_DEC_NUMBER

    ASSUME CS:CODE2

    ;?---------------------------------------------------

    ; * Procedure to read a decimal number from the screen until non-digit character is read
    READ_DEC_NUMBER PROC FAR

        PUSH CX

        MOV CX, 1
        MOV AX, 0
        MOV DX, 0

        WHILE1:

            READCHAR DL

            CMP DL, 'S'
            JE TERMINATOR1

            CMP DL, '0'
            JB BELOW_BOUND1

            CMP DL, '9'
            JA ABOVE_BOUND1

            MOV BX, 10D

            PUSH DX
            MOV DX, 0

            MUL BX

            POP DX

            SUB DL, '0'
            ADD AL, DL

            INC CX

            BELOW_BOUND1:
            ABOVE_BOUND1:
            TERMINATOR1:

        LOOP WHILE1

        POP CX

        RET

    READ_DEC_NUMBER ENDP

    ;?---------------------------------------------------

    ; * Procedure to print a decimal number to the screen
    PRINT_DEC_NUMBER PROC FAR

        PUSH CX
        MOV CX, 0

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
            PRINTCHAR DL     
            LOOP PRINT_LOOP  

        POP CX

        RET

    PRINT_DEC_NUMBER ENDP

    ;?---------------------------------------------------

    ; * Procedure to apply the algorithm until one edge-case is met
    ;   Also, the function prints the wanted information about the
    ;   iterations to the console
    KAPREKAR_FUN PROC FAR

        MOV CX, 1
        MOV SI, 0

        ITER:

            CMP AX, KAPREKAR_CNST
            JE FOUND_KAPREKAR

            CMP AX, 0000D
            JE FOUND_4ZEROS

            CALL APPLY_LOOP

            INC SI
            INC CX

            MOV DX, 0
            MOV BX, 10D

            PUSH AX
            PUSH AX

            MOV AX, HIGH_NB
            CALL PRINT_DEC_NUMBER

            PRINT_MSG ADR_SUB_TEXT

            MOV AX, LOW_NB
            CALL PRINT_DEC_NUMBER

            PRINT_MSG ADR_EQ_TEXT

            POP AX
            CALL PRINT_DEC_NUMBER
            NEW_LINE

            POP AX

            FOUND_KAPREKAR:
            FOUND_4ZEROS:

        LOOP ITER

        RET

    KAPREKAR_FUN ENDP

    ; * Procedure to apply the algorithm until one edge-case is met
    KAPREKAR_FUN2 PROC FAR

        MOV CX, 1
        MOV SI, 0

        ITER2:

            CMP AX, KAPREKAR_CNST
            JE FOUND_KAPREKAR2

            CMP AX, 0000D
            JE FOUND_4ZEROS2

            PUSH CX
            CALL APPLY_LOOP
            POP CX

            INC SI
            INC CX

            MOV DX, 0
            MOV BX, 10D

            FOUND_KAPREKAR2:
            FOUND_4ZEROS2:

        LOOP ITER2

        RET

    KAPREKAR_FUN2 ENDP

    ;?---------------------------------------------------
    
    ; * Procedure to apply the algorithm for finding next wanted number
    ;   The procedure does the following:
    ;           - store digits in memory (at adr=0)
    ;           - applys bubble-sort algorithm to the digits
    ;           - builds digit-increasing and digit-decreasing numbers
    ;           - subtracts first from the latter and stores value in AX

    ;   Thus, one loop from the entire algorithm is done using this function
    ;   APPLY_LOOP is called in the "Kaprekar_Fun" procedures 

    APPLY_LOOP PROC FAR


        PUSH CX
        PUSH SI

            MOV SI, 0D  ;! reinitialize SI to 0 so we can iterate through array

            MOV CX, 4D

            STORE_DIGITS: 

                XOR DX, DX
                DIV BX

                MOV BYTE PTR [SI], DL
                INC SI

                EXIT_STORE_DIGITS:

            LOOP STORE_DIGITS
 
            MOV CX, 3  
            MOV BX, 0
            MOV SI, 0

            BUBBLE_SORT

            MOV CX, 4D
            MOV BX, 10D
            MOV SI, 0
            MOV AX, 0

            CONSTRUCT_DECR_DIGITS:

                MUL BX
                ADD AL, BYTE PTR [SI]
                ADC AH, 0
                INC SI

            LOOP CONSTRUCT_DECR_DIGITS

            MOV LOW_NB, AX

            MOV AX, 0
            MOV SI, 3D
            MOV CX, 4D  

            CONSTRUCT_INCR_DIGITS:

                MUL BX

                ADD AL, BYTE PTR [SI]
                ADC AH, 0
                DEC SI

            LOOP CONSTRUCT_INCR_DIGITS

            MOV HIGH_NB, AX

            SUB AX, LOW_NB

        POP SI
        POP CX

        RET 

    APPLY_LOOP ENDP

    ;?---------------------------------------------------

    ; * Procedure to print a decimal number in the file
    PRINTF_DEC_NUMBER PROC FAR

        MOV SI, BX

        MOV CX, 0

        CONVERT_LOOP2:
            MOV DX, 0        
            MOV BX, 10D        
            DIV BX           
            ADD DL, '0'      
            PUSH DX            
            INC CX  
            CMP AX, 0         
        JNZ CONVERT_LOOP2 

        MOV BX, SI

        PRINT_LOOP2:
            POP DX         
            PRINTFCHAR DL    
        LOOP PRINT_LOOP2  

        RET

    PRINTF_DEC_NUMBER ENDP

    ; * Procedure to convert AX' value to the screen and store its
    ; * string representation in specified address in memory
    CONVERT_TO_STR PROC FAR 

        CALL CLEAR_TOOL ; make sure that memory we want to use is cleared

        PUSH CX

        MOV SI, BX
        MOV DI, 3
        MOV CX, 0

        CONVERT_LOOP3:
            MOV DX, 0        
            MOV BX, 10D        
            DIV BX           
            ADD DL, '0'      
            MOV BYTE PTR [TOOL_NB + DI], DL
            DEC DI   
            INC CX  
            CMP AX, 0         
        JNZ CONVERT_LOOP3 

        MOV BX, SI

        POP CX

        RET 

    CONVERT_TO_STR ENDP

    ; * Procedure to clear the memory space where CONVERT_TO_STR string 
    ; * is stored (make the bytes' value as '0' again)
    CLEAR_TOOL PROC FAR 

        PUSH CX
        PUSH DI

        MOV CX, 4
        MOV DI, 3
        ITER1:

            MOV BYTE PTR [TOOL_NB + DI], 30H
            DEC DI

        LOOP ITER1

        POP DI
        POP CX

        RET

    CLEAR_TOOL ENDP

    ; * Procedure that iterates through all 0000 to 9999 numbers, calls 
    ; * Kaprekar_Fun for each one of them and prints %NUMBER and %NO_ITERs 
    ; * to the file
    FILE_LOOP PROC FAR

        MOV AX, 0D
        MOV CX, 1D

        ITERATE:

            PUSH AX
            PUSH AX

            CALL CONVERT_TO_STR
            PRINTF_MSG [ADR_TOOL_NB] 4D
            PRINTF_MSG [ADR_BLANKSPACE] 1D

            POP AX
            
            PUSH CX
            PUSH BX
            MOV BX, 10D
            CALL KAPREKAR_FUN2
            POP BX
            POP CX

            MOV AX, SI
            CALL CONVERT_TO_STR
            PRINTF_MSG [ADR_TOOL_NB] 4D

            PRINTF_MSG [ADR_NEWLINE] 1D

            POP AX

            CMP AX, 9999D
            JE EXIT_FILE_LOOP

            INC AX

            INC CX

            EXIT_FILE_LOOP:

        LOOP ITERATE

        RET

    FILE_LOOP ENDP

CODE2 ENDS

END START