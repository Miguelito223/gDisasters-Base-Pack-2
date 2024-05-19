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
        local MAP_WIDTH = mapMaxX - mapMinX
        local MAP_DEPTH = mapMaxY - mapMinY
        local MAP_HEIGHT = mapMaxZ - mapMinZ
        -- Verificar si las coordenadas están dentro de los límites del mapa
        if x < 0 or x >= MAP_WIDTH or y < 0 or y >= MAP_DEPTH or z < 0 or z >= MAP_HEIGHT  then
            return "out_of_bounds" -- Devolver un tipo especial para coordenadas fuera de los límites del mapa
        end

        -- Simular diferentes tipos de celdas basadas en coordenadas
        if y <= WATER_LEVEL then
            return "water" -- Por debajo del nivel del agua es agua
        elseif y >= MOUNTAIN_LEVEL then
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

        return airflowX, airflowY, airflowZ
    end
   
    function GetClosestDistance(x1, y1, z1, x2, y2, z2)
        local dx = x2 - x1
        local dy = y2 - y1
        local dz = z2 - z1
        return math.sqrt(dx*dx + dy*dy + dz*dz)
    end
    
    -- Función para encontrar la fuente de agua más cercana a un punto dado
    function GetClosestWaterSource(x, y, z, source)
        local closestDistance = math.huge
        local closestSource = nil

        for _, source in ipairs(source) do
            local distance = GetClosestDistance(x, y, z, source.x, source.y, source.z)
            if distance < closestDistance then
                closestDistance = distance
                closestSource = source
            end
        end

        return closestSource, closestDistance
    end

    function AddTemperatureHumiditySources()
        local waterSources = GetWaterSources() -- Obtener las coordenadas de las fuentes de agua
        local landSources = GetLandSources() -- Obtener las coordenadas de las fuentes de tierra

        -- Iterar sobre todas las celdas en la cuadrícula
        for x, column in pairs(GridMap) do
            for y, row in pairs(column) do
                for z, cell in pairs(row) do
                    -- Calcular la distancia a las fuentes de agua y tierra más cercanas
                    local closestWaterDist = GetClosestDistance(x, y, z, waterSources)
                    local closestLandDist = GetClosestDistance(x, y, z, landSources)

                    -- Ajustar la temperatura y la humedad en función de las fuentes de agua y tierra
                    if closestWaterDist < closestLandDist then
                        -- La celda está más cerca del agua que de la tierra
                        GridMap[x][y][z].temperature = GridMap[x][y][z].temperature - waterTemperatureEffect
                        GridMap[x][y][z].humidity = math.min(maxHumidity, GridMap[x][y][z].humidity + waterHumidityEffect)
                    else
                        -- La celda está más cerca de la tierra que del agua
                        GridMap[x][y][z].temperature = GridMap[x][y][z].temperature + landTemperatureEffect
                        GridMap[x][y][z].humidity = math.max(minHumidity, GridMap[x][y][z].humidity - landHumidityEffect)
                    end
                end
            end
        end
    end

    function GetWaterSources()
        local waterSources = {} -- Lista para almacenar las coordenadas de las fuentes de agua

        -- Supongamos que tienes una función GetCellType(x, y, z) que devuelve el tipo de la celda en las coordenadas dadas
        -- Esta función podría ser proporcionada por tu motor de juego o implementada por ti mismo

        local mapBounds = getMapBounds() -- Obtener los límites del mapa
        local minX, minY, maxZ = mapBounds[2].x, mapBounds[2].y, mapBounds[2].z -- Límites mínimos del mapa
        local maxX, maxY, minZ = mapBounds[1].x, mapBounds[1].y, mapBounds[1].z -- Límites máximos del mapa

        -- Recorrer el mapa para encontrar las fuentes de agua
        for x = minX, maxX do
            for y = minY, maxY do
                for z = minZ, maxZ do
                    if GetCellType(x, y, z) == "water" then
                        table.insert(waterSources, {x = x, y = y, z = z}) -- Agregar las coordenadas de la fuente de agua
                    end
                end
            end
        end

        return waterSources
    end

    -- Función para detectar automáticamente las fuentes de tierra en el entorno del juego
    function GetLandSources()
        local landSources = {} -- Lista para almacenar las coordenadas de las fuentes de tierra

        -- Supongamos que tienes una función GetCellType(x, y, z) que devuelve el tipo de la celda en las coordenadas dadas
        -- Esta función podría ser proporcionada por tu motor de juego o implementada por ti mismo

        local mapBounds = getMapBounds() -- Obtener los límites del mapa
        local minX, minY, minZ = mapBounds[2].x, mapBounds[2].y, mapBounds[2].z -- Límites mínimos del mapa
        local maxX, maxY, maxZ = mapBounds[1].x, mapBounds[1].y, mapBounds[1].z -- Límites máximos del mapa

        -- Recorrer el mapa para encontrar las fuentes de tierra
        for x = minX, maxX do
            for y = minY, maxY do
                for z = minZ, maxZ do
                    if GetCellType(x, y, z) == "land" then
                        table.insert(landSources, {x = x, y = y, z = z}) -- Agregar las coordenadas de la fuente de tierra
                    end
                end
            end
        end

        return landSources
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
                    GridMap[x][y][z] = { temperature = math.random(minTemperature, maxTemperature), humidity = math.random(minHumidity, maxHumidity), pressure = math.random(minPressure, maxPressure), SimulateAirFlow = Vector(0,0,0)}
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
                            local newSimulateAirFlow = SimulateAirFlow(x, y, z)
                            GridMap[x][y][z].temperature = newTemperature
                            GridMap[x][y][z].humidity = newHumidity
                            GridMap[x][y][z].pressure = newPressure
                            GridMap[x][y][z].SimulateAirFlow = newSimulateAirFlow
                            
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
    hook.Add("Think", "AddTemperatureHumiditySources", AddTemperatureHumiditySources)
end