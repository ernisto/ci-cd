-- functions
local function from_hex_str(hex_str: string): buffer
	local buf = buffer.create(#hex_str)
	for i = 1, #hex_str do
		buffer.writeu8(buf, i - 1, string.byte(hex_str, i))
	end
	return buf
end
local function random(length: number): buffer
	local buf = buffer.create(length)
	for offset = 0, length - 1 do
		buffer.writeu8(buf, offset, math.random(0, 255))
	end
	return buf
end

-- module
return table.freeze {
	from_hex_str = from_hex_str,
	random = random,
}
