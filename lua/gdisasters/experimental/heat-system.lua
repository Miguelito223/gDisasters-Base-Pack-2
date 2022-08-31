CreateConVar("gdisasters_HeatSytem_enabled", 0, {FCVAR_ARCHIVE}) --Convars

if (SERVER) then

function Core() -- System Core

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

	SetGLOBALSYSTEM()
	CalculateHeat()
	
end
hook.Add("Tick", "Experimental", Core)


function CalculateHeat() -- Calculate Heat -_-
	TransferHeatToGround()
	AddHeatToGround()
	CalculateAirInstability()
	RandomEvent()
	Weather()
    airheat = airheat + sunHeat - heatIRmultiplier
	upperairheat = airheat - (heatIRmultiplier * sunHeat) * heightCooldownRate
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

function AddHeatToGround() -- Trasfer Current Heat To Ground (Floor)

    floorheat = floorheat + sunHeat - heatIRmultiplier
	waterheat = waterheat + sunHeat - heatIRmultiplier

end

function Weather() -- Weather Stuffy

end

function RandomEvent() -- Randomly Change Stuff For More Variance

    if math.random(1, 256) == 11 then
		airheat = airheat * math.random(-3, 3)
	end

	if math.random(1, 256) == 34 then
		waterheat = waterheat * math.random(-3, 3)
	end

	if math.random(1, 256) == 84 then
		upperairheat = upperairheat * math.random(-5, 5)
	end

end

function SetGLOBALSYSTEM() -- Make Values Like Wind Speed Show Correct Stuff
	GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = airheat
	GLOBAL_SYSTEM["Atmosphere"]["Pressure"] = airheat * pressureCoeffitient
	GLOBAL_SYSTEM["Atmosphere"]["Humidity"] = waterheat + airheat
	GLOBAL_SYSTEM["Atmosphere"]["Wind"]["Speed"] = windDiff
end

end