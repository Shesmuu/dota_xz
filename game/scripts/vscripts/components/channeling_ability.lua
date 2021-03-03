ChannelingAbility = class( {}, nil, Ability )

function ChannelingAbility:Update( now )
	if self.pressed and not self.channeling then
		self:ChannelStart( now )
	elseif not self.pressed and self.channeling then
		self:ChannelEnd( now )
	elseif self.channeling then
		self:Channeling( now )
	elseif
		not self.channeling and
		self.chargeCount < self.maxChargeCount and
		now >= self.nextChargeRecovery
	then
		self:SetChargeCount( self.chargeCount + 1 )

		self.nextChargeRecovery = now + self.channelingInterval
	end
end

function ChannelingAbility:ChannelStart( now )
	if self.chargeCount <= 0 then
		return
	end

	self:OnChannelStart()

	self.nextChannelingTime = now

	self.channeling = true
end

function ChannelingAbility:Channeling( now )
	if now < self.nextChannelingTime then
		return
	end

	self:OnChanneling()

	self.nextChannelingTime = now + self.channelingInterval

	self:SetChargeCount( self.chargeCount - 1 )

	if self.chargeCount <= 0 then
		self:ChannelEnd( now )
	end
end

function ChannelingAbility:ChannelEnd( now )
	if not self.channeling then
		return
	end

	self:OnChannelEnd()

	self.nextChargeRecovery = now + 2

	self.channeling = false
end

function ChannelingAbility.OnChannelStart() end
function ChannelingAbility.OnChanneling() end
function ChannelingAbility.OnChannelEnd() end