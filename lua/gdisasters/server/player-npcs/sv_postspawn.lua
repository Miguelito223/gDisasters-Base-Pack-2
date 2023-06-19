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
	local function gDisasters_SetupConvars()
	
		--env
			
		CreateConVar( "gdisasters_envdynamicwater_simquality", "0.10", {FCVAR_ARCHIVE}, "this affects simulation quality of env_dynamicwater " )
		CreateConVar( "gdisasters_envdynamicwater_candamageconstraints", "1", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_level_min", "100", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_level_max", "800", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_b_startlevel", "1", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_b_middellevel", "500", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_b_endlevel", "100", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envdynamicwater_b_speed", "20", {FCVAR_ARCHIVE}, "" )
			
		CreateConVar( "gdisasters_envearthquake_simquality", "0.10", {FCVAR_ARCHIVE}, "this affects simulation quality of env_earthquake " )
		CreateConVar( "gdisasters_envearthquake_change_collision_group", "1", {FCVAR_ARCHIVE}, "" )
			
		CreateConVar( "gdisasters_envtornado_simquality", "0.10", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_envtornado_candamageconstraints", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_envtornado_manualspeed", "0", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envtornado_speed", "9", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envtornado_lifetime_min", "100", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envtornado_lifetime_max", "500", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_envtornado_damage", "200", {FCVAR_ARCHIVE}, "" )
			
		CreateConVar( "gdisasters_wind_physics_simquality", "0.10", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_physics_enabled", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_candamageconstraints", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_postdamage_nocollide_enabled", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout_spread", "1", {FCVAR_ARCHIVE}, " " )
		CreateConVar( "gdisasters_wind_postdamage_reducemass_enabled", "1", {FCVAR_ARCHIVE}, " " )
			
		CreateConVar( "gdisasters_volcano_weatherchange", "1", {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_volcano_pressure_increase", "0.05", {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_volcano_pressure_decrease", "0.1", {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_weather_acidraindamageprops", "1", {FCVAR_ARCHIVE}, "")
			
			
		--hud
			
		CreateConVar( "gdisasters_hud_temp_damage", "1", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temp_player_speed_enable", "1", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temp_player_speed_walk", "400", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temp_player_speed_sprint", "600", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temp_value", "1", {FCVAR_ARCHIVE}	, "" )
		CreateConVar( "gdisasters_hud_temp_enable", "1", {FCVAR_ARCHIVE}	, "" )
			
		CreateConVar( "gdisasters_hud_oxygen_damage", "1", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_hud_oxygen_enable", "1", {FCVAR_ARCHIVE}, "" )
			
			
		--autospawn
			
		CreateConVar( "gdisasters_autospawn_getridmaptor", "0", {FCVAR_ARCHIVE}, "" )
			
		CreateConVar( "gdisasters_autospawn_spawn_timer", "120", { FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_PROTECTED}, "How often do you want to run the tornado spawn?")
		CreateConVar( "gdisasters_autospawn_remove_timer", "300", { FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_PROTECTED}, "How often do you want to run the tornado spawn?")
		CreateConVar( "gdisasters_autospawn_spawn_chance", "3", { FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_PROTECTED}, "What is the chance that a tornado will spawn?")
		CreateConVar( "gdisasters_autospawn_enable", "0", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_autospawn_chat", "1", {FCVAR_ARCHIVE}, "")
		CreateConVar( "gdisasters_autospawn_type", "Tornado", {FCVAR_ARCHIVE}, "" )
		
		--graphics
		
		CreateConVar( "gdisasters_graphics_atmosphere", "1", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_graphics_gfx", "1", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_graphics_fog", "1", {FCVAR_ARCHIVE}, "" )
		
		
		
		CreateConVar( "gdisasters_antilag_enabled", "0", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_average", "400", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_per_prop", "400", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_antilag_post_damage_no_collide_base_time", "400", {FCVAR_ARCHIVE}, "" )
		CreateConVar( "gdisasters_antilag_mode", "0", {FCVAR_ARCHIVE}, "" )
		
		
		--SpaceBuild
		
		CreateConVar( "gdisasters_spacebuild_enabled", "0", {FCVAR_ARCHIVE}, "" )
		
		--stormfox
		
		CreateConVar( "gdisasters_stormfox_enabled", "0", {FCVAR_ARCHIVE}, "")
	
	end
	local function gDisasters_SetupAreaVariables()
		ply.gDisasters.Area      = {}
		ply.gDisasters.Area.LocalWind = 0
		ply.gDisasters.Area.IsOutdoor = false
	
	end
	local function gDisasters_SetupLavaIntesity()
		ply.LavaIntensity = 0
	end


	
	gDisasters_SetupConvars()
	gDisasters_SetupBodyVariables()
	gDisasters_SetupAreaVariables()	
	gDisasters_SetupLavaIntesity()
	


	

	
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