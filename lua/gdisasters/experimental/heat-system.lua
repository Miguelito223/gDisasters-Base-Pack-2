CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars

function HeatSytem() -- System Core
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
	
	print("heat: ".. floorheat, airheat, upperairheat, waterheat)
end

function CalculateHeat() -- Calculate Heat -_-

    TransferHeatToGround()
	CalculateAirInstability()
    airheat = airheat + sunHeat + heatIRmultiplier
	upperairheat = airheat - heatIRmultiplier * sunHeat * heightCooldownRate
	waterheat = floorheat + sunHeat - heatIRmultiplier

end

function CalculateAirInstability() -- Calculate CAPE index, wind

    windDiff = airheat + waterheat / lowerPointPressure
    CAPE = airheat + waterheat * (sunheat + 1) + heatIRmultipiler + heightCooldownRate

end

function TransferHeatToGround() -- Trasfer Current Heat To Ground (Floor)

    floorheat = airheat - heatIRmultiplier + sunHeat
	airheat = airheat - heatIRmultiplier

end

function SetGLOBALSYSTEM() -- Make Values Like Wind Speed Show Correct Stuff
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = airheat
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = waterheat + airheat
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"] = windDiff
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = airheat * pressureCoeffitient

end