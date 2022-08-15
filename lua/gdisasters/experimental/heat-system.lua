CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars

function start() 
	if GetConVar("gdisasters_HeatSytem_enabled"):GetInt() == 0 then return end

	local floorheat = 0 + 1
	local airheat =  100
	local upperairheat =  50
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

	print(airheat, floorheat, upperairheat)

	if floorheat > airheat and airheat - upperairheat > 1000 then
		local airheat = airheat + 1
		local floorheat = floorheat - airheat
		EF = ents.Create( tornado[math.random( 1, #tornado )])
		if S37K_mapbounds == nil or table.IsEmpty(S37K_mapbounds) then
			EF:SetPos(Vector(math.random(-10000,10000),math.random(-10000,10000),5000))
		else
			local stormtable = S37K_mapbounds[1]
			EF:SetPos( Vector(math.random(stormtable.negativeX,stormtable.positiveX),math.random(stormtable.negativeY,stormtable.positiveY),stormtable.skyZ) )
		end
		EF:Spawn()
	elseif floorheat < airheat and airheat - upperairheat > 1000 then
		local wea = ents.FindByClass("gd_w1_lightbreeze")
		wea:Spawn()
		wea:Activate()
	else

	end

end

hook.Add("heatSystem", "experimental", start)