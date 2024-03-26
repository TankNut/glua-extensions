-- Draws an expanding ring around the player.

if SERVER then
	return
end

hook.Add("PostDrawTranslucentRenderables", "Rings Example", function()
	local pos = LocalPlayer():GetPos()
	local radius = CurTime() * 300 % 1000
	local alpha = math.Remap(radius, 0, 1000, 255, 0)

	render.DrawRing(pos, radius, 20, 50, Color(255, 0, 0, alpha))
end)
