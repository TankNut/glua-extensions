--[[
	Package: Libraries.classify

	A library for handling NPC relationships in a simplified manner.
]]

-- Group: Functions
-------------------

classify = classify or {}

classify.Tracked = classify.Tracked or {}

classify.Relationships = classify.Relationships or {}

classify.ClassMap = classify.ClassMap or {}
classify.EntityMap = classify.EntityMap or {}
classify.BaseMap = classify.BaseMap or {}

classify.DefaultMap = {
	["player"] = CLASS_PLAYER,
	["proto_sniper"] = CLASS_PROTOSNIPER,
	["func_guntarget"] = CLASS_MILITARY,
	["apc_missile"] = CLASS_MISSILE,
	["grenade_pathfollower"] = CLASS_MISSILE,
	["env_flare"] = CLASS_FLARE,
	["xen_tree"] = CLASS_ALIEN_PREDATOR,
	["xen_hull"] = CLASS_ALIEN_PREDATOR
}

--[[
	Server: SetBase

	Sets up interitance for an NPC class.

	Parameters:
		<npc_class: Types.npc_class> id - The class to configure.
		<npc_class: Types.npc_class> base - The class to inherit from.
]]
function classify.SetBase(id, base)
	local data = classify.Relationships[id] or {}
	local baseData = classify.Relationships[base] or {}

	setmetatable(data, {
		__index = baseData
	})

	classify.Relationships[id] = data
	classify.Relationships[base] = baseData

	classify.BaseMap[id] = base
end

--[[
	Server: GetDefault

	Gets the default NPC class for an entity.

	Parameters:
		<Entity: Types.Entity> ent - The entity to get the class for.

	Returns:
		<npc_class: Types.npc_class> - The default class for this entity, for unconfigured non-NPC entities this will almost always be <CLASS_NONE: https://wiki.facepunch.com/gmod/Enums/CLASS#CLASS_NONE>.
]]
function classify.GetDefault(ent)
	return ent:IsNPC() and ent:Classify() or classify.DefaultMap[ent:GetClass()] or CLASS_NONE
end

--[[
	Server: GetClass

	Gets the current NPC class for an entity.

	Parameters:
		<Entity: Types.Entity> ent - The entity to get the class for.

	Returns:
		<npc_class: Types.npc_class> - The current class for this entity.
]]
function classify.GetClass(ent)
	local class = ent:GetClass()

	if classify.EntityMap[ent] then
		return classify.EntityMap[ent]
	elseif classify.ClassMap[class] then
		return classify.ClassMap[class]
	elseif ent:IsNPC() then
		return ent:Classify()
	elseif classify.DefaultMap[class] then
		return classify.DefaultMap[class]
	end

	return CLASS_NONE
end

--[[
	Server: IsDefault

	Checks whether the entity's NPC class is set to their default.

	Parameters:
		<Entity: Types.Entity> ent - The entity to check.

	Returns:
		<bool: Types.bool> - Whether the entity's class is set to their default.
]]
function classify.IsDefault(ent)
	return classify.GetClass(ent) == classify.GetDefault(ent)
end

--[[
	Server: Name

	Returns a string version of a given NPC class.

	Parameters:
		<npc_class: Types.npc_class> id - The class to get the name of.

	Returns:
		<string: Types.string> - The class's name.
]]
function classify.Name(id)
	if isstring(id) then
		return id
	end

	return classify.Names[id] or "*INVALID*"
end

--[[
	Server: GetDisposition

	Checks how a class or entity feels about another class or entity.

	Parameters:
		<any: Types.any> self - The <npc_class: Types.npc_class> or <Entity: Types.Entity> to get the relationship for.
		<any: Types.any> target - The <npc_class: Types.npc_class> or <Entity: Types.Entity> to check.

	Returns:
		<number: Types.number> - A <D: https://wiki.facepunch.com/gmod/Enums/D> enum.
		<number: Types.number> - The disposition priority.
]]
function classify.GetDisposition(self, target)
	local ourClass = IsEntity(self) and classify.GetClass(self) or self
	local theirClass = IsEntity(target) and classify.GetClass(target) or target

	local relationshipData = classify.Relationships[theirClass]

	if not relationshipData then
		return D_NU, 0
	end

	local class = ourClass

	while class and not relationshipData[class] do
		class = classify.BaseMap[class]
	end

	if class then
		local data = relationshipData[class]

		return data[1], data[2]
	else
		return D_NU, 0
	end
end

--[[
	Server: AddRelationship

	Specifies a default relationship between one class and another.

	Parameters:
		<npc_class: Types.npc_class> self - The class to configure.
		<npc_class: Types.npc_class> other - The class to add a relationship for.
		<number: Types.number> disposition - A <D: https://wiki.facepunch.com/gmod/Enums/D> enum specifying the relationship.
		<number: Types.number> priority - The priority to assign to the relationship.
]]
function classify.AddRelationship(self, other, disposition, priority)
	local data = classify.Relationships[other]

	if not data then
		data = {}
		classify.Relationships[other] = data
	end

	data[self] = {disposition, priority or 0}
end

--[[
	Server: Set

	Sets an entity or classname to a specific NPC class.

	Parameters:
		<any: Types.any> target - The <Entity: Types.Entity> or classname to configure.
		<npc_class: Types.npc_class> class - The class to set the target to.
		<bool: Types.bool>? force - Whether to force other entities to update their relationship even when they normally wouldn't.
]]
function classify.Set(target, class, force)
	classify.Tracked[target] = true

	if isentity(target) then
		classify.EntityMap[target] = class
		classify.Initialize(target, force)
	else
		classify.ClassMap[target] = class

		for _, ent in pairs(ents.FindByClass(target)) do
			classify.Initialize(ent, force)
		end
	end
end

--[[
	Server: Reset

	Resets an entity or classname back to their default NPC class.

	Parameters:
		<any: Types.any> target - The <Entity: Types.Entity> or classname to reset.
]]
function classify.Reset(target)
	classify.Set(target, classify.GetDefault(target), true)
	classify.Tracked[target] = nil
end

--[[
	Server: ConfigureNPC

	Updates an NPC's relationships towards other entities. You shouldn't have to call this.

	Parameters:
		<NPC: Types.NPC> npc - The NPC to configure.
		<bool: Types.bool>? force - Whether to force an update for entities that we would normally skip.
]]
function classify.ConfigureNPC(npc, force)
	if classify.IsDefault(npc) and not force then
		for ent in pairs(classify.Tracked) do
			npc:AddEntityRelationship(ent, classify.GetDisposition(npc, ent))
		end
	else
		for _, ent in ents.Iterator() do
			if not ent:IsFlagSet(FL_OBJECT) and not ent:IsNPC() and not ent:IsPlayer() then
				continue
			end

			npc:AddEntityRelationship(ent, classify.GetDisposition(npc, ent))
		end
	end
end

--[[
	Server: ConfigureEntity

	Updates the relationship of other NPC's towards this entity. You shouldn't have to call this.

	Parameters:
		<Entity: Types.Entity> ent - The entity to configure.
		<bool: Types.bool>? force - Whether to force an update for NPC's that we would normally skip.
]]
function classify.ConfigureEntity(ent, force)
	-- We're not visible
	if not ent:IsFlagSet(FL_OBJECT) and not ent:IsNPC() and not ent:IsPlayer() then
		return
	end

	if classify.IsDefault(ent) and not force then
		for npc in pairs(classify.Tracked) do
			if not npc:IsNPC() then
				continue
			end

			npc:AddEntityRelationship(ent, classify.GetDisposition(npc, ent))
		end
	else
		for _, npc in ents.Iterator() do
			if not npc:IsNPC() then
				continue
			end

			npc:AddEntityRelationship(ent, classify.GetDisposition(npc, ent))
		end
	end
end

--[[
	Server: Initialize

	Initializes an entity's relationships. You shouldn't have to call this.

	Parameters:
		<Entity: Types.Entity> ent - The entity to configure.
		<bool: Types.bool>? force - Whether to force relationships to update.
]]
function classify.Initialize(ent, force)
	if ent:IsNPC() then
		classify.ConfigureNPC(ent, force)
	end

	classify.ConfigureEntity(ent, force)
end

hook.Add("OnEntityCreated", "glua-extensions.classify", function(ent)
	if not IsValid(ent) then
		return
	end

	timer.Simple(0, function()
		if not IsValid(ent) then
			return
		end

		classify.Initialize(ent)
	end)
end)

hook.Add("EntityRemoved", "glua-extensions.classify", function(ent)
	classify.Tracked[ent] = nil
end)

classify.Names = {
	[CLASS_NONE] = "CLASS_NONE",
	[CLASS_PLAYER] = "CLASS_PLAYER",
	[CLASS_PLAYER_ALLY] = "CLASS_PLAYER_ALLY",
	[CLASS_PLAYER_ALLY_VITAL] = "CLASS_PLAYER_ALLY_VITAL",
	[CLASS_ANTLION] = "CLASS_ANTLION",
	[CLASS_BARNACLE] = "CLASS_BARNACLE",
	[CLASS_BULLSEYE] = "CLASS_BULLSEYE",
	[CLASS_CITIZEN_PASSIVE] = "CLASS_CITIZEN_PASSIVE",
	[CLASS_CITIZEN_REBEL] = "CLASS_CITIZEN_REBEL",
	[CLASS_COMBINE] = "CLASS_COMBINE",
	[CLASS_COMBINE_GUNSHIP] = "CLASS_COMBINE_GUNSHIP",
	[CLASS_CONSCRIPT] = "CLASS_CONSCRIPT",
	[CLASS_HEADCRAB] = "CLASS_HEADCRAB",
	[CLASS_MANHACK] = "CLASS_MANHACK",
	[CLASS_METROPOLICE] = "CLASS_METROPOLICE",
	[CLASS_MILITARY] = "CLASS_MILITARY",
	[CLASS_SCANNER] = "CLASS_SCANNER",
	[CLASS_STALKER] = "CLASS_STALKER",
	[CLASS_VORTIGAUNT] = "CLASS_VORTIGAUNT",
	[CLASS_ZOMBIE] = "CLASS_ZOMBIE",
	[CLASS_PROTOSNIPER] = "CLASS_PROTOSNIPER",
	[CLASS_MISSILE] = "CLASS_MISSILE",
	[CLASS_FLARE] = "CLASS_FLARE",
	[CLASS_EARTH_FAUNA] = "CLASS_EARTH_FAUNA",
	[CLASS_HACKED_ROLLERMINE] = "CLASS_HACKED_ROLLERMINE",
	[CLASS_COMBINE_HUNTER] = "CLASS_COMBINE_HUNTER",
	[CLASS_MACHINE] = "CLASS_MACHINE",
	[CLASS_HUMAN_PASSIVE] = "CLASS_HUMAN_PASSIVE",
	[CLASS_HUMAN_MILITARY] = "CLASS_HUMAN_MILITARY",
	[CLASS_ALIEN_MILITARY] = "CLASS_ALIEN_MILITARY",
	[CLASS_ALIEN_MONSTER] = "CLASS_ALIEN_MONSTER",
	[CLASS_ALIEN_PREY] = "CLASS_ALIEN_PREY",
	[CLASS_ALIEN_PREDATOR] = "CLASS_ALIEN_PREDATOR",
	[CLASS_INSECT] = "CLASS_INSECT",
	[CLASS_PLAYER_BIOWEAPON] = "CLASS_PLAYER_BIOWEAPON",
	[CLASS_ALIEN_BIOWEAPON] = "CLASS_ALIEN_BIOWEAPON",
}

--[[
classify.AddRelationship(CLASS_NONE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_ANTLION, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_VORTIGAUNT, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_NONE, CLASS_HACKED_ROLLERMINE, D_NU)
]]

classify.AddRelationship(CLASS_ANTLION, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_ANTLION, D_LI)
classify.AddRelationship(CLASS_ANTLION, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_PROTOSNIPER, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_ANTLION, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_ANTLION, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_BARNACLE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_BARNACLE, D_LI)
classify.AddRelationship(CLASS_BARNACLE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_MANHACK, D_FR)
classify.AddRelationship(CLASS_BARNACLE, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_BARNACLE, CLASS_EARTH_FAUNA, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_BARNACLE, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_BULLSEYE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_ANTLION, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_VORTIGAUNT, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_BULLSEYE, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_BARNACLE, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_COMBINE_HUNTER, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_HEADCRAB, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_MANHACK, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_MISSILE, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_ZOMBIE, D_FR)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_CITIZEN_PASSIVE, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_BARNACLE, D_FR)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_MISSILE, D_FR)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_CITIZEN_REBEL, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_COMBINE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_BARNACLE, D_FR)
classify.AddRelationship(CLASS_COMBINE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_COMBINE, D_LI)
classify.AddRelationship(CLASS_COMBINE, CLASS_COMBINE_GUNSHIP, D_LI)
classify.AddRelationship(CLASS_COMBINE, CLASS_COMBINE_HUNTER, D_LI)
classify.AddRelationship(CLASS_COMBINE, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_COMBINE, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_COMBINE, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_COMBINE, D_LI)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_COMBINE_GUNSHIP, D_LI)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_COMBINE_HUNTER, D_LI)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_MISSILE, D_FR)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_COMBINE_GUNSHIP, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_COMBINE, D_LI)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_COMBINE_GUNSHIP, D_LI)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_COMBINE_HUNTER, D_LI)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_COMBINE_HUNTER, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_CONSCRIPT, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_BARNACLE, D_FR)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_VORTIGAUNT, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_CONSCRIPT, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_FLARE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_ANTLION, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_VORTIGAUNT, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_PLAYER_ALLY, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_PLAYER_ALLY_VITAL, D_NU)
classify.AddRelationship(CLASS_FLARE, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_HEADCRAB, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_HEADCRAB, CLASS_HACKED_ROLLERMINE, D_FR)

classify.AddRelationship(CLASS_MANHACK, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_HEADCRAB, D_HT, -1)
classify.AddRelationship(CLASS_MANHACK, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_MANHACK, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_MANHACK, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_METROPOLICE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_METROPOLICE, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_MILITARY, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_MILITARY, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_MILITARY, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_MISSILE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_MISSILE, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_MISSILE, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_PLAYER, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_PLAYER, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_BARNACLE, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_BULLSEYE, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_CITIZEN_PASSIVE, D_LI)
classify.AddRelationship(CLASS_PLAYER, CLASS_CITIZEN_REBEL, D_LI)
classify.AddRelationship(CLASS_PLAYER, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_COMBINE_GUNSHIP, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_PLAYER, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_PROTOSNIPER, D_HT)
classify.AddRelationship(CLASS_PLAYER, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_PLAYER, CLASS_PLAYER_ALLY, D_LI)
classify.AddRelationship(CLASS_PLAYER, CLASS_PLAYER_ALLY_VITAL, D_LI)
classify.AddRelationship(CLASS_PLAYER, CLASS_HACKED_ROLLERMINE, D_LI)

classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_PLAYER, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_BARNACLE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_HEADCRAB, D_FR)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_ZOMBIE, D_FR)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_PROTOSNIPER, D_FR)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_PLAYER_ALLY, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_PLAYER_ALLY_VITAL, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY, CLASS_HACKED_ROLLERMINE, D_LI)

classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_PLAYER, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_BARNACLE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_COMBINE_HUNTER, D_FR)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_PROTOSNIPER, D_FR)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_PLAYER_ALLY, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_PLAYER_ALLY_VITAL, D_LI)
classify.AddRelationship(CLASS_PLAYER_ALLY_VITAL, CLASS_HACKED_ROLLERMINE, D_LI)

classify.AddRelationship(CLASS_SCANNER, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_COMBINE, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_COMBINE_GUNSHIP, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_COMBINE_HUNTER, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_MANHACK, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_METROPOLICE, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_MILITARY, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_SCANNER, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_STALKER, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_PROTOSNIPER, D_LI)
classify.AddRelationship(CLASS_SCANNER, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_SCANNER, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_SCANNER, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_STALKER, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_STALKER, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_STALKER, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_PLAYER, D_LI)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_BARNACLE, D_FR)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_CITIZEN_PASSIVE, D_LI)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_CITIZEN_REBEL, D_LI)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_VORTIGAUNT, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_PLAYER_ALLY, D_LI)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_PLAYER_ALLY_VITAL, D_LI)
classify.AddRelationship(CLASS_VORTIGAUNT, CLASS_HACKED_ROLLERMINE, D_LI)

classify.AddRelationship(CLASS_ZOMBIE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_HEADCRAB, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_MANHACK, D_FR)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_MILITARY, D_FR)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_ZOMBIE, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_ZOMBIE, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_COMBINE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_METROPOLICE, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_MILITARY, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_MISSILE, D_NU, 5)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_STALKER, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_PROTOSNIPER, CLASS_HACKED_ROLLERMINE, D_HT)

classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_NONE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_PLAYER, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_CITIZEN_PASSIVE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_CITIZEN_REBEL, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_COMBINE_GUNSHIP, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_COMBINE_HUNTER, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_CONSCRIPT, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_FLARE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_MANHACK, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_MISSILE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_SCANNER, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_VORTIGAUNT, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_PROTOSNIPER, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_EARTH_FAUNA, D_NU)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_PLAYER_ALLY, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_PLAYER_ALLY_VITAL, D_HT)
classify.AddRelationship(CLASS_EARTH_FAUNA, CLASS_HACKED_ROLLERMINE, D_NU)

classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_NONE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_PLAYER, D_LI)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_ANTLION, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_BARNACLE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_BULLSEYE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_CITIZEN_PASSIVE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_CITIZEN_REBEL, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_COMBINE, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_COMBINE_GUNSHIP, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_COMBINE_HUNTER, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_CONSCRIPT, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_FLARE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_HEADCRAB, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_MANHACK, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_METROPOLICE, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_MILITARY, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_MISSILE, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_SCANNER, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_STALKER, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_VORTIGAUNT, D_LI)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_ZOMBIE, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_PROTOSNIPER, D_NU)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_EARTH_FAUNA, D_HT)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_PLAYER_ALLY, D_LI)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_PLAYER_ALLY_VITAL, D_LI)
classify.AddRelationship(CLASS_HACKED_ROLLERMINE, CLASS_HACKED_ROLLERMINE, D_LI)
