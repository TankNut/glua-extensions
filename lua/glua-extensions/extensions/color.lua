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

	See Also:
		<HexToColor>

		<GetHex>
]]
function ColorToHex(color, alpha)
	if alpha then
		return "#" .. bit.tohex(bit.Pack(8, color.a, color.b, color.g, color.r), 8):upper()
	else
		return "#" .. bit.tohex(bit.Pack(8, color.b, color.g, color.r), 6):upper()
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
	
	See Also:
		<ColorToHex>
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
		local a, b, g, r = bit.Unpack(8, hex)

		return Color(r, g, b, a)
	else
		local b, g, r = bit.Unpack(8, hex)

		return Color(r, g, b)
	end
end

local colors = {
	aliceblue = {240, 248, 255},
	antiquewhite = {250, 235, 215},
	aqua = {0, 255, 255},
	aquamarine = {127, 255, 212},
	azure = {240, 255, 255},
	beige = {245, 245, 220},
	bisque = {255, 228, 196},
	black = {0, 0, 0},
	blanchedalmond = {255, 235, 205},
	blue = {0, 0, 255},
	blueviolet = {138, 43, 226},
	brown = {165, 42, 42},
	burlywood = {222, 184, 135},
	cadetblue = {95, 158, 160},
	chartreuse = {127, 255, 0},
	chocolate = {210, 105, 30},
	coral = {255, 127, 80},
	cornflowerblue = {100, 149, 237},
	cornsilk = {255, 248, 220},
	crimson = {220, 20, 60},
	cyan = {0, 255, 255},
	darkblue = {0, 0, 139},
	darkcyan = {0, 139, 139},
	darkgoldenrod = {184, 134, 11},
	darkgray = {169, 169, 169},
	darkgrey = {169, 169, 169},
	darkgreen = {0, 100, 0},
	darkkhaki = {189, 183, 107},
	darkmagenta = {139, 0, 139},
	darkolivegreen = {85, 107, 47},
	darkorange = {255, 140, 0},
	darkorchid = {153, 50, 204},
	darkred = {139, 0, 0},
	darksalmon = {233, 150, 122},
	darkseagreen = {143, 188, 143},
	darkslateblue = {72, 61, 139},
	darkslategray = {47, 79, 79},
	darkslategrey = {47, 79, 79},
	darkturquoise = {0, 206, 209},
	darkviolet = {148, 0, 211},
	deeppink = {255, 20, 147},
	deepskyblue = {0, 191, 255},
	dimgray = {105, 105, 105},
	dimgrey = {105, 105, 105},
	dodgerblue = {30, 144, 255},
	firebrick = {178, 34, 34},
	floralwhite = {255, 250, 240},
	forestgreen = {34, 139, 34},
	fuchsia = {255, 0, 255},
	gainsboro = {220, 220, 220},
	ghostwhite = {248, 248, 255},
	gold = {255, 215, 0},
	goldenrod = {218, 165, 32},
	gray = {128, 128, 128},
	grey = {128, 128, 128},
	green = {0, 128, 0},
	greenyellow = {173, 255, 47},
	honeydew = {240, 255, 240},
	hotpink = {255, 105, 180},
	indianred = {205, 92, 92},
	indigo = {75, 0, 130},
	ivory = {255, 255, 240},
	khaki = {240, 230, 140},
	lavender = {230, 230, 250},
	lavenderblush = {255, 240, 245},
	lawngreen = {124, 252, 0},
	lemonchiffon = {255, 250, 205},
	lightblue = {173, 216, 230},
	lightcoral = {240, 128, 128},
	lightcyan = {224, 255, 255},
	lightgoldenrodyellow = {250, 250, 210},
	lightgray = {211, 211, 211},
	lightgrey = {211, 211, 211},
	lightgreen = {144, 238, 144},
	lightpink = {255, 182, 193},
	lightsalmon = {255, 160, 122},
	lightseagreen = {32, 178, 170},
	lightskyblue = {135, 206, 250},
	lightslategray = {119, 136, 153},
	lightslategrey = {119, 136, 153},
	lightsteelblue = {176, 196, 222},
	lightyellow = {255, 255, 224},
	lime = {0, 255, 0},
	limegreen = {50, 205, 50},
	linen = {250, 240, 230},
	magenta = {255, 0, 255},
	maroon = {128, 0, 0},
	mediumaquamarine = {102, 205, 170},
	mediumblue = {0, 0, 205},
	mediumorchid = {186, 85, 211},
	mediumpurple = {147, 112, 219},
	mediumseagreen = {60, 179, 113},
	mediumslateblue = {123, 104, 238},
	mediumspringgreen = {0, 250, 154},
	mediumturquoise = {72, 209, 204},
	mediumvioletred = {199, 21, 133},
	midnightblue = {25, 25, 112},
	mintcream = {245, 255, 250},
	mistyrose = {255, 228, 225},
	moccasin = {255, 228, 181},
	navajowhite = {255, 222, 173},
	navy = {0, 0, 128},
	oldlace = {253, 245, 230},
	olive = {128, 128, 0},
	olivedrab = {107, 142, 35},
	orange = {255, 165, 0},
	orangered = {255, 69, 0},
	orchid = {218, 112, 214},
	palegoldenrod = {238, 232, 170},
	palegreen = {152, 251, 152},
	paleturquoise = {175, 238, 238},
	palevioletred = {219, 112, 147},
	papayawhip = {255, 239, 213},
	peachpuff = {255, 218, 185},
	peru = {205, 133, 63},
	pink = {255, 192, 203},
	plum = {221, 160, 221},
	powderblue = {176, 224, 230},
	purple = {128, 0, 128},
	rebeccapurple = {102, 51, 153},
	red = {255, 0, 0},
	rosybrown = {188, 143, 143},
	royalblue = {65, 105, 225},
	saddlebrown = {139, 69, 19},
	salmon = {250, 128, 114},
	sandybrown = {244, 164, 96},
	seagreen = {46, 139, 87},
	seashell = {255, 245, 238},
	sienna = {160, 82, 45},
	silver = {192, 192, 192},
	skyblue = {135, 206, 235},
	slateblue = {106, 90, 205},
	slategray = {112, 128, 144},
	slategrey = {112, 128, 144},
	snow = {255, 250, 250},
	springgreen = {0, 255, 127},
	steelblue = {70, 130, 180},
	tan = {210, 180, 140},
	teal = {0, 128, 128},
	thistle = {216, 191, 216},
	tomato = {255, 99, 71},
	turquoise = {64, 224, 208},
	violet = {238, 130, 238},
	wheat = {245, 222, 179},
	white = {255, 255, 255},
	whitesmoke = {245, 245, 245},
	yellow = {255, 255, 0},
	yellowgreen = {154, 205, 50}
}

--[[
	Shared: NamedColor

	Creates a new color based off of a named color from the <CSS color specification: https://www.w3.org/TR/css-color-4/#named-colors>.

	Parameters:
		<string: Types.string> name - The case-insensitive name of a color.
		<number: Types.number>? alpha - The alpha value to assign to the color. *Default:* 255

	Returns:
		<Color: Types.Color> - The corresponding color, or `nil` if no matches were found.
]]
function NamedColor(name, alpha)
	name = name:lower()

	if name == "transparent" then
		return Color(255, 255, 255, 0)
	end

	local data = colors[name]

	if data then
		alpha = alpha and math.Clamp(alpha, 0, 255) or 255

		return Color(data[1], data[2], data[3], alpha)
	end
end

-- Group: Fixes
---------------

local meta = FindMetaTable("Color")

local function patchFunction(name, location)
	location = location or _G

	local func = location[name]

	if debug.getinfo(func, "S").what == "C" then
		location[name] = function(...)
			return setmetatable(func(...), meta)
		end
	end
end

--[[
	Shared: HSVToColor

	HSVToColor now returns a color with the correct metatable set.

	--- Prototype
	function HSVToColor(hue, saturation, value)
	---
]]
patchFunction("HSVToColor")

--[[
	Shared: HSLToColor

	HSLToColor now returns a color with the correct metatable set.

	--- Prototype
	function HSLToColor(hue, saturation, lightness)
	---
]]
patchFunction("HSLToColor")

-- Group: Methods
-----------------

--[[
	Shared: GetHex

	Returns the hexidecimal color string for this color object.

	Parameters:
		<bool: Types.bool>? alpha - Whether to include the alpha in the output. *Default:* false

	Returns:
		<string: Types.string> - The hex string.

	See Also:
		<ColorToHex>
]]
function meta:GetHex(alpha)
	return ColorToHex(self, alpha)
end

--[[
	Shared: GetInverted

	Returns an inverted version of this color.

	Returns:
		<Color: Types.Color> - A copy of the color with it's R G and B values inverted.
]]
function meta:GetInverted()
	return Color(255 - self.r, 255 - self.g, 255 - self.b, self.a)
end

local function sRGBToLinear(val)
	val = val / 255

	if val < 0.04045 then
		return val / 12.92
	else
		return math.pow((val + 0.055) / 1.055, 2.4)
	end
end

function meta:GetLuminance()
	return 0.2126 * sRGBToLinear(self.r)
		+ 0.7152 * sRGBToLinear(self.g)
		+ 0.0722 * sRGBToLinear(self.b)
end
