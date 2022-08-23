CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function start()
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    temp = StormFox2.Temperature.Get()
    wind = StormFox2.Wind.GetForce()
    
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind

    if !StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(0) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(0.1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 10
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(0.5) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 30
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(0.8) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 80
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 100
    end
end
hook.Add("Tick", "stormfoxandgdisasters", start)
end