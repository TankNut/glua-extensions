--[[
	Package: Extensions.render

	Extension functions for the <render: https://wiki.facepunch.com/gmod/render> Library.
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
