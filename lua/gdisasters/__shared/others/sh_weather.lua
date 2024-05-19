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
    local function applyWeatherEffects()
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
        elseif currentWeather == "lluvioso" then
            minTemperature = 15
            maxTemperature = 25
            minHumidity = 20
            maxHumidity = 50
            minPressure = 100000
            maxPressure = 110000
        elseif currentWeather == "nevado" then
            minTemperature = -10
            maxTemperature = 5
            minHumidity = 20
            maxHumidity = 50
            minPressure = 11000
            maxPressure = 120000
        elseif currentWeather == "tormentoso" then
            minTemperature = 10
            maxTemperature = 30
            minHumidity = 50
            maxHumidity = 100
            minPressure = 110000
            maxPressure = 120000
        end
        
        -- Actualizar la temperatura en la cuadrícula
        for x, column in pairs(GridMap) do
            for y, cell in pairs(column) do
                GridMap[x][y].temperature = math.random(minTemperature, maxTemperature)
                GridMap[x][y].humidity = math.random(minHumidity, maxHumidity)
                GridMap[x][y].pressure = math.random(minPressure, maxPressure)
            end
        end
    end

    -- Función para actualizar el clima
    local function updateWeather()
        local currentTime = CurTime()
        if currentTime - lastWeatherUpdateTime >= weatherUpdateInterval then
            currentWeather = weatherTypes[math.random(#weatherTypes)]
            applyWeatherEffects()
            print("Clima actualizado: " .. currentWeather)
            lastWeatherUpdateTime = currentTime
            
        end
    end



    -- Hook para generar el clima inicial al inicio del juego
    hook.Add("Initialize", "GenerateInitialWeather", generateInitialWeather)

    -- Hook para actualizar el clima periódicamente
    hook.Add("Think", "UpdateWeather", updateWeather)
end
