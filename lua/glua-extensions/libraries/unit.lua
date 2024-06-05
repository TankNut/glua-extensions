--[[
	Package: Libraries.unit

	A library for converting quantities between different units.
]]

-- Group: Functions
-------------------

unit = unit or {}

--[[
	Shared: Convert

	Converts the supplied value from one unit to another based on the supplied <UnitData>.

	Parameters:
		<UnitData: UnitData> data - The data source to use for the conversion.
		<number: Types.number> value - The value to convert.
		<string: Types.string> from - The unit to convert the value from.
		<string: Types.string> to - The unit to convert the value to.
	
	Returns:
		<number: Types.number> - The converted value.
]]
function unit.Convert(data, value, from, to)
	from = assert(data[from:lower()], "unit.Convert: unknown conversion unit: " .. from:lower())
	to = assert(data[to:lower()], "unit.Convert: unknown conversion unit: " .. to:lower())

	if from != 1 then
		value = isnumber(from) and value * from or from.From(value)
	end

	if to != 1 then
		value = isnumber(to) and value / to or to.To(value)
	end

	return value
end

--[[
	Shared: Length

	Converts the supplied value from one <length: LengthUnits> unit to another.

	Parameters:
		<number: Types.number> value - The value to convert.
		<string: Types.string> from - The unit to convert the value from.
		<string: Types.string> to - The unit to convert the value to.
	
	Returns:
		<number: Types.number> - The converted value.
]]
function unit.Length(value, from, to)
	return unit.Convert(unit.LengthUnits, value, from, to)
end

--[[
	Shared: Mass

	Converts the supplied value from one <mass: MassUnits> unit to another.

	Parameters:
		<number: Types.number> value - The value to convert.
		<string: Types.string> from - The unit to convert the value from.
		<string: Types.string> to - The unit to convert the value to.
	
	Returns:
		<number: Types.number> - The converted value.
]]
function unit.Mass(value, from, to)
	return unit.Convert(unit.MassUnits, value, from, to)
end

--[[
	Shared: Temperature

	Converts the supplied value from one <temperature: TemperatureUnits> unit to another.

	Parameters:
		<number: Types.number> value - The value to convert.
		<string: Types.string> from - The unit to convert the value from.
		<string: Types.string> to - The unit to convert the value to.
	
	Returns:
		<number: Types.number> - The converted value.
]]
function unit.Temperature(value, from, to)
	return unit.Convert(unit.TemperatureUnits, value, from, to)
end

--[[
	Shared: Time

	Converts the supplied value from one <time: TimeUnits> unit to another.

	Parameters:
		<number: Types.number> value - The value to convert.
		<string: Types.string> from - The unit to convert the value from.
		<string: Types.string> to - The unit to convert the value to.
	
	Returns:
		<number: Types.number> - The converted value.
]]
function unit.Time(value, from, to)
	return unit.Convert(unit.TimeUnits, value, from, to)
end

-- Group: Structs
-----------------

--[[
	Shared: UnitData

	--- Lua
	local data = {
		["unit"] = 1, -- Direct
		["unit2"] = { -- Callbacks
			From = function(value) return value + 1 end,
			To = function(value) return value - 1 end
		}
	}
	---

	*Note:* Keys should be _lowercase only_ as units are passed through <string.lower: https://wiki.facepunch.com/gmod/string.lower>.
	
	Default units are completely arbitrary and only exist to serve as the central pivot that conversion happens around.
	E.g. length units are all converted first to meters, then to whatever value was put in.

	For direct conversion, numbers are first multiplied by the unit's value to standardize them and then divided by the other unit's value to translate them to the new unit.

	For callbacks, the To or From function are called based on which direction the value is moving.
]]


-- Group: Units
---------------

--[[
	Shared: LengthUnits

	Units used for expressing lengths and distances.

	Source units are sourced from <https://developer.valvesoftware.com/wiki/Dimensions_(Half-Life_2_and_Counter-Strike:_Source)>

	--- Lua
	unit.LengthUnits = {
		-- Source units
		u = 0.01905, -- Worldscale units: 1 foot = 16 units
		su = 0.3048, -- Skybox units: 1 foot = 1 unit
		cu = 0.2286, -- Character units: 1 foot = 12 units
		-- Metric
		mm = 0.001, -- Milimeters
		cm = 0.01, -- Centimeters
		m = 1, -- Meters
		km = 1000, -- Kilometers
		-- Imperial
		["in"] = 0.0254, -- Inches
		ft = 0.3048, -- Feet
		yd = 0.9144, -- Yards
		mi = 1609.344, -- Miles
		nmi = 1852 -- Nautical Miles
	}
	---
]]
unit.LengthUnits = {
	-- Source units
	u = 0.01905, -- Worldscale units: 1 foot = 16 units
	su = 0.3048, -- Skybox units: 1 foot = 1 unit
	cu = 0.2286, -- Character units: 1 foot = 12 units
	-- Metric
	mm = 0.001, -- Milimeters
	cm = 0.01, -- Centimeters
	m = 1, -- Meters
	km = 1000, -- Kilometers
	-- Imperial
	["in"] = 0.0254, -- Inches
	ft = 0.3048, -- Feet
	yd = 0.9144, -- Yards
	mi = 1609.344, -- Miles
	nmi = 1852 -- Nautical Miles
}

--[[
	Shared: MassUnits

	Units used for expressing weight.

	--- Lua
	unit.MassUnits = {
		-- Metric
		mg = 0.000001, -- Miligrams
		g = 0.001, -- Grams
		kg = 1, -- Kilograms
		t = 1000, -- Tons
		-- Imperial
		lb = 0.45359237 -- Pounds
	}
	---
]]
unit.MassUnits = {
	-- Metric
	mg = 0.000001, -- Miligrams
	g = 0.001, -- Grams
	kg = 1, -- Kilograms
	t = 1000, -- Tons
	-- Imperial
	lb = 0.45359237 -- Pounds
}

--[[
	Shared: TemperatureUnits

	Units used for expressing temperature.

	--- Lua
	unit.TemperatureUnits = {
		-- Metric
		c = {
			From = function(value) return value + 273.15 end,
			To = function(value) return value - 273.15 end
		},
		k = 1,
		-- Imperial
		f = {
			From = function(value) return (value - 32) * (5 / 9) + 273.15 end,
			To = function(value) return (value - 273.15) * (9 / 5) + 32 end
		}
	}
	---
]]
unit.TemperatureUnits = {
	-- Metric
	c = {
		From = function(value) return value + 273.15 end,
		To = function(value) return value - 273.15 end
	},
	k = 1,
	-- Imperial
	f = {
		From = function(value) return (value - 32) * (5 / 9) + 273.15 end,
		To = function(value) return (value - 273.15) * (9 / 5) + 32 end
	}
}

--[[
	Shared: TimeUnits

	Units used for expressing time.

	--- Lua
	unit.TimeUnits = {
		ms = 0.001, -- Miliseconds
		s = 1, -- Seconds
		m = 60, -- Minutes
		h = 3600, -- Hours
		d = 86400, -- Days
		w = 604800, -- Weeks
		mon = 2628000, -- Months (as 365 days divided by 12 months)
		y = 31536000 -- Years
	}
	---
]]
unit.TimeUnits = {
	ms = 0.001, -- Miliseconds
	s = 1, -- Seconds
	m = 60, -- Minutes
	h = 3600, -- Hours
	d = 86400, -- Days
	w = 604800, -- Weeks
	mon = 2628000, -- Months (as 365 days divided by 12 months)
	y = 31536000 -- Years
}
