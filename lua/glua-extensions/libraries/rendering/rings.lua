--[[
	Package: Libraries.rings

	Not so much a library as it's a set of extension functions for the <render: Libraries.render> library that allow you to draw rings that wrap themselves around geometry.

	Functions are formatted the way they are to mimic the <beam: https://wiki.facepunch.com/gmod/render_beams> ones as much as possible.
]]

-- Group: Functions
-------------------

--[[
	Client: StartRings

	Begins drawing a multi-segment ring. Multi-segment rings use a single shared border between them.
]]
function render.StartRings()
	render.SetStencilEnable(true)
	render.ClearStencil()
end

--[[
	Client: AddRing

	Adds a ring to a multi-segment ring started by <StartRings>.

	Parameters:
		*<Vector: Types.Vector> pos* - The position to draw the ring at.
		*<number: Types.number> radius* - The radius of the ring.
		*<thickness: Types.number> thickness* - The thickness of the ring. Positive values extend out past the radius while negative values extend inwards instead.
		*<steps: Types.number> steps* - The number of steps. This controls the quality of the ring itself, higher values will lower performance significantly.
]]
function render.AddRing(pos, radius, thickness, steps)
	local innerRadius = thickness < 0 and radius + thickness or radius
	local outerRadius = thickness > 0 and radius + thickness or radius

	-- Hijack the stencil state back to known defaults, if this somehow gets in your way you probably don't need this Libraries.
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

--[[
	Client: EndRings

	Finishes a multi-segment ring started with <StartRings> and draws it to the screen.

	Parameters:
		*<Color: Extensions.Color>? color* - The color used to draw the ring. *Default:* color_white
]]
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

--[[
	Client: DrawRing

	Draws a single ring.

	Parameters:
		*<Vector: Types.Vector> pos* - The position to draw the ring at.
		*<number: Types.number> radius* - The radius of the ring.
		*<thickness: Types.number> thickness* - The thickness of the ring. Positive values extend out past the radius while negative values extend inwards instead.
		*<steps: Types.number> steps* - The number of steps. This controls the quality of the ring itself, higher values will lower performance significantly.
		*<Color: Extensions.Color>? color* - The color used to draw the ring. *Default:* color_white
]]
function render.DrawRing(pos, radius, thickness, steps, color)
	render.StartRings()
	render.AddRing(pos, radius, thickness, steps)
	render.EndRings(color)
end
