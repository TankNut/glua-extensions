--[[
	Package: Extensions.render

	Extension functions for the <render: https://wiki.facepunch.com/gmod/render> library.
]]

-- Group: Functions
-------------------

--[[
	Client: DrawCylinder

	Draws a cylinder at a specified point using <primitive.Cylinder>.

	Parameters:
		<Vector: Types.Vector> pos - The position to draw the cylinder at.
		<Angle: Types.Angle> ang - The angle to draw the cylinder at.
		<number: Types.number> height - The height of the cylinder. A negative value will make it cylinder render inside out.
		<number: Types.number> radius1 - The radius of the bottom face of the cylinder. A value of 0 removes the face entirely.
		<number: Types.number> radius2 - The radius of the top face of the cylinder. A value of 0 removes the face entirely.
		<number: Types.number> steps - The amount of steps. This controls the quality of the cylinder. Higher values will lower performance significantly.
		<Color: Types.Color>? color - The color to draw the cylinder with. *Default:* color_white
]]
function render.DrawCylinder(pos, ang, height, radius1, radius2, steps, color)
	local matrix = Matrix()

	matrix:SetTranslation(pos)
	matrix:SetAngles(ang)

	cam.PushModelMatrix(matrix, true)
		primitive.Cylinder(nil, height, radius1, radius2, steps, color)
	cam.PopModelMatrix()
end

--[[
	Client: DrawWorldText

	Draws a piece of text at a certain point in 3D space.

	Parameters:
		<Vector: Types.Vector> pos - The position to draw the text at.
		<string: Types.string> text - The text to draw.
		<bool: Types.bool>? noz - Whether to render through walls. *Default:* false
]]
function render.DrawWorldText(pos, text, noz)
	local ang = (pos - EyePos()):Angle()

	cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.25)
		if noz then
			render.DepthRange(0, 0)
		end

		render.PushFilterMag(TEXFILTER.NONE)
		render.PushFilterMin(TEXFILTER.NONE)
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetTextSize(text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(-w * 0.5, -h * 0.5)

			surface.DrawText(text)
		render.PopFilterMin()
		render.PopFilterMag()

		if noz then
			render.DepthRange(0, 1)
		end
	cam.End3D2D()
end

local spotSprite = Material("sprites/light_glow02_add")
local spotBeam = CreateMaterial("glua-extensions.spotlight", "UnlitGeneric", {
	["$basetexture"] = "sprites/glow_test02",
	["$additive"] = 1,
	["$translucent"] = 1,
	["$vertexcolor"] = 1
})

local color_black = Color(0, 0, 0)

--[[
	Client: DrawSpotlight

	Draws a spotlight similar to the one produced by <point_spotlight: https://developer.valvesoftware.com/wiki/Point_spotlight>.

	Parameters:
		<Vector: Types.Vector> pos - The position to draw the spotlight at.
		<Angle: Types.Angle> ang - The angle to draw the spotlight at.
		<number: Types.number> length - The length of the beam part of the spotlight.
		<number: Types.number> radius - The radius of the spotlight.
		<Color: Types.Color> color - The color of the spotlight.
		<pixelvis_handle_t: https://wiki.facepunch.com/gmod/util.GetPixelVisibleHandle> pixvis - The PixVis handle.
]]
function render.DrawSpotlight(pos, ang, length, radius, color, pixvis)
	local dir = ang:Forward()
	local dot = (EyePos() - pos):GetNormalized():Dot(dir)
	local alpha = util.PixelVisible(pos, 10, pixvis)
	local width = radius * 0.15
	local size = math.ClampedRemap(dot, 0.75, 1, radius * 0.25, radius)

	render.SetMaterial(spotBeam)

	render.StartBeam(2)
		render.AddBeam(pos, width, 0, ColorAlpha(color, 100))
		render.AddBeam(pos + dir * length, width, 0.99, color_black)
	render.EndBeam()

	render.SetMaterial(spotSprite)

	spotSprite:SetFloat("$hdrcolorscale", 0.75)

	render.DepthRange(0, 0)
	render.DrawSprite(pos, size, size, Color(color.r * alpha, color.g * alpha, color.b * alpha))
	render.DepthRange(0, 1)

	spotSprite:SetFloat("$hdrcolorscale", 1)
end
