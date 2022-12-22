S37K_mapbounds = {}

local function within(num, tbl)
	local contains = false
	for k, v in pairs( tbl ) do
		if (v - 2000) < num and (v+2000) > num then
			contains = true
			break
		end
	end
	if not contains then
		table.insert(tbl,num)
	end
	return contains
end

local function filterfunc(ent)
	if ent:IsWorld() then
		for _, surface in pairs( ent:GetBrushSurfaces() ) do
			if surface:IsSky() then return true end
		end
	end
end

local function findbounds()
	print("s37k_lib: finding map bounds...")
	local skyzpos = {}
	local entz
	for _, v in ipairs( ents.GetAll() ) do
		if v:GetClass() == "info_player_start" or v:GetClass() == "info_teleport_destination" then
			local tra = util.TraceLine( {
				start = v:GetPos(),
				endpos = Vector(v:GetPos().x,v:GetPos().y,v:GetPos().z + 100000),
				mask = MASK_SOLID_BRUSHONLY,
				filter = filterfunc
			} )
			if (tra.HitPos.z - v:GetPos().z > 2000) then
				if not within(tra.HitPos.z,skyzpos) then entz =v:GetPos().z end
			else
				local trb = util.TraceLine( {
					start = Vector(v:GetPos().x,v:GetPos().y,v:GetPos().z + 2000),
					endpos = tra.HitPos,
					mask = MASK_SOLID_BRUSHONLY,
					filter = filterfunc
				} )
				local trc = util.TraceLine( {
					start = trb.HitPos,
					endpos = Vector(v:GetPos().x,v:GetPos().y,v:GetPos().z + 100000),
					mask = MASK_SOLID_BRUSHONLY,
					filter = filterfunc
				} )
				if (trc.HitPos.z - v:GetPos().z > 2000) then
					print(trc.HitPos.z - v:GetPos().z)
					if not within(trc.HitPos.z,skyzpos) then entz =v:GetPos().z end
				end
			end
		end
	end
	for _, v in pairs( skyzpos ) do
		local pos = v - 100
		local trpx = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(50000,0,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trnx = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(-50000,0,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trpy = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(0,50000,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local trny = util.TraceLine( {
			start = Vector(0,0,pos),
			endpos = Vector(0,-50000,pos),
			mask = MASK_SOLID_BRUSHONLY,
			filter = filterfunc
		} )
		local tbl = {}
		tbl.area = (trpx.HitPos.x - trnx.HitPos.x) * (trpy.HitPos.y - trny.HitPos.y) * (v - entz)
		tbl.skyZ = v
		if trpx.HitPos.x == 50000 or trnx.HitPos.x == -50000 or trpy.HitPos.y == 50000 or trny.HitPos.y == -50000 then continue end
		tbl.positiveX = trpx.HitPos.x
		tbl.negativeX = trnx.HitPos.x
		tbl.positiveY = trpy.HitPos.y
		tbl.negativeY = trny.HitPos.y
		table.insert(S37K_mapbounds,tbl)
	end
	if #S37K_mapbounds == 0 then print("s37k_lib: Failed to find map bounds! Are you on a weird/complex shaped map?") return end
	print("s37k_lib: map bounds found! (access S37K_mapbounds table to use them in your addons!)")
	PrintTable(S37K_mapbounds)
end
hook.Add("InitPostEntity","swm_findmapbounds",findbounds)
findbounds()

hook.Add("Think", "S37KMapBounds", function()
	if GetConVar("gdisasters_advanced_S37K"):GetInt() >= 1 then

		local function toint(n)
			local s = tostring(n)
			local i, j = s:find('%.')
			if i then
				return tonumber(s:sub(1, i-1))
			else
				return n
			end
		end

		function IsMapRegistered()
			if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then return false else return true end 
		end

		if IsMapRegistered() == true then

			stormtable = S37K_mapbounds[1]

			stormtableX = toint(stormtable.positiveX)
			negative_stormtableX = toint(stormtable.negativeX)
			stormtableY = toint(stormtable.positiveY)
			negative_stormtableY = toint(stormtable.negativeY)
			stormtableZ = toint(stormtable.skyZ)
			negative_stormtableZ = toint(-stormtable.skyZ)
		end

		function getMapBounds()
			if IsMapRegistered()==false then print("S37k Can't found the Bounds") return nil end 
			return {Vector(stormtableX,stormtableY,negative_stormtableZ), Vector(negative_stormtableX,negative_stormtableY,stormtableZ)}
		end

		function getMapCeiling()
			if IsMapRegistered()==false then print("S37k Can't found the Ceiling") return nil end 

			return stormtableZ
		end

		function getMapSkyBox()
			if IsMapRegistered()==false then print("S37k Can't found the SkyBox") return nil end 

			local bounds = getMapBounds()
			local min    = bounds[1]
			local max    = bounds[2]

			return {Vector(min.x, min.y, max.z), Vector(max.x, max.y, max.z)}
		end

		function getMapCenterPos()
			if IsMapRegistered()==false then print("S37k Can't found the CenterPos") return nil end 

			local av         = ((Vector(stormtableX,stormtableY,negative_stormtableZ) + Vector(negative_stormtableX,negative_stormtableY,stormtableZ)) / 2)
			return av
		end

		function getMapCenterFloorPos()
			if IsMapRegistered()==false then print("S37k Can't found the FloorPos") return nil end

			local bounds = Vector(getMapCenterPos().x,getMapCenterPos().y,negative_stormtableZ )

			local tr = util.TraceLine({
				start = bounds,
				endpos = bounds + Vector(0,0,50000),
				mask = MASK_WATER + MASK_SOLID_BRUSHONLY
			})

			return Vector(tr.HitPos.x, tr.HitPos.y, toint(tr.HitPos.z))
		end
	end
end)