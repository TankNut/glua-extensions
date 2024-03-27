local meta = FindMetaTable("IMesh")

function meta:BuildCylinder(height, radius1, radius2, steps, color)
	primitive.Cylinder(self, height, radius1, radius2, steps, color)
end
