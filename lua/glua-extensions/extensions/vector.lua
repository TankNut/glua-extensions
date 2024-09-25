local meta = FindMetaTable("Vector")

function meta:Approach(target, rate)
	local ratio = (target - self):GetNormalized()

	self.x = math.Approach(self.x, target.x, rate * ratio.x)
	self.y = math.Approach(self.y, target.y, rate * ratio.y)
	self.z = math.Approach(self.z, target.z, rate * ratio.z)
end

function meta:Clamp(min, max)
	self.x = math.Clamp(self.x, min.x, max.x)
	self.x = math.Clamp(self.x, min.x, max.x)
	self.x = math.Clamp(self.x, min.x, max.x)
end
