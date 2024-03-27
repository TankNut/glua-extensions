function render.StartRings()
	render.SetStencilEnable(true)
	render.ClearStencil()
end

function render.AddRing(pos, radius, thickness, steps)
	local innerRadius = thickness < 0 and radius + thickness or radius
	local outerRadius = thickness > 0 and radius + thickness or radius

	-- Hijack the stencil state back to known defaults, if this somehow gets in your way you probably don't need this library.
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)

	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_KEEP)
	render.SetStencilFailOperation(STENCIL_KEEP)

	render.SetColorMaterial()
	render.OverrideColorWriteEnable(true, false)

	-- 1. Inside-facing sphere, increments the whole area to 1
	render.CullMode(MATERIAL_CULLMODE_CW)
	render.SetStencilZFailOperation(STENCIL_INCR)
	render.DrawSphere(pos, outerRadius, steps, steps)

	-- 2. Outside-facing sphere, decrements the front-facing zfail to 0
	render.CullMode(MATERIAL_CULLMODE_CCW)
	render.SetStencilZFailOperation(STENCIL_DECR)
	render.DrawSphere(pos, outerRadius, steps, steps)

	-- 3. Inside-facing sphere, increments the inner radius by 1 (to 2) and resets parts of what step 2 did back to 1
	render.CullMode(MATERIAL_CULLMODE_CW)
	render.SetStencilZFailOperation(STENCIL_INCR)
	render.DrawSphere(pos, innerRadius, steps, steps)

	-- 4. Undo step 3 with a smaller radius outside-facing sphere to fix the front-facing zfail again and to fix the border
	render.CullMode(MATERIAL_CULLMODE_CCW)
	render.SetStencilZFailOperation(STENCIL_DECR)
	render.DrawSphere(pos, innerRadius, steps, steps)

	render.OverrideColorWriteEnable(false)
end

function render.EndRings(color)
	color = color or color_white

	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_EQUAL)

	cam.Start2D()
		surface.SetDrawColor(color:Unpack())
		surface.DrawRect(0, 0, ScrW(), ScrH())
	cam.End2D()

	render.SetStencilEnable(false)
end

function render.DrawRing(pos, radius, thickness, steps, color)
	render.StartRings()
	render.AddRing(pos, radius, thickness, steps)
	render.EndRings(color)
end
