
gDisasters_gDisastersSetupTime = CurTime()

local function AddControlCB(CPanel, label, command)
	return CPanel:CheckBox( label, command )
end
local function AddControlLabel( CPanel, label )
	return  CPanel:Help( language.GetPhrase(label) )
end
local function AddControlSlider( CPanel, label, command, min, max, dp  )
	return  CPanel:NumSlider( label, command, min, max, dp );
end

local function AddComboBox( CPanel, title, listofitems, convar)
		
	local combobox, label = CPanel:ComboBox( language.GetPhrase(title), convar)
		
		
	for k, item in pairs(listofitems) do
		combobox:AddChoice(item)
	end
		
	return combobox
end
	
local function CreateTickboxConVariable(CPanel, desc, convarname)
	local CB = AddControlCB(CPanel, language.GetPhrase(desc), convarname)
	
 
	CB.OnChange = function( panel, bVal ) 
		if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 

		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( convarname ) ) then return end
			net.Start( "gd_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
	end

	
	return CB 
	
end

local function CreateSliderConVariable(CPanel, desc, minvar, maxvar, dp, convarname)
	local CB = AddControlSlider( CPanel, language.GetPhrase(desc), convarname, minvar, maxvar, dp  )
	

	CB.OnValueChanged = function( panel, val )
		if (CurTime() - gDisasters_gDisastersSetupTime) < 1 then return end 
		
		
		if( (LocalPlayer():IsAdmin() or LocalPlayer():IsSuperAdmin() ) and !Created ) then
			if ( tonumber(val) ) == cvars.Number( convarname )  then return end
			net.Start( "gd_clmenu_vars" );
			net.WriteString( convarname );
			net.WriteFloat( tonumber(val) );
			net.SendToServer();
			
			timer.Simple(0.1, function()
				
				if( CB ) then
					CB:SetValue( GetConVar(( convarname )):GetFloat() );
				end
			end)
		end
		
	end

	
	return CB
end

--SH MENU 

local function gDisastersSHSettings( CPanel )

	local lb = AddControlLabel( CPanel, "gd_1" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_2"  , "gdisasters_envdynamicwater_candamageconstraints");
	CreateTickboxConVariable(CPanel, "gd_3" ,"gdisasters_envtornado_candamageconstraints");
	CreateTickboxConVariable(CPanel, "gd_4" ,"gdisasters_wind_candamageconstraints");

	local lb3 = AddControlLabel( CPanel, "gd_5" )
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_6" ,"gdisasters_tvirus_zombie_strength");
	CreateTickboxConVariable(CPanel, "gd_7" ,"gdisasters_tvirus_nmrih_zombies");
end

local function gDisastersSHADVSettings( CPanel )

	local lb = AddControlLabel( CPanel, "gd_8")
	local lb2 = AddControlLabel( CPanel, "gd_9")
	lb:SetTextColor(Color( 255, 0, 0))
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	local lb3 = AddControlLabel( CPanel, "gd_10")
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "gd_11", 0.1, 0.50, 2, "gdisasters_envtornado_simquality" );
	CreateSliderConVariable(CPanel, "gd_12", 0.1, 0.50, 2, "gdisasters_envearthquake_simquality" );
	CreateSliderConVariable(CPanel, "gd_13", 0.1, 0.50, 2, "gdisasters_envdynamicwater_simquality");
	CreateSliderConVariable(CPanel, "gd_14", 0.1, 0.50, 2, "gdisasters_wind_physics_simquality");

	local lb4 = AddControlLabel( CPanel, "gd_15" )
	lb4:SetTextColor(Color( 0, 0, 0))
	lb4:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_16" ,"gdisasters_wind_physics_enabled");
	CreateTickboxConVariable(CPanel, "gd_17" ,"gdisasters_wind_postdamage_nocollide_enabled");
	CreateTickboxConVariable(CPanel, "gd_18" ,"gdisasters_wind_postdamage_nocollide_basetimeout");
	CreateTickboxConVariable(CPanel, "gd_19" ,"gdisasters_wind_postdamage_nocollide_basetimeout_spread");
	CreateTickboxConVariable(CPanel, "gd_20" ,"gdisasters_wind_postdamage_reducemass_enabled");

	local lb41 = AddControlLabel( CPanel, "gd_21" )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_22" ,"gdisasters_envearthquake_change_collision_group");

	local lb41 = AddControlLabel( CPanel, "gd_23" )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_24" ,"gdisasters_volcano_weatherchange");

	CreateSliderConVariable(CPanel, "gd_25", 0, 10, 2, "gdisasters_volcano_pressure_increase" );
	CreateSliderConVariable(CPanel, "gd_26", 0, 10, 2, "gdisasters_volcano_pressure_decrease" );

	local lb41 = AddControlLabel( CPanel, "gd_27" )
	lb41:SetTextColor(Color( 0, 0, 0))
	lb41:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_28" ,"gdisasters_weather_bradiation_damage_props");
	CreateTickboxConVariable(CPanel, "gd_28.1" ,"gdisasters_weather_bradiation_damage_npcs");

	local lb5 = AddControlLabel( CPanel, "gd_29" )
	lb5:SetTextColor(Color( 0, 0, 0))
	lb5:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "gd_30" , 0, 10000, 1,"gdisasters_envdynamicwater_level_min");
	CreateSliderConVariable(CPanel, "gd_31", 0, 10000, 1 ,"gdisasters_envdynamicwater_level_max");

	CreateSliderConVariable(CPanel, "gd_32", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_startlevel");
	CreateSliderConVariable(CPanel, "gd_33", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_middellevel");
	CreateSliderConVariable(CPanel, "gd_34", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_endlevel");

	CreateSliderConVariable(CPanel, "gd_35", 0, 10000, 1 ,"gdisasters_envdynamicwater_b_speed");
	
	local lb6 = AddControlLabel( CPanel, "gd_36")
	lb6:SetTextColor(Color( 0, 0, 0))
	lb6:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_37" ,"gdisasters_envtornado_manualspeed");
	CreateSliderConVariable(CPanel, "gd_38", 4, 20, 1, "gdisasters_envtornado_speed" );
	CreateSliderConVariable(CPanel, "gd_39", 1, 1000, 1, "gdisasters_envtornado_lifetime_min" );
	CreateSliderConVariable(CPanel, "gd_40", 1, 1000, 1, "gdisasters_envtornado_lifetime_max" );
	CreateSliderConVariable(CPanel, "gd_41", 0, 5000, 1, "gdisasters_envtornado_damage" );
	
	
end

local function gDisastersSHGraphics( CPanel )

	local lb = AddControlLabel( CPanel, "gd_42" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_43"  , "gdisasters_graphics_atmosphere");
	CreateTickboxConVariable(CPanel, "gd_44"  , "gdisasters_graphics_gfx");
	CreateTickboxConVariable(CPanel, "gd_45"  , "gdisasters_graphics_fog");
	

	local lb2 = AddControlLabel( CPanel, "gd_46" )
	local lb3 = AddControlLabel( CPanel, "gd_47" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	lb3:SetTextColor(Color( 0, 47, 255))

	CreateSliderConVariable(CPanel,"gd_48", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_per_prop");
	CreateSliderConVariable(CPanel,"gd_49", 0, 1000, 0,"gdisasters_antilag_post_damage_no_collide_base_time");
	CreateSliderConVariable(CPanel,"gd_50", 0, 1000, 0,"gdisasters_antilag_maximum_safe_collisions_per_second_average" );

	local lb4 = AddControlLabel( CPanel, "gd_51" )
	lb4:SetTextColor(Color( 0, 0, 0))
	lb4:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel,"gd_52", 0, 2, 0,"gdisasters_antilag_mode" );
	CreateTickboxConVariable(CPanel,"gd_53", "gdisasters_antilag_enabled" );
	
end



local function gDisastersAutospawn( CPanel )

	local lb = AddControlLabel( CPanel, "gd_54" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "gd_55", 1, 1000, 0, "gdisasters_autospawn_spawn_timer" )
	CreateSliderConVariable(CPanel, "gd_56", 1, 1000, 0, "gdisasters_autospawn_remove_timer" )
	CreateSliderConVariable(CPanel, "gd_57", 0, 1000, 0, "gdisasters_autospawn_spawn_chance" )

	AddComboBox( CPanel, "Autospawn Type", {"Disasters", "Weather", "Tornado", "Weather/Disasters"}, "gdisasters_autospawn_type")

	local lb2 = AddControlLabel( CPanel, "gd_58" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)

	CreateTickboxConVariable(CPanel, "gd_59"  , "gdisasters_autospawn_getridmaptor");
	CreateTickboxConVariable(CPanel, "gd_60"  , "gdisasters_autospawn_chat");
	CreateTickboxConVariable(CPanel, "gd_61"  , "gdisasters_autospawn_enable");

	
end

local function gDisastersHeatSystemBeta( CPanel )

	CreateTickboxConVariable(CPanel, "gd_88", "gdisasters_heat_system");
	CreateTickboxConVariable(CPanel, "gd_87", "gdisasters_graphics_draw_heatsystem_grid");

end

local function gDisastersSHhud( CPanel )

	
	local lb2 = AddControlLabel( CPanel, "gd_62" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_63" ,"gdisasters_hud_temp_enable");
	CreateTickboxConVariable(CPanel, "gd_64" ,"gdisasters_hud_temp_breathing");
	CreateTickboxConVariable(CPanel, "gd_65" ,"gdisasters_hud_temp_damage");
	CreateTickboxConVariable(CPanel, "gd_65.1" ,"gdisasters_hud_temp_npc_damage");
	CreateTickboxConVariable(CPanel, "gd_66" ,"gdisasters_hud_temp_player_speed_enable");
	CreateTickboxConVariable(CPanel, "gd_67" ,"gdisasters_hud_temp_value");

	CreateSliderConVariable(CPanel, "gd_68", 0, 1000, 0, "gdisasters_hud_temp_player_speed_walk" );
	CreateSliderConVariable(CPanel, "gd_69", 0, 1000, 0, "gdisasters_hud_temp_player_speed_sprint" );

	local lb3 = AddControlLabel( CPanel, "gd_70" )
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_71" ,"gdisasters_hud_oxygen_enable");
	CreateTickboxConVariable(CPanel, "gd_71.1" ,"gdisasters_hud_oxygen_npc_damage");
	CreateTickboxConVariable(CPanel, "gd_72" ,"gdisasters_hud_oxygen_damage");
	
end

local function gDisastersDNC( CPanel )
	local lb1 = AddControlLabel( CPanel, "gd_74" )
	local lb2 = AddControlLabel( CPanel, "gd_75" )
	lb1:SetTextColor(Color( 0, 47, 255))
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_76"  , "gdisasters_dnc_enabled");
	CreateTickboxConVariable(CPanel, "gd_77"  , "gdisasters_dnc_paused");
	CreateTickboxConVariable(CPanel, "gd_78"  , "gdisasters_dnc_realtime");
	CreateTickboxConVariable(CPanel, "gd_79"  , "gdisasters_dnc_create_light_environment");
	
	CreateSliderConVariable(CPanel, "gd_80", 1, 3600, 0, "gdisasters_dnc_length_day" )
	CreateSliderConVariable(CPanel, "gd_81", 1, 3600, 0, "gdisasters_dnc_length_night" )

	CreateSliderConVariable(CPanel, "gd_82", 1, 6000, 0, "gdisasters_dnc_moon_size" )
	
end

local function gDisastersAddonsCompatibility( CPanel )

	local lb = AddControlLabel( CPanel, "gd_83" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_84"  , "gdisasters_spacebuild_enabled");

	local lb = AddControlLabel( CPanel, "gd_85" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateTickboxConVariable(CPanel, "gd_86"  , "gdisasters_stormfox_enabled");
end


--CL MENU 

local function gDisastersADVGraphicsSettings( CPanel )			
	local lb = AddControlLabel( CPanel, "gd_cl_1" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)

	CreateSliderConVariable(CPanel,  "gd_cl_2", 1, 4, 0, "gdisasters_graphics_water_quality" );
	CreateSliderConVariable(CPanel,  "gd_cl_3", 1, 2, 0, "gdisasters_graphics_water_shader_quality" );
	CreateSliderConVariable(CPanel,  "gd_cl_4", 1, 2, 0, "gdisasters_graphics_lava_quality" );
	CreateSliderConVariable(CPanel,   "gd_cl_5", 1, 4, 0, "gdisasters_graphics_fog_quality" );

	CreateTickboxConVariable(CPanel, "gd_cl_41"  , "gdisasters_graphics_draw_smarttornado_path");

	local lb2 = AddControlLabel( CPanel, "gd_cl_6" )
	lb2:SetTextColor(Color( 255, 0, 0))

	AddComboBox( CPanel, "gd_cl_7", {"4x4","8x8","16x16","32x32","64x64","48x48","128x128"}, "gdisasters_graphics_dr_resolution")
	AddComboBox( CPanel, "gd_cl_8", {"false", "true"}, "gdisasters_graphics_dr_monochromatic")

	CreateSliderConVariable(CPanel,"gd_cl_9", 1, 600, 0, "gdisasters_graphics_dr_maxrenderdistance" );
	CreateSliderConVariable(CPanel,"gd_cl_10", 1, 16, 0, "gdisasters_graphics_dr_refreshrate" );
	CreateSliderConVariable(CPanel,"gd_cl_11", 1, 16, 0, "gdisasters_graphics_dr_updaterate" );
	
end

local function gDisastersGraphicsSettings( CPanel )

	local lb3 = AddControlLabel( CPanel, "gd_cl_12" )
	local lb4 = AddControlLabel( CPanel, "gd_cl_13")
	lb3:SetTextColor(Color( 0, 0, 0))
	lb3:SetSize(500, 500)
	lb4:SetTextColor(Color( 0, 47, 255))

	CreateTickboxConVariable(CPanel, "gd_cl_14"  , "gdisasters_graphics_experimental_overdraw");
	CreateTickboxConVariable(CPanel, "gd_cl_15"  , "gdisasters_graphics_shakescreen_enable");
	CreateTickboxConVariable(CPanel, "gd_cl_16"  , "gdisasters_graphics_draw_ceiling_effects");
	
	CreateTickboxConVariable(CPanel, "gd_cl_17"  , "gdisasters_graphics_enable_ground_particles");
	CreateTickboxConVariable(CPanel, "gd_cl_18"  , "gdisasters_graphics_enable_weather_particles");
	CreateTickboxConVariable(CPanel, "gd_cl_19"  , "gdisasters_graphics_enable_screen_particles");

	CreateTickboxConVariable(CPanel, "gd_cl_20"  , "gdisasters_graphics_enable_manual_number_of_screen_particles");

	CreateSliderConVariable(CPanel, "gd_cl_21", 0, 20, 1,"gdisasters_graphics_number_of_screen_particles"  );

end

local function gDisastersHudSettings( CPanel )
	
	local lb = AddControlLabel( CPanel, "gd_cl_22")
	local lb2 = AddControlLabel( CPanel, "gd_cl_23")
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	lb2:SetTextColor(Color( 0, 47, 255))

	CreateTickboxConVariable(CPanel, "gd_cl_24", "gdisasters_hud_enabled");
	
	CreateTickboxConVariable(CPanel, "gd_cl_25" ,"gdisasters_hud_temp_effects");
	CreateTickboxConVariable(CPanel, "gd_cl_26" ,"gdisasters_hud_temp_vomit");
	CreateTickboxConVariable(CPanel, "gd_cl_27" ,"gdisasters_hud_temp_sneeze");
	CreateTickboxConVariable(CPanel, "gd_cl_28" ,"gdisasters_hud_underwater_effects");
	CreateTickboxConVariable(CPanel, "gd_cl_29" ,"gdisasters_hud_underlava_effects");
	
	CreateSliderConVariable(CPanel, "gd_cl_30", 1, 4, 0, "gdisasters_hud_type" );

	AddComboBox( CPanel, "gd_cl_31", {"km/h", "mph"}, "gdisasters_hud_windtype")
	AddComboBox( CPanel, "gd_cl_32", {"°C", "°F", "°K"}, "gdisasters_hud_temptype")


end


local function gDisastersAudioSettings( CPanel )
	
	local lb = AddControlLabel( CPanel, "gd_cl_33" )
	lb:SetTextColor(Color( 0, 0, 0))
	lb:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "gd_cl_34", 0,1,1, "gdisasters_volume_Light_Wind" );
	CreateSliderConVariable(CPanel, "gd_cl_35", 0,1,1, "gdisasters_volume_Moderate_Wind" );
	CreateSliderConVariable(CPanel, "gd_cl_36", 0,1,1,"gdisasters_volume_Heavy_Wind" );
	CreateSliderConVariable(CPanel, "gd_cl_37", 0,1,1,"gdisasters_volume_soundwave" );
	
	local lb2 =  AddControlLabel( CPanel, "gd_cl_38" )
	lb2:SetTextColor(Color( 0, 0, 0))
	lb2:SetSize(500, 500)
	
	CreateSliderConVariable(CPanel, "gd_cl_39", 0,1,1, "gdisasters_volume_hud_heartbeat" );
	CreateSliderConVariable(CPanel, "gd_cl_40", 0,1,1, "gdisasters_volume_hud_warning" );
end

hook.Add( "AddToolMenuTabs", "gDisasters_Tab", function()
	spawnmenu.AddToolTab( "gDisasters Revived", "#gDisasters Revived", "icons/gdlogo.png" )
end)

hook.Add( "PopulateToolMenu", "gDisasters_PopulateMenu", function()
	

	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersSHADSettings", language.GetPhrase("gd_advanced"), "", "", gDisastersSHADVSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersSHSettings", language.GetPhrase("gd_main"), "", "", gDisastersSHSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersAutospawn", language.GetPhrase("gd_autospawn"), "", "", gDisastersAutospawn )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisasterDNC", language.GetPhrase("gd_dnc"), "", "", gDisastersDNC )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersSHhud", language.GetPhrase("gd_server_hud"), "", "", gDisastersSHhud )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersAddonsCompatibility", language.GetPhrase("gd_addons"), "", "", gDisastersAddonsCompatibility )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersSHGraphics", language.GetPhrase("gd_server_graphics"), "", "", gDisastersSHGraphics )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Shared", "gDisastersHeatSystemSettings", language.GetPhrase("gd_heatsystem"), "", "", gDisastersHeatSystemBeta )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersAudioSettings", language.GetPhrase("gd_volume"), "", "", gDisastersAudioSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersADVGraphicsSettings", language.GetPhrase("gd_advanced_graphics"), "", "", gDisastersADVGraphicsSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "ggDisastersHudSettings", language.GetPhrase("gd_hud"), "", "", gDisastersHudSettings )
	spawnmenu.AddToolMenuOption( "gDisasters Revived", "Client", "gDisastersGraphicsSettings", language.GetPhrase("gd_graphics"), "", "", gDisastersGraphicsSettings )
	

end );
