title
.186
codesg  segment para 'code'
        assume  cs:codesg, ds:codesg, es:codesg
        org     100h
begin:
        mov     ax, 13h
        int     10h
        cld
        push    ds
        xor     ax, ax
        push    ax
        mov     ds, ax
        mov     si, 70h ;1Ch
        mov     di, offset old1ChV
        movsw
        movsw
        mov     si, 24h ;09h
        mov     di, offset old09hV
        movsw
        movsw
        pop     es
        pop     ds
        mov     di, 70h
        mov     ax, offset new1ChV
        cli
        stosw
        mov     ax, ds
        stosw
        mov     di, 24h
        mov     ax, offset new09hV
        stosw
        mov     ax, ds
        stosw
        sti        ; int 1Ch и int 09h перехвачены
;        mov     ax, 0A000h
;        mov     es, ax

endloop:
        mov     al, byte ptr actionflag
        shr     al, 1
        jc      okexit
        jmp     endloop
okexit:
        push    cs
        pop     ds
        xor     ax, ax
        mov     es, ax
        mov     si, offset old1ChV
        mov     di, 70h
        cli
        movsw
        movsw
        mov     si, offset old09hV
        mov     di, 24h
        movsw
        movsw
        sti
        mov     ax, 03h
        int     10h
        ret

old1ChV         dd 0
old09hV         dd 0
exitkey         equ 081h
actionflag      db 0
delayer         dw 0

new1ChV proc
        push    es
        push    ds
        pusha
        cmp     word ptr cs:delayer, 1
        je      ni1Chex
        inc     word ptr cs:delayer
        jmp     i1Chex
ni1Chex:
        mov     word ptr cs:delayer, 0
        ;mov     ax, 0A000h
        ;mov     es, ax
        ;mov     ds, ax
        ;mov     si, 320*199
        ;mov     di, 320*200
        ;mov     cx, 320*199
        ;std
        ;rep     movsb
i1Chex:
        popa
        pop     ds
        pop     es
        jmp     cs:old1ChV
new1ChV endp

new09hV proc
        pusha
        push    es
        push    ds
        push    cs
        pop     ds
        push    cs
        pop     es
        in      al, 60h
        cmp     al, exitkey
        jne     notexit
        or      byte ptr cs:actionflag, 1
        jmp     oni9exit
notexit:

oni9exit:
        in      al, 61h
        push    ax
        or      al, 80h
        out     61h, al
        pop     ax
        out     61h, al
        mov     al, 20h
        out     20h, al
        pop     ds
        pop     es
        popa
        iret
new09hV endp

codesg  ends
end     begin
