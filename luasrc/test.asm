xor ax, ax
mov byte [0xb800], 0x65
mov al, byte [0x6665]
segments:
	mov ds, ax
	mov es, ax
	mov cx, start

start:
	mov word [start], segments