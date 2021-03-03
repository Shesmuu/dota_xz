XZ_STATE_NONE = 0
XZ_STATE_TEAM_SELECTION = 1
XZ_STATE_HERO_SELECTION = 2
XZ_STATE_GAME = 3
XZ_STATE_FINISHED = 4

localID = Players.GetLocalPlayer()
localCamera = -1
localTeam = -1

stateValue = XZ_STATE_NONE
stateHandler = null

function Update() {
	if ( localCamera !== -1 ) {
		GameUI.SetCameraLookAtPositionHeightOffset( Entities.GetAbsOrigin( localCamera )[2] + 30 )
	}

	const cp = GameUI.GetCursorPosition()
	const center = [
		Game.GetScreenWidth() / 2,
		Game.GetScreenHeight() / 2
	]

	GameEvents.SendCustomGameEventToServer( "cursor", {
		x: cp[0] - center[0],
		z: cp[1] - center[1],
		lkm: GameUI.IsMouseDown( 0 ),
		radius: Math.min( Game.GetScreenWidth(), Game.GetScreenHeight() )
	} )

	const now = Game.GetGameTime()

	if ( stateHandler && stateHandler.Update ) {
		stateHandler.Update( now )
	}

	centralCountdown.Update( now )

	$.Schedule( 0, Update )
}

function StateUpdated( data ) {
	if ( data.state !== stateValue ) {
		NewState( data.state )
	}

	if ( stateHandler && stateHandler.StateUpdated ) {
		stateHandler.StateUpdated( data )
	}
}

function TeamsUpdated( data ) {
	if ( stateHandler && stateHandler.TeamsUpdated ) {
		stateHandler.TeamsUpdated( data )
	}
}

function StatisticsUpdated( data ) {
	if ( stateHandler && stateHandler.StatisticsUpdated ) {
		stateHandler.StatisticsUpdated( data )
	}
}

function NewState( state ) {
	if ( stateHandler ) {
		stateHandler.End()
	}

	stateValue = state

	if ( state == XZ_STATE_TEAM_SELECTION ) {
		stateHandler = new TeamSelection()
	} else if ( state == XZ_STATE_HERO_SELECTION ) {
		stateHandler = new HeroSelection()
	} else if ( state == XZ_STATE_GAME ) {
		stateHandler = new GameHud()
	} else {
		stateHandler = null
	}
}

function PlayersUpdated( data ) {
	if ( !!data.camera ) {
		localCamera = data.camera
	}

	if ( !!data.team ) {
		localTeam = data.team
	}
}

for ( let i = 0; i < DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ELEMENT_COUNT; i++ ) {
	GameUI.SetDefaultUIEnabled( i, false )
}

SubscribeNetTable( "players", localID.toString(), PlayersUpdated )
SubscribeNetTable( "game", "state", StateUpdated )
SubscribeNetTable( "game", "teams", TeamsUpdated )
SubscribeNetTable( "game", "statistics", StatisticsUpdated )

GameEvents.Subscribe( "hero_updated", data => {
	if ( stateHandler && stateHandler.HeroUpdated ) {
		stateHandler.HeroUpdated( data )
	}
} )

GameUI.SetCameraPitchMin( 4 )
GameUI.SetCameraPitchMax( 4 )
GameUI.SetCameraTerrainAdjustmentEnabled( false )

GameEvents.SendCustomGameEventToServer( "connected", null )

Update()