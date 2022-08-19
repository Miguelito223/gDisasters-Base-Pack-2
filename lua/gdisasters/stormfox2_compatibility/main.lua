CreateConVar("gdisasters_stormfox_compatibility", 0, {FCVAR_ARCHIVE}, "")

function start()
    if GetConVar("gdisasters_stormfox_compatibility"):GetInt() == 0 then return end

	temp = StormFox2.Temperature.Get()
	wind = StormFox2.Wind.GetForce()

    SetGlobalFloat("gDisasters_Temperature", temp)
	SetGlobalFloat("gDisasters_Pressure", temp * 1000)
	SetGlobalFloat("gDisasters_Humidity", temp + 23)
	SetGlobalFloat("gDisasters_Wind", wind)
end
hook.Add("Tick", "stormfox_compatibility", start)