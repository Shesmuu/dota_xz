Trigger = class( {}, nil, EntAABB )

function Trigger:constructor( c, w, h )
	local hw, hh = w / 2, h / 2

	self.min = c + Vector( -hw, 0, -hh )
	self.min = c + Vector( hw, 0, hh )

	self.index = Add( GameMode.triggers, self )
end

function Trigger:IsObstruction( unit )
	return false
end

function Trigger:IsPhysics()
	return false
end

function Trigger:Destroy()
	if self.OnDestroy then
		self:OnDestroy()
	end

	GameMode.triggers[self.index] = nil
end

Trigger.Update = FUNCTION_NIL