RuneSpawner = class( {} )

function RuneSpawner:constructor( pos, delay, firstDelay )
	self.pos = pos
	self.delay = delay
	self.firstDelay = firstDelay
end

function RuneSpawner:Update( now )
	if now >= self.nextRuneTime then
		if not self.rune then
			self.rune = Rune( self.pos, self )
		end

		self.nextRuneTime = now + self.delay
	end
end

function RuneSpawner:Activate()
	self.nextRuneTime = GameRules:GetGameTime() + self.firstDelay

	Add( GameMode.other, self )
end