require( "components/heroes/slark/pounce" )
require( "components/heroes/slark/dark_pact" )
require( "components/heroes/slark/shadow_dance" )
require( "components/heroes/slark/unique_buff" )

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
		self.parent.center,
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