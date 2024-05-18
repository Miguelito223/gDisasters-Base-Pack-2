function IsMapRegistered()
	if game.GetWorld():GetModelBounds()==nil then
		return false
	else 
		return true
	end 
end

function getMapBounds()
    local minVector, maxVector = game.GetWorld():GetModelBounds()
    return { minVector, maxVector, minVector }
end

function getMapCeiling()
	if IsMapRegistered()==false then print("This map no have Ceiling") return nil end 

	return getMapBounds()[2].z
end

function getMapSkyBox()
	if IsMapRegistered()==false then print("This map no have SkyBox") return nil end 
	local bounds = getMapBounds()
	local min    = bounds[1]
	local max    = bounds[2]

	return { Vector(min.x, min.y, max.z), Vector(max.x, max.y, max.z) }
end


function getMapCenterPos()
	if IsMapRegistered()==false then print("This map no have CenterPos") return nil end 

	local av         = ((getMapBounds()[1] + getMapBounds()[2])  / 2)
	return av
end

function getMapCenterFloorPos()
	if IsMapRegistered()==false then print("This map no have FloorPos") return nil end 

	return getMapBounds()[3]
end
