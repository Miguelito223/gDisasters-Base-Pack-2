function gDisasters_PostSpawn(ply)
	ply.gDisasters = {}
	
	local function gDisasters_SetupBodyVariables()
		ply.gDisasters.Body = {}
		ply.gDisasters.Body.Temperature = 37
		ply.gDisasters.Body.Oxygen      = 100

		if GetConVar("gdisasters_hud_temp_enable"):GetInt() <= 0 or GetConVar("gdisasters_hud_temp_value"):GetInt() <= 0 then 
			ply:SetNWFloat("BodyTemperature", ply.gDisasters.Body.Temperature)
		elseif GetConVar("gdisasters_hud_oxygen_enable"):GetInt() <= 0 then
			ply:SetNWFloat("BodyOxygen", ply.gDisasters.Body.Oxygen)
		end
		
	end
	local function gDisasters_SetupAreaVariables()
		ply.gDisasters.Area      = {}
		ply.gDisasters.Area.LocalWind = 0
		ply.gDisasters.Area.IsOutdoor = false
	
	end
	local function gDisasters_SetupIntesity()
		ply.LavaIntensity = 0
		ply.WaterIntensity = 0
	end

	gDisasters_SetupBodyVariables()
	gDisasters_SetupAreaVariables()	
	gDisasters_SetupIntesity()
	
end
hook.Add( "PlayerInitialSpawn", "gDisasters_PostSpawn", gDisasters_PostSpawn )

function gDisasters_OnSpawn_Reset( ply )
	ply.gDisasters.Body.Temperature = 37 
	ply.gDisasters.Body.Oxygen      = 100
	ply.LavaIntensity = 0
	ply.gasmasked=false
	ply.hazsuited=false
	ply:StopSound("breathing")
	net.Start( "gd_net" )        
	net.WriteBit( false )
	net.Send(ply)

	if GetConVar("gdisasters_hud_temp_enable"):GetInt() <= 0 or GetConVar("gdisasters_hud_temp_value"):GetInt() <= 0 then 
		ply:SetNWFloat("BodyTemperature", ply.gDisasters.Body.Temperature)
	elseif GetConVar("gdisasters_hud_oxygen_enable"):GetInt() <= 0 then
		ply:SetNWFloat("BodyOxygen", ply.gDisasters.Body.Oxygen)
	end
end
hook.Add( "PlayerSpawn", "gDisasters_OnSpawn_Reset", gDisasters_OnSpawn_Reset )