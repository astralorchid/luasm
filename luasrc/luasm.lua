local luasm = {}

luasm.SIZES = require("sizes")
luasm.TOKENS = require("tokens")
local OPCODES = require("opcodes")

luasm.RETURN_CHAR = string.char(10)
luasm.SPACE_CHAR = " "
luasm.UNDERSCORE_CHAR = "_"

luasm.REG = {
al = 0,
cl = 1,
dl = 2,
bl = 3,
ah = 4,
ch = 5,
dh = 6,
bh = 7,

ax = 0,
cx = 1,
dx = 2,
bx = 3,
sp = 4,
bp = 5,
si = 6,
di = 7,

eax = 0,
ecx = 1,
edx = 2,
ebx = 3,
esp = 4,
ebp = 5,
esi = 6,
edi = 7,
}

luasm.RM = {
 ["bx+si"] = 0,
 ["bx+di"] = 1,
 ["bp+si"] = 2,
 ["bp+di"] = 3,
 si = 4,
 di = 5,
 bp = 6,
 bx = 7,

 ["ebx+esi"] = 0,
 ["ebx+edi"] = 1,
 ["ebp+esi"] = 2,
 ["ebp+edi"] = 3,
 esi = 4,
 edi = 5,
 ebp = 6,
 ebx = 7
}
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

	tokenizedLines = luasm.createTokenizedLines(lines, tokenizedLines, mem_tokens)
	--[[pass 1: detect instruction size / omit size tokens]]
	tokenizedLines, errors = luasm.pass1(tokenizedLines, mem_tokens, errors)
	--[[pass 2: assemble op dest, src instructions]]
	tokenizedLines, errors = luasm.pass2(tokenizedLines, mem_tokens, errors)
		
	return errors, outputbin
end

function luasm.createTokenizedLines(lines, tokenizedLines, mem_tokens)
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

	return tokenizedLines
end

function luasm.pass1(tokenizedLines, mem_tokens, errors)
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

	return tokenizedLines, errors
end

function luasm.pass2(tokenizedLines, mem_tokens, errors)
	for i, line in pairs(tokenizedLines) do 
		if #line[1] == 3 then
			local tokenInst = line[1]
			local actualInst = line[2]
			local bin = line[3]
			local opcodeString = ""
			local opcode, modrm, imm
			local destToken = tokenInst[2]
			local srcToken = tokenInst[3]
			local dest = actualInst[2]
			local src = actualInst[3]
			local mod, reg, rm = 0
			local size = actualInst[0]

			for b, token in pairs(tokenInst) do
				opcodeString = opcodeString..token.." "
			end

			opcode = OPCODES[opcodeString]
			if not opcode then
				table.insert(errors, {"Invalid instruction format", i})
				break
			else
				print(opcodeString..string.format("%x", opcode))
			end

			if srcToken ~= "imm" then
				if destToken == srcToken then 
					mod = 3
					reg = luasm.REG[dest]
					rm = luasm.REG[src]
				end

				if destToken == "mimm" then
					mod = 0
					rm = 6
					reg = luasm.REG[src]
					imm = dest
				elseif srcToken == "mimm" then
					mod = 0
					rm = 6
					reg = luasm.REG[dest]
					imm = src
				end

				if destToken == "mr16" or destToken == "mr32" then
					reg = luasm.REG[src]
					rm = luasm.RM[dest]
					if not rm then
						table.insert(errors, {"Invalid memory addressing register", i})
						break
					end
				elseif srcToken == "mr16" or srcToken == "mr32" then
					reg = luasm.REG[dest]
					rm = luasm.RM[src]
					if not rm then
						table.insert(errors, {"Invalid memory addressing register", i})
						break
					end
				end
				modrm = luasm.getModRM(mod, reg, rm)
				print(string.format("%x", modrm))
			else
				--immediate handling
			end
		end
	end
	return tokenizedLines, errors
end

function luasm.getModRM(mod, reg, rm)
	local modrm = bit.shl(mod, 3)
	modrm = bit.OR(modrm, reg)
	modrm = bit.shl(modrm, 3)
	modrm = bit.OR(modrm, rm)
	return modrm
end

return luasm
