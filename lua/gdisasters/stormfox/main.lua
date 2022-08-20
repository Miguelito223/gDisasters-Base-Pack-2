CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function start()
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    temp = StormFox2.Temperature.Get()
    tempd = temp + -1
    wind = StormFox2.Wind.GetForce()
    pressure = 6.11 * 10 * (7.5 * temp / 237.3 + temp)
    pressurereal = 6.11 * 10 * (7.5 * tempd / 237.3 + tempd)
    humidity = pressure / pressurereal * 100
    alture = getMapCenterFloorPos().z
    density = 1225
    gravity = 9.8
    pressureATS = alture * density * gravity
    
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = humidity
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = pressureATS
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind
end
hook.Add("Tick", "stormfoxandgdisasters", start)
end