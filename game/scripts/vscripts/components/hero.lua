Hero = class( {
	isHero = true,
}, nil, Unit )

function Hero:constructor( player, data, team )
	Unit.constructor( self, data, team:GetSpawner(), team )

	self.player = player
	self.lastDamages = {}

	self.control = {}
	self.abilities = {
		w = data.abilityW( self ),
		s = data.abilityS( self ),
		x = data.abilityX( self )
	}
end

function Hero:GetMove()
	local x = 0

	if self.control.right then
		x = x + 1
	end

	if self.control.left then
		x = x - 1
	end

	return Vector( x * self:GetMoveSpeed() )
end