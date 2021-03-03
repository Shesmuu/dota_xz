PlayArea = {
	levelLength = {
		[1] = 10000,
		[2] = 8000,
		[3] = 6000,
		[4] = 4000,
		[5] = 2500,
		[6] = 1600,
		[7] = 900,
		[8] = 0
	},
	levelDelays = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[5] = 0,
		[6] = 0,
		[7] = 0,
		[8] = 0
	},
	levelDurations = {
		[1] = 10,
		[2] = 10,
		[3] = 10,
		[4] = 10,
		[5] = 10,
		[6] = 10,
		[7] = 10,
		[8] = 10
	},
	levelAABB = {},
	level = 0
}

function PlayArea:Create()
	self.top = self:Side()
	self.bottom = self:Side()
	self.left = self:Side()
	self.right = self:Side()

	self.min = Map.bounds.min
	self.max = Map.bounds.max

	local min = self.min
	local length = self.max.x - self.min.x

	self.levelAABB[0] = Map.bounds

	for i = 1, #self.levelLength do
		local l = self.levelLength[i]
		local le = length - l
		local x = RandomInt( 0, le )
		local z = RandomInt( 0, le )

		min = min + Vector( x, 0, z )

		self.levelAABB[i] = {
			min = min,
			max = min + Vector( l, 0, l )
		}

		length = l
	end

	self:NextLevel( GameRules:GetGameTime() )

	self.created = true
end

function PlayArea:NextLevel( now )
	local level = self.level + 1

	if not self.levelAABB[level] then
		self:DestroyEffects()

		return
	end

	local duration = self.levelDurations[level]

	self.startTime = now + self.levelDelays[level]
	self.nextTime = self.startTime + duration

	local newAABB = self.levelAABB[self.level]
	local nextAABB = self.levelAABB[level]

	self.forwardMin = ( nextAABB.min - newAABB.min ) / duration
	self.forwardMax = ( nextAABB.max - newAABB.max ) / duration

	self.min = newAABB.min
	self.max = newAABB.max

	self.level = level

	CustomNetTables:SetTableValue( "map", "play_area_next", {
		min = { x = nextAABB.min.x, y = nextAABB.max.z },
		max = { x = nextAABB.max.x, y = nextAABB.min.z },
		start_time = self.startTime
	} )
end

function PlayArea:Update( now, dt )
	if not self.created then
		return
	end

	if self.nextTime and now >= self.nextTime then
		self:NextLevel( now )
	end

	if not self.startTime or self.startTime > now then
		return
	end

	self.min = self.min + self.forwardMin * dt
	self.max = self.max + self.forwardMax * dt

	local a = Vector( self.min.x, 0, self.max.z )
	local b = self.max
	local c = Vector( self.max.x, 0, self.min.z )
	local d = self.min

	self:SetSide( self.top, a, b )
	self:SetSide( self.bottom, b, c )
	self:SetSide( self.left, c, d )
	self:SetSide( self.right, d, a )

	CustomNetTables:SetTableValue( "map", "play_area_now", {
		min = { x = self.min.x, y = self.max.z },
		max = { x = self.max.x, y = self.min.z }
	} )
end

function PlayArea:Particle()
	return ParticleManager:CreateParticle( "particles/maps/battle_royale/play_area_side/play_area_side.vpcf", PATTACH_CUSTOMORIGIN, nil )
end

function PlayArea:Side()
	return {
		self:Particle(),
		self:Particle()
	}
end

function PlayArea:SetSide( side, a, b )
	ParticleManager:SetParticleControl( side[1], 0, a + Vector( 0, Map.y + 40 ) )
	ParticleManager:SetParticleControl( side[1], 1, b + Vector( 0, Map.y + 40 ) )
	ParticleManager:SetParticleControl( side[2], 0, b + Vector( 0, Map.y - 40 ) )
	ParticleManager:SetParticleControl( side[2], 1, a + Vector( 0, Map.y - 40 ) )
end

function PlayArea:DestroyEffects()
	self.created = false
end