--[[
	Package: Extensions.Entity

	Extension functions for the <Entity: https://wiki.facepunch.com/gmod/Entity> metatable.
]]

-- Group: Methods
-----------------

local entity = FindMetaTable("Entity")

if SERVER then
	--[[
		Server: SetForceTransmit

		Forces the entity to be considered in <PVS: https://developer.valvesoftware.com/wiki/PVS> for networking purposes.

		Parameters:
			<bool: Types.bool> force - true to force the entity to always transmit, false to make it obey normal PVS rules.

		Example:
			This will make NPC's and players always transmit, allowing their positions to be known in real-time even when in another room.
			--- Lua
			if SERVER then
				hook.Add("OnEntityCreated", "ForceTransmitMobs", function(ent)
					if IsValid(ent) and (ent:IsNPC() or ent:IsPlayer()) then
						ent:SetForceTransmit(true)
					end
				end)
			end
			---
	]]
	function entity:SetForceTransmit(force)
		if force then
			self:AddEFlags(EFL_IN_SKYBOX)
		else
			self:RemoveEFlags(EFL_IN_SKYBOX)
		end
	end
end

--[[
	Shared: ClearBodyGroups

	Resets all of an entity's bodygroups to their default value.
]]
function entity:ClearBodyGroups()
	for i = 0, self:GetNumBodyGroups() - 1 do
		self:SetBodygroup(i, 0)
	end
end
