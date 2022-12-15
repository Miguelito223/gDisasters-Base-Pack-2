hook.Add("Tick", "S37K", function()
	if S37K_mapbounds then
		local stormtable = S37K_mapbounds[1]

		function IsMapRegistered()
			if stormtable == nil or S37K_mapbounds == nil then return false else return true end 
		end

		function getMapBounds()
			if IsMapRegistered()==false then print("S37k Can't found the Bounds") return nil end 
			

			return {Vector(stormtable.positiveX,stormtable.positiveY,-stormtable.skyZ),Vector(stormtable.negativeX,stormtable.negativeY,stormtable.skyZ)}
		end

		function getMapCeiling()
			if IsMapRegistered()==false then print("S37k Can't found the Ceiling") return nil end 

			return stormtable.skyZ
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

			local av         = ((Vector(stormtable.negativeX,stormtable.negativeY,-stormtable.skyZ) + Vector(stormtable.positiveX,stormtable.positiveY,stormtable.skyZ)) / 2)
			return av
		end

		function getMapCenterFloorPos()
			if IsMapRegistered()==false then print("S37k Can't found the FloorPos") return nil end

			local bounds = Vector(getMapCenterPos().x,getMapCenterPos().y,-stormtable.skyZ)

			local tr = util.TraceLine({
				start = bounds,
				endpos = bounds + Vector(0,0,50000),
				mask = MASK_WATER + MASK_SOLID_BRUSHONLY
			})

			return Vector(0,0,tr.HitPos.z)
		end
	end
end)
