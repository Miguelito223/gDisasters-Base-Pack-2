-- Tamaño de la cuadrícula y rango de temperatura
gridSize = 1000 -- Tamaño de cada cuadrado en unidades

minTemperature = -40 -- Temperatura mínima
maxTemperature = 40 -- Temperatura máxima
minHumidity = 0 -- Humedad mínima
maxHumidity = 100 -- Humedad máxima
minPressure = 80000 -- Presión mínima en milibares
maxPressure = 130000 -- Presión máxima en milibares

updateInterval = 1 -- Intervalo de actualización en segundos
updateBatchSize = 100 -- Número de celdas a actualizar por frame
nextThinkTime = CurTime()

diffusionCoefficient = 0.1 -- Coeficiente de difusión de calor
gas_constant = 287.05
specific_heat_vapor = 2010
airflowCoefficient = 0.1

waterTemperatureEffect = 2  -- El agua tiende a mantener una temperatura más constante
landTemperatureEffect = 5    -- La tierra se calienta y enfría más rápido que el agua
waterHumidityEffect = 5      -- El agua puede aumentar la humedad en su entorno
landHumidityEffect = 2       -- La tierra puede retener menos humedad que el agua
mountainTemperatureEffect = -5  -- Las montañas tienden a ser más frías debido a la altitud
mountainHumidityEffect = 5       -- Las montañas pueden influir en la humedad debido a las corrientes de aire

GridMap = {}
cellsToUpdate = {}

waterSources = {}
LandSources = {}

Cloud = {}

rainThreshold = 70 -- Umbral de humedad para la generación de lluvia
stormTemperatureThreshold = 30 -- Umbral de temperatura para la generación de tormentas
stormPressureThreshold = 100000 -- Umbral de presión para la generación de tormentas
lowTemperatureThreshold = 10
lowHumidityThreshold =  40
MaxClouds = 30
MaxRainDrop = 5



 

function CalculateTemperature(x, y, z)
    local totalTemperature = 0
    local totalAirFlow = {0, 0, 0} -- Para almacenar la suma de los componentes del flujo de aire
    local count = 0

    -- Sumar la temperatura de las celdas vecinas y el flujo de aire
    for i = -1, 1 do
        for j = -1, 1 do
            for k = -1, 1 do
                local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                    local neighborCell = GridMap[nx][ny][nz]
                    if neighborCell.temperature and neighborCell.airflow then
                        totalTemperature = totalTemperature + neighborCell.temperature
                        totalAirFlow[1] = totalAirFlow[1] + (neighborCell.airflow[1] or 0)
                        totalAirFlow[2] = totalAirFlow[2] + (neighborCell.airflow[2] or 0)
                        totalAirFlow[3] = totalAirFlow[3] + (neighborCell.airflow[3] or 0)
                        count = count + 1
                    end
                end
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
    local newTemperature = currentTemperature + diffusionCoefficient * (averageTemperature - currentTemperature)

    -- Ajustar la temperatura en función del flujo de aire
    -- Por simplicidad, asumimos que el flujo de aire positivo en los ejes x, y, z aumenta la temperatura y el flujo negativo la disminuye
    local airflowEffect = airflowCoefficient * (averageAirFlow[1] + averageAirFlow[2] + averageAirFlow[3])
    newTemperature = newTemperature + airflowEffect

    -- Ajustar la temperatura en función de la altitud
    local altitudeEffect = z * 0.0065 -- La temperatura desciende aproximadamente 0.0065 grados por metro de altitud
    newTemperature = newTemperature - altitudeEffect
    local temperatureInfluence = GridMap[x][y][z].temperatureInfluence
    newTemperature = newTemperature + temperatureInfluence

    -- Asegurarse de que la temperatura esté dentro del rango
    return math.max(minTemperature, math.min(maxTemperature, newTemperature))
end

function CalculateHumidity(x, y, z)
    local totalHumidity = 0
    local count = 0

    -- Sumar la humedad de las celdas vecinas
    for i = -1, 1 do
        for j = -1, 1 do
            for k = -1, 1 do
                local nx, ny, nz = x + i * gridSize, y + j * gridSize, z + k * gridSize
                if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                    local neighborCell = GridMap[nx][ny][nz]
                    if neighborCell.humidity then
                        totalHumidity = totalHumidity + neighborCell.humidity
                        count = count + 1
                    end
                end
            end
        end
    end

    -- Si no hay celdas vecinas válidas, retornar la humedad actual
    if count == 0 then return GridMap[x][y][z].humidity end

    -- Calcular la humedad promedio de las vecinas
    local averageHumidity = totalHumidity / count

    -- Ajustar la humedad de la celda actual basada en la difusión de humedad
    local currentHumidity = GridMap[x][y][z].humidity
    local newHumidity = currentHumidity + diffusionCoefficient * (averageHumidity - currentHumidity)

    -- Ajustar la humedad en función de la altitud
    local altitudeEffect = z * 0.1 -- La humedad disminuye con la altitud
    newHumidity = newHumidity - altitudeEffect
    local humidityinfluence = GridMap[x][y][z].humidityInfluence
    newHumidity = newHumidity + humidityinfluence

    -- Asegurarse de que la humedad esté dentro del rango permitido
    return math.max(minHumidity, math.min(maxHumidity, newHumidity))
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
    local MOUNTAIN_LEVEL = floorz + 5000

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

function SimulateAirFlow(x, y, z)
    local totalDeltaPressureX = 0
    local totalDeltaPressureY = 0
    local totalDeltaPressureZ = 0

    -- Calcular la diferencia de presión entre las celdas vecinas
    for i = -1, 1 do
        for j = -1, 1 do
            for k = -1, 1 do
                if i ~= 0 or j ~= 0 or k ~= 0 then -- Evitar la celda actual
                    local nx, ny, nz = x + i, y + j, z + k
                    if GridMap[nx] and GridMap[nx][ny] and GridMap[nx][ny][nz] then
                        local neighborCell = GridMap[nx][ny][nz]
                        local currentCell = GridMap[x][y][z]

                        -- Diferencia de presión específica para cada eje
                        totalDeltaPressureX = totalDeltaPressureX + (neighborCell.pressure - currentCell.pressure) * i
                        totalDeltaPressureY = totalDeltaPressureY + (neighborCell.pressure - currentCell.pressure) * j
                        totalDeltaPressureZ = totalDeltaPressureZ + (neighborCell.pressure - currentCell.pressure) * k
                    end
                end
            end
        end
    end

    -- Ajustar la velocidad del flujo de aire en función de la diferencia de presión
    local airflowX = totalDeltaPressureX * airflowCoefficient
    local airflowY = totalDeltaPressureY * airflowCoefficient
    local airflowZ = totalDeltaPressureZ * airflowCoefficient

    return Vector(airflowX, airflowY, airflowZ)
end

-- Función para simular la generación de lluvia
function SimulateRain()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                if cell.humidity > rainThreshold then
                    CreateRaindrops(x, y, z)
                    AdjustHumiditySurroundingCells(x, y, z)
                end
            end
        end
    end
end

-- Función para crear partículas de lluvia
function CreateRaindrops(x, y, z)

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

-- Function to adjust humidity levels in surrounding cells based on rain
function AdjustHumiditySurroundingCells(x, y, z)
    local neighbors = {
        {dx = -1, dy = 0},  -- Left
        {dx = 1, dy = 0},   -- Right
        {dx = 0, dy = -1},  -- Up
        {dx = 0, dy = 1}    -- Down
    }
    
    local currentHumidity = GridMap[x][y][z].humidity
    local spreadFactor = 0.2  -- Factor to determine how much humidity spreads to neighbors

    for _, neighbor in ipairs(neighbors) do
        local nx, ny = x + neighbor.dx, y + neighbor.dy
        if GridMap[nx] and GridMap[nx][ny] then
            -- Adjust humidity in neighboring cell based on current cell's humidity
            local neighborHumidity = GridMap[nx][ny][z].humidity
            local newHumidity = neighborHumidity + spreadFactor * (currentHumidity - neighborHumidity)
            GridMap[nx][ny][z].humidity = newHumidity
        end
    end
end

function SimulateStorms()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                if cell.temperature > stormTemperatureThreshold and cell.pressure < stormPressureThreshold then
                    local airflow = GridMap[x][y][z].airflow
                    local pos = Vector(x, y, z) * gridSize
                    local color = Color(128,128,128)
                    SpawnCloud(pos, airflow, color)
                end
            end
        end
    end
end

function SimulateLightningAndThunder()
    local bounds = getMapSkyBox()
    local min = bounds[1]
    local max = bounds[2]
    local startpos = Vector(math.random(min.x, max.x), math.random(min.y, max.y), max.z)
    local tr = util.TraceLine({
        start = startpos,
        endpos = startpos - Vector(0, 0, 50000),
    })
    local endpos = tr.HitPos

    if HitChance(1) then
        if HitChance(2) then
            local sprite_pos = Vector(math.random(min.x, max.x), math.random(min.y, max.y), max.z)
            ParticleEffect(table.Random({"sprite_lightning_main_01", "sprite_lightning_main_02", "sprite_lightning_main_03"}), sprite_pos - Vector(0, 0, math.random(0, 2000)), Angle(0, 0, 0), nil)
        end

        if HitChance(1) then
            local elves_pos = Vector(math.random(min.x, max.x), math.random(min.y, max.y), max.z)
            ParticleEffect(table.Random({"elves_main_01", "elves_main_02"}), elves_pos - Vector(0, 0, math.random(0, 2000)), Angle(0, 0, 0), nil)
        end

        if HitChance(0.1) then
            local blue_jet_pos = Vector(math.random(min.x, max.x), math.random(min.y, max.y), max.z)
            ParticleEffect("blue_jet_lightning_01_main", blue_jet_pos - Vector(0, 0, math.random(2000, 4000)), Angle(0, 0, 0), nil)
        end

        CreateLightningBolt(startpos - Vector(0, 0, 4000), endpos, {"purple", "blue"}, {"Grounded", "NotGrounded"})
    end
end

function SpawnCloud(pos, airflow, color)
    if #ents.FindByClass("gd_cloud_cumulus") > MaxClouds then return end


    local cloud = ents.Create("gd_cloud_cumulus")
    if not IsValid(cloud) then return end -- Verifica si la entidad fue creada correctamente

    cloud:SetPos(pos)
    cloud.DefaultColor = color
    cloud:Spawn()
    cloud:Activate()

    table.insert(Cloud, cloud)

    -- Aplicar el flujo de aire a la velocidad de movimiento de la nube
    local velocity = Vector(airflow.x, airflow.y, airflow.z) * 10 -- Ajusta el factor de escala según sea necesario
    cloud:SetVelocity(velocity)

    

    timer.Simple(cloud.Life, function()
        if IsValid(cloud) then cloud:Remove() end
    end)
end

-- Función para simular la formación y movimiento de nubes
function SimulateClouds()
    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local humidity = cell.humidity
                local temperature = cell.temperature
                if humidity < lowHumidityThreshold and temperature < lowTemperatureThreshold then
                    -- Generate clouds in cells with low humidity and temperature
                    local airflow = GridMap[x][y][z].airflow
                    local pos = Vector(x, y, z) * gridSize
                    local color = Color(255,255,255)
                    SpawnCloud(pos, airflow, color)
                end
            end
        end
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
    local waterSources = GetWaterSources()
    local landSources = GetLandSources()
    local mountainSources = GetMountainSources()

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local closestWaterDist = math.huge
                local closestLandDist = math.huge
                local closestMountainDist = math.huge

                for _, source in ipairs(waterSources) do
                    local dist = GetDistance(x, y, z, source.x, source.y, source.z)
                    if dist < closestWaterDist then
                        closestWaterDist = dist
                    end
                end

                for _, source in ipairs(landSources) do
                    local dist = GetDistance(x, y, z, source.x, source.y, source.z)
                    if dist < closestLandDist then
                        closestLandDist = dist
                    end
                end
                for _, source in ipairs(mountainSources) do
                    local dist = GetDistance(x, y, z, source.x, source.y, source.z)
                    if dist < closestMountainDist then
                        closestMountainDist = dist
                    end
                end

                -- Comparar distancias y ajustar temperatura, humedad y presión en consecuencia
                if closestWaterDist < closestLandDist and closestWaterDist < closestMountainDist then
                    cell.InWater = true
                    cell.temperatureInfluence = -waterTemperatureEffect
                    cell.humidityInfluence = waterHumidityEffect
                    cell.pressureInfluence = waterPressureEffect -- Asegúrate de definir waterPressureEffect
                elseif closestLandDist < closestMountainDist then
                    cell.InWater = false
                    cell.temperatureInfluence = landTemperatureEffect
                    cell.humidityInfluence = -landHumidityEffect
                    cell.pressureInfluence = landPressureEffect -- Asegúrate de definir landPressureEffect
                else
                    cell.InWater = false
                    cell.temperatureInfluence = mountainTemperatureEffect
                    cell.humidityInfluence = -mountainHumidityEffect
                    cell.pressureInfluence = mountainPressureEffect -- Asegúrate de definir mountainPressureEffect
                end 
            end
        end
    end
end

-- Función para obtener las coordenadas de las fuentes de agua
function GetWaterSources()
    local waterSources = {}

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
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

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                if GetCellType(x, y, z) == "land" then
                    table.insert(landSources, {x = x, y = y, z = z})
                end
            end
        end
    end

    return landSources
end

function GetMountainSources()
    local landSources = {}

    for x, column in pairs(GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                if GetCellType(x, y, z) == "mountain" then
                    table.insert(landSources, {x = x, y = y, z = z})
                end
            end
        end
    end

    return landSources
end




-- Llamar a SimulateClouds() para simular la formación y movimiento de las nubes
function UpdateWeather()
    if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then
        if CurTime() > nextThinkTime then
            nextThinkTime = CurTime() + 0.1
            SimulateClouds()
            SimulateStorms()
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
                GridMap[x][y][z].airflow = Vector(0,0,0)
                print("Position grid: X: " .. x .. ", Y:".. y .. ", Z:" .. z) -- Depuración
            end
        end
    end

    print("Grid generated.") -- Depuración

end

function UpdateGrid()
    if GetConVar("gdisasters_heat_system"):GetInt() >= 1 then
        -- Obtener los límites del mapa
        local mapBounds = getMapBounds()
        local minX, minY, maxZ = math.floor(mapBounds[2].x / gridSize) * gridSize, math.floor(mapBounds[2].y / gridSize) * gridSize, math.ceil(mapBounds[2].z / gridSize) * gridSize
        local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gridSize) * gridSize, math.ceil(mapBounds[1].y / gridSize) * gridSize, math.floor(mapBounds[1].z / gridSize) * gridSize

        for i = 1, updateBatchSize do
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
                    local newAirFlow = SimulateAirFlow(x, y, z)
                    GridMap[x][y][z].temperature = newTemperature
                    GridMap[x][y][z].humidity = newHumidity
                    GridMap[x][y][z].pressure = newPressure
                    GridMap[x][y][z].airflow = newAirFlow
                else
                    print("Error: Posición fuera de los límites de la cuadrícula.")
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
                    print("Actual Position grid: X: " .. px .. ", Y:".. py .. ", Z:" .. pz .. ", Temperature Grid: " .. cell.temperature ) -- Depuración
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

if CLIENT then
    
    local maxDrawDistance = 5000 -- Distancia máxima en unidades para dibujar la cuadrícula

    hook.Add("PostDrawOpaqueRenderables", "DrawGridDebug", function()
        if GetConVar("gdisasters_graphics_draw_heatsystem_grid"):GetInt() >= 1 then 
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
        end
    end)

end
-- Llamar a la función para generar la cuadrícula al inicio del juego
hook.Add("PlayerSpawn", "GenerateGrid", GenerateGrid)
hook.Add("PlayerSpawn", "AddTemperatureHumiditySources", AddTemperatureHumiditySources)
hook.Add("Think", "UpdatePlayerGrid", UpdatePlayerGrid)
hook.Add("Think", "UpdateGrid", UpdateGrid)
hook.Add("Think", "UpdateWeather", UpdateWeather)
