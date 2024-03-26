local entity = FindMetaTable("Entity")

if SERVER then
	function entity:SetForceTransmit(force)
		if force then
			self:AddEFlags(EFL_IN_SKYBOX)
		else
			self:RemoveEFlags(EFL_IN_SKYBOX)
		end
	end
end
