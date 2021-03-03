class TeamSlot {
	constructor( parent ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.AddClass( "TeamSlot" )

		let avatarContainer = $.CreatePanel( "Panel", this.panel, "" )
		avatarContainer.AddClass( "Avatar" )

		this.nickname = $.CreatePanel( "Label", this.panel, "" )
		this.avatar = $.CreatePanel( "DOTAAvatarImage", avatarContainer, "" )
		this.avatar.style.width = "100%"
		this.avatar.style.height = "100%"
	}

	Set( id ) {
		this.nickname.visible = id != null
		this.avatar.visible = id != null

		if ( id != null ) {
			this.nickname.text = Players.GetPlayerName( id )
			this.avatar.steamid = Game.GetPlayerInfo( id ).player_steamid
		}
	}
}

class TeamForSelect {
	constructor( parent, index, playersInTeam, color, name ) {
		this.slots = []
		this.panel = $.CreatePanel( "Button", parent, "" )
		this.panel.BLoadLayoutSnippet( "TeamToSelect" )
		//this.panel.style["background-color"] = ColorRGB( color )

		const teamName = this.panel.FindChildTraverse( "TeamName" )

		this.panel.SetPanelEvent( "onactivate", function() {
			GameEvents.SendCustomGameEventToServer( "team_selection_select", { team: index } )
		} )

		if ( name ) {
			this.panel.FindChildTraverse( "TeamName" ).text = $.Localize( name )
		}

		this.container = this.panel.FindChildTraverse( "PlayersContainer" )

		for ( let i = 0; i < playersInTeam; i++ ) {
			this.slots.push( new TeamSlot( this.container ) )
		}
	}

	SetData( players ) {
		for ( let i = 0; i < this.slots.length; i++ ) {
			this.slots[i].Set( players[i] )
		}
	}
}

class TeamSelection {
	constructor() {
		$( "#TeamSelectionHud" ).SetHasClass( "Visible", true )

		const statics = CustomNetTables.GetTableValue( "game", "statics" )
		const colors = LuaArrayToJs( statics.team_colors )
		const names = LuaArrayToJs( statics.team_names )
		const container = $( "#TeamsContainer" )
		const unassigned = $( "#Unassigned" )
		container.RemoveAndDeleteChildren()
		unassigned.RemoveAndDeleteChildren()

		centralCountdown.SetEnabled( true )

		if ( localID != 0 ) {
			$( "#ConfirmButton" ).visible = false
		}

		this.teams = []
		this.unassigned = new TeamForSelect( $( "#Unassigned" ), 0, 4, [ 55, 55, 55 ], "Unassigned" )

		for ( let i = 0; i < statics.team_count; i++ ) {
			this.teams[i] = new TeamForSelect( container, i + 1, statics.players_in_team, LuaArrayToJs( colors[i] ), names[i] )
		}

		this.TeamsUpdated( CustomNetTables.GetTableValue( "game", "teams" ) )
	}

	SetUnassigned( data ) {
		if ( data.length > 0 ) {
			$( "#ConfirmText" ).text = "Assign and Confirm"
		} else {
			$( "#ConfirmText" ).text = "Confirm"
		}

		this.unassigned.SetData( data )
	}

	SetData( data ) {
		for ( let i in data ) {
			this.teams[i].SetData( LuaArrayToJs( data[i].players ) )
		}
	}

	TeamsUpdated( data ) {
		this.SetData( LuaArrayToJs( data ) )
	}

	StateUpdated( data ) {
		centralCountdown.SetEndTime( data.end_time )
		this.SetUnassigned( LuaArrayToJs( data.unassigned ) )
	}

	End() {
		$( "#TeamSelectionHud" ).SetHasClass( "Visible", false )

		let container = $( "#TeamsContainer" )
		let unassigned = $( "#Unassigned" )
		container.RemoveAndDeleteChildren()
		unassigned.RemoveAndDeleteChildren()

		centralCountdown.SetEnabled( false )
	}
}