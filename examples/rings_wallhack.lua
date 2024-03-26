-- Draws an expanding pulse around the player, highlights NPC's through walls as the expanding ring passes them.

if SERVER then
	return
end

hook.Add("PostDrawTranslucentRenderables", "stencil rings", function()
	local pos = LocalPlayer():GetPos()
	local radius = CurTime() * 300 % 1000
	local alpha = math.Remap(radius, 0, 1000, 255, 0)

	render.StartRings()
		render.AddRing(pos, radius, 20, 50)

		-- Technical note, the stencil layout of the actual rings is as follows:
		-- 0 - Outside
		-- 1 - Border
		-- 2 - Inside

		render.SetStencilReferenceValue(1)
		-- Stencil comparisons compare the reference value to the stencil value, so in this case it checks 1 <= stencil or stencil > 1
		render.SetStencilCompareFunction(STENCIL_LESSEQUAL)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilZFailOperation(STENCIL_REPLACE)

		local sqr = (radius + 20) * (radius + 20)

		for _, ent in ipairs(ents.FindByClass("npc_*")) do
			-- If you want to do this the proper way you're going to have to get a second depth buffer, write just your NPC's and a radius sphere to it with ZFail REPLACE to 1
			-- then write the result back to the main view. Otherwise the walls are going to ZFail first and you'll see them through walls before the 'pulse' has reached them proper
			--
			-- It's probably possible, but entirely beyond me atm
			if ent:NearestPoint(pos):DistToSqr(pos) < sqr then
				ent:DrawModel()

				local weapon = ent:GetActiveWeapon()

				if IsValid(weapon) then
					weapon:DrawModel()
				end
			end
		end
	render.EndRings(Color(255, 0, 0, alpha))
end)
