-- Definir los tipos de clima
weatherTypes = {
    "soleado",
    "lluvioso",
    "nevado",
    "tormentoso",
}

weatherTransitions = {
    soleado = { soleado = 0.6, lluvioso = 0.3, nevado = 0.0, tormentoso = 0.1 },
    lluvioso = { soleado = 0.2, lluvioso = 0.5, nevado = 0.0, tormentoso = 0.3 },
    nevado = { soleado = 0.1, lluvioso = 0.1, nevado = 0.7, tormentoso = 0.1 },
    tormentoso = { soleado = 0.2, lluvioso = 0.4, nevado = 0.0, tormentoso = 0.4 },
}

-- Variables para el clima
currentWeather = "soleado"
lastWeatherUpdateTime = 0
weatherUpdateInterval = 300

if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then 
    -- Función para generar el clima inicial
    function generateInitialWeather()
        if CLIENT then return end
        applyWeather()
        SetWeatherEffects()
        print("Clima inicial generado: " .. currentWeather)
    end

    -- Función para aplicar efectos climáticos
    function applyWeather()
        if CLIENT then return end
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
    -- Función para verificar condiciones climáticas y generar tormentas
    function checkForStormConditions()
        if CLIENT then return end
        local stormProbability = 0
        for x, column in pairs(GridMap) do
            for y, cell in pairs(column) do
                for z, altura in pairs(cell) do
                    local temperature = GridMap[x][y][z].temperature
                    local humidity = GridMap[x][y][z].humidity
                    local pressure = GridMap[x][y][z].pressure
                    local wind_speed = GridMap[x][y][z].wind_speed
                    
                    -- Incrementar la probabilidad de tormenta basada en condiciones específicas
                    if temperature > 25 and humidity > 70 and pressure < 100000 and wind_speed > 15 then
                        stormProbability = stormProbability + 1
                    end
                end
            end
        end
        
        -- Determinar si se debe generar una tormenta
        if stormProbability > 50 then -- Ajusta este valor según sea necesario
            currentWeather = "tormentoso"
            print("Condiciones de tormenta detectadas. Generando tormenta.")
        end
    end

    function determineNewWeather()
        local transitionProbabilities = weatherTransitions[currentWeather]
        local randomValue = math.random()
        local cumulativeProbability = 0

        for weather, probability in pairs(transitionProbabilities) do
            cumulativeProbability = cumulativeProbability + probability
            if randomValue <= cumulativeProbability then
                return weather
            end
        end

        return currentWeather -- Por si acaso algo falla, mantenemos el clima actual
    end

    -- Función para actualizar el clima
    function updateWeather()
        if CLIENT then return end
        local currentTime = CurTime()
        if currentTime - lastWeatherUpdateTime >= weatherUpdateInterval then
            checkForStormConditions() -- Verificar condiciones para tormentas antes de actualizar el clima
            currentWeather = determineNewWeather()
            applyWeather()
            SetWeatherEffects()
            print("Clima actualizado: " .. currentWeather)
            lastWeatherUpdateTime = currentTime
        end
    end



    function SetWeatherEffects()
        if CLIENT then return end
        
        local entity

        if currentWeather == "soleado" then
            if not IsValid(entity) then
                entity = ents.Create("gd_w1_sunny")
            else
                entity:Remove()
                entity = ents.Create("gd_w1_sunny")
            end
        elseif currentWeather == "lluvioso" then
            if not IsValid(entity) then
                entity = ents.Create("gd_w2_heavyrain")
            else
                entity:Remove()
                entity = ents.Create("gd_w2_heavyrain")
            end
        elseif currentWeather == "nevado" then
            if not IsValid(entity) then
                entity = ents.Create("gd_w2_blizzard")
            else
                entity:Remove()
                entity = ents.Create("gd_w2_blizzard")
            end
        elseif currentWeather == "tormentoso" then
            if not IsValid(entity) then
                entity = ents.Create("gd_w2_thunderstorm")
            else
                entity:Remove()
                entity = ents.Create("gd_w2_thunderstorm")
            end
        else
            if IsValid(entity) then
                entity:Remove()
            end
        end
    end

    -- Hook para generar el clima inicial al inicio del juego
    hook.Add("Initialize", "GenerateInitialWeather", generateInitialWeather)

    -- Hook para actualizar el clima periódicamente
    hook.Add("Think", "UpdateWeather", updateWeather)
end -- Aquí cerramos el if inicial
