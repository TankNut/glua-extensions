--[[
	Package: Extensions.effects

	Extension functions for the <effects: https://wiki.facepunch.com/gmod/effects> library.
]]

-- Group: Functions
-------------------

--[[
	Shared: Sparks

	Emits a set of sparks at a given location, shorthand for creating the 'Sparks' effect.

	Parameters:
		<Vector: Types.Vector> pos - The position to emit the sparks from.
		<Vector: Types.Vector> dir - The direction to emit the sparks in.
		<number: Types.number> amount - The amount of sparks to emit, the total amount is equal to amount * amount * math.Rand(2 * 4)
		<number: Types.number> size - The size of the sparks.
		<number: Types.number> trailLength - The length of each spark's 'tail'
		<any: Types.any>? ignoreFilter - Identical to the ignoreFilter argument of <util.Effect: https://wiki.facepunch.com/gmod/util.Effect>.
]]
function effects.Sparks(pos, dir, amount, size, trailLength, ignoreFilter)
	dir = dir or vector_origin

	local effect = EffectData()

	effect:SetOrigin(pos)
	effect:SetNormal(dir)

	effect:SetMagnitude(amount)
	effect:SetRadius(size)
	effect:SetScale(trailLength)

	util.Effect("Sparks", effect, true, ignoreFilter)
end
