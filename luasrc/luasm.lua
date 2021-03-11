local luasm = {}
local slen = string.len
local ssub = string.sub
local sbyte = string.byte
local sspl = string.split
local sfind = string.find
local slow = string.lower
local sfor = string.format
local tins = table.insert
local tcon = table.concat
local trem = table.remove

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

es = 0,
ds = 3,
fs = 4,
gs = 5,
ss = 2
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
 ebx = 7,

}

luasm.IMM_OPCODE_EXT = {
	add = 0,
	["or"] = 1,
	adc = 2,
	sbb = 3,
	["and"] = 4,
	sub = 5,
	xor = 6,
	cmp = 7
}
function luasm.removeComma(b) --b is a token 
	if slen(b) > 1 then --remove commas
	local first = ssub(b,1,1)
		if first == "," or sbyte(first) == 9 then
			b = ssub(b,2,slen(b))
		end
		local slenb = slen(b)
		if ssub(b,slenb,slenb) == "," or sbyte(first) == 9 then
			b = ssub(b,1,slen(b)-1)
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
	local bLen = slen(b)
	local ss = string.sub
	if ss(b,1,1) == "[" then
		b = ss(b,2,bLen)
		bLen = slen(b)
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

function luasm.tokenize(inputString, errors)
	local lines = {}
	local mem_tokens = {}
	local mem_flag = false

	local inputStringLines = sspl(inputString, luasm.RETURN_CHAR)
	
	--this loop is a terrible bugfix, but its working!
	for i,v in pairs(inputStringLines) do
		local splitToken = sspl(v)
		local newLineToken = {}
		local omit = 0
		for is, iv in pairs(splitToken) do
			if is == 1 then
				--local n = is
				while sbyte(splitToken[omit+1]) == 32 or sbyte(splitToken[omit+1]) == 9 do
					omit = omit + 1
					--n = n + 1
				end
				--print(omit)
				if omit > 0 then
					for o = omit,#splitToken do
						tins(newLineToken,splitToken[o])
					end
					inputStringLines[i] = tcon(newLineToken)
				end
			end
		end
	end

	for i,v in pairs(inputStringLines) do
		local offset = 0
		lines[i] = {}

		if sfind(v, "+") then
			local express = sspl(v) --prepare arithmetic/modrm expressions
			local loopAgain = true
			while loopAgain do
				for index, char in pairs(express) do
					if char == "+" and express[index+1] and express[index-1] and (express[index+1] ~= " " or express[index-1] ~= " ") then
						if express[index+1] ~= " " then
							tins(express, index+1, " ")
						end
						if express[index-1] ~= " " then
							tins(express, index, " ")
						end
						loopAgain = true
						break
					else
						loopAgain = false
					end
				end
			end

			if express then
				v = tcon(express)
			--print(v)
		end
		end

		--this allows proc labels to be placed on the same line as something
		local spl = sspl(v, " ")
		for o,s in pairs(spl) do
			local vLen = slen(s)
			if ssub(s, vLen,vLen) == ":" then
				if o <= 2 then
					vLen = sspl(s)
					tins(vLen, #vLen, " ")
					s = tcon(vLen)
					spl[o] = s
				else
				if s == " " then
					tins(errors, {"Invalid instruction format", i})
					break
				end
				end
			end
		end
		local newV = ""
		for i, v in pairs(spl) do
			if v ~= " " then
			newV = newV..v.." "
			end
		end
		v = newV

		local inputStringTokens = sspl(v, luasm.SPACE_CHAR)
		for o,b in pairs(inputStringTokens) do

			b = luasm.removeComma(b)

			if b == "," or b == " " or sbyte(b) == 10--[[ or string.byte(b) == 9]] or b == nil or b == "" then
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
			end
		end
	end

	return lines, mem_tokens, errors
end

function luasm:FindToken(token)
	local lowerToken = slow(token)
	
	for k,v in pairs(self.TOKENS) do
		if k == lowerToken then
			return k,v
		end
	end
	
	local tokenImmediate = tonumber(token)
	
	if tokenImmediate then
		return tokenImmediate, "imm"
	end

	local splitToken = sspl(token)
	if (splitToken[1] == "'" and splitToken[#splitToken] == "'") or (splitToken[1] == '"' and splitToken[#splitToken] == '"') then
		for sti, stv in pairs(splitToken) do
			if stv == string.char(0xFF) then
			splitToken[sti] = " "
			end
		end
		trem(splitToken, #splitToken)
		trem(splitToken, 1)
		token = tcon(splitToken)
		return token, "str"
	end

	return token, "lbl"

end

function luasm.assemble(lines, mem_tokens, errors)
	local tokenizedLines = {}
	local labels = {}
	local outputbin = {}
	local org = 0
	local bootsig
	--[[pass group 0: tokenize, preprocess]]
	tokenizedLines = luasm.createTokenizedLines(lines, tokenizedLines, mem_tokens)
	tokenizedLines, org, errors, bootsig = luasm.preprocess(tokenizedLines, mem_tokens, errors)
	--[[pass group 1: detect instruction size, find labels and create placeholders]]
	tokenizedLines, errors = luasm.setInstructionSizes(tokenizedLines, mem_tokens, errors)
	labels, tokenizedLines, errors = luasm.getLabels(tokenizedLines, mem_tokens, errors)
	tokenizedLines, errors = luasm.replaceLabels(labels, tokenizedLines, errors)
	--[[pass group 2: assemble, fill label offsets, generate binary]]
	tokenizedLines, errors = luasm.pass2(tokenizedLines, mem_tokens, errors)
	labels, tokenizedLines, errors = luasm.setLabelOffsets(labels, tokenizedLines, errors, org)

	tokenizedLines, errors, outputbin = luasm.getOutputBinary(labels, tokenizedLines, errors)

	if bootsig then 
		outputbin = luasm.setBootsig(outputbin, bootsig)
	end

	return errors, outputbin
end

function luasm.setBootsig(outputbin, bootsig)
		if outputbin[bootsig+1] then
		outputbin[bootsig+1] = 0x55
		outputbin[bootsig+2] = 0xAA
		else
			local bootsigOffset = (bootsig-#outputbin)
			for i = 1,bootsigOffset+1 do
				if not outputbin[#outputbin+1] then
					outputbin[#outputbin+1] = 0
				end
			end
		outputbin[bootsig+1] = 0x55
		outputbin[bootsig+2] = 0xAA
		end
	return outputbin
end

function luasm.preprocess(tokenizedLines, mem_tokens, errors)
	local org = 0
	local bootsig
	for i, line in pairs(tokenizedLines) do
		for b, tokenPair in pairs(line) do
			local nextPair = line[b+1]
			local actual = tokenPair[1]
			local token = tokenPair[2]

			if token == "org" then
				if nextPair and nextPair[2] == "imm" then
					org = nextPair[1]
				else
					tins(errors, {"Invalid org directive", i})
					break
				end
			elseif token == "bootsig" then
				if nextPair and nextPair[2] == "imm" then
					bootsig = nextPair[1]
				else
					tins(errors, {"Invalid bootsig directive", i})
					break
				end
			end
		end
	end
	print(org)
	return tokenizedLines, org, errors, bootsig
end

function luasm.createTokenizedLines(lines, tokenizedLines, mem_tokens)
	for i, line in pairs(lines) do
		local tokenizedLine = {}
		for b = 1,#line do
			local token, tokenType = luasm:FindToken(line[b])
			if token then
				if tokenType == "str" then
					local chars = string.split(token)
					for ci, cv in pairs(chars) do
						tins(tokenizedLine, {string.byte(cv), "imm"})
					end
				else
					if mem_tokens[i] and mem_tokens[i][b] then
						tokenType = "m"..tokenType
					end
					tins(tokenizedLine, {token, tokenType})
				end
			end
		end
		tins(tokenizedLines, tokenizedLine)
	end

	return tokenizedLines
end

function luasm.setInstructionSizes(tokenizedLines, mem_tokens, errors)
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
					--print(tokenSize)
				end
			else
				if isMem and not actualInst[0] then
					actualInst[0] = "byte"
					tokenSize = "byte"
				end

				if tokenSize and tokenSize ~= actualInst[0] and not isMem then
					--print(actualInst[0])
					tins(errors, {"Operand size mismatch", i})
					break
				end
			end
			if tokenPair[2] ~= "size" then
				tins(tokenInst, tokenPair[2])
				tins(actualInst, tokenPair[1])
			end
		end

		if not actualInst[0] then
			if actualInst[3] then
				local operand2Size = luasm.getSize(actualInst[3])
				if operand2Size then
					actualInst[0] = operand2Size
					size = actualInst[0]
				else
					tins(errors, {"Undefined operand size", i}) 
					break
				end
			else
				--table.insert(errors, {"Undefined operand size", i}) 
				--break
			end
		end
		tokenizedLines[i] = {tokenInst,actualInst, {[0] = {}}}
	end

	return tokenizedLines, errors
end

function luasm.setLabelOffsets(labels, tokenizedLines, errors, org)
	local bin_ptr = 0
	for i, line in pairs(tokenizedLines) do
		local tokenInst = line[1]
		local actualInst = line[2]
		local bin = line[3]
		if type(bin[0]) == "table" then
			for o, b in pairs(bin[0]) do
				labels[b] = bin_ptr + (org)
				--print("Added offset")
			end
		end

		for ia, va in pairs(actualInst) do
			if type(va) == "table" then
				bin_ptr = bin_ptr + #va-1
			end
		end
		for ibin, vbin in pairs(bin) do
			if ibin > 0 and type(vbin) ~= "string" then
				bin_ptr = bin_ptr + 1
			end
		end
	end
	--print(bin_ptr)
	return labels, tokenizedLines, errors
end

function luasm.replaceLabels(labels, tokenizedLines, errors)
	for i, line in pairs(tokenizedLines) do
			local tokenInst = line[1]
			local actualInst = line[2]
			local bin = line[3]
		for b, token in pairs(tokenInst) do
			local actual = actualInst[b]
			if token == "lbl" and bin[0] ~= 0 then
				tokenInst, actualInst, errors = luasm.convertLblToImm(labels, b, "imm", tokenInst, actualInst, actual, errors)
			elseif token == "mlbl" then
				tokenInst, actualInst, errors = luasm.convertLblToImm(labels, b, "mimm", tokenInst, actualInst, actual, errors)
			end
		end
	end

	return tokenizedLines, errors
end

function luasm.convertLblToImm(labels, b, tokenType, tokenInst, actualInst, actual, errors)
	if labels[actual] then
		--print("Label exists")
		tokenInst[b] = tokenType
		actualInst[b] = {}
		actualInst[b][1] = actual
		actualInst[b][2] = 0
		return tokenInst, actualInst, errors
	else
		table.insert(errors, {"Undefined label ("..actual..")", i})
	end
end

local cloneTable = {__call = function(t)
	local nt = {}
		for k,v in pairs(t) do
			nt[k] = v
		end
	return t
	end}

function luasm.getLabels(tokenizedLines, mem_tokens, errors)

	local labels = {}
	
	local offset = 0
	for i, line in pairs(tokenizedLines) do
		local hasLabelDef
		local aloneOnLine
		labels, hasLabelDef, aloneOnLine, --[[newTokenizedLines,]] offset, errors = luasm.getLabelOnLine(i, line, labels, tokenizedLines, --[[newTokenizedLines,]] offset, errors)
	end

		newTokenizedLines = luasm.collapseLabelDef(tokenizedLines)
	return labels, newTokenizedLines,--[[newTokenizedLines,]] errors
end

function luasm.collapseLabelDef(tokenizedLines)
	local newTokenizedLines = {}
	local carryLabels = {}
	for i, line in pairs(tokenizedLines) do
		local tokenInst = line[1]
		local bin = line[3]
		if #tokenInst == 0 then
			for bini, binv in pairs(bin[0]) do
				tins(carryLabels, binv)
			end
			bin[0] = 0
			tins(newTokenizedLines, line)
		else
			--print(tokenInst[1])
			for ci, cv in pairs(carryLabels) do
				tins(bin[0], cv)
			end
			carryLabels = {}
			tins(newTokenizedLines, line)
		end
	end
	return newTokenizedLines
end

function luasm.getLabelOnLine(i, line, labels, tokenizedLines, offset, errors)
		--newTokenizedLines[i--[[offset]]] = line

		local tokenInst = line[1]

		local actualInst = line[2]

		--setmetatable(tokenInst, cloneTable)
		--setmetatable(actualInst, cloneTable)

		local bin = line[3]
		local nextLine = tokenizedLines[i+1]
		local nextBin

		if nextLine then
			nextBin = nextLine[3]
		end

		--local newTokenInst = tokenInst()
		--local newActualInst = actualInst()

		local tokensToRemove = 0
		local aloneOnLine = false
		local hasLabelDef = false
		for b, token in pairs(tokenInst) do
			local actual = actualInst[b]
			local nextToken = tokenInst[b+1]
			local prevToken = tokenInst[b-1]
			local nextActual = actualInst[b+1]
			local prevActual = actualInst[b-1]
			if b <= 2 and nextToken then
			--print(actual.." "..nextToken.."||")
				if nextToken == ":" then
					if token == "lbl" then
						tokensToRemove = 2
						if not labels[actual] then
							labels[actual] = 0
							tins(bin[0], actual)
							hasLabelDef = true
						else
							tins(errors, {"Label already used ("..actual..")", i}) 
							break
						end
					else
						tins(errors, {"Invalid label ("..actual..")", i}) 
						break
					end
				elseif nextToken == "def" then
					if token == "lbl" then
						tokensToRemove = 1
						if not labels[actual] then
							labels[actual] = 0
							tins(bin[0], actual)
							hasLabelDef = true
						else
							tins(errors, {"Label already used ("..actual..")", i}) 
							break
						end
					else
						tins(errors, {"Invalid label ("..actual..")", i}) 
						break
					end
				elseif nextToken == "equ" then
					--preprocess labels
				end
			elseif b == 2 and not nextToken then
				aloneOnLine = true
			--label proc def alone on line
				if token == ":" then --check if label
					if prevToken == "lbl" then
					tokensToRemove = 2
						if not labels[prevActual] then --create label
							labels[prevActual] = 0
							tins(bin[0], actual)
							hasLabelDef = true
						else
							--table.insert(errors, {"Label already used ("..prevActual..")", i}) 
							--break
						end
					else
						tins(errors, {"Invalid label ("..prevActual..")", i}) 
						break
					end
				end
				
			else
			--print(actual.." "..tostring(nextToken).."||")
				if token == ":" or token == "def" or token == "equ" then
						tins(errors, {"Invalid label ("..actual..")", i}) 
						break
				end
			end
		end

		if tokensToRemove > 0 then
			for rem = 1,tokensToRemove do --remove label def tokens from line
				trem(tokenInst,1)
				trem(actualInst,1)
			end
		end

return labels, hasLabelDef, aloneOnLine, --[[newTokenizedLines,]] offset, errors
end

function luasm.pass2(tokenizedLines, mem_tokens, errors)
	for i, line in pairs(tokenizedLines) do 
	local bin = line[3]
	if bin[0] ~= 0 then
		local tokenInst = line[1]
		local actualInst = line[2]
		local size = actualInst[0]

		if tokenInst[1] and tokenInst[1] == "def" then
			for ti, tv in pairs(tokenInst) do
				if ti > 1 then
					if tv == "imm" and type(actualInst[ti]) ~= "table" then --check for immediates
						if size == "byte" then
							local byte = luasm.getByte(actualInst[ti])
							tins(bin, byte)
						elseif size == "word" then
							print("word")
							local firstByte, secondByte = luasm.getLittleEndianWord(actualInst[ti])
							tins(bin, firstByte)
							tins(bin, secondByte)
						end
					elseif type(actualInst[ti]) == "table" then
						if size == "byte" then
							local byte = luasm.getByte(actualInst[ti][2])
							actualInst[ti][2] = byte
							tins (bin, actualInst[ti][1])
						elseif size == "word" then
							print("word")
							local firstByte, secondByte = luasm.getLittleEndianWord(actualInst[ti][2])
							actualInst[ti][2] = firstByte
							actualInst[ti][3] = secondByte
							tins (bin, actualInst[ti][1])
						end	
					end
				end
			end
		elseif #line[1] == 3 then
			local opcodeString = ""
			local actualString = ""
			local opcode, modrm, disp, imm
			local destToken = tokenInst[2]
			local srcToken = tokenInst[3]
			local dest = actualInst[2]
			local src = actualInst[3]
			local mod, reg, rm = 0
			local modrmReady = false

			for b, token in pairs(tokenInst) do
				opcodeString = opcodeString..token.." "
			end
			--for b, token in pairs(actualInst) do
				--actualString = actualString..token.." "
			--end
			opcode = OPCODES[opcodeString]

			--print(actualString)
			--print(opcodeString)
			if not opcode then
				--print(tokenInst[1].." "..actualInst[1].."e")
				tins(errors, {"Invalid token / instruction format", i})
				break
			else
				tins(bin, opcode)
			end

			if srcToken ~= "imm" then

				if destToken == srcToken and not modrm then 
					mod = 3
					reg = luasm.REG[dest]
					rm = luasm.REG[src]
					modrm = luasm.getModRM(mod, reg, rm)
				end

				if srcToken == "sreg" then
					if destToken == "r16" or destToken == "r32" then
						reg = luasm.REG[src]
						rm = luasm.REG[dest]
						mod = 3
						modrm = luasm.getModRM(mod, reg, rm)
					elseif destToken == "mimm" then
						disp = dest
						rm = 6
						reg = luasm.REG[src]
						modrm = luasm.getModRM(mod, reg, rm)
					end
				elseif destToken == "sreg" then
					if srcToken == "r16" or srcToken == "r32" then
						reg = luasm.REG[dest]
						--print(tokenInst[2])
						rm = luasm.REG[src]
						mod = 3
						modrm = luasm.getModRM(mod, reg, rm)
					elseif srcToken == "mimm" then
						disp = src
						rm = 6
						reg = luasm.REG[dest]
						modrm = luasm.getModRM(mod, reg, rm)
					end
				end

				if not modrm then
					if destToken == "mimm" then
						mod = 0
						rm = 6
						reg = luasm.REG[src]
						disp = dest
						modrm = luasm.getModRM(mod, reg, rm)
					elseif srcToken == "mimm" then
						mod = 0
						rm = 6
						reg = luasm.REG[dest]
						disp = src
						modrm = luasm.getModRM(mod, reg, rm)
					end
				end

				if not modrm then
					if destToken == "mr16" or destToken == "mr32" then
						reg = luasm.REG[src]
						rm = luasm.RM[dest]
						mod = 0
						if not rm then
							tins(errors, {"Invalid memory addressing register", i})
							break
						else
							modrm = luasm.getModRM(mod, reg, rm)
						end
					elseif srcToken == "mr16" or srcToken == "mr32" then
						reg = luasm.REG[dest]
						rm = luasm.RM[src]
						mod = mod
						if not rm then
							tins(errors, {"Invalid memory addressing register", i})
							break
						else
							modrm = luasm.getModRM(mod, reg, rm)
						end
					end
				end

				table.insert(bin, modrm)

				if disp then
					if type(disp) == "table" then
						if mod == 0 and rm == 6 then
							local firstByte, secondByte = luasm.getLittleEndianWord(disp)
							--tins(bin, firstByte)
							--tins(bin, secondByte)
							disp[2] = firstByte
							disp[3] = secondByte
							tins(bin, disp[1]) 
						elseif mod == 1 then
							local byte = luasm.getByte(disp)
							--tins(bin, disp)
							disp[2] = byte
							tins(bin, disp[1]) 
						elseif mod == 2 then
							--local firstByte = bit.shl(disp, 24)
							--firstByte = bit.shr(firstByte, 24)
							local firstByte, secondByte = luasm.getLittleEndianWord(disp)
							disp[2] = firstByte
							disp[3] = secondByte
							tins(bin, disp[1])
							--local secondByte = bit.shl(disp, 16)
							--secondByte = bit.shr(secondByte, 24)
							--tins(bin, secondByte)
						end
					else
						if mod == 0 and rm == 6 then
							local firstByte, secondByte = luasm.getLittleEndianWord(disp)
							tins(bin, firstByte)
							tins(bin, secondByte)
						elseif mod == 1 then
							disp = luasm.getByte(disp)
							tins(bin, disp)
						elseif mod == 2 then
							--local firstByte = bit.shl(disp, 24)
							--firstByte = bit.shr(firstByte, 24)
							local secondByte = bit.shl(disp, 16)
							secondByte = bit.shr(secondByte, 24)
							tins(bin, secondByte)
						end
					end
				end
			else
				if destToken == "mimm" then
					mod = 0
					rm = 6
					reg = luasm.IMM_OPCODE_EXT[actualInst[1]]
					--disp = dest
						if type(dest) == "table" then
							disp = dest[2]
						else
							disp = dest
						end
					--imm = src
						if type(src) == "table" then
							imm = src[2]
						else
							imm = src
						end
					modrm = luasm.getModRM(mod, reg, rm)
					tins(bin, modrm)
					local firstByte, secondByte = luasm.getLittleEndianWord(disp)
					--tins(bin, firstByte)
					--tins(bin, secondByte)
						if type(dest) == "table" then
							dest[2] = firstByte
							dest[3] = secondByte
							tins(bin, dest[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, firstByte)
							tins(bin, secondByte)
						end

					if size == "byte" then
					print(srcToken)
						imm = luasm.getByte(imm)
						--tins(bin, imm)
						if type(src) == "table" then
							src[2] = imm
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, imm)
						end

					elseif size == "word" then
						bin[1] = bit.OR(bin[1], 1) --set opcode size bit
						local firstByte, secondByte = luasm.getLittleEndianWord(imm)
						--tins(bin, firstByte)
						--tins(bin, secondByte)
						if type(src) == "table" then
							src[2] = firstByte
							src[3] = secondByte
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, firstByte)
							tins(bin, secondByte)
						end

					end

				elseif destToken == "r8" then
					if actualInst[1] == "mov" then
						if type(src) == "table" then
							imm = src[2]
						else
							imm = src
						end

						bin[1] = bit.OR(bin[1], luasm.REG[dest]) --add reg to opcode
						imm = luasm.getByte(imm)

						if type(src) == "table" then
							src[2] = imm
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, imm)
						end
					else
						mod = 3
						rm = luasm.REG[dest]
						reg = luasm.IMM_OPCODE_EXT[actualInst[1]]
						modrm = luasm.getModRM(mod, reg, rm)
						tins(bin, modrm)
						if type(src) == "table" then
							imm = src[2]
						else
							imm = src
						end
						imm = luasm.getByte(imm)
						if type(src) == "table" then
							src[2] = imm
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, imm)
						end
					end
				elseif destToken == "r16" then
					if actualInst[1] == "mov" then

						if type(src) == "table" then
							imm = src[2]
						else
							imm = src
						end

						bin[1] = bit.OR(bin[1], luasm.REG[dest]) --add reg to opcode
						local firstByte, secondByte = luasm.getLittleEndianWord(imm)

						if type(src) == "table" then
							src[2] = firstByte
							src[3] = secondByte
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, firstByte)
							tins(bin, secondByte)
						end
					else
						mod = 3
						rm = luasm.REG[dest]
						reg = luasm.IMM_OPCODE_EXT[actualInst[1]]
						modrm = luasm.getModRM(mod, reg, rm)
						tins(bin, modrm)
						if type(src) == "table" then
							imm = src[2]
						else
							imm = src
						end
						local firstByte, secondByte = luasm.getLittleEndianWord(imm)
						if type(src) == "table" then
							src[2] = firstByte
							src[3] = secondByte
							tins(bin, src[1]) --insert label name into bin to be replaced on next pass
						else
							tins(bin, firstByte)
							tins(bin, secondByte)
						end
					end
				elseif destToken == "mr16" then
					mod = 0
					reg = luasm.IMM_OPCODE_EXT[actualInst[1]]
					if size == "byte" then
						bin[1] = bin[1] - 1
					end
					rm = luasm.RM[dest]
					imm = src
					modrm = luasm.getModRM(mod, reg, rm)
					tins(bin, modrm)
					if size == "byte" then
						imm = luasm.getByte(imm)
						tins(bin, imm)
					elseif size == "word" then
						bin[1] = bit.OR(bin[1], 1) --set opcode size bit
						local firstByte, secondByte = luasm.getLittleEndianWord(imm)
						tins(bin, firstByte)
						tins(bin, secondByte)
					end
				end
			end

			local binStr = ""
			for bini, binv in pairs(bin) do
				if type(binv) ~= "table" and type(binv) ~= "string" then
					local hex = sfor("%x", binv)
					if string.len(hex) == 1 then
						hex = "0"..hex
					end
					binStr = binStr..hex.." "
				else
				end
			end
			--print(binStr)		
		elseif #line[2] == 2 then 
			local opcode
			local mnem = actualInst[1]
			local bin = line[3]
			local imm
			local reg
			local opcodeString = ""
			local operand = actualInst[2]
			local operandToken = tokenInst[2]
			for b, token in pairs(tokenInst) do
				opcodeString = opcodeString..token.." "
			end
			opcode = OPCODES[opcodeString]

			if not opcode then
				--print(tokenInst[1].." "..actualInst[1].."e")
				tins(errors, {"Invalid token / instruction format", i})
				break
			else
				tins(bin, opcode)
			end

			if mnem == "int" then
				if not size then
					size = "byte"
				elseif size ~= "byte" then
					--error here
				end
				if size == "byte" then
					if type(operand) == "table" then
						imm = operand[2]
					else
						imm = operand
					end
					local byte = luasm.getByte(imm)
					if type(operand) == "table" then
						operand[2] = byte
						tins(bin, operand[1])
					else
						tins(bin, byte)
					end
				end
			elseif mnem == "push" or mnem == "pop" then
				if operandToken == "r16" or operandToken == "r32" then
					reg = luasm.REG[operand]
					bin[1] = bit.OR(bin[1], reg)
				end
			elseif mnem == "inc" or mnem == "dec" then
				if operandToken == "r16" or operandToken == "r32" then
					reg = luasm.REG[operand]
					bin[1] = bit.OR(bin[1], reg)
				end
			elseif (opcode > 0x6F and opcode < 0x80) or opcode == 0xEB then
					if type(operand) == "table" then
						imm = operand[2]
						tins(bin, operand[1])
					else
						imm = operand
						tinc(bin, imm)
					end
					
			elseif mnem == "org" or mnem == "bootsig" then
				bin[1] = nil
			end
		elseif #line[1] == 1 then
			local tokenInst = line[1]
			local actualInst = line[2]
			local opcode
			local bin = line[3]

			opcode = OPCODES[tokenInst[1].." "]
			if not opcode then
				--print(tokenInst[1].." "..actualInst[1].."e")
					tins(errors, {"Invalid token / instruction format", i})
					break
			else
					tins(bin, opcode)
			end
				--print(sfor("%x", bin[1]))
		end
	else
		--print("skipped label def")
	end
	end
	return tokenizedLines, errors
end

function luasm.getOutputBinary(labels, tokenizedLines, errors)
	local totalBin = {}
	for i, line in pairs(tokenizedLines) do
		local tokenInst = line[1]
		local actualInst = line[2]
		local bin = line[3]
		local newBin = {}
		if bin[0] ~= 0 then
			for bini, binv in pairs(bin) do
				if bini > 0 then
					if type(binv) == "string" then
						local labelOffset = labels[binv]
						print(binv)
							--if labelOffset > 0 then labelOffset = labelOffset - 1 end
						local size = 0
						for ai, av in pairs(actualInst) do
							if ai > 0 and type(av) == "table" and av[1] == binv then
								size = #av-1
								break
							end
						end
						if (bin[1] > 0x6F and bin[1] < 0x80) or bin[1] == 0xEB then --convert label to a relative offset
							local rel = (labelOffset-#totalBin)-1
							
							--[[local neg = false
							if rel < 0 then
								rel = math.abs(rel)
								neg = true
							end]]
							rel = bit.shl(rel, 24)
							rel = bit.shr(rel, 24)
							--[[if neg then
							rel = bit.OR(rel, 0x80)
							else
							rel = bit.shl(rel, 25)
							rel = bit.shr(rel, 25)
							end]]
							tins(totalBin, rel)
						else
							if size == 2 then
								local firstByte, secondByte = luasm.getLittleEndianWord(labelOffset)
								tins(totalBin, firstByte)
								tins(totalBin, secondByte)
							elseif size == 1 then
								local byte = luasm.getByte(labelOffset)
								tins(totalBin, byte)
							end
						end
					else
						tins(totalBin, binv)
					end
				end
			end
		end
	end
	--print(#totalBin)
			local binStr = ""
			for bini, binv in pairs(totalBin) do
				if binv then
					local hex = sfor("%x", binv)
					if slen(hex) == 1 then
						hex = "0"..hex
					end
					binStr = binStr..hex.." "
				end
			end
			print(binStr)		
	return tokenizedLines, errors, totalBin
end

function luasm.getModRM(mod, reg, rm)
	local modrm = bit.shl(mod, 3)
	modrm = bit.OR(modrm, reg)
	modrm = bit.shl(modrm, 3)
	modrm = bit.OR(modrm, rm)
	return modrm
end

function luasm.getLittleEndianWord(n)
	local firstByte = bit.shl(n, 24)
	firstByte = bit.shr(firstByte, 24)
	local secondByte = bit.shl(n, 16)
	secondByte = bit.shr(secondByte, 24)
	return firstByte, secondByte
end

function luasm.getByte(n)
	n = bit.shl(n, 24)
	n = bit.shr(n, 24)
	return n
end

return luasm
