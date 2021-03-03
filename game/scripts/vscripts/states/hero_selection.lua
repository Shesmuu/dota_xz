HeroSelection = {}

function HeroSelection:Start()
	GameMode.state = self

	MethodAll( GameMode.players, Player.UpdateNetTable )

	self.selected = {}
	self.hovered = {}

	self.hoverHeroListener = ListenToClient( "hero_selection_hover", Dynamic_Wrap( self, "HoverHero" ), self )
	self.selectHeroListener = ListenToClient( "hero_selection_select", Dynamic_Wrap( self, "SelectHero" ), self )

	self.endTime = GameRules:GetGameTime() + Map.heroSelectionTime

	GameMode:UpdateStateNetTable()
end

function HeroSelection:HoverHero( data )
	self.hovered[data.PlayerID] = data.hero

	GameMode:UpdateStateNetTable()
end

function HeroSelection:SelectHero( data )
	self.selected[data.PlayerID] = self.hovered[data.PlayerID]

	for id, _ in pairs( GameMode.players ) do
		if not self.selected[id] then
			GameMode:UpdateStateNetTable()

			return
		end
	end

	self:End()
end

function HeroSelection:Update( now )
	if now < self.endTime then
		return 
	end

	for id, _ in pairs( GameMode.players ) do
		if not self.selected[id] then
			if self.hovered[id] then
				self.selected[id] = self.hovered[id]
			else
				self.selected[id] = Map.heroes[RandomInt( 1, #Map.heroes )]
			end
		end
	end

	self:End()
end

function HeroSelection:GetNetTableData()
	return {
		state = XZ_STATE_HERO_SELECTION,
		end_time = self.endTime,
		selected = self.selected,
		hovered = self.hovered
	}
end

function HeroSelection:End()
	CustomGameEventManager:UnregisterListener( self.hoverHeroListener )
	CustomGameEventManager:UnregisterListener( self.selectHeroListener )

	Game:Start( self.selected )

	self.endTime = nil
	self.selected = nil
	self.hovered = nil
end