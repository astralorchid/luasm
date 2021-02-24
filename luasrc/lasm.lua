local luasm = require("luasm")
local argc, argv = getargs()
local content = fopen(argv)
	local lines, mem_tokens = luasm.tokenize(content)
	for i = 1,#lines do
		for b = 1,#lines[i] do
			print(lines[i][b])
		end
	end
	
	--local errors, bytecode = luasm.ParseTokens(lines, mem_tokens)
--[[binalloc(4)
writebyte(tonumber("0x10"))
writebyte(tonumber("0xFF"))
writebyte(tonumber("0xDE"))
writebyte(tonumber("0xAD"))
makebin("hello.bin")]]