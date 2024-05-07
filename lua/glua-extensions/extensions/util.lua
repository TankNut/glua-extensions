--[[
	Package: Extensions.util

	Extension functions for the <util: https://wiki.facepunch.com/gmod/util> library.
]]

-- Group: Functions
-------------------

if SERVER then
	--[[
		Server: Explosion

		Creates an explosion at a given location.

		Parameters:
			<Vector: Types.Vector> pos - The position to explode.
			<Angle: Types.Angle>? ang - The angle of the explosion effect.
			<Entity: Types.Entity>? owner - The entity that owns the explosion, used for crediting kills.
			<Entity: Types.Entity>? inflictor - The entity to credit as the weapon for any kills made with this explosion.
			<number: Types.number> magnitude - The magnitude of the explosion, determines the radius and damage.
			<number: Types.number>? radius - Allows you to override the explosion's radius.
			<bool: Types.bool>? doDamage - Whether to deal damage. *Default:* true
	]]
	function util.Explosion(pos, ang, owner, inflictor, magnitude, radius, doDamage)
		doDamage = doDamage or true

		local flags = bit.bor(8, 32, 1024) + (doDamage and 0 or 1)
		local ent = ents.Create("env_explosion")

		ent:SetPos(pos)
		ent:SetAngles(ang or angle_zero)

		if IsValid(owner) then
			ent:SetOwner(owner)
		end

		ent:SetKeyValue("spawnflags", flags)
		ent:SetKeyValue("iMagnitude", magnitude)

		if radius then
			ent:SetKeyValue("iRadiusOverride", radius)
		end

		if IsValid(inflictor) then
			ent:SetSaveValue("m_hInflictor", inflictor)
		end

		ent:Spawn()
		ent:Fire("Explode")
	end
end
