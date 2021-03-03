class Scoreboard {
	constructor() {
		this.panel = $( "#Scoreboard" )
		this.panel.RemoveAndDeleteChildren()

		GameUI.scoreboard = this
	}

	Show() {
		this.panel.SetHasClass( "Visible", true )
	}

	Hide() {
		this.panel.SetHasClass( "Visible", false )
	}
}

class DefaultScoreboardPlayer {
	constructor( parent, stats ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "DefaultScoreboardPlayer" )

		this.nickname = this.panel.FindChildTraverse( "PlayerName" )
		this.avatar = $.CreatePanel( "DOTAAvatarImage", this.panel.FindChildTraverse( "AvatarContainer" ), "" )
		this.avatar.style.width = "100%"
		this.avatar.style.height = "100%"

		this.stats = {}

		const stats_container = this.panel.FindChildTraverse( "Stats" )

		for ( let stat of stats ) {
			const stat_container =  $.CreatePanel( "Panel", stats_container, "" )
			stat_container.AddClass( "Stat" )
			stat_container.AddClass( stat )

			this.stats[stat] = $.CreatePanel( "Label", stat_container, "" )
			this.stats[stat].text = $.Localize( "scoreboard_stats_" + stat )
		}
	}

	SetPlayer( id ) {
		this.id = id
		this.panel.visible = id != null

		if ( id != null ) {
			this.nickname.text = Players.GetPlayerName( id )
			this.avatar.steamid = Game.GetPlayerInfo( id ).player_steamid
		}
	}

	SetStats( stats ) {
		if ( stats ) {
			for ( let stat in this.stats ) {
				this.stats[stat].text = stats[stat]
			}
		}
	}
}

class DefaultScoreboardTeam {
	constructor( parent, index, playersInTeam, color, logo, name, stats ) {
		this.panel = $.CreatePanel( "Panel", parent, "" )
		this.panel.BLoadLayoutSnippet( "DefaultScoreboardTeam" )
		this.panel.style["background-color"] = ColorRGBA( color, 0.4 )

		this.index = index
		this.players = []

		this.panel.FindChildTraverse( "Logo" ).SetImage( logo )
		this.panel.FindChildTraverse( "TeamName" ).text = $.Localize( name )

		const stats_container = this.panel.FindChildTraverse( "Stats" )
		const player_container = this.panel.FindChildTraverse( "Players" )

		for ( let stat of stats ) {
			const stat_container =  $.CreatePanel( "Panel", stats_container, "" )
			stat_container.AddClass( "Stat" )
			stat_container.AddClass( stat )

			const stat_name = $.CreatePanel( "Label", stat_container, "" )
			stat_name.text = $.Localize( "scoreboard_stats_" + stat )
		}

		for ( let i = 0; i < playersInTeam; i++ ) {
			this.players.push( new DefaultScoreboardPlayer( player_container, stats ) )
		}
	}

	SetPlayers( players ) {
		for ( let i in this.players ) {
			this.players[i].SetPlayer( players[i] )
		}
	}

	SetStats( stats ) {
		for ( let player of this.players ) {
			player.SetStats( stats[player.id] )
		}
	}
}

class DefaultScoreboard extends Scoreboard {
	constructor( statics, stats ) {
		super()

		this.panel.AddClass( "DefaultScoreboard" )
		this.teams = []

		const colors = LuaArrayToJs( statics.team_colors )
		const logos = LuaArrayToJs( statics.team_logos )
		const names = LuaArrayToJs( statics.team_names )

		for ( let i = 0; i < statics.team_count; i++ ) {
			this.teams[i] = new DefaultScoreboardTeam(
				this.panel,
				i + 1,
				statics.players_in_team,
				LuaArrayToJs( colors[i] ),
				logos[i],
				names[i],
				stats
			)
		}

		this.TeamsUpdated( LuaArrayToJs( CustomNetTables.GetTableValue( "game", "teams" ) ) )
	}

	StatisticsUpdated( data ) {
		for ( let team of this.teams ) {
			team.SetStats( data.players )
		}
	}

	TeamsUpdated( data ) {
		for ( let index in data ) {
			this.teams[index].SetPlayers( LuaArrayToJs( data[index].players ) )
		}
	}
}