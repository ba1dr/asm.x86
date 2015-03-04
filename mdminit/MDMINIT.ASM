title   trying to talk with modem... :)
.186
model   compact
COM             equ 03F8h
IRQ             equ 0Ch
E_BITMASK       equ 11101111b
D_BITMASK       equ 00010000b

codesg  segment para 'code'
        assume  cs:codesg, ss:stacksg, ds:datasg, es:datasg
begin:
        mov     ax, datasg
        mov     ds, ax
        cld
        call    scrcls
        mov     si, offset sayHello
        call    mdoutstr
        call    init_all
        cmp     mdready, 1
        je      ok_mdm_ready
        jmp     eterminate
ok_mdm_ready:

exiter:
        call    restor
eterminate:
        mov     ax, 4C00h
        int     21h

handlers        dw      offset line_h, offset trans_h
                dw      offset recv_h, offset modem_h

irqer   proc far
        pusha           ; сохранить регистры
        mov     dx, COM+2        ; прочитать регистр идентификации
        in      al, dx           ; прерывания
repeat_handler:
        and     ax, 00000110b ; обнулить все биты, кроме 1 и 2,
        mov     di, ax           ; отвечающие за 4 основные ситуации
        call    word ptr cs:handlers[di] ; косвенный вызов процедуры
                                        ; для обработки ситуации
        mov     dx, COM+2        ; еще раз прочитать регистр идентификации
        in      al, dx           ; прерывания,
        test    al, 1            ; если младший бит не 1,
        jz      repeat_handler  ; надо обработать еще одно прерывание,
        mov     al, 20h  ; иначе - завершить аппаратное прерывание
        out     20h, al  ; посылкой команды EOI (см. 1.2.10)
        popa
        iret
; эта процедура вызывается при изменении состояния линии
line_h  proc    near
        mov     dx,COM+5        ; пока не будет прочитан LSR,
        in      al,dx           ; прерывание не считается завершившимся
; здесь можно проверить, что случилось, и, например, прервать связь, если
; обнаружено состояние BREAK
        ret
line_h  endp
; эта процедура вызывается при приеме новых данных
recv_h  proc    near
        mov     dx,COM  ; пока не будет прочитан RBR,
        in      al,dx           ; прерывание не считается завершившимся
; здесь следует поместить принятый байт в буфер приема для основной программы,
; но мы просто сразу выведем его на экран
        int     29h     ; вывод на экран
        ret
recv_h  endp
; эта процедура вызывается по окончании передачи данных
trans_h proc    near
; здесь следует записать в THR следующий символ из буфера передачи и, если
; буфер после этого оказывается пустым - запретить этот тип прерывания
        ret
trans_h endp
; эта процедура вызывается при изменении состояния модема
modem_h proc    near
        mov     dx,COM+6        ; пока MCR не будет прочитан,
        in      al,dx           ; прерывание не считается завершившимся
; здесь можно определить состояние звонка и поднять трубку, определить
; потерю несущей и перезвонить, и т. д.
        ret
modem_h endp
irqer   endp

init_all proc
        mov     si, IRQ
        xor     ax, ax
        mov     ds, ax
        mov     di, offset oldIRQ
        mov     ax, seg @data
        mov     es, ax
        movsw
        movsw
        mov     di, IRQ
        xor     ax, ax
        mov     es, ax
        mov     ax, offset irqer
        cli
        stosw
        mov     ax, cs
        stosw
        sti
        mov     ax, seg @data
        mov     ds, ax ; Прерывание установлено
        mov     dx, COM+1
        mov     al, 0
        out     dx, al
        mov     dx, COM+4
        out     dx, al
        mov     dx, COM+5        ; и выполнить чтение из LSR,
        in      al, dx
        mov     dx, COM+0        ; из RBR
        in      al, dx
        mov     dx, COM+6        ; и из MSR,
        in      al, dx           ; на тот случай, если они недавно изменялись,
        mov     dx, COM+2        ; а также послать 0 в регистр FCR,
        mov     al, 0            ; чтобы выключить FIFO
        out     dx, al

; установка скорости COM-порта
        mov     dx, COM+3        ; записать в регистр LCR
        mov     al, 80h  ; любое число со старшим битом 1
        out     dx, al
        mov     dx, COM+0        ; теперь записать в регистр DLL
        mov     al, 2            ; младший байт делителя скорости,
        out     dx, al
        mov     dx, COM+1        ; а в DLH -
        mov     al, 0            ; старший байт
        out     dx, al           ; (мы записали 0002h - скорость порта 57 600)

; инициализация линии
        mov     dx, COM+3        ; записать теперь в LCR
        mov     al, 0011b        ; число, соответствующее режиму 8N1
        out     dx, al           ; (наиболее часто используемому)
; инициализация модема
        mov     dx, COM+4        ; записать в регистр MCR
        mov     al, 1011b        ; битовую маску, активирующую DTR, RTS
        out     dx, al           ; и OUT2

; здесь следует выполнить проверку на наличие модема на этом порту (читать
; регистр MSR, пока не будут установлены линии CTS и DSR или не кончится время),
; а затем послать в модем (то есть поместить в буфер передачи) инициализирующую
; строку, например 'ATZ',0Dh

        push    es
        mov     ax, 0B800h
        mov     es, ax
        mov     ah, 07h
        xor     bx, bx

secwait: ; Ждем, чтобы текущая секунда была <30
        mov     dx, 70h
        mov     al, 00h
        out     dx, al
        inc     dx
        in      al, dx ; Берем текущую секунду
        mov     cx, ax
comment `
        mov     di, 160
        mov     si, offset hextbl
        push    si
        mov     bl, al
        and     bl, 0F0h
        shr     bl, 4
        add     si, bx
        mov     al, byte ptr [si]
        stosw
        mov     bl, cl
        and     bl, 0Fh
        pop     si
        add     si, bx
        mov     al, byte ptr [si]
        stosw
`
        cmp     cl, 30h
        ja      secwait
        pop     es
        mov     bx, cx
        add     bl, 15h
chkmdm:
        mov     dx, COM+6
        in      al, dx
        and     al, 00110000b
        cmp     al, 00110000b
        je      ok_ready
        mov     dx, 70h
        mov     al, 00h
        out     dx, al
        inc     dx
        in      al, dx ; Берем текущую секунду
        cmp     al, bl
        jae     mdmtimeout
        jmp     chkmdm
mdmtimeout: ; Модем не готов
        mov     mdready, 0
; разрешение прерываний
        mov     dx, COM+1        ; записать в IER - битовую маску, разрешающую
        mov     al, 1101b        ; все прерывания, кроме "регистр передачи пуст"
        out     dx, al
        in      al, 21h          ; прочитать OCW1 (см. 1.2.10)
        and     al, E_BITMASK    ; размаскировать прерывание
        out     21h, al          ; записать OCW1
        call    restor
        add     word ptr cs:mycursorpos, 160
        mov     si, offset mdm_failed
        call    mdoutstr
        ret
ok_ready: ; Модем готов
        mov     mdready, 1
        mov     dx, COM
        mov     al, 'A'
        out     dx, al
        mov     al, 'T'
        out     dx, al
        mov     al, 'Z'
        out     dx, al
        mov     al, 0Dh
        out     dx, al
; разрешение прерываний
        mov     dx, COM+1        ; записать в IER - битовую маску, разрешающую
        mov     al, 1101b        ; все прерывания, кроме "регистр передачи пуст"
        out     dx, al
        in      al, 21h          ; прочитать OCW1 (см. 1.2.10)
        and     al, E_BITMASK    ; размаскировать прерывание
        out     21h, al          ; записать OCW1
        add     word ptr cs:mycursorpos, 160
        mov     si, offset mdm_is_ready
        call    mdoutstr
        ret
init_all endp

restor  proc
        ; запрещение прерываний
        in      al, 21h          ; прочитать OCW1
        or      al, D_BITMASK    ; замаскировать прерывание
        out     21h, al          ; записать OCW1
        mov     dx, COM+1        ; записать в регистр IER
        mov     al, 0            ; ноль
        out     dx, al
; сброс линий модема DTR и CTS
        mov     dx, COM+4        ; записать в регистр MCR
        mov     al, 0            ; ноль
        out     dx, al
        mov     di, IRQ
        xor     ax, ax
        mov     es, ax
        mov     si, offset oldIRQ
        cli
        movsw
        movsw
        sti
        ret
restor  endp

mycursorpos     dw 0

scrcls  proc
        push    ax
        push    cx
        push    es
        push    di
        mov     ax, 0B800h
        mov     es, ax
        xor     di, di
        mov     ax, 0720h
        mov     cx, 80*25
        rep     stosw
        mov     word ptr cs:mycursorpos, 0
        pop     di
        pop     es
        pop     cx
        pop     ax
        ret
scrcls  endp

mdoutstr proc
        push    es
        push    di
        push    ax
        mov     ax, 0B800h
        mov     es, ax
        mov     di, cs:mycursorpos
        mov     ah, 07h
nextout:
        lodsb
        and     al, al
        jz      out_end
        stosw
        jmp     nextout
out_end:
        pop     ax
        pop     di
        pop     es
        ret
mdoutstr endp

codesg  ends

stacksg segment para stack 'stack'
                dw 100h dup(?)
stacksg ends

datasg  segment para 'data'

sayHello        db "Initializing modem...", 0
pleasewait      db "Please wait...", 0
mdm_is_ready    db "Modem is ready.", 0
mdm_failed      db "Modem is not ready.", 0

hextbl          db "0123456789ABCDEF"

oldIRQ          dd 0
mdready         db 0
connected       db 0

datasg  ends
end     begin
