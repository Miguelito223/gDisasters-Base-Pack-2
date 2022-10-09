CreateConVar("gdisasters_stormfox_enable", 0, {FCVAR_ARCHIVE}, "")

if (SERVER) then

function gdisasters_stormfox2(ply)
    
    if GetConVar("gdisasters_stormfox_enable"):GetInt() == 0 then return end
    
    local temp = StormFox2.Temperature.Get()
    local wind = StormFox2.Wind.GetForce()
    local wind_yaw = StormFox2.Wind.GetYaw()

    if wind_yaw >= 0
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-1,0,0)
    elseif wind_yaw >= 10
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.90,-0.10,0)
    elseif wind_yaw >= 20
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.80,-0.20,0)
    elseif wind_yaw >= 30
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.70,-0.30,0)
    elseif wind_yaw >= 40
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.60,-0.40,0)
    elseif wind_yaw >= 50 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.50,-0.50,0)
    elseif wind_yaw >= 60 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.40,-0.60,0)
    elseif wind_yaw >= 70 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.30,-0.70,0)
    elseif wind_yaw >= 80 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.20,-0.80,0)
    elseif wind_yaw >= 90 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(-0.10,-0.90,0)
    elseif wind_yaw >= 100 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0,-1,0)
    elseif wind_yaw >= 110 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.10,-1.10,0)
    elseif wind_yaw >= 120 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.20,-1.20,0)
    elseif wind_yaw >= 130 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.30,-1.30,0)
    elseif wind_yaw >= 140 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.40,-1.40,0)
    elseif wind_yaw >= 150 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.50,-1.50,0)
    elseif wind_yaw >= 160 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.60,-1.60,0)
    elseif wind_yaw >= 170 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.70,-1.70,0)
    elseif wind_yaw >= 180 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.80,-1.80,0)
    elseif wind_yaw >= 190 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(0.90,-1.90,0)
    elseif wind_yaw >= 200 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1,-2,0)
    elseif wind_yaw >= 210 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.10,-2.10,0)
    elseif wind_yaw >= 220 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.20,-2.20,0)
    elseif wind_yaw >= 230 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.30,-2.30,0)
    elseif wind_yaw >= 240 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.40,-2.40,0)
    elseif wind_yaw >= 250 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.50,-2.50,0)
    elseif wind_yaw >= 260 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.60,-2.60,0)
    elseif wind_yaw >= 270 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.70,-2.70,0)
    elseif wind_yaw >= 280 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.80,-2.80,0)
    elseif wind_yaw >= 290 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(1.90,-2.90,0)
    elseif wind_yaw >= 300 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2,3,0)
    elseif wind_yaw >= 310 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.10,-3.10,0)
    elseif wind_yaw >= 320 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.20,-3.20,0)
    elseif wind_yaw >= 330 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.30,-3.30,0)
    elseif wind_yaw >= 340 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.40,-3.40,0)
    elseif wind_yaw >= 350 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.50,-3.50,0)
    elseif wind_yaw >= 360 then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Vector(2.60,-3.60,0)
    end
    
    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = temp
	GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = wind
    

    if !StormFox2.Weather.IsRaining() and !StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    elseif StormFox2.Weather.IsRaining() and StormFox2.Weather.GetRainAmount(1) then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 50
    elseif StormFox2.Weather.IsSnowing() and StormFox2.Weather.GetRainAmount(0)then
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 50
    else
        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = 0
    end

    if StormFox2.Thunder.IsThundering() then
        local ent = ents.FindByClass("gd_d3_lightningstorm")[1]
        if !ent then return end
        if ent:IsValid() then ent:Remove() end
    end
end
hook.Add("Tick", "stormfox2_gdisasters", gdisasters_stormfox2)
end

if (CLIENT) then
end