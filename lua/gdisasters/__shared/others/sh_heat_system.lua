-- Tamaño de la cuadrícula y rango de temperatura
gridSize = 1000 -- Tamaño de cada cuadrado en unidades
minTemperature = -20 -- Temperatura mínima
maxTemperature = 40 -- Temperatura máxima
minHumidity = 30 -- Humedad mínima
maxHumidity = 80 -- Humedad máxima
minPressure = 90000 -- Presión mínima en milibares
maxPressure = 110000 -- Presión máxima en milibares
updateInterval = 0.01 -- Intervalo de actualización en segundos
updateBatchSize = 100 -- Número de celdas a actualizar por frame
diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor
GridMap = {}
cellsToUpdate = {}

if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then 

    -- Función para calcular la temperatura de una celda basada en sus vecinos
    function CalculateTemperature(x, y)
        local totalTemperature = 0
        local count = 0

        -- Sumar la temperatura de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                local nx, ny = x + i * gridSize, y + j * gridSize
                if GridMap[nx] and GridMap[nx][ny] then
                    totalTemperature = totalTemperature + GridMap[nx][ny].temperature
                    count = count + 1
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la temperatura actual
        if count == 0 then return GridMap[x][y].temperature end

        -- Calcular la temperatura promedio de las vecinas
        local averageTemperature = totalTemperature / count

        -- Ajustar la temperatura de la celda actual basada en la difusión de calor
        local currentTemperature = GridMap[x][y].temperature
        local newTemperature = currentTemperature + diffusionCoefficient * (averageTemperature - currentTemperature)

        return math.max(minTemperature, math.min(maxTemperature, newTemperature)) -- Asegurarse de que la temperatura esté dentro del rango
    end



    -- Función para calcular la humedad de una celda basada en sus vecinos
    function CalculateHumidity(x, y)
        local totalHumidity = 0
        local count = 0

        -- Sumar la humedad de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                local nx, ny = x + i * gridSize, y + j * gridSize
                if GridMap[nx] and GridMap[nx][ny] then
                    totalHumidity = totalHumidity + GridMap[nx][ny].humidity
                    count = count + 1
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la humedad actual
        if count == 0 then return GridMap[x][y].humidity end

        -- Calcular la humedad promedio de las vecinas
        local averageHumidity = totalHumidity / count

        -- Ajustar la humedad de la celda actual
        local currentHumidity = GridMap[x][y].humidity
        local newHumidity = currentHumidity + diffusionCoefficient * (averageHumidity - currentHumidity)

        return math.max(minHumidity, math.min(maxHumidity, newHumidity)) -- Asegurarse de que la humedad esté dentro del rango
    end

    function CalculatePressure(x, y)
        local totalPressure = 0
        local count = 0

        -- Sumar la presión de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                local nx, ny = x + i * gridSize, y + j * gridSize
                if GridMap[nx] and GridMap[nx][ny] then
                    totalPressure = totalPressure + GridMap[nx][ny].pressure
                    count = count + 1
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la presión actual
        if count == 0 then return GridMap[x][y].pressure end

        -- Calcular la presión promedio de las vecinas
        local averagePressure = totalPressure / count

        -- Ajustar la presión de la celda actual
        local currentPressure = GridMap[x][y].pressure
        local newPressure = currentPressure + diffusionCoefficient * (averagePressure - currentPressure)

        return math.max(minPressure, math.min(maxPressure, newPressure)) -- Asegurarse de que la presión esté dentro del rango
    end

    -- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
    function GenerateGrid(ply)
        local MapBounds = getMapBounds()
        local max, min = MapBounds[1], MapBounds[2]
        local mapMinX, mapMinY = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize
        local mapMaxX, mapMaxY = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize

        print("Generating grid...") -- Depuración

        -- Generar la cuadrícula y asignar temperaturas iniciales aleatorias
        for x = mapMinX, mapMaxX, gridSize do
            if not GridMap[x] then
                GridMap[x] = {} -- Asegurarse de que cada columna esté inicializada
            end
            for y = mapMinY, mapMaxY, gridSize do
                GridMap[x][y] = { temperature = math.random(minTemperature, maxTemperature), humidity = math.random(minHumidity, maxHumidity), pressure = math.random(minPressure, maxPressure)}
                print("Position grid: " .. x .. ", ".. y) -- Depuración
            end
        end

        print("Grid generated.") -- Depuración

    -- Variables para controlar la actualización por lotes
        
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
                        if GridMap[x] and GridMap[x][y] then
                            local newTemperature = CalculateTemperature(x, y)
                            local newHumidity = CalculateHumidity(x, y)
                            local newPressure = CalculatePressure(x, y)
                            GridMap[x][y].temperature = newTemperature
                            GridMap[x][y].humidity = newHumidity
                            GridMap[x][y].pressure = newPressure
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
            if GridMap[px] and GridMap[px][py] then
                GLOBAL_SYSTEM["Atmosphere"]["Temperature"] = CalculateTemperature(px, py)
                GLOBAL_SYSTEM["Atmosphere"]["Humidity"] = CalculateHumidity(px, py)
                GLOBAL_SYSTEM["Atmosphere"]["Pressure"] = CalculatePressure(px, py)
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
end