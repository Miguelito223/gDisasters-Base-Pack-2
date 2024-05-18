-- Tamaño de la cuadrícula y rango de temperatura
local gridSize = 100 -- Tamaño de cada cuadrado en unidades
local minTemperature = 10 -- Temperatura mínima
local maxTemperature = 40 -- Temperatura máxima
local updateInterval = 1 -- Intervalo de actualización en segundos
local updateBatchSize = 100 -- Número de celdas a actualizar por frame
local diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor

-- Función para calcular la temperatura de una celda basada en sus vecinos
local function CalculateTemperature(x, y, temperatureMap)
    local totalTemperature = 0
    local count = 0

    -- Sumar la temperatura de las celdas vecinas
    for i = -1, 1 do
        for j = -1, 1 do
            local nx, ny = x + i * gridSize, y + j * gridSize
            if temperatureMap[nx] and temperatureMap[nx][ny] then
                totalTemperature = totalTemperature + temperatureMap[nx][ny]
                count = count + 1
            end
        end
    end

    -- Calcular la temperatura promedio de las vecinas
    local averageTemperature = totalTemperature / count

    -- Ajustar la temperatura de la celda actual basada en la difusión de calor
    local currentTemperature = temperatureMap[x][y]
    local newTemperature = currentTemperature + diffusionCoefficient * (averageTemperature - currentTemperature)

    return math.max(minTemperature, math.min(maxTemperature, newTemperature)) -- Asegurarse de que la temperatura esté dentro del rango
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
local function GenerateGrid()
    local temperatureMap = {}
   
    if not IsMapRegistered() then return end
   
    local mapMinX = getMapBounds()[1].x
    local mapMaxX = getMapBounds()[2].x
    local mapMinY = getMapBounds()[1].y
    local mapMaxY = getMapBounds()[2].y

    -- Generar la cuadrícula y asignar temperaturas iniciales aleatorias
    for x = mapMinX, mapMaxX, gridSize do
        temperatureMap[x] = {}
        for y = mapMinY, mapMaxY, gridSize do
            temperatureMap[x][y] = math.random(minTemperature, maxTemperature)
        end
    end

   -- Variables para controlar la actualización por lotes
    local cellsToUpdate = {}
    for x = mapMinX, mapMaxX, gridSize do
        for y = mapMinY, mapMaxY, gridSize do
            table.insert(cellsToUpdate, {x, y})
        end
    end

    local lastUpdateTime = CurTime()

    -- Hook para actualizar la temperatura de las celdas en lotes
    hook.Add("Think", "UpdateTemperatureGrid", function()
        if CurTime() - lastUpdateTime >= updateInterval then
            lastUpdateTime = CurTime()

            -- Actualizar un lote de celdas
            for i = 1, updateBatchSize do
                local cell = table.remove(cellsToUpdate, 1)
                if not cell then
                    -- Reiniciar la lista de celdas para actualizar
                    for x = mapMinX, mapMaxX, gridSize do
                        for y = mapMinY, mapMaxY, gridSize do
                            table.insert(cellsToUpdate, {x, y})
                        end
                    end
                    cell = table.remove(cellsToUpdate, 1)
                end

                if cell then
                    local x, y = cell[1], cell[2]
                    local newTemperature = CalculateTemperature(x, y, temperatureMap)
                    temperatureMap[x][y] = newTemperature
                end
            end
        end
    end)

    -- Hook para actualizar la temperatura alrededor de cada jugador
    hook.Add("Think", "UpdatePlayerAreaTemperature", function()
        for _, ply in ipairs(player.GetAll()) do
            local pos = ply:GetPos()
            local px, py = math.floor(pos.x / gridSize) * gridSize, math.floor(pos.y / gridSize) * gridSize
            local totalTemperature = 0
            local count = 0

            -- Calcular la temperatura promedio de la celda actual y las vecinas
            for i = -1, 1 do
                for j = -1, 1 do
                    local nx, ny = px + i * gridSize, py + j * gridSize
                    if temperatureMap[nx] and temperatureMap[nx][ny] then
                        totalTemperature = totalTemperature + temperatureMap[nx][ny]
                        count = count + 1
                    end
                end
            end

            if count > 0 then
                local averageTemperature = totalTemperature / count
                GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = averageTemperature
                print(string.format("Temperatura promedio alrededor del jugador %s: %d grados Celsius", ply:GetName(), averageTemperature))
            end
        end
    end)
end

-- Llamar a la función para generar la cuadrícula al inicio del juego
hook.Add("InitPostEntity", "GenerateTemperatureGrid", GenerateGrid)
GenerateGrid()