--[[
	Package: Classes.Encoder

	A class that packs sets of unsigned integers into a single number.
]]

-- Group: Functions
-------------------

encoder = encoder or {}

local CLASS = FindMetaTable("Encoder")

if not CLASS then
	CLASS = {}
	CLASS.__index = CLASS

	debug.getregistry().Encoder = CLASS
end

--[[
	Shared: encoder.New

	Creates a new bit encoder.

	Parameters:
		<number: Types.number> bitSpace - The amount of bits to allocate, this will prevent overflows when encoding into a data type that has limited precision or space like a float or a signed integer.
		<number: Types.number> offset - The static offset to apply to the resulting number. Enables you to use all of the space available in signed integers.
		<number: Types.number> ... - Any amount of numbers that represent the range of digits you want to encode. The resulting range will be equal to [0, n) (0 inclusive to n exclusive). Meaning that a number of 128 will support a range of 0 to 127.
	
	Returns:
		<Encoder> - The new encoder object.
]]
function encoder.New(bitSpace, offset, ...)
	local bases = {...}
	local count = #bases
	local maxCoef = 1

	assert(count > 0, "attempt to create encoder without any values")

	for i = 1, count do
		maxCoef = maxCoef * bases[i]
	end

	assert(maxCoef - 1 < 2^bitSpace, string.format(
		"format exceeds available number space (requires %s bits of space, only have %s)",
		math.ceil(math.log(maxCoef, 2)), bitSpace))

	return setmetatable({
		BitSpace = bitSpace,
		Offset = offset,
		Bases = bases,
		Count = count
	}, CLASS)
end

--[[
	Shared: encoder.Double

	Creates a new bit encoder pre-configured for a double. A double can store 2^52 before losing precision.

	Parameters:
		<number: Types.number> ... - Any amount of numbers that represent the range of digits you want to encode.
	
	Returns:
		<Encoder> - The new encoder object.
]]
function encoder.Double(...)
	return encoder.New(52, 0, ...)
end

--[[
	Shared: encoder.Float

	Creates a new bit encoder pre-configured for a float. A double can store 2^23 before losing precision.

	Parameters:
		<number: Types.number> ... - Any amount of numbers that represent the range of digits you want to encode.
	
	Returns:
		<Encoder> - The new encoder object.
]]
function encoder.Float(...)
	return encoder.New(23, 0, ...)
end

--[[
	Shared: encoder.Double

	Creates a new bit encoder pre-configured for an unsigned 32-bit integer.

	Parameters:
		<number: Types.number> ... - Any amount of numbers that represent the range of digits you want to encode.
	
	Returns:
		<Encoder> - The new encoder object.
]]
function encoder.UInt(...)
	return encoder.New(32, 0, ...)
end

--[[
	Shared: encoder.Double

	Creates a new bit encoder pre-configured for a signed 32-bit integer.

	Parameters:
		<number: Types.number> ... - Any amount of numbers that represent the range of digits you want to encode.
	
	Returns:
		<Encoder> - The new encoder object.
]]
function encoder.Int(...)
	return encoder.New(32, -2^16, ...)
end

-- Group: Members
-----------------

--[[
	Shared: BitSpace
	*Type:* <number: Types.number>

	The amount of bits the encoder is configured to store.
]]

--[[
	Shared: Offset
	*Type:* <number: Types.number>

	The offset that is applied when encoding or decoding numbers. This lets you fit larger numbers into signed integers.
]]

--[[
	Shared: Bases
	*Type:* <table: Types.table>

	The format used by the encoder, contains all of the individual ranges.
]]

--[[
	Shared: Count
	*Type:* <number: Types.number>

	The amount of values the encoder is configured to work with.
]]

-- Group: Methods
-----------------

--[[
	Shared: Encode

	Encodes a series of numbers into a single number.

	Parameters:
		<number: Types.number> ... - Any amount of numbers to encode, all of them should fit inside of the allocated space defined by the encoder object. Decimals will be truncated.
	
	Returns:
		<number: Types.number> - The resulting encoded number.
]]
function CLASS:Encode(...)
	local argCount = select("#", ...)

	assert(argCount <= self.Count, string.format("attempt to encode %s values with only %s allocated", argCount, self.Count))

	local acc = self.Offset
	local coef = 1

	for i = argCount, 1, -1 do
		local v = math.Truncate(select(i, ...))

		assert(v >= 0 and v < self.Bases[i], string.format(
			"attempt to encode out-of-range value: %s (expected [0, %s])",
			v, self.Bases[i] - 1))

		acc = acc + coef * v
		coef = coef * self.Bases[i]
	end

	return acc
end

--[[
	Shared: Decode

	Decodes a previously encoded number back into a table of numbers.

	Parameters:
		<number: Types.number> num - A number previously encoded with <Encode>.
	
	Returns:
		<table: Types.table> - A table containing all of the previously encoded numbers *left-padded with 0's*.
]]
function CLASS:Decode(num)
	assert(num % 1 == 0, "received malformed number (float?)")

	num = num - self.Offset

	local values = {}
	local k = 1

	for i = self.Count, 1, -1 do
		values[i] = math.floor(num % (k * self.Bases[i]) / k)

		k = k * self.Bases[i]
	end

	return values
end
