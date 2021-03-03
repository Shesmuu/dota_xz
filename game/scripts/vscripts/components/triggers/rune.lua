RuneHaste = class( {
	effect = "particles/generic_gameplay/rune_haste_owner.vpcf",
	duration = 10,

	moveSpeedMulti = 1.5
}, nil, Buff )

local runesData = {
	[RUNE_HASTE] = {
		model = "models/props_gameplay/rune_haste01.vmdl",
		effect = "particles/generic_gameplay/rune_haste.vpcf",
		sound = "Rune.Haste",
		buff = RuneHaste
	}
}

Rune = class( {}, nil, Trigger )

function Rune:constructor( pos, spawner, r )
	Trigger.constructor( self, AABB( pos, 10, 10 ) )

	self.spawner = spawner
	self.data = runesData[r or Map:RandomRune()]
	self.prop = SpawnEntityFromTableSynchronous( "prop_dynamic", {
		origin = pos + Vector( 0, GameMode:Y() ),
		model = self.data.model,
		DefaultAnim = "ACT_DOTA_IDLE"
	} )

	self.particle = ParticleManager:CreateParticle( self.data.effect, PATTACH_POINT_FOLLOW, self.prop )
end

function Rune:OnStartTouch( unit )
	EmitSoundOn( self.data.sound, unit.unit )

	unit:Buff( self.data.buff )

	self:Destroy()
end

function Rune:OnDestroy()
	self.prop:Destroy()

	if self.spawner then
		self.spawner.rune = nil
	end

	ParticleManager:DestroyParticle( self.particle, false )
	ParticleManager:ReleaseParticleIndex( self.particle )
end