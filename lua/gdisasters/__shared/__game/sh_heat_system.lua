-- Tamaño de la cuadrícula y rango de temperatura
local gridSize = 100 -- Tamaño de cada cuadrado en unidades
local minTemperature = 10 -- Temperatura mínima
local maxTemperature = 40 -- Temperatura máxima
local updateInterval = 0.01 -- Intervalo de actualización en segundos
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

    -- Si no hay celdas vecinas válidas, retornar la temperatura actual
    if count == 0 then return temperatureMap[x][y] end

    -- Calcular la temperatura promedio de las vecinas
    local averageTemperature = totalTemperature / count

    -- Ajustar la temperatura de la celda actual basada en la difusión de calor
    local currentTemperature = temperatureMap[x][y]
    local newTemperature = currentTemperature + diffusionCoefficient * (averageTemperature - currentTemperature)

    return math.max(minTemperature, math.min(maxTemperature, newTemperature)) -- Asegurarse de que la temperatura esté dentro del rango
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
local function GenerateGrid(ply)
    local temperatureMap = {}
    local MapBounds = getMapBounds()
    local max, min = MapBounds[1], MapBounds[2]
    local mapMinX, mapMinY = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize
    local mapMaxX, mapMaxY = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize

    print("Generating grid...") -- Depuración

    -- Generar la cuadrícula y asignar temperaturas iniciales aleatorias
    for x = mapMinX, mapMaxX, gridSize do
        if not temperatureMap[x] then
            temperatureMap[x] = {} -- Asegurarse de que cada columna esté inicializada
        end
        for y = mapMinY, mapMaxY, gridSize do
            temperatureMap[x][y] = math.random(minTemperature, maxTemperature)
            print("Position grid: " .. x .. ", ".. y) -- Depuración
        end
    end

    print("Grid generated.") -- Depuración

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
                    if temperatureMap[x] and temperatureMap[x][y] then
                        local newTemperature = CalculateTemperature(x, y, temperatureMap)
                        temperatureMap[x][y] = newTemperature
                    end
                end
            end
        end
    end)

   -- Hook para actualizar la temperatura alrededor del jugador
    hook.Add("Think", "UpdatePlayerAreaTemperature_" .. ply:SteamID(), function()
        local pos = ply:GetPos()
        local px = math.floor(pos.x / gridSize) * gridSize
        local py = math.floor(pos.y / gridSize ) * gridSize
        print(px, py)
        if temperatureMap[px] and temperatureMap[px][py] then
            GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = CalculateTemperature(px, py, temperatureMap)
            print(string.format("Temperatura promedio alrededor del jugador %s: %d grados Celsius", ply:GetName(), GLOBAL_SYSTEM["Atmosphere"]["Temperature"]))
        end
    end)

    if CLIENT then
        hook.Add("PostDrawOpaqueRenderables", "DrawGridDebug", function()
            for x = mapMinX, mapMaxX, gridSize do
                for y = mapMinY, mapMaxY, gridSize do
                    local pos1 = Vector(x, y, min.z)
                    local pos2 = Vector(x + gridSize, y + gridSize, max.z)
                    render.DrawBox(pos1, Angle(0, 0, 0), pos1, pos2, Color(255, 0, 0))
                end
            end
        end)
    end
end

-- Llamar a la función para generar la cuadrícula al inicio del juego
hook.Add("PlayerSpawn", "GenerateTemperatureGrid", GenerateGrid)