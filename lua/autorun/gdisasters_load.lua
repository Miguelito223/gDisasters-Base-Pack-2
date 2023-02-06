if (SERVER) then

	AddCSLuaFile("gdisasters/server/player-npcs/sv_process_oxygen.lua")
	AddCSLuaFile("gdisasters/server/game/sv_autospawn.lua")
	AddCSLuaFile("gdisasters/server/game/sv_damagetypes.lua")

	include("gdisasters/server/player-npcs/sv_process_oxygen.lua")
	include("gdisasters/server/game/sv_autospawn.lua")
	include("gdisasters/server/game/sv_damagetypes.lua")
	include("gdisasters/server/game/antilag/sv_main.lua")
	
end

if (CLIENT) then	

	AddCSLuaFile("autorun/client/garrys_particles.lua")

	AddCSLuaFile("gdisasters/client/spawnlist/menu/cl_main.lua")
	AddCSLuaFile("gdisasters/client/spawnlist/menu/cl_populate.lua")
	AddCSLuaFile("gdisasters/client/hud/cl_main.lua")

	include("gdisasters/client/spawnlist/menu/cl_main.lua")
	include("gdisasters/client/spawnlist/menu/cl_populate.lua")
	include("gdisasters/client/hud/cl_main.lua")
end

	
AddCSLuaFile("autorun/gdisasters_load.lua")
AddCSLuaFile("autorun/precached_particles.lua")

AddCSLuaFile("gdisasters/shared/shared_func/sh_main.lua")
AddCSLuaFile("gdisasters/shared/shared_func/sh_netstrings.lua")
AddCSLuaFile("gdisasters/shared/extensions/sh_patchs-bounds.lua")
AddCSLuaFile("gdisasters/shared/game/convars/sh_main.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/sh_menu.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/sh_postspawn.lua")
AddCSLuaFile("gdisasters/shared/game/sh_water_physics.lua")
AddCSLuaFile("gdisasters/shared/game/sh_world_init.lua")
AddCSLuaFile("gdisasters/shared/game/sh_dnc.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/sh_process_gfx.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/sh_process_temp.lua")
AddCSLuaFile("gdisasters/shared/atmosphere/sh_main.lua")
AddCSLuaFile("gdisasters/shared/game/sh_decals.lua")


include("gdisasters/shared/shared_func/sh_main.lua")	
include("gdisasters/shared/shared_func/sh_netstrings.lua")
include("gdisasters/shared/extensions/sh_patchs-bounds.lua")
include("gdisasters/shared/game/sh_water_physics.lua")
include("gdisasters/shared/game/sh_world_init.lua")
include("gdisasters/shared/game/convars/sh_main.lua")
include("gdisasters/shared/game/sh_dnc.lua")
include("gdisasters/shared/player-npcs/sh_postspawn.lua")
include("gdisasters/shared/player-npcs/sh_menu.lua")
include("gdisasters/shared/game/sh_decals.lua")
include("gdisasters/shared/player-npcs/sh_process_gfx.lua")
include("gdisasters/shared/player-npcs/sh_process_temp.lua")
include("gdisasters/shared/atmosphere/sh_main.lua")