class HealthBar {
	constructor() {
		this.panelMaxHealth = $( "#HealthBar" )
		this.panelCurrentHealth = $( "#CurrentHealth" )
	}

	SetData( data ) {
		this.ent = data.ent
		this.maxHealth = data.max_health

		let m = data.health / this.maxHealth

		this.panelCurrentHealth.style.width = m * 100 + "%"
		this.panelCurrentHealth.style["wash-color"] = "rgb( " + ( 1 - m ) * 255 + ", " + m * 255 + ", 0 )"
	}
}