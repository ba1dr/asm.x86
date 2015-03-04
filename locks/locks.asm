Title	Программа для гашения/зажигания	индикаторов
Codesg	SEGMENT	Para 'CODE'
ASSUME	cs:Codesg,ds:Codesg,es:Biosin
	ORG	100h
Begin:
;	Вывод справки
	mov	ah,03h
	mov	bh,0h
	int	10h
	mov	ch,0h
	mov	ah,13h
	mov	bl,0Dh
	push	ds
	pop	es
	mov	bp,OFFSET St1
	mov	cl,2Ch
	int	10h
	inc	dh
	mov	cl,10h
	mov	bl,0Eh
	mov	bp,OFFSET St2
	int	10h
	inc	dh
	mov	bl,0Bh
;	 INC	 CX
	mov	bp,OFFSET St3
	int	10h
	mov	bp,OFFSET St4
	inc	dh
	mov	bl,9h
	mov	cl,39h
	int	10h
	mov	ax,Biosin
	mov	es,ax
	mov	bl,82h
	mov	ah,[bx]
	sub	ah,30h
	shl	ah,5h
	mov	al,0DFh
	call	Setbt
	shl	ah,6h
	mov	al,0BFh
	call	Setbt
	shl	ah,4h
	mov	al,0EFh
	call	Setbt
Exitr:
	ret
St1		DB ' Программа для зажигания/гашения индикаторов'
St2		DB '  Использование:'
St3		DB '   Locks.com NCS'
St4		DB '   где NCS - требуемое состояние всех индикаторов (0 - 1)'
Setbt	PROC
	cmp	ah,0
	je	Nulpr
	or	Kbd,ah
	jmp	Ender
Nulpr:
	and	Kbd,al
Ender:
	inc	bx
	mov	ah,[bx]
	sub	ah,30h
	ret
Setbt	ENDP
Copyright	DB 'Copyright 2000 by Kolyanov Alexey'
Codesg	ENDS
Biosin	SEGMENT	At 0040h
	ORG	17h
Kbd		DB ?
Biosin	ENDS
END	Begin
