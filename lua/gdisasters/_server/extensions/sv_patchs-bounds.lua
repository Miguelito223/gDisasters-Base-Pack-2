concommand.Add("GPS", function(ply, cmd, args)
	local pos = ply:GetPos()
	pos.x  = math.floor(pos.x)
	pos.y  = math.floor(pos.y)
	pos.z  = math.floor(pos.z)
	
	ply:ChatPrint( "Vector("..pos.x..","..pos.y..","..pos.z..")")
	
end)

concommand.Add("gdisasters_ncompat_maps", function(ply, cmd, args)
	for k, v in pairs(MAP_BOUNDS) do
		ply:ChatPrint(k)
	
	end
	
end)

concommand.Add("gdisasters_tornadocompat_maps", function(ply, cmd, args)
	for k, v in pairs(MAP_PATHS) do
		ply:ChatPrint(k)
	
	end
	
end)
	

