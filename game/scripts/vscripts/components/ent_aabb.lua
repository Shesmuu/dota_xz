EntAABB = class( {} )

function EntAABB:constructor( c, w, h, d )
	local hw, hh = w / 2, h / 2
	local min, max = Vector( -hw, 0, -hh ), Vector( hw, 0, hh )

	if d then
		self.addMin = min
		self.addMax = max
		self.velocity = Vector()
		self.onGround = false
	end

	self.width = w
	self.height = h
	self.pos = c
	self.min = c + min
	self.max = c + max
end

function EntAABB:Physic( now, dt )
	if not self:IsPhysics() then
		return
	end

	local a = Vector()

	if self:HasGravity() then
		a = a + Vector( 0, 0, -2000 )
	end

	if self:HasWindage() then
		a = a - 0.6 * self.velocity - self.velocity:Normalized() * 200
	end

	self.velocity = self.velocity + a * dt

	local move = ( self.velocity + self:GetMove() ) * dt
	local move_space = AABB(
		self.pos,
		self.width + math.abs( move.x ) * 2,
		self.height + math.abs( move.z ) * 2,
		false
	)

	self.onGround = false

	for collision, _ in pairs( GetCollisions( self.pos ) ) do
		move = self:CalcMove( Map.collisions[collision], move )
	end

	for _, aabb in pairs( GameMode.aabbs or {} ) do
		if aabb:IsObstruction( self ) and aabb ~= self then
			move = self:CalcMove( aabb, move )
		end
	end

	for _, limit in pairs( self:GetLimitSpaces() ) do
		self:CalcMoveLimit( limit, move )
	end

	self.velocity.x = move.x == 0 and 0 or self.velocity.x
	self.velocity.z = move.z == 0 and 0 or self.velocity.z

	self:SetPos( self.pos + move )
end

function EntAABB:SetPos( v )
	self.pos = v
	self.min = v + self.addMin
	self.max = v + self.addMax
end

function EntAABB:SetCenter( v )
	self.center = v
end

function EntAABB:CalcMoveLimit( limit, move )
	if move.x > 0 then
		if self.max.x < limit.max.x then
			local d = limit.max.x - self.max.x

			if move.x > d then
				move.x = d
			end
		end
	elseif move.x < 0 then
		if self.min.x > limit.min.x then
			local d = self.min.x - aabb.max.x

			if move.x > d then
				move.x = d
			end
		end
	end

	if move.z > 0 then
		if self.max.z < limit.max.z then
			local d = limit.max.z - self.max.z

			if move.z > d then
				move.z = d
			end
		end
	elseif move.z < 0 then
		if self.min.z > limit.max.z then
			local d = self.min.z - limit.max.z

			if move.z > d then
				move.z = d

				if d == 0 then
					self.onGround = true
				end
			end
		end
	end

	return move
end

function EntAABB:CalcMove( aabb, move )
	if self:IsCrossingV( aabb ) then
		if move.x > 0 then
			if self.max.x <= aabb.min.x then
				local d = aabb.min.x - self.max.x

				if move.x > d then
					move.x = d
				end
			end
		elseif move.x < 0 then
			if self.min.x >= aabb.max.x then
				local d = -( self.min.x - aabb.max.x )

				if move.x < d then
					move.x = d
				end
			end
		end
	end

	if self:IsCrossingH( aabb ) then
		if move.z > 0 then
			if self.max.z <= aabb.min.z then
				local d = aabb.min.z - self.max.z

				if move.z > d then
					move.z = d
				end
			end
		elseif move.z < 0 then
			if self.min.z >= aabb.max.z then
				local d = -( self.min.z - aabb.max.z )

				if move.z < d then
					move.z = d
				end
			end
		end
	end

	return move
end

function EntAABB:IsBelong( v )
	if
		self.min.x > v.x or
		self.max.x < v.x or
		self.min.z > v.z or
		self.max.z < v.z 
	then
		return false
	end

	return true
end

function EntAABB:IsCrossing( aabb )
	if
		not self:IsCrossingH( aabb ) or
		not self:IsCrossingV( aabb )
	then
		return false
	end

	return true
end

function EntAABB:IsCrossingH( aabb )
	if
		self.min.x >= aabb.max.x or
		self.max.x <= aabb.min.x
	then
		return false
	end

	return true
end

function EntAABB:IsCrossingV( aabb )
	if
		self.min.z >= aabb.max.z or
		self.max.z <= aabb.min.z
	then
		return false
	end

	return true
end

function EntAABB:SetVelocity( v )
	self.velocity = v
	self:OnVelocityChanged()
end

function EntAABB:SetHVelocity( n )
	self.velocity.x = n
	self:OnVelocityChanged()
end

function EntAABB:SetVVelocity( n )
	self.velocity.z = n
	self:OnVelocityChanged()
end

function EntAABB:AddVelocity( v )
	self.velocity = self.velocity + v
	self:OnVelocityChanged()
end

function EntAABB:AddHVelocity( n )
	self.velocity.x = self.velocity.x + n
	self:OnVelocityChanged()
end

function EntAABB:AddVVelocity( n )
	self.velocity.z = self.velocity.z + n
	self:OnVelocityChanged()
end

function EntAABB:IsObstruction( unit )
	return false
end

function EntAABB:IsPhysics()
	return false
end

function EntAABB:HasGravity()
	return true
end

function EntAABB:HasWindage()
	return true
end

function EntAABB:GetLimitSpaces()
	return {}
end

function EntAABB:GetMove()
	return Vector()
end

function EntAABB.OnVelocityChanged() end
function EntAABB.OnGround() end