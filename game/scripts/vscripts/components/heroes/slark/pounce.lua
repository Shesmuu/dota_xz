local specialValues = {
	name = "slark_pounce",
	cooldown = 6,
	duration = 3
}

SlarkPounce = class( {}, nil, Ability )
SlarkPounce.specialValues = specialValues

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
		unit:Buff( SlarkPounceBuffSnap, self.parent, self, specialValues.duration )

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