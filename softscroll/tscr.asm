Codesg  SEGMENT PARA 'CODE'
ASSUME  CS:Codesg, DS:Codesg, ES:Codesg
        ORG     100h
Begin:
        CLD
        MOV     BX, OFFSET w1
;Гасим курсор
        MOV     DX, 03D4h
        MOV     AL, 0Ah
        OUT     DX, AL
        INC     DX
        IN      AL, DX
        PUSH    AX
        MOV     AL, 100000b
        OUT     DX, AL
        MOV     AX, 0B800h
        MOV     ES, AX
        MOV     DS, AX
        MOV     DI, 25*80*2
        MOV     AX, 720h
        MOV     CX, 80
        REP     STOSW
        XOR     SI, SI
        MOV     DI, 26*80*2
begloop:
        CLI
scrlloop:
;Плавный сдвиг 16 пикселей
        CALL    WRETR
        MOV     DX, 03D4h
        MOV     AL, 08h
        OUT     DX, AL
        INC     DX
        MOV     AL, CL
        OUT     DX, AL
        INC     CX
        CMP     CX, 16
        JLE     scrlloop
;Копируем из первого во второе окно, начиная со второй строки
        PUSH    SI
        PUSH    DI
        ADD     SI, 160
        MOV     CX, 25*80*2
        REP     MOVSB
        POP     DI
        POP     SI
;Переключаемся во второе окно
        DEC     DX
        MOV     AL, 0Ch
        OUT     DX, AL
        MOV     AX, 26*80*2
        INC     DX
        OUT     DX, AX
;Возврат скроллера в 0
        DEC     DX
        MOV     AL, 08
        OUT     DX, AL
        INC     DX
        MOV     AL, 0
        OUT     DX, AL
;Копируем из второго окна в первое
        PUSH    SI
        PUSH    DI
        MOV     DI, SI
        MOV     CX, 25*80*2
        ADD     SI, 160
        REP     MOVSB
        POP     DI
        POP     SI
;Вывод очередной текстовой строки и
;заполнение первой строки второго окна пробелами
        PUSH    SI
        PUSH    DI
        MOV     CX, 80
        SUB     DI, CX
        SUB     DI, CX
        CMP     BYTE PTR CS:[BX], 0
        JNE     nemp
        MOV     BX, OFFSET w1
nemp:
        MOV     AH, 7
nextsymb:
        MOV     AL, BYTE PTR CS:[BX]
        CMP     AL, 0
        JE      outsmb
        CMP     AL, 1
        JNE     sout
        INC     BX
        MOV     AH, BYTE PTR CS:[BX]
        INC     BX
        JMP     nextsymb
        ;MOV     AL, BYTE PTR CS:[BX]
sout:
        STOSW
        INC     BX
        DEC     CX
        JMP     nextsymb
        DB "baldr"
outsmb:
        INC     BX
        MOV     AX, 720h
        REP     STOSW
        POP     DI
        POP     SI
;Переключаемся из второго в первое окно
        DEC     DX
        MOV     AL, 0Ch
        OUT     DX, AL
        XOR     AX, AX
        INC     DX
        OUT     DX, AX
        STI
;Проверка на нажатую клавишу
        MOV     AH, 01h
        INT     16h
        JNZ     lpp1
        JMP     begloop
lpp1:
;Readkey...
        MOV     AH, 00h
        INT     16h
exiter:
        MOV     DX, 03D4h
        MOV     AL, 0Ah
        OUT     DX, AL
        INC     DX
        POP     AX
        OUT     DX, AL
        RET
WRETR   PROC NEAR
        MOV     DX, 03DAh
wre:
        IN      AL, DX
        TEST    AL, 1000b
        JNZ     wre
wrs:
        IN      AL, DX
        TEST    AL, 1000b
        JZ      wrs
        RET
WRETR   ENDP
w1      DB "1", 0, "2", 0, "3", 0, " ", 0,0
Codesg  ENDS
END     Begin
