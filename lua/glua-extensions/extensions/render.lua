function render.DrawCylinder(pos, ang, height, radius1, radius2, steps, color)
	local matrix = Matrix()

	matrix:SetTranslation(pos)
	matrix:SetAngles(ang)

	cam.PushModelMatrix(matrix, true)
		primitive.Cylinder(nil, height, radius1, radius2, steps, color)
	cam.PopModelMatrix()
end
