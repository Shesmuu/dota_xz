TeamBarrier = class( {}, nil, Trigger )

function TeamBarrier:constructor( team, min, max )
	local aabb = MinMaxToAABB( min, max )
	Trigger.constructor( self, aabb )

	self.team = team
end

function TeamBarrier:IsObstruction( unit )
	return unit.team ~= self.team
end