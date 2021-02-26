--[[for i,v in pairs(lines) do
	for o,b in pairs(v) do
	print(b)
	end
end]]
local luasm = require("luasm")
local argc, argv = getargs()
local content = fopen(argv)
local lines, mem_tokens = luasm.tokenize(content)
errors = luasm.assemble(lines, mem_tokens)

if #errors > 0 then
	for i,v in pairs(errors) do
	print("luasm:"..argv..":"..v[2]..":".." "..v[1])
	end
end
--[[binalloc(4)
writebyte(tonumber("0x10"))
writebyte(tonumber("0xFF"))
writebyte(tonumber("0xDE"))
writebyte(tonumber("0xAD"))
makebin("hello.bin")]]