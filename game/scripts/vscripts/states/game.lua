Game = {
	buffFilters = {
		damage = {}
	},
	buffEvents = {
		damage = {},
		unitKilled = {}
	},
}

function Game:Start( heroes )
	GameMode.state = self

	for id, hero in pairs( heroes ) do
		GameMode.players[id]:Hero( GameMode.heroes[hero] )
	end

	self:StatisticsUpdated()

	Map:GameStart()

	GameMode:UpdateStateNetTable()
end

function Game:Update( now, dt )
	MethodAll( GameMode.triggers, EntAABB.Physic, now, dt )
	MethodAll( GameMode.units, EntAABB.Physic, now, dt )

	MethodAll( GameMode.triggers, Trigger.Update, now, dt )
	MethodAll( GameMode.units, Unit.Update, now, dt )
	MethodAll( GameMode.projectiles, Projectile.Update, now, dt )
	MethodAll( GameMode.players, Player.Update, dt )

	if self.statisticsUpdated then
		self:StatisticsUpdated()
	end

	if self.winner then
		self:End()
	end
end

function Game:DamageFilter( data )
	for _, buff in pairs( self.buffFilters.damage ) do
		buff:DamageFilter( data )
	end

	data.damage = math.ceil( data.damage )
end

function Game:DamageEvent( data )
	for _, buff in pairs( self.buffEvents.damage ) do
		buff:DamageEvent( data )
	end

	local ap, vp, ally = AttackerVictim( data.attacker, data.victim )

	if not ally then
		if ap then
			ap:AddStatistics( "heroDamage" )

			self.statisticsUpdated = true
		end

		if data.victim.isHero and vp then
			if ap then
				ap.lastDamages[ap.id] = GameRules:GetGameTime()
			end

			ap:AddStatistics( "damageTaked", data.originalDamage )

			self.statisticsUpdated = true
		end
	end

	Particle(
		"particles/msg_fx/msg_damage.vpcf",
		PATTACH_CUSTOMORIGIN,
		nil,
		{
			[0] = data.victim.pos,
			[1] = Vector( 0, data.damage, 0 ),
			[2] = Vector( 3, #tostring( data.damage ), 0 ),
			[3] = Vector( 255, 0, 0 )
		},
		nil,
		true
	)

end

function Game:UnitKilledEvent( attacker, victim )
	for _, buff in pairs( self.buffEvents.unitKilled ) do
		buff:UnitKilledEvent( attacker, victim )
	end

	local ap, vp, ally = AttackerVictim( attacker, victim )

	if not ally then
		if ap then
			if victim.isHero then
				ap:AddStatistics( "kills" )
			elseif victim.isBoss then
				ap:AddStatistics( "bosses" )
			else
				ap:AddStatistics( "creeps" )
			end
		end

		if vp then
			for _, id in pairs( vp.lastDamages ) do
				local p = GameMode.players[id]

				if p and p.team == attacker.team then
					p:AddStatistics( "assists" )
				end
			end

			vp:AddStatistics( "deaths" )
		end
	end

	if Map.UnitKilledEvent then
		Map:UnitKilledEvent( attacker, victim )
	end

	Particle(
		"particles/msg_fx/msg_death.vpcf",
		PATTACH_CUSTOMORIGIN,
		nil,
		{
			[0] = victim.pos
		},
		nil,
		true
	)
end

function Game:StatisticsUpdated()
	local t = {
		players = {},
		teams = {}
	}

	for _, player in pairs( GameMode.players ) do
		t.players[player.id] = player.statistics
	end

	for _, team in pairs( GameMode.teams ) do
		t.teams[team.index] = team.score
	end

	CustomNetTables:SetTableValue( "game", "statistics", t )

	Map:StatisticsUpdated( t )

	self.statisticsUpdated = false
end

function Game:GetNetTableData()
	return {
		state = XZ_STATE_GAME
	}
end

function Game:End( winner )
	if GameMode.state == self then
		Map:GameEnd()

		Finished:Start( winner )
	end
end