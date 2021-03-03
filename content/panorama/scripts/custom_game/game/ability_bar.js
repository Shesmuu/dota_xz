class Ability {
	constructor( parent, key, hA ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "Ability" )
		this.panel.style["horizontal-align"] = hA

		this.panel.FindChildTraverse( "Key" ).text = key

		this.image = this.panel.FindChildTraverse( "Image" )
		this.cooldown = this.panel.FindChildTraverse( "Cooldown" )
		this.charges = this.panel.FindChildTraverse( "ChargeCount" )
	}

	SetData( data ) {
		this.image.SetImage( AbilityImages[data.name] )
		
		this.cooldownReady = data.cooldown_ready == 1
		this.cooldownEndTime = data.cooldown_end_time
		this.cooldownDuration = data.cooldown

		this.cooldown.visible = !this.cooldownReady
		this.charges.visible = data.charge_count != null

		this.charges.text = data.charge_count
	}

	Update( now ) {
		if ( this.cooldownReady || !this.cooldownEndTime ) {
			return
		}

		let cooldown_remaining = Math.max( 0, this.cooldownEndTime - Game.GetGameTime() )
		let deg = ( cooldown_remaining / this.cooldownDuration ) * -360

		this.cooldown.style.clip = "radial( 50% 50%, 0deg, " + deg + "deg )"
	}
}

class AbilityBar {
	constructor() {
		this.abilities = {}

		let container = $( "#AbilitiesContainer" )
		let a = { w: "left", s: "center", x: "right" }

		container.RemoveAndDeleteChildren()

		for ( let k in a ) {
			this.abilities[k] = new Ability( container, k, a[k] )
		}
	}

	SetData( data ) {
		for ( let k in data ) {
			this.abilities[k].SetData( data[k] )
		}
	}

	Update( now ) {
		for ( let k in this.abilities ) {
			this.abilities[k].Update( now )
		}
	}
}