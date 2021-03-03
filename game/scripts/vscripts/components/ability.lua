Ability = class( {} )

function Ability:constructor( owner )
	self.owner = owner
	self.cooldownReady = true
	self.chargeCount = self.maxChargeCount
end

function Ability:Update( now )
	if self.cooldownReady and self.pressed then
		self:Cast( now )
	end

	if self.maxChargeCount then
		if
			self.chargeCount < self.maxChargeCount and
			self.nextChargeRecoveryTime >= now
		then
			self.chargeCount = self.chargeCount + 1

			self.cooldownReady = true

			self.owner.updated = true
		end
	elseif
		self.cooldown and
		not self.cooldownReady and
		now >= self.cooldownEndTime
	then
		self.cooldownReady = true
		self.owner.updated = true
	end
end

function Ability:Pressed()
	if self.pressed then 
		return
	end

	self.pressed = true
end

function Ability:Released()
	if not self.pressed then
		return
	end

	self.pressed = false
end

function Ability:Cast( now )
	if self.OnCast then
		self:OnCast()
	end

	if self.cooldown then
		if self.maxChargeCount then
			if self.chargeCount == self.maxChargeCount then
				self.nextChargeRecoveryTime = now + self.cooldown
			end

			self.chargeCount = self.chargeCount - 1

			if self.chargeCount == 0 then
				self.cooldownEndTime = self.nextChargeRecoveryTime
				self.cooldownReady = false
			end
		else
			self.cooldownEndTime = now + self.cooldown
			self.cooldownReady = false
		end

		self.owner.updated = true
	end
end

function Ability:SetChargeCount( chargeCount )
	self.chargeCount = chargeCount

	self.owner.updated = true
end

function Ability:GetClientData()
	return {
		name = self.name,
		cooldown = self.cooldown,
		cooldown_end_time = self.cooldownEndTime,
		cooldown_ready = self.cooldownReady,
		charge_count = self.chargeCount
	}
end

Ability.OnCast = FUNCTION_NIL