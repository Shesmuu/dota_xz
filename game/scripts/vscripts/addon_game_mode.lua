if GameMode then
	return
end

_G.GameMode = {
	heroes = {},
	teams = {},
	players = {},
	other = {},
	units = {},
	projectiles = {},
	triggers = {},
	interactions = {},
	events = {},
	timers = {},
	lastTime = 0,
	teamSelectionEnabled = false
}

require( "utils" )
require( "constants" )
require( "precache" )

require( "states/team_selection" )
require( "states/hero_selection" )
require( "states/game" )
require( "states/finished" )

require( "components/projectile" )
require( "components/ability" )
require( "components/channeling_ability" )
require( "components/buff" )
require( "components/ent_aabb" )
require( "components/trigger" )
require( "components/unit" )
require( "components/hero" )

require( "components/triggers/rune" )

require( "player" )
require( "team" )
require( "http" )
require( "map" )

local map_path = "maps/" .. GetMapName()

require( map_path .. "/collisions" )
require( map_path .. "/blocks" )
require( map_path .. "/map" )

function GameMode:Y()
	return Map.y
end

function GameMode:Update()
	if GameRules:IsGamePaused() then
		return 0
	end

	local now = GameRules:GetGameTime()
	local dt = now - self.lastTime

	self.lastTime = now

	for i, timer in pairs( self.timers ) do
		if now >= timer.endTime then
			local time = timer.func()

			if time then
				timer.endTime = now + time
			else
				self.timers[i] = nil
			end
		end
	end

	if self.state then
		self.state:Update( now, dt )
	end

	Map:Update( now, dt )

	return 0
end

function GameMode:UpdateTeamsNetTable()
	local t = {}

	for i, team in pairs( self.teams ) do
		t[i] = {
			score = team.score,
			players = {}
		}

		for p, player in pairs( team.players ) do
			t[i].players[p] = player.id
		end
	end

	CustomNetTables:SetTableValue( "game", "teams", t )
end

function GameMode:UpdateStateNetTable()
	CustomNetTables:SetTableValue( "game", "state", self.state:GetNetTableData() )
end

function GameMode:GameInProgress()
	MethodAll( self.players, Player.GameInProgress )

	Map:GameInProgress()

	if self.teamSelectionEnabled then
		TeamSelection:Start()
	else
		HeroSelection:Start()
	end
end

function GameMode:CustomGameSetup()
	for id = 0, 64 do
		if PlayerResource:IsValidPlayerID( id ) then
			self.players[id] = Player( id )
		end
	end

	self:FormTeams()

	Map:CustomGameSetup()
end

function GameMode:Activate()
	SendToServerConsole( "r_farz 10000" )

	self.neutralTeam = Team( "neutral" )

	for i = 1, Map.teamCount do
		self.teams[i] = Team( i )
	end

	Map:Activate()

	local hero_list = {}

	for i, name in pairs( Map.heroes ) do
		local hero = self.heroes[name]

		hero_list[i] = {
			name = name,
			attributies = {
				width = hero.width,
				height = hero.height,
				health = hero.maxHealth,
				attack_damage = hero.attackDamage,
				attack_interval = hero.attackInterval,
				move_speed = hero.moveSpeed
			},
			abilities = {
				w = hero.abilityW.specialValues,
				s = hero.abilityS.specialValues,
				x = hero.abilityX.specialValues
			}
		}
	end

	CustomNetTables:SetTableValue( "game", "statics", {
		team_count = Map.teamCount,
		players_in_team = Map.playersInTeam,
		team_colors = Map.teamColors,
		team_names = Map.teamNames,
		team_logos = Map.teamLogos,
		death_screen_type = Map.deathScreenType,
		top_bar_type = Map.topBarType,
		scoreboard_type = Map.scoreboardType,
		hero_list = hero_list
	} )

	self:Convars()
	self:Events()
	self:Modifiers()
	self:Settings()
end

function GameMode:Convars()
	Convars:RegisterCommand( "xz_set_winner", function( _, teamID )
		Game:End( self.teams[tonumber( teamID )] )
	end, "", FCVAR_CHEAT )

	Convars:RegisterCommand( "xz_create_unit", function( _ )
		local hero = self.players[0].hero

		Unit( {
			unit = "npc_xz_slark",
			hx = 40,
			hz = 40,
			maxHealth = 228,
			attackType = ATTACK_MELEE,
			attackDamage = 20,
			attackInterval = 0.3,
			moveSpeed = 450
		}, hero.pos + hero.dir * 400, self.neutralTeam )
	end, "", FCVAR_CHEAT )
end

function GameMode:Events()
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( self, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( self, "OnNPCSpawned" ), self )
end

function GameMode:OnGameRulesStateChange()
	local s = GameRules:State_Get()

	if s == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		self:CustomGameSetup()
	elseif s == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:GameInProgress()
	end
end

function GameMode:OnNPCSpawned( data )
	local unit = EntIndexToHScript( data.entindex )

	if unit:IsRealHero() or unit:GetUnitName() == "npc_xz_dummy" then
		unit:AddNewModifier( unit, nil, "modifier_xz_hidden", nil )
		unit:AddNoDraw()
	else
		unit:AddNewModifier( unit, nil, "modifier_xz_unit", nil )
	end
end

function GameMode:Settings()
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM, 24 )
	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameRules:SetFirstBloodActive( false )
	GameRules:SetGoldPerTick( 0 )
	GameRules:SetPostGameTime( 60 )
	GameRules:SetPreGameTime( 0 )
	GameRules:SetSafeToLeave( true )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetStartingGold( 0 )
	GameRules:SetStrategyTime( 0 )
	GameRules:SetTimeOfDay( 0 )

	local ent = GameRules:GetGameModeEntity()

	ent:SetAnnouncerDisabled( false )
	ent:SetCameraDistanceOverride( 1600 )
	ent:SetCustomGameForceHero( "npc_dota_hero_wisp" )
	ent:SetFogOfWarDisabled( true )
	ent:SetWeatherEffectsDisabled( true )

	ent:SetThink( "Update", self, "", 0 )
end

function GameMode:Modifiers()
	LinkLuaModifier( "modifier_xz_hidden", "modifiers/modifier_xz_hidden", 0 )
	LinkLuaModifier( "modifier_xz_unit", "modifiers/modifier_xz_unit", 0 )
	LinkLuaModifier( "modifier_xz_activity_attack", "modifiers/modifier_xz_activity_attack", 0 )
	LinkLuaModifier( "modifier_xz_activity_run", "modifiers/modifier_xz_activity_run", 0 )
	LinkLuaModifier( "modifier_xz_status_effect", "modifiers/modifier_xz_status_effect", 0 )
end

function Precache( context )
	for _, unit in pairs( Precaches.units ) do
		PrecacheUnitByNameSync( unit, context )
	end

	for _, resource in pairs( Precaches.resources ) do
		PrecacheResource( resource.type, resource.resource, context )
	end
end

function Activate()
	GameMode:Heroes()
	GameMode:Activate()
end

function GameMode:Heroes()
	for i, name in pairs( Map.heroes ) do
		local hero = require( "components/heroes/" .. name )

		Precaches:AddUnit( hero.unit )

		self.heroes[name] = hero
	end
end

function GameMode:FormTeams()
	if Map.teamCount == 1 then
		local team = self.teams[1]

		for _, player in pairs( self.players ) do
			team:AddPlayer( player )
		end
	elseif Map.playersInTeam == 1 then
		local t = 1

		for _, player in pairs( self.players ) do
			self.teams[t]:AddPlayer( player )
			t = t + 1
		end
	else
		self.teamSelectionEnabled = true

		local p = {}

		for id, player in pairs( self.players ) do
			local party = tostring( PlayerResource:GetPartyID( id ) )

			p[party] = p[party] or {}

			table.insert( p[party], player )
		end

		local parties = {}

		for _, party in pairs( p ) do
			table.insert( parties, party )
		end

		table.sort( parties, function( a, b )
			return #a < #b
		end )

		local t = 1
		local free_teams = {}

		for i, team in pairs( self.teams ) do
			free_teams[i] = team
		end

		while #free_teams > 0 do
			if #parties < 1 then
				break
			end

			for i = #parties, 1, -1 do 
				local party = parties[i]
				local team = free_teams[t]
				local max = Map.playersInTeam - #team.players

				if max > 0 then
					if #party > max then
						local new_party = {}

						for _ = 1, math.floor( #party / 2 ) do
							table.insert( new_party, table.remove( party ) )
						end
						
						table.insert( parties, new_party )
					else
						for _, player in pairs( party ) do
							team:AddPlayer( player )
						end

						table.remove( parties, i )
					end
				else
					table.remove( free_teams, t )
				end

				t = t + 1

				if not free_teams[t] then
					t = 1
				end
			end
		end
	end

	self:UpdateTeamsNetTable()
end