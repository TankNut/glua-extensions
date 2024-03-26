AddCSLuaFile()

local prefix = "glua-extensions/"

local function includeClient(path)
	path = prefix .. path

	if CLIENT then
		include(path)
	else
		AddCSLuaFile(path)
	end
end

local function includeShared(path)
	path = prefix .. path

	AddCSLuaFile(path)
	include(path)
end

local function includeServer(path)
	path = prefix .. path

	if SERVER then
		include(path)
	end
end

includeShared("extensions/entity.lua")
includeClient("extensions/imesh.lua")
includeClient("extensions/render.lua")
includeShared("extensions/table.lua")

includeClient("libraries/rendering/primitive.lua")
includeClient("libraries/rendering/rings.lua")
includeShared("libraries/unit.lua")
