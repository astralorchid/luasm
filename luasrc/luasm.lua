local luasm = {}
luasm.RETURN_CHAR = string.char(10)
luasm.SPACE_CHAR = " "
luasm.UNDERSCORE_CHAR = "_"

luasm.TOKEN = {
	mov = "OP_MOV",
	add = "OP_ADD",
	sub = "OP_SUB",
	xor = "OP_XOR",
	inc = "OP_INC",
	dec = "OP_DEC",
	["+"] = "PLUS",
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
	bp = "REG_BP",
	sp = "REG_SP",
	di = "REG_DI",
	si = "REG_SI",

	cs = "SREG_CS",
	ds = "SREG_DS",
	es = "SREG_ES",
	fs = "SREG_FS",
	gs = "SREG_GS",
	ss = "SREG_SS",

	byte = "SIZE_BYTE",
	word = "SIZE_WORD",
	dword = "SIZE_DWORD",
	qword = "SIZE_QWORD",
}

luasm.REG_SIZES = {
	REG_AL = "BYTE",
	REG_CL = "BYTE",
	REG_DL = "BYTE",
	REG_BL = "BYTE",
	REG_AH = "BYTE",
	REG_CH = "BYTE",
	REG_DH = "BYTE",
	REG_BH = "BYTE",
	REG_AX = "WORD",
	REG_CX = "WORD",
	REG_DX = "WORD",
	REG_BX = "WORD",
	REG_SP = "WORD",
	REG_BP = "WORD",
	REG_SI = "WORD",
	REG_DI = "WORD",

	SREG_CS = "WORD",
	SREG_DS = "WORD",
	SREG_ES = "WORD",
	SREG_FS = "WORD",
	SREG_GS = "WORD",
	SREG_SS = "WORD",

	SIZE_BYTE = "BYTE",
	SIZE_WORD = "WORD",
	SIZE_DWORD = "DWORD",
	SIZE_QWORD = "QWORD"
}

luasm.REGField = {
	REG_AL = 0,
	REG_CL = 1,
	REG_DL = 2,
	REG_BL = 3,
	REG_AH = 4,
	REG_CH = 5,
	REG_DH = 6,
	REG_BH = 7,
	REG_AX = 0,
	REG_CX = 1,
	REG_DX = 2,
	REG_BX = 3,
	REG_SP = 4,
	REG_BP = 5,
	REG_SI = 6,
	REG_DI = 7,

	SREG_DS = 3,
	SREG_ES = 0,
	SREG_FS = 4,
	SREG_GS = 5,
	SREG_SS = 2,

}

luasm.ILLEGAL_INST_FORMAT = {
	["OP IMM IMM"] = true,
	["OP IMM REG"] = true,
}

luasm.OPCODES = {
OP_NOP = 144,
OP_PUSHA = 96,
OP_POPA = 97,
OP_CMPSB = 166,
OP_CMPSW = 167,
OP_MOVSB = 164,
OP_MOVSW = 165,
OP_SCASB = 174,
OP_SCASW = 175,
OP_RET = 195,
OP_RETF = 203,

OP_INC = 64,
OP_DEC = 72,

OP_MOV = 136,
OP_XOR = 48,
OP_OR = 8,
OP_ADC = 16,
OP_SBB = 24,
OP_AND = 32,
OP_CMP = 56,
OP_ADD = 0,
OP_SUB = 40,
}

luasm.IMM_OPCODES = {
	OP_MOV = 198,
	OP_XOR = 128,
	OP_CMP = 128,
	OP_ADD = 128,
	OP_OR = 128,
	OP_ADC = 128,
	OP_SBB = 128,
	OP_AND = 128,
	OP_SUB = 128,
	OP_ROL = 192,
	OP_ROR = 192,
	OP_RCL = 192,
	OP_RCR = 192,
	OP_SHL = 192,
	OP_SAL = 192,
	OP_SHR = 192,
	OP_SAR = 192
}
luasm.IMM_OPCODE_EXT = { --immediate opcode extensions for the mod r/m byte
	OP_MOV = 0,
	OP_XOR = 6,
	OP_CMP = 7,
	OP_ADD = 0,
	OP_OR = 1,
	OP_ADC = 2,
	OP_SBB = 3,
	OP_AND = 4,
	OP_SUB = 5,

	OP_ROL = 0,
	OP_ROR = 1,
	OP_RCL = 2,
	OP_RCR = 3,
	OP_SHL = 4,
	OP_SAL = 5,
	OP_SHR = 6,
	OP_SAR = 7
}

luasm.RMField = {
	REG_BX_REG_SI = 0,
	REG_BX_REG_DI = 1,
	REG_BP_REG_SI = 2,
	REG_BP_REG_DI = 3,
	REG_SI = 4,
	REG_DI = 5,
	REG_BP = 6,
	REG_BX = 7,

	SREG_DS = 3,
	SREG_ES = 0,
	SREG_FS = 4,
	SREG_GS = 5,
	SREG_SS = 2,
}

luasm.SREG_RMField = {
	REG_AX = 0,
	REG_CX = 1,
	REG_DX = 2,
	REG_BX = 3,
	REG_SP = 4,
	REG_BP = 5,
	REG_SI = 6,
	REG_DI = 7,
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

function luasm.getRegSize(token)
	for char, size in pairs(luasm.REG_SIZES) do
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

				lines[i][o-offset] = b
				--print(b.." | "..o-offset)
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

local outputbinMT = {
	__newindex = function(t,k,v)
		rawset(t, k, v)
	end
}
function luasm.assemble(lines, mem_tokens)
	local outputbin = {}
	setmetatable(outputbin, outputbinMT)

	local errors = {}
	local imm = nil
	for i,line in pairs(lines) do
		local instFormat = {}
		local proper = false
		local operands = 0
		local opcodes = 0

		local instBytes = {
			opcodeByte = nil,
			modRMByte = nil,--MOD dictates register addressing (RA) modes
			displacementByte = nil,--RA displacement (if applicable)
			immediateByte = nil--immediate value (if applicable)
		}

		
		local opcodeToken 
		local MOD = 0
		local REG
		local RM
		local dualREG = false 
		local immReg --sets REG field in modRMByte if immediate operand
		local operandSize
		local destBit --dictates dest/src of R/M and REG fields (opcodeByte bit 1)
		local sizeBit --dictates instruction size (opcodeByte bit 0)
		local has_SREG = false
		local isImmMemAddr = false --bool for an immediate memory addressing operation
		local alreadyEncoded = false --some operations have special encoding before the end of the instFormat loop
		for b = 1,#line do
			local token, tokenType = luasm:FindToken(line[b])
			if token then
			--print(token)
				if mem_tokens[i] and mem_tokens[i][b] then
					tokenType = "mem"..tokenType
				end

				table.insert(instFormat, {token, tokenType})
				
				if tokenType == "OP" then
					opcodes = opcodes + 1
					opcodeToken = token
					instBytes.opcodeByte = luasm.OPCODES[token]
				end
				
				proper = true
			else
				table.insert(errors, {tokenType, i})
				proper = false
				break
			end
			
		end

		if opcodes > 1 then
			table.insert(errors, {"Invalid instruction format", i})
			break	
		end
		
		--[[local instFormatLen = string.len(instFormat)
		instFormat = string.sub(instFormat,2,instFormatLen)]]
		
		if luasm.ILLEGAL_INST_FORMAT[instFormat] then
			table.insert(errors, {"Invalid instruction format", i})
			break
		end

		for _,tokenPair in pairs(instFormat) do --{token, tokenType}

			if tokenPair[2] == "OP" then
				if instBytes.opcodeByte == 64 or instBytes.opcodeByte == 72 then --if inc
					if instFormat[_+1] and instFormat[_+1][2] == "REG" then
						local incRegSize = luasm.getRegSize(instFormat[_+1][1])
						if incRegSize == "WORD" then
							instBytes.opcodeByte = bit.OR(instBytes.opcodeByte, luasm.REGField[instFormat[_+1][1]])
							table.insert(outputbin, instBytes.opcodeByte)
							alreadyEncoded = true
							break
						elseif incRegSize == "BYTE" then
							if instBytes.opcodeByte == 64 then
								instBytes.modRMByte = 192
							else
								instBytes.modRMByte = 200
							end
							instBytes.opcodeByte = 254
							instBytes.modRMByte = bit.OR(instBytes.modRMByte, luasm.REGField[instFormat[_+1][1]])
							table.insert(outputbin, instBytes.opcodeByte)
							table.insert(outputbin, instBytes.modRMByte)
							alreadyEncoded = true
							break
						end
					elseif instFormat[_+2] and instFormat[_+2][2] == "memIMM" then
					end
				end
			end

			if tokenPair[2] == "REG" then
				destBit = 2
				local opSize = luasm.getRegSize(tokenPair[1])
				if operandSize == nil then
					operandSize = opSize
				else
					if operandSize ~= opSize then
						table.insert(errors, {"Operand size mismatch", i})
						break
					end
				end

				if REG == nil then
					REG = luasm.REGField[tokenPair[1]]
				else
					RM = luasm.REGField[tokenPair[1]]
					dualREG = true
					MOD = 3
				end

				if instFormat[_-1] and instFormat[_-1][2] == "SREG" then
					instBytes.opcodeByte = 140 --MOV SREG, REG opcode
					destBit = 2
					REG = luasm.REGField[instFormat[_-1][1]]
					RM = luasm.SREG_RMField[tokenPair[1]]
					--print(REG)
					--print(RM)
					MOD = 3
					has_SREG = true
					--print("SREG FIRST OPERAND")
				elseif instFormat[_+1] and instFormat[_+1][2] == "SREG" then
					instBytes.opcodeByte = 140
					destBit = 0
					RM = luasm.SREG_RMField[tokenPair[1]]
					REG = luasm.REGField[instFormat[_+1][1]]
					MOD = 3
					has_SREG = true
					--print("SREG 2nd OPERAND")
				end

			end

			if tokenPair[2] == "IMM" then
				instBytes.immediateByte = tokenPair[1]
				instBytes.opcodeByte = luasm.IMM_OPCODES[opcodeToken]
				REG = luasm.IMM_OPCODE_EXT[opcodeToken]
			end

			if tokenPair[2] == "memIMM" then
				if not REG then
					destBit = 0
				end
				RM = 6
				instBytes.displacementByte = tokenPair[1]
				isImmMemAddr = true
			end

			if tokenPair[2] == "memREG" then
				if not REG then
					destBit = 0
				end
				if luasm.RMField[tokenPair[1]] then
					if not RM then
						RM = luasm.RMField[tokenPair[1]]
					end
				else
					table.insert(errors, {"Invalid address register", i})
					break
				end
			end

			if tokenPair[2] == "memPLUS" and instFormat[_+1] and instFormat[_-1] then
				if instFormat[_-1][2] == "memREG" and instFormat[_+1][2] == "memIMM" then --[bx + 1]
					instFormat[_+1][2] = "DISP" --change token memIMM to DISP
					instBytes.displacementByte = instFormat[_+1][1] --the actual integer
					if dualREG then
						MOD = 3
					elseif instBytes.displacementByte <= 255 then
						MOD = 1
					elseif instBytes.displacementByte <= 65535 then
						MOD = 2
					end
				elseif instFormat[_-1][2] == "memREG" and instFormat[_+1][2] == "memREG" then
					--print(instFormat[_-1][1].."_"..instFormat[_+1][1])
					RM = luasm.RMField[instFormat[_-1][1].."_"..instFormat[_+1][1]]
					--print("GOT RM")
				end
			elseif tokenPair[2] == "memPLUS" and (not instFormat[_+1] or not instFormat[_-1]) then
				print("Incomplete expression")
			end

			if tokenPair[2] == "SIZE" then
				local opSize = luasm.getRegSize(tokenPair[1])
				if operandSize == nil then
					operandSize = opSize
				else
					if operandSize ~= opSize then
						table.insert(errors, {"Operand size mismatch", i})
						break
					end
				end
			end

			print(tokenPair[2])
		end

		if alreadyEncoded then goto endEncode end

		if not operandSize then
			table.insert(errors, {"Operand size not specified", i})
			break
		end

		if #errors > 0 then break end

		if REG and RM then
			instBytes.modRMByte = MOD
			instBytes.modRMByte = bit.shl(instBytes.modRMByte, 3)
			instBytes.modRMByte = bit.OR(instBytes.modRMByte, REG)
			instBytes.modRMByte = bit.shl(instBytes.modRMByte, 3)
			instBytes.modRMByte = bit.OR(instBytes.modRMByte, RM)
		end

		if operandSize == "BYTE" or has_SREG then
			sizeBit = 0
		elseif operandSize == "WORD" then 
			sizeBit = 1
		end

		if sizeBit then
			instBytes.opcodeByte = bit.OR(instBytes.opcodeByte, sizeBit)
		end

		if destBit then
			instBytes.opcodeByte = bit.OR(instBytes.opcodeByte, destBit)
		end
		--print((operandSize or "--").." "..string.format("%x", (instBytes.opcodeByte or "0")).." "..string.format("%x", (instBytes.modRMByte or "0")).." "..string.format("%x", (instBytes.displacementByte or "0")).." "..string.format("%x", (instBytes.immediateByte or "0")))
		
		::isInc::

		if instBytes.opcodeByte then table.insert(outputbin, instBytes.opcodeByte) end
		if instBytes.modRMByte then table.insert(outputbin, instBytes.modRMByte) end

		if instBytes.displacementByte then
			if (instBytes.displacementByte > 255 and instBytes.displacementByte < 65536) or isImmMemAddr then
				local firstByte = bit.shl(instBytes.displacementByte, 24)
				firstByte = bit.shr(firstByte, 24)
				local secondByte = bit.shr(instBytes.displacementByte, 8)
				secondByte = bit.shl(secondByte, 24)
				secondByte = bit.shr(secondByte, 24)
				table.insert(outputbin, firstByte)
				table.insert(outputbin, secondByte)
			else
				table.insert(outputbin, instBytes.displacementByte)
			end
		end

		if instBytes.immediateByte then 
			if operandSize == "BYTE" then
				local immByte = bit.shl(instBytes.immediateByte, 24)
				immByte = bit.shr(immByte, 24)
				table.insert(outputbin, immByte)
			elseif operandSize == "WORD" then
			print("what")
				local firstByte = bit.shl(instBytes.immediateByte, 24)
				firstByte = bit.shr(firstByte, 24)
				local secondByte = bit.shr(instBytes.immediateByte, 8)
				secondByte = bit.shl(secondByte, 24)
				secondByte = bit.shr(secondByte, 24)
				table.insert(outputbin, firstByte)
				table.insert(outputbin, secondByte)
			end
		end
		::endEncode::
	end

	local outStr = ""
	for i,v in pairs(outputbin) do
		local outStrHex = string.format("%x", v)
		if string.len(outStrHex) < 2 then
			outStrHex = "0"..outStrHex
		end
		outStr = outStr..outStrHex.." "
	end
	print(outStr)
	return errors
end

return luasm
