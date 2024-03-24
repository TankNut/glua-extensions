module("primitives", package.seeall)

-- Default units are completely arbitrary and only exist to serve as the central pivot that conversion happens around.
-- E.g. length units are all converted first to meters, then to whatever value was put in.

-- Converts a value from one unit to another based on the provided data table.
function Convert(data, value, from, to)
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

-- Default unit: Meter
LengthUnits = {
	-- Source units sourced from https://developer.valvesoftware.com/wiki/Dimensions_(Half-Life_2_and_Counter-Strike:_Source)
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

-- Converts a length value from one unit to another.
function Length(value, from, to)
	return Convert(LengthUnits, value, from, to)
end

-- Default unit: Kilogram
MassUnits = {
	-- Metric
	mg = 0.000001, -- Miligrams
	g = 0.001, -- Grams
	kg = 1, -- Kilograms
	t = 1000, -- Tons
	-- Imperial
	lb = 0.45359237 -- Pounds
}

-- Converts a mass value from one unit to another.
function Mass(value, from, to)
	return Convert(MassUnits, value, from, to)
end

-- Default unit: Kelvin
TemperatureUnits = {
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

-- Converts a temperature value from one unit to another.
function Temperature(value, from, to)
	return Convert(TemperatureUnits, value, from, to)
end

-- Default unit: Second
TimeUnits = {
	ms = 0.001, -- Miliseconds
	s = 1, -- Seconds
	m = 60, -- Minutes
	h = 3600, -- Hours
	d = 86400, -- Days
	w = 604800, -- Weeks
	mon = 2628000, -- Months (as 365 days divided by 12 months)
	y = 31536000 -- Years
}

-- Converts a time value from one unit to another.
function Time(value, from, to)
	return Convert(TimeUnits, value, from, to)
end
