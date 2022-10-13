CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function gdisasters_stormfox2()
    
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    
    local temp = StormFox2.Temperature.Get()
    local wind = StormFox2.Wind.GetForce()
    
    GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = wind
    GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Direction"] = Vector(1,0,0)


    if !StormFox2.Weather.IsRaining() and !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
    elseif StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0)then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
    else
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    end

    if StormFox2.Thunder.IsThundering() then
        local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
        if !ent then return end
        if ent:IsValid() then ent:Remove() end
    end
end
hook.Add("Tick", "stormfox2_gdisasters", gdisasters_stormfox2)
end

if (CLIENT) then
end