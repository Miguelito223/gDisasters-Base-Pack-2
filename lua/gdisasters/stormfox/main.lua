CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function start()
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    temp = StormFox2.Temperature.Get()
    wind = StormFox2.Wind.GetForce()
    
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind

    if !StormFox2.Weather.IsRaining() or !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    elseif StormFox2.Weather.IsRaining() or StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 50
    end
end
hook.Add("Tick", "stormfoxandgdisasters", start)
end