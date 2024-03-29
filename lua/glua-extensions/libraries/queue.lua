--[[
	Class: Classes.Queue

	A <first-in-first-out: https://en.wikipedia.org/wiki/Queue_(abstract_data_type)> data structure.
]]

-- Group: Functions
-------------------

local CLASS = {}
local META = {__index = CLASS}

--[[
	Shared: util.Queue

	Creates a new Queue object.
	
	Returns:
		<Queue> - The new Queue object.
]]
function util.Queue()
	return setmetatable({
		First = 0,
		Last = -1,
		Items = {}
	}, META)
end

-- Group: Members
-----------------

--[[
	Shared: First
	*Type:* <number: Types.number>

	The index into <Items> that contains the item at the front of the queue.
]]

--[[
	Shared: Last
	*Type:* <number: Types.number>

	The index into <Items> that contains the item at the back of the queue.
]]

--[[
	Shared: Items
	*Type:* <table: Types.table>

	The table that contains all of the items stored in the queue.
]]

-- Group: Methods
-----------------

--[[
	Shared: Push

	Pushes an item onto the back of the queue.

	Parameters:
		<any: Types.any> item - The item to push onto the queue.
]]
function CLASS:Push(item)
	local index = self.Last + 1

	self.Last = index
	self.Items[index] = item
end

--[[
	Shared: Pop

	Removes the first item in line from the queue and returns it.

	Returns:
		<any: Types.any> - The first item in line or `nil` if the queue is empty.
]]
function CLASS:Pop()
	local index = self.First

	if index > self.Last then
		return -- Empty
	end

	local item = self.Items[index]

	self.Items[index] = nil
	self.First = index + 1

	return item
end

--[[
	Shared: Count

	Returns the number of items currently in the queue.

	Returns:
		<number: Types.number> - The amount of items currently in the queue.
]]
function CLASS:Count()
	return self.Last - self.First + 1
end

--[[
	Shared: Empty

	Removes all items from the queue, effectively resetting it.
]]
function CLASS:Empty()
	self.First = 0
	self.Last = -1
	table.Empty(self.Items)
end
