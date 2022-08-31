CreateConVar("gdisasters_HeatSytem_enabled", 0, {FCVAR_ARCHIVE}) --Convars

if (SERVER) then

function Core() -- System Core

	if GetConVar("gdisasters_HeatSytem_enabled"):GetInt() == 0 then return end

	floorheat = 0
	airheat =  23
	upperairheat =  15
	waterheat =  0
	steam = 0
	humidity = 0
	gravity = physenv.GetGravity()
	centerpos = getMapCenterPos()
	pressure = gravity * centerpos
	capeofcondesation = 1000
	SunHeat = 1
	Cold = 1
	

	local function SetGLOBALSYSTEM() -- Make Values Like Wind Speed Show Correct Stuff
		GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = airheat
		GLOBAL_SYSTEM["Atmosphere"]["Humidity"] = humidity
	end

	local function calculateheat()
		airheat = airheat + SunHeat - Cold
		floorheat = floorheat + SunHeat * airheat
		waterheat = waterheat + SunHeat * airheat

		if floorheat and waterheat >= 20 then
			steam = 15
			humidity = 52
		elseif floorheat and waterheat >= 30 then
			steam = 28
			humidity = 28
		elseif floorheat and waterheat >= 10 then
			steam = 8
			humidity = 100
		elseif floorheat and waterheat >= 10 then
			steam = 8
			humidity = 100
		end



	end

	calculateheat()
	SetGLOBALSYSTEM()
	
end
hook.Add("Tick", "Experimental", Core)

end