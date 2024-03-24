local meta = FindMetaTable("Entity")

if SERVER then
	function meta:SetForceTransmit(force)
		if force then
			self:AddEFlags(EFL_IN_SKYBOX)
		else
			self:RemoveEFlags(EFL_IN_SKYBOX)
		end
	end
end
