gDisasters = {}
gDisasters.CachedExists     = {}
gDisasters.Cached         = {}
gDisasters.DayNightSystem        = {}
gDisasters.DayNightSystem.InternalVars = {}
gDisasters.Game                  = {}
gDisasters.Version = 0.33
gDisasters.WorkshopURL = "https://steamcommunity.com/sharedfiles/filedetails/changelog/2522900784"
gDisasters.WorkshopVersion = false

--loading lua files

print("[GDISASTERS] INCLUDING LUA FILES...")

local root_Directory = "gdisasters"

local function AddFile( File, directory )
	if string.StartWith(File, "_sv_") or string.StartWith(File, "sv_") then
		if SERVER then
			include( directory .. File )
			print( "[GDISASTERS] SERVER INCLUDE: " .. File )
		end
	elseif string.StartWith(File, "_sh_") or string.StartWith(File, "sh_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[GDISASTERS] SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		print( "[GDISASTERS] SHARED INCLUDE: " .. File )
	elseif string.StartWith(File, "_cl_") or string.StartWith(File, "cl_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			print( "[GDISASTERS] CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			print( "[GDISASTERS] CLIENT INCLUDE: " .. File )
		end
	end
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( root_Directory )

print("[GDISASTERS] FINISH")

--loading decals

print("[GDISASTERS] LOADING DECALS...")

local root_Directory = "materials/decals" 

local function AddDecalsFile( File, directory )
	local name = File:match("(.+)%..+$")
	local directory_fixed = directory:match("materials/(.-)/")

	game.AddDecal( name, directory_fixed .. "/" .. name )
	print( "[GDISASTERS] ADDING: " .. File )
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do

		AddDecalsFile( v, directory )

	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles(root_Directory)

print("[GDISASTERS] FINISH")

--adding materials and sounds and models to client

if SERVER then

	if not gDisasters.WorkshopVersion then
		print("[GDISASTERS] DOWNLOADING BASIC...")

		local root_Directory = "materials"
		local root_Directory2 = "sound/streams"
		local root_Directory3 = "models/ramses/models"

		local function AddResourceFile( File, directory )
			resource.AddSingleFile( directory .. File )
			print( "[GDISASTERS] ADDING: " .. File )
		end

		local function loadfiles( directory )
			directory = directory .. "/"

			local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

			for _, v in ipairs( files ) do	
				if string.EndsWith( v, ".png" ) then return end
				AddResourceFile( v, directory )
			end

			for _, v in ipairs( directories ) do
				print( "[GDISASTERS] Directory: " .. v )
				loadfiles( directory .. v )
			end
		end

		loadfiles(root_Directory)
		loadfiles(root_Directory2)
		loadfiles(root_Directory3)

		print("[GDISASTERS] FINISH")
	else
		resource.AddWorkshop(string.match(gDisasters.WorkShopURL, "%d+$"))
		print("[GDISASTERS] ADDED CONTENT FILE FROM WORKSHOP")
	end
end

--adding particles

if CLIENT then

	print("[GDISASTERS] LOADING PARTICLES...")

	local root_Directory = "particles/gdisasters"

	local function AddParticleFile( File, directory )
		game.AddParticles( directory .. File )
		print( "[GDISASTERS] ADDING: " .. File )
	end

	local function loadfiles( directory )
		directory = directory .. "/"

		local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

		for _, v in ipairs( files ) do
			if string.EndsWith( v, ".pcf" ) then
				AddParticleFile( v, directory )
			end
		end

		for _, v in ipairs( directories ) do
			print( "[GDISASTERS] Directory: " .. v )
			loadfiles( directory .. v )
		end
	end

	loadfiles( root_Directory)

	print("[GDISASTERS] FINISH")
end

--prechaching the particles

print("[GDISASTERS] Prechaching particles...")

PrecacheParticleSystem("localized_dust_effect")
PrecacheParticleSystem("localized_sand_effect")
PrecacheParticleSystem("localized_rain_effect")
PrecacheParticleSystem("localized_light_rain_effect")
PrecacheParticleSystem("localized_extreme_rain_effect")
PrecacheParticleSystem("localized_ash_effect")
PrecacheParticleSystem("darkness_approaches_main")
PrecacheParticleSystem("localized_snow_effect")
PrecacheParticleSystem("localized_heavy_snow_effect")
PrecacheParticleSystem("localized_sleet_effect")
PrecacheParticleSystem("localized_acid_rain_effect")
PrecacheParticleSystem("localized_ash_effect_2")
PrecacheParticleSystem("heatwave_ripple_01_main")
PrecacheParticleSystem("hail_character_effect_01_main")
PrecacheParticleSystem("meteorite_burnup_trail_main")
PrecacheParticleSystem("meteor_explosion_main_ground")
PrecacheParticleSystem("meteorite_explosion_main_ground")
PrecacheParticleSystem("meteor_burnup_main")
PrecacheParticleSystem("meteorite_skyripple")
PrecacheParticleSystem("tumbleweed_effect")
PrecacheParticleSystem("moderate_rain_effect")
PrecacheParticleSystem("shootingstar_burnup_main")
PrecacheParticleSystem("mini_firenado")
PrecacheParticleSystem("small_mini_firenado_hd_main")
PrecacheParticleSystem("localized_firestorm_effect")

PrecacheParticleSystem( "dryice_lowfog_crawler" )
PrecacheParticleSystem( "dryice_medfog_crawler" )
PrecacheParticleSystem( "dryice_deepfog_crawler" )
PrecacheParticleSystem( "dryice_fog_explosion" )
PrecacheParticleSystem( "dryice_melting" )

PrecacheParticleSystem("rain_ceiling_drops_effect")
PrecacheParticleSystem("rain_ceiling_drop_ground_splash")

PrecacheParticleSystem("downburst_light_rain_main")
PrecacheParticleSystem("downburst_medium_rain_main")
PrecacheParticleSystem("downburst_heavy_rain_main")

PrecacheParticleSystem("extreme_rain_splash_effect")
PrecacheParticleSystem("heavy_rain_splash_effect")
PrecacheParticleSystem("heavy_snow_ground_effect")
PrecacheParticleSystem("snow_ground_effect")
PrecacheParticleSystem("snow_gust_effect")
PrecacheParticleSystem("sleet_splash_effect")
PrecacheParticleSystem("rain_splash_effect")
PrecacheParticleSystem("light_rain_splash_a")
PrecacheParticleSystem("tumbleweed_effect")

PrecacheParticleSystem("water_huge")
PrecacheParticleSystem("water_medium")
PrecacheParticleSystem("water_small")
PrecacheParticleSystem("water_torpedo")

PrecacheParticleSystem("heatburst_air_compression_main")

PrecacheParticleSystem("neutron_star_magnetic_field_lines_main")
PrecacheParticleSystem("neutron_star_ray_main")
PrecacheParticleSystem("localized_blizzard_effect")
PrecacheParticleSystem("hail_character_effect_02_main")


-- character_effects.pcf
PrecacheParticleSystem("exhale")
PrecacheParticleSystem("vomit_main")
PrecacheParticleSystem("cough_ash")
PrecacheParticleSystem("sneeze_main")
PrecacheParticleSystem("sneeze_big_main")

-- gustnado
PrecacheParticleSystem("gustnado_01_main")
PrecacheParticleSystem("gustnado_02_main")
PrecacheParticleSystem("gustnado_03_main")
PrecacheParticleSystem("gustnado_04_main")
PrecacheParticleSystem("gustnado_05_main")
PrecacheParticleSystem("gustnado_06_main")

-- ef0
PrecacheParticleSystem("h_ef0")
PrecacheParticleSystem("temp_EF0")
PrecacheParticleSystem("t_ef0")
PrecacheParticleSystem("har_ef0")
PrecacheParticleSystem("t_tornado_EF0")
PrecacheParticleSystem("h1_EF0")
PrecacheParticleSystem("t_EF0_2")
PrecacheParticleSystem("t_EF0_wip")

-- ef1
PrecacheParticleSystem("h_ef1")
PrecacheParticleSystem("t_ef1")
PrecacheParticleSystem("temp_EF1")
PrecacheParticleSystem("temp_EF1_fix")
PrecacheParticleSystem("har_ef1")
PrecacheParticleSystem("t_tornado_EF1")
PrecacheParticleSystem("h1_EF1")


PrecacheParticleSystem("har_landspout")
PrecacheParticleSystem("har_landspout_nocloud")
PrecacheParticleSystem("har_snownado")
PrecacheParticleSystem("har_snownado_nocloud")
PrecacheParticleSystem("har_waterspout")
PrecacheParticleSystem("har_waterspout_nocloud")
PrecacheParticleSystem("alien_tornado")

-- ef2
PrecacheParticleSystem("h_ef2")
PrecacheParticleSystem("temp_EF2")
PrecacheParticleSystem("t_ef2")
PrecacheParticleSystem("har_ef2")
PrecacheParticleSystem("t_tornado_EF2")
PrecacheParticleSystem("h1_EF2")

-- ef3
PrecacheParticleSystem("h_ef3")
PrecacheParticleSystem("temp_EF3")
PrecacheParticleSystem("t_ef3")
PrecacheParticleSystem("har_ef3")
PrecacheParticleSystem("t_tornado_EF3")
PrecacheParticleSystem("h1_EF3")

-- ef4
PrecacheParticleSystem("h_ef4")
PrecacheParticleSystem("temp_EF4")
PrecacheParticleSystem("t_ef4")
PrecacheParticleSystem("har_ef4")
PrecacheParticleSystem("t_tornado_EF4")
PrecacheParticleSystem("h1_EF4")

-- ef5
PrecacheParticleSystem("h_ef5")
PrecacheParticleSystem("temp_EF5")
PrecacheParticleSystem("t_ef5")
PrecacheParticleSystem("har_ef5")
PrecacheParticleSystem("t_tornado_EF5")
PrecacheParticleSystem("h1_EF5")

-- ef6
PrecacheParticleSystem("martian_tornado")

-- ef7
PrecacheParticleSystem("f7_a")

-- firenadoes
PrecacheParticleSystem("small_mini_firenado_hd_main")
PrecacheParticleSystem("mini_firenado")
PrecacheParticleSystem("mini_firenado_hd_main")
PrecacheParticleSystem("firenado")
PrecacheParticleSystem("firenado_hd_main")
PrecacheParticleSystem("mega_firenado")

-- LIGHTNING 

PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_1")
PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_2")
PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_3")

PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_1_NON_GROUNDED")
PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_2_NON_GROUNDED")
PrecacheParticleSystem("LIGHTNING_STRIKE_BLUE_3_NON_GROUNDED")

PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_1")
PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_2")
PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_3")

PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_1_NON_GROUNDED")
PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_2_NON_GROUNDED")
PrecacheParticleSystem("LIGHTNING_STRIKE_PURPLE_3_NON_GROUNDED")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_2")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_3")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_4")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_5")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_6")
PrecacheParticleSystem("LIGHTNING_STRIKE_EXPLOSION_MAIN_7")
PrecacheParticleSystem("ball_lightning_arc_main")--
PrecacheParticleSystem("shootingstar_burnup_main")

-- fire
PrecacheParticleSystem("fire_burning_main")
PrecacheParticleSystem("darkness_arriving_main")

-- earthquake

PrecacheParticleSystem("earthquake_player_ground_rocks")
PrecacheParticleSystem("earthquake_player_ground_dust")
PrecacheParticleSystem("earthquake_player_ground_debris")
PrecacheParticleSystem("earthquake_swave_main")
PrecacheParticleSystem("earthquake_swave_refract")


-- renderfog 
PrecacheParticleSystem("renderfog_main_HQ")

-- tsunami
PrecacheParticleSystem("splash_main")
PrecacheParticleSystem("tsunami_splash_effect_r200")
PrecacheParticleSystem("tsunami_splash_effect_r300")--tsunami_splash_effect_r200
PrecacheParticleSystem("tsunami_splash_effect_r400")
PrecacheParticleSystem("tsunami_splash_effect_r500")

--black hole
PrecacheParticleSystem("micro_blackhole_effect")

print("[GDISASTERS] finish")

--adding new hook

timer.Simple(1,function()
	print("[GDISASTERS] adding custom hook")
    hook.Run("PostInit")
	print("[GDISASTERS] added custom hook")
end)