start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    xor bp, bp
    xor sp, sp

    mov bx, testString
    mov ax, [bx]
    mov [0xb800], al
    hlt
testString db 'Hello World!', 0