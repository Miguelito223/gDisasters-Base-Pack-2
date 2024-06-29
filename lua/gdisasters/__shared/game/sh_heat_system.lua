gDisasters.HeatSystem = {}
gDisasters.HeatSystem.GridMap = {}
gDisasters.HeatSystem.cellsToUpdate = {}
gDisasters.HeatSystem.waterSources = {}
gDisasters.HeatSystem.LandSources = {}
gDisasters.HeatSystem.Cloud = {}

-- Tamaño de la cuadrícula y rango de temperatura
gDisasters.HeatSystem.gridSize = GetConVar("gdisasters_heat_system_gridsize"):GetInt() -- Tamaño de cada cuadrado en unidades
gDisasters.HeatSystem.totalgridSize = gDisasters.HeatSystem.gridSize * gDisasters.HeatSystem.gridSize * gDisasters.HeatSystem.gridSize


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
gDisasters.HeatSystem.nextUpdateGridEntity = CurTime()


gDisasters.HeatSystem.airflowForceMultiplier = 10 -- Ajusta este valor según la intensidad deseada del flujo de aire


gDisasters.HeatSystem.coolingFactor = -5
gDisasters.HeatSystem.gas_constant = 8.314 -- J/(mol·K)
gDisasters.HeatSystem.specific_heat_vapor = 1.996 -- J/(g·K)


gDisasters.HeatSystem.TempDiffusionCoefficient = GetConVar("gdisasters_heat_system_tempdifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.HumidityDiffusionCoefficient = GetConVar("gdisasters_heat_system_humiditydifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.SolarInfluenceCoefficient = GetConVar("gdisasters_heat_system_solarinfluencecoefficient"):GetFloat()
gDisasters.HeatSystem.LatentHeatCoefficient = GetConVar("gdisasters_heat_system_latentheatcoefficient"):GetFloat()
gDisasters.HeatSystem.AirflowCoefficient = GetConVar("gdisasters_heat_system_airflowcoefficient"):GetFloat()
gDisasters.HeatSystem.CloudDensityCoefficient = GetConVar("gdisasters_heat_system_clouddensitycoefficient"):GetFloat()  -- Coeficiente para convertir humedad en densidad de nubes
gDisasters.HeatSystem.ConvergenceCoefficient = GetConVar("gdisasters_heat_system_convergencecoefficient"):GetFloat()
gDisasters.HeatSystem.TerrainCoefficient = GetConVar("gdisasters_heat_system_terraincoefficient"):GetFloat()
gDisasters.HeatSystem.CoolingCoefficient = GetConVar("gdisasters_heat_system_coolingcoefficient"):GetFloat()


gDisasters.HeatSystem.waterTemperatureEffect = -2   -- El agua tiende a mantener una temperatura más constante
gDisasters.HeatSystem.landTemperatureEffect = 4     -- La tierra se calienta y enfría más rápido que el agua
gDisasters.HeatSystem.mountainTemperatureEffect = -3  -- Las montañas tienden a ser más frías debido a la altitud
gDisasters.HeatSystem.waterHumidityEffect = 5       -- El agua puede aumentar significativamente la humedad en su entorno
gDisasters.HeatSystem.landHumidityEffect = -5        -- La tierra puede retener menos humedad que el agua
gDisasters.HeatSystem.mountainHumidityEffect = -4    -- Las montañas pueden influir moderadamente en la humedad debido a las corrientes de aire
gDisasters.HeatSystem.landAirflowEffect = -5         -- La tierra puede disminuir significativamente el flujo de aire
gDisasters.HeatSystem.waterAirflowEffect = 5        -- El agua puede aumentar significativamente el flujo de aire
gDisasters.HeatSystem.mountainairflowEffect = -5     -- Las montaña pueden disminuir significativamente el flujo de aire


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
gDisasters.HeatSystem.CalculateSolarRadiation = function(x, y, z, hour)
    if not hour then return 0 end
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

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
    return math.Clamp(solarRadiation, 0, maxRadiation) * gDisasters.HeatSystem.SolarInfluenceCoefficient
    
end

gDisasters.HeatSystem.CalculateVPs = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = cell.temperature or 0
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local T = temperature -- Convertir la temperatura a Kelvin

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    local VPs
    if T < 0 then
        -- Usar la fórmula para temperaturas bajo cero
        VPs = math.exp(31.9602 - (6270.3605 / T) - (0.46057 * math.log(T)))
    else
        -- Usar la fórmula para temperaturas sobre cero
        VPs = math.exp(60.433 - (6834.271 / T) - (5.16923 * math.log(T)))
    end

    return VPs
end

gDisasters.HeatSystem.Calculatetemperaturebh = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = cell.temperature or 0
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local humidity = cell.humidity or 0

    local T = temperature

    -- Convertir la humedad relativa a decimal (por ejemplo, 50% -> 0.5)
    local HR = humidity

    local Tbh = T * math.atan(0.151977 * math.sqrt(HR + 8.313659)) + math.atan(T + HR) - math.atan(HR - 1.676331) + 0.00391838 * math.pow(HR, 1.5) * math.atan(0.023101 * HR) - 4.686035

    return Tbh

end

gDisasters.HeatSystem.CalculateVPsHb = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperaturebh = cell.temperaturebh or 0
    if temperaturebh == 0 then
        temperaturebh = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local Tbh = temperaturebh

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    local VPshb
    if Tbh < 0 then
        -- Usar la fórmula para temperaturas bajo cero
        VPshb = math.exp(31.9602 - (6270.3605 / Tbh) - (0.46057 * math.log(Tbh)))
    else
        -- Usar la fórmula para temperaturas sobre cero
        VPshb = math.exp(60.433 - (6834.271 / Tbh) - (5.16923 * math.log(Tbh)))
    end
    return VPshb

end

gDisasters.HeatSystem.CalculateVaporPressure = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = cell.temperature or 0
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    -- Constantes
    local P = cell.pressure / 100 -- Presión atmosférica en Pascales (a nivel del mar)
    local Tbh = cell.temperaturebh -- Temperatura base de referencia en Celsius (ajusta según tu caso)
    local Cp = 1005 -- Capacidad calorífica del aire seco en kJ/kg·K
    local Lv = 2.5e6 -- Calor latente de vaporización del agua en J/kg

    -- Convertir Cp a J/kg·K para que las unidades sean consistentes
    Cp = Cp * 1000

    -- Calcular el factor psicrométrico
    local a1 = (Cp * P) / Lv

    -- Convertir la temperatura de Celsius a Kelvin
    local T = temperature
    
    -- Calcular la presión de vapor saturada a la temperatura base de referencia (VPs,bh)
    local VPshb = cell.VPsHb

    -- Calcular la presión de vapor (Pv) usando la fórmula proporcionada
    local Pv = VPshb - (a1 * P * (T - Tbh))

    return Pv
end



gDisasters.HeatSystem.CalculateCoolEffect = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

    local solarInfluence = cell.solarInfluence or 0
    if solarInfluence <= 0 then
        return gDisasters.HeatSystem.coolingFactor * gDisasters.HeatSystem.CoolingCoefficient
    end
end

gDisasters.HeatSystem.CalculatelatentHeat = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

    local cloudDensity = cell.cloudDensity or 0
    local currentTemperature = cell.temperature or 0

    if cloudDensity > 0 then
        if (currentTemperature > gDisasters.HeatSystem.freezingTemperature) then 
            return gDisasters.HeatSystem.calculateCondensationLatentHeat(cloudDensity) * gDisasters.HeatSystem.LatentHeatCoefficient
        else 
            return gDisasters.HeatSystem.calculateFreezingLatentHeat(cloudDensity) * gDisasters.HeatSystem.LatentHeatCoefficient
        end
    end
end

gDisasters.HeatSystem.CalculateTerrainInfluence = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

    if cell.terrainType == "land" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.landTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.landHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainAirflowEffect = gDisasters.HeatSystem.landAirflowEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif cell.terrainType == "water" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.waterTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.waterHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainAirflowEffect = gDisasters.HeatSystem.waterAirflowEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif cell.terrainType == "mountain" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.mountainTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.mountainHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainAirflowEffect = gDisasters.HeatSystem.mountainairflowEffect * gDisasters.HeatSystem.TerrainCoefficient
    end
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
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.gridSize, y + dy * gDisasters.HeatSystem.gridSize, z + dz * gDisasters.HeatSystem.gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.temperature and neighborCell.terrainType and neighborCell.terrainType == currentCell.terrainType then
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

    local currentTemperature = currentCell.temperature or 0
    local cloudDensity = currentCell.cloudDensity or 0
    local solarInfluence = currentCell.solarInfluence or 0
    local terraintemperatureEffect = currentCell.terrainTemperatureEffect or 0
    local Latentheat = currentCell.LatentHeat or 0
    local coolingEffect = currentCell.coolingEffect or 0
    local temperatureChange = gDisasters.HeatSystem.TempDiffusionCoefficient * (averageTemperature - currentTemperature)
    local newTemperature = currentTemperature + temperatureChange + terraintemperatureEffect + Latentheat + solarInfluence + coolingEffect

    -- Guardar las diferencias de temperatura calculadas en la celda actual
    currentCell.temperatureDifferenceX = temperatureDifferenceX
    currentCell.temperatureDifferenceY = temperatureDifferenceY
    currentCell.temperatureDifferenceZ = temperatureDifferenceZ

    return math.Clamp(newTemperature, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
end

gDisasters.HeatSystem.CalculateHumidity = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista
    
    local vp = currentCell.VP
    local vps = currentCell.VPs
    local newHumidity = (vp/vps) * 100

    return math.Clamp(newHumidity, gDisasters.HeatSystem.minHumidity, gDisasters.HeatSystem.maxHumidity)
end


-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculatePressure = function(x, y, z) 
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista

    -- Definir valores de los parámetros
    local Po = 1013.25 -- Presión al nivel del mar estándar en hPa
    local altitude = 1000 -- Altitud de 1000 metros
    local gravity = 9.80665 -- Aceleración debido a la gravedad en m/s²
    local gas_constant = 8.31447 -- Constante específica del aire en J/(mol·K)
    local Tm = 288.15 -- Temperatura media en Kelvin
   
    local P1 = Po / math.exp(z * gravity / (gas_constant * Tm))
    return math.Clamp(P1, gDisasters.HeatSystem.minPressure, gDisasters.HeatSystem.maxPressure)
end

-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculateDewPoint = function(x, y, z) 
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0
    
    local temperature = cell.temperature or 0
    if temperature == 0 then
        temperature = 0.01 -- Ajuste mínimo para evitar división por cero
    end

    local humidity = cell.humidity or 0

    local Td = temperature + 35 * math.log(humidity)

    return Td
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
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.gridSize, y + dy * gDisasters.HeatSystem.gridSize, z + dz * gDisasters.HeatSystem.gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.pressure and neighborCell.terrainType and neighborCell.terrainType == currentCell.terrainType then
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
    end

    -- Contribución adicional del flujo de aire debido a la difusión natural
    local combinedDiffusionContributionX = currentCell.temperatureDifferenceX
    local combinedDiffusionContributionY = currentCell.temperatureDifferenceY
    local combinedDiffusionContributionZ = currentCell.temperatureDifferenceZ

    local diffusionContributionX = combinedDiffusionContributionX * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionY = combinedDiffusionContributionY * gDisasters.HeatSystem.AirflowCoefficient
    local diffusionContributionZ = combinedDiffusionContributionZ * gDisasters.HeatSystem.AirflowCoefficient

    -- Crear un vector de flujo de aire
    local airflowVector = Vector(totalDeltaPressureX + diffusionContributionX, totalDeltaPressureY + diffusionContributionY, totalDeltaPressureZ + diffusionContributionZ)

    -- Calcular la magnitud del flujo de aire
    local airflowMagnitude = airflowVector:Length()
 
    local newAirflow = airflowMagnitude * gDisasters.HeatSystem.AirflowCoefficient * currentCell.terrainAirflowEffect

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
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.gridSize, y + dy * gDisasters.HeatSystem.gridSize, z + dz * gDisasters.HeatSystem.gridSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.pressure and neighborCell.terrainType and neighborCell.terrainType == currentCell.terrainType then
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
    end
    -- Contribución adicional del flujo de aire debido a la difusión natural
    local combinedDiffusionContributionX = currentCell.temperatureDifferenceX
    local combinedDiffusionContributionY = currentCell.temperatureDifferenceY
    local combinedDiffusionContributionZ = currentCell.temperatureDifferenceZ
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
        windDirection.z = airflowVector.z / airflowMagnitude
    end

    return windDirection
end

gDisasters.HeatSystem.GetCellType = function(x, y, z)
    local MapBounds = getMapBounds()
    local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
    local minX, minY, maxZ = math.floor(min.x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(min.y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize,  math.ceil(min.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize
    local maxX, maxY, minZ = math.ceil(max.x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.ceil(max.y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize,  math.floor(max.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize
    local floorz = math.floor(floor.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize

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

    
    local WATER_LEVEL = math.floor(tr.HitPos.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize
    local MOUNTAIN_LEVEL = math.floor((floorz + 10000) / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize -- Ajusta la altura de la montaña según sea necesario
   
    -- Trace to check for land
    local trLand = util.TraceLine({
        start = traceStart,
        endpos = traceEnd - Vector(0, 0, 100), -- Un trace más largo para detectar el terreno
        mask = MASK_SOLID_BRUSHONLY, -- Colisionar solo con el terreno sólido
        filter = function(ent) return ent:IsValid() end -- Filtrar cualquier entidad válida
    })

    -- Si el trazado de línea colisiona con tierra, la celda es de tipo "land"
    if trLand.Hit then
        if trLand.HitPos.z <= WATER_LEVEL then
            return "water" -- La celda es agua si está por debajo del nivel del agua detectado
        else
            return "land" -- La celda es tierra si está por encima del nivel del agua
        end
    end

    -- Simular diferentes tipos de celdas basadas en coordenadas
    if z >= MOUNTAIN_LEVEL then
        return "mountain" -- Por encima del nivel de la montaña es montaña
    else
        return "land" -- En otras coordenadas es tierra
    end
end


gDisasters.HeatSystem.CreateSnow = function(x, y, z) 
    if CLIENT then return end -- No ejecutar en el cliente (solo en el servidor)
    if #ents.FindByClass("env_spritetrail") > gDisasters.HeatSystem.MaxRainDrop then return end
    
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
    if #ents.FindByClass("env_spritetrail") > gDisasters.HeatSystem.MaxRainDrop then return end

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

    if humidity > gDisasters.HeatSystem.humidityThreshold then
        currentCell.cloudDensity = (humidity - gDisasters.HeatSystem.humidityThreshold) * gDisasters.HeatSystem.CloudDensityCoefficient
    else
        currentCell.cloudDensity = 0
    end
end

gDisasters.HeatSystem.CheckStormFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity and currentCell.cloudDensity > 0 then
        if currentCell.temperature > gDisasters.HeatSystem.freezingTemperature then
            latentHeat = gDisasters.HeatSystem.calculateCondensationLatentHeat(currentCell.cloudDensity)
        else
            latentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(currentCell.cloudDensity)
        end
    end

    if latentHeat > gDisasters.HeatSystem.stormLatentHeatThreshold then
        -- Trigger storm formation logic here
        gDisasters.HeatSystem.CreateStorm(x, y, z)
    end
end

gDisasters.HeatSystem.CheckHailFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity and currentCell.cloudDensity > 0 then
        if currentCell.temperature <= gDisasters.HeatSystem.freezingTemperature then
            latentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(currentCell.cloudDensity)
        end
    end

    if latentHeat > gDisasters.HeatSystem.hailLatentHeatThreshold then
        -- Trigger hail formation logic here
        gDisasters.HeatSystem.CreateHail(x, y, z)
    end
end

gDisasters.HeatSystem.CheckSnowFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= gDisasters.HeatSystem.snowFormationThreshold and currentCell.temperature <= gDisasters.HeatSystem.snowTemperatureThreshold then
        -- Calcular el calor latente necesario para la formación de nieve
        latentHeat = gDisasters.HeatSystem.CalculateSnowLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= gDisasters.HeatSystem.snowLatentHeatThreshold then
        -- Disparar la lógica de formación de nieve aquí
        gDisasters.HeatSystem.CreateSnow(x, y, z)
    end
end

gDisasters.HeatSystem.CheckCloudFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= gDisasters.HeatSystem.cloudFormationThreshold then
        -- Calcular el calor latente necesario para la formación de nubes
        latentHeat = gDisasters.HeatSystem.CalculateCloudLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= gDisasters.HeatSystem.cloudLatentHeatThreshold then
        -- Disparar la lógica de formación de nubes aquí
        gDisasters.HeatSystem.CreateCloud(x, y, z)
    end
end

gDisasters.HeatSystem.CheckRainFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = 0

    if currentCell.cloudDensity >= gDisasters.HeatSystem.rainFormationThreshold then
        -- Calcular el calor latente necesario para la formación de lluvia
        latentHeat = gDisasters.HeatSystem.CalculateRainLatentHeat(currentCell.cloudDensity)
    end

    if latentHeat >= gDisasters.HeatSystem.rainLatentHeatThreshold then
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
    if #ents.FindByClass("gd_cloud_cumulus") > gDisasters.HeatSystem.MaxClouds then return end

    local cloud = ents.Create("gd_cloud_cumulus")
    if not IsValid(cloud) then return end -- Verifica si la entidad fue creada correctamente

    cloud:SetPos(pos)
    cloud.DefaultColor = color
    cloud:SetModelScale(0.5, 0)
    cloud:Spawn()
    cloud:Activate()

    table.insert(gDisasters.HeatSystem.Cloud, cloud)

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
    if humidity > gDisasters.HeatSystem.humidityThreshold and temperature < gDisasters.HeatSystem.temperatureThreshold then
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
    if humidity < gDisasters.HeatSystem.lowHumidityThreshold and temperature < gDisasters.HeatSystem.lowTemperatureThreshold then
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
gDisasters.HeatSystem.GetClosestDistance = function(x, y, z, sources)
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
    if #ents.FindByClass("gd_d1_hail_ch") > gDisasters.HeatSystem.MaxHail then return end
    
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

                if nubegrid.humidity > gDisasters.HeatSystem.humidityThreshold and nubegrid.temperature < temperatureThreshold then
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
                local nx, ny, nz = x + dx * gDisasters.HeatSystem.gridSize, y + dy * gDisasters.HeatSystem.gridSize, z + dz * gDisasters.HeatSystem.gridSize
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
    currentCell.cloudDensity = math.min(currentCell.cloudDensity + (averageCloudDensity * gDisasters.HeatSystem.ConvergenceCoefficient), 1)
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
    if cell.cloudDensity > gDisasters.HeatSystem.cloudDensityThreshold then
        if cell.temperature <= gDisasters.HeatSystem.freezingTemperature and cell.cloudDensity > gDisasters.HeatSystem.hailThreshold then
            weatherType = "hail"
        elseif cell.cloudDensity > gDisasters.HeatSystem.thunderstormThreshold then
            weatherType = "thunder"
        elseif cell.cloudDensity > gDisasters.HeatSystem.rainThreshold then
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
    local minX, minY, maxZ = math.floor(mapBounds[2].x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(mapBounds[2].y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.ceil(mapBounds[2].z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize
    local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.ceil(mapBounds[1].y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(mapBounds[1].z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize

    print("Generating grid...") -- Depuración

    -- Inicializar la cuadrícula
    for x = minX, maxX, gDisasters.HeatSystem.gridSize do
        gDisasters.HeatSystem.GridMap[x] = {}
        for y = minY, maxY, gDisasters.HeatSystem.gridSize do
            gDisasters.HeatSystem.GridMap[x][y] = {}
            for z = minZ, maxZ, gDisasters.HeatSystem.gridSize do
                gDisasters.HeatSystem.GridMap[x][y][z] = {}
                gDisasters.HeatSystem.GridMap[x][y][z].temperature = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Temperature"]
                gDisasters.HeatSystem.GridMap[x][y][z].humidity = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
                gDisasters.HeatSystem.GridMap[x][y][z].pressure = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
                gDisasters.HeatSystem.GridMap[x][y][z].airflow = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Speed"]
                gDisasters.HeatSystem.GridMap[x][y][z].airflow_direction = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Direction"]
                gDisasters.HeatSystem.GridMap[x][y][z].cloudDensity = 0
                gDisasters.HeatSystem.GridMap[x][y][z].terrainType = "land"
                print("Grid generated in position (" .. x .. "," .. y .. "," .. z .. ")") -- Depuración
            end
        end
    end

    print("Grid generated.") -- Depuración

end

gDisasters.HeatSystem.UpdateGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        if CurTime() > gDisasters.HeatSystem.nextUpdateGrid then
            gDisasters.HeatSystem.nextUpdateGrid = CurTime() + gDisasters.HeatSystem.updateInterval

            for i= 1, gDisasters.HeatSystem.updateBatchSize do
                local cell = table.remove(gDisasters.HeatSystem.cellsToUpdate, 1)
                if not cell then
                    -- Reiniciar la lista de celdas para actualizar
                    gDisasters.HeatSystem.cellsToUpdate = {}
                    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
                        for y, row in pairs(column) do
                            for z, cell in pairs(row) do
                                table.insert(gDisasters.HeatSystem.cellsToUpdate, {x, y, z})
                            end
                        end
                    end
                    cell = table.remove(gDisasters.HeatSystem.cellsToUpdate, 1)
                end

                if cell then
                    local x, y, z = cell[1], cell[2], cell[3]
                    if gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z] then
                        local currentcell = gDisasters.HeatSystem.GridMap[x][y][z]
                        gDisasters.HeatSystem.CalculateTerrainInfluence(x, y, z)
                        currentcell.solarInfluence = gDisasters.HeatSystem.CalculateSolarRadiation(x, y, z, gDisasters.DayNightSystem.Time)
                        currentcell.coolingEffect = gDisasters.HeatSystem.CalculateCoolEffect(x, y, z)
                        currentcell.LatentHeat = gDisasters.HeatSystem.CalculatelatentHeat(x, y, z)
                        currentcell.temperature = gDisasters.HeatSystem.CalculateTemperature(x, y, z)
                        currentcell.temperaturebh = gDisasters.HeatSystem.Calculatetemperaturebh(x, y, z)
                        currentcell.pressure = gDisasters.HeatSystem.CalculatePressure(x, y, z)
                        currentcell.VPs = gDisasters.HeatSystem.CalculateVPs(x, y, z)
                        currentcell.VPsHb = gDisasters.HeatSystem.CalculateVPsHb(x, y, z)
                        currentcell.VP = gDisasters.HeatSystem.CalculateVaporPressure(x, y, z)
                        currentcell.humidity = gDisasters.HeatSystem.CalculateHumidity(x, y, z)
                        currentcell.dewpoint = gDisasters.HeatSystem.CalculateDewPoint(x, y, z)
                        currentcell.airflow = gDisasters.HeatSystem.CalculateAirFlow(x, y, z)
                        currentcell.airflow_direction =  gDisasters.HeatSystem.CalculateAirFlowDirection(x, y, z)
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
                local px, py, pz = math.floor(pos.x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(pos.y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(pos.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize
                
                -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
                if gDisasters.HeatSystem.GridMap[px] and gDisasters.HeatSystem.GridMap[px][py] and gDisasters.HeatSystem.GridMap[px][py][pz] then
                    local cell = gDisasters.HeatSystem.GridMap[px][py][pz]

                    -- Verifica si las propiedades de la celda son válidas
                    if cell.temperature and cell.humidity and cell.pressure and cell.airflow and cell.airflow_direction and cell.terrainType and cell.cloudDensity then
                        -- Actualiza las variables de la atmósfera del jugador
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = cell.temperature
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = cell.humidity
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = cell.pressure
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = cell.airflow
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = cell.airflow_direction
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

gDisasters.HeatSystem.UpdateEntityGrid = function()
    if CLIENT then return end
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        
        if CurTime() > gDisasters.HeatSystem.nextUpdateGridEntity then
            gDisasters.HeatSystem.nextUpdateGridEntity = CurTime() + gDisasters.HeatSystem.updateInterval

            for _, ent in pairs(ents.GetAll()) do
                if ent:IsValid() and ent:GetPhysicsObject():IsValid() then
                    local pos = ent:GetPos()
                    local px, py, pz = math.floor(pos.x / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(pos.y / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize, math.floor(pos.z / gDisasters.HeatSystem.gridSize) * gDisasters.HeatSystem.gridSize

                    -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
                    if gDisasters.HeatSystem.GridMap[px] and gDisasters.HeatSystem.GridMap[px][py] and gDisasters.HeatSystem.GridMap[px][py][pz] then
                        local cell = gDisasters.HeatSystem.GridMap[px][py][pz]
                        local windspeed  = cell.airflow
	                    local winddir    = cell.airflow_direction
                        local windphysics_enabled = GetConVar( "gdisasters_wind_physics_enabled" ):GetInt() == 1 
                        local windconstraints_remove = GetConVar( "gdisasters_wind_candamageconstraints" ):GetInt() == 1

                        local function WindUnweld(ent)
                            local wind_mul   = (math.Clamp(windspeed,200, 256) -200) / 10
                            local phys = ent:GetPhysicsObject()

                            if HitChance(0.01 + wind_mul ) then
                                local can_play_sound = false


                                if #constraint.GetTable( ent ) != 0 then
                                    can_play_sound = true 
                                elseif phys:IsMotionEnabled()==false then
                                    can_play_sound = true 
                                end	

                                if can_play_sound then
                                    local material_type = GetMaterialType(ent)


                                    if material_type == "wood" then 
                                        sound.Play(table.Random(Break_Sounds.Wood), ent:GetPos(), 80, math.random(90,110), 1)
                                    
                                    elseif material_type == "metal" then 
                                        sound.Play(table.Random(Break_Sounds.Metal), ent:GetPos(), 80, math.random(90,110), 1)
                                    
                                    elseif material_type == "plastic" then 
                                        sound.Play(table.Random(Break_Sounds.Plastic), ent:GetPos(), 80, math.random(90,110), 1)

                                    elseif material_type == "rock" then 
                                        sound.Play(table.Random(Break_Sounds.Rock), ent:GetPos(), 80, math.random(90,110), 1)

                                    elseif material_type == "glass" then 
                                        sound.Play(table.Random(Break_Sounds.Glass), ent:GetPos(), 80, math.random(90,110), 1)

                                    elseif material_type == "ice" then 
                                        sound.Play(table.Random(Break_Sounds.Ice), ent:GetPos(), 80, math.random(90,110), 1)
                                    
                                    else
                                        sound.Play(table.Random(Break_Sounds.Generic), ent:GetPos(), 80, math.random(90,110), 1)
                                    
                                    end

                                    phys:EnableMotion(true)
                                    phys:Wake()
                                    constraint.RemoveAll( ent )
                                end
                            end

                        end

                        local function performTrace(ply, direction)
                        
                            local tr = util.TraceLine( {
                                start = ply:GetPos(),
                                endpos = ply:GetPos() + direction * 60000,
                                filter = function( ent ) if ent:IsWorld() then return true end end
                            } )
                        
                        
                            
                            return tr.HitPos
                        end

                        -- Verifica si las propiedades de la celda son válidas
                        if cell.airflow and cell.airflow_direction and windphysics_enabled and windspeed >= 1 and CurTime() >= GLOBAL_SYSTEM["Atmosphere"]["Wind"]["NextThink"] then
                            local phys = ent:GetPhysicsObject()
                            local outdoor = isOutdoor(ent, true) 
				            local blocked = IsSomethingBlockingWind(ent)
                            if blocked==false and outdoor==true then
                                -- Calcula la fuerza a aplicar
                                local area    = Area(ent)
                                local mass    = phys:GetMass()

                                local force_mul_area     = math.Clamp((area/680827),0,1) -- bigger the area >> higher the f multiplier is
                                local friction_mul       = math.Clamp((mass/50000),0,1) -- lower the mass  >> lower frictional force 
                                local avrg_mul           = (force_mul_area + friction_mul) / 2 

                                local windvel           = convert_MetoSU(convert_KMPHtoMe(windspeed / 2.9225)) * winddir 
                                local frictional_scalar = math.Clamp(windvel:Length(), 0, mass)
                                local frictional_velocity = frictional_scalar * -windvel:GetNormalized()
                                local windvel_new         = (windvel + frictional_velocity) * -1

                                local windvel_cap         = windvel_new:Length() - ent:GetVelocity():Length() 

                                if windvel_cap > 0 then
                                    
                                    phys:AddVelocity(windvel_new )
                                
                                end
                        

                                if windconstraints_remove then 
                                    WindUnweld(ent)
                                
                                end

                            end
                        end
                    else
                        -- Manejo de celdas fuera de los límites de la cuadrícula
                        print("Error: Posición fuera de los límites de la cuadrícula.")
                    end
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
                        local color = gDisasters.HeatSystem.TemperatureToColor(temperature)

                        -- Dibujar el cubo en la posición correspondiente con el color calculado
                        render.SetColorMaterial()
                        render.DrawBox(cellPos, Angle(0, 0, 0), Vector(-gDisasters.HeatSystem.gridSize / 2, -gDisasters.HeatSystem.gridSize / 2, -gDisasters.HeatSystem.gridSize / 2), Vector(gDisasters.HeatSystem.gridSize / 2, gDisasters.HeatSystem.gridSize / 2, gDisasters.HeatSystem.gridSize / 2), color)
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
hook.Add("Think", "gDisasters_UpdateEntityGrid", gDisasters.HeatSystem.UpdateEntityGrid)
hook.Add("Think", "gDisasters_UpdateWeather", gDisasters.HeatSystem.UpdateWeather)
hook.Add("PostDrawTranslucentRenderables", "gDisasters_DrawGridDebug", gDisasters.HeatSystem.DrawGridDebug)