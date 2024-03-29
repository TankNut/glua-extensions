--[[
	Package: Examples.Soft Rings

	Draws a ring around the player with a softened edge.

	Note that this example isn't particularly performant, especially with higher step counts as each ring does 4 sphere draws internally.

	Uses <render.DrawRing: Libraries.rings.DrawRing>.

	--- Lua
	if SERVER then
		return
	end

	hook.Add("PostDrawTranslucentRenderables", "Rings Example", function()
		local pos = LocalPlayer():GetPos()
		local radius = 100
		local steps = 20
		local color = Color(255, 0, 0, 10)

		for i = 0, 10 do
			render.DrawRing(pos, radius, -i, steps, color)
		end
	end)
	---
]]
