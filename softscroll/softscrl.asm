Codesg  SEGMENT PARA 'CODE'
ASSUME  CS:Codesg, DS:Codesg, ES:Codesg
        ORG     100h
Begin:
        CLI   ; Ну люблю я полностью забирать ресурсы...
        CLD
        MOV     BP, OFFSET w1
        MOV     BL, 3
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
        MOV     DI, 27*80*2
begloop:
        MOV     CX, 1
scrlloop:
;Плавный сдвиг 16 пикселей
        CMP     BL, 0
        JE      notwretr
        CALL    DELY
        CALL    WRETR
notwretr:
        CALL    scrol
;Проверка на нажатую клавишу
        MOV     AH, 11h
        INT     16h
        JNZ     lpp1
        JMP     abc
lpp1:
;Readkey...
        MOV     AH, 10h
        INT     16h
        CMP     AH, 01
        JE      exiter
        MOV     AL, BL
        CMP     AH, 4Ah
        JNE     ifplus
        CMP     AL, 6
        JGE     bgl
        INC     AL
ifplus:
        CMP     AH, 4Eh
        JNE     bgl
        CMP     AL, 0
        JE      bgl
        DEC     AL
bgl:
        MOV     BL, AL
abc:
        INC     CX
        CMP     CX, 16
        JLE     scrlloop
;Возврат скроллера в 0
        XOR     CX, CX
        CALL    scrol
;Вывод очередной текстовой строки и
;заполнение первой строки второго окна пробелами
        PUSH    SI
        PUSH    DI
        MOV     CX, 80
        SUB     DI, CX
        SUB     DI, CX
        CMP     BYTE PTR CS:[BP], 0
        JNE     nemp
        MOV     BP, OFFSET w1
nemp:
        MOV     AH, CS:colr
nextsymb:
        MOV     AL, BYTE PTR CS:[BP]
        CMP     AL, 0
        JE      outsmb
        CMP     AL, 1
        JNE     sout
        INC     BP
        MOV     AH, BYTE PTR CS:[BP]
        MOV     CS:colr, AH
        INC     BP
        JMP     nextsymb
sout:
        STOSW
        INC     BP
        DEC     CX
        JMP     nextsymb
                DB "baldr"   ;Типа копирайт...
outsmb:
        INC     BP
        MOV     AX, 720h
        REP     STOSW
        POP     DI
        POP     SI
        PUSH    BX
        MOV     AX, 0601h
        XOR     BX, BX
        XOR     CX, CX
        MOV     DX, 1A4Fh
        INT     10h
        POP     BX
        JMP     begloop
exiter:
        XOR     CX, CX
        CALL    scrol
        MOV     DX, 03D4h
        MOV     AL, 0Ah
        OUT     DX, AL
        INC     DX
        POP     AX
        OUT     DX, AL
        STI
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
DELY    PROC
        PUSH    CX
        MOV     CL, BL
        CMP     CL, 0
        JE      zer
        DEC     CL
zer:
        SHL     CL, 2
        MOV     AX, 02FFFh
        MUL     CX
        MOV     CX, DX
        MOV     DX, AX
        MOV     AH, 86h
        INT     15h
        POP     CX
        RET
DELY    ENDP
scrol   PROC
        MOV     DX, 03D4h
        MOV     AL, 08h
        OUT     DX, AL
        INC     DX
        MOV     AL, CL
        OUT     DX, AL
        RET
scrol   ENDP
colr            DB 7
w1              DB 1, 0Eh, "QHELP:", 1, 7, " gray+", 1, 0Eh, ", ", 1, 7, " gray-", 1, 0Eh, ", ", 1, 7, " Esc", 0
                DB " ", 0
                DB 1, 0Ch, " Тек", 1, 0Bh, "ст1", 0
                DB "Т", 1, 0Ah, "екст2 ", 0
                DB "Т", 1, 0Ah, "екст3 ", 0
                DB 1, 0Fh, " Еще текст...", 0
                DB 1, 7, " Кстати, экран нигде не дергается?", 0
                DB " ", 0
                DB " ", 0
wend            DB 0  ;Завершается двумя нулями...
Codesg  ENDS
END     Begin
