local luasm = {}
luasm.SIZES = require("sizes")
luasm.TOKENS = require("tokens")
local OPCODES = require("opcodes")

luasm.RETURN_CHAR = string.char(10)
luasm.SPACE_CHAR = " "
luasm.UNDERSCORE_CHAR = "_"

function luasm.removeComma(b) --b is a token 
	if string.len(b) > 1 then --remove commas
	local first = string.sub(b,1,1)
		if first == "," or string.byte(first) == 9 then
			b = string.sub(b,2,string.len(b))
		end
		if string.sub(b,string.len(b),string.len(b)) == "," or string.byte(first) == 9 then
			b = string.sub(b,1,string.len(b)-1)
		end
	end
	return b
end

function luasm.getSize(token)
	for char, size in pairs(luasm.SIZES) do
		if token == char then
			return size
		end
	end
end

function luasm.checkMem(b)
	local bLen = string.len(b)
	local ss = string.sub
	if ss(b,1,1) == "[" then
		b = ss(b,2,bLen)
		bLen = string.len(b)
		if ss(b,bLen,bLen) == "]" then
			b = ss(b,1,bLen-1)
			return b, false
		else
			return b, true
		end
	end
	if ss(b,bLen,bLen) == "]" then
		b = ss(b,1,bLen-1)
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

	 --helps remove nil indices if throwing away tokens
	local inputStringLines = string.split(inputString, luasm.RETURN_CHAR)
	
	for i,v in pairs(inputStringLines) do
		local offset = 0
		lines[i] = {}

		if string.find(v, "+") then
			local express = string.split(v) --prepare arithmetic/modrm expressions
			local loopAgain = true
			while loopAgain do
				for index, char in pairs(express) do
					if char == "+" and express[index+1] and express[index-1] and (express[index+1] ~= " " or express[index-1] ~= " ") then
						if express[index+1] ~= " " then
							table.insert(express, index+1, " ")
						end
						if express[index-1] ~= " " then
							table.insert(express, index, " ")
						end
						loopAgain = true
						break
					else
						loopAgain = false
					end
				end
			end

			if express then
				v = table.concat(express)
			print(v)
		end
		end



		local vLen = string.len(v)
		if string.sub(v, vLen,vLen) == ":" then
			vLen = string.split(v)
			table.insert(vLen, #vLen, " ")
			v = table.concat(vLen)

		end

		local inputStringTokens = string.split(v, luasm.SPACE_CHAR)
		for o,b in pairs(inputStringTokens) do

			b = luasm.removeComma(b)

			if b == "," or b == " " or string.byte(b) == 10--[[ or string.byte(b) == 9]] or b == nil or b == "" then
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

				lines[i][(o-offset)] = b
				print(b.." | "..o-offset)
			end
		end
	end

	return lines, mem_tokens
end

function luasm:FindToken(token)
	local lowerToken = string.lower(token)
	
	for k,v in pairs(self.TOKENS) do
		if k == lowerToken then
			return k,v
		end
	end
	
	local tokenImmediate = tonumber(token)
	
	if tokenImmediate then
		return tokenImmediate, "imm"
	end

	return token, "lbl"

end

function luasm.assemble(lines, mem_tokens)
	local errors = {}
	local tokenizedLines = {}

	for i, line in pairs(lines) do
		local tokenizedLine = {}
		for b = 1,#line do
			local token, tokenType = luasm:FindToken(line[b])
			if token then
				if mem_tokens[i] and mem_tokens[i][b] then
					tokenType = "m"..tokenType
				end
				table.insert(tokenizedLine, {token, tokenType})
			end
		end
		table.insert(tokenizedLines, tokenizedLine)
	end
		--[[pass 1: detect instruction size / omit size tokens]]
		for i, line in pairs(tokenizedLines) do
			local tokenInst = {}
			local actualInst = {}
			for b, tokenPair in pairs(line) do
				local isMem
				if mem_tokens[i] and mem_tokens[i][b] then isMem = true end

				local tokenSize = luasm.getSize(tokenPair[1])
				if not actualInst[0] and not isMem then
					if tokenSize then 
						actualInst[0] = tokenSize
						print(tokenSize)
					end
				else
					if tokenSize and tokenSize ~= actualInst[0] then
						table.insert(errors, {"Operand size mismatch", i})
						break
					end
				end
				if tokenPair[2] ~= "size" then
					table.insert(tokenInst, tokenPair[2])
					table.insert(actualInst, tokenPair[1])
				end
			end

			if not actualInst[0] then table.insert(errors, {"Undefined operand size", i}) break end

			tokenizedLines[i] = {tokenInst,actualInst, {}}
		end

		--[[pass 2: assemble op dest, src instructions]]
		for i, line in pairs(tokenizedLines) do 
			if #line[1] == 3 then
				local tokenInst = line[1]
				local actualInst = line[2]
				local bin = lines[3]
				local opcodeString = ""
				local opcode
				local dest
				local src
				for b, token in pairs(tokenInst) do
					opcodeString = opcodeString..token.." "
				end

				opcode = OPCODES[opcodeString]
				print(opcodeString..string.format("%x", opcode))
			end
		end
	return errors, outputbin
end

return luasm
