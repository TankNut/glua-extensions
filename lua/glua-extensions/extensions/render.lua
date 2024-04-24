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
