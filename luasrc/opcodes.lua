local opcodes = {
["add r8 r8 "] = 0x0,
["add mimm r8 "] = 0x0,
["add r16 r16 "] = 0x1,
["add mimm r16 "] = 0x1,
["add mr16 r16 "] = 0x1,
["add r32 r32 "] = 0x1,
["add mimm r32 "] = 0x1,
["add mr32 r32 "] = 0x1,
["add r8 mimm "] = 0x2,
["add r8 mr16 "] = 0x2,
["add r8 mr32 "] = 0x2,
["add r16 mimm "] = 0x3,
["add r32 mimm "] = 0x3,
["add r16 mr16 "] = 0x3,
["add r16 mr32 "] = 0x3,
["add r32 mr16 "] = 0x3,
["add r32 mr32 "] = 0x3,


["or r8 r8 "] = 0x08,
["or mimm r8 "] = 0x08,
["or r16 r16 "] = 0x09,
["or mimm r16 "] = 0x9,
["or mr16 r16 "] = 0x9,
["or r32 r32 "] = 0x09,
["or mimm r32"] = 0x9,
["or mr32 r32"] = 0x9,
["or r8 mimm "] = 0xA,
["or r8 mr16 "] = 0xA,
["or r8 mr32 "] = 0xA,

["or r16 mimm "] = 0xB,
["or r32 mimm "] = 0xB,
["or r16 mr16 "] = 0xB,
["or r16 mr32 "] = 0xB,
["or r32 mr16 "] = 0xB,
["or r32 mr32 "] = 0xB,

["adc r8 r8 "] = 0x10,
["adc mimm r8 "] = 0x10,
["adc r16 r16 "] = 0x11,
["adc mimm r16 "] = 0x11,
["adc mr16 r16 "] = 0x11,
["adc r32 r32 "] = 0x11,
["adc mimm r32 "] = 0x11,
["adc mr32 r32 "] = 0x11,
["adc r8 mimm "] = 0x12,
["adc r8 mr16 "] = 0x12,
["adc r8 mr32 "] = 0x12,
["adc r16 mimm "] = 0x13,
["adc r32 mimm "] = 0x13,
["adc r16 mr16 "] = 0x13,
["adc r16 mr32 "] = 0x13,
["adc r32 mr16 "] = 0x13,
["adc r32 mr32 "] = 0x13,

["sbb r8 r8 "] = 0x18,
["sbb mimm r8 "] = 0x18,
["sbb r16 r16 "] = 0x19,
["sbb mimm r16 "] = 0x19,
["sbb mr16 r16 "] = 0x19,
["sbb r32 r32 "] = 0x19,
["sbb mimm r32 "] = 0x19,
["sbb mr32 r32 "] = 0x19,
["sbb r8 mimm "] = 0x1A,
["sbb r8 mr16 "] = 0x1A,
["sbb r8 mr32 "] = 0x1A,
["sbb r16 mimm "] = 0x1B,
["sbb r32 mimm "] = 0x1B,
["sbb r16 mr16 "] = 0x1B,
["sbb r16 mr32 "] = 0x1B,
["sbb r32 mr16 "] = 0x1B,
["sbb r32 mr32 "] = 0x1B,

["and r8 r8 "] = 0x20,
["and mimm r8 "] = 0x20,
["and r16 r16 "] = 0x21,
["and mimm r16 "] = 0x21,
["and mr16 r16 "] = 0x21,
["and r32 r32 "] = 0x21,
["and mimm r32 "] = 0x21,
["and mr32 r32 "] = 0x21,
["and r8 mimm "] = 0x22,
["and r8 mr16 "] = 0x22,
["and r8 mr32 "] = 0x22,
["and r16 mimm "] = 0x23,
["and r32 mimm "] = 0x23,
["and r16 mr16 "] = 0x23,
["and r16 mr32 "] = 0x23,
["and r32 mr16 "] = 0x23,
["and r32 mr32 "] = 0x23,

["sub r8 r8 "] = 0x28,
["sub mimm r8 "] = 0x28,
["sub r16 r16 "] = 0x29,
["sub mimm r16 "] = 0x29,
["sub mr16 r16 "] = 0x29,
["sub r32 r32 "] = 0x29,
["sub mimm r32 "] = 0x29,
["sub mr32 r32 "] = 0x29,
["sub r8 mimm "] = 0x2A,
["sub r8 mr16 "] = 0x2A,
["sub r8 mr32 "] = 0x2A,
["sub r16 mimm "] = 0x2B,
["sub r32 mimm "] = 0x2B,
["sub r16 mr16 "] = 0x2B,
["sub r16 mr32 "] = 0x2B,
["sub r32 mr16 "] = 0x2B,
["sub r32 mr32 "] = 0x2B,

["xor r8 r8 "] = 0x30,
["xor mimm r8 "] = 0x30,
["xor r16 r16 "] = 0x31,
["xor mimm r16 "] = 0x31,
["xor mr16 r16 "] = 0x31,
["xor r32 r32 "] = 0x31,
["xor mimm r32 "] = 0x31,
["xor mr32 r32 "] = 0x31,
["xor r8 mimm "] = 0x32,
["xor r8 mr16 "] = 0x32,
["xor r8 mr32 "] = 0x32,
["xor r16 mimm "] = 0x33,
["xor r32 mimm "] = 0x33,
["xor r16 mr16 "] = 0x33,
["xor r16 mr32 "] = 0x33,
["xor r32 mr16 "] = 0x33,
["xor r32 mr32 "] = 0x33,

["cmp r8 r8 "] = 0x38,
["cmp mimm r8 "] = 0x38,
["cmp r16 r16 "] = 0x39,
["cmp mimm r16 "] = 0x39,
["cmp mr16 r16 "] = 0x39,
["cmp r32 r32 "] = 0x39,
["cmp mimm r32 "] = 0x39,
["cmp mr32 r32 "] = 0x39,
["cmp r8 mimm "] = 0x3A,
["cmp r8 mr16 "] = 0x3A,
["cmp r8 mr32 "] = 0x3A,
["cmp r16 mimm "] = 0x3B,
["cmp r32 mimm "] = 0x3B,
["cmp r16 mr16 "] = 0x3B,
["cmp r16 mr32 "] = 0x3B,
["cmp r32 mr16 "] = 0x3B,
["cmp r32 mr32 "] = 0x3B,

["test r8 r8 "] = 0x84,
["test mimm r8 "] = 0x84,
["test r16 r16 "] = 0x85,
["test mimm r16 "] = 0x85,
["test mr16 r16 "] = 0x85,
["test r32 r32 "] = 0x85,
["test mimm r32 "] = 0x85,
["test mr32 r32 "] = 0x85,

["xchg r8 r8 "] = 0x86,
["xchg r8 mimm "] = 0x86,
["xchg r16 r16 "] = 0x87,
["xchg r16 mimm "] = 0x87,
["xchg r16 mr16 "] = 0x87,
["xchg r32 r32 "] = 0x87,
["xchg r32 mimm "] = 0x87,
["xchg r32 mr32 "] = 0x87,

["mov r8 r8 "] = 0x88,
["mov mimm r8 "] = 0x88,
["mov r16 r16 "] = 0x89,
["mov mimm r16 "] = 0x89,
["mov mr16 r16 "] = 0x89,
["mov r32 r32 "] = 0x89,
["mov mimm r32 "] = 0x89,
["mov mr32 r32 "] = 0x89,
["mov r8 mimm "] = 0x8A,
["mov r16 mimm "] = 0x8B,
["mov r32 mimm "] = 0x8B,
["mov r8 mr16 "] = 0x8A,
["mov r8 mr32 "] = 0x8A,
["mov r16 mr16 "] = 0x8B,
["mov r32 mr32"] = 0x8B,

["mov mimm sreg "] = 0x8C,
["mov mr16 sreg "] = 0x8C,
["mov r16 sreg "] = 0x8C,
["mov r32 sreg "] = 0x8C,
["mov mr32 sreg "] = 0x8C,

["lea r16 mimm "] = 0x8D,
["lea r32 mimm "] = 0x8D,
["lea r16 mr16 "] = 0x8D,
["lea r32 mr32 "] = 0x8D,

["mov sreg r16 "] = 0x8E,
["mov sreg mimm "] = 0x8E,
["mov sreg r32 "] = 0x8E,
["mov sreg mr32 "] = 0x8E,
["mov sreg mr16 "] = 0x8E,

["mov r8 imm "] = 0xB0,
["mov r16 imm "] = 0xB8,
["mov r32 imm "] = 0xB8,

["mov mimm imm "] = 0xC6,
["mov mr16 imm "] = 0xC6,
["mov mr32 imm "] = 0xC6,

["add r8 imm "] = 0x80,
["add mimm imm "] = 0x80,
["or r8 imm "] = 0x80,
["or mimm imm "] = 0x80,
["adc r8 imm "] = 0x80,
["adc mimm imm "] = 0x80,
["sbb r8 imm "] = 0x80,
["sbb mimm imm "] = 0x80,
["and r8 imm "] = 0x80,
["and mimm imm "] = 0x80,
["sub r8 imm "] = 0x80,
["sub mimm imm "] = 0x80,
["xor r8 imm "] = 0x80,
["xor mimm imm "] = 0x80,
["cmp r8 imm "] = 0x80,
["cmp mimm imm "] = 0x80,

["add r16 imm "] = 0x81,
["add mr16 imm "] = 0x81,
["or r16 imm "] = 0x81,
["or mr16 imm "] = 0x81,
["adc r16 imm "] = 0x81,
["adc mr16 imm "] = 0x81,
["sbb r16 imm "] = 0x81,
["sbb mr16 imm "] = 0x81,
["and r16 imm "] = 0x81,
["and mr16 imm "] = 0x81,
["sub r16 imm "] = 0x81,
["sub mr16 imm "] = 0x81,
["xor r16 imm "] = 0x81,
["xor mr16 imm "] = 0x81,
["cmp r16 imm "] = 0x81,
["cmp mr16 imm "] = 0x81,

["int imm "] = 0xCD,

["push sreg "] = 0x0,
["pop sreg"] = 0x0,

["inc r16 "] = 0x40,
["inc r32 "] = 0x40,
["dec r16 "] = 0x48,
["dec r32 "] = 0x48,

["push r16 "] = 0x50,
["push r32 "] = 0x50,
["pop r16 "] = 0x58,
["pop r32 "] = 0x58,

["push imm "] = 0x68,

["jo imm "] = 0x70,
["jno imm "] = 0x71,
["jb imm "] = 0x72,
["jnae imm "] = 0x72,
["jc imm "] = 0x72,
["jnb imm "] = 0x73,
["jae imm "] = 0x73,
["jnc imm "] = 0x73,
["jz imm "] = 0x74,
["je imm "] = 0x74,
["jnz imm "] = 0x75,
["jne imm "] = 0x75,
["jbe imm "] = 0x76,
["jna imm "] = 0x76,
["jnbe imm "] = 0x77,
["ja imm "] = 0x77,
["js imm "] = 0x78,
["jns imm "] = 0x79,
["jp imm "] = 0x7A,
["jpe imm "] = 0x7A,
["jnp imm "] = 0x7B,
["jpo imm "] = 0x7B,
["jl imm "] = 0x7C,
["jnge imm "] = 0x7C,
["jnl imm "] = 0x7D,
["jge imm "] = 0x7D,
["jle imm "] = 0x7E,
["jng imm "] = 0x7E,
["jnle imm "] = 0x7F,
["jg imm "] = 0x7F,

["nop "] = 0x90,
["wait "] = 0x9B,
["retn "] = 0xC3,
["ret "] = 0xC3,
["retf "] = 0xcB,
["hlt "] = 0xF4,
["cmc "] = 0xF5,
["clc "] = 0xF8,
["stc "] = 0xF9,
["cli "] = 0xFA,
["sti "] = 0xFB,
["cld "] = 0xFC,
["std "] = 0xFD,
["iret "] = 0xCF,
["iretd "] = 0xCF,

["movsb "] = 0xA4,
["movsw "] = 0xA5,
["movsd "] = 0xA5,
["cmpsb "] = 0xA6,
["cmpsw "] = 0xA7,
["cmpsd "] = 0xA7,
["lodsb "] = 0xAC,
["lodsw "] = 0xAD,
["lodsd "] = 0xAD,
["scasb "] = 0xAE,
["scasw "] = 0xAF,
["scasd "] = 0xAF,
}

return opcodes