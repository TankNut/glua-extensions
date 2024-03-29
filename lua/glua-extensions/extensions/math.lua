--[[
	Package: Libraries.math

	Extension functions for the <math: https://wiki.facepunch.com/gmod/math> Libraries.
]]

-- Group: Functions
-------------------

--[[
	Shared: Sign

	Returns the <sign: https://en.wikipedia.org/wiki/Sign_(mathematics)> of a number.

	Parameters:
		<number: Types.number> value - The number to get the sign for.
	
	Returns:
		<number: Types.number> - The sign of the value. This is either *0* for a value of 0, *-1* for a negative number or *1* for a positive number.
]]
function math.Sign(value)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	end

	return 0
end

--[[
	Shared: InRange

	Checks whether a number falls within a specific inclusive range.

	Parameters:
		<number: Types.number> value - The number to check.
		<number: Types.number> min - The minimum value to compare against.
		<number: Types.number> max - The maximum value to compare against.
	
	Returns:
		<bool: Types.bool> - Whether the number lies within the provided range.
]]
function math.InRange(value, min, max)
	return value >= min and value <= max
end

--[[
	Shared: ClampedRemap

	Combines the functionality of <math.Remap: https://wiki.facepunch.com/gmod/math.Remap> and <math.Clamp: https://wiki.facepunch.com/gmod/math.Clamp>.

	Parameters:
		<number: Types.number> value - The number to remap.
		<number: Types.number> inMin - The minimum of the initial range.
		<number: Types.number> inMax - The maximum of the initial range.
		<number: Types.number> outMin - The minimum of the new range.
		<number: Types.number> outMax - The maximum of the new range.
	
	Returns:
		<number: Types.number> - The number, remapped to the new range and clamped between it's values.
]]
function math.ClampedRemap(value, inMin, inMax, outMin, outMax)
	return math.Clamp(
		math.Remap(value, inMin, inMax, outMin, outMax),
		math.min(outMin, outMax),
		math.max(outMin, outMax)
	)
end
