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
updateInterval = 1 -- Intervalo de actualización en segundos
updateBatchSize = 100 -- Número de celdas a actualizar por frame
diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor
gas_constant = 287.05
specific_heat_vapor = 2010
airflowCoefficientX = 0.1 
airflowCoefficientY = 0.1 
airflowCoefficientZ = 0.1 
waterTemperatureEffect = 10  -- Por ejemplo, un valor de temperatura predeterminado para el agua
landTemperatureEffect = 5    -- Por ejemplo, un valor de temperatura predeterminado para la tierra
lastUpdateTime = CurTime()
GridMap = {}
cellsToUpdate = {}
waterSources = {}
LandSources = {}

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

    -- Función para calcular la presión de una celda basada en temperatura y humedad
    function CalculatePressure(x, y, z)
        local temperature = GridMap[x][y][z].temperature
        local humidity = GridMap[x][y][z].humidity

        local pressure = gas_constant * temperature * (1 + (specific_heat_vapor * humidity / temperature))
        return pressure
    end

    function GetCellType(x, y, z)
        local MapBounds = getMapBounds()
        local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
        local mapMinX, mapMinY, mapMaxZ = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize, math.floor(min.z / gridSize) * gridSize
        local mapMaxX, mapMaxY, mapMinZ = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize, math.ceil(max.z / gridSize) * gridSize
        local floorz = math.ceil(floor.z / gridSize) * gridSize
        
        local MAP_WIDTH = mapMaxX - mapMinX
        local MAP_DEPTH = mapMaxY - mapMinY
        local MAP_HEIGHT = mapMaxZ - mapMinZ
        local WATER_LEVEL = floorz
        local MOUNTAIN_LEVEL = floorz + 1000

        -- Verificar si las coordenadas están dentro de los límites del mapa
        if x < 0 or x >= MAP_WIDTH or y < 0 or y >= MAP_DEPTH or z < 0 or z >= MAP_HEIGHT  then
            return "out_of_bounds" -- Devolver un tipo especial para coordenadas fuera de los límites del mapa
        end

        -- Simular diferentes tipos de celdas basadas en coordenadas
        if z <= WATER_LEVEL then
            return "water" -- Por debajo del nivel del agua es agua
        elseif z >= MOUNTAIN_LEVEL then
            return "mountain" -- Por encima del nivel de la montaña es montaña
        else
            return "land" -- En otras coordenadas es tierra
        end
    end

    -- Función para simular el flujo de aire basado en la presión
    function SimulateAirFlow(x, y, z)
        local totalDeltaPressureX = 0
        local totalDeltaPressureY = 0
        local totalDeltaPressureZ = 0

        -- Calcular la diferencia de presión entre las celdas vecinas
        for i = -1, 1 do
            for j = -1, 1 do
                for k = -1, 1 do
                    if i ~= 0 or j ~= 0 or k ~= 0 then -- Evitar la celda actual
                        local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                            local deltaPressureX = GridMap[nx][ny][nz].pressure - GridMap[x][y][z].pressure
                            local deltaPressureY = GridMap[nx][ny][nz].pressure - GridMap[x][y][z].pressure
                            local deltaPressureZ = GridMap[nx][ny][nz].pressure - GridMap[x][y][z].pressure
                            totalDeltaPressureX = totalDeltaPressureX + deltaPressureX
                            totalDeltaPressureY = totalDeltaPressureY + deltaPressureY
                            totalDeltaPressureZ = totalDeltaPressureZ + deltaPressureZ
                        end
                    end
                end
            end
        end

        -- Ajustar la velocidad del flujo de aire en función de la diferencia de presión
        local airflowX = totalDeltaPressureX * airflowCoefficientX
        local airflowY = totalDeltaPressureY * airflowCoefficientY
        local airflowZ = totalDeltaPressureZ * airflowCoefficientZ

        return Vector(airflowX, airflowY, airflowZ)
    end
   
    -- Función para obtener la distancia a la fuente más cercana
    function GetClosestDistance(x, y, z, sources)
        local closestDistance = math.huge

        for _, source in ipairs(sources) do
            local distance = GetDistance(x, y, z, source.x, source.y, source.z)
            if distance < closestDistance then
                closestDistance = distance
            end
        end

        return closestDistance
    end

    lastUpdateTime = CurTime()

    function AddTemperatureHumiditySources()    
        local waterSources = GetWaterSources()
        local landSources = GetLandSources()

        for x, column in pairs(GridMap) do
            for y, row in pairs(column) do
                for z, cell in pairs(row) do
                    local closestWaterDist = GetClosestDistance(x, y, z, waterSources)
                    local closestLandDist = GetClosestDistance(x, y, z, landSources)

                    if closestWaterDist < closestLandDist then
                        cell.temperature = cell.temperature - waterTemperatureEffect
                        cell.humidity = math.min(maxHumidity, cell.humidity + waterHumidityEffect)
                    else
                        cell.temperature = cell.temperature + landTemperatureEffect
                        cell.humidity = math.max(minHumidity, cell.humidity - landHumidityEffect)
                    end
                end
            end
        end
    end

    -- Función para obtener las coordenadas de las fuentes de agua
    function GetWaterSources()
        local waterSources = {}

        local mapBounds = getMapBounds()
        local minX, minY, maxZ = mapBounds[2].x, mapBounds[2].y, mapBounds[2].z
        local maxX, maxY, minZ = mapBounds[1].x, mapBounds[1].y, mapBounds[1].z

        for x = minX, maxX do
            for y = minY, maxY do
                for z = minZ, maxZ do
                    if GetCellType(x, y, z) == "water" then
                        table.insert(waterSources, {x = x, y = y, z = z})
                    end
                end
            end
        end

        return waterSources
    end

    -- Función para obtener las coordenadas de las fuentes de tierra
    function GetLandSources()
        local landSources = {}

        local mapBounds = getMapBounds()
        local minX, minY, maxZ = mapBounds[2].x, mapBounds[2].y, mapBounds[2].z
        local maxX, maxY, minZ = mapBounds[1].x, mapBounds[1].y, mapBounds[1].z

        for x = minX, maxX do
            for y = minY, maxY do
                for z = minZ, maxZ do
                    if GetCellType(x, y, z) == "land" then
                        table.insert(landSources, {x = x, y = y, z = z})
                    end
                end
            end
        end

        return landSources
    end


    local function SpawnCloud(pos, airflow)
        local cloud = ents.Create("gd_cloud_cumulus")
        cloud:SetPos(pos)

        -- Aplicar el flujo de aire a la velocidad de movimiento de la nube
        local velocity = Vector(airflow.x, airflow.y, airflow.z) * 10 -- Ajusta el factor de escala según sea necesario
        cloud:SetVelocity(velocity)

        return cloud
    end

    -- Función para simular la formación y movimiento de nubes
    function SimulateClouds()
        for x, column in pairs(GridMap) do
            for y, row in pairs(column) do
                for z, cell in pairs(row) do
                    local airflow = SimulateAirFlow(x, y, z)
                    local pos = Vector(x, y, z) * gridSize
                    SpawnCloud(pos, airflow)
                end
            end
        end
    end

    -- Llamar a SimulateClouds() para simular la formación y movimiento de las nubes
    function UpdateWeather()
        SimulateClouds()
    end

    -- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
    function GenerateGrid(ply)
        if CLIENT then return end

        -- Obtener los límites del mapa
        local mapBounds = getMapBounds()
        local minX, minY, maxZ = math.floor(mapBounds[2].x / gridSize) * gridSize, math.floor(mapBounds[2].y / gridSize) * gridSize, math.ceil(mapBounds[2].z / gridSize) * gridSize
        local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gridSize) * gridSize, math.ceil(mapBounds[1].y / gridSize) * gridSize, math.ceil(mapBounds[1].z / gridSize) * gridSize

        print("Generating grid...") -- Depuración

        -- Inicializar la cuadrícula
        for x = minX, maxX, gridSize do
            GridMap[x] = {}
            for y = minY, maxY, gridSize do
                GridMap[x][y] = {}
                for z = minZ, maxZ, gridSize do
                    GridMap[x][y][z] = {
                        temperature = math.random(minTemperature, maxTemperature),
                        humidity = math.random(minHumidity, maxHumidity),
                        pressure = math.random(minPressure, maxPressure),
                        airflow = Vector(0, 0, 0)
                    }
                    print("Position grid: " .. x .. ", ".. y .. ", " .. z) -- Depuración
                end
            end
        end

        print("Grid generated.") -- Depuración

        -- Actualizar la cuadrícula
        hook.Add("Think2", "UpdateTemperatureGrid", function()
            -- Actualizar un lote de celdas
            for i = 1, updateBatchSize do
                local cell = table.remove(cellsToUpdate, 1)
                if not cell then
                    -- Reiniciar la lista de celdas para actualizar
                    cellsToUpdate = {}
                    for x = minX, maxX, gridSize do
                        for y = minY, maxY, gridSize do
                            for z = minZ, maxZ, gridSize do
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
                        local newAirFlow = SimulateAirFlow(x, y, z)
                        GridMap[x][y][z].temperature = newTemperature
                        GridMap[x][y][z].humidity = newHumidity
                        GridMap[x][y][z].pressure = newPressure
                        GridMap[x][y][z].airflow = newAirFlow
                    end
                end
            end
        end)

        -- Actualizar la temperatura alrededor del jugador
        hook.Add("Think", "UpdatePlayerAreaTemperature_" .. ply:SteamID(), function()
            local pos = ply:GetPos()
            local px, py, pz = math.floor(pos.x / gridSize) * gridSize, math.floor(pos.y / gridSize) * gridSize, math.floor(pos.z / gridSize) * gridSize
            if GridMap[px] and GridMap[px][py] and GridMap[px][py][pz] then
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = CalculateTemperature(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = CalculateHumidity(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = CalculatePressure(px, py, pz)
                GLOBAL_SYSTEM_TARGET["Atmosphere"]["AirFlow"] = SimulateAirFlow(px, py, pz)
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
    hook.Add("Think3", "UpdateTemperatureHumidity", function()
        AddTemperatureHumiditySources()
    end)
end