CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function start()
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    temp = StormFox2.Temperature.Get()
    wind = StormFox2.Wind.GetForce()
    wind_direction = Vector(StormFox2.Wind.GetYaw(), -StormFox2.Wind.GetYaw(), 0)
    
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = wind_direction
end
hook.Add("Tick", "stormfoxandgdisasters", start)
end