local tokens = {
	al = "r8",
	bl = "r8",
	cl = "r8",
	dl = "r8",

	ah = "r8",
	bh = "r8",
	ch = "r8",
	dh = "r8",

	ax = "r16",
	bx = "r16",
	cx = "r16",
	dx = "r16",

	si = "r16",
	di = "r16",
	bp = "r16",
	sp = "r16",

	eax = "r32",
	ebx = "r32",
	ecx = "r32",
	edx = "r32",

	esi = "r32",
	edi = "r32",
	ebp = "r32",
	esp = "r32",

	mov = "mov",
	add = "add",

	["+"] = "+",

	byte = "size",
	word = "size",
	dword = "size"

}

return tokens