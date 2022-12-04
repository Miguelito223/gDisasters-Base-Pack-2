CreateConVar( "gdisasters_envdynamicwater_simquality", "1", {FCVAR_ARCHIVE}, "this affects simulation quality of env_dynamicwater " )
CreateConVar( "gdisasters_envdynamicwater_candamageconstraints", "1", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envearthquake_simquality", "1", {FCVAR_ARCHIVE}, "this affects simulation quality of env_earthquake " )
CreateConVar( "gdisasters_envearthquake_change_collision_group", "1", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envtornado_simquality", "1", {FCVAR_ARCHIVE}, " " )
CreateConVar( "gdisasters_wind_physics_simquality", "1", {FCVAR_ARCHIVE}, " " )

CreateConVar( "gdisasters_wind_physics_enabled", "1", {FCVAR_ARCHIVE}, " " )
CreateConVar( "gdisasters_wind_candamageconstraints", "1", {FCVAR_ARCHIVE}, " " )

CreateConVar( "gdisasters_envtornado_candamageconstraints", "1", {FCVAR_ARCHIVE}, " " )

CreateConVar( "gdisasters_getridmaptor", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_atmosphere", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_gfx_enable", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_fog_enable", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envtornado_manualspeed", "0", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envtornado_speed", "9", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_hud_temp_damage", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_player_speed", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_breathing", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_vomit", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_sneeze", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_enable_cl", "1", {FCVAR_ARCHIVE}	, "" )
CreateConVar( "gdisasters_hud_temp_enable", "1", {FCVAR_ARCHIVE}	, "" )

CreateConVar( "gdisasters_envtornado_lifetime_min", "100", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envtornado_lifetime_max", "500", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envdynamicwater_level_min", "100", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envdynamicwater_level_max", "800", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envdynamicwater_b_startlevel", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envdynamicwater_b_middellevel", "500", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_envdynamicwater_b_endlevel", "100", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envdynamicwater_b_speed", "20", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

CreateConVar( "gdisasters_autospawn_timer", 120, { FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_PROTECTED}, "How often do you want to run the tornado spawn?")
CreateConVar( "gdisasters_autospawn_spawn_chance", 3, { FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_PROTECTED}, "What is the chance that a tornado will spawn?")
CreateConVar( "gdisasters_autospawn_enable", 1, {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_autospawn_chat", 1, {FCVAR_ARCHIVE}, "")
CreateConVar( "gdisasters_autospawn_type", "Tornado", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_envtornado_damage", "200", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_oxygen_damage", "1", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_oxygen_enable", "1", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_wind_postdamage_nocollide_enabled", "1", {FCVAR_ARCHIVE}, " " )
CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout", "1", {FCVAR_ARCHIVE}, " " )
CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout_spread", "1", {FCVAR_ARCHIVE}, " " )
CreateConVar( "gdisasters_wind_postdamage_reducemass_enabled", "1", {FCVAR_ARCHIVE}, " " )

CreateConVar( "gdisasters_antilag_enabled", "0", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_average", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_per_prop", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_post_damage_no_collide_base_time", "400", {FCVAR_ARCHIVE}, "" )
CreateConVar( "gdisasters_antilag_mode", "1", {FCVAR_ARCHIVE}, "" )

CreateConVar( "gdisasters_dnc_enabled", "1", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Day & Night enabled." )
CreateConVar( "gdisasters_dnc_paused", "0", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Day & Night time progression enabled." )
CreateConVar( "gdisasters_dnc_realtime", "0", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Whether or not Day & Night progresses based on the servers time zone." );
CreateConVar( "gdisasters_dnc_log", "0", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED, FCVAR_NOTIFY }, "Turn Day & Night logging to console on or off." )

CreateConVar( "gdisasters_dnc_length_day", "3600", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED }, "The duration modifier of daytime in seconds." )
CreateConVar( "gdisasters_dnc_length_night", "3600", { FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_REPLICATED }, "The duration modifier of nighttime in seconds." )