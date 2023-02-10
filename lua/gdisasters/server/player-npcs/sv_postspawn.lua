function gDisasters_PostSpawn(ply)
	ply.gDisasters = {}
	
	local function gDisasters_SetupBodyVariables()
		ply.gDisasters.Body = {}
		ply.gDisasters.Body.Temperature = 37
		ply.gDisasters.Body.Oxygen      = 10
		
	end
	local function gDisasters_SetupAreaVariables()
		ply.gDisasters.Area      = {}
		ply.gDisasters.Area.LocalWind = 0
		ply.gDisasters.Area.IsOutdoor = false
	
	end
	
	
	gDisasters_SetupBodyVariables()
	gDisasters_SetupAreaVariables()	


	

	
end
hook.Add( "PlayerInitialSpawn", "gDisasters_PostSpawn", gDisasters_PostSpawn )




function gDisasters_OnSpawn_Reset( ply )
	ply.gDisasters.Body.Temperature = 37 
	ply.gDisasters.Body.Oxygen      = 10
end
hook.Add( "PlayerSpawn", "gDisasters_OnSpawn_Reset", gDisasters_OnSpawn_Reset )