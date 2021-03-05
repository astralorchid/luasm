xor ax, ax
mov byte [0xb800], 0x65
segments:
	mov ds, ax
	mov es, ax
	mov cx, start

start:
	mov word [start], segments