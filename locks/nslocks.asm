;Программа проверки горящих индикаторов клавиатуры
;Автор: baldr
;  e-mail:  baldr@pisem.net
;homepage:  http://www.dospage.far.ru
;
;                     Пользуйтесь на здоровье!
Codesg  SEGMENT PARA 'CODE'
ASSUME  CS:Codesg, DS:Codesg, ES:Codesg
        ORG     100h
Begin:
        MOV     AX, 40h
        MOV     ES, AX
        MOV     AL, BYTE PTR ES:[17h]
        AND     AL, 01110000b
        MOV     AH, AL
        AND     AH, 00010000b
        JZ      n1
        OR      AL, 10000000b
n1:
        SHR     AL, 5
exiter:
        MOV     AH, 4Ch
        INT     21h
Codesg  ENDS
END     Begin
