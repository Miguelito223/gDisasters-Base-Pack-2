CreateConVar("gdisasters_stormfox_compatibility", 0, {FCVAR_ARCHIVE}, "")

function start()
    if GetConVar("gdisasters_stormfox_compatibility"):GetInt() == 0 then return end

    SetGlobalFloat("gDisasters_Temperature", StormFox2.Temperature.Get())
	SetGlobalFloat("gDisasters_Pressure", 0)
	SetGlobalFloat("gDisasters_Humidity", 0)
	SetGlobalFloat("gDisasters_Wind", StormFox2.Wind.GetForce())
end
hook.Add("Tick", "stormfox_compatibility", start)