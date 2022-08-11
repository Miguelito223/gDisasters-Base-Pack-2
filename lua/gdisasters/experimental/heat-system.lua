AddCSLuaFile()

CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars (Settings)

if (SERVER) then

	function generateents(ent)
		local bound = getMapBounds()
		local center = getMapCenterPos()
		local centerpos = getMapCenterFloorPos()
		local grid = debugoverlay.Grid(center.x, center.y, center.z)
		
		local ent = ents.Create("prop_detail")

	
	
	end

end

if (CLIENT) then

end