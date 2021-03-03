require( "components/other/rune_spawners" )
require( "components/triggers/team_barrier" )

Map.y = -148
Map.teamCount = 2
Map.playersInTeam = 2
Map.scoreLimit = 20
Map.teamColors = {
	[1] = { 138, 58, 58 },
	[2] = { 219, 204, 66 }
}
Map.teamNames = {
	[1] = "team_pvp_1",
	[2] = "team_pvp_2"
}
Map.teamLogos = {
	[1] = "file://{images}/custom_game/team_logos/pvp_first.png",
	[2] = "file://{images}/custom_game/team_logos/pvp_second.png"
}

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

function Map:Activate()
	local t = GameMode.teams

	TeamBarrier( t[1], Vector( -1952, 0, 2080 ), Vector( -1232, 0, 2416 ) )
	TeamBarrier( t[2], Vector( 1216, 0, 2080 ), Vector( 1936, 0, 2416 ) )

	self.runeSpawners = {
		RuneSpawner( Vector( 776, 0, 3448 ), 30, 0 ),
		RuneSpawner( Vector( -752, 0, 3448 ), 30, 0 )
	}
end

function Map:GameStart()
	for _, s in pairs( self.runeSpawners ) do
		s:Activate()
	end
end