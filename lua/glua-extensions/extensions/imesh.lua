--[[
	Package: Extensions.IMesh

	Extension functions for the <IMesh: https://wiki.facepunch.com/gmod/IMesh> metatable.
]]

-- Group: Methods
-----------------

local meta = FindMetaTable("IMesh")

--[[
	Client: BuildCylinder

	Writes a cylinder to the IMesh using <primitive.Cylinder>.

	Parameters:
		<number: Types.number> height - The height of the cylinder. A negative value will make it cylinder render inside out.
		<number: Types.number> radius1 - The radius of the bottom face of the cylinder. A value of 0 removes the face entirely.
		<number: Types.number> radius2 - The radius of the top face of the cylinder. A value of 0 removes the face entirely.
		<number: Types.number> steps - The amount of steps. This controls the quality of the cylinder. Higher values will lower performance significantly.
		<Color: Types.Color>? color - The color to draw the cylinder with. *Default:* color_white
]]
function meta:BuildCylinder(height, radius1, radius2, steps, color)
	primitive.Cylinder(self, height, radius1, radius2, steps, color)
end
