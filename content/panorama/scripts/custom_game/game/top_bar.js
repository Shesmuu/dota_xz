class TopBar {
	constructor( snippet ) {
		this.panel = $( "#TopBar" )
		this.panel.RemoveAndDeleteChildren()
		this.panel.BLoadLayoutSnippet( snippet )
	}
}

class DefaultTopBar extends TopBar {
	constructor( teamLogos ) {
		super( "DefaultTopBar" )

		this.firstTeamScore = this.panel.FindChildTraverse( "FirstTeamScore" )
		this.secondTeamScore = this.panel.FindChildTraverse( "SecondTeamScore" )

		this.SetVisible( true )

		const ftl = this.panel.FindChildTraverse( "FirstTeamLogo" )
		const stl = this.panel.FindChildTraverse( "SecondTeamLogo" )

		ftl.SetImage( teamLogos[1] )
		stl.SetImage( teamLogos[2] )
	}

	StatisticsUpdated( data ) {
		this.firstTeamScore.text = data.teams[1]
		this.secondTeamScore.text = data.teams[2]
	}

	SetVisible( b ) {
		this.panel.SetHasClass( "Visible", b )
	}
}

class BattleRoyaleTopBar extends TopBar {
	constructor() {
		super( "BattleRoyaleTopBar" )
	}
}