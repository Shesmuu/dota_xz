Buff = class( {} )

function Buff:constructor( parent, caster, ability, duration )
	local now = GameRules:GetGameTime()

	self.parent = parent
	self.particles = {}
	self.filters = {}
	self.events = {}
	self:SetData( now, caster, ability, duration )

	if self.effect then
		self:Particle( self.effect, PATTACH_POINT_FOLLOW, parent.unit )
	end

	if self.interval then
		self.nextInterval = now + self.interval
	end

	if self.stackable then
		self.stackCount = 1
	end

	if self.statusEffect then
		self.statusEffectModifier = StatusEffect( self.parent.unit, self.statusEffect )
	end

	if self.declareFilters then
		for _, filter in pairs( self.declareFilters ) do
			self.filters[filter] = Add( Game.buffFilters[filter], self )
		end
	end

	if self.declareEvents then
		for _, event in pairs( self.declareEvents ) do
			self.events[event] = Add( Game.buffEvents[event], self )
		end
	end

	self:OnCreated()

	self.index = Add( parent.buffs, self )

	self.parent.updated = true
end

function Buff:SetStackCount( count )
	if self.stackCount == count then
		return
	end

	self.stackCount = count

	self:OnStackCountChanged()

	self.parent.updated = true
end

function Buff:ChangeStackCount( count )
	self:SetStackCount( self.stackCount + count )
end

function Buff:Particle( ... )
	local p = Particle( ... )

	table.insert( self.particles, p )

	return p
end

function Buff:SetData( now, caster, ability, duration )
	self.caster = caster or self.caster or self.parent
	self.ability = ability or self.ability

	if duration then
		self.duration = duration
		self.dieTime = now + self.duration
	else
		self.dieTime = nil
		self.duration = nil
	end
end

function Buff:Refresh( ... )
	self:SetData( GameRules:GetGameTime(), ... )

	if self.stackable then
		self:ChangeStackCount( 1 )

		if not self.stackPermanent then
			Delay( self.duration, function()
				self:ChangeStackCount( -1 )
			end )
		end
	end

	self:OnRefresh()

	self.parent.updated = true
end

function Buff:Update( now )
	if self.interval and now >= self.nextInterval then
		self:OnInterval()

		self.nextInterval = now + self.interval
	end

	if self.dieTime and now >= self.dieTime then
		self:Destroy()
	end
end

function Buff:GetClientData()
	return {
		ability_name = self.ability and self.ability.specialValues.name or nil,
		duration = self.duration,
		die_time = self.dieTime,
		debuff = self:IsDebuff()
	}
end

function Buff:Destroy()
	self:OnDestroy()

	for _, p in pairs( self.particles ) do
		ParticleManager:DestroyParticle( p, false )
		ParticleManager:ReleaseParticleIndex( p )
	end

	if self.statusEffectModifier then
		self.statusEffectModifier:Destroy()
	end

	if self.declareFilters then
		for filter, index in pairs( self.filters ) do
			Game.buffFilters[filter][index] = nil
		end
	end

	RemoveFrom( self.parent.buffs, self )

	self.parent.updated = true
end

function Buff:IsDebuff()
	return self.caster.team ~= self.parent.team
end

Buff.GetMoveSpeedBonus = FUNCTION_0
Buff.GetAttackDamageBonus = FUNCTION_0
Buff.GetAttackIntervalBonus = FUNCTION_0
Buff.GetMaxHealthBonus = FUNCTION_0
Buff.GetHealthRegenBonus = FUNCTION_0
Buff.GetHealthRegenPerc = FUNCTION_0
Buff.GetDamageBlockBonus = FUNCTION_0
Buff.GetEvadeDamageBonus = FUNCTION_0
Buff.GetEvadeProjectileBonus = FUNCTION_0

Buff.GetMoveSpeedMulti = FUNCTION_1
Buff.GetAttackDamageMulti = FUNCTION_1
Buff.GetAttackIntervalMulti = FUNCTION_1
Buff.GetMaxHealthMulti = FUNCTION_1
Buff.GetHealthRegenMulti = FUNCTION_1

Buff.GetTrueStrike = FUNCTION_FALSE

Buff.OnCreated = FUNCTION_NIL
Buff.OnRefresh = FUNCTION_NIL
Buff.OnInterval = FUNCTION_NIL
Buff.OnDestroy = FUNCTION_NIL
Buff.OnStackCountChanged = FUNCTION_NIL