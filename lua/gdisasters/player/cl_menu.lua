
-- SV MENU 
gDisasters_gDisastersSetupTime = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( label )
end

local function AddComboBox( CPanel, title, listofitems, convar)
		
	local combobox, label = CPanel:ComboBox( title, convar)
		
		
	for k, item in pairs(listofitems) do
		combobox:AddChoice(item)
	end
		
	return combobox
end
	
local function CreateTickboxConVariable(CPanel, desc, convarname)
	local CB = AddControlCB(CPanel, desc, convarname)
	
 
	CB.OnChange = function( panel, bVal ) 
	if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() )and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "gdisasters_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	timer.Simple(0.1, function()
	
		if( CB ) then
			CB:SetValue( GetConVar(( convarname )):GetFloat() );
		end
	end)
	
	return CB 
	
end

local function CreateSliderConVariable(CPanel, desc, minvar, maxvar, dp, convarname)
	local CB = CPanel:NumSlider(desc, convarname, minvar, maxvar, dp);
	
 	CB.Scratch.ConVarChanged = function() end	
	CB.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() )and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "gdisasters_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat(tonumber(val) );
			net.SendToServer();
		end
		
	end
		

	timer.Simple(0.1, function()
		
		if( CB ) then
			CB:SetValue( GetConVar(( convarname )):GetFloat() );
		end
	end)
	
	return CB
end

local function gDisastersSVSettings( CPanel )

	AddControlLabel( CPanel, "wind/tornado/water Related Damage options: " )

	CreateTickboxConVariable(CPanel, "Enable Water Related Damage"  , "gdisasters_envdynamicwater_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Tornado Related Damage" ,"gdisasters_envtornado_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Wind Related Damage" ,"gdisasters_wind_candamageconstraints");

	AddControlLabel( CPanel, "Temp options: " )

	CreateTickboxConVariable(CPanel, "Enable Temp Related Damage" ,"gdisasters_hud_temp_damage");
	CreateTickboxConVariable(CPanel, "Enable Temp Breathing" ,"gdisasters_hud_temp_breathing");
	CreateTickboxConVariable(CPanel, "Enable Temp Vomit" ,"gdisasters_hud_temp_vomit");
	CreateTickboxConVariable(CPanel, "Enable Temp Sneeze" ,"gdisasters_hud_temp_sneeze");

	AddControlLabel( CPanel, "Oxygen options: " )
	
	CreateTickboxConVariable(CPanel, "Enable Oxygen enable" ,"gdisasters_oxygen_enable");
	CreateTickboxConVariable(CPanel, "Enable Oxygen Related damage" ,"gdisasters_oxygen_damage");


	AddControlLabel( CPanel, "Other options: \n\nThe Atmophere option requires a map RESTART to take effect."  )

	CreateTickboxConVariable(CPanel, "Enable Atmosphere"  , "gdisasters_atmosphere");
	CreateTickboxConVariable(CPanel, "Enable Hud"  , "gdisasters_hud_enabled");
	CreateTickboxConVariable(CPanel, "Enable Experimental Overdraw"  , "gdisasters_experimental_overdraw");
	CreateTickboxConVariable(CPanel, "Enable Stormfox2 compatibility"  , "gdisasters_stormfox_enable");
end

-- ADVANCED SV MENU
local function gDisastersSVADVSettings( CPanel )

	AddControlLabel( CPanel, "Don't mess with these settings unless you know what you're doing.\n\nAdvanced options: ")
	
	AddControlLabel( CPanel, "Simulation Option: Change the quality of simulation.")
	CreateSliderConVariable(CPanel, "Tornado Simulation Quality", 0.1, 0.50, 2, "gdisasters_envtornado_simquality" );
	CreateSliderConVariable(CPanel, "Earthquake Simulation Quality", 0.1, 0.50, 2, "gdisasters_envearthquake_simquality" );
	CreateSliderConVariable(CPanel, "Water Simulation Quality", 0.1, 0.50, 2, "gdisasters_envdynamicwater_simquality");
	CreateSliderConVariable(CPanel, "Wind Simulation Quality", 0.1, 0.50, 2, "gdisasters_wind_physics_simquality");

	AddControlLabel( CPanel, "Advanced Wind options: " )
	
	CreateTickboxConVariable(CPanel, "Enable Wind physical" ,"gdisasters_wind_physics_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide" ,"gdisasters_wind_postdamage_nocollide_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetimeout" ,"gdisasters_wind_postdamage_nocollide_basetimeout");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetime spread" ,"gdisasters_wind_postdamage_nocollide_basetimeout_spread");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage reducemass" ,"gdisasters_wind_postdamage_reducemass_enabled");

	AddControlLabel( CPanel, "Advanced Temp options: " )

	CreateTickboxConVariable(CPanel, "Enable Temp UpdateVars" ,"gdisasters_hud_temp_updatevars");
	CreateTickboxConVariable(CPanel, "Enable Temp ClientSide" ,"gdisasters_hud_temp_cl");
	CreateTickboxConVariable(CPanel, "Enable Temp ServerSide" ,"gdisasters_hud_temp_sv");

	AddControlLabel( CPanel, "Water/lava flood or tsunami options: " )
	
	CreateSliderConVariable(CPanel, "min flood level" , 0, 10000, 1,"gdisasters_envdynamicwater_level_min");
	CreateSliderConVariable(CPanel, "max flood level", 0, 10000, 1 ,"gdisasters_envdynamicwater_level_max");

	CreateSliderConVariable(CPanel, "Tsunami start level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_startlevel");
	CreateSliderConVariable(CPanel, "Tsunami middel level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_middellevel");
	CreateSliderConVariable(CPanel, "Tsunami end level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_endlevel");

	CreateSliderConVariable(CPanel, "Tsunami speed", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_speed");

	
	AddControlLabel( CPanel, "Tornado options: i need talk about this?")
	
	CreateTickboxConVariable(CPanel, "Enable Custom Tornado Speed" ,"gdisasters_envtornado_manualspeed");
	CreateSliderConVariable(CPanel, "Tornado Speed", 4, 20, 2, "gdisasters_envtornado_speed" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime min", 1, 1000, 0, "gdisasters_envtornado_lifetime_min" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime max", 1, 1000, 0, "gdisasters_envtornado_lifetime_max" );
	CreateSliderConVariable(CPanel, "Tornado Damage", 0, 5000, 0, "gdisasters_envtornado_damage" );

	AddControlLabel( CPanel, "Hud type options: \n\n1: body hud\n\n2: pressure hud\n\n3: earthquake hud")
	
	CreateSliderConVariable(CPanel, "Hud Type", 1, 3, 0, "gdisasters_hud_type" );
	
	
end

local function gDisastersServerGraphics( CPanel )

	AddControlLabel( CPanel, "Antilag collision settings: \n\nPD NC BT: Post Damage No Collide Base Time\n\nCPPPS: Collisions Per Prop Per Second\n\nCAPS:Collisions Average Per Second" )
	
	CreateSliderConVariable(CPanel,"Max CPPPS", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_per_prop");
	CreateSliderConVariable(CPanel,"Max PD NC BT", 0, 1000, 0,"gdisasters_antilag_post_damage_no_collide_base_time");
	CreateSliderConVariable(CPanel,"Max CAPS (s)", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_average" );

	AddControlLabel( CPanel, "Antilag options: remove the lag :)" )
	
	--CreateSliderConVariable(CPanel,"Antilag Mode (s)", 0, 2, 0,"gdisasters_antilag_mode" );
	CreateTickboxConVariable(CPanel,"Enable Antilag", "gdisasters_antilag_enabled" );
	
end

local function gDisastersDayAndNightCycle( CPanel )
	CreateTickboxConVariable(CPanel, "Enable DNC"  , "gdisasters_dnc_enabled");
	CreateTickboxConVariable(CPanel, "Pause DNC"  , "gdisasters_dnc_paused");
	CreateTickboxConVariable(CPanel, "Real Time"  , "gdisasters_dnc_realtime");
	CreateTickboxConVariable(CPanel, "Log"  , "gdisasters_dnc_log");
	
	CreateSliderConVariable(CPanel, "length day", 1, 3600, 0, "gdisasters_dnc_length_day" )
	CreateSliderConVariable(CPanel, "length night", 1, 3600, 0, "gdisasters_dnc_length_night" )
end

local function gDisastersGraphicsSettings( CPanel )
	AddControlLabel( CPanel, "Graphics options: \n\nWind/Temp Type: " )

	AddComboBox( CPanel, "Hud Wind Display", {"km/h", "mph"}, "gdisasters_hud_windtype")
	AddComboBox( CPanel, "Hud Temperature Display", {"c", "f"}, "gdisasters_hud_temptype")

	AddControlLabel( CPanel, "\n\nGP: Ground Particles\n\nWP:Weather Particles\n\nSP: Screen Particles" )

	CreateTickboxConVariable(CPanel, "Enable Shake Screen"  , "gdisasters_shakescreen_enable");
	
	CreateTickboxConVariable(CPanel, "Enable GP"  , "gdisasters_graphics_enable_ground_particles");
	CreateTickboxConVariable(CPanel, "Enable WP"  , "gdisasters_graphics_enable_weather_particles");
	CreateTickboxConVariable(CPanel, "Enable SP"  , "gdisasters_graphics_enable_screen_particles");

	CreateSliderConVariable(CPanel, "Max SP", 0, 20, 1,"gdisasters_graphics_number_of_screen_particles"  );

end


local function gDisastersAudioSettings( CPanel )
	
	AddControlLabel( CPanel, "Audio options: " )
	
	CreateSliderConVariable(CPanel, "Light Wind Volume", 0,1,1, "gdisasters_sound_Light_Wind" );
	CreateSliderConVariable(CPanel, "Moderate Wind Volume", 0,1,1, "gdisasters_sound_Moderate_Wind" );
	CreateSliderConVariable(CPanel, "Heavy Wind Volume", 0,1,1,"gdisasters_sound_Heavy_Wind" );
	
	AddControlLabel( CPanel, "Hud Audio options: " )
	
	CreateSliderConVariable(CPanel, "hud Hearth Volume", 0,1,1, "gdisasters_hud_heartbeat_volume" );
	CreateSliderConVariable(CPanel, "hud Warning Volume", 0,1,1, "gdisasters_hud_warning_volume" );
end

local function gDisastersAutospawn( CPanel )

	AddControlLabel( CPanel, "Autospawn options: " )
	
	CreateSliderConVariable(CPanel, "Autospawn Time", 1, 1000, 0, "gdisasters_autospawn_timer" )
	CreateSliderConVariable(CPanel, "Autospawn Chance", 0, 1000, 0, "gdisasters_autospawn_spawn_chance" )

	AddControlLabel( CPanel, "Autospawn Box Options: " )

	CreateTickboxConVariable(CPanel, "Enable Storm Skybox"  , "gdisasters_autospawn_skybox");
	CreateTickboxConVariable(CPanel, "Disable Map Tornadoes "  , "gdisasters_getridmaptor");

	CreateTickboxConVariable(CPanel, "Autospawn Tornados"  , "gdisasters_autospawn");
	CreateTickboxConVariable(CPanel, "Autospawn Disasters"  , "gdisasters_autospawn_disasters");
	CreateTickboxConVariable(CPanel, "Autospawn Weather"  , "gdisasters_autospawn_weather");
	CreateTickboxConVariable(CPanel, "Autospawn Weather/Disasters"  , "gdisasters_autospawn_weatherdisaster");


	
end

local function gDisastersADVGraphicsSettings( CPanel )			
	AddControlLabel( CPanel, "Advanced Graphics options:" )

	CreateSliderConVariable(CPanel,  "Water Quality", 1, 3, 0, "gdisasters_graphics_water_quality" );
	CreateSliderConVariable(CPanel,   "Fog Quality", 1, 8, 0, "gdisasters_graphics_fog_quality" );

	AddControlLabel( CPanel, "Section dedicated to Doppler Radar.\nUse with caution." )

	AddComboBox( CPanel, "Resolution", {"4x4","8x8","16x16","32x32","64x64","48x48","128x128"}, "gdisasters_graphics_dr_resolution")
	AddComboBox( CPanel, "Monochromatic Mode", {"false", "true"}, "gdisasters_graphics_dr_monochromatic")

	CreateSliderConVariable(CPanel,"Max Render Distance", 1, 600, 0, "gdisasters_graphics_dr_maxrenderdistance" );
	CreateSliderConVariable(CPanel,"Refresh Rate (Hz)", 1, 16, 0, "gdisasters_graphics_dr_refreshrate" );
	CreateSliderConVariable(CPanel,"Update  Rate (Hz)", 1, 16, 0, "gdisasters_graphics_dr_updaterate" );
	
end


hook.Add( "PopulateToolMenu", "gDisasters_PopulateMenu", function()

	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersSVADSettings", "Advanced", "", "", gDisastersSVADVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersSVSettings", "Main", "", "", gDisastersSVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersAutospawn", "Autospawn", "", "", gDisastersAutospawn )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersServerGraphics", "Server Graphics", "", "", gDisastersServerGraphics )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Server", "gDisastersDayAndNightCycle", "Day and Night Cycle", "", "", gDisastersDayAndNightCycle)
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersAudioSettings", "Volume", "", "", gDisastersAudioSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersADVGraphicsSettings", "Advanced Graphics", "", "", gDisastersADVGraphicsSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived Edition", "Client", "gDisastersGraphicsSettings", "Graphics", "", "", gDisastersGraphicsSettings )

end );
