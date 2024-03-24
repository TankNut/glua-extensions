module("primitive", package.seeall)

function Cylinder(iMesh, height, radius1, radius2, steps, color)
	color = color or color_white

	local r, g, b, a = color:Unpack()

	local primitiveCount = 2 * steps

	if radius1 != 0 then
		primitiveCount = primitiveCount + steps
	end

	if radius2 != 0 then
		primitiveCount = primitiveCount + steps
	end

	if iMesh then
		mesh.Begin(iMesh, MATERIAL_TRIANGLES, primitiveCount)
	else
		mesh.Begin(MATERIAL_TRIANGLES, primitiveCount)
	end

	local step = (2 * math.pi) / steps
	local nUp = Vector(0, 0, 1)
	local nDown = Vector(0, 0, -1)

	for i = 0, steps - 1 do
		local t1 = i * step
		local t2 = (i + 1) * step

		local u1 = i / steps
		local u2 = (i + 1) / steps

		local n1 = Vector(math.cos(t1), math.sin(t1), 0):GetNormalized()
		local n2 = Vector(math.cos(t2), math.sin(t2), 0):GetNormalized()

		local indices = {
			Vector(radius1 * math.cos(t1), radius1 * math.sin(t1), 0),
			Vector(radius1 * math.cos(t2), radius1 * math.sin(t2), 0),
			Vector(radius2 * math.cos(t2), radius2 * math.sin(t2), height),
			Vector(radius2 * math.cos(t1), radius2 * math.sin(t1), height)
		}

		-- Bottom face
		if radius1 != 0 then
			mesh.Position(Vector(0, 0, 0)) mesh.Normal(nDown)
			mesh.TexCoord(0, 0.5, 0) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()

			mesh.Position(indices[1]) mesh.Normal(nDown)
			mesh.TexCoord(0, 1, 1) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()

			mesh.Position(indices[2]) mesh.Normal(nDown)
			mesh.TexCoord(0, 0, 1) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()
		end

		-- Middle strip
		mesh.Position(indices[1]) mesh.Normal(n1)
		mesh.TexCoord(0, u1, 1) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()

		mesh.Position(indices[4]) mesh.Normal(n1)
		mesh.TexCoord(0, u1, 0) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()

		mesh.Position(indices[2]) mesh.Normal(n2)
		mesh.TexCoord(0, u2, 1) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()


		mesh.Position(indices[4]) mesh.Normal(n1)
		mesh.TexCoord(0, u1, 0) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()

		mesh.Position(indices[3]) mesh.Normal(n2)
		mesh.TexCoord(0, u2, 0) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()

		mesh.Position(indices[2]) mesh.Normal(n2)
		mesh.TexCoord(0, u2, 1) mesh.Color(r, g, b, a)
		mesh.AdvanceVertex()

		-- Top face
		if radius2 != 0 then
			mesh.Position(Vector(0, 0, height)) mesh.Normal(nUp)
			mesh.TexCoord(0, 0.5, 0) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()

			mesh.Position(indices[3]) mesh.Normal(nUp)
			mesh.TexCoord(0, 1, 1) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()

			mesh.Position(indices[4]) mesh.Normal(nUp)
			mesh.TexCoord(0, 0, 1) mesh.Color(r, g, b, a)
			mesh.AdvanceVertex()
		end
	end

	mesh.End()
end
