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
        pusha           ; ��࠭��� ॣ�����
        mov     dx, COM+2        ; ������ ॣ���� �����䨪�樨
        in      al, dx           ; ���뢠���
repeat_handler:
        and     ax, 00000110b ; ���㫨�� �� ����, �஬� 1 � 2,
        mov     di, ax           ; �⢥��騥 �� 4 �᭮��� ���樨
        call    word ptr cs:handlers[di] ; ��ᢥ��� �맮� ��楤���
                                        ; ��� ��ࠡ�⪨ ���樨
        mov     dx, COM+2        ; �� ࠧ ������ ॣ���� �����䨪�樨
        in      al, dx           ; ���뢠���,
        test    al, 1            ; �᫨ ����訩 ��� �� 1,
        jz      repeat_handler  ; ���� ��ࠡ���� �� ���� ���뢠���,
        mov     al, 20h  ; ���� - �������� �����⭮� ���뢠���
        out     20h, al  ; ���뫪�� ������� EOI (�. 1.2.10)
        popa
        iret
; �� ��楤�� ��뢠���� �� ��������� ���ﭨ� �����
line_h  proc    near
        mov     dx,COM+5        ; ���� �� �㤥� ���⠭ LSR,
        in      al,dx           ; ���뢠��� �� ��⠥��� �����訢訬��
; ����� ����� �஢����, �� ��稫���, �, ���ਬ��, ��ࢠ�� ���, �᫨
; �����㦥�� ���ﭨ� BREAK
        ret
line_h  endp
; �� ��楤�� ��뢠���� �� �ਥ�� ����� ������
recv_h  proc    near
        mov     dx,COM  ; ���� �� �㤥� ���⠭ RBR,
        in      al,dx           ; ���뢠��� �� ��⠥��� �����訢訬��
; ����� ᫥��� �������� �ਭ��� ���� � ���� �ਥ�� ��� �᭮���� �ணࠬ��,
; �� �� ���� �ࠧ� �뢥��� ��� �� ��࠭
        int     29h     ; �뢮� �� ��࠭
        ret
recv_h  endp
; �� ��楤�� ��뢠���� �� ����砭�� ��।�� ������
trans_h proc    near
; ����� ᫥��� ������� � THR ᫥���騩 ᨬ��� �� ���� ��।�� �, �᫨
; ���� ��᫥ �⮣� ����뢠���� ����� - ������� ��� ⨯ ���뢠���
        ret
trans_h endp
; �� ��楤�� ��뢠���� �� ��������� ���ﭨ� ������
modem_h proc    near
        mov     dx,COM+6        ; ���� MCR �� �㤥� ���⠭,
        in      al,dx           ; ���뢠��� �� ��⠥��� �����訢訬��
; ����� ����� ��।����� ���ﭨ� ������ � ������� ��㡪�, ��।�����
; ����� ����饩 � ��१������, � �. �.
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
        mov     ds, ax ; ���뢠��� ��⠭������
        mov     dx, COM+1
        mov     al, 0
        out     dx, al
        mov     dx, COM+4
        out     dx, al
        mov     dx, COM+5        ; � �믮����� �⥭�� �� LSR,
        in      al, dx
        mov     dx, COM+0        ; �� RBR
        in      al, dx
        mov     dx, COM+6        ; � �� MSR,
        in      al, dx           ; �� �� ��砩, �᫨ ��� ������� �����﫨��,
        mov     dx, COM+2        ; � ⠪�� ��᫠�� 0 � ॣ���� FCR,
        mov     al, 0            ; �⮡� �몫���� FIFO
        out     dx, al

; ��⠭���� ᪮��� COM-����
        mov     dx, COM+3        ; ������� � ॣ���� LCR
        mov     al, 80h  ; �� �᫮ � ���訬 ��⮬ 1
        out     dx, al
        mov     dx, COM+0        ; ⥯��� ������� � ॣ���� DLL
        mov     al, 2            ; ����訩 ���� ����⥫� ᪮���,
        out     dx, al
        mov     dx, COM+1        ; � � DLH -
        mov     al, 0            ; ���訩 ����
        out     dx, al           ; (�� ����ᠫ� 0002h - ᪮���� ���� 57 600)

; ���樠������ �����
        mov     dx, COM+3        ; ������� ⥯��� � LCR
        mov     al, 0011b        ; �᫮, ᮮ⢥�����饥 ०��� 8N1
        out     dx, al           ; (�������� ��� �ᯮ��㥬���)
; ���樠������ ������
        mov     dx, COM+4        ; ������� � ॣ���� MCR
        mov     al, 1011b        ; ��⮢�� ����, ��⨢������� DTR, RTS
        out     dx, al           ; � OUT2

; ����� ᫥��� �믮����� �஢��� �� ����稥 ������ �� �⮬ ����� (����
; ॣ���� MSR, ���� �� ���� ��⠭������ ����� CTS � DSR ��� �� ������� �६�),
; � ��⥬ ��᫠�� � ����� (� ���� �������� � ���� ��।��) ���樠����������
; ��ப�, ���ਬ�� 'ATZ',0Dh

        push    es
        mov     ax, 0B800h
        mov     es, ax
        mov     ah, 07h
        xor     bx, bx

secwait: ; ����, �⮡� ⥪��� ᥪ㭤� �뫠 <30
        mov     dx, 70h
        mov     al, 00h
        out     dx, al
        inc     dx
        in      al, dx ; ��६ ⥪���� ᥪ㭤�
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
        in      al, dx ; ��६ ⥪���� ᥪ㭤�
        cmp     al, bl
        jae     mdmtimeout
        jmp     chkmdm
mdmtimeout: ; ����� �� ��⮢
        mov     mdready, 0
; ࠧ�襭�� ���뢠���
        mov     dx, COM+1        ; ������� � IER - ��⮢�� ����, ࠧ������
        mov     al, 1101b        ; �� ���뢠���, �஬� "ॣ���� ��।�� ����"
        out     dx, al
        in      al, 21h          ; ������ OCW1 (�. 1.2.10)
        and     al, E_BITMASK    ; ࠧ��᪨஢��� ���뢠���
        out     21h, al          ; ������� OCW1
        call    restor
        add     word ptr cs:mycursorpos, 160
        mov     si, offset mdm_failed
        call    mdoutstr
        ret
ok_ready: ; ����� ��⮢
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
; ࠧ�襭�� ���뢠���
        mov     dx, COM+1        ; ������� � IER - ��⮢�� ����, ࠧ������
        mov     al, 1101b        ; �� ���뢠���, �஬� "ॣ���� ��।�� ����"
        out     dx, al
        in      al, 21h          ; ������ OCW1 (�. 1.2.10)
        and     al, E_BITMASK    ; ࠧ��᪨஢��� ���뢠���
        out     21h, al          ; ������� OCW1
        add     word ptr cs:mycursorpos, 160
        mov     si, offset mdm_is_ready
        call    mdoutstr
        ret
init_all endp

restor  proc
        ; ����饭�� ���뢠���
        in      al, 21h          ; ������ OCW1
        or      al, D_BITMASK    ; ����᪨஢��� ���뢠���
        out     21h, al          ; ������� OCW1
        mov     dx, COM+1        ; ������� � ॣ���� IER
        mov     al, 0            ; ����
        out     dx, al
; ��� ����� ������ DTR � CTS
        mov     dx, COM+4        ; ������� � ॣ���� MCR
        mov     al, 0            ; ����
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
