BristlebackSnot = class( {
	name = "bristleback_snot",
	channelingInterval = 0.3,
	maxChargeCount = 10,
	cooldown = 2
}, nil, ChannelingAbility )

function BristlebackSnot:OnChanneling()
	self.owner.unit:EmitSound( "Hero_Bristleback.ViscousGoo.Cast" )

	Projectile( {
		effect = "particles/heroes/bristleback/snot/bristleback_viscous_nasal_goo.vpcf",
		velocity = self.owner.dir * 800,
		startPos = GetAttachPos( self.owner.unit, "attach_attack3" ),
		radius = 20,
		duration = 2,
		unit = self.owner,
		onHit = function( unit , projectile )
			unit.unit:EmitSound( "Hero_Bristleback.ViscousGoo.Target" )

			unit:Buff( BristlebackSnotBuff, self.owner, self, 10 )

			projectile:Destroy()
		end
	} )
end

BristlebackSnotBuff = class( {
	effect = "particles/units/heroes/hero_bristleback/bristleback_viscous_nasal_goo_debuff.vpcf",
	statusEffect = 2,
	declareFilters = {
		"damage"
	},
	stackable = true,
	duration = 10,
}, nil, Buff )

function BristlebackSnotBuff:DamageFilter( data )
	if
		data.attacker ~= self.caster or
		data.victim ~= self.parent
	then
		return
	end

	data.damage = data.damage + self.stackCount
end

function BristlebackSnotBuff:GetMoveSpeedBonus()
	return self.stackCount * -10
end

BristlebackQuillSpray = class( {
	name = "bristleback_quill_spray",
	cooldown = 3
}, nil, Ability )

function BristlebackQuillSpray:OnCast()
	Particle(
		"particles/heroes/bristleback/quill_spray/bristleback_quill_spray.vpcf",
		PATTACH_ABSORIGIN,
		self.owner.unit,
		nil,
		nil,
		true
	)

	self.owner.unit:EmitSound( "Hero_Bristleback.QuillSpray.Cast" )

	local units = FindUnitsInRadiusXZ(
		self.owner.center,
		700,
		self.owner.team,
		TEAM_ENEMY,
		nil,
		true
	)

	for _, unit in pairs( units ) do
		self.owner.unit:EmitSound( "Hero_Bristleback.QuillSpray.Target" )

		unit:Buff( QuillSprayBuff, self.owner, self, 10 )
	end
end

QuillSprayBuff = class( {
	stackable = true,
	debuff = true
}, nil, Buff )

function QuillSprayBuff:OnCreated()
	self:Particle(
		"particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.parent.unit,
		{
			[1] = {
				pattach = PATTACH_ABSORIGIN_FOLLOW
			}
		}
	)

	QuillSprayDamage( self )
end

function QuillSprayDamage( buff )
	buff.parent:Damage( buff.caster, buff.ability, buff.stackCount * 2 + 4 )
end

QuillSprayBuff.OnRefresh = QuillSprayDamage

BristlebackWarpath = class( {
	name = "bristleback_warpath"
}, nil, Ability )

function BristlebackWarpath:OnCast()
	self.owner:Buff( WarpathBuff, self.owner, self, 10 )
end

WarpathBuff = class( {
	effect = "particles/units/heroes/hero_bristleback/bristleback_warpath_dust.vpcf"
}, nil, Buff )

Precaches:AddResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts" )

return {
	unit = "npc_xz_bristleback",
	hx = 40,
	hz = 40,
	maxHealth = 228,
	attackType = ATTACK_MELEE,
	attackDamage = 20,
	attackInterval = 0.3,
	moveSpeed = 450,
	abilityW = BristlebackSnot,
	abilityS = BristlebackQuillSpray,
	abilityX = BristlebackWarpath
}