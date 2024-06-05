gDisasters.HeatSystem = {}
gDisasters.HeatSystem.GridMap = {}
gDisasters.HeatSystem.cellsToUpdate = {}
gDisasters.HeatSystem.waterSources = {}
gDisasters.HeatSystem.LandSources = {}
gDisasters.HeatSystem.Cloud = {}

-- Tamaño de la cuadrícula y rango de temperatura
gDisasters.HeatSystem.gridSize = GetConVar("gdisasters_heat_system_gridsize"):GetInt() -- Tamaño de cada cuadrado en unidades
gDisasters.HeatSystem.totalgridSize = gridSize * gridSize * gridSize


gDisasters.HeatSystem.minTemperature = GetConVar("gdisasters_heat_system_mintemp"):GetFloat()
gDisasters.HeatSystem.maxTemperature = GetConVar("gdisasters_heat_system_maxtemp"):GetFloat()
gDisasters.HeatSystem.minHumidity = GetConVar("gdisasters_heat_system_minhumidity"):GetInt()
gDisasters.HeatSystem.maxHumidity = GetConVar("gdisasters_heat_system_maxhumidity"):GetInt()
gDisasters.HeatSystem.minPressure = GetConVar("gdisasters_heat_system_minpressure"):GetInt()
gDisasters.HeatSystem.maxPressure = GetConVar("gdisasters_heat_system_maxpressure"):GetInt()
gDisasters.HeatSystem.minAirflow = GetConVar("gdisasters_heat_system_minairflow"):GetInt()
gDisasters.HeatSystem.maxAirflow = GetConVar("gdisasters_heat_system_maxairflow"):GetInt()

gDisasters.HeatSystem.updateInterval = GetConVar("gdisasters_heat_system_updateinterval"):GetFloat() -- Intervalo de actualización en segundos
gDisasters.HeatSystem.updateBatchSize = GetConVar("gdisasters_heat_system_updatebatchsize"):GetInt()
gDisasters.HeatSystem.nextUpdateGrid = CurTime()
gDisasters.HeatSystem.nextUpdateGridPlayer = CurTime()
gDisasters.HeatSystem.nextUpdateWeather = CurTime()
gDisasters.HeatSystem.nextThunderThink = CurTime()

gDisasters.HeatSystem.coolingFactor = 5
gDisasters.HeatSystem.gas_constant = 8.314 -- J/(mol·K)
gDisasters.HeatSystem.specific_heat_vapor = 1.996 -- J/(g·K)


gDisasters.HeatSystem.TempDiffusionCoefficient = GetConVar("gdisasters_heat_system_tempdifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.HumidityDiffusionCoefficient = GetConVar("gdisasters_heat_system_humiditydifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.solarInfluenceCoefficient = GetConVar("gdisasters_heat_system_solarinfluencecoefficient"):GetFloat()
gDisasters.HeatSystem.AirflowCoefficient = GetConVar("gdisasters_heat_system_airflowcoefficient"):GetFloat()
gDisasters.HeatSystem.cloudDensityCoefficient = GetConVar("gdisasters_heat_system_clouddensitycoefficient"):GetFloat()  -- Coeficiente para convertir humedad en densidad de nubes
gDisasters.HeatSystem.convergenceCoefficient = GetConVar("gdisasters_heat_system_convergencecoefficient"):GetFloat()
gDisasters.HeatSystem.TerrainCoefficient = GetConVar("gdisasters_heat_system_terraincoefficient"):GetFloat()
gDisasters.HeatSystem.CoolingCoefficient = GetConVar("gdisasters_heat_system_coolingcoefficient"):GetFloat()


gDisasters.HeatSystem.waterTemperatureEffect = 2   -- El agua tiende a mantener una temperatura más constante
gDisasters.HeatSystem.landTemperatureEffect = 4     -- La tierra se calienta y enfría más rápido que el agua
gDisasters.HeatSystem.waterHumidityEffect = 5       -- El agua puede aumentar significativamente la humedad en su entorno
gDisasters.HeatSystem.landHumidityEffect = 5        -- La tierra puede retener menos humedad que el agua
gDisasters.HeatSystem.mountainTemperatureEffect = 3  -- Las montañas tienden a ser más frías debido a la altitud
gDisasters.HeatSystem.mountainHumidityEffect = 4    -- Las montañas pueden influir moderadamente en la humedad debido a las corrientes de aire

gDisasters.HeatSystem.convergenceThreshold = 0.5
gDisasters.HeatSystem.strongStormThreshold = 2.0
gDisasters.HeatSystem.hailThreshold = 1.5
gDisasters.HeatSystem.rainThreshold = 1.0
gDisasters.HeatSystem.cloudFormationThreshold = 0.3 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.rainFormationThreshold = 0.6 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.hailFormationThreshold = 0.3 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.snowTemperatureThreshold = 0
gDisasters.HeatSystem.snowFormationThreshold = 0.5
gDisasters.HeatSystem.thunderstormThreshold = 0.8 
gDisasters.HeatSystem.cloudThreshold = 0.5
gDisasters.HeatSystem.cloudDensityThreshold = 0.7
gDisasters.HeatSystem.stormTemperatureThreshold = 30 -- Umbral de temperatura para la generación de tormentas
gDisasters.HeatSystem.stormPressureThreshold = 10000 -- Umbral de presión para la generación de tormentas
gDisasters.HeatSystem.lowTemperatureThreshold = 10
gDisasters.HeatSystem.lowHumidityThreshold = 40 -- Umbral de humedad para la formación de nubes
gDisasters.HeatSystem.temperatureThreshold = 20
gDisasters.HeatSystem.humidityThreshold = 75


gDisasters.HeatSystem.MaxClouds = GetConVar("gdisasters_heat_system_maxclouds"):GetInt()
gDisasters.HeatSystem.MaxRainDrop = GetConVar("gdisasters_heat_system_maxraindrop"):GetInt()
gDisasters.HeatSystem.MaxHail = GetConVar("gdisasters_heat_system_maxhail"):GetInt()

gDisasters.HeatSystem.freezingTemperature = 0
gDisasters.HeatSystem.boilingTemperature = 100

-- Mantenemos este valor para el calor latente de congelación
gDisasters.HeatSystem.stormLatentHeatThreshold = 180  -- Ajustamos este valor a uno más bajo para una formación de tormenta más realista
gDisasters.HeatSystem.hailLatentHeatThreshold = 200  -- Ajustamos este valor también a uno más bajo
gDisasters.HeatSystem.cloudLatentHeatThreshold = 100  -- Umbral de calor latente necesario para la formación de nubes
gDisasters.HeatSystem.snowLatentHeatThreshold = 150   -- Umbral de calor latente necesario para la formación de nieve
gDisasters.HeatSystem.rainLatentHeatThreshold = 120   -- Umbral de calor latente necesario para la formación de lluvia

gDisasters.HeatSystem.maxDistance = 100000

-- Función para normalizar un vector
gDisasters.HeatSystem.CalculateSolarRadiation = function(hour)
    if not hour then return 0 end

    -- Parámetros para el modelo senoidal
    local sunrise = gDisasters.DayNightSystem.InternalVars.time.Dawn_Start   -- Hora de salida del sol
    local sunset = gDisasters.DayNightSystem.InternalVars.time.Dusk_Start   -- Hora de puesta del sol
    local maxRadiation = 1  -- Radiación máxima normalizada (puede ser ajustada)

    -- Verificar si la hora está fuera del rango de la luz solar
    if hour < sunrise or hour > sunset then
        return 0
    end

    -- Calcular la fracción del día solar
    local dayFraction = (hour - sunrise) / (sunset - sunrise)

    -- Calcular la radiación solar usando una función senoidal
    local solarRadiation = maxRadiation * math.sin(math.pi * dayFraction)

    -- Asegurarse de que la radiación esté en el rango de 0 a maxRadiation
    solarRadiation = math.Clamp(solarRadiation, 0, maxRadiation)
    
    return solarRadiation
end

gDisasters.HeatSystem.CalculateTemperature = function(x, y, z)
    local totalTemperature = 0
    local count = 0

    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista

    -- Inicializar las diferencias de temperatura en cada dirección a cero
    local temperatureDifferenceX, temperatureDifferenceY, temperatureDifferenceZ = 0, 0, 0

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.temperature then
                            totalTemperature = totalTemperature + neighborCell.temperature
                            count = count + 1

                            -- Calcular las diferencias de temperatura en cada dirección
                            if dx ~= 0 then
                                temperatureDifferenceX = temperatureDifferenceX + (neighborCell.temperature - currentCell.temperature)
                            end
                            if dy ~= 0 then
                                temperatureDifferenceY = temperatureDifferenceY + (neighborCell.temperature - currentCell.temperature)
                            end
                            if dz ~= 0 then
                                temperatureDifferenceZ = temperatureDifferenceZ + (neighborCell.temperature - currentCell.temperature)
                            end
                        end
                    end
                end
            end
        end
    end

    if count == 0 then return currentCell.temperature or 0 end

    local averageTemperature = totalTemperature / count

    -- Factores adicionales (solar, terreno, etc.)
    local solarRadiation = gDisasters.HeatSystem.CalculateSolarRadiation(gDisasters.DayNightSystem.Time)
    local solarInfluence = solarRadiation * gDisasters.HeatSystem.solarInfluenceCoefficient
    
    local coldeffect = 0
    if solarInfluence <= 0 then
        coldeffect = -coolingFactor * gDisasters.HeatSystem.CoolingCoefficient
    end

    local currentTemperature = currentCell.temperature or 0
    local cloudDensity = currentCell.cloudDensity or 0
    local terrainType = currentCell.terrainType or "land"
    local terrainTemperatureEffect = 0
    
    if (terrainType == "water" and gDisasters.HeatSystem.waterTemperatureEffect) then
        terrainTemperatureEffect = -gDisasters.HeatSystem.waterTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif (terrainType == "mountain" and gDisasters.HeatSystem.mountainTemperatureEffect) then
        terrainTemperatureEffect = -gDisasters.HeatSystem.mountainTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
    else 
        terrainTemperatureEffect = gDisasters.HeatSystem.landTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
    end

    local latentHeat = 0
    if cloudDensity > 0 then
        if (currentTemperature > freezingTemperature) then 
            latentHeat = gDisasters.HeatSystem.calculateCondensationLatentHeat(cloudDensity) 
        else 
            latentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(cloudDensity) 
        end
    end

    local temperatureChange = gDisasters.HeatSystem.TempDiffusionCoefficient * (averageTemperature - currentTemperature)
    local newTemperature = currentTemperature + temperatureChange + terrainTemperatureEffect + solarInfluence + latentHeat + coldeffect

    -- Guardar las diferencias de temperatura calculadas en la celda actual
    currentCell.temperatureDifferenceX = temperatureDifferenceX
    currentCell.temperatureDifferenceY = temperatureDifferenceY
    currentCell.temperatureDifferenceZ = temperatureDifferenceZ

    return math.Clamp(newTemperature, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
end

gDisasters.HeatSystem.CalculateHumidity = function(x, y, z)
    local totalHumidity = 0
    local count = 0

    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista

    local humidityDifferenceX, humidityDifferenceY, humidityDifferenceZ = 0, 0, 0

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.humidity then
                            totalHumidity = totalHumidity + neighborCell.humidity
                            count = count + 1


                            -- Calcular las diferencias de temperatura en cada dirección
                            if dx ~= 0 then
                                humidityDifferenceX = humidityDifferenceX + (neighborCell.humidity - currentCell.humidity)
                            end
                            if dy ~= 0 then
                                humidityDifferenceY = humidityDifferenceY + (neighborCell.humidity - currentCell.humidity)
                            end
                            if dz ~= 0 then
                                humidityDifferenceZ = humidityDifferenceZ + (neighborCell.humidity - currentCell.humidity)
                            end
                        end
                    end
                end
            end
        end
    end

    if count == 0 then return currentCell.humidity or 0 end

    local averageHumidity = totalHumidity / count
    
    local currentHumidity = currentCell.humidity or 0
    local terrainType = currentCell.terrainType or "land"
    local terrainHumidityEffect = 0
    
    if (terrainType == "water" and gDisasters.HeatSystem.waterHumidityEffect) then
        terrainHumidityEffect =gDisasters.HeatSystem. waterHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif (terrainType == "mountain" and gDisasters.HeatSystem.mountainHumidityEffect) then
        terrainHumidityEffect = -gDisasters.HeatSystem.mountainHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
    else 
        terrainHumidityEffect = -gDisasters.HeatSystem.landHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
    end

    local humidityChange = gDisasters.HeatSystem.HumidityDiffusionCoefficient * (averageHumidity - currentHumidity)
    local newHumidity = currentHumidity + humidityChange + terrainHumidityEffect

    currentCell.humidityDifferenceX = humidityDifferenceX
    currentCell.humidityDifferenceY = humidityDifferenceY
    currentCell.humidityDifferenceZ = humidityDifferenceZ

    return math.Clamp(newHumidity, gDisasters.HeatSystem.minHumidity, gDisasters.HeatSystem.maxHumidity)
end


-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculatePressure = function(x, y, z) 
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = cell.temperature or 0
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local humidity = cell.humidity or 0

    -- Calcular la presión basada en la temperatura y la humedad
    local newpressure = (gas_constant * temperature * (1 + ((specific_heat_vapor * humidity) / temperature))) * 100

    -- Asegurarse de que la presión esté dentro del rango
    return math.Clamp(newpressure, gDisasters.HeatSystem.minPressure, gDisasters.HeatSystem.maxPressure)
end

gDisasters.HeatSystem.CalculateAirFlow = function(x, y, z)
    local totalDeltaPressureX = 0
    local totalDeltaPressureY = 0
    local totalDeltaPressureZ = 0

    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]

    -- Verificar que la celda actual exista
    if not currentCell then
        return 0
    end

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                -- Evitar la celda actual en el cálculo
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        
                        local deltaPressure = neighborCell.pressure - currentCell.pressure

                        -- Sumar la diferencia de presión a los totales en cada eje
                        totalDeltaPressureX = totalDeltaPressureX + deltaPressure * dx
                        totalDeltaPressureY = totalDeltaPressureY + deltaPressure * dy
                        totalDeltaPressureZ = totalDeltaPressureZ + deltaPressure * dz
                    end
                end
            end
        end
    end

    -- Contribución adicional del flujo de aire debido a la difusión natural
    local combinedDiffusionContributionX = currentCell.temperatureDifferenceX + currentCell.humidityDifferenceX
    local combinedDiffusionContributionY = currentCell.temperatureDifferenceY + currentCell.humidityDifferenceY
    local combinedDiffusionContributionZ = currentCell.temperatureDifferenceZ + currentCell.humidityDifferenceZ

    local diffusionContributionX = combinedDiffusionContributionX * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionY = combinedDiffusionContributionY * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionZ = combinedDiffusionContributionZ * gDisasters.HeatSystem.AirflowCoefficient

    -- Crear un vector de flujo de aire
    local airflowVector = Vector(totalDeltaPressureX + diffusionContributionX, totalDeltaPressureY + diffusionContributionY, totalDeltaPressureZ + diffusionContributionZ)

    -- Calcular la magnitud del flujo de aire
    local airflowMagnitude = airflowVector:Length()

    local newAirflow = airflowMagnitude * gDisasters.HeatSystem.AirflowCoefficient

    -- Clampear el flujo de aire entre los valores mínimos y máximos permitidos
    return math.Clamp(newAirflow, gDisasters.HeatSystem.minAirflow, gDisasters.HeatSystem.maxAirflow)
end

gDisasters.HeatSystem.CalculateAirFlowDirection = function(x, y, z)
    local totalDeltaPressureX = 0
    local totalDeltaPressureY = 0
    local totalDeltaPressureZ = 0

    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]

    -- Verificar que la celda actual exista
    if not currentCell then
        return Vector(0, 0, 0)
    end

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                -- Evitar la celda actual en el cálculo
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        
                        local deltaPressure = neighborCell.pressure - currentCell.pressure

                        -- Sumar la diferencia de presión a los totales en cada eje
                        totalDeltaPressureX = totalDeltaPressureX + deltaPressure * dx
                        totalDeltaPressureY = totalDeltaPressureY + deltaPressure * dy
                        totalDeltaPressureZ = totalDeltaPressureZ + deltaPressure * dz
                    end
                end
            end
        end
    end
    -- Contribución adicional del flujo de aire debido a la difusión natural
    local combinedDiffusionContributionX = currentCell.temperatureDifferenceX + currentCell.humidityDifferenceX
    local combinedDiffusionContributionY = currentCell.temperatureDifferenceY + currentCell.humidityDifferenceY
    local combinedDiffusionContributionZ = currentCell.temperatureDifferenceZ + currentCell.humidityDifferenceZ
    -- Contribución adicional del flujo de aire debido a la difusión natural
    local diffusionContributionX = combinedDiffusionContributionX * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionY = combinedDiffusionContributionY * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionZ = combinedDiffusionContributionZ * gDisasters.HeatSystem.AirflowCoefficient

    -- Crear un vector de flujo de aire
    local airflowVector = Vector(totalDeltaPressureX + diffusionContributionX, totalDeltaPressureY + diffusionContributionY, totalDeltaPressureZ + diffusionContributionZ)

    -- Calcular la magnitud del flujo de aire
    local airflowMagnitude = airflowVector:Length()

    -- Normalizar el vector de flujo de aire para obtener la dirección del viento
    local windDirection = Vector(0, 0, 0)
    if airflowMagnitude > 0 then
        windDirection.x = airflowVector.x / airflowMagnitude
        windDirection.y = airflowVector.y / airflowMagnitude
        windDirection.z = 0
    end

    return windDirection
end

gDisasters.HeatSystem.GetCellType = function(x, y, z)
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
    local MOUNTAIN_LEVEL = floorz + 10000 -- Ajusta la altura de la montaña según sea necesario

    -- Simular diferentes tipos de celdas basadas en coordenadas
    if z <= WATER_LEVEL then
        return "water" -- Por debajo del nivel del agua es agua
    elseif z >= MOUNTAIN_LEVEL then
        return "mountain" -- Por encima del nivel de la montaña es montaña
    else
        return "land" -- En otras coordenadas es tierra
    end
end


gDisasters.HeatSystem.CreateSnow = function(x, y, z) 
    if CLIENT then return end -- No ejecutar en el cliente (solo en el servidor)
    
    -- Crear una entidad de partículas para la nieve
    local particle = ents.Create("env_spritetrail")
    if not IsValid(particle) then return end -- Verificar si la entidad fue creada correctamente
    
    -- Establecer las propiedades de la partícula de nieve
    particle:SetPos(Vector(x, y, z)) -- Establecer la posición de la partícula
    particle:SetKeyValue("lifetime", "3") -- Duración de la partícula
    particle:SetKeyValue("startwidth", "1") -- Ancho inicial de la partícula
    particle:SetKeyValue("endwidth", "0") -- Ancho final de la partícula
    particle:SetKeyValue("spritename", "effects/snowflake") -- Nombre del sprite para la partícula de nieve
    particle:SetKeyValue("rendermode", "5") -- Modo de renderizado de la partícula
    particle:SetKeyValue("rendercolor", "255 255 255") -- Color de la partícula de nieve (blanco)
    particle:SetKeyValue("spawnflags", "1") -- Banderas de aparición para la partícula
    particle:Spawn() -- Generar la partícula
    particle:Activate() -- Activar la partícula
    
    -- Programar la eliminación de la partícula después de un tiempo
    timer.Simple(5, function()
        if IsValid(particle) then
            particle:Remove() -- Eliminar la partícula
        end
    end)
end

-- Función para crear partículas de lluvia
gDisasters.HeatSystem.CreateRain = function(x, y, z)
    if CLIENT then return end  
    if #ents.FindByClass("env_spritetrail") > MaxRainDrop then return end

    local particle = ents.Create("env_spritetrail") -- Create a sprite trail entity for raindrop particle
    if not IsValid(particle) then return end -- Verifica si la entidad fue creada correctamente

    particle:SetPos(Vector(x, y, z)) -- Set the position of the particle
    particle:SetKeyValue("lifetime", "2") -- Set the lifetime of the particle
    particle:SetKeyValue("startwidth", "2") -- Set the starting width of the particle
    particle:SetKeyValue("endwidth", "0") -- Set the ending width of the particle
    particle:SetKeyValue("spritename", "effects/blood_core") -- Set the sprite name for the particle (you can use any sprite)
    particle:SetKeyValue("rendermode", "5") -- Set the render mode of the particle
    particle:SetKeyValue("rendercolor", "0 0 255") -- Set the color of the particle (blue for rain)
    particle:SetKeyValue("spawnflags", "1") -- Set the spawn flags for the particle
    particle:Spawn() -- Spawn the particle
    particle:Activate() -- Activate the particle

    timer.Simple(5, function() -- Remove the particle after 2 seconds
        if IsValid(particle) then particle:Remove() end
    end)
end
-- Function to calculate latent heat released during condensation
gDisasters.HeatSystem.calculateCondensationLatentHeat = function(cloudDensity)
    local condensationLatentHeat = 60
    return cloudDensity * condensationLatentHeat
end

-- Function to calculate latent heat released during freezing
gDisasters.HeatSystem.calculateFreezingLatentHeat = function(cloudDensity)
    local freezingLatentHeat = 80 
    return cloudDensity * freezingLatentHeat
end

gDisasters.HeatSystem.CalculateCloudLatentHeat = function(cloudDensity)
    local CloudLatentHeat = 100
    return cloudDensity * CloudLatentHeat   -- Este valor es un ejemplo, puedes ajustarlo según tus necesidades.
end

-- Función para calcular el calor latente necesario para la formación de lluvia
gDisasters.HeatSystem.CalculateRainLatentHeat = function(cloudDensity)
    RainLatentHeat = 120 
    return cloudDensity * RainLatentHeat-- Este valor es un ejemplo, puedes ajustarlo según tus necesidades.
end

-- Función para calcular el calor latente necesario para la formación de nieve
gDisasters.HeatSystem.CalculateSnowLatentHeat = function(cloudDensity)
    SnowLatentHeat = 150
    return cloudDensity * SnowLatentHeat-- Este valor es un ejemplo, puedes ajustarlo según tus necesidades.
end

gDisasters.HeatSystem.UpdateCloudDensity = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local humidity = currentCell.humidity or 0

    if humidity > humidityThreshold then
        currentCell.cloudDensity = (humidity - humidityThreshold) * gDisasters.HeatSystem.cloudDensityCoefficient
    else
        currentCell.cloudDensity = 0
    end
end

gDisasters.HeatSystem.CheckStormFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity and currentCell.cloudDensity > 0 then
        if currentCell.temperature > freezingTemperature then
            latentHeat = gDisasters.HeatSystem.calculateCondensationLatentHeat(currentCell.cloudDensity)
        else
            latentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(currentCell.cloudDensity)
        end
    end

    if latentHeat > stormLatentHeatThreshold then
        -- Trigger storm formation logic here
        gDisasters.HeatSystem.CreateStorm(x, y, z)
    end
end

gDisasters.HeatSystem.CheckHailFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity and currentCell.cloudDensity > 0 then
        if currentCell.temperature <= freezingTemperature then
            latentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(currentCell.cloudDensity)
        end
    end

    if latentHeat > hailLatentHeatThreshold then
        -- Trigger hail formation logic here
        gDisasters.HeatSystem.CreateHail(x, y, z)
    end
end

gDisasters.HeatSystem.CheckSnowFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= snowFormationThreshold and currentCell.temperature <= snowTemperatureThreshold then
        -- Calcular el calor latente necesario para la formación de nieve
        latentHeat = gDisasters.HeatSystem.CalculateSnowLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= snowLatentHeatThreshold then
        -- Disparar la lógica de formación de nieve aquí
        gDisasters.HeatSystem.CreateSnow(x, y, z)
    end
end

gDisasters.HeatSystem.CheckCloudFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= cloudFormationThreshold then
        -- Calcular el calor latente necesario para la formación de nubes
        latentHeat = gDisasters.HeatSystem.CalculateCloudLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= cloudLatentHeatThreshold then
        -- Disparar la lógica de formación de nubes aquí
        gDisasters.HeatSystem.CreateCloud(x, y, z)
    end
end

gDisasters.HeatSystem.CheckRainFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= rainFormationThreshold then
        -- Calcular el calor latente necesario para la formación de lluvia
        latentHeat = gDisasters.HeatSystem.CalculateRainLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= rainLatentHeatThreshold then
        -- Disparar la lógica de formación de lluvia aquí
        gDisasters.HeatSystem.CreateRain(x, y, z)
    end
end


gDisasters.HeatSystem.CreateLightningAndThunder = function(x,y,z)
    if CLIENT then return end
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

gDisasters.HeatSystem.SpawnCloud = function(pos, color)
    if CLIENT then return end
    if #ents.FindByClass("gd_cloud_cumulus") > MaxClouds then return end

    local cloud = ents.Create("gd_cloud_cumulus")
    if not IsValid(cloud) then return end -- Verifica si la entidad fue creada correctamente

    cloud:SetPos(pos)
    cloud.DefaultColor = color
    cloud:SetModelScale(0.5, 0)
    cloud:Spawn()
    cloud:Activate()

    table.insert(Cloud, cloud)

    timer.Simple(cloud.Life, function()
        if IsValid(cloud) then cloud:Remove() end
    end)

    return cloud
    
end

-- Función para simular la formación y movimiento de nubes
gDisasters.HeatSystem.CreateCloud = function(x,y,z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]

    local humidity = cell.humidity
    local temperature = cell.temperature
    if humidity > humidityThreshold and temperature < temperatureThreshold then
        -- Generate clouds in cells with low humidity and temperature
        gDisasters.HeatSystem.AdjustCloudBaseHeight(x, y, z)
        
        local baseHeight = cell.baseHeight or z
        local pos = Vector(x, y, baseHeight)
        local color = Color(255,255,255)
        
        gDisasters.HeatSystem.SpawnCloud(pos, color)
        
        
    end
    
end

-- Función para simular la formación y movimiento de nubes
gDisasters.HeatSystem.CreateStorm = function(x,y,z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]

    local humidity = cell.humidity
    local temperature = cell.temperature
    if humidity < lowHumidityThreshold and temperature < lowTemperatureThreshold then
        gDisasters.HeatSystem.AdjustCloudBaseHeight(x, y, z)

        -- Generate clouds in cells with low humidity and temperature
        local baseHeight = cell.baseHeight or z
        local pos = Vector(x, y, baseHeight)
        local color = Color(117,117,117)
        
        local cloud = SpawnCloud(pos, color)

        if not IsValid(cloud) then
            return
        end
        
        -- Crear rayo y trueno en intervalos regulares
        local lightningInterval = 10 -- Intervalo en segundos
        local lightningTimerName = "LightningTimer_" .. cloud:EntIndex()

        timer.Create(lightningTimerName, lightningInterval, 0, function()
            timer.Remove(lightningTimerName)
            gDisasters.HeatSystem.CreateLightningAndThunder(pos.x, pos.y, pos.z)
        end)

       
        -- Detener el temporizador cuando la nube se elimina
        timer.Simple(cloud.Life, function()
            
            cloud:Remove()
            timer.Remove(lightningTimerName)
            
        end)

        
    end
    
end

gDisasters.HeatSystem.GetDistance = function(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Función para obtener la distancia a la fuente más cercana
gDisasters.HeatSystem.GetClosestDistance(x, y, z, sources)
    local closestDistance = math.huge

    for _, source in ipairs(sources) do
        local distance = gDisasters.HeatSystem.GetDistance(x, y, z, source.x, source.y, source.z)
        if distance < closestDistance then
            closestDistance = distance
        end
    end

    return closestDistance
end

gDisasters.HeatSystem.AddTemperatureHumiditySources = function()
    print("Adding Sources...")
    local waterSources = gDisasters.HeatSystem.GetWaterSources()
    local landSources = gDisasters.HeatSystem.GetLandSources()
    local mountainSources = gDisasters.HeatSystem.GetMountainSources()

    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local closestWaterDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, waterSources)
                local closestLandDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, landSources)
                local closestMountainDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, mountainSources)


                -- Comparar distancias y ajustar temperatura, humedad y presión en consecuencia
                if closestWaterDist < closestLandDist and closestWaterDist < closestMountainDist then
                    cell.terrainType = "water"
                elseif closestLandDist < closestMountainDist and closestLandDist < closestWaterDist then
                    cell.terrainType = "land"
                else
                    cell.terrainType = "mountain"
                end 
            end
        end
    end

    print("Adding Finish")
end

-- Función para obtener las coordenadas de las fuentes de agua
gDisasters.HeatSystem.GetWaterSources = function()
    local waterSources = {}

    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "water" then
                    table.insert(waterSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return waterSources
end

-- Función para obtener las coordenadas de las fuentes de tierra
gDisasters.HeatSystem.GetLandSources = function()
    local landSources = {}

    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "land" then
                    table.insert(landSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return landSources
end

gDisasters.HeatSystem.GetMountainSources = function()
    local MountainSources = {}

    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "mountain" then
                    table.insert(MountainSources, {x = x, y = y , z = z})
                end
            end
        end
    end

    return MountainSources
end

gDisasters.HeatSystem.AdjustCloudBaseHeight = function(x,y,z)
    local nubegrid = gDisasters.HeatSystem.GridMap[x][y][z]
    local humidity = nubegrid.humidity or 0
    local baseHeightAdjustment = (1 - humidity) * 0.1
    
    nubegrid.baseHeight = (nubegrid.baseHeight or 0) + baseHeightAdjustment
    return nubegrid.baseHeight
end

gDisasters.HeatSystem.SimulateRain = function()
    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, nubegrid in pairs(row) do
                gDisasters.HeatSystem.CreateRain(x, y, z)

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

gDisasters.HeatSystem.CreateHail = function(x, y, z)
    if CLIENT then return end
    if #ents.FindByClass("gd_d1_hail_ch") > MaxHail then return end
    
    local hail = ents.Create("gd_d1_hail_ch")
    hail:SetPos(Vector(x, y, z))
    hail:Spawn()
    hail:Activate()

    timer.Simple(5, function() -- Remove the particle after 2 seconds
        if IsValid(hail) then hail:Remove() end
    end)
end

gDisasters.HeatSystem.SimulateHail = function()
    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, nubegrid in pairs(row) do

                if nubegrid.humidity > humidityThreshold and nubegrid.temperature < temperatureThreshold then
                    gDisasters.HeatSystem.CreateHail(x, y, z)
                end
            end
        end
    end
end
gDisasters.HeatSystem.SimulateConvergence = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return end

    local totalCloudDensity = 0
    local count = 0

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                local nx, ny, nz = x + dx * gridSize, y + dy * gridSize, z + dz * gridSize
                if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                    local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                    if neighborCell.cloudDensity then
                        totalCloudDensity = totalCloudDensity + neighborCell.cloudDensity
                        count = count + 1
                    end
                end
            end
        end
    end

    if count == 0 then return end

    local averageCloudDensity = totalCloudDensity / count
    currentCell.cloudDensity = math.min(currentCell.cloudDensity + (averageCloudDensity * gDisasters.HeatSystem.convergenceCoefficient), 1)
end

gDisasters.HeatSystem.SpawnWeatherEntity = function(weatherType, x, y, z)
    if CLIENT then return end
    
    local entityName = ""
    if weatherType == "rain" then
        entityName = "gd_heatsys_raincell"
    elseif weatherType == "thunder" then
        entityName = "gd_heatsys_thundercell"
    elseif weatherType == "hail" then
        entityName = "gd_heatsys_hailcell"
    else
        return
    end

    local weatherEntity = ents.Create(entityName)
    if not IsValid(weatherEntity) then return end

    weatherEntity:SetPos(Vector(x, y, z))
    weatherEntity:Spawn()
    weatherEntity:SetNoDraw(true) -- Make the entity invisible
    weatherEntity:SetCollisionGroup(COLLISION_GROUP_WORLD) -- Disable collision

    -- Store the entity in the grid map for later reference
    gDisasters.HeatSystem.GridMap[x][y][z][weatherType .. "Entity"] = weatherEntity
end

-- Function to remove weather entities
gDisasters.HeatSystem.RemoveWeatherEntity = function(weatherType, x, y, z)
    local weatherEntity = gDisasters.HeatSystem.GridMap[x][y][z][weatherType .. "Entity"]
    if IsValid(weatherEntity) then
        weatherEntity:Remove()
        gDisasters.HeatSystem.GridMap[x][y][z][weatherType .. "Entity"] = nil
    end
end


gDisasters.HeatSystem.UpdateWeatherInCell = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

    local weatherType = "clear"
    if cell.cloudDensity > cloudDensityThreshold then
        if cell.temperature <= freezingTemperature and cell.cloudDensity > hailThreshold then
            weatherType = "hail"
        elseif cell.cloudDensity > thunderstormThreshold then
            weatherType = "thunder"
        elseif cell.cloudDensity > rainThreshold then
            weatherType = "rain"
        end
    end

    -- If the weather type has changed, update the entity
    if cell.weather ~= weatherType then
        -- Remove old weather entity if it exists
        if cell.weather and cell.weather ~= "clear" then
            gDisasters.HeatSystem.RemoveWeatherEntity(cell.weather, x, y, z)
        end
        
        -- Spawn new weather entity if necessary
        if weatherType ~= "clear" then
            gDisasters.HeatSystem.SpawnWeatherEntity(weatherType, x, y, z)
        end

        -- Update the cell's weather type
        cell.weather = weatherType
    end
end

-- Llamar a SimulateClouds() para simular la formación y movimiento de las nubes
gDisasters.HeatSystem.UpdateWeather = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        if CurTime() > gDisasters.HeatSystem.nextUpdateWeather then
            gDisasters.HeatSystem.nextUpdateWeather = CurTime() + gDisasters.HeatSystem.updateInterval
            for x, column in pairs(gDisasters.HeatSystem.GridMap) do
                for y, row in pairs(column) do
                    for z, cell in pairs(row) do
                        
                        gDisasters.HeatSystem.UpdateCloudDensity(x,y,z)
                        gDisasters.HeatSystem.UpdateWeatherInCell(x, y, z)
                        gDisasters.HeatSystem.SimulateConvergence(x, y, z)
                        gDisasters.HeatSystem.CheckStormFormation(x, y, z)
                        gDisasters.HeatSystem.CheckHailFormation(x, y, z)
                        gDisasters.HeatSystem.CheckCloudFormation(x, y, z)
                        gDisasters.HeatSystem.CheckRainFormation(x, y, z)
                        gDisasters.HeatSystem.CheckSnowFormation(x,y,z)
                        


                        
                    end
                end
            end
        end
    end
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
gDisasters.HeatSystem.GenerateGrid = function(ply)
    -- Obtener los límites del mapa
    local mapBounds = getMapBounds()
    local minX, minY, maxZ = math.floor(mapBounds[2].x / gridSize) * gridSize, math.floor(mapBounds[2].y / gridSize) * gridSize, math.ceil(mapBounds[2].z / gridSize) * gridSize
    local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gridSize) * gridSize, math.ceil(mapBounds[1].y / gridSize) * gridSize, math.floor(mapBounds[1].z / gridSize) * gridSize

    print("Generating grid...") -- Depuración

    -- Inicializar la cuadrícula
    for x = minX, maxX, gridSize do
        gDisasters.HeatSystem.GridMap[x] = {}
        for y = minY, maxY, gridSize do
            gDisasters.HeatSystem.GridMap[x][y] = {}
            for z = minZ, maxZ, gridSize do
                gDisasters.HeatSystem.GridMap[x][y][z] = {}
                gDisasters.HeatSystem.GridMap[x][y][z].temperature = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Temperature"]
                gDisasters.HeatSystem.GridMap[x][y][z].humidity = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
                gDisasters.HeatSystem.GridMap[x][y][z].pressure = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
                gDisasters.HeatSystem.GridMap[x][y][z].Airflow = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Speed"]
                gDisasters.HeatSystem.GridMap[x][y][z].Airflow_Direction = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Direction"]
                gDisasters.HeatSystem.GridMap[x][y][z].cloudDensity = 0
                gDisasters.HeatSystem.GridMap[x][y][z].terrainType = "land"
            end
        end
    end

    print("Grid generated.") -- Depuración

end

gDisasters.HeatSystem.UpdateGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        if CurTime() > gDisasters.HeatSystem.nextUpdateGrid then
            gDisasters.HeatSystem.nextUpdateGrid = CurTime() + gDisasters.HeatSystem.updateInterval

            for i= 1, updateBatchSize do
                local cell = table.remove(cellsToUpdate, 1)
                if not cell then
                    -- Reiniciar la lista de celdas para actualizar
                    cellsToUpdate = {}
                    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
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
                    if gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z] then
                        local currentcell = gDisasters.HeatSystem.GridMap[x][y][z]
                        currentcell.temperature =  gDisassters.HeatSystem.CalculateTemperature(x, y, z)
                        currentcell.humidity = gDisassters.HeatSystem.CalculateHumidity(x, y, z)
                        currentcell.pressure = gDisassters.HeatSystem.CalculatePressure(x, y, z)
                        currentcell.Airflow = gDisassters.HeatSystem.CalculateAirFlow(x, y, z)
                        currentcell.Airflow_Direction =  gDisassters.HeatSystem.CalculateAirFlowDirection(x, y, z)
                    else
                        print("Error: Cell position out of grid bounds.")
                    end
                end
            end
        end
    end
end
gDisasters.HeatSystem.UpdatePlayerGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        if CurTime() > gDisasters.HeatSystem.nextUpdateGridPlayer then
            gDisasters.HeatSystem.nextUpdateGridPlayer = CurTime() + gDisasters.HeatSystem.updateInterval

            for k,ply in pairs(player.GetAll()) do
                local pos = ply:GetPos()
                local px, py, pz = math.floor(pos.x / gridSize) * gridSize, math.floor(pos.y / gridSize) * gridSize, math.floor(pos.z / gridSize) * gridSize
                
                -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
                if gDisasters.HeatSystem.GridMap[px] and gDisasters.HeatSystem.GridMap[px][py] and gDisasters.HeatSystem.GridMap[px][py][pz] then
                    local cell = gDisasters.HeatSystem.GridMap[px][py][pz]

                    -- Verifica si las propiedades de la celda son válidas
                    if cell.temperature and cell.humidity and cell.pressure and cell.Airflow and cell.Airflow_Direction and cell.terrainType and cell.cloudDensity then
                        -- Actualiza las variables de la atmósfera del jugador
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = cell.temperature
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = cell.humidity
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = cell.pressure
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = cell.Airflow
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = cell.Airflow_Direction
                        print("Actual grid: x: " .. px .. ", y: ".. py .. ", z: " .. pz .. ", Terrain Type: " .. cell.terrainType .. ", Temp: " .. cell.temperature .. ", Humidity: " .. cell.humidity .. ", Pressure: " .. cell.pressure .. ", Airflow Speed: " .. cell.Airflow .. ", Cloud Density: " .. cell.cloudDensity)
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
end

gDisasters.HeatSystem.TemperatureToColor = function(temperature)
    -- Define una función simple para convertir la temperatura en un color
    local r = math.Clamp(temperature / 100, 0, 1)
    local b = math.Clamp(1 - r, 0, 1)
    return Color(r * 255, 0, b * 255)
end

gDisasters.HeatSystem.DrawGridDebug = function()
    if GetConVar("gdisasters_graphics_draw_heatsystem_grid"):GetInt() >= 1 then 
        local playerPos = LocalPlayer():GetPos() -- Obtener la posición del jugador

        for x, column in pairs(gDisasters.HeatSystem.GridMap) do
            for y, row in pairs(column) do
                for z, cell in pairs(row) do
                    local cellPos = Vector(x, y, z) -- Posición de la celda
                    local distance = playerPos:DistToSqr(cellPos) -- Distancia al cuadrado del jugador a la celda

                    if distance <= gDisasters.HeatSystem.maxDistance * gDisasters.HeatSystem.maxDistance then -- Comparar con la distancia máxima al cuadrado
                        local temperature = cell.temperature -- Obtener la temperatura de la celda
                        local color = Color(0, 0, 0) -- Color por defecto (negro)

                        -- Asignar un color según la temperatura
                        if temperature < freezingTemperature then
                            color = Color(0, 0, 255) -- Azul para temperaturas bajo cero
                        elseif temperature > boilingTemperature then
                            color = Color(255, 0, 0) -- Rojo para temperaturas sobre el punto de ebullición
                        else
                            local greenValue = math.Clamp((temperature - freezingTemperature) / (boilingTemperature - freezingTemperature) * 255, 0, 255)
                            color = Color(0, greenValue, 255 - greenValue) -- Gradiente de azul a verde para temperaturas entre el punto de congelación y el de ebullición
                        end

                        -- Dibujar el cubo en la posición correspondiente con el color calculado
                        render.SetColorMaterial()
                        render.DrawBox(cellPos, Angle(0, 0, 0), Vector(-gridSize / 2, -gridSize / 2, -gridSize / 2), Vector(gridSize / 2, gridSize / 2, gridSize / 2), color)
                    end
                end
            end
        end
    end
end

hook.Add("InitPostEntity", "gDisasters_GenerateGrid", gDisasters.HeatSystem.GenerateGrid)
hook.Add("InitPostEntity", "gDisasters_AddTemperatureHumiditySources", gDisasters.HeatSystem.AddTemperatureHumiditySources)
hook.Add("Think", "gDisasters_UpdateGrid", gDisasters.HeatSystem.UpdateGrid)
hook.Add("Think", "gDisasters_UpdatePlayerGrid", gDisasters.HeatSystem.UpdatePlayerGrid)
hook.Add("Think", "gDisasters_UpdateWeather", gDisasters.HeatSystem.UpdateWeather)
hook.Add("PostDrawTranslucentRenderables", "gDisasters_DrawGridDebug", gDisasters.HeatSystem.DrawGridDebug)