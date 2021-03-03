class TeammatePick {
	constructor( parent, id ) {
		let panel = $.CreatePanel( "Panel", parent, "" )
		panel.AddClass( "TeammatePick" )

		let nickname = $.CreatePanel( "Label", panel, "" )
		nickname.text = Players.GetPlayerName( id )

		this.heroImage = $.CreatePanel( "Image", panel, "" )
	}

	SetHero( name ) {
		this.heroImage.SetImage( "file://{images}/heroes/npc_dota_hero_" + name + ".png" )
	}

	SetSelected( b ) {
		this.heroImage.SetHasClass( "Selected", b )
	}
}

class HeroSelection {
	constructor() {
		$( "#HeroSelectionHud" ).SetHasClass( "Visible", true )

		let statics = CustomNetTables.GetTableValue( "game", "statics" )
		let teams = CustomNetTables.GetTableValue( "game", "teams" )
		let hero_list = $( "#HeroList" )
		let team_picks = $( "#TeamPicks" )
		hero_list.RemoveAndDeleteChildren()
		team_picks.RemoveAndDeleteChildren()

		for ( let k in statics.hero_list ) {
			let data = statics.hero_list[k]

			this.CreateHeroForSelect( hero_list, data )
		}

		this.teamPicks = []

		$.Msg( teams, " a a ", localTeam )

		for ( let id of LuaArrayToJs( teams[localTeam].players ) ) {
			this.teamPicks[id] = new TeammatePick( team_picks, id )
		}
	}

	StateUpdated( data ) {
		for ( let id in this.teamPicks ) {
			let team_pick = this.teamPicks[id]
			let selected = data.selected[id]
			let hovered = data.hovered[id]

			if ( selected ) {
				team_pick.SetHero( selected )
				team_pick.SetSelected( true )

				if ( id == localID ) {
					this.selected = selected
				}
			} else if ( hovered ) {
				if ( id == localID ) {
					this.hovered = hovered
				}

				team_pick.SetHero( hovered )
			}
		}
	}

	Hover( name, abilities, attributies ) {
		if ( name === this.hovered ) {
			return
		}

		GameEvents.SendCustomGameEventToServer( "hero_selection_hover", { hero: name } )

		$( "#HeroName" ).text = $.Localize( "npc_dota_hero_" + name )
		$( "#HeroPortrait" ).heroname = "npc_dota_hero_" + name
	
		for ( let k in abilities ) {
			$( "#AbilityImage_" + k ).SetImage( AbilityImages[abilities[k].name] )
		}
	
		for ( let k in attributies ) {
			let v = attributies[k]
	
			if ( v.toString().includes( "." ) ) {
				v = v.toFixed( 2 )
			}
	
			$( "#HeroAtr_" + k ).text = v
		}
	}

	CreateHeroForSelect( parent, data ) {
		let button = $.CreatePanel( "Button", parent, "" )
		button.AddClass( "HeroForSelect" )
	
		let image = $.CreatePanel( "Image", button, "" )
		image.SetImage( "file://{images}/heroes/npc_dota_hero_" + data.name + ".png" )

		button.SetPanelEvent( "onactivate", ( function( state ) {
			return function() {
				state.Hover( data.name, data.abilities, data.attributies )
			}
		} ( this ) ) )
	}

	End() {
		$( "#HeroSelectionHud" ).SetHasClass( "Visible", false )

		let hero_list = $( "#HeroList" )
		let team_picks = $( "#TeamPicks" )
		hero_list.RemoveAndDeleteChildren()
		team_picks.RemoveAndDeleteChildren()
	}
}