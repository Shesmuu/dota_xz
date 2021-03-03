Unit = class( {}, nil, EntAABB )

function Unit:constructor( data, pos, team )
	EntAABB.constructor( self, pos, 110, 110, true )

	self.abilities = {}
	self.buffs = {}
	self.team = team
	self.unitData = data

	self.unit = CreateUnitByName( data.unit, Vector(), false, nil, nil, 2 )

	self.maxHealth = data.maxHealth
	self.healthRegen = data.healthRegen
	self.attackType = data.attackType
	self.projectileEffect = data.projectileEffect
	self.projectileSpeed = data.projectileSpeed

	self.nextAttackTime = 0
	self.attacking = false
	self.dir = Vector( 1 )

	self.alive = true
	self.health = data.maxHealth

	self.index = Add( GameMode.units, self )
end

function Unit:IsPhysics()
	return true
end

function Unit:Update( now, dt )
	MethodAllSeq( self.buffs, Buff.Update, now )
	MethodAll( self.abilities, Ability.Update, now )

	if not self.alive then
		if now >= self.respawnTime then
			self:Respawn()
		else
			return
		end
	end

	local health = self.health
	local maxHealth = self:GetMaxHealth()

	if health < maxHealth then
		self.health = math.min( self.health + self:GetHealthRegen() * dt, self:GetMaxHealth() )

		if health ~= self.health then
			self.updated = true
		end
	end

	if self.attacking and now >= self.nextAttackTime then
		self:Attack()
		self.nextAttackTime = now + self:GetAttackInterval()
	end

	if self.onGround then
		self:Ground()
	end

	self.unit:SetAbsOrigin( Vector( self.pos.x, GameMode:Y(), self.pos.z - self.height * 0.5 ) )
end

function Unit:SetDir( dir )
	self.unit:SetForwardVector( Vector( One( dir.x ) ) )
	self.dir = dir
end

function Unit:SetAttacking( b )
	self.attacking = b
end

function Unit:Jump()
	self:SetVVelocity( 1250 )
end

function Unit:Ground()
	
end

function Unit:Attack()
	self.unit:ForcePlayActivityOnce( ACT_DOTA_ATTACK )

	if self.attackType == ATTACK_RANGE then
		Projectile( {
			effect = self.projectileEffect,
			velocity = self.dir * self.projectileSpeed,
			startPos = GetAttachPos( self.unit ),
			radius = 20,
			duration = 100
		} )
	else
		local ac = self.pos + self.dir:Normalized() * 40
		local particle = ParticleManager:CreateParticle( "particles/melee_attack.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( particle, 0, ac + Vector( 0, GameMode:Y(), 0 ) )
		ParticleManager:SetParticleControlForward( particle, 0, self.dir )
		ParticleManager:ReleaseParticleIndex( particle )

		local units = FindUnitsInAABB( AABB( ac, 40, 40 ), self.team, TEAM_ENEMY )

		for _, unit in pairs( units ) do
			unit:Damage( self, nil, self:GetAttackDamage() )
		end
	end
end

function Unit:Damage( attacker, ability, damage )
	local damageTable = {
		attacker = attacker,
		ability = ability,
		originalDamage = damage,
		damage = damage,
		victim = self
	}

	Game:DamageFilter( damageTable )

	if damageTable.damage >= self.health then
		damageTable.damage = self.health

		self:Kill( source )
	else
		self.health = self.health - damageTable.damage
	end

	self.updated = true

	Game:DamageEvent( damageTable )
end

function Unit:Kill()
	self.unit:SetUnitCanRespawn( true )
	self.unit:ForceKill( false )

	self.health = 0
	self.alive = false

	if self.isHero and Map.respawnEnabled then
		self.respawnTime = GameRules:GetGameTime() + Map.respawnTime
	else
		Delay( 5, function()
			self:Destroy()
		end )
	end

	self:SetPos( self.pos )
	self:SetDir( self.dir )

	self.updated = true
end

function Unit:Respawn()
	self.unit:RespawnUnit()

	self.health = self:GetMaxHealth()
	self.alive = true

	self:SetPos( self.player.team:GetSpawner() )

	self.updated = true
end

function Unit:Buff( buffClass, ... )
	local buff = self:FindBuff( buffClass )

	if buff then
		buff:Refresh( ... )
	else
		buffClass( self, ... )
	end
end

function Unit:FindBuff( buffClass )
	for _, buff in pairs( self.buffs ) do
		if getclass( buff ) == buffClass then
			return buff
		end
	end
end

function Unit:GetClientData()
	local t = {
		ent = self.unit:GetEntityIndex(),
		team = self.team.index,
		max_health = self:GetMaxHealth(),
		move_speed = self:GetMoveSpeed(),
		health = self.health,
		alive = self.alive,
		respawn_time = self.respawnTime,
		buffs = {}
	}

	for _, buff in pairs( self.buffs ) do
		if not buff:Get( "hidden" ) then
			table.insert( t.buffs, buff:GetClientData() )
		end
	end

	if self.isHero then
		t.abilities = {}

		for k, ability in pairs( self.abilities ) do
			t.abilities[k] = ability:GetClientData()
		end
	end

	return t
end

function Unit:Destroy()
	self.unit:Destroy()

	GameMode.units[self.index] = nil
end

function Unit:GetPlayer()
	local unit = self

	while true do
		if unit.player then
			return unit.player
		elseif unit.owner then
			unit = unit.owner
		else
			return
		end
	end
end

function Unit:GetMoveSpeed()
	local ms = self.unitData.moveSpeed
	local m = 1

	for _, buff in pairs( self.buffs ) do
		ms = ms + buff:GetMoveSpeedBonus()
		m = m * buff:GetMoveSpeedMulti()
	end

	return ms * m
end

function Unit:GetMaxHealth()
	local h = self.unitData.maxHealth
	local m = 1

	--for _, buff in pairs( self.buffs ) do
	--	h = h + buff
	--end

	return h * m
end

function Unit:GetAttackDamage()
	local ad = self.unitData.attackDamage
	local m = 1

	--for _, buff in pairs( self.buffs ) do
	--	ad = ad + buff.attackDamageBonus
	--end

	return ad * m
end

function Unit:GetHealthRegen()
	return 1
end

function Unit:GetAttackInterval()
	return 1
end