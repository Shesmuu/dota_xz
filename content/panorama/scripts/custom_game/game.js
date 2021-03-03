class GameHud {
	constructor() {
		$( "#GameHud" ).SetHasClass( "Visible", true )

		this.abilityBar = new AbilityBar()
		this.buffBar = new BuffsBar()
		this.healthBar = new HealthBar()

		this.updates = []
		this.playersUpdates = []
		this.stateUpdates = []
		this.teamsUpdates = []
		this.statisticUpdates = []

		const statics = CustomNetTables.GetTableValue( "game", "statics" )
		const dst = statics.death_screen_type
		const tbt = statics.top_bar_type
		const st = statics.scoreboard_type

		if ( dst == "default" ) {
			this.deathScreen = new DefaultDeathScreen()
		}

		if ( tbt == "default" ) {
			this.topBar = new DefaultTopBar( statics.team_logos )
		} else if ( tbt == "battle_royale" ) {
			this.topBar = new BattleRoyaleTopBar()
		}

		if ( st == "default" ) {
			this.scoreboard = new DefaultScoreboard( statics, [
				"kills",
				"deaths",
				"assists"
			] )
		}
	}

	HeroUpdated( data ) {
		this.hasData = true

		this.abilityBar.SetData( data.abilities )
		this.buffBar.SetData( data.buffs )
		this.healthBar.SetData( data )

		if ( this.deathScreen ) {
			if ( !data.alive ) {
				this.deathScreen.Enable( data.respawn_time )
			} else {
				this.deathScreen.Disable()
			}
		}
	}

	PlayersUpdated( data ) {
		for ( let a of this.playersUpdates ) {
			a.PlayersUpdated()
		}
	}

	StateUpdated( data ) {
		for ( let a of this.stateUpdates ) {
			a.StateUpdated()
		}
	}

	TeamsUpdated( data ) {
		for ( let a of this.teamsUpdates ) {
			a.TeamsUpdated()
		}
	}

	StatisticsUpdated( data ) {
		for ( let a of this.statisticUpdates ) {
			a.StatisticsUpdated()
		}
	}

	Update( now ) {
		if ( !this.hasData ) {
			return
		}

		this.abilityBar.Update( now )
		this.buffBar.Update( now )

		for ( let a of this.updates ) {
			a.Update()
		}
	}
}