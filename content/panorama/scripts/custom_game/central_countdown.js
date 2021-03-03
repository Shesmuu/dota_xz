class CentralCountdown {
	constructor() {
		this.panel = $( "#CentralCountdown" )
		this.SetEnabled( false )
	}

	SetEndTime( endTime ) {
		this.endTime = endTime

		if ( this.enabled && !this.panel.visible ) {
			this.panel.visible = true
		}
	}

	SetEnabled( b ) {
		this.enabled = b
		this.panel.SetHasClass( "Visible", b )
		this.SetEndTime( this.endTime )
	}

	Update( now ) {
		if ( !this.enabled || this.endTime == null ) {
			return
		}

		this.panel.text = Countdown( now, this.endTime, 0 )
	}
}

centralCountdown = new CentralCountdown()