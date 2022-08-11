AddCSLuaFile()

CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars (Settings)

if (SERVER) then

function Data(ents, temp, wind, windDir, humidity, Pressure) -- Data Management
    
	if GetConVar("gdisasters_HeatSytem_enabled"):GetInt() == 0 then return end
	
	SetGlobalFloat("gDisasters_Temperature", temp) --Temperature
	SetGlobalFloat("gDisasters_Pressure", Pressure)
	SetGlobalFloat("gDisasters_Humidity", humidity)
	SetGlobalFloat("gDisasters_Wind", wind)
    
	local precipitation = {		--Precipitation Amount
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
		"gd_w3_blizzard",
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

	

	precipitation_cold = {
		"gd_w1_citysnow",
		"gd_w2_coldwave",
		"gd_w1_snow",
		"gd_w3_blizzard",
		"gd_w3_icestorm",
		"gd_w6_neptune",
		"gd_w2_heavysnow"

	}

	precipitation_hot = {


	}

	prep = precipitation[math.random(1, #precipitation)]
	prep_cold = precipitation_cold[math.random(1, #precipitation_cold)]

	if temp <= 0 then
		prep_cold:Spawn()
		prep_cold:Activate()
		prep_cold:SetPos(ents:GetPos())
		
	elseif temp >= 0 then

	end

end

function GenerateEnts()  -- Generate Grid Of Entites
	local center = getMapCenterPos()
	local centerfloor = getMapCenterFloorPos()
	local bound = getMapBounds()
    local grid = debugoverlay.Grid(vector(center.x, center.y, center.z)) -- Draw Grid

    local ents = ents.Create("prop_detail")
	ents:SetPos(Vector(bound[1].x + 1, bound[1].y + 1, centerfloor.z))
	ents:SetModel("models/props_junk/PopCan01a.mdl") -- Set HL2 Popcan Model
	ents:SetNoDraw(false)
    ents:Spawn()
    ents:Activate()
	
		
	Data(ents, math.random(-100, 100), math.random(0, 1000), math.random(Vector(0,0,0), Vector(360, 360, 0)), math.random(0, 100))


end
hook.Add("heatSystem", "experimental", GenerateEnts)

end

if (CLIENT) then

end