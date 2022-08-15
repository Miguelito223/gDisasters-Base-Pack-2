CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars

function HeatSystem() -- System Core
	if GetConVar("gdisasters_HeatSytem_enabled"):GetInt() == 0 then return end

	floorheat = 0
	airheat =  23
	upperairheat =  15
	waterheat =  0
	heatIRmultiplier = 1
	sunHeat = 1
	heightCooldownRate = 1
	pressureCoeffitient = 1000
	lowerPointPressure = 10
	CAPE = 0
	windDiff = 0
	CalculateHeat()
	SetGLOBALSYSTEM()
	
	print("heat: ".. floorheat, airheat, upperairheat, waterheat)
end
hook.Add("Tick", "experimental", HeatSystem)

function CalculateHeat() -- Calculate Heat -_-

    TransferHeatToGround()
	CalculateAirInstability()
    airheat = airheat + sunHeat + heatIRmultiplier
	upperairheat = airheat - heatIRmultiplier * sunHeat * heightCooldownRate
	waterheat = floorheat + sunHeat - heatIRmultiplier

end

function CalculateAirInstability() -- Calculate CAPE index, wind

    windDiff = airheat + waterheat / lowerPointPressure
    CAPE = airheat + waterheat * (sunHeat + 1) + heatIRmultiplier + heightCooldownRate

end

function TransferHeatToGround() -- Trasfer Current Heat To Ground (Floor)

    floorheat = airheat - heatIRmultiplier + sunHeat
	airheat = airheat - heatIRmultiplier

end

function SetGLOBALSYSTEM() -- Make Values Like Wind Speed Show Correct Stuff
	SetGlobalFloat("gDisasters_Temperature", airheat)
	SetGlobalFloat("gDisasters_Pressure", airheat * pressureCoeffitient)
	SetGlobalFloat("gDisasters_Humidity", waterheat + airheat)
	SetGlobalFloat("gDisasters_Wind", windDiff)

end