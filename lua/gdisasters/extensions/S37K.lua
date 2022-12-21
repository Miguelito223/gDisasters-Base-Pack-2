hook.Add("Think", "S37KMapBounds", function()
	if GetConVar("gdisasters_enable_S37K"):GetInt() >= 1 then

		function IsMapRegistered()
			if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then return false else return true end 
		end

		if IsMapRegistered() == true then
			stormtable = S37K_mapbounds[1]
			
			stormtableX = stormtable.positiveX
			negative_stormtableX = stormtable.negativeX
			stormtableY = stormtable.positiveY
			negative_stormtableY = stormtable.negativeY
			stormtableZ = stormtable.skyZ
			negative_stormtableZ = -stormtable.skyZ
		end

		function getMapBounds()
			if IsMapRegistered()==false then print("S37k Can't found the Bounds") return nil end 
			return {Vector(stormtableX,stormtableY,negative_stormtableZ),Vector(negative_stormtableX,negative_stormtableY,stormtableZ)}
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

			return {Vector(min.x, min.y, max.z),Vector(max.x, max.y, max.z)}
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

			return tr.HitPos
		end
	end
end)