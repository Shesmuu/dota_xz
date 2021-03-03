modifier_xz_activity_run = {}

function modifier_xz_activity_run:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		--MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
	}
end

function modifier_xz_activity_run:GetOverrideAnimation()
	return ACT_DOTA_RUN
end