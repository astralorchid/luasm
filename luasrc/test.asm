org 0x7c00
bootsig 0x1FE
start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    xor bp, bp
    xor sp, sp
    mov si, testChar2
    mov ah, 0x0e
sprint:
    cmp byte [si], 0
    je endprint
    mov al, [si]
    int 0x10
    inc si
    jmp sprint
endprint:
    mov si, testChar
sprint2:
    cmp byte [si], 0
    je end
    mov al, [si]
    int 0x10
    inc si
    jmp sprint2
end:
jmp end
testChar db 'Hello world!', 0
testChar2 db 'Another test', 0