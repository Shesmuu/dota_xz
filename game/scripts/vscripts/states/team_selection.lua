TeamSelection = {}

function TeamSelection:Start()
	GameMode.state = self

	self.unassigned = {}

	self.selectTeamListener = ListenToClient( "team_selection_select", Dynamic_Wrap( self, "SelectTeam" ), self )
	self.confirmListener = ListenToClient( "team_selection_confirm", Dynamic_Wrap( self, "Confirm" ), self )

	self.endTime = GameRules:GetGameTime() + Map.teamSelectionTime

	GameMode:UpdateStateNetTable()
end

function TeamSelection:SelectTeam( data )
	local team = GameMode.teams[data.team] or -1
	local max = team == -1 and 4 or Map.playersInTeam
	local players = team == -1 and self.unassigned or team.players

	if max - #players >= 1 then
		local player = GameMode.players[data.PlayerID]
		local current_team = player.team

		if current_team == -1 then
			RemoveFrom( self.unassigned, player.id )

			if #self.unassigned == 0 then
				self.endTime = GameRules:GetGameTime() + Map.teamSelectionTime
			end
		else
			player.team:RemovePlayer( player )
		end

		if team == -1 then
			table.insert( self.unassigned, player.id )
			player.team = -1

			self.endTime = nil
		else
			team:AddPlayer( player )
		end

		GameMode:UpdateStateNetTable()
		GameMode:UpdateTeamsNetTable()
	end
end

function TeamSelection:Confirm( data )
	if data.PlayerID == 0 then
		if #self.unassigned > 0 then
			self:AssignPlayers()
		end

		self:End()
	end
end

function TeamSelection:AssignPlayers()
	for _, id in pairs( self.unassigned ) do
		local min

		for _, team in pairs( GameMode.teams ) do
			min = min or team

			if #team.players < #min.players then
				min = team
			end
		end

		min:AddPlayer( GameMode.players[id] )
	end
		
	GameMode:UpdateTeamsNetTable()
end

function TeamSelection:Update( now )
	if self.endTime and now > self.endTime then
		self:End()
	end
end

function TeamSelection:GetNetTableData()
	return {
		state = XZ_STATE_TEAM_SELECTION,
		unassigned = self.unassigned,
		end_time = self.endTime
	}
end

function TeamSelection:End()
	CustomGameEventManager:UnregisterListener( self.selectTeamListener )
	CustomGameEventManager:UnregisterListener( self.confirmListener )

	self.endTime = nil
	self.unassigned = nil

	HeroSelection:Start()
end