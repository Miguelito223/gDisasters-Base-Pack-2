-- Tamaño de la cuadrícula y rango de temperatura
gridSize = 1000 -- Tamaño de cada cuadrado en unidades
minTemperature = 20 -- Temperatura mínima
maxTemperature = 35 -- Temperatura máxima
minHumidity = 30 -- Humedad mínima
maxHumidity = 80 -- Humedad máxima
minPressure = 90000 -- Presión mínima en milibares
maxPressure = 110000 -- Presión máxima en milibares
minWind_speed = 0
maxWind_speed = 10
updateInterval = 0.1 -- Intervalo de actualización en segundos
updateBatchSize = 100 -- Número de celdas a actualizar por frame
diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor
GridMap = {}
cellsToUpdate = {}

if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then 

    -- Función para calcular la temperatura de una celda basada en sus vecinos
    function CalculateTemperature(x, y, z)
        local totalTemperature = 0
        local count = 0

        -- Sumar la temperatura de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                for k = -1, 1 do
                    local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                    if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                        totalTemperature = totalTemperature + GridMap[nx][ny][nz].temperature
                        count = count + 1
                    end
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la temperatura actual
        if count == 0 then return GridMap[x][y][z].temperature end

        -- Calcular la temperatura promedio de las vecinas
        local averageTemperature = totalTemperature / count

        -- Ajustar la temperatura de la celda actual basada en la difusión de calor
        local currentTemperature = GridMap[x][y][z].temperature
        local newTemperature = currentTemperature + diffusionCoefficient * (averageTemperature - currentTemperature)
        -- Ajustar la temperatura en función de la altitud
        local altitudeEffect = z * 0.0065 -- La temperatura desciende aproximadamente 0.0065 grados por metro de altitud
        newTemperature = newTemperature - altitudeEffect


        return math.max(minTemperature, math.min(maxTemperature, newTemperature)) -- Asegurarse de que la temperatura esté dentro del rango
    end



    -- Función para calcular la humedad de una celda basada en sus vecinos
    function CalculateHumidity(x, y, z)
        local totalHumidity = 0
        local count = 0

        -- Sumar la humedad de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                for k = -1, 1 do
                    local nx, ny, nz = x + i * gridSize, y + j * gridSize, y + k * gridSize
                    if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                        totalHumidity = totalHumidity + GridMap[nx][ny][nz].humidity
                        count = count + 1
                    end
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la humedad actual
        if count == 0 then return GridMap[x][y][z].humidity end

        -- Calcular la humedad promedio de las vecinas
        local averageHumidity = totalHumidity / count

        -- Ajustar la humedad de la celda actual
        local currentHumidity = GridMap[x][y][z].humidity
        local newHumidity = currentHumidity + diffusionCoefficient * (averageHumidity - currentHumidity)

        return math.max(minHumidity, math.min(maxHumidity, newHumidity)) -- Asegurarse de que la humedad esté dentro del rango
    end

    function CalculatePressure(x, y, z)
        local totalPressure = 0
        local count = 0

        -- Sumar la presión de las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                for k = -1, 1 do
                    local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                    if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                        totalPressure = totalPressure + GridMap[nx][ny][nz].pressure
                        count = count + 1
                    end
                end
            end
        end

        -- Si no hay celdas vecinas válidas, retornar la presión actual
        if count == 0 then return GridMap[x][y][z].pressure end

        -- Calcular la presión promedio de las vecinas
        local averagePressure = totalPressure / count

        -- Ajustar la presión de la celda actual
        local currentPressure = GridMap[x][y][z].pressure
        local newPressure = currentPressure + diffusionCoefficient * (averagePressure - currentPressure)
        local altitudeEffect = z * 12 -- La temperatura desciende aproximadamente 0.0065 grados por metro de altitud
        newPressure = newPressure - altitudeEffect
        return math.max(minPressure, math.min(maxPressure, newPressure)) -- Asegurarse de que la presión esté dentro del rango
    end

    function CalculateWindSpeed(x, y, z)
        local maxDeltaPressure = 0 -- Almacena el cambio máximo de presión

        -- Calcular la diferencia de presión entre las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                for k = -1, 1 do
                    if i ~= 0 or j ~= 0 or k ~= 0 then -- Evitar la celda actual
                        local nx, ny,nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                            local deltaPressure = GridMap[nx][ny][nz].pressure - GridMap[x][y][z].pressure
                            if math.abs(deltaPressure) > math.abs(maxDeltaPressure) then
                                maxDeltaPressure = deltaPressure
                            end
                        end
                    end
                end
            end
        end

        -- Calcular la velocidad del viento en función de la diferencia de presión
        local windSpeed = maxDeltaPressure * (maxWind_speed - minWind_speed) / (maxPressure - minPressure)

        return math.max(minWind_speed, math.min(maxWind_speed, windSpeed))
    end

    -- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
    function GenerateGrid(ply)
        if CLIENT then return end
        
        local MapBounds = getMapBounds()
        local max, min = MapBounds[1], MapBounds[2]
        local mapMinX, mapMinY, mapMaxZ  = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize,math.ceil(min.z / gridSize) * gridSize
        local mapMaxX, mapMaxY, mapMinZ = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize, math.ceil(max.z / gridSize) * gridSize

        print("Generating grid...") -- Depuración

        -- Generar la cuadrícula y asignar temperaturas iniciales aleatorias
        for x = mapMinX, mapMaxX, gridSize do
            if not GridMap[x] then
                GridMap[x] = {} -- Asegurarse de que cada columna esté inicializada
            end
            for y = mapMinY, mapMaxY, gridSize do
                GridMap[x][y] = {}

                for z = mapMinZ, mapMaxZ, gridSize do
                    GridMap[x][y][z] = { temperature = math.random(minTemperature, maxTemperature), humidity = math.random(minHumidity, maxHumidity), pressure = math.random(minPressure, maxPressure), wind_speed = math.random(minWind_speed, maxWind_speed)}
                    print("Position grid: " .. x .. ", ".. y .. ", " .. z) -- Depuración
                end
            end

        end

        print("Grid generated.") -- Depuración

        -- Variables para controlar la actualización por lotes
        
        for x = mapMinX, mapMaxX, gridSize do
            for y = mapMinY, mapMaxY, gridSize do
                for z = mapMinZ, mapMaxZ, gridSize do
                    table.insert(cellsToUpdate, {x, y, z})
                end
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
                                for z = mapMinZ, mapMaxZ, gridSize do
                                    table.insert(cellsToUpdate, {x, y, z})
                                end
                            end
                        end
                        cell = table.remove(cellsToUpdate, 1)
                    end

                    if cell then
                        local x, y, z = cell[1], cell[2], cell[3]
                        if GridMap[x] and GridMap[x][y] and GridMap[x][y][z] then
                            local newTemperature = CalculateTemperature(x, y, z)
                            local newHumidity = CalculateHumidity(x, y, z)
                            local newPressure = CalculatePressure(x, y, z)
                            local newWind_speed = CalculateWindSpeed(x, y, z)
                            GridMap[x][y][z].temperature = newTemperature
                            GridMap[x][y][z].humidity = newHumidity
                            GridMap[x][y][z].pressure = newPressure
                            GridMap[x][y][z].wind_speed = newWind_speed
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
            local pz = math.floor(pos.z / gridSize ) * gridSize
            if GridMap[px] and GridMap[px][py] and GridMap[px][py][pz] then
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = CalculateTemperature(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = CalculateHumidity(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = CalculatePressure(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = CalculateWindSpeed(px, py, pz)
            end
        end)
    end

    if CLIENT then
        local maxDrawDistance = 5000 -- Distancia máxima en unidades para dibujar la cuadrícula

        hook.Add("PostDrawOpaqueRenderables", "DrawGridDebug", function()
            local playerPos = LocalPlayer():GetPos()
            local MapBounds = getMapBounds()
            local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
            local mapMinX, mapMinY, mapMaxZ = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize, math.floor(min.z / gridSize) * gridSize
            local mapMaxX, mapMaxY, mapMinZ = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize, math.ceil(max.z / gridSize) * gridSize

            for x = mapMinX, mapMaxX, gridSize do
                for y = mapMinY, mapMaxY, gridSize do
                    for z = mapMinZ, mapMaxZ, gridSize do
                        local cellCenter = Vector(x + gridSize / 2, y + gridSize / 2, z + gridSize / 2)
                        if playerPos:DistToSqr(cellCenter) < maxDrawDistance * maxDrawDistance then
                            local pos1, pos2

                            pos1 = Vector(x, y, z)
                            pos2 = Vector(x + gridSize, y, z)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y, z)
                            pos2 = Vector(x, y + gridSize, z)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y, z)
                            pos2 = Vector(x, y, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x + gridSize, y + gridSize, z + gridSize)
                            pos2 = Vector(x, y + gridSize, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x + gridSize, y + gridSize, z + gridSize)
                            pos2 = Vector(x + gridSize, y, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x + gridSize, y + gridSize, z + gridSize)
                            pos2 = Vector(x + gridSize, y + gridSize, z)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x + gridSize, y, z)
                            pos2 = Vector(x + gridSize, y, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x + gridSize, y, z)
                            pos2 = Vector(x + gridSize, y + gridSize, z)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y + gridSize, z)
                            pos2 = Vector(x, y + gridSize, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y + gridSize, z)
                            pos2 = Vector(x + gridSize, y + gridSize, z)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y, z + gridSize)
                            pos2 = Vector(x + gridSize, y, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)

                            pos1 = Vector(x, y, z + gridSize)
                            pos2 = Vector(x, y + gridSize, z + gridSize)
                            render.SetColorMaterial()
                            render.DrawLine(pos1, pos2, Color(255, 0, 0), true)
                        end
                    end
                end
            end
        end)
    end
    

    

    -- Llamar a la función para generar la cuadrícula al inicio del juego
    hook.Add("PlayerSpawn", "GenerateTemperatureGrid", GenerateGrid)
end