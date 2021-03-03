function SubscribeNetTable( tN, k, f, any ) {
	let t = CustomNetTables.GetTableValue( tN, k )

	if ( t ) {
		f( t, k )
	}

	CustomNetTables.SubscribeNetTableListener( tN, function( table, key, data ) {
			if ( k == key || any ){
				f( data, key )
			}
	} )
}

function WorldToScreen( pos ) {
	return [
		Game.WorldToScreenX( pos[0], pos[1], pos[2] ),
		Game.WorldToScreenY( pos[0], pos[1], pos[2] )
	]
}

function LuaArrayToJs( a ) {
	let array = []

	for ( let k in a ) {
		if ( Number( k ) ) {
			array.push( a[k] )
		}
	}

	return array
}

function ColorRGB( c ) {
	return "rgb( " + c[0] + ", " + c[1] + ", " + c[2] + " )"
}

function ColorRGBA( c, o ) {
	return "rgba( " + c[0] + ", " + c[1] + ", " + c[2] + ", " + o + " )"
}

function Countdown( now, endTime, fix ) {
	return Math.max( 0, endTime - now ).toFixed( fix )
}

function GetBuff( ent, name ) {
	let buffCount = Entities.GetNumBuffs( ent )

	if ( buffCount < 1 ) {
		return
	}

	for ( let i = 0; i < buffCount; i++ ) {
		let buff = Entities.GetBuff( ent, i )

		if ( Buffs.GetName( ent, buff ) === name ) {
			return buff
		}
	}
}