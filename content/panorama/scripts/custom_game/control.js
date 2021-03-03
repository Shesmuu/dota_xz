const controls = [
	"a",
	"d",
	"w",
	"s",
	"x",
	"space",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6"
]

function ControlServer( k, v ) {
	return function() {
		GameEvents.SendCustomGameEventToServer( "control", {
			key: k,
			value: v
		} )
	}
}

for ( let k of controls ) {
	Game.AddCommand( "+pressed_" + k, ControlServer( k, true ), "", 0 )
	Game.AddCommand( "-pressed_" + k, ControlServer( k, false ), "", 0 )
}

Game.AddCommand( "+pressed_tab", () => {
	if ( GameUI.scoreboard ) GameUI.scoreboard.Show()
}, "", 0 )
Game.AddCommand( "-pressed_tab", () => {
	if ( GameUI.scoreboard ) GameUI.scoreboard.Hide()
}, "", 0 )

GameUI.SetMouseCallback( function( event, button ) {
	GameEvents.SendCustomGameEventToServer( "mouse", {
		event: event,
		button: button
	} )

	return true
} )