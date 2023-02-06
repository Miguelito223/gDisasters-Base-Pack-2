if (SERVER) then

	AddCSLuaFile("gdisasters/server/player-npcs/process_oxygen.lua")
	AddCSLuaFile("gdisasters/server/game/autospawn.lua")
	AddCSLuaFile("gdisasters/server/game/damagetypes.lua")

	include("gdisasters/server/player-npcs/process_oxygen.lua")
	include("gdisasters/server/game/autospawn.lua")
	include("gdisasters/server/game/damagetypes.lua")
	include("gdisasters/server/game/antilag/main.lua")
	
end

if (CLIENT) then	

	AddCSLuaFile("autorun/client/garrys_particles.lua")

	AddCSLuaFile("gdisasters/client/spawnlist/menu/main.lua")
	AddCSLuaFile("gdisasters/client/spawnlist/menu/populate.lua")
	AddCSLuaFile("gdisasters/client/hud/main.lua")

	include("gdisasters/client/spawnlist/menu/main.lua")
	include("gdisasters/client/spawnlist/menu/populate.lua")
	include("gdisasters/client/hud/main.lua")
end

	
AddCSLuaFile("autorun/gdisasters_load.lua")
AddCSLuaFile("autorun/precached_particles.lua")

AddCSLuaFile("gdisasters/shared/shared_func/main.lua")
AddCSLuaFile("gdisasters/shared/shared_func/netstrings.lua")
AddCSLuaFile("gdisasters/shared/extensions/patchs-bounds.lua")
AddCSLuaFile("gdisasters/shared/game/convars/main.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/menu.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/postspawn.lua")
AddCSLuaFile("gdisasters/shared/game/water_physics.lua")
AddCSLuaFile("gdisasters/shared/game/world_init.lua")
AddCSLuaFile("gdisasters/shared/game/dnc.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/process_gfx.lua")
AddCSLuaFile("gdisasters/shared/player-npcs/process_temp.lua")
AddCSLuaFile("gdisasters/shared/atmosphere/main.lua")
AddCSLuaFile("gdisasters/shared/game/decals.lua")


include("gdisasters/shared/shared_func/main.lua")	
include("gdisasters/shared/shared_func/netstrings.lua")
include("gdisasters/shared/extensions/patchs-bounds.lua")
include("gdisasters/shared/game/water_physics.lua")
include("gdisasters/shared/game/world_init.lua")
include("gdisasters/shared/game/convars/main.lua")
include("gdisasters/shared/game/dnc.lua")
include("gdisasters/shared/player-npcs/postspawn.lua")
include("gdisasters/shared/player-npcs/menu.lua")
include("gdisasters/shared/game/decals.lua")
include("gdisasters/shared/player-npcs/process_gfx.lua")
include("gdisasters/shared/player-npcs/process_temp.lua")
include("gdisasters/shared/atmosphere/main.lua")