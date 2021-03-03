class Buff {
	constructor( parent ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "Buff" )

		this.image = this.panel.FindChildTraverse( "Image" )
		this.countdown = this.panel.FindChildTraverse( "Countdown" )
	}

	SetData( data ) {
		if ( !!data.die_time ) {
			this.countdown.visible = true
			this.dieTime = data.die_time
		} else {
			this.countdown.visible = false
		}

		this.image.SetImage( data.image )
	}

	SetVisible( b ) {
		this.panel.visible = b
	}

	Update( now ) {
		if ( !this.panel.visible || !this.countdown.visible ) {
			return
		}

		this.countdown.text = Countdown( now, this.dieTime, 0 )
	}
}

class BuffsBar {
	constructor() {
		this.parent = $( "#BuffsContainer" )
		this.buffs = []

		this.parent.RemoveAndDeleteChildren()
	}

	SetData( data ) {
		let i = 0

		for ( const k in data ) {
			if ( !this.buffs[i] ) {
				this.buffs[i] = new Buff( this.parent )
			}

			this.buffs[i].SetVisible( true )
			this.buffs[i].SetData( data[k] )
			
			i++
		}

		while ( true ) {
			let buff = this.buffs[i]

			if ( buff ) {
				buff.SetVisible( false )
			} else {
				break
			}

			i++
		}
	}

	Update( now ) {
		for ( const buff of this.buffs ) {
			buff.Update( now )
		}
	}
}