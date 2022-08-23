CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function start()
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    if stormfox2 then
        temp = StormFox2.Temperature.Get()
        wind = StormFox2.Wind.GetForce()
    
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
	    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind
    end
end
hook.Add("Tick", "stormfoxandgdisasters", start)
end