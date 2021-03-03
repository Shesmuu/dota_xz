local specialValues = {
	name = "slark_pounce",
	cooldown = 6,
	duration = 3
}

SlarkPounce = class( {
	name = "slark_pounce",
	cooldown = 6,
}, nil, Ability )

function SlarkPounce:OnCast()
	self.owner:SetVelocity( self.owner.dir * 1800 )

	self.owner.unit:EmitSound( "Hero_Slark.Pounce.Cast" )

	Particle(
		"particles/units/heroes/hero_slark/slark_pounce_start.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.owner.unit,
		nil,
		nil,
		true
	)

	self.owner.unit:StartGesture( ACT_DOTA_SLARK_POUNCE )

	SlarkPounceBuffSlark( self.owner, self.owner, self, 1 )
end

SlarkPounceBuffSlark = class( {
	interval = 0,
	hidden = true
}, nil, Buff )

function SlarkPounceBuffSlark:OnInterval()
	local unit = FindUnitsInAABB( self.parent, self.parent.team, TEAM_ENEMY )[1]

	if unit then
		unit:Buff( SlarkPounceBuffSnap, self.parent, self, 3 )

		self:Destroy()
	end
end

function SlarkPounceBuffSlark:OnVelocityChanged()
	self:Destroy()
end

function SlarkPounceBuffSlark:OnDestroy()
	self.parent.unit:FadeGesture( ACT_DOTA_SLARK_POUNCE )
end

SlarkPounceBuffSnap = class( {
	debuff = true
}, nil, Buff )

function SlarkPounceBuffSnap:OnCreated()
	self.limitedSpace = AABB( self.parent.pos, 150, 150 )

	self.parent.unit:EmitSound( "Hero_Slark.Pounce.Impact" )
	self.parent.unit:EmitSound( "Hero_Slark.Pounce.Leash" )

	self:Particle(
		"particles/units/heroes/hero_slark/slark_pounce_ground.vpcf",
		PATTACH_WORLDORIGIN,
		self.parent.unit,
		{
			[3] = self.parent.pos,
			[4] = Vector( 150 )
		}
	)

	self:Particle(
		"particles/units/heroes/hero_slark/slark_pounce_leash.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.parent.unit,
		{
			[1] = {},
			[3] = self.parent.pos
		}
	)
end

function SlarkPounceBuffSnap:OnDestroy()
	self.parent.unit:StopSound( "Hero_Slark.Pounce.Leash" )
	self.parent.unit:EmitSound( "Hero_Slark.Pounce.End" )
end

SlarkDarkPact = class( {
	name = "slark_dark_pact",
	cooldown = 5,
}, nil, Ability )

function SlarkDarkPact:OnCast()
	self.owner.unit:EmitSound( "Hero_Slark.DarkPact.PreCast" )

	local particle = Particle(
		"particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.owner.unit,
		{
			[1] = {
				pattach = PATTACH_ABSORIGIN_FOLLOW
			}
		}
	)

	Delay( 1.5, function()
		ParticleManager:DestroyParticle( particle, false )
		ParticleManager:ReleaseParticleIndex( particle )

		Particle(
			"particles/heroes/slark/dark_pact/slark_dark_pact_pulses.vpcf",
			PATTACH_ABSORIGIN_FOLLOW,
			self.owner.unit,
			{
				[0] = {},
				[1] = {
					pattach = PATTACH_ABSORIGIN_FOLLOW
				},
				[3] = Vector( 200 )
			},
			nil,
			true
		)

		self.owner.unit:StartGesture( ACT_DOTA_CAST_ABILITY_1 )

		self.owner:Buff( SlarkDarkPactBuff, self.owner, self, 1 )
	end )
end

SlarkDarkPactBuff = class( {
	interval = 0.1
}, nil, Buff )

function SlarkDarkPactBuff:OnInterval()
	--self.parent:Purge( true )

	local units = FindUnitsInRadiusXZ(
		self.parent.pos,
		200,
		self.parent.team,
		TEAM_ENEMY,
		nil,
		true
	)

	for _, unit in pairs( units ) do
		unit:Damage( self.parent, self, 5 )
	end
end

SlarkShadowDance = class( {
	name = "slark_shadow_dance",
	cooldown = 20,
}, nil, Ability )

function SlarkShadowDance:OnCast()
	self.owner:Buff( SlarkShadowDanceBuff, self.owner, self, 3.5 )
end

SlarkShadowDanceBuff = class( {
	statusEffect = 1,
	dodgeProjectiles = 100,
	healthRegenPerc = 10,

	moveSpeedMulti = 1.7
}, nil, Buff )

function SlarkShadowDanceBuff:OnCreated()
	self:Particle(
		"particles/units/heroes/hero_slark/slark_shadow_dance.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.parent.unit,
		{
			[1] = {},
			[3] = {
				attach = "attach_eyeR"
			},
			[4] = {
				attach = "attach_eyeL"
			}		
		}
	)

	self:Particle(
		"particles/units/heroes/hero_slark/slark_shadow_dance_dummy.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.parent.unit,
		{
			[1] = {
				pattach = PATTACH_ABSORIGIN_FOLLOW
			}
		}
	)
end

Precaches:AddResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slark.vsndevts" )

return {
	unit = "npc_xz_slark",
	hx = 40,
	hz = 40,
	maxHealth = 228,
	attackType = ATTACK_MELEE,
	attackDamage = 20,
	attackInterval = 0.3,
	moveSpeed = 450,
	abilityW = SlarkPounce,
	abilityS = SlarkDarkPact,
	abilityX = SlarkShadowDance
}