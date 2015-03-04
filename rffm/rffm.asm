title   Program for reading array & searching minimum in it
CodeSg  segment para 'CODE'
        assume  cs:CodeSg, ds:CodeSg, ss:CodeSg, es:CodeSg
        org     100h
start:
        mov     si, 82h
        mov     di, offset filename
getfnsymb:
        ;Getting file name from PSP
        mov     ah, byte ptr [si]
        cmp     ah, 30h
        jl      getnameok1
        mov     byte ptr [di], ah
        inc     di
        inc     si
        jmp     getfnsymb
getnameok1:
        mov     dx, offset filename
        call    filefind
        jc      notfind1
        jmp     openfile
notfind1:
        ;Getting file name from keyboard
        mov     ah, 09h
        mov     dx, offset msg1
        int     21h
        mov     ah, 09h
        mov     dx, offset msg2
        int     21h
        mov     ah, 0Ah
        mov     dx, offset buffer
        int     21h
        mov     ah, 09h
        mov     dx, offset crlf
        int     21h
        xor     bx, bx
        mov     bl, stlen
        add     bx, offset filename
        mov     byte ptr [bx], 0
        mov     dx, offset filename
        call    filefind
        jc      notfind2
        jmp     openfile
notfind2:
        ;File not found, exiting...
        mov     ah, 09h
        mov     dx, offset msg3
        int     21h
        jmp     progexit
openfile:
        ;Opening exist file for reading.
        mov     ax, 3D00h
        mov     cl, 0h
        mov     dx, offset filename
        int     21h
        jnc     fopened
        jmp     errorexit
fopened:
        mov     fhandle, ax
        ;Getting file size
        mov     ax, 4202h
        mov     bx, fhandle
        xor     dx, dx
        xor     cx, cx
        int     21h
        jnc     fseeked1
        ;If not seeked:
        jmp     errorexit
fseeked1: ;Checking: file size less than 4E20h ?
        cmp     dx, 0
        je      fseeked2
        jmp     errorexit
fseeked2:
        cmp     ax, 07FFFh ;Maximum array size - 07FFFh
        jl      savesize
        jmp     errorexit
savesize:
        mov     fsize, ax
        mov     ax, 4200h
        mov     bx, fhandle
        xor     dx, dx
        xor     cx, cx
        int     21h
        jnc     readfile
        ;If not seeked:
        jmp     errorexit
readfile: ;Reading file
        mov     di, offset array
getarr:
        xor     ax, ax
        mov     si, offset filename
        mov     byte ptr [si], al
        inc     si
nextsymb:
        ;Reading non-digits
        cmp     fsize, 0
        je      closefile
        mov     ah, 3Fh
        mov     cx, 1
        mov     bx, fhandle
        mov     dx, si
        dec     word ptr fsize
        int     21h
        jnc     checkbyte
        jmp     errorexit
checkbyte:
        ;Checking byte was readed
        cmp     byte ptr [si], 30h
        jl      nextsymb
        cmp     byte ptr [si], 39h
        jg      nextsymb ;See: if [si]<'0' and [si]>'9' then it's "litter"
nextsymb1:
        ;Reading digits
        inc     si
        cmp     fsize, 0
        je      decode
        mov     ah, 3Fh
        mov     cx, 1
        mov     bx, fhandle
        mov     dx, si
        dec     word ptr fsize
        int     21h
        jnc     checkbyte1
        jmp     errorexit
checkbyte1:
        ;Checking byte was readed
        cmp     byte ptr [si], 30h
        jl      decode
        cmp     byte ptr [si], 39h
        jg      decode
        jmp     nextsymb1
decode:
        ;Decoding number was readed.
        ;Number must be written with 2 digits as maximum
        ;So, any array element can be less than 100
        ;If it was written with 3 digits and more - it will truncated.
        ;For example: from 12345 we get 45 !
        xor     ax, ax
        mov     [si], al
        mov     al, [si-1]
        mov     ah, [si-2]
        and     ax, 0F0Fh ;Convert symbol digits to binary digits in AX
        aad    ; Convert BCD in AX to HEX in AL
        mov     [di], al ;filling array
        inc     di
        jmp     getarr
closefile:
        ;Closing file
        mov     ah, 3Eh
        mov     bx, fhandle
        int     21h
        jc      errorexit
        ;Searching minimum in array
        dec     di
        xor     ax, ax
        mov     al, [di]
step:
        cmp     di, offset array
        je      outresult
        dec     di
        cmp     al, [di]
        jle     step
        mov     al, [di]
        jmp     step
outresult:
        ;Out results: minimum of array
        mov     cl, 4
        shl     ax, cl
        shr     al, cl
        mov     cx, ax
        mov     ah, 09h
        mov     dx, offset msg4
        int     21h
        mov     ah, 02h
        mov     al, ch
        mov     bx, offset digit
        xlatb
        mov     dl, al
        int     21h
        mov     al, cl
        mov     bx, offset digit
        xlatb
        mov     dl, al
        mov     ah, 02h
        int     21h
        mov     ah, 02h
        mov     dl, 'h'
        int     21h
        mov     ah, 09h
        mov     dx, offset crlf
        int     21h
        jmp     progexit
errorexit:
        mov     ah, 09h
        mov     dx, offset errmsg
        int     21h
progexit:
        mov     ax, 4C00h
        int     21h
;Procedures
filefind proc
        push    ax
        push    cx
        mov     ah, 4Eh
        mov     cx, 0
        int     21h
        pop     cx
        pop     ax
        ret
filefind endp
;Data
buffer:
stnl            db 80h
stlen           db 0
filename        db 80h dup (0)
fhandle         dw 0
fsize           dw 0
msg1            db "File not found!", 13, 10, '$'
msg2            db "Enter file name: ", '$'
msg3            db "Entered file not found!", 13, 10, '$'
msg4            db "Minimum: ", '$'
crlf            db 13, 10 , '$'
digit           db "0123456789ABCDEF"
errmsg          db 'Fatal error!', 13, 10, '$'
array: ;Array of values be placed over the end our program
       ;There are a lot of place for small array
CodeSg  ends
        end     start
