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
["add r16 mimm "] = 0x3,
["add r32 mimm "] = 0x3,
["add r16 mr16"] = 0x3,
["add r32 mr32"] = 0x3,

["or r8 r8 "] = 0x08,
["or mimm r8 "] = 0x08,
["or r16 r16 "] = 0x09,
["or mimm r16 "] = 0x9,
["or mr16 r16 "] = 0x9,
["or r32 r32 "] = 0x09,
["or mimm r32"] = 0x9,
["or mr32 r32"] = 0x9,
["or r8 mimm "] = 0xA,
["or r16 mimm "] = 0xB,
["or r32 mimm "] = 0xB,
["or r16 mr16 "] = 0xB,
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
["adc r16 mimm "] = 0x13,
["adc r32 mimm "] = 0x13,
["adc r16 mr16 "] = 0x13,
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
["sbb r16 mimm "] = 0x1B,
["sbb r32 mimm "] = 0x1B,
["sbb r16 mr16 "] = 0x1B,
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
["and r16 mimm "] = 0x23,
["and r32 mimm "] = 0x23,
["and r16 mr16 "] = 0x23,
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
["sub r16 mimm "] = 0x2B,
["sub r32 mimm "] = 0x2B,
["sub r16 mr16 "] = 0x2B,
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
["xor r16 mimm "] = 0x33,
["xor r32 mimm "] = 0x33,
["xor r16 mr16 "] = 0x33,
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
["cmp r16 mimm "] = 0x3B,
["cmp r32 mimm "] = 0x3B,
["cmp r16 mr16 "] = 0x3B,
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
["mov mr32 imm "] = 0xC6
}

return opcodes