function AABB( c, w, h )
	return {
		min = c + Vector( -w, 0, -h ) * 0.5,
		max = c + Vector( w, 0, h ) * 0.5,
	}
end

function CheckTeam( fTeam, sTeam, tType )
	local ally = fTeam == sTeam

	return (
		TEAM_BOTH == tType or
		TEAM_FRIENDLY == tType and ally or
		TEAM_ENEMY == tType and not ally
	)
end

function IsBelong1D( min, max, num )
	if
		num > max or
		num < min
	then
		return false
	end

	return true
end

function IsCrossing1D( min1, max1, min2, max2 )
	if
		min1 > max2 or
		max1 < min2
	then
		return false
	end

	return true
end

function FindUnitsInRadiusXZ( center, radius, team, teamType )
	local units = {}

	for _, unit in pairs( GameMode.units ) do
		if
			unit.alive and
			CheckTeam( unit.team, team, teamType ) and
			aabb ~= unit
		then
			local abs = ( center - unit.center ):Length()
			local length = abs - radius - math.sqrt( unit.addMax.x ^ 2 + unit.addMax.z ^ 2 )

			if length < 0 then
				table.insert( units, unit )
			end
		end
	end

	return units
end

function FindUnitsInAABB( aabb, team, teamType )
	local units = {}

	for _, unit in pairs( GameMode.units ) do
		if
			unit.alive and
			CheckTeam( unit.team, team, teamType ) and
			unit:IsCrossing( aabb ) and
			aabb ~= unit
		then
			table.insert( units, unit )
		end
	end

	return units
end

function ListenToClient( n, f, context, id )
	return CustomGameEventManager:RegisterListener( n, function( _, data )
		if id and id ~= data.PlayerID then
			return
		end

		f( context, data )
	end )
end

function AttackerVictim( attacker, victim )
	local ap = attacker:GetPlayer()
	local vp = victim:GetPlayer()
	local ally = ( vp and vp.team or nil ) == ( ap and ap.team or nil )

	return ap, vp, ally
end

function StatusEffect( ent, effect )
	local modifier = ent:AddNewModifier( ent, nil, "modifier_xz_status_effect", nil )

	modifier:SetStackCount( effect )

	return modifier
end

function GetAttachPos( unit, attackName )
	return unit:GetAttachmentOrigin( unit:ScriptLookupAttachment( attachName or "attach_attack1" ) )
end

function GetCollisions( v )
	local blockSize = 512
	local xi = math.ceil( ( v.x + 16384 ) / blockSize )
	local zi = math.ceil( ( v.z + 16384 ) / blockSize )
	local collisions = {}

	for x = xi - 1, xi + 1 do
		for z = zi - 1, zi + 1 do
			local xcolum = Map.collisionBlocks[x]

			if xcolum and xcolum[z] then
				for _, ci in pairs( xcolum[z] ) do
					collisions[ci] = true
				end
			end
		end
	end

	return collisions
end

function One( a )
	if a == 0 then
		return 1
	else
		return a > 0 and 1 or -1
	end
end

function Angle2D( v1, v2, a1, a2 )
	local x1 = v1[a1]
	local y1 = v1[a2]
	local x2 = v2[a1]
	local y2 = v2[a2]
	local t1 = math.atan2( y1, x1 )
	local t2 = math.atan2( y2, x2 )
	local a = t2 - t1
	local aa = math.abs( a )
	local n = aa / a
	
	if aa > math.pi then
	    return ( math.pi - aa ) * n
	end
	
	return a
end

function Rotate2D( x, y, a )
	local c = math.cos( a )
	local s = math.sin( a )
	local rx = x * c - y * s
	local ry = x * s + y * c
	
	return rx, ry
end

function MethodAll( t, func, ... )
	for _, o in pairs( t ) do
		func( o, ... )
	end
end

function MethodAllSeq( t, func, ... )
	for i = #t, 1, -1 do
		local o = t[i]

		func( o, ... )
	end
end

function Add( t, o )
	local i = 1

	while true do
		if not t[i] then
			break
		end

		i = i + 1
	end

	t[i] = o

	return i
end

function RemoveFrom( t, value )
	for k, v in pairs( t ) do
		if v == value then
			table.remove( t, k )

			break
		end
	end
end

function Delay( t, f )
	return Add( GameMode.timers, {
		endTime = GameRules:GetGameTime() + t,
		func = f
	} )
end

function XpcallError( msg )
	print( "Delay Error: " .. msg )
end

function Particle( name, pattach, ent, control, forwards, release )
	local p = ParticleManager:CreateParticle( name, pattach, ent )

	for i, cp in pairs( control or {} ) do
		if type( cp ) == "userdata" then
			ParticleManager:SetParticleControl( p, i, cp )
		else
			local cp_ent = cp.ent or ent

			ParticleManager:SetParticleControlEnt(
				p,
				i,
				cp.ent or ent,
				cp.pattach or PATTACH_POINT_FOLLOW,
				cp.attach or "attach_hitloc",
				cp_ent:GetAbsOrigin(),
				true
			)
		end
	end

	if release then
		ParticleManager:ReleaseParticleIndex( p )
	end

	return p
end

function DestroyParticle( p, i )
	if not p then
		return
	end

	ParticleManager:DestroyParticle( p, not not i )
	ParticleManager:ReleaseParticleIndex( p )
end

function PrintRadAsDeg( ... )
	local t = {}

	for _, v in pairs( { ... } ) do
		table.insert( t, v / math.pi * 180 )
	end

	print( unpack( t ) )
end

function PrintTable( t )
	for k, v in pairs( t ) do
		print( k, v )
	end
end