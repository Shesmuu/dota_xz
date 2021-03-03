local modifierStatusEffects = {
	[1] = { "particles/status_fx/status_effect_slark_shadow_dance.vpcf", MODIFIER_PRIORITY_SUPER_ULTRA },
	[2] = { "particles/status_fx/status_effect_goo.vpcf" }
}

modifier_xz_status_effect = {}

function modifier_xz_status_effect:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_xz_status_effect:GetStatusEffectName()
	return modifierStatusEffects[self:GetStackCount()][1]
end

function modifier_xz_status_effect:GetPriority()
	return modifierStatusEffects[self:GetStackCount()][2]
end