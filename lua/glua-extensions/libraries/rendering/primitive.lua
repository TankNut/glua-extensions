module("primitive", package.seeall)

local function addVertex(pos, normal, u, v, color)
	mesh.Position(pos) mesh.Normal(normal)
	mesh.TexCoord(0, u, v) mesh.Color(color:Unpack())
	mesh.AdvanceVertex()
end

function Cylinder(iMesh, height, radius1, radius2, steps, color)
	color = color or color_white

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
			addVertex(Vector(0, 0, 0), nDown, 0.5, 0, color)
			addVertex(indices[1],      nDown, 1,   1, color)
			addVertex(indices[2],      nDown, 0,   1, color)
		end

		-- Middle strip
		addVertex(indices[1], n1, u1, 1, color)
		addVertex(indices[4], n1, u1, 1, color)
		addVertex(indices[2], n2, u2, 1, color)

		addVertex(indices[4], n1, u1, 0, color)
		addVertex(indices[3], n2, u2, 0, color)
		addVertex(indices[2], n2, u2, 1, color)

		-- Top face
		if radius2 != 0 then
			addVertex(Vector(0, 0, height), nUp, 0.5, 0, color)
			addVertex(indices[3],           nUp, 1,   1, color)
			addVertex(indices[4],           nUp, 0,   1, color)
		end
	end

	mesh.End()
end
