-- Tamaño de la cuadrícula y rango de temperatura
local gridSize = 100 -- Tamaño de cada cuadrado en unidades
local minTemperature = 10 -- Temperatura mínima
local maxTemperature = 40 -- Temperatura máxima

local mapMinX = getMapBounds()[1].x
local mapMaxX = getMapBounds()[0].x
local mapMinY = getMapBounds()[1].y
local mapMaxY = getMapBounds()[0].y


-- Función para calcular la temperatura de un cuadrado basada en sus vecinos
local function CalculateTemperature(x, y, temperatureMap)
    local totalTemperature = 0
    local count = 0

    -- Sumar la temperatura de los cuadrados vecinos
    for i = -1, 1 do
        for j = -1, 1 do
            local nx, ny = x + i * gridSize, y + j * gridSize
            if temperatureMap[nx] and temperatureMap[nx][ny] then
                totalTemperature = totalTemperature + temperatureMap[nx][ny]
                count = count + 1
            end
        end
    end

    -- Calcular la temperatura promedio de los vecinos
    local averageTemperature = totalTemperature / count

    -- Ajustar la temperatura del cuadrado actual basada en la temperatura promedio de los vecinos
    local temperature = averageTemperature + math.random(-1, 1)
    return math.max(minTemperature, math.min(maxTemperature, temperature)) -- Asegurarse de que la temperatura esté dentro del rango
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
local function GenerateGrid()
    local temperatureMap = {}

    -- Generar la cuadrícula y asignar temperaturas iniciales aleatorias
    for x = mapMinX, mapMaxX, gridSize do
        temperatureMap[x] = {}
        for y = mapMinY, mapMaxY, gridSize do
            temperatureMap[x][y] = math.random(minTemperature, maxTemperature)
        end
    end

    -- Actualizar la temperatura de cada cuadrado en cada ciclo
    hook.Add("Think", "UpdateTemperatureGrid", function()
        local newTemperatureMap = {}
        for x, column in pairs(temperatureMap) do
            newTemperatureMap[x] = {}
            for y, temperature in pairs(column) do
                newTemperatureMap[x][y] = CalculateTemperature(x, y, temperatureMap)
                GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = newTemperatureMap[x][y]
                print(string.format("Cuadrado en (%d, %d) tiene una temperatura de %d grados Celsius", x, y, newTemperatureMap[x][y]))
            end
        end
        temperatureMap = newTemperatureMap
    end)
end

-- Llamar a la función para generar la cuadrícula al inicio del juego
hook.Add("Initialize", "GenerateTemperatureGrid", GenerateGrid)
