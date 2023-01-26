gDisasters_gDisastersSetupTime = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( label )
end
local function AddControlSlider( CPanel, label, command, min, max, dp  )
	return  CPanel:NumSlider( label, command, min, max, dp );
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

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "gd_clmenu_vars" );
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
	local CB = AddControlSlider( CPanel, desc, convarname, minvar, maxvar, dp  )
	

	CB.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "gd_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( tonumber(val) );
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

--SV MENU 

local function gDisastersSVSettings( CPanel )

	local lb = AddControlLabel( CPanel, "Wind/Tornado/Water Related Damage Options: " )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable Water Related Damage"  , "gdisasters_envdynamicwater_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Tornado Related Damage" ,"gdisasters_envtornado_candamageconstraints");
	CreateTickboxConVariable(CPanel, "Enable Wind Related Damage" ,"gdisasters_wind_candamageconstraints");

	local lb2 = AddControlLabel( CPanel, "Body Temperature Options: " )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "Enable Body Temperature" ,"gdisasters_hud_temp_enable");
	CreateTickboxConVariable(CPanel, "Enable Body Temperature Screen Effects" ,"gdisasters_hud_temp_enable_cl");
	CreateTickboxConVariable(CPanel, "Enable Body Temperature Related Damage" ,"gdisasters_hud_temp_damage");
	CreateTickboxConVariable(CPanel, "Enable Body Temperature Change Player Speed" ,"gdisasters_hud_temp_player_speed");

	CreateTickboxConVariable(CPanel, "Enable Body Temperature Breathing" ,"gdisasters_hud_temp_breathing");
	CreateTickboxConVariable(CPanel, "Enable Body Temperature Vomit" ,"gdisasters_hud_temp_vomit");
	CreateTickboxConVariable(CPanel, "Enable Body Temperature Sneeze" ,"gdisasters_hud_temp_sneeze");

	local lb3 = AddControlLabel( CPanel, "Body Oxygen Options: " )
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "Enable Body Oxygen" ,"gdisasters_hud_oxygen_enable");
	CreateTickboxConVariable(CPanel, "Enable Body Oxygen Related Damage" ,"gdisasters_hud_oxygen_damage");
end

local function gDisastersSVADVSettings( CPanel )

	local lb = AddControlLabel( CPanel, "Don't mess with these settings unless you know what you're doing.")
	local lb2 = AddControlLabel( CPanel, "Advanced Options: ")
	lb:SetTextColor(Color( 255, 0, 0))
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	local lb3 = AddControlLabel( CPanel, "Simulation Option: Change the quality of simulation.")
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "Tornado Simulation Quality", 0.1, 0.50, 2, "gdisasters_envtornado_simquality" );
	CreateSliderConVariable(CPanel, "Earthquake Simulation Quality", 0.1, 0.50, 2, "gdisasters_envearthquake_simquality" );
	CreateSliderConVariable(CPanel, "Water Simulation Quality", 0.1, 0.50, 2, "gdisasters_envdynamicwater_simquality");
	CreateSliderConVariable(CPanel, "Wind Simulation Quality", 0.1, 0.50, 2, "gdisasters_wind_physics_simquality");

	local lb4 = AddControlLabel( CPanel, "Wind Options: " )
	lb4:SetTextColor(Color( 0, 0, 0))
	lb4:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "Enable Wind physical" ,"gdisasters_wind_physics_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide" ,"gdisasters_wind_postdamage_nocollide_enabled");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetimeout" ,"gdisasters_wind_postdamage_nocollide_basetimeout");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage no collide basetime spread" ,"gdisasters_wind_postdamage_nocollide_basetimeout_spread");
	CreateTickboxConVariable(CPanel, "Enable Wind postdamage reducemass" ,"gdisasters_wind_postdamage_reducemass_enabled");

	local lb41 = AddControlLabel( CPanel, "Eathquake Options: " )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable earthquake change collision group" ,"gdisasters_envearthquake_change_collision_group");

	local lb41 = AddControlLabel( CPanel, "Volcano/Moon/Asteroid Options: " )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable volcano/moon/asteroid climate change" ,"gdisasters_volcano_weatherchange");

	local lb41 = AddControlLabel( CPanel, "Weather Options: " )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable Acid Rain damage props" ,"gdisasters_weather_acidraindamageprops");

	local lb4 = AddControlLabel( CPanel, "Map Bounds options: " )
	lb4:SetTextColor(Color( 0, 0, 0))
	lb4:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable S37K Map Bounds (Only work in server so it may have errors if you are a client)", "gdisasters_mapbounds_S37K");

	local lb5 = AddControlLabel( CPanel, "Water/Lava and Flood/Tsunami Options: " )
	lb5:SetTextColor(Color( 0, 0, 0))
	lb5:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "min flood level" , 0, 10000, 1,"gdisasters_envdynamicwater_level_min");
	CreateSliderConVariable(CPanel, "max flood level", 0, 10000, 1 ,"gdisasters_envdynamicwater_level_max");

	CreateSliderConVariable(CPanel, "Tsunami start level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_startlevel");
	CreateSliderConVariable(CPanel, "Tsunami middel level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_middellevel");
	CreateSliderConVariable(CPanel, "Tsunami end level", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_endlevel");

	CreateSliderConVariable(CPanel, "Tsunami speed", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_speed");
	
	local lb6 = AddControlLabel( CPanel, "Tornado Options: ")
	lb6:SetTextColor(Color( 0, 0, 0))
	lb6:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "Enable Custom Tornado Speed" ,"gdisasters_envtornado_manualspeed");
	CreateSliderConVariable(CPanel, "Tornado Speed", 4, 20, 1, "gdisasters_envtornado_speed" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime min", 1, 1000, 1, "gdisasters_envtornado_lifetime_min" );
	CreateSliderConVariable(CPanel, "Tornado Lifetime max", 1, 1000, 1, "gdisasters_envtornado_lifetime_max" );
	CreateSliderConVariable(CPanel, "Tornado Damage", 0, 5000, 1, "gdisasters_envtornado_damage" );
	
	
end

local function gDisastersServerGraphics( CPanel )

	local lb = AddControlLabel( CPanel, "Main Server Graphics: " )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable Atmosphere"  , "gdisasters_graphics_atmosphere");
	CreateTickboxConVariable(CPanel, "Enable GFX effect"  , "gdisasters_graphics_gfx");
	CreateTickboxConVariable(CPanel, "Enable Fog Effect"  , "gdisasters_graphics_fog");
	CreateTickboxConVariable(CPanel, "Enable Stormfox2 Compatibility"  , "gdisasters_graphics_stormfox");

	local lb2 = AddControlLabel( CPanel, "Antilag Collision Options:" )
	local lb3 = AddControlLabel( CPanel, "PD NC BT: Post Damage No Collide Base Time\n\nCPPPS: Collisions Per Prop Per Second\n\nCAPS:Collisions Average Per Second" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	lb3:SetTextColor(Color( 0, 47, 255))

	CreateSliderConVariable(CPanel,"Max CPPPS", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_per_prop");
	CreateSliderConVariable(CPanel,"Max PD NC BT", 0, 1000, 0,"gdisasters_antilag_post_damage_no_collide_base_time");
	CreateSliderConVariable(CPanel,"Max CAPS (s)", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_average" );

	local lb4 = AddControlLabel( CPanel, "Antilag Options:" )
	lb4:SetTextColor(Color( 0, 0, 0))
	lb4:SetSize(500, 500)
	
	--CreateSliderConVariable(CPanel,"Antilag Mode (s)", 0, 2, 0,"gdisasters_antilag_mode" );
	CreateTickboxConVariable(CPanel,"Enable Antilag", "gdisasters_antilag_enabled" );
	
end

local function gDisastersDayAndNightCycle( CPanel )
	local lb = AddControlLabel( CPanel, "DNC Options:" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Enable DNC"  , "gdisasters_dnc_enabled");
	CreateTickboxConVariable(CPanel, "Pause DNC"  , "gdisasters_dnc_paused");
	CreateTickboxConVariable(CPanel, "Real Time"  , "gdisasters_dnc_realtime");
	CreateTickboxConVariable(CPanel, "Log"  , "gdisasters_dnc_log");
	
	local lb2 = AddControlLabel( CPanel, "DNC Length Options:" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)

	CreateSliderConVariable(CPanel, "Length day", 1, 3600, 0, "gdisasters_dnc_length_day" )
	CreateSliderConVariable(CPanel, "Length night", 1, 3600, 0, "gdisasters_dnc_length_night" )
end



local function gDisastersAutospawn( CPanel )

	local lb = AddControlLabel( CPanel, "Autospawn Options: " )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "Autospawn Spawn Time", 1, 1000, 0, "gdisasters_autospawn_spawn_timer" )
	CreateSliderConVariable(CPanel, "Autospawn Remove Time", 1, 1000, 0, "gdisasters_autospawn_remove_timer" )
	CreateSliderConVariable(CPanel, "Autospawn Chance", 0, 1000, 0, "gdisasters_autospawn_spawn_chance" )

	AddComboBox( CPanel, "Autospawn Type", {"Disasters", "Weather", "Tornado", "Weather/Disasters"}, "gdisasters_autospawn_type")

	local lb2 = AddControlLabel( CPanel, "Autospawn Box Options: " )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "Disable Map Tornadoes "  , "gdisasters_autospawn_getridmaptor");
	CreateTickboxConVariable(CPanel, "Enable Chat Messages"  , "gdisasters_autospawn_chat");
	
	CreateTickboxConVariable(CPanel, "Enable Autospawn "  , "gdisasters_autospawn_enable");

	
end

--CL MENU 

local function gDisastersADVGraphicsSettings( CPanel )			
	local lb = AddControlLabel( CPanel, "Advanced Graphics Options:" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateSliderConVariable(CPanel,  "Water Quality", 1, 3, 0, "gdisasters_graphics_water_quality" );
	CreateSliderConVariable(CPanel,   "Fog Quality", 1, 4, 0, "gdisasters_graphics_fog_quality" );

	local lb2 = AddControlLabel( CPanel, "Section dedicated to Doppler Radar.\nUse with caution." )
	lb2:SetTextColor(Color( 255, 0, 0))

	AddComboBox( CPanel, "Resolution", {"4x4","8x8","16x16","32x32","64x64","48x48","128x128"}, "gdisasters_graphics_dr_resolution")
	AddComboBox( CPanel, "Monochromatic Mode", {"false", "true"}, "gdisasters_graphics_dr_monochromatic")

	CreateSliderConVariable(CPanel,"Max Render Distance", 1, 600, 0, "gdisasters_graphics_dr_maxrenderdistance" );
	CreateSliderConVariable(CPanel,"Refresh Rate (Hz)", 1, 16, 0, "gdisasters_graphics_dr_refreshrate" );
	CreateSliderConVariable(CPanel,"Update  Rate (Hz)", 1, 16, 0, "gdisasters_graphics_dr_updaterate" );
	
end

local function gDisastersGraphicsSettings( CPanel )

	local lb3 = AddControlLabel( CPanel, "Graphics Options." )
	local lb4 = AddControlLabel( CPanel, "GP: Ground Particles\n\nWP:Weather Particles\n\nSP: Screen Particles" )
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	lb4:SetTextColor(Color( 0, 47, 255))

	CreateTickboxConVariable(CPanel, "Enable Experimental Overdraw"  , "gdisasters_graphics_experimental_overdraw");
	CreateTickboxConVariable(CPanel, "Enable Shake Screen"  , "gdisasters_graphics_shakescreen_enable");
	
	CreateTickboxConVariable(CPanel, "Enable GP"  , "gdisasters_graphics_enable_ground_particles");
	CreateTickboxConVariable(CPanel, "Enable WP"  , "gdisasters_graphics_enable_weather_particles");
	CreateTickboxConVariable(CPanel, "Enable SP"  , "gdisasters_graphics_enable_screen_particles");

	CreateTickboxConVariable(CPanel, "Enable Manual SP"  , "gdisasters_graphics_enable_manual_number_of_screen_particles");

	CreateSliderConVariable(CPanel, "Max SP", 0, 20, 1,"gdisasters_graphics_number_of_screen_particles"  );

end

local function gDisastersHudSettings( CPanel )
	
	local lb = AddControlLabel( CPanel, "Hud Options: ")
	local lb2 = AddControlLabel( CPanel, "1: body hud\n\n2: pressure hud\n\n3: earthquake hud")
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	lb2:SetTextColor(Color( 0, 47, 255))

	CreateTickboxConVariable(CPanel, "Enable Hud", "gdisasters_hud_enabled");
	CreateSliderConVariable(CPanel, "Hud Type", 1, 3, 0, "gdisasters_hud_type" );

	AddComboBox( CPanel, "Hud Wind Display", {"km/h", "mph"}, "gdisasters_hud_windtype")
	AddComboBox( CPanel, "Hud Temperature Display", {"c", "f"}, "gdisasters_hud_temptype")
end


local function gDisastersAudioSettings( CPanel )
	
	local lb = AddControlLabel( CPanel, "Audio Options: " )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "Light Wind Volume", 0,1,1, "gdisasters_volume_Light_Wind" );
	CreateSliderConVariable(CPanel, "Moderate Wind Volume", 0,1,1, "gdisasters_volume_Moderate_Wind" );
	CreateSliderConVariable(CPanel, "Heavy Wind Volume", 0,1,1,"gdisasters_volume_Heavy_Wind" );
	CreateSliderConVariable(CPanel, "SoundWave Volume", 0,1,1,"gdisasters_volume_soundwave" );
	
	local lb2 =  AddControlLabel( CPanel, "Hud Audio Options: " )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "hud Hearth Volume", 0,1,1, "gdisasters_volume_hud_heartbeat" );
	CreateSliderConVariable(CPanel, "hud Warning Volume", 0,1,1, "gdisasters_volume_hud_warning" );
end


hook.Add( "PopulateToolMenu", "gDisasters_PopulateMenu", function()

	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Server", "gDisastersSVADSettings", "Advanced", "", "", gDisastersSVADVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Server", "gDisastersSVSettings", "Main", "", "", gDisastersSVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Server", "gDisastersAutospawn", "Autospawn", "", "", gDisastersAutospawn )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Server", "gDisastersServerGraphics", "Server Graphics", "", "", gDisastersServerGraphics )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Server", "gDisastersDayAndNightCycle", "Day and Night Cycle", "", "", gDisastersDayAndNightCycle)
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersAudioSettings", "Volume", "", "", gDisastersAudioSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersADVGraphicsSettings", "Advanced Graphics", "", "", gDisastersADVGraphicsSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "ggDisastersHudSettings", "Hud", "", "", gDisastersHudSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersGraphicsSettings", "Graphics", "", "", gDisastersGraphicsSettings )

end );
