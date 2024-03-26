-- Draws a spinning crystal at the specified location.

if SERVER then
	return
end

local pos = Vector(0, 0, 150)
local mat = Material("models/props_combine/combine_interface_disp")

-- Persisted variables
local ang = Angle()
local vel = Angle()
local targetVel = Angle()

hook.Add("PostDrawTranslucentRenderables", "test", function()
	if vel == targetVel then
		targetVel = AngleRand(-50, 50)
	end

	vel.p = math.Approach(vel.p, targetVel.p, FrameTime() * 5)
	vel.y = math.Approach(vel.y, targetVel.y, FrameTime() * 5)
	vel.r = math.Approach(vel.r, targetVel.r, FrameTime() * 5)

	ang = ang + vel * FrameTime()

	local height = 40
	local radius = 20
	local steps = 8

	render.SetMaterial(mat)
	render.DrawCylinder(pos, ang, height, radius, 0, steps)

	render.CullMode(MATERIAL_CULLMODE_CW)
	render.DrawCylinder(pos, ang, -height, radius, 0, steps)
	render.CullMode(MATERIAL_CULLMODE_CCW)
end)
