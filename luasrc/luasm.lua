local luasm = {}
luasm.RETURN_CHAR = string.char(10)
luasm.SPACE_CHAR = " "
luasm.UNDERSCORE_CHAR = "_"

luasm.TOKEN = {
	mov = "OP_MOV",
	add = "OP_ADD",
	sub = "OP_SUB",
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
}

luasm.REG_SIZES = {
	l = "BYTE",
	x = "WORD",
	e = "DWORD",
	r = "QWORD",
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
	REG_BX = 7
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
	local tokenLow = string.lower(token)
	for char, size in pairs(luasm.REG_SIZES) do
		if string.find(tokenLow, char, 4) then
			return size
		end
	end
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

function luasm.assemble(lines, mem_tokens)

	local errors = {}
	local imm = nil
	for i,line in pairs(lines) do
		local instFormat = {}
		local proper = false
		local operands = 0
		local opcodes = 0

		local opcodeByte
		local opcodeToken
		local modRMByte --MOD dictates register addressing (RA) modes
		local MOD = 0
		local REG
		local RM
		local dualREG = false
		local displacementByte --RA displacement (if applicable)
		local immediateByte --immediate value (if applicable)
		local immReg --sets REG field in modRMByte if immediate operand
		local operandSize
		local destBit --dictates dest/src of R/M and REG fields (opcodeByte bit 1)
		local sizeBit --dictates instruction size (opcodeByte bit 0)

		for b = 1,#line do
			local token, tokenType = luasm:FindToken(line[b])
			if token then
				if mem_tokens[i] and mem_tokens[i][b] then
					tokenType = "mem"..tokenType
				end

				table.insert(instFormat, {token, tokenType})
				
				if tokenType == "OP" then
					opcodes = opcodes + 1
					opcodeToken = token
					opcodeByte = luasm.OPCODES[token]
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
				end
			end

			if tokenPair[2] == "IMM" then
				immediateByte = tokenPair[1]
				opcodeByte = luasm.IMM_OPCODES[opcodeToken]
				REG = luasm.IMM_OPCODE_EXT[opcodeToken]
			end

			if tokenPair[2] == "memIMM" then
				if not REG then
					destBit = 0
				end
				RM = 6
				displacementByte = tokenPair[1]
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
					displacementByte = instFormat[_+1][1] --the actual integer
					if dualREG then
						MOD = 3
					elseif displacementByte <= 255 then
						MOD = 1
					elseif displacementByte <= 65535 then
						MOD = 2
					end
				elseif instFormat[_-1][2] == "memREG" and instFormat[_+1][2] == "memREG" then
				print(instFormat[_-1][1].."_"..instFormat[_+1][1])
					RM = luasm.RMField[instFormat[_-1][1].."_"..instFormat[_+1][1]]
					print("GOT RM")
				end
			elseif tokenPair[2] == "memPLUS" and (not instFormat[_+1] or not instFormat[_-1]) then
				print("Incomplete expression")
			end

			print(tokenPair[2])
		end

		if #errors > 0 then break end

		if REG and RM then
			modRMByte = MOD
			modRMByte = bit.shl(modRMByte, 3)
			modRMByte = bit.OR(modRMByte, REG)
			modRMByte = bit.shl(modRMByte, 3)
			modRMByte = bit.OR(modRMByte, RM)
		end

		if operandSize == "BYTE" then
			sizeBit = 0
		elseif operandSize == "WORD" then 
			sizeBit = 1
		end

		if sizeBit then
			opcodeByte = bit.OR(opcodeByte, sizeBit)
		end

		if destBit then
			opcodeByte = bit.OR(opcodeByte, destBit)
		end
		print((operandSize or "--").." "..string.format("%x", (opcodeByte or "0")).." "..string.format("%x", (modRMByte or "0")).." "..string.format("%x", (displacementByte or "0")).." "..string.format("%x", (immediateByte or "0")))
	end

	
	
	return errors
end

return luasm
