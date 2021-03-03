require( "maps/battle_royale/play_area" )

Map.y = -128
Map.teamCount = 24
Map.playersInTeam = 1
Map.deathScreenType = "battle_royale"
Map.topBarType = "battle_royale"
Map.scoreboardType = "battle_royale"
Map.respawnEnabled = false

Map.teamSpawners = {
	[1] = {
		Vector( -1864, 0, 2080 ),
		Vector( -1736, 0, 2080 ),
		Vector( -1600, 0, 2080 ),
		Vector( -1456, 0, 2080 )
	},
	[2] = {
		Vector( 1856, 0, 2080 ),
		Vector( 1712, 0, 2080 ),
		Vector( 1576, 0, 2080 ),
		Vector( 1448, 0, 2080 )
	}
}

Map.bounds = {
	min = Vector( -7232, 0, -7232 ),
	max = Vector( 7232, 0, 7232 )
}
Map.cameraBounds = Map.bounds

function Map:Update( now, dt )
	PlayArea:Update( now, dt )
end

function Map:GameStart()
	PlayArea:Create()
end

function Map:CustomGameSetup()
	self.alive = #GameMode.players
end

function Map:UnitKilledEvent( attacker, victim )
	if victim.isHero then
		victim.player.statistics.rank = self.alive

		self.alive = self.alive - 1

		if self.alive <= 1 then
			Game:End()
		end
	end
end

function Map:GameEnd()
	for _, player in pairs( GameMode.players ) do
		if player.hero.alive then
			player.statistics.rank = 1
		end
	end
end