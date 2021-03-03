Finished = {}

function Finished:Start( winner )
	GameMode.state = self

	self.winner = winner

	GameMode:UpdateStateNetTable()
	GameRules:SetGameWinner( DOTA_TEAM )
end

function Finished:GetNetTableData()
	return {
		state = XZ_STATE_FINISHED,
		winner = self.winner.index
	}
end