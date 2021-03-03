modifier_xz_activity_attack = {}

function modifier_xz_activity_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		--MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
end

function modifier_xz_activity_attack:GetOverrideAnimation()
	return ACT_DOTA_ATTACK
end