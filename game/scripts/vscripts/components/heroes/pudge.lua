PudgeHook = class( {}, nil, Ability )

PudgeDismember = class( {}, nil, Ability )

PudgeRot = class( {}, nil, ChannelingAbility )

function PudgeRot:OnChannelStart()
	self.particle = Particle(
		"particles/units/heroes/hero_pudge/pudge_rot.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		self.owner.unit,
		{
			[1] = Vector( 150, 0, 0 )
		}
	)
end

function PudgeRot:OnChannelEnd()
	DestroyParticle( self.particle )
end