Team = class( {} )

function Team:constructor( index )
	self.index = index
	self.players = {}
	self.score = 0

	self.spawners = Map.teamSpawners[index]
	self.spawner = 1
end

function Team:SetScore( count )
	self.score = count

	Game.statisticsUpdated = true
end

function Team:AddScore( count )
	self:SetScore( self.score + ( count or 1 ) )
end

function Team:AddPlayer( player )
	if #self.players >= Map.playersInTeam then
		return 
	end

	player.team = self

	table.insert( self.players, player )
end

function Team:RemovePlayer( player )
	player.team = nil

	RemoveFrom( self.players, player )
end

function Team:GetSpawner()
	local spawner = self.spawners[self.spawner]

	if not spawner then
		self.spawner = 1

		spawner = self.spawners[1]
	end

	return spawner
end

function Team:UpdateNetTable( test )
	local teams = CustomNetTables:GetTableValue( "game", "teams" ) or {}
	local team = {}

	for _, player in pairs( self.players ) do
		table.insert( team, player.id )
	end

	teams[tostring( self.index )] = team

	CustomNetTables:SetTableValue( "game", "teams", teams )
end