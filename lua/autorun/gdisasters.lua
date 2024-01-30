--class
gDisasters = {}
gDisasters.__index = gDisasters
gDisasters.Version = 0.43
gDisasters.WorkShopURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=2522900784"
gDisasters.WorkshopVersion = false

for _,v in pairs(engine.GetAddons()) do
	if v.downloaded and tonumber(v.wsid) == 2522900784 or v.title == "gDisasters Revived" then
		gDisasters.WorkshopVersion = true
		break
	end
end

print("Workshop Version == ".. tostring(gDisasters.WorkshopVersion))

--functions

local env_color = SERVER and Color(138,223,255) or Color(230,217,111)

function gDisasters:dump(o)
   	if type(o) == 'table' then
    	local s = '{ '
      	for k,v in pairs(o) do
      	   if type(k) ~= 'number' then k = '"'..k..'"' end
      	   s = s .. '['..k..'] = ' .. self:dump(v) .. ','
      	end
      	return s .. '} '
   	else
      	return tostring(o)
   	end
end

function gDisasters:is_done(x, y)
	if x == y then
		return true
	end
	return false
end

function gDisasters:Msg(...)
	local a = {...}
	table.insert(a, 1, env_color)
	local t = {}
	local last = 0
	for _, v in ipairs(a) do
		local cur = 0
		if type(v) == "string" then
			cur = 1
		elseif type(v) == "table" then
			cur = 2
		end
		if last == cur then
			if cur == 1 then
				t[#t] = t[#t] .. " " .. v
				break
			elseif cur == 2 then
				t[#t] = self:dump(v)
				break
			end
		end
		last = cur
		table.insert(t,v)
	end
	MsgC(Color(255,136,0),"[gDisasters] ",unpack( t ))
	MsgN()
end

function gDisasters:Warning( sMessage, bError )
	MsgC(Color(255,136,0),"[gDisasters]",Color(255,75,75)," [WARNING] ",env_color,sMessage,"\n")
	if bError then
		error(sMessage)
	end
end




--loading lua files

gDisasters:Msg("INCLUDING LUA FILES...")

gDisasters.root_Directory = "gdisasters"

function gDisasters:IncludeFile( File, directory )
	if string.StartWith(File, "_sv_") or string.StartWith(File, "sv_") then
		if SERVER then
			include( directory .. File )
			self:Msg( "SERVER INCLUDE: " .. File )
		end
	elseif string.StartWith(File, "_sh_") or string.StartWith(File, "sh_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			self:Msg( "SHARED ADDCS: " .. File )
		end
		include( directory .. File )
		self:Msg( "SHARED INCLUDE: " .. File )
	elseif string.StartWith(File, "_cl_") or string.StartWith(File, "cl_") then
		if SERVER then
			AddCSLuaFile( directory .. File )
			self:Msg( "CLIENT ADDCS: " .. File )
		elseif CLIENT then
			include( directory .. File )
			self:Msg( "CLIENT INCLUDE: " .. File )
		end
	end
end

function gDisasters:loadluafiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "LUA" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".lua" ) then
			self:IncludeFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		self:Msg( "Directory: " .. v )
		self:loadluafiles( directory .. v )
	end
end

gDisasters:loadluafiles( gDisasters.root_Directory )

gDisasters:Msg("FINISH")

--adding materials and sounds and models to client

if SERVER then

	gDisasters:Msg("DOWNLOADING BASIC...")

	gDisasters.root_Directory = "resource/localization"
	
	function gDisasters:AddResourceFile( File, directory )
		resource.AddSingleFile( directory .. File )
		self:Msg( "ADDING: " .. File )
	end

	function gDisasters:loadresourcefiles( directory )
		directory = directory .. "/"

		local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

		for _, v in ipairs( files ) do	
			if !string.EndsWith( v, ".png" ) and !string.EndsWith( v, ".vtf" ) then 
				self:AddResourceFile( v, directory )		
			end	
		end

		for _, v in ipairs( directories ) do
			self:Msg( "Directory: " .. v )
			self:loadresourcefiles( directory .. v )
		end
	end

	gDisasters:loadresourcefiles(gDisasters.root_Directory)

	if not gDisasters.WorkshopVersion then

		self:Msg("ADDING CONTENT FILE...")

		gDisasters.root_Directory = "materials"
		gDisasters.root_Directory2 = "sound/streams"
		gDisasters.root_Directory3 = "models/ramses/models"

		function gDisasters:AddResourceFile( File, directory )
			resource.AddSingleFile( directory .. File )
			self:Msg( "ADDING: " .. File )
		end

		function gDisasters:loadresourcefiles( directory )
			directory = directory .. "/"

			local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

			for _, v in ipairs( files ) do	
				if !string.EndsWith( v, ".png" ) and !string.EndsWith( v, ".vtf" ) then 
					self:AddResourceFile( v, directory )
				end
			end

			for _, v in ipairs( directories ) do
				self:Msg( "Directory: " .. v )
				self:loadresourcefiles( directory .. v )
			end
		end

		gDisasters:loadresourcefiles(gDisasters.root_Directory)
		gDisasters:loadresourcefiles(gDisasters.root_Directory2)
		gDisasters:loadresourcefiles(gDisasters.root_Directory3)

		gDisasters:Msg("ADDED CONTENT FILE")
		
	else
		gDisasters:Msg("ADDING CONTENT FILE FROM WORKSHOP...")
		resource.AddWorkshop(string.match(gDisasters.WorkShopURL, "%d+$"))
		gDisasters:Msg("ADDED CONTENT FILE FROM WORKSHOP")
	end

	gDisasters:Msg("FINISH")
end

--loading decals

gDisasters:Msg("LOADING DECALS...")

gDisasters.root_Directory = "materials/decals/gdisasters" 

local snowtable = {}
local sandtable = {}
local icetable = {}

function gDisasters:AddDecalsFile( Key, File, directory)
	local name = File:match("(.+)%..+$")
	directory = directory:match("materials/(.-)/") .. "/gdisasters/" .. name

	if string.StartWith(File, "_ice") then
		table.insert(icetable,  directory)
	elseif string.StartWith(File, "_sand") then
		table.insert(sandtable,  directory)
	elseif string.StartWith(File, "_snow") then
		table.insert(snowtable,  directory)
	else	
		self:Msg( "ADDING: " .. name .. " DECAL")
		game.AddDecal(name, directory)
		self:Msg( "ADDED")
	end

	if self:is_done(Key, 21) then
		
		self:Msg( "ADDING ICE DECALS")
		game.AddDecal( "ice", icetable)
		self:Msg( "ADDED ICE DECALS")

		self:Msg( "ADDING SAND DECALS")
		game.AddDecal( "sand", sandtable)
		self:Msg( "ADDED SAND DECALS")

		self:Msg( "ADDING SNOW DECALS")
		game.AddDecal( "snow", snowtable)
		self:Msg( "ADDED SNOW DECALS")
	end
	
	
end

function gDisasters:loaddecalsfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for k, v in ipairs( files ) do
		if !string.EndsWith( v, ".png" ) and !string.EndsWith( v, ".vtf" ) then 
			self:AddDecalsFile( k, v, directory)
		end
	end

	for _, v in ipairs( directories ) do
		self:Msg( "Directory: " .. v )
		self:loaddecalsfiles( directory .. v )
	end
end

gDisasters:loaddecalsfiles(gDisasters.root_Directory)

gDisasters:Msg("FINISH")

--adding particles

if CLIENT then

	gDisasters:Msg("LOADING PARTICLES...")

	gDisasters.root_Directory = "particles/gdisasters"

	function gDisasters:AddParticleFile( File, directory )
		game.AddParticles( directory .. File )
		self:Msg( "ADDING: " .. File )
	end

	function gDisasters:loadparticlesfiles( directory )
		directory = directory .. "/"

		local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

		for _, v in ipairs( files ) do
			if string.EndsWith( v, ".pcf" ) then
				self:AddParticleFile( v, directory )
			end
		end

		for _, v in ipairs( directories ) do
			self:Msg( "Directory: " .. v )
			self:loadparticlesfiles( directory .. v )
		end
	end

	gDisasters:loadparticlesfiles( gDisasters.root_Directory)

	gDisasters:Msg("FINISH")
end

--prechaching the particles

gDisasters:Msg("PRECHACHING PARTICLES...")

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

PrecacheParticleSystem("sumerged_volcano_main")
PrecacheParticleSystem("sumerged_bigvolcano_main")


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
PrecacheParticleSystem("har_landspout")
PrecacheParticleSystem("har_landspout_nocloud")
PrecacheParticleSystem("har_snownado")
PrecacheParticleSystem("har_snownado_nocloud")
PrecacheParticleSystem("har_icenado")
PrecacheParticleSystem("har_icenado_nocloud")
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

gDisasters:Msg("FINISH")

--adding new hook
gDisasters:Msg("ADDING CUSTOM HOOK")
timer.Simple(1,function()
    hook.Run("PostInit")
end)

timer.Create("Think2", 0.5, 0, function()
    hook.Run("Think2")
end)

timer.Create("Think3", 1, 0, function()
    hook.Run("Think3")
end)
gDisasters:Msg("ADDED CUSTOM HOOK")