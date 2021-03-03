class DeathScreen {
	constructor( snippet ) {
		this.panel = $( "#DeathScreen" )
		this.panel.BLoadLayoutSnippet( snippet )
	}
}

class DefaultDeathScreen extends DeathScreen {
	constructor() {
		super( "DefaultDeathScreen" )

		this.countdown = this.panel.FindChildTraverse( "RespawnCountdown" )

		stateHandler.updates.push( this )
	}

	Enable( respawnTime ) {
		this.respawnTime = respawnTime

		this.panel.SetHasClass( "Visible", true )
	}

	Update( now ) {
		if ( !this.panel.visible ) {
			return
		}

		this.countdown.text = Countdown( now, this.respawnTime, 0 )
	}

	Disable() {
		this.panel.SetHasClass( "Visible", false )
	}
}