AddCSLuaFile("autorun/gdisasters_load.lua")
AddCSLuaFile("autorun/precached_particles.lua")


AddCSLuaFile("gdisasters/shared/extensions/sh_patchs-bounds.lua")
AddCSLuaFile("gdisasters/shared/game/convars/sh_main.lua")
AddCSLuaFile("gdisasters/shared/game/sh_world_init.lua")
AddCSLuaFile("gdisasters/shared/game/sh_decals.lua")
AddCSLuaFile("gdisasters/shared/shared_func/sh_main.lua")

include("gdisasters/shared/shared_func/sh_main.lua")
include("gdisasters/shared/extensions/sh_patchs-bounds.lua")
include("gdisasters/shared/game/sh_world_init.lua")
include("gdisasters/shared/game/convars/sh_main.lua")
include("gdisasters/shared/game/sh_decals.lua")




if (SERVER) then

	AddCSLuaFile("gdisasters/server/shared_func/sv_main.lua")
	AddCSLuaFile("gdisasters/server/shared_func/sv_netstrings.lua")
	AddCSLuaFile("gdisasters/server/game/antilag/sv_main.lua")
	AddCSLuaFile("gdisasters/server/player-npcs/sv_process_oxygen.lua")
	AddCSLuaFile("gdisasters/server/game/sv_autospawn.lua")
	AddCSLuaFile("gdisasters/server/game/sv_damagetypes.lua")
	AddCSLuaFile("gdisasters/server/game/sv_water_physics.lua")
	AddCSLuaFile("gdisasters/server/game/sv_world_init.lua")
	AddCSLuaFile("gdisasters/server/player-npcs/sv_postspawn.lua")
	AddCSLuaFile("gdisasters/server/player-npcs/sv_process_gfx.lua")
	AddCSLuaFile("gdisasters/server/player-npcs/sv_process_temp.lua")
	AddCSLuaFile("gdisasters/server/atmosphere/sv_main.lua")
	AddCSLuaFile("gdisasters/shared/extensions/sv_patchs-bounds.lua")

	include("gdisasters/shared/extensions/sv_patchs-bounds.lua")
	include("gdisasters/server/shared_func/sv_main.lua")
	include("gdisasters/server/shared_func/sv_netstrings.lua")
	include("gdisasters/server/atmosphere/sv_main.lua")
	include("gdisasters/server/player-npcs/sv_process_gfx.lua")
	include("gdisasters/server/player-npcs/sv_process_temp.lua")
	include("gdisasters/server/player-npcs/sv_postspawn.lua")
	include("gdisasters/server/game/antilag/sv_main.lua")
	include("gdisasters/server/player-npcs/sv_process_oxygen.lua")
	include("gdisasters/server/game/sv_autospawn.lua")
	include("gdisasters/server/game/sv_damagetypes.lua")
	include("gdisasters/server/game/sv_water_physics.lua")
	include("gdisasters/server/game/sv_world_init.lua")
	
end

if (CLIENT) then	

	AddCSLuaFile("autorun/client/garrys_particles.lua")

	AddCSLuaFile("gdisasters/client/shared_func/cl_main.lua")
	AddCSLuaFile("gdisasters/client/shared_func/cl_netstrings.lua")
	AddCSLuaFile("gdisasters/client/spawnlist/menu/cl_main.lua")
	AddCSLuaFile("gdisasters/client/spawnlist/menu/cl_populate.lua")
	AddCSLuaFile("gdisasters/client/toolmenu/cl_menu.lua")
	AddCSLuaFile("gdisasters/client/hud/cl_main.lua")
	AddCSLuaFile("gdisasters/client/player-npcs/cl_postspawn.lua")
	AddCSLuaFile("gdisasters/client/player-npcs/sv_process_gfx.lua")
	AddCSLuaFile("gdisasters/client/player-npcs/sv_process_temp.lua")
	AddCSLuaFile("gdisasters/client/atmosphere/cl_main.lua")
	AddCSLuaFile("gdisasters/client/game/cl_world_init.lua")

	include("gdisasters/client/game/cl_world_init.lua")
	include("gdisasters/client/atmosphere/cl_main.lua")
	include("gdisasters/client/shared_func/cl_main.lua")
	include("gdisasters/client/shared_func/cl_netstrings.lua")
	include("gdisasters/client/player-npcs/cl_process_gfx.lua")
	include("gdisasters/client/player-npcs/cl_process_temp.lua")
	include("gdisasters/client/player-npcs/cl_postspawn.lua")
	include("gdisasters/client/spawnlist/menu/cl_main.lua")
	include("gdisasters/client/spawnlist/menu/cl_populate.lua")
	include("gdisasters/client/toolmenu/cl_menu.lua")
	include("gdisasters/client/hud/cl_main.lua")
end