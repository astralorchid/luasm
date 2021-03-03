--[[for i,v in pairs(lines) do
	for o,b in pairs(v) do
	print(b)
	end
end]]
local luasm = require("luasm")
local argc, argv = getargs()
local file = io.open(argv, "r")
local content = file:read("*a")
--local content = fopen(argv)
local errors = {}
local lines, mem_tokens, errors = luasm.tokenize(content, errors)
local errors, outputbin = luasm.assemble(lines, mem_tokens, errors)

if #errors > 0 then
	for i,v in pairs(errors) do
	print("luasm:"..argv..":"..v[2]..":".." "..v[1])
	end
end
--[[binalloc(#outputbin)
for i,v in pairs(outputbin) do
	writebyte(v)
end
makebin("hello.bin")]]