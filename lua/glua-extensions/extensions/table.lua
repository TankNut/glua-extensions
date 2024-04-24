--[[
	Package: Extensions.table

	Extension functions for the <table: https://wiki.facepunch.com/gmod/table> library.

	See Also:
		<https://wiki.facepunch.com/gmod/Beginner_Tutorial_Tables>
]]

-- Group: Functions
-------------------

--[[
	Shared: Map

	Returns a new table populated with the result of calling the callback function for each key-value pair.

	Parameters:
		<table: Types.table> tab - The table to map.
		<function: Types.function> callback - The callback to call for each key-value pair.
	
	Returns:
		<table: Types.table> - The newly populated table.
	
	Callback:
	--- Lua
	value = callback(value, key)
	---
]]
function table.Map(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		res[k] = callback(v, k)
	end

	return res
end

--[[
	Shared: Filter

	Returns a table populated with values that pass the filter function.

	This function preserves the original table keys.

	Parameters:
		<table: Types.table> tab - The table to map.
		<function: Types.function> callback - The function to use as a filter.
	
	Returns:
		<table: Types.table> - The filtered table.

	Callback:
	--- Lua
	ok = callback(value, key)
	---

	See Also:
		<table.FilterSequential>
]]
function table.Filter(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		if callback(v, k) then
			res[k] = v
		end
	end

	return res
end

--[[
	Shared: FilterSequential

	Returns a sequential table populated with values that pass the filter function.
	
	This function *does not* preserve the original table keys and instead returns a sequential table.

	Parameters:
		<table: Types.table> tab - The table to map.
		<function: Types.function> callback - The function to use as a filter.
	
	Returns:
		<table: Types.table> - The filtered table.

	Callback:
	--- Lua
	ok = callback(value, key)
	---

	See Also:
		<table.Filter>
]]
function table.FilterSequential(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		if callback(v, k) then
			table.insert(res, v)
		end
	end

	return res
end

--[[
	Shared: Lookup

	Returns a new table containing all of the values mapped to keys with their value set to true.

	Parameters:
		<table: Types.table> tab - The table to create a lookup for.
	
	Returns:
		<table: Types.table> - A lookup table based on the input table.
	
	Example:
		Uses a lookup table to check whether a value is a <bool: Types.bool> or a <string: Types.string>.
		---lua
		local lookup = table.Lookup({TYPE_BOOL, TYPE_STRING})

		function IsBoolOrString(value)
			return tobool(lookup[value])
		end

		print(IsBoolOrString(true)) -- true
		print(IsBoolOrString("Hello World!")) -- true
		print(IsBoolOrString({})) -- false
		---
]]
function table.Lookup(tab)
	local res = {}

	for _, v in pairs(tab) do
		res[v] = true
	end

	return res
end
