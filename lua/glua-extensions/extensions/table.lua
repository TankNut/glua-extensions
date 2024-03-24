-- Returns a new table populated with the results of calling `callback` on every entry.
-- Preserves table keys.
function table.Map(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		res[k] = callback(v, k)
	end

	return res
end

-- Returns a new table populated with values that `callback` returned true for.
-- Preserves table keys.
function table.Filter(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		if callback(v, k) then
			res[k] = v
		end
	end

	return res
end

-- Returns a new table populated with values that `callback` returned true for.
-- Does not preserve table keys but always returns a sequential table.
function table.FilterSequential(tab, callback)
	local res = {}

	for k, v in pairs(tab) do
		if callback(v, k) then
			table.insert(res, v)
		end
	end

	return res
end

-- Returns a new table containing all of the values of a table mapped as keys with their values set to `true`.
function table.Lookup(tab)
	local res = {}

	for _, v in pairs(tab) do
		res[v] = true
	end

	return res
end
