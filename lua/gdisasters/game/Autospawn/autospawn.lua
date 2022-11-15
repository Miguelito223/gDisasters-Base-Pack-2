if (SERVER) then

local function Autospawn_Timer()
	local recent = false

	local function Autospawn()
		if GetConVar("gdisasters_autospawn_type"):GetString() == "Tornado" then
			recent = true
			local tornado = {
			"gd_d3_ef0", 
			"gd_d4_ef1", 
			"gd_d4_landspout", 
			"gd_d5_ef2", 
			"gd_d6_ef3", 
			"gd_d7_ef4", 
			"gd_d8_ef5", 
			"gd_d9_ef6", 
			"gd_d10_ef7"
			}

			local EF = ents.Create(table.Random(tornado))
			local map_bounds = getMapBounds()
			local map_floorcenter = getMapCenterFloorPos()

			if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
				EF:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
			else
				local stormtable = S37K_mapbounds[1]
				EF:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
			end
			
			EF:Spawn()
			EF:Activate()

		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Disasters" then
			recent = true
			local disasters = {
				"gd_d1_rs1eq", 
				"gd_d2_rs2eq", 
				"gd_d3_rs3eq", 
				"gd_d4_rs4eq", 
				"gd_d5_rs5eq", 
				"gd_d6_rs6eq", 
				"gd_d7_rs7eq", 
				"gd_d8_rs8eq", 
				"gd_d9_rs9eq", 
				"gd_d10_rs10eq", 
				"gd_d10_meteorshower", 
				"gd_d7_tsunami", 
				"gd_d10_meteoriteshower", 
				"gd_d6_cryoshower", 
				"gd_d10_lavabombshower", 
				"gd_d8_volcano", 
				"gd_d5_maturevolcano", 
				"gd_d4_volcano",
				"gd_d2_minivolcano",
				"gd_d3_lightningstorm", 
				"gd_d2_flashflood", 
				"gd_d2_locust_apoc", 
    	    	"gd_d2_planttakeover", 
    	    	"gd_d1_geyser",   
    	    	"gd_d10_chicxuclub", 
    	    	"gd_d10_blackhole", 
    	    	"gd_d10_martiantornado", 
    	    	"gd_d10_neutron_star",
    	    	"gd_d3_ef0", 
    	    	"gd_d4_ef1", 
    	    	"gd_d4_landspout", 
    	    	"gd_d5_ef2", 
    	    	"gd_d6_ef3", 
    	    	"gd_d7_ef4", 
    	    	"gd_d8_ef5", 
    	    	"gd_d9_ef6",
    	    	"gd_d6_zombieapoc",
    	    	"gd_d10_ef7",
    	    	"gd_d9_whitehole",
    	    	"gd_d2_minivolcano",
    	    	"gd_d2_blackiceover",
    	    	"gd_d2_gustnado",
    	    	"gd_d3_ball_lightning",
    	    	"gd_d10_mfirenado",
    	    	"gd_d5_mfirenado",
    	    	"gd_d2_mfirenado",
    	    	"gd_d1_dustdevil",
    	    	"gd_d1_steamdevil",
    	    	"gd_d3_landslide",
    	    	"gd_d2_waterspout",
    	    	"gd_d7_lavaflood",
    	    	"gd_d8_combineinv",
    	    	"gd_d8_lavatsunami"
			}

			local dis = ents.Create(table.Random(disasters))
			local map_bounds = getMapBounds()
			local map_floorcenter = getMapCenterFloorPos()

			for k, v in pairs(ents.FindByClass("gd_d*")) do
				dis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), map_floorcenter.z))
			end
			for k, v in pairs(ents.FindByClass("gd_d*_ef*")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					dis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					dis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d4_landspout")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					dis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					dis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d2_waterspout")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					dis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					dis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d*_mfirenado")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					dis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					dis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end

			dis:Spawn()
			dis:Activate()
			print("the disaster that is happening now: " .. tostring(dis) .. " Pos: " .. tostring(dis:GetPos()) )
			timer.Simple(GetConVar( "gdisasters_autospawn_timer" ):GetInt(), function()
				if dis:IsValid() then dis:Remove() end
			end)
		
		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Weather" then
			recent = true
			local weather = {
				"gd_w1_lightbreeze", 
				"gd_w2_mildbreeze", 
				"gd_w3_strongbreeze", 
				"gd_w4_intensebreeze", 
				"gd_w5_veryintensebreeze", 
				"gd_w6_beaufort10", 
				"gd_w2_hailstorm", 
				"gd_w1_catonehurricane", 
				"gd_w2_cattwohurricane", 
				"gd_w3_catthreehurricane", 
				"gd_w4_catfourhurricane", 
				"gd_w5_catfivehurricane", 
				"gd_w6_catsixhurricane", 
				"gd_w1_shootingstarshower", 
				"gd_w1_duststorm",  
				"gd_w1_snow",  
				"gd_w1_heavyfog", 
				"gd_w1_tropicalstorm", 
				"gd_w1_lightrain", 
				"gd_w1_tropicaldepression", 
				"gd_w1_sleet",
				"gd_w1_sandstorm",
				"gd_w1_cumu_cldy",
				"gd_w2_smog",
				"gd_w2_thundersnow",
				"gd_w2_shelfcloud",
				"gd_w2_heatwave",
				"gd_w2_thunderstorm",
				"gd_w2_freezingrain",
				"gd_w2_heavyrain",
				"gd_w2_acidrain",	
				"gd_w2_volcano_ash",
				"gd_w2_heavysnow",		
				"gd_w2_coldwave",
				"gd_w3_heavyashstorm",
				"gd_w3_major_hailstorm",
				"gd_w3_heatburst",
				"gd_w3_extremeheavyrain",
				"gd_w2_blizzard",
				"gd_w3_icestorm",
				"gd_w4_heavyacidrain",
				"gd_w5_microburst",
				"gd_w6_downburst",
				"gd_w5_macroburst",
				"gd_w6_martianduststorm",
				"gd_w6_martiansnow",
				"gd_w7_solarray",
				"gd_w4_growingstorm",
				"gd_w6_freezeray", 
				"gd_w3_drought",
				"gd_w1_citysnow",
				"gd_w2_chinese_smog",
				"gd_w3_heavythunderstorm",
				"gd_w1_highpressure_sys",
				"gd_w2_lowpressure_sys",
				"gd_w3_hurricanic_lowpressure_sys",
				"gd_d5_silenthill",
				"gd_w4_dryline",
				"gd_w4_derecho",
				"gd_w4_strong_coldfront",
				"gd_w4_strong_occludedfront",
				"gd_w4_strong_warmfront",
				"gd_w4_severethunderstorm",
				"gd_w3_drythunderstorm",
				"gd_w2_stationaryfront",
				"gd_w2_haboob",
				"gd_w5_pyrocum",
				"gd_w6_neptune",
				"gd_w6_redspot"
			}

			local wea = ents.Create(table.Random(weather))
			local map_bounds = getMapBounds()
			local map_floorcenter = getMapCenterFloorPos()

			if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
				wea:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
			else
				local stormtable = S37K_mapbounds[1]
				wea:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
			end

			wea:Spawn()
			wea:Activate()
			print("the weather that is happening now: " .. tostring(wea) .. " Pos: " .. tostring(wea:GetPos()) )
			timer.Simple(GetConVar( "gdisasters_autospawn_timer" ):GetInt(), function()
				if wea:IsValid() then wea:Remove() end
			end)

		elseif GetConVar("gdisasters_autospawn_type"):GetString() == "Weather/Disasters" then
			recent = true
			local weadisas = {
				"gd_w1_lightbreeze", 
				"gd_w2_mildbreeze", 
				"gd_w3_strongbreeze", 
				"gd_w4_intensebreeze", 
				"gd_w5_veryintensebreeze", 
				"gd_w6_beaufort10", 
				"gd_w2_hailstorm", 
				"gd_w1_catonehurricane", 
				"gd_w2_cattwohurricane", 
				"gd_w3_catthreehurricane", 
				"gd_w4_catfourhurricane", 
				"gd_w5_catfivehurricane", 
				"gd_w6_catsixhurricane", 
				"gd_w1_shootingstarshower", 
				"gd_w1_duststorm",  
				"gd_w1_snow",  
				"gd_w1_heavyfog", 
				"gd_w1_tropicalstorm", 
				"gd_w1_lightrain", 
				"gd_w1_tropicaldepression", 
				"gd_w1_sleet",
				"gd_w1_sandstorm",
				"gd_w1_cumu_cldy",
				"gd_w2_smog",
				"gd_w2_thundersnow",
				"gd_w2_shelfcloud",
				"gd_w2_heatwave",
				"gd_w2_thunderstorm",
				"gd_w2_freezingrain",
				"gd_w2_heavyrain",
				"gd_w2_acidrain",	
				"gd_w2_volcano_ash",
				"gd_w2_heavysnow",		
				"gd_w2_coldwave",
				"gd_w3_heavyashstorm",
				"gd_w3_major_hailstorm",
				"gd_w3_heatburst",
				"gd_w3_extremeheavyrain",
				"gd_w2_blizzard",
				"gd_w3_icestorm",
				"gd_w4_heavyacidrain",
				"gd_w5_microburst",
				"gd_w6_downburst",
				"gd_w5_macroburst",
				"gd_w6_martianduststorm",
				"gd_w6_martiansnow",
				"gd_w7_solarray",
				"gd_w5_weather",
				"gd_w6_freezeray", 
				"gd_w3_drought",
				"gd_w1_citysnow",
				"gd_w2_chinese_smog",
				"gd_w3_heavythunderstorm",
				"gd_w1_highpressure_sys",
				"gd_w2_lowpressure_sys",
				"gd_w3_hurricanic_lowpressure_sys",
				"gd_w4_dryline",
				"gd_w4_derecho",
				"gd_w4_strong_coldfront",
				"gd_w4_strong_occludedfront",
				"gd_w4_strong_warmfront",
				"gd_w4_severethunderstorm",
				"gd_w3_drythunderstorm",
				"gd_w2_stationaryfront",
				"gd_d5_silenthill",
				"gd_w2_haboob",
				"gd_w5_pyrocum",
				"gd_w6_neptune",
				"gd_w6_redspot",
				"gd_d1_rs1eq", 
				"gd_d2_rs2eq", 
				"gd_d3_rs3eq", 
				"gd_d4_rs4eq", 
				"gd_d5_rs5eq", 
				"gd_d6_rs6eq", 
				"gd_d7_rs7eq", 
				"gd_d8_rs8eq", 
				"gd_d9_rs9eq", 
				"gd_d10_rs10eq", 
				"gd_d10_meteorshower", 
				"gd_d7_tsunami",  
				"gd_d10_meteoriteshower", 
				"gd_d6_cryoshower", 
				"gd_d10_lavabombshower", 
				"gd_d8_volcano", 
				"gd_d5_maturevolcano", 
				"gd_d4_volcano",
				"gd_d2_minivolcano",
				"gd_d3_lightningstorm", 
				"gd_d2_flashflood", 
				"gd_d2_locust_apoc", 
				"gd_d2_planttakeover", 
				"gd_d1_geyser",   
				"gd_d10_chicxuclub", 
				"gd_d10_blackhole", 
				"gd_d10_martiantornado", 
				"gd_d10_neutron_star",
				"gd_d3_ef0", 
				"gd_d4_ef1", 
				"gd_d4_landspout", 
				"gd_d5_ef2", 
				"gd_d6_ef3", 
				"gd_d7_ef4", 
				"gd_d8_ef5", 
				"gd_d9_ef6",
				"gd_d6_zombieapoc",
				"gd_d10_ef7",
				"gd_d9_whitehole",
				"gd_d2_minivolcano",
				"gd_d2_blackiceover",
				"gd_d2_gustnado",
				"gd_d3_ball_lightning",
				"gd_d10_mfirenado",
				"gd_d5_mfirenado",
				"gd_d2_mfirenado",
				"gd_d1_dustdevil",
				"gd_d1_steamdevil",
				"gd_d3_landslide",
				"gd_d2_waterspout",
				"gd_d7_lavaflood",
				"gd_d8_combineinv",
				"gd_d8_lavatsunami"
			}

			local weadis = ents.Create(table.Random(weadisas))
			local map_bounds = getMapBounds()
			local map_floorcenter = getMapCenterFloorPos()

			for k, v in pairs(ents.FindByClass("gd_d*")) do
				weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), map_floorcenter.z))
			end
			for k, v in pairs(ents.FindByClass("gd_w*")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					weadis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d*_ef*")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					weadis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d4_landspout")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					weadis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d2_waterspout")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					weadis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end
			for k, v in pairs(ents.FindByClass("gd_d*_mfirenado")) do
				if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
					weadis:SetPos(Vector(math.random(map_bounds[1].x,map_bounds[2].x),math.random(map_bounds[1].y,map_bounds[2].y), 4500))
				else
					local stormtable = S37K_mapbounds[1]
					weadis:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
				end
			end

			weadis:Spawn()
			weadis:Activate()
			
			print("the weather or disaster that is happening now: " .. tostring(weadis) .. " Pos: " .. tostring(weadis:GetPos()))
			
			timer.Simple(GetConVar( "gdisasters_autospawn_timer" ):GetInt(), function()
				if weadis:IsValid() then weadis:Remove() end
			end)
		end
	end

	timer.Create( "Autospawn_Timer", GetConVar( "gdisasters_autospawn_timer" ):GetInt(), 0, function()
		if GetConVar("gdisasters_autospawn_enable"):GetInt() >= 1 then 
			if IsMapRegistered() == true and S37K_mapbounds ~= nil or table.IsEmpty(S37K_mapbounds) == false then 
				if math.random(0,GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt()) == GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt() then
					if recent then recent = false return end
					Autospawn()
				end
			elseif IsMapRegistered() == false and S37K_mapbounds ~= nil or table.IsEmpty(S37K_mapbounds) == false then
				if math.random(0,GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt()) == GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt() then
					if recent then recent = false return end
					Autospawn()
				end
			elseif IsMapRegistered() == true and S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) == true then
				if math.random(0,GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt()) == GetConVar( "gdisasters_autospawn_spawn_chance" ):GetInt() then
					if recent then recent = false return end
					Autospawn()
				end
			else
				for k, v in pairs(player.GetAll()) do 
					v:ChatPrint("This map is incompatible with this addon! Tell the addon owner about this as soon as possible and change to gm_flatgrass or construct.") 
				end 
				return 
			end
		end
	end
	)

end
hook.Add( "Initialize", "gDisasters_Autospawn", Autospawn_Timer)

local function Removemaptornados()
	if GetConVar('gdisasters_getridmaptor'):GetInt() == 1 then
		for k,v in pairs(ents.FindByClass("func_tracktrain", "func_tanktrain")) do
			v:Remove()
		end
	end
end

hook.Add("InitPostEntity","Removemaptornados", Removemaptornados)
hook.Add("PostCleanupMap","ReRemovemaptornados", Removemaptornados)
	
end