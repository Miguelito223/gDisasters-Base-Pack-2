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
CreateConVar( "gdisasters_weather_acidraindamageprops", "1", {FCVAR_ARCHIVE}, "")


--hud

CreateConVar( "gdisasters_hud_temp_damage", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_player_speed", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_breathing", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_vomit", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_sneeze", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_enable_cl", "1", {FCVAR_ARCHIVE}	, "" )
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

--S37K map bounds

CreateConVar( "gdisasters_mapbounds_S37K", "1", {FCVAR_ARCHIVE}, "" )

--graphics

CreateConVar( "gdisasters_graphics_atmosphere", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_graphics_gfx", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_graphics_fog", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_graphics_stormfox", "0", {FCVAR_ARCHIVE}, "")



CreateConVar( "gdisasters_antilag_enabled", "0", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_average", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_per_prop", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_post_damage_no_collide_base_time", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_mode", "0", {FCVAR_ARCHIVE}, "" )

--dnc

gDisasters.DayNightSystem.InternalVars.Enabled = CreateConVar( "gdisasters_dnc_enabled", "0", {FCVAR_ARCHIVE}, "" )
gDisasters.DayNightSystem.InternalVars.RealTime = CreateConVar( "gdisasters_dnc_realtime", "0", {FCVAR_ARCHIVE}, "" )
gDisasters.DayNightSystem.InternalVars.Paused = CreateConVar( "gdisasters_dnc_paused", "0", {FCVAR_ARCHIVE}, "" )

gDisasters.DayNightSystem.InternalVars.Length_Day = CreateConVar( "gDisasters_dnc_length_day", "600", {FCVAR_ARCHIVE}, "" )
gDisasters.DayNightSystem.InternalVars.Length_Night = CreateConVar( "gDisasters_dnc_length_night", "600", {FCVAR_ARCHIVE}, "" )

gDisasters.DayNightSystem.InternalVars.MoonSize = CreateConVar( "gdisasters_dnc_Moon_Size", "3000", {FCVAR_ARCHIVE}, "" )


