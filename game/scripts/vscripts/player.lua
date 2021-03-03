Player = class( {} )

function Player:constructor( id )
	self.id = id
	self.control = {}
	self.statistics = {
		kills = 0,
		deaths = 0,
		assists = 0,
		creeps = 0,
		bosses = 0,
		heroDamage = 0,
		damageTaked = 0
	}
	self.rating = 0

	self.camera = CreateUnitByName( "npc_xz_dummy", Vector(), false, nil, nil, 2 )

	ListenToClient( "control", Dynamic_Wrap( Player, "Control" ), self, self.id )
	ListenToClient( "cursor", Dynamic_Wrap( Player, "Cursor" ), self, self.id )
	ListenToClient( "mouse", Dynamic_Wrap( Player, "Mouse" ), self, self.id )
	ListenToClient( "connected", Dynamic_Wrap( Player, "Connected" ), self, self.id )

	self:UpdateNetTable()
end

function Player:AddStatistics( name, value )
	self.statistics[name] = self.statistics[name] + ( value or 1 )

	Game.statisticsUpdated = true
end

function Player:Control( data )
	if not self.hero or not self.hero.alive then
		return
	end

	local k = data.key
	local v = data.value
	local n = tonumber( k )
	local ability = self.hero.abilities[k]

	if k == "a" then
		self.hero.control.left = v == 1
	elseif k == "d" then
		self.hero.control.right = v == 1
	elseif k == "space" and v == 1 then
		self.hero:Jump()
	elseif k == "e" then
		
	elseif ability then
		if v == 1 then
			ability:Pressed()
		else
			ability:Released()
		end
	elseif n then
		self.hero:SelectItem( n )
	end
end

function Player:Cursor( data )
	self.cursorDir = Vector( data.x, 0, -data.z )

	if  self.cursorDir == Vector() then
		self.cursorDir = Vector( 1 )
	end

	if self.hero and self.hero.alive then
		self.camera:SetAbsOrigin( self.hero.pos )

		self.hero:SetAttacking( data.lkm == 1 )
		self.hero:SetDir( self.cursorDir:Normalized() )
	end
end

function Player:Mouse( data )

end

function Player:IsConnected()
	return ( PlayerResource:GetPlayer( self.id ) )
end

function Player:GameInProgress()
	PlayerResource:SetCameraTarget( self.id, self.camera )
end

function Player:Hero( data )
	self.hero = Hero( self, data, self.team )

	self:HeroUpdated()
end

function Player:Update()
	if self.hero and self.hero.updated then
		self:HeroUpdated()

		self.hero.updated = false
	end
end

function Player:HeroUpdated()
	if not self.hero then
		return
	end

	local player = PlayerResource:GetPlayer( self.id )

	if player then
		CustomGameEventManager:Send_ServerToPlayer( player, "hero_updated", self.hero:GetClientData() )
	end
end

function Player:UpdateNetTable()
	CustomNetTables:SetTableValue( "players", tostring( self.id ), {
		camera = self.camera:GetEntityIndex(),
		team = self.team and self.team.index or nil
	} )
end

function Player:Connected()
	self:HeroUpdated()
end