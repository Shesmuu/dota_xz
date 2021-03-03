require( "components/triggers/team_barrier" )

Map.y = 192
Map.teamCount = 2
Map.playersInTeam = 2
Map.teamColors = {
	[1] = { 138, 58, 58 },
	[2] = { 219, 204, 66 }
}
Map.teamNames = {
	[1] = "Team One",
	[2] = "Team Second"
}

Map.teamSpawners = {
	[1] = {
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 )
	},
	[2] = {
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 ),
		Vector( -11537.7, 0, 14336 )
	}
}

function Map:Activate()
	local t = GameMode.teams
end

function Map:OnGameStart()
end