--[[for i,v in pairs(lines) do
	for o,b in pairs(v) do
	print(b)
	end
end]]
local luasm = require("luasm")
local argc, argv = getargs()
local file = io.open(argv, "r")
local content = file:read("*a")
local content = string.split(content)

local strFlag --replace spaces in string literals with 0xFF
for i,v in pairs(content) do
	if v == "'" or v == '"' then
		if strFlag and strFlag == v then
			strFlag = nil
		else
			strFlag = v
		end
	end
	if v == string.char(9) then
		content[i] = string.char(32)
	end
	if v == " " and strFlag then
		content[i] = string.char(0xFF)
	end
end

content = table.concat(content)
--local content = fopen(argv)
local errors = {}
local lines, mem_tokens, errors = luasm.tokenize(content, errors)
local errors, outputbin = luasm.assemble(lines, mem_tokens, errors)

if errors and #errors > 0 then
	for i,v in pairs(errors) do
	print("luasm:"..argv..":"..v[2]..":".." "..v[1])
	end
end

	local binStr = ""
	for bini, binv in pairs(outputbin) do
		if binv then
			local hex = string.format("%x", binv)
			if string.len(hex) == 1 then
				hex = "0"..hex
			end
			binStr = binStr..hex.." "
		end
	end
	print(binStr)	
binalloc(#outputbin)
for i,v in pairs(outputbin) do
		writebyte(v)
end
makebin("hello.bin")