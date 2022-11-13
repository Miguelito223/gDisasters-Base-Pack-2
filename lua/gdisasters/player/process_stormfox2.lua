function gDisasters_stormfox2()

    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    if Stormfox and StormFox.Version < 2 then 
	    for k, v in pairs(player.GetAll()) do 
	    	v:ChatPrint("StormFox 1 is no compatible with gDisasters. Please install stormfox 2")
	    end
        return
    end
    
    local temp = StormFox2.Temperature.Get()
    local wind = StormFox2.Wind.GetForce()
    
    GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = wind
    GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = Vector(1,0,0)


    if !StormFox2.Weather.IsRaining() and !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 10200
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 9600
    elseif StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0)then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 9600
    else
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = 10200
    end

    if StormFox2.Thunder.IsThundering() then
        local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
        if !ent then return end
        if ent:IsValid() then ent:Remove() end
    end
end
