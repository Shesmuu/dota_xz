Http = {
	host = IsInToolsMode() and "http://localhost/"
}

function Http:GameEnded()
	
end

function Http:GameStarting()
	local steam_ids = {}

	for id, _ in pairs( GameMode.players ) do
		table.insert( steam_ids, tostring( PlayerResource:GetSteamID() ) )
	end

	self:Request( "get/players", {
		ids = steam_ids,
		map = GetMapName()
	}, function( data )
		
	end, function()
		
	end )
end

function Http:Request( p, data, success, fail )
	if IsCheatMode() then
		return
	end

	local r = CreateHTTPRequestScriptVM( "POST", self.host .. p )

	if data then
		r:SetHTTPRequestRawPostBody( "application/json", json.encode( data ) )
	end

	r:Send( function( response )
		if response.StatusCode == 200 then
			local decoded = json.decode( response.Body )

			if success then
				success( decoded )
			end
		else
			if fail then
				fail( response )
			end
		end
	end )
end