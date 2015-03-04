Codesg  segment para 'CODE'
assume  cs:Codesg, ds:Codesg, es:Codesg
        org     100h
Begin:
        xor     cx, cx
        mov     cl, byte ptr ds:[80h]
        mov     si, 82h
        dec     cx
nsfnd:
        lodsb
        cmp     al, 20h
        je      sfnd
        loop    nsfnd
sfnd:
        xor     ax, ax
        xchg    di, si
        stosb
        mov     dx, 82h
        mov     ax, 3D00h
        int     21h ;Открываем файл
        jnc     openOk
        ret
openOk:
        mov     word ptr cs:fhandle, ax
        call    fload
        xor     ax, ax
        mov     es, ax
        mov     ax, word ptr es:[0024h]
        mov     word ptr cs:oldint9, ax
        mov     ax, word ptr es:[0026h]
        mov     word ptr cs:oldint9+2, ax
        cli   ; Ну люблю я полностью забирать ресурсы...
        mov     ax, offset int9h
        mov     word ptr es:[0024h], ax
        mov     ax, cs
        mov     word ptr es:[0026h], ax
BegScroll:
        cld
;Гасим курсор
        mov     dx, 03D4h
        mov     al, 0Ah
        out     dx, al
        inc     dx
        in      al, dx
        push    ax
        mov     al, 100000b
        out     dx, al
        mov     ax, 0B800h
        mov     es, ax
        mov     ds, ax
        mov     di, 25*80*2
        mov     ax, 720h
        mov     cx, 80
        rep     stosw
        xor     si, si
        mov     di, 27*80*2
begloop:
        mov     cx, 1
scrlloop:
;Плавный сдвиг 16 пикселей
        call    DELY
        call    scrol
        cmp     byte ptr cs:exitkey, 1
        jne     notexitkey
        jmp     exiter
notexitkey:
        inc     cx
        cmp     cx, 16
        jle     scrlloop
;Возврат скроллера в 0
        xor     cx, cx
        call    scrol
;Вывод очередной текстовой строки и
;заполнение первой строки второго окна пробелами
        push    si
        push    di
        mov     cx, 80
        sub     di, cx
        sub     di, cx
        cmp     byte ptr cs:lastpage, 0
        jne     nemp
        cmp     bp, word ptr cs:wend
        jb      nemp
        call    fload
nemp:
        mov     ah, colr
nextsymb:
        mov     al, byte ptr cs:[bp]
        cmp     al, 13
        jne     l1
        inc     bp
        mov     al, byte ptr cs:[bp]
l1:
        cmp     al, 10
        je      outsmb
sout:
        cmp     al, 26
        je      exiter
        stosw
        inc     bp
        loop    nextsymb
outsmb:  ;Перевод строки
        inc     bp
        mov     ax, 720h
        rep     stosw
        pop     di
        pop     si
        push    bx
        mov     ax, 0601h
        xor     bx, bx
        xor     cx, cx
        mov     dx, 1A4Fh
        int     10h
        pop     bx
        jmp     begloop
                db "baldr"   ;Типа копирайт...
exiter:
        cli
        xor     ax, ax
        mov     es, ax
        mov     ax, word ptr cs:oldint9
        mov     word ptr es:[0024h], ax
        mov     ax, word ptr cs:oldint9+2
        mov     word ptr es:[0026h], ax
        xor     cx, cx
        call    scrol
        mov     ax, 0601h
        xor     bx, bx
        xor     cx, cx
        mov     dx, 1A4Fh
        int     10h
        mov     dx, 03D4h
        mov     al, 0Ah
        out     dx, al
        inc     dx
        pop     ax
        out     dx, al
        sti
        call    fclose
        ret
WRETR   proc near
        mov     dx, 03DAh
wre:
        in      al, dx
        test    al, 1000b
        jnz     wre
wrs:
        in      al, dx
        test    al, 1000b
        jz      wrs
        ret
WRETR   endp
DELY    proc
        mov     bl, byte ptr cs:speed
        cmp     bl, 0
        jg      delaypres
        ret
delaypres:
        cmp     bl, 1
        jg      not1
        inc     cx
        jmp     WRETR
not1:
        cmp     bl, 2
        jg      not2
        ;inc     cx
not2:
        push    cx
        xor     ax, ax
        xor     dx, dx
        mov     dl, bl
.286
        mov     cx, 14
        cmp     bl, 3
        jle     bln3
        inc     cx
bln3:
lpp2:
        shl     dx, 1
        rcl     ax, 1
        loop    lpp2
        mov     cx, ax
        mov     ah, 86h
        int     15h
        pop     cx
        call    WRETR
        ret
DELY    endp
scrol   proc
        mov     dx, 03D4h
        mov     al, 08h
        out     dx, al
        inc     dx
        mov     al, cl
        out     dx, al
        ret
scrol   endp
fclose  proc
        mov     bx, word ptr cs:fhandle
        mov     ah, 3Eh
        int     21h
        ret
fclose  endp
fload   proc
        push    ax
        push    bx
        push    dx
        push    cx
        push    ds
        push    cs
        pop     ds
        mov     bx, word ptr cs:fhandle
        cmp     word ptr cs:wend, 0
        je      firstrun
        mov     ax, 4201h
        xor     dx, dx
        xor     cx, cx
        int     21h
        mov     cx, dx
        mov     dx, ax
        push    bx
        mov     bx, bp
        sub     bx, word ptr cs:wend
        mov     ax, endbls
        sub     ax, bx
        pop     bx
        sub     dx, ax
        sbb     cx, 0
        mov     ax, 4200h
        int     21h
firstrun:
        mov     ah, 3Fh
        mov     dx, offset cs:w1
        mov     cx, blocksize
        int     21h
        pop     ds
        jnc     readOk
        pop     cx
        pop     dx
        pop     bx
        pop     ax
        pop     ax
        jmp     exiter
readOk:
        mov     bx, ax
        cmp     cx, ax
        je      notlp
        mov     byte ptr cs:lastpage, 1
notlp:
        mov     bp, offset cs:w1
        add     bx, bp
        mov     word ptr cs:wend, bx
        mov     ax, endbls
        sub     word ptr cs:wend, ax
        mov     word ptr cs:[bx], 0A0Ah
        inc     bx
        inc     bx
        mov     byte ptr cs:[bx], 26
        pop     cx
        pop     dx
        pop     bx
        pop     ax
        ret
fload   endp
int9h   proc
        push    ax
        in      al, 60h   ;Считываем нажатую клавишу
        cmp     al, 81h
        jne     notesc
        mov     cs:exitkey, 1
notesc:
        mov     ah, byte ptr cs:speed
        cmp     al, 0CEh
        jne     ifminus
        cmp     ah, 0
        je      bgl
        dec     ah
ifminus:
        cmp     al, 0CAh
        jne     bgl
        cmp     ah, 5
        jge     bgl
        inc     ah
bgl:
        mov     byte ptr cs:speed, ah
i09h_exit:
        in      al, 61h
        or      al, 80h
        out     61h, al
        and     ax, 7Fh
        out     61h, al
        mov     al, 20h   ;Завершения прерывания
        out     20h, al
        pop     ax
        iret
int9h   endp
cp              db 000h, 001h, 002h, 003h, 004h, 005h, 006h, 007h
                db 008h, 009h, 00Ah, 00Bh, 00Ch, 00Dh, 00Eh, 00Fh
                db 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h
                db 018h, 019h, 01Ah, 01Bh, 01Ch, 01Dh, 01Eh, 01Fh
                db 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h
                db 028h, 029h, 02Ah, 02Bh, 02Ch, 02Dh, 02Eh, 02Fh
                db 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h
                db 038h, 039h, 03Ah, 03Bh, 03Ch, 03Dh, 03Eh, 03Fh
                db 040h, 041h, 042h, 043h, 044h, 045h, 046h, 047h
                db 048h, 049h, 04Ah, 04Bh, 04Ch, 04Dh, 04Eh, 04Fh
                db 050h, 051h, 052h, 053h, 054h, 055h, 056h, 057h
                db 058h, 059h, 05Ah, 05Bh, 05Ch, 05Dh, 05Eh, 05Fh
                db 060h, 061h, 062h, 063h, 064h, 065h, 066h, 067h
                db 068h, 069h, 06Ah, 06Bh, 06Ch, 06Dh, 06Eh, 06Fh
                db 070h, 071h, 072h, 073h, 074h, 075h, 076h, 077h
                db 078h, 079h, 07Ah, 07Bh, 07Ch, 07Dh, 07Eh, 07Fh
                db 03Fh, 03Fh, 027h, 03Fh, 022h, 03Ah, 0C5h, 0D8h
                db 03Fh, 025h, 03Fh, 03Ch, 03Fh, 03Fh, 03Fh, 03Fh
                db 03Fh, 027h, 027h, 022h, 022h, 007h, 02Dh, 02Dh
                db 03Fh, 054h, 03Fh, 03Eh, 03Fh, 03Fh, 03Fh, 03Fh
                db 0FFh, 0F6h, 0F7h, 03Fh, 0FDh, 03Fh, 0B3h, 015h
                db 0F0h, 063h, 0F2h, 03Ch, 0BFh, 02Dh, 052h, 0F4h
                db 0F8h, 02Bh, 049h, 069h, 03Fh, 0E7h, 014h, 0FAh
                db 0F1h, 0FCh, 0F3h, 03Eh, 03Fh, 03Fh, 03Fh, 0F5h
                db 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h
                db 088h, 089h, 08Ah, 08Bh, 08Ch, 08Dh, 08Eh, 08Fh
                db 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h
                db 098h, 099h, 09Ah, 09Bh, 09Ch, 09Dh, 09Eh, 09Fh
                db 0A0h, 0A1h, 0A2h, 0A3h, 0A4h, 0A5h, 0A6h, 0A7h
                db 0A8h, 0A9h, 0AAh, 0ABh, 0ACh, 0ADh, 0AEh, 0AFh
                db 0E0h, 0E1h, 0E2h, 0E3h, 0E4h, 0E5h, 0E6h, 0E7h
                db 0E8h, 0E9h, 0EAh, 0EBh, 0ECh, 0EDh, 0EEh, 0EFh
koi             db 000h, 001h, 002h, 003h, 004h, 005h, 006h, 007h
                db 008h, 009h, 00Ah, 00Bh, 00Ch, 00Dh, 00Eh, 00Fh
                db 010h, 011h, 012h, 013h, 014h, 015h, 016h, 017h
                db 018h, 019h, 01Ah, 01Bh, 01Ch, 01Dh, 01Eh, 01Fh
                db 020h, 021h, 022h, 023h, 024h, 025h, 026h, 027h
                db 028h, 029h, 02Ah, 02Bh, 02Ch, 02Dh, 02Eh, 02Fh
                db 030h, 031h, 032h, 033h, 034h, 035h, 036h, 037h
                db 038h, 039h, 03Ah, 03Bh, 03Ch, 03Dh, 03Eh, 03Fh
                db 040h, 041h, 042h, 043h, 044h, 045h, 046h, 047h
                db 048h, 049h, 04Ah, 04Bh, 04Ch, 04Dh, 04Eh, 04Fh
                db 050h, 051h, 052h, 053h, 054h, 055h, 056h, 057h
                db 058h, 059h, 05Ah, 05Bh, 05Ch, 05Dh, 05Eh, 05Fh
                db 060h, 061h, 062h, 063h, 064h, 065h, 066h, 067h
                db 068h, 069h, 06Ah, 06Bh, 06Ch, 06Dh, 06Eh, 06Fh
                db 070h, 071h, 072h, 073h, 074h, 075h, 076h, 077h
                db 078h, 079h, 07Ah, 07Bh, 07Ch, 07Dh, 07Eh, 07Fh
                db 0C4h, 0B3h, 0DAh, 0BFh, 0C0h, 0D9h, 0C3h, 0B4h
                db 0C2h, 0C1h, 0C5h, 0DFh, 0DCh, 0DBh, 0DDh, 0DEh
                db 0B0h, 0B1h, 0B2h, 0F4h, 0FEh, 0F9h, 0FBh, 0F7h
                db 0F3h, 0F2h, 0FFh, 0F5h, 0F8h, 0FDh, 0FAh, 0F6h
                db 0CDh, 0BAh, 0D5h, 0F1h, 0D6h, 0C9h, 0B8h, 0B7h
                db 0BBh, 0D4h, 0D3h, 0C8h, 0BEh, 0BDh, 0BCh, 0C6h
                db 0C7h, 0CCh, 0B5h, 0F0h, 0B6h, 0B9h, 0D1h, 0D2h
                db 0CBh, 0CFh, 0D0h, 0CAh, 0D8h, 0D7h, 0CEh, 0FCh
                db 0EEh, 0A0h, 0A1h, 0E6h, 0A4h, 0A5h, 0E4h, 0A3h
                db 0E5h, 0A8h, 0A9h, 0AAh, 0ABh, 0ACh, 0ADh, 0AEh
                db 0AFh, 0EFh, 0E0h, 0E1h, 0E2h, 0E3h, 0A6h, 0A2h
                db 0ECh, 0EBh, 0A7h, 0E8h, 0EDh, 0E9h, 0E7h, 0EAh
                db 09Eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h
                db 095h, 088h, 089h, 08Ah, 08Bh, 08Ch, 08Dh, 08Eh
                db 08Fh, 09Fh, 090h, 091h, 092h, 093h, 086h, 082h
                db 09Ch, 09Bh, 087h, 098h, 09Dh, 099h, 097h, 09Ah
exitkey         db 0
speed           db 2
oldint9         dw 0, 0
colr            equ 7
endbls          equ 100
blocksize       equ 60000
lastpage        db 0
fhandle         dw 0
wend            dw 0
w1:
Codesg  ends
end     Begin
