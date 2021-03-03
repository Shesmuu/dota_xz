Projectile = class( {} )

function Projectile:constructor( data )
	self.ingoreMap = data.ingoreMap or false
	self.center = data.startPos
	self.hx = data.radius
	self.hz = data.radius
	self.velocity = data.velocity
	self.dieTime = GameRules:GetGameTime() + data.duration
	self.unit = data.unit
	self.onHit = data.onHit
	self.affectedUnits = {}

	self.particle = ParticleManager:CreateParticle( data.effect, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( self.particle, 0, self.center )
	ParticleManager:SetParticleControlForward( self.particle, 0, self.velocity )
	ParticleManager:SetParticleControl( self.particle, 1, self.velocity )

	self.index = Add( GameMode.projectiles, self )
end

function Projectile:Update( now, dt )
	self.center = self.center + self.velocity * dt
	self.min = self.center + Vector( -self.hx, 0, -self.hz )
	self.max = self.center + Vector( self.hx, 0, self.hz )

	if not self.ingoreMap then
		for i, _ in pairs( GetCollisions( self.center ) ) do
			if NoGameNoLife( self, Map.collisions[i] ) then
				self:Destroy()

				return
			end
			--local a, x, z = RelaxTakeItEasy( c, self )

			--if a then
			--	self:Destroy()

			--	return
			--end
		end
	end

	for _, unit in pairs( GameMode.units ) do
		local a, x, z = RelaxTakeItEasy( unit, self )

		if unit ~= self.unit and a and not self.affectedUnits[unit] then
			if self.onHit then
				self.onHit( unit, self )
			end

			self.affectedUnits[unit] = true
		end
	end

	if now >= self.dieTime then
		self:Destroy()
	end
end

function Projectile:Destroy()
	if self.destroyed then
		return
	end

	ParticleManager:DestroyParticle( self.particle, false )
	ParticleManager:ReleaseParticleIndex( self.particle )

	GameMode.projectiles[self.index] = nil

	self.destroyed = true
end