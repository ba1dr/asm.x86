TITLE   Recoder by baldr. Version 6.0
codesg  SEGMENT PARA 'code'
        ASSUME  CS:codesg, DS:codesg, ES:codesg
        ORG     100h
start:
        MOV     SI, 82h
        MOV     DI, OFFSET filename
getfnsymb:
        ;Getting file name from PSP
        MOV     AH, BYTE PTR [SI]
        CMP     AH, 30h
        JL      getnameok1
        MOV     BYTE PTR [DI], AH
        INC     DI
        INC     SI
        JMP     getfnsymb
getnameok1:
        INC     DI
        XOR     CX, CX
        MOV     BYTE PTR [DI], CL
        MOV     DX, OFFSET filename
        CALL    filefind
        JC      notfind
        JMP     getf2
notfind:
        MOV     AH, 09h
        MOV     DX, OFFSET error1
        INT     21h
        JMP     exiter
getf2:
        INC     SI
        MOV     DI, OFFSET refile
getfnsymb1:
        ;Getting file name from PSP
        MOV     AH, BYTE PTR [SI]
        CMP     AH, 30h
        JL      getnameok2
        MOV     BYTE PTR [DI], AH
        INC     DI
        INC     SI
        JMP     getfnsymb1
getnameok2:
        INC     DI
        MOV     BYTE PTR [DI], CL
        INC     SI
exiter:
        RET
;Procedures
filefind PROC
        PUSH    AX
        PUSH    CX
        MOV     AH, 4Eh
        MOV     CX, 0
        INT     21h
        POP     CX
        POP     AX
        RET
filefind ENDP

;Data
error1          DB "File not found...", 13, 10, '$'
filename        DB 50 DUP (0)
refile          DB 50 DUP (0)
codetables:
codesg  ENDS
        END     start
