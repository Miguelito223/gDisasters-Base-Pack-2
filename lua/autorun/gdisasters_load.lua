if (SERVER) then

	AddCSLuaFile("autorun/gdisasters_load.lua")
	
	AddCSLuaFile("gdisasters/shared_func/main.lua")
	AddCSLuaFile("gdisasters/shared_func/netstrings.lua")
	AddCSLuaFile("gdisasters/extensions/patchs-bounds.lua")
	AddCSLuaFile("gdisasters/game/convars/main.lua")
	AddCSLuaFile("gdisasters/player/cl_menu.lua")
	AddCSLuaFile("gdisasters/player/sv_menu.lua")
	AddCSLuaFile("gdisasters/player/postspawn.lua")
	AddCSLuaFile("gdisasters/game/water_physics.lua")
	AddCSLuaFile("gdisasters/game/world_init.lua")
	AddCSLuaFile("gdisasters/spawnlist/menu/main.lua")
	AddCSLuaFile("gdisasters/spawnlist/menu/populate.lua")
	AddCSLuaFile("gdisasters/game/dnc.lua")
	AddCSLuaFile("gdisasters/game/damagetypes.lua")
	AddCSLuaFile("gdisasters/player/process_gfx.lua")
	AddCSLuaFile("gdisasters/player/process_temp.lua")
	AddCSLuaFile("gdisasters/atmosphere/main.lua")
	AddCSLuaFile("gdisasters/hud/main.lua")	
	AddCSLuaFile("gdisasters/game/decals.lua")
	AddCSLuaFile("gdisasters/experimental/heat-system.lua")
	AddCSLuaFile("gdisasters/Autospawn/autospawn.lua")
	AddCSLuaFile("gdisasters/stormfox2_compatibility/main.lua")

	include("gdisasters/shared_func/main.lua")	
	include("gdisasters/shared_func/netstrings.lua")
	include("gdisasters/extensions/patchs-bounds.lua")	
	include("gdisasters/player/sv_menu.lua")
	include("gdisasters/game/antilag/main.lua")
	include("gdisasters/game/water_physics.lua")
	include("gdisasters/game/world_init.lua")
	include("gdisasters/game/convars/main.lua")
	include("gdisasters/game/dnc.lua")
	include("gdisasters/player/postspawn.lua")
	include("gdisasters/player/cl_menu.lua")
	include("gdisasters/game/decals.lua")
	include("gdisasters/experimental/heat-system.lua")
	include("gdisasters/Autospawn/autospawn.lua")
	include("gdisasters/stormfox2_compatibility/main.lua")
	
	include("gdisasters/spawnlist/menu/main.lua")
	include("gdisasters/spawnlist/menu/populate.lua")
	include("gdisasters/game/damagetypes.lua")
	include("gdisasters/player/process_gfx.lua")
	include("gdisasters/player/process_temp.lua")
	include("gdisasters/atmosphere/main.lua")
	include("gdisasters/hud/main.lua")	
	
	

	
end

if (CLIENT) then	

	include("gdisasters/player/cl_menu.lua")
	include("gdisasters/shared_func/main.lua")	
	include("gdisasters/shared_func/netstrings.lua")
	include("gdisasters/extensions/patchs-bounds.lua")		
	include("gdisasters/player/postspawn.lua")
	include("gdisasters/experimental/heat-system.lua")

	include("gdisasters/stormfox2_compatibility/main.lua")
	
	include("gdisasters/player/process_gfx.lua")
	include("gdisasters/player/process_temp.lua")
	include("gdisasters/atmosphere/main.lua")
	include("gdisasters/hud/main.lua")
	include("gdisasters/Autospawn/skybox.lua")
		
	include("gdisasters/spawnlist/menu/main.lua")
	include("gdisasters/spawnlist/menu/populate.lua")
	include("gdisasters/game/decals.lua")
	include("gdisasters/game/dnc_cl.lua")
	
end


PrecacheParticleSystem("earthquake_player_ground_rocks")
PrecacheParticleSystem("earthquake_player_ground_dust")
PrecacheParticleSystem("earthquake_player_ground_debris")



PrecacheParticleSystem("tsunami_splash_effect_r100")
PrecacheParticleSystem("tsunami_splash_effect_r200")
PrecacheParticleSystem("tsunami_splash_effect_r300")
PrecacheParticleSystem("tsunami_splash_effect_r400")
PrecacheParticleSystem("tsunami_splash_effect_r500")


