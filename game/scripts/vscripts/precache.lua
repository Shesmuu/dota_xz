Precaches = {
	resources = {},
	units = {
		"npc_xz_dummy",
		"npc_xz_test_unit"
	}
}

function Precaches:AddUnit( unit )
	table.insert( self.units, unit )
end

function Precaches:AddResource( t, r )
	table.insert( self.resources, {
		type = t,
		resource = r
	} )
end