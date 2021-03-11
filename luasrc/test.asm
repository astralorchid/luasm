org 0x7c00
bootsig 0x1FE
start:
    xor ax ax
    mov ds ax
    mov es ax
    mov ss ax
    xor bp bp
    xor sp sp
    mov si testChar
    dec si
    mov ah 0x0e
sprint:
    cmp [si], 0
    je endprint
    mov al [si]
    int 0x10
    inc si
    jmp sprint
endprint:
hlt

testChar db 'Hello world!', 0