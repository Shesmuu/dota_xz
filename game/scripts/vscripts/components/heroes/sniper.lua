SniperTrap = class( {
	name = "sniper_trap",
	cooldown = 20,
}, nil, Ability )

function SniperTrap:OnCast()
	
end

SniperTrapTrigger = class( {}, nil, Trigger )

function SniperTrapTrigger:constructor()
	Trigger.constructor( self, )
end

function SniperTrapTrigger:OnStartTouch( unit )
	
end

return {

}