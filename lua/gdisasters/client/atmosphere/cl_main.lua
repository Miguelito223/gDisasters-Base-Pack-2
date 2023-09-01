function Atmosphere()
	WindControl()
end
hook.Add("Think", "atmosphericLoop", Atmosphere)

function WindControl()
	if LocalPlayer().gDisasters == nil then return end
	if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
	
	local local_wind    = LocalPlayer():GetNWFloat("LocalWind")
	local outside_fac   = LocalPlayer().gDisasters.Outside.OutsideFactor/100 
	local wind_weak_vol = math.Clamp( ( (math.Clamp((( math.Clamp(local_wind / 20, 0, 1) * 5)^2) * local_wind, 0, local_wind)) / 20), 0, GetConVar("gdisasters_volume_Light_Wind"):GetFloat()) 
	
	
	if LocalPlayer().gDisasters.Outside.IsOutside then
		wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0, 1) 
	else
		wind_weak_vol   = wind_weak_vol * math.Clamp(outside_fac , 0.1, 1)
	end
	
	local wind_mod_vol  = math.Clamp( ( (local_wind-20) / 60), 0, GetConVar("gdisasters_volume_Moderate_Wind"):GetFloat()) * outside_fac 		
	local wind_str_vol  = math.Clamp( ( (local_wind-80) / 120), 0, GetConVar("gdisasters_volume_Heavy_Wind"):GetFloat()) * outside_fac 	
	
	if LocalPlayer().Sounds["Wind_Heavy"] == nil then
		
		
		LocalPlayer().Sounds["Wind_Light"]         = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_weak.wav")
		LocalPlayer().Sounds["Wind_Moderate"]      = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_moderate.wav")
		LocalPlayer().Sounds["Wind_Heavy"]         = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/wind_heavy.wav")
		
		LocalPlayer().Sounds["Wind_Light"]:ChangeVolume(0, 0)
		LocalPlayer().Sounds["Wind_Moderate"]:ChangeVolume(0, 0)
		LocalPlayer().Sounds["Wind_Heavy"]:ChangeVolume(0, 0)
						
	end

	LocalPlayer().Sounds["Wind_Light"]:ChangeVolume(wind_weak_vol, 0)
	LocalPlayer().Sounds["Wind_Moderate"]:ChangeVolume(wind_mod_vol, 0)
	LocalPlayer().Sounds["Wind_Heavy"]:ChangeVolume(wind_str_vol, 0)		
	
	
end

	
	














