--[[
	Package: Extensions.Color

	<Color: https://wiki.facepunch.com/gmod/Color> related functions and metatable extensions.
]]

-- Group: Functions
-------------------

--[[
	Shared: ColorToHex

	Returns the hexidecimal color string for a color object. This will be in the format #RRGGBB or #RRGGBBAA depending on the value of the second argument.

	Parameters:
		<Color: Types.Color> color - The color to format.
		<bool: Types.bool>? alpha - Whether to include the alpha in the output. *Default:* false

	Returns:
		<string: Types.string> - The hex string.
]]
function ColorToHex(color, alpha)
	if alpha then
		return "#" .. bit.tohex(bit.Pack(8, color.r, color.g, color.b, color.a), 8):upper()
	else
		return "#" .. bit.tohex(bit.Pack(8, color.r, color.g, color.b), 8):upper()
	end
end

local function handleHexString(hex)
	hex = hex[1] == "#" and hex:sub(2) or hex

	if #hex == 3 or #hex == 4 then
		local exploded = string.Explode("", hex)

		for k, v in ipairs(exploded) do
			exploded[k] = v .. v
		end

		hex = table.concat(exploded)
	elseif #hex != 6 and #hex != 8 then
		return false
	end

	return hex
end

--[[
	Shared: HexToColor

	Translates a hex string to a color object. This handles the following formats:
		#RGB
		#RGBA
		#RRGGBB
		#RRGGBBAA

	Parameters:
		<string: Types.string> hex - The hex string to parse.

	Returns:
		<Color: Types.Color> - The resulting color or nil if an invalid format was passed.
]]
function HexToColor(hex)
	hex = handleHexString(hex)

	if not hex then
		return
	end

	local alpha = #hex == 8

	hex = tonumber(hex, 16)

	if not hex then
		return
	end

	if alpha then -- Includes alpha component
		return Color(bit.Unpack(8, hex))
	else
		local r, g, b = bit.Unpack(8, hex)

		return Color(r, g, b)
	end
end

-- Group: Methods
-----------------

local meta = FindMetaTable("Color")
