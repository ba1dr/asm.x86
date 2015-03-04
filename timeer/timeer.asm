TITLE   SMALLEST CLOCK - 38 bytes!!!
CODESG  SEGMENT PARA 'Code'
        ASSUME  CS:CODESG
        ORG     100h
BEGIN:
        MOV     AH, 2Ch
        INT     21h
        MOV     AL, CH
ML:
        AAM
        OR      AX, 3030h
        MOV     DL, AH
        MOV     CH, AL
        MOV     AH, 06h
        INT     21h
        MOV     DL, CH
        INT     21h
        MOV     DL, 20h
        INT     21h
        MOV     AL, CL
        MOV     CL, DH
        MOV     DH, 61
        CMP     AL, DH
        JNZ     ML
        RET
CODESG  ENDS
        END     BEGIN