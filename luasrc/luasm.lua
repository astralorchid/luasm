local luasm = {}
luasm.RETURN_CHAR = string.char(10)
luasm.SPACE_CHAR = " "
luasm.UNDERSCORE_CHAR = "_"

luasm.TOKEN = {
	mov = "OP_MOV",
	add = "OP_ADD",
	sub = "OP_SUB",
	
	ax = "REG_AX",
	cx = "REG_CX",
	bx = "REG_BX",
	dx = "REG_DX",
	al = "REG_AL",
	cl = "REG_CL",
	bl = "REG_BL",
	dl = "REG_DL",
	ah = "REG_AH",
	ch = "REG_CH",
	bh = "REG_BH",
	dh = "REG_DH",

}

luasm.ILLEGAL_INST_FORMAT = {
	["OP IMM IMM"] = true,
	["OP IMM REG"] = true,
}
function luasm.removeComma(b) --b is a token 
	if string.len(b) > 1 then --remove commas
		if string.sub(b,1,1) == "," or string.byte(string.sub(b,1,1)) == 9 then
			b = string.sub(b,2,string.len(b))
		end
		if string.sub(b,string.len(b),string.len(b)) == "," or string.byte(string.sub(b,1,1)) == 9 then
			b = string.sub(b,1,string.len(b)-1)
		end
	end
	return b
end

function luasm.checkMem(b)
		if string.sub(b,1,1) == "[" then
			b = string.sub(b,2,string.len(b))
			if string.sub(b,string.len(b),string.len(b)) == "]" then
				b = string.sub(b,1,string.len(b)-1)
				return b, false
			else
				return b, true
			end
		end
		if string.sub(b,string.len(b),string.len(b)) == "]" then
			b = string.sub(b,1,string.len(b)-1)
			return b, false
		end
		return b, nil
end

function setMemToken(mem_tokens, i, o, offset)
	if mem_tokens[i] == nil then
		mem_tokens[i] = {}
		mem_tokens[i][o-offset] = true
	else
		mem_tokens[i][o-offset] = true
	end
end

function luasm.tokenize(inputString)
	local lines = {}
	local mem_tokens = {}
	local mem_flag = false

	local offset = 0 --helps remove nil indices if throwing away tokens
	local inputStringLines = string.split(inputString, luasm.RETURN_CHAR)
	
	for i,v in pairs(inputStringLines) do
		lines[i] = {}
		local inputStringTokens = string.split(v, luasm.SPACE_CHAR)
		for o,b in pairs(inputStringTokens) do

			b = luasm.removeComma(b)

			if b == "," or b == " " or string.byte(b) == 10 or string.byte(b) == 9 or b == nil or b == ""  then
				offset = offset + 1
			elseif b == "[" then
				offset = offset + 1
				mem_flag = true
			elseif b == "]" then
				offset = offset + 1
				mem_flag = false
			else
				local b, mem_flag_update, mem_token = luasm.checkMem(b)
				if mem_flag_update == nil then
					if mem_flag == true then
						setMemToken(mem_tokens, i, o, offset)
					end
				else
					mem_flag = mem_flag_update
					setMemToken(mem_tokens, i, o, offset)
				end

				lines[i][o-offset] = b
			end

		end
	end
	
	return lines, mem_tokens
end

function luasm:FindToken(token)
	local lowerToken = string.lower(token)
	
	for k,v in pairs(self.TOKEN) do
		if k == lowerToken then
			local tokenType = string.split(v, luasm.UNDERSCORE_CHAR)
			return v, tokenType[1]
		end
	end
	
	local tokenImmediate = tonumber(token)
	
	if tokenImmediate then
		return tokenImmediate, "IMM"
	end
	
	return nil, "Unrecognized label"
end

function luasm.ParseTokens(lines, mem_tokens)
	local errors = {}
	local imm = nil
	for i,line in pairs(lines) do
		local instFormat = ""
		local proper = false
		local operands = 0
		local opcodes = 0
		for b = 1,#line do
			local token, tokenType = luasm:FindToken(line[b])
			if token then
				if mem_tokens[i] and mem_tokens[i][b] then
					tokenType = "mem"..tokenType
				end

				instFormat = instFormat..tokenType.." "
				
				if tokenType == "OP" then
					opcodes = opcodes + 1
				end
				
				proper = true
			else
				table.insert(errors, {tokenType, i})
				proper = false
				break
			end
			
		end
		--print(instFormat)
		if opcodes > 1 then
			table.insert(errors, {"Invalid instruction format", i})
			break	
		end
		
		local instFormatLen = string.len(instFormat)
		instFormat = string.sub(instFormat,2,instFormatLen)
		
		if luasm.ILLEGAL_INST_FORMAT[instFormat] then
			table.insert(errors, {"Invalid instruction format", i})
			break
		end
	end
	
	return errors
end

return luasm
