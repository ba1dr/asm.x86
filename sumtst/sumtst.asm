TITLE   Smallest summator
CODESG  SEGMENT PARA 'CODE'
        ASSUME  CS:CODESG, DS:CODESG, ES:CODESG
        ORG     100h
BEGIN:
        MOV     SI, (OFFSET chislo2)-1
        MOV     CL, maxlen+1
        MOV     BL, maxlen+1
        MOV     DH, 0B8h
        MOV     ES, DX
        MOV     DI, 0170h;0B40h
        STD
sums:
        XOR     AX, 0A030h
        STOSW
        LODSB
        ADD     AL, BYTE PTR [BX+SI]
        ADD     AL, AH
        AAM
        LOOP    sums
EXITER:
        RET
chislo1         DB '0076856758123456789'
chislo2         DB '3456789116586567823'
ch2end:
maxlen          EQU (OFFSET chislo2)-(OFFSET chislo1)
result:
CODESG  ENDS
END     BEGIN
