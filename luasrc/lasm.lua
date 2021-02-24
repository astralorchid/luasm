
local luasm = require("luasm")
local argc, argv = getargs()
local content = fopen(argv)

local lines, mem_tokens = luasm.tokenize(content)
for i,v in pairs(lines) do
	for o,b in pairs(v) do
	print(b)
	end
end

local e = bit.OR(2,4)
print(e)
local errors, bytecode = luasm.ParseTokens(lines, mem_tokens)
--[[binalloc(4)
writebyte(tonumber("0x10"))
writebyte(tonumber("0xFF"))
writebyte(tonumber("0xDE"))
writebyte(tonumber("0xAD"))
makebin("hello.bin")]]