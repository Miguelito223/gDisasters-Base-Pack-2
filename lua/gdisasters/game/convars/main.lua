
AddCSLuaFile("autorun/server/convars.lua") -- REMOVE THIS FILE AND YOU WILL DIE A HORRIBLE DEATH 

CreateConVar( "gdisasters_envdynamicwater_simquality", "50", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "this affects simulation quality of env_dynamicwater " )
CreateConVar( "gdisasters_envdynamicwater_candamageconstraints", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )

CreateConVar( "gdisasters_envearthquake_simquality", "50", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "this affects simulation quality of env_earthquake " )

CreateConVar( "gdisasters_envtornado_simquality", "50", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )
CreateConVar( "gdisasters_wind_physics_simquality", "50", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )

CreateConVar( "gdisasters_wind_physics_enabled", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )
CreateConVar( "gdisasters_wind_candamageconstraints", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )

CreateConVar( "gdisasters_envtornado_candamageconstraints", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )

CreateConVar( "gdisasters_getridmaptor", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_atmosphere", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_envtornado_manualspeed", "0", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_envtornado_speed", "9", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )

CreateConVar( "gdisasters_wind_postdamage_nocollide_enabled", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )
CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )
CreateConVar( "gdisasters_wind_postdamage_nocollide_basetimeout_spread", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )
CreateConVar( "gdisasters_wind_postdamage_reducemass_enabled", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, " " )

CreateConVar( "gdisasters_antilag_enabled", "0", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_average", "400", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_antilag_maximum_safe_collisions_per_second_per_prop", "400", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_antilag_post_damage_no_collide_base_time", "400", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )
CreateConVar( "gdisasters_antilag_mode", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "" )

CreateConVar( "gdisasters_experimental_overdraw", "1", {FCVAR_ARCHIVE,FCVAR_NOTIFY}, "sexy " )








