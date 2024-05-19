-- Definir los tipos de clima
local weatherTypes = {
    "soleado",
    "lluvioso",
    "nevado",
    "tormentoso",
}

-- Variables para el clima
local currentWeather = "soleado"
local lastWeatherUpdateTime = 0
local weatherUpdateInterval = 300

if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then 
    -- Función para generar el clima inicial
    local function generateInitialWeather()
        currentWeather = weatherTypes[math.random(#weatherTypes)]
        print("Clima inicial generado: " .. currentWeather)
    end

    -- Función para aplicar efectos climáticos
    local function applyWeather()
        -- Aquí puedes implementar los efectos visuales y de juego asociados con cada tipo de clima
        -- Por ahora, solo imprimimos el clima actual en la consola
        print("El clima actual es: " .. currentWeather)
        
        -- Ajustar la temperatura según el clima
        if currentWeather == "soleado" then
            minTemperature = 20
            maxTemperature = 35
            minHumidity = 10
            maxHumidity = 20
            minPressure = 90000
            maxPressure = 110000
            minWind_speed = 0
            maxWind_speed = 10
        elseif currentWeather == "lluvioso" then
            minTemperature = 15
            maxTemperature = 25
            minHumidity = 20
            maxHumidity = 50
            minPressure = 100000
            maxPressure = 110000
            minWind_speed = 10
            maxWind_speed = 20
        elseif currentWeather == "nevado" then
            minTemperature = -10
            maxTemperature = 5
            minHumidity = 20
            maxHumidity = 50
            minPressure = 11000
            maxPressure = 120000
            minWind_speed = 10
            maxWind_speed = 20
        elseif currentWeather == "tormentoso" then
            minTemperature = 10
            maxTemperature = 30
            minHumidity = 50
            maxHumidity = 100
            minPressure = 110000
            maxPressure = 120000
            minWind_speed = 20
            maxWind_speed = 30
        end
        
        -- Actualizar la temperatura en la cuadrícula
        for x, column in pairs(GridMap) do
            for y, cell in pairs(column) do
                for z, altura in pairs(cell) do
                    GridMap[x][y][z].temperature = math.random(minTemperature, maxTemperature)
                    GridMap[x][y][z].humidity = math.random(minHumidity, maxHumidity)
                    GridMap[x][y][z].pressure = math.random(minPressure, maxPressure)
                    GridMap[x][y][z].wind_speed = math.random(minWind_speed, maxWind_speed)
                end
            end
        end
    end

    -- Función para actualizar el clima
    local function updateWeather()
        local currentTime = CurTime()
        if currentTime - lastWeatherUpdateTime >= weatherUpdateInterval then
            currentWeather = weatherTypes[math.random(#weatherTypes)]
            applyWeather()
            SetWeatherEffects()
            print("Clima actualizado: " .. currentWeather)
            lastWeatherUpdateTime = currentTime
        end
    end

    function CreateSnowDecals()
        for k, v in pairs(player.GetAll()) do
            net.Start("gd_createdecals")
            net.WriteString("snow")
            net.WriteBool(self.CreatedDecals)
            net.Send(v)
        end
    end

    local function updateWeatherEffects()
        if currentWeather == "soleado" then
            
        elseif currentWeather == "lluvioso" then
            if SERVER then
                for k, v in pairs(player.GetAll()) do
                    if v.gDisasters.Area.IsOutdoor then
                        net.Start("gd_clParticles")
                        net.WriteString("localized_rain_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                        net.Start("gd_clParticles_ground")
                        net.WriteString("heavy_rain_splash_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                        
                        if math.random(1, 2) == 1 then
                            net.Start("gd_screen_particles")
                            net.WriteString("hud/warp_ripple3")
                            net.WriteFloat(math.random(5, 228))
                            net.WriteFloat(math.random(0, 100) / 100)
                            net.WriteFloat(math.random(0, 1))
                            net.WriteVector(Vector(0, math.random(0, 200) / 100, 0))
                            net.Send(v)
                        end
                    end
                end
            end
        elseif currentWeather == "nevado" then
            if SERVER then
                for k, v in pairs(player.GetAll()) do
                    if v.gDisasters.Area.IsOutdoor then
                        if HitChance(0.1) then
                            net.Start("gd_screen_particles")
                            net.WriteString("hud/snow")
                            net.WriteFloat(math.random(5, 128))
                            net.WriteFloat(math.random(0, 100) / 100)
                            net.WriteFloat(math.random(0, 1))
                            net.WriteVector(Vector(0, 2, 0))
                            net.Send(v)
                        end
                        
                        net.Start("gd_clParticles")
                        net.WriteString("localized_blizzard_effect")
                        net.Send(v)
                        net.Start("gd_clParticles_ground")
                        net.WriteString("heavy_snow_ground_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                        net.Start("gd_clParticles_ground")
                        net.WriteString("snow_gust_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                    end
                end
            end
        elseif currentWeather == "tormentoso" then
            if SERVER then
                for k, v in pairs(player.GetAll()) do
                    if v.gDisasters.Area.IsOutdoor then
                        net.Start("gd_clParticles")
                        net.WriteString("localized_rain_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                        net.Start("gd_clParticles_ground")
                        net.WriteString("heavy_rain_splash_effect", Angle(0, math.random(1, 40), 0))
                        net.Send(v)
                        
                        if math.random(1, 2) == 1 then
                            net.Start("gd_screen_particles")
                            net.WriteString("hud/warp_ripple3")
                            net.WriteFloat(math.random(5, 228))
                            net.WriteFloat(math.random(0, 100) / 100)
                            net.WriteFloat(math.random(0, 1))
                            net.WriteVector(Vector(0, math.random(0, 200) / 100, 0))
                            net.Send(v)
                        end
                    end
                end
            end
        end
    end

    local function SetWeatherEffects()
        if currentWeather == "soleado" then
            
        elseif currentWeather == "lluvioso" then
            if CLIENT then
                LocalPlayer().Sounds["Rainstorm_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop.wav")
                LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop_muffled.wav")
            else
                setMapLight("d")
            end
        elseif currentWeather == "nevado" then
            if CLIENT then

            else
                CreateSnowDecals()
                setMapLight("d")
            end
        elseif currentWeather == "tormentoso" then
            if CLIENT then
                LocalPlayer().Sounds["Rainstorm_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop.wav")
                LocalPlayer().Sounds["Rainstorm_muffled_IDLE"] = CreateLoopedSound(LocalPlayer(), "streams/disasters/nature/heavy_rain_loop_muffled.wav")
            else
                CreateSnowDecals()
                setMapLight("d")
            end
        end
    end

    -- Hook para generar el clima inicial al inicio del juego
    hook.Add("Initialize", "GenerateInitialWeather", generateInitialWeather)

    -- Hook para actualizar el clima periódicamente
    hook.Add("Think", "UpdateWeather", updateWeather)
    hook.Add("Think", "UpdateWeatherEffect", updateWeatherEffects)
end -- Aquí cerramos el if inicial
