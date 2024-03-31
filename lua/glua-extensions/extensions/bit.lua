--[[
	Package: Extensions.bit

	Extension functions for the <bit: https://wiki.facepunch.com/gmod/bit> Library.
]]

-- Group: Functions
-------------------

--[[
	Shared: bit.Pack

	Compresses a set of unsigned integers into the space of a single number.

	Note:
		For most use cases it is recommended to use <encoders: Classes.Encoder> instead.

	Parameters:
		<number: Types.number> bitCount - The amount of bits to allocate per number.
		<number: Types.number> ... - Any amount of unsigned integers to fit into the resulting integer, trying to fit more than 32 bits into a single number will result in an error being thrown.

	Returns:
		<number: Types.number> - The packed integer.

	See Also:
		<bit.Unpack>
]]
function bit.Pack(bitCount, ...)
	local args = {...}

	assert(#args * bitCount <= 32, "bitCount exceeds limit")

	local limit = 2 ^ bitCount - 1
	local num = 0

	for k, v in ipairs(args) do
		num = num + bit.lshift(math.Clamp(v, 0, limit), (k - 1) * bitCount)
	end

	return num
end

--[[
	Shared: bit.Unpack

	Decompresses a packed unsigned integer back into it's constituent numbers.

	Parameters:
		<number: Types.number> bitCount - The amount of bits allocated per number.
		<number: Types.number> num - The packed integer.

	Returns:
		<number: Types.number> ... - The unpacked integers, the amount of args returned is equal to the floored value of 32 / bitCount.

	See Also:
		<bit.Pack>
]]
function bit.Unpack(bitCount, num)
	assert(bitCount <= 32, "bitCount exceeds limit")

	local count = math.floor(32 / bitCount)
	local returns = {}
	local limit = 2 ^ bitCount - 1

	for i = 1, count do
		returns[i] = bit.band(bit.rshift(num, bitCount * (i - 1)), limit)
	end

	return unpack(returns)
end
