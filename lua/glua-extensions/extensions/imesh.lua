local meta = FindMetaTable("IMesh")

function meta:BuildCylinder(height, radius1, radius2, steps)
	primitive.Cylinder(self, height, radius1, radius2, steps)
end
