-- Tamaño de la cuadrícula y rango de temperatura
gridSize = 1000 -- Tamaño de cada cuadrado en unidades

minTemperature = -44.00 -- Temperatura mínima
maxTemperature = 44.00 -- Temperatura máxima
minHumidity = 0 -- Humedad mínima
maxHumidity = 100 -- Humedad máxima
minPressure = 94000 -- Presión mínima en milibares
maxPressure = 106000 -- Presión máxima en milibares

updateInterval = 1 -- Intervalo de actualización en segundos
updateBatchSize = 100 -- Número de celdas a actualizar por frame
nextUpdateGrid = CurTime()
nextUpdateGridPlayer = CurTime()
nextUpdateWeather = CurTime()
nextThunderThink = CurTime()

diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor
gas_constant = 8.314
specific_heat_vapor = 1.996
AirflowCoefficient = 0.1
N = 100

waterTemperatureEffect = 0.2  -- El agua tiende a mantener una temperatura más constante
landTemperatureEffect = 0.5    -- La tierra se calienta y enfría más rápido que el agua
waterHumidityEffect = 0.5      -- El agua puede aumentar la humedad en su entorno
landHumidityEffect = 0.2       -- La tierra puede retener menos humedad que el agua
mountainTemperatureEffect = -0.5  -- Las montañas tienden a ser más frías debido a la altitud
mountainHumidityEffect = 0.5    -- Las montañas pueden influir en la humedad debido a las corrientes de aire

rainThreshold = 0.8 -- Umbral de humedad para la generación de lluvia
cloudThreshold = 0.6
strongStormThreshold = 0.9
convergenceThreshold = 0.7
stormTemperatureThreshold = 30 -- Umbral de temperatura para la generación de tormentas
stormPressureThreshold = 100000 -- Umbral de presión para la generación de tormentas
lowTemperatureThreshold = 10
lowHumidityThreshold =  40
MaxClouds = 5
MaxRainDrop = 5
MaxHail = 5

maxDrawDistance = 100000

GridMap = {}
cellsToUpdate = {}

waterSources = {}
LandSources = {}

Cloud = {}

function CalculateTemperature(x, y, z)
    local totalTemperature = 0
    local totalAirFlow = {0, 0, 0} -- Para almacenar la suma de los componentes del flujo de aire
    local count = 0

    -- Definir los vecinos y sus desplazamientos
    local neighbors = {
        {dx = -1, dy = 0, dz = 0},  -- Izquierda
        {dx = 1, dy = 0, dz = 0},   -- Derecha
        {dx = 0, dy = -1, dz = 0},  -- Arriba
        {dx = 0, dy = 1, dz = 0},   -- Abajo
        {dx = 0, dy = 0, dz = -1},  -- Atrás
        {dx = 0, dy = 0, dz = 1}    -- Adelante
    }

    -- Ajustar la temperatura de las celdas vecinas y sumar la temperatura y el flujo de aire
    for _, neighbor in pairs(neighbors) do
        local nx, ny, nz = x + neighbor.dx * gridSize, y + neighbor.dy * gridSize, z + neighbor.dz * gridSize
        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
            local neighborCell = GridMap[nx][ny][nz]
            if neighborCell.temperature and neighborCell.Airflow then
                totalTemperature = totalTemperature + neighborCell.temperature
                totalAirFlow[1] = totalAirFlow[1] + (neighborCell.Airflow[1] or 0)
                totalAirFlow[2] = totalAirFlow[2] + (neighborCell.Airflow[2] or 0)
                totalAirFlow[3] = totalAirFlow[3] + (neighborCell.Airflow[3] or 0)
                count = count + 1
            end
        end
    end

    -- Si no hay celdas vecinas válidas, retornar la temperatura actual
    if count == 0 then return GridMap[x][y][z].temperature end

    -- Calcular la temperatura promedio de las vecinas
    local averageTemperature = totalTemperature / count

    -- Calcular el flujo de aire promedio
    local averageAirFlow = {
        totalAirFlow[1] / count,
        totalAirFlow[2] / count,
        totalAirFlow[3] / count
    }

    -- Ajustar la temperatura de la celda actual basada en la difusión de calor
    local currentTemperature = GridMap[x][y][z].temperature
    local temperatureInfluence = GridMap[x][y][z].temperatureInfluence
    local AirflowEffect = AirflowCoefficient * (averageAirFlow[1] + averageAirFlow[2] + averageAirFlow[3])
    local temperatureChange = diffusionCoefficient * (averageTemperature - currentTemperature)

    -- Calcular la nueva temperatura
    local newTemperature = currentTemperature + temperatureChange + AirflowEffect + temperatureInfluence

    -- Asegurarse de que la temperatura esté dentro del rango
    return math.max(minTemperature, math.min(maxTemperature, newTemperature))
end

function CalculateHumidity(x, y, z)
    local totalHumidity = 0
    local count = 0

    -- Definir los vecinos y sus desplazamientos
    local neighbors = {
        {dx = -1, dy = 0, dz = 0},  -- Izquierda
        {dx = 1, dy = 0, dz = 0},   -- Derecha
        {dx = 0, dy = -1, dz = 0},  -- Arriba
        {dx = 0, dy = 1, dz = 0},   -- Abajo
        {dx = 0, dy = 0, dz = -1},  -- Atrás
        {dx = 0, dy = 0, dz = 1}    -- Adelante
    }

    -- Ajustar la humedad de las celdas vecinas
    for _, neighbor in pairs(neighbors) do
        local nx, ny, nz = x + neighbor.dx * gridSize, y + neighbor.dy * gridSize, z + neighbor.dz * gridSize
        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
            local neighborCell = GridMap[nx][ny][nz]
            if neighborCell.humidity then
                totalHumidity = totalHumidity + neighborCell.humidity
                count = count + 1
            end
        end
    end

    -- Si no hay celdas vecinas válidas, retornar la humedad actual
    if count == 0 then return GridMap[x][y][z].humidity end

    -- Ajustar la humedad de la celda actual basada en la difusión de humedad
    local averageHumidity = totalHumidity / count
    local currentHumidity = GridMap[x][y][z].humidity
    local humidityInfluence = GridMap[x][y][z].humidityInfluence
    local humidityChange = diffusionCoefficient * (averageHumidity - currentHumidity)

    -- Calcular la nueva humedad
    local newHumidity = currentHumidity + humidityChange + humidityInfluence

    -- Asegurarse de que la humedad esté dentro del rango
    return math.max(minHumidity, math.min(maxHumidity, newHumidity))
end

-- Función para calcular la presión de una celda basada en temperatura y humedad
function CalculatePressure(x, y, z)
    local cell = GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = cell.temperature or 0 
    
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local humidity = cell.humidity or 0

    -- Calcular la presión basada en la temperatura y la humedad
    local newpressure = (gas_constant * temperature * (1 + ((specific_heat_vapor * humidity) / temperature))) * 100
    
    -- Transmitir la presión a las celdas vecinas
    local neighbors = {
        {dx = -1, dy = 0, dz = 0},  -- Izquierda
        {dx = 1, dy = 0, dz = 0},   -- Derecha
        {dx = 0, dy = -1, dz = 0},  -- Arriba
        {dx = 0, dy = 1, dz = 0},   -- Abajo
        {dx = 0, dy = 0, dz = -1},  -- Atrás
        {dx = 0, dy = 0, dz = 1}    -- Adelante
    }

    local pressureChangeFactor = 0.1 -- Factor de cambio de presión entre celdas vecinas

    for _, neighbor in pairs(neighbors) do
        local nx, ny, nz = x + neighbor.dx, y + neighbor.dy, z + neighbor.dz
        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
            local neighborCell = GridMap[nx][ny][nz]
            if neighborCell.pressure then
                -- Calcular la diferencia de presión y ajustar la presión de la celda vecina
                local pressureDifference = newpressure - neighborCell.pressure
                neighborCell.pressure = neighborCell.pressure + pressureDifference * pressureChangeFactor
            end
        end
    end

    -- Asegurarse de que la presión esté dentro del rango
    return math.max(minPressure, math.min(maxPressure, newpressure))
end

function GetCellType(x, y, z)
    local MapBounds = getMapBounds()
    local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
    local minX, minY, maxZ = math.floor(min.x / gridSize) * gridSize, math.floor(min.y / gridSize) * gridSize,  math.ceil(min.z / gridSize) * gridSize
    local maxX, maxY, minZ = math.ceil(max.x / gridSize) * gridSize, math.ceil(max.y / gridSize) * gridSize,  math.floor(max.z / gridSize) * gridSize
    local floorz = math.floor(floor.z / gridSize) * gridSize

    -- Verificar si las coordenadas están dentro de los límites del mapa
    if x < minX or x >= maxX or y < minY or y >= maxY or z < minZ or z >= maxZ then
        return "out_of_bounds" -- Devolver un tipo especial para coordenadas fuera de los límites del mapa
    end
    
    local traceStart = Vector(x, y, z)
    local traceEnd = traceStart - Vector(0, 0, 10) 
    traceEnd.z = math.max(traceEnd.z, minZ)
    local tr = util.TraceLine( {
        startpos = traceStart,
        endpos = traceEnd,
        mask = MASK_WATER, -- Solo colisionar con agua
        filter = function(ent) return ent:IsValid() end  -- Filtrar cualquier entidad válida
    } )

    -- Si el trazado de línea colisiona con agua, la celda es de tipo "water"
    if tr.Hit then
        return "water"
    end

    local WATER_LEVEL = tr.HitPos.z
    local MOUNTAIN_LEVEL = floorz + 50000 -- Ajusta la altura de la montaña según sea necesario

    -- Simular diferentes tipos de celdas basadas en coordenadas
    if z <= WATER_LEVEL then
        return "water" -- Por debajo del nivel del agua es agua
    elseif z >= MOUNTAIN_LEVEL then
        return "mountain" -- Por encima del nivel de la montaña es montaña
    else
        return "land" -- En otras coordenadas es tierra
    end
end

function CalculateAirFlow(x, y, z)
    local totalDeltaPressureX = 0
    local totalDeltaPressureY = 0
    local totalDeltaPressureZ = 0

    -- Calcular la diferencia de presión entre las celdas vecinas y sumarlas
    for i = -1, 1 do
        for j = -1, 1 do
            for k = -1, 1 do
                if i ~= 0 or j ~= 0 or k ~= 0 then -- Evitar la celda actual
                    local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                    if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                        local neighborCell = GridMap[nx][ny][nz]
                        local currentCell = GridMap[x][y][z]

                        -- Diferencia de presión específica para cada eje
                        local deltaPressureX = neighborCell.pressure - currentCell.pressure
                        local deltaPressureY = neighborCell.pressure - currentCell.pressure
                        local deltaPressureZ = neighborCell.pressure - currentCell.pressure
                        
                        -- Sumar la diferencia de presión al total en cada eje
                        totalDeltaPressureX = totalDeltaPressureX + deltaPressureX
                        totalDeltaPressureY = totalDeltaPressureY + deltaPressureY
                        totalDeltaPressureZ = totalDeltaPressureZ + deltaPressureZ
                    end
                end
            end
        end
    end

    -- Ajustar la velocidad del flujo de aire en función de la diferencia de presión
    local AirflowX = totalDeltaPressureX * AirflowCoefficient
    local AirflowY = totalDeltaPressureY * AirflowCoefficient
    local AirflowZ = totalDeltaPressureZ * AirflowCoefficient

    -- Transmitir el flujo de aire a las celdas vecinas
    local neighbors = {
        {dx = -1, dy = 0, dz = 0},  -- Izquierda
        {dx = 1, dy = 0, dz = 0},   -- Derecha
        {dx = 0, dy = -1, dz = 0},  -- Arriba
        {dx = 0, dy = 1, dz = 0},   -- Abajo
        {dx = 0, dy = 0, dz = -1},  -- Atrás
        {dx = 0, dy = 0, dz = 1}    -- Adelante
    }

    for _, neighbor in pairs(neighbors) do
        local nx, ny, nz = x + neighbor.dx, y + neighbor.dy, z + neighbor.dz
        if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
            local neighborCell = GridMap[nx][ny][nz]
            neighborCell.Airflow = {AirflowX, AirflowY, AirflowZ}
        end
    end

    return {AirflowX, AirflowY, AirflowZ}
end


-- Función para crear partículas de lluvia
function CreateRain(x, y, z)

    if #ents.FindByClass("env_spritetrail") > MaxRainDrop then return end

    local particle = ents.Create("env_spritetrail") -- Create a sprite trail entity for raindrop particle
    if not IsValid(particle) then return end -- Verifica si la entidad fue creada correctamente

    particle:SetPos(Vector(x * gridSize, y * gridSize, z * gridSize)) -- Set the position of the particle
    particle:SetKeyValue("lifetime", "2") -- Set the lifetime of the particle
    particle:SetKeyValue("startwidth", "2") -- Set the starting width of the particle
    particle:SetKeyValue("endwidth", "0") -- Set the ending width of the particle
    particle:SetKeyValue("spritename", "effects/blood_core") -- Set the sprite name for the particle (you can use any sprite)
    particle:SetKeyValue("rendermode", "5") -- Set the render mode of the particle
    particle:SetKeyValue("rendercolor", "0 0 255") -- Set the color of the particle (blue for rain)
    particle:SetKeyValue("spawnflags", "1") -- Set the spawn flags for the particle
    particle:Spawn() -- Spawn the particle
    particle:Activate() -- Activate the particle

    timer.Simple(2, function() -- Remove the particle after 2 seconds
        if IsValid(particle) then particle:Remove() end
    end)
end




function CreateLightningAndThunder(x,y,z)
    if CurTime() > nextThunderThink then
        local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
        nextThunderThink = CurTime() + t
        
        local startpos = Vector(x,y,z)
        local endpos = startpos - Vector(0, 0, 50000)
        local tr = util.TraceLine({
            start = startpos,
            endpos = endpos,
        })
        if HitChance(1) then
            CreateLightningBolt(startpos, tr.HitPos, {"purple", "blue"}, {"Grounded", "NotGrounded"})
        end
    end
end

function SpawnCloud(pos, Airflow, color)
    if #ents.FindByClass("gd_cloud_cumulus") > MaxClouds then return end

    local cloud = ents.Create("gd_cloud_cumulus")
    if not IsValid(cloud) then return end -- Verifica si la entidad fue creada correctamente

    cloud:SetPos(pos)
    cloud.DefaultColor = color
    cloud:SetModelScale(0.5, 0)
    cloud:Spawn()
    cloud:Activate()

    table.insert(Cloud, cloud)

    -- Aplicar el flujo de aire a la velocidad de movimiento de la nube
    local velocity = Vector(Airflow.x, Airflow.y, Airflow.z) * 10 -- Ajusta el factor de escala según sea necesario
    cloud:SetVelocity(velocity)

    timer.Simple(cloud.Life, function()
        if IsValid(cloud) then cloud:Remove() end
    end)

    return cloud
    
end

-- Función para simular la formación y movimiento de nubes
function CreateClouds(x,y,z)
    local cell = GridMap[x][y][z]

    local humidity = cell.humidity
    local temperature = cell.temperature
    if humidity < lowHumidityThreshold and temperature < lowTemperatureThreshold then
        -- Generate clouds in cells with low humidity and temperature
        AdjustCloudBaseHeight(x, y, z)
        
        local airflow = GridMap[x][y][z].VecAirflow
        local baseHeight = cell.baseHeight or (z * gridSize)
        local pos = Vector(x * gridSize, y * gridSize, baseHeight)
        local color = Color(255,255,255)
        
        SpawnCloud(pos, airflow, color)
        
        
    end
    
end

-- Función para simular la formación y movimiento de nubes
function CreateStorm(x,y,z)
    local cell = GridMap[x][y][z]

    local humidity = cell.humidity
    local temperature = cell.temperature
    if humidity < lowHumidityThreshold and temperature < lowTemperatureThreshold then
        AdjustCloudBaseHeight(x, y, z)

        -- Generate clouds in cells with low humidity and temperature
        local airflow = GridMap[x][y][z].VecAirflow
        local baseHeight = cell.baseHeight or (z * gridSize)
        local pos = Vector(x * gridSize, y * gridSize, baseHeight)
        local color = Color(117,117,117)
        
        SpawnCloud(pos, airflow, color)
        CreateLightningAndThunder(x,y,z)
        
    end
    
end

function GetDistance(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
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

function AddTemperatureHumiditySources()
    print("Adding Sources...")
    local waterSources = GetWaterSources()
    local landSources = GetLandSources()
    local mountainSources = GetMountainSources()

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local closestWaterDist = GetClosestDistance(x, y, z, waterSources)
                local closestLandDist = GetClosestDistance(x, y, z, landSources)
                local closestMountainDist = GetClosestDistance(x, y, z, mountainSources)


                -- Comparar distancias y ajustar temperatura, humedad y presión en consecuencia
                if closestWaterDist < closestLandDist and closestWaterDist < closestMountainDist then
                    cell.terrainType = "water"
                    cell.temperatureInfluence = -waterTemperatureEffect
                    cell.humidityInfluence = waterHumidityEffect
                elseif closestLandDist < closestMountainDist and closestLandDist < closestWaterDist then
                    cell.terrainType = "land"
                    cell.temperatureInfluence = landTemperatureEffect
                    cell.humidityInfluence = -landTemperatureEffect
                else
                    cell.terrainType = "mountain"
                    cell.temperatureInfluence = mountainTemperatureEffect
                    cell.humidityInfluence = -mountainHumidityEffect
                end 
            end
        end
    end

    print("Adding Finish")
end

-- Función para obtener las coordenadas de las fuentes de agua
function GetWaterSources()
    local waterSources = {}

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = GetCellType(x, y, z)
                if celltype == "water" then
                    table.insert(waterSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return waterSources
end

-- Función para obtener las coordenadas de las fuentes de tierra
function GetLandSources()
    local landSources = {}

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = GetCellType(x, y, z)
                if celltype == "land" then
                    table.insert(landSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return landSources
end

function GetMountainSources()
    local MountainSources = {}

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = GetCellType(x, y, z)
                if celltype == "mountain" then
                    table.insert(MountainSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return MountainSources
end

function AdjustCloudBaseHeight(x,y,z)
    local nubegrid = GridMap[x][y][z]
    local humidity = nubegrid.humidity or 0
    local baseHeightAdjustment = (1 - humidity) * 0.1
    
    nubegrid.baseHeight = (nubegrid.baseHeight or 0) + baseHeightAdjustment
    return nubegrid.baseHeight
end

function SimulateRain()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, nubegrid in pairs(row) do
                CreateRain(x, y, z)

                local coolingFactor = 0.1  -- Factor base de enfriamiento
                local pressureIncreaseFactor = 0.2  -- Factor base de aumento de presión
                
                local originalTemperature = nubegrid.temperature or 0
                local originalHumidity = nubegrid.humidity or 0

                -- Cálculo de enfriamiento y aumento de presión basado en la humedad
                local humidityModifier = 1 - originalHumidity  -- Más seco = más enfriamiento y aumento de presión

                local temperatureChange = coolingFactor * humidityModifier
                local pressureChange = pressureIncreaseFactor * humidityModifier

                nubegrid.temperature = originalTemperature - temperatureChange
                nubegrid.pressure = (nubegrid.pressure or 0) + pressureChange


            end
        end
    end
end

function CreateHail(x, y, z)
    if #ents.FindByClass("gd_d1_hail_ch") > MaxHail then return end
    
    local hail = ents.Create("gd_d1_hail_ch")
    hail:SetPos(Vector(x * gridSize, y * gridSize, z * gridSize))
    hail:Spawn()
    hail:Activate()

    timer.Simple(2, function() -- Remove the particle after 2 seconds
        if IsValid(hail) then hail:Remove() end
    end)
end

function SimulateHail()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, nubegrid in pairs(row) do
                local convergenceFactor = 0.3
                local temperatureThreshold = 0.5
                local humidityThreshold = 0.8

                if nubegrid.humidity > humidityThreshold and nubegrid.temperature < temperatureThreshold then
                    CreateHail(x, y, z)
                end
            end
        end
    end
end
function SimulateConvergence()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local convergenceStrength = 0
                local airSpeedSum = 0
                local neighborCount = 0

                for dx = -1, 1 do
                    for dy = -1, 1 do
                        for dz = -1, 1 do
                            if not (dx == 0 and dy == 0 and dz == 0) then -- Evitar la celda actual
                                local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                                if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                                    local neighborCell = GridMap[nx][ny][nz]
                                    local airSpeed = math.abs((cell.pressure or 0) - (neighborCell.pressure or 0))
                                    airSpeedSum = airSpeedSum + airSpeed
                                    neighborCount = neighborCount + 1
                                end
                            end
                        end
                    end
                end

                if neighborCount > 0 then
                    convergenceStrength = airSpeedSum / neighborCount

                    if convergenceStrength > convergenceThreshold then
                        if convergenceStrength > strongStormThreshold then
                            CreateStorm(x, y, z)
                        elseif convergenceStrength > rainThreshold then
                            CreateRain(x, y, z)
                        elseif convergenceStrength > cloudThreshold then
                            CreateCloud(x, y, z)
                        end
                    end
                end
            end
        end
    end
end



-- Llamar a SimulateClouds() para simular la formación y movimiento de las nubes
function UpdateWeather()
    if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then
        if CLIENT then return end
        if CurTime() > nextUpdateWeather then
            nextUpdateWeather = CurTime() + updateInterval
            SimulateConvergence()
        end
    end
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
function GenerateGrid(ply)
    -- Obtener los límites del mapa
    local mapBounds = getMapBounds()
    local minX, minY, maxZ = math.floor(mapBounds[2].x / gridSize) * gridSize, math.floor(mapBounds[2].y / gridSize) * gridSize, math.ceil(mapBounds[2].z / gridSize) * gridSize
    local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gridSize) * gridSize, math.ceil(mapBounds[1].y / gridSize) * gridSize, math.floor(mapBounds[1].z / gridSize) * gridSize

    print("Generating grid...") -- Depuración

    -- Inicializar la cuadrícula
    for x = minX, maxX, gridSize do
        GridMap[x] = {}
        for y = minY, maxY, gridSize do
            GridMap[x][y] = {}
            for z = minZ, maxZ, gridSize do
                GridMap[x][y][z] = {}
                GridMap[x][y][z].temperature = math.random(minTemperature, maxTemperature)
                GridMap[x][y][z].humidity = math.random(minHumidity, maxHumidity)
                GridMap[x][y][z].pressure = math.random(minPressure, maxPressure)
                GridMap[x][y][z].Airflow = {0,0,0}
                GridMap[x][y][z].VecAirflow = Vector(0,0,0)
            end
        end
    end

    print("Grid generated.") -- Depuración

end

function UpdateGrid()
    if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then
        for i= 1, updateBatchSize do
            local cell = table.remove(cellsToUpdate, 1)
            if not cell then
                -- Reiniciar la lista de celdas para actualizar
                cellsToUpdate = {}
                for x, column in pairs(GridMap) do
                    for y, row in pairs(column) do
                        for z, cell in pairs(row) do
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
                    local newAirFlow = CalculateAirFlow(x, y, z)
                    GridMap[x][y][z].temperature = newTemperature
                    GridMap[x][y][z].humidity = newHumidity
                    GridMap[x][y][z].pressure = newPressure
                    GridMap[x][y][z].Airflow = newAirFlow
                    GridMap[x][y][z].VecAirflow = Vector(newAirFlow[1], newAirFlow[2], newAirFlow[3])
                else
                    print("Error: Cell position out of grid bounds.")
                end
            end
        end
    end
end
function UpdatePlayerGrid()
    if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then
        for k,ply in pairs(player.GetAll()) do
            local pos = ply:GetPos()
            local px, py, pz = math.floor(pos.x / gridSize) * gridSize, math.floor(pos.y / gridSize) * gridSize, math.floor(pos.z / gridSize) * gridSize
            
            -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
            if GridMap[px] and GridMap[px][py] and GridMap[px][py][pz] then
                local cell = GridMap[px][py][pz]

                -- Verifica si las propiedades de la celda son válidas
                if cell.temperature and cell.humidity and cell.pressure then
                    -- Actualiza las variables de la atmósfera del jugador
                    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = cell.temperature
                    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = cell.humidity
                    GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = cell.pressure
                else
                    -- Manejo de valores no válidos
                    print("Error: Valores no válidos en la celda de la cuadrícula.")
                end
            else
                -- Manejo de celdas fuera de los límites de la cuadrícula
                print("Error: Posición fuera de los límites de la cuadrícula.")
            end
        end
    end
end

function TemperatureToColor(temperature)
    -- Define una función simple para convertir la temperatura en un color
    local r = math.Clamp(temperature / 100, 0, 1)
    local b = math.Clamp(1 - r, 0, 1)
    return Color(r * 255, 0, b * 255)
end

function DrawGridDebug()
    if GetConVar("gdisasters_graphics_draw_heatsystem_grid"):GetInt() >= 1 then 
        local playerPos = LocalPlayer():GetPos()
        
        -- Verificar existencia de GridMap y maxDrawDistance
        if not GridMap then
            print("GridMap is not defined.")
            return
        end
        
        -- Verificar existencia de maxDrawDistance y gridSize
        if not maxDrawDistance or not gridSize then
            print("maxDrawDistance or gridSize is not defined.")
            return
        end

        for x, column in pairs(GridMap) do
            for y, row in pairs(column) do
                for z, cell in pairs(row) do
                    local cellpos = Vector(x, y, z)
                    if cell then
                        local temperature = cell.temperature or 0
                        local color = TemperatureToColor(temperature) or Color(255, 255, 255)  -- Asegúrate de que siempre haya un color

                        render.SetColorMaterial()
                        render.DrawBox(cellpos, Angle(0, 0, 0), Vector(-gridSize / 2, -gridSize / 2, -gridSize / 2), Vector(gridSize / 2, gridSize / 2, gridSize / 2), color)
                    else
                        -- Mensaje de depuración para celdas nulas
                        print("Cell at ", cellpos, " is nil.")
                    end
                end
            end
        end
    end
end

hook.Add("InitPostEntity", "gDisasters_GenerateGrid", GenerateGrid)
hook.Add("InitPostEntity", "gDisasters_AddTemperatureHumiditySources", AddTemperatureHumiditySources)
hook.Add("Think", "gDisasters_UpdateGrid", UpdateGrid)
hook.Add("Think", "gDisasters_UpdatePlayerGrid", UpdatePlayerGrid)
hook.Add("Think", "gDisasters_UpdateWeather", UpdateWeather)
hook.Add("PostDrawTranslucentRenderables", "gDisasters_DrawGridDebug", DrawGridDebug)