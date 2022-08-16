CreateConVar("gdisasters_HeatSytem_enabled", 1, {FCVAR_ARCHIVE}) --Convars

hook.Add("Tick", "Experimental", function() -- System Core
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
end)


function CalculateHeat() -- Calculate Heat -_-
	TransferHeatToGround()
	AddHeatToGround()
	CalculateAirInstability()
	RandomEvent()
	Weather()
    airheat = airheat + sunHeat + heatIRmultiplier + sunHeat
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
	timer.Create("lol", 10, 0, function()
    	floorheat = floorheat + sunHeat
		waterheat = waterheat + sunHeat
    end)
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
	SetGlobalFloat("gDisasters_Temperature", airheat)
	SetGlobalFloat("gDisasters_Pressure", airheat * pressureCoeffitient)
	SetGlobalFloat("gDisasters_Humidity", waterheat + airheat)
	SetGlobalFloat("gDisasters_Wind", windDiff)

end