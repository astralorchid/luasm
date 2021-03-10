org 0x7c00
bootsig 0x1FE
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    xor bp, bp
    xor sp, sp
    mov al, [testChar]
    mov ah, 0x0e
    int 0x10
hlt

testChar db 'E', 0