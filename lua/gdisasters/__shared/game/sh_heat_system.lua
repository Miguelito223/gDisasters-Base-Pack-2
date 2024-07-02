gDisasters.HeatSystem = {}

gDisasters.HeatSystem.GridMap = {}

gDisasters.HeatSystem.cellsToUpdate = {}

gDisasters.HeatSystem.WaterSources = {}
gDisasters.HeatSystem.LandSources = {}
gDisasters.HeatSystem.MountainSources = {}

gDisasters.HeatSystem.Cloud = {}

gDisasters.HeatSystem.cellSize = GetConVar("gdisasters_heat_system_cellsize"):GetInt()
gDisasters.HeatSystem.cellArea = gDisasters.HeatSystem.cellSize * gDisasters.HeatSystem.cellSize * gDisasters.HeatSystem.cellSize

gDisasters.HeatSystem.minTemperature = GetConVar("gdisasters_heat_system_mintemp"):GetFloat()
gDisasters.HeatSystem.maxTemperature = GetConVar("gdisasters_heat_system_maxtemp"):GetFloat()
gDisasters.HeatSystem.minHumidity = GetConVar("gdisasters_heat_system_minhumidity"):GetInt()
gDisasters.HeatSystem.maxHumidity = GetConVar("gdisasters_heat_system_maxhumidity"):GetInt()
gDisasters.HeatSystem.minPressure = GetConVar("gdisasters_heat_system_minpressure"):GetInt()
gDisasters.HeatSystem.maxPressure = GetConVar("gdisasters_heat_system_maxpressure"):GetInt()
gDisasters.HeatSystem.minwind = GetConVar("gdisasters_heat_system_minwind"):GetInt()
gDisasters.HeatSystem.maxwind = GetConVar("gdisasters_heat_system_maxwind"):GetInt()

gDisasters.HeatSystem.updateInterval = GetConVar("gdisasters_heat_system_updateinterval"):GetFloat() -- Intervalo de actualización en segundos
gDisasters.HeatSystem.updateBatchSize = GetConVar("gdisasters_heat_system_updatebatchsize"):GetInt()
gDisasters.HeatSystem.nextUpdateGrid = CurTime()
gDisasters.HeatSystem.nextUpdateGridPlayer = CurTime()
gDisasters.HeatSystem.nextUpdateWeather = CurTime()
gDisasters.HeatSystem.nextThunderThink = CurTime()
gDisasters.HeatSystem.nextUpdateGridEntity = CurTime()

gDisasters.HeatSystem.TempDiffusionCoefficient = GetConVar("gdisasters_heat_system_tempdifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.HumidityDiffusionCoefficient = GetConVar("gdisasters_heat_system_humiditydifussioncoefficient"):GetFloat()
gDisasters.HeatSystem.SolarInfluenceCoefficient = GetConVar("gdisasters_heat_system_solarinfluencecoefficient"):GetFloat()
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
gDisasters.HeatSystem.landwindEffect = -5         -- La tierra puede disminuir significativamente el flujo de aire
gDisasters.HeatSystem.waterwindEffect = 5        -- El agua puede aumentar significativamente el flujo de aire
gDisasters.HeatSystem.mountainwindEffect = -5     -- Las montaña pueden disminuir significativamente el flujo de aire

gDisasters.HeatSystem.coolingFactor = -5

gDisasters.HeatSystem.convergenceThreshold = 0.5
gDisasters.HeatSystem.strongStormThreshold = 2.0
gDisasters.HeatSystem.hailThreshold = 1.5
gDisasters.HeatSystem.hailHumidityThreshold = 0.8
gDisasters.HeatSystem.hailTemperatureThreshold = 0 
gDisasters.HeatSystem.rainThreshold = 1.0
gDisasters.HeatSystem.rainTemperatureThreshold = 15
gDisasters.HeatSystem.rainHumidityThreshold = 0.7
gDisasters.HeatSystem.cloudFormationThreshold = 0.3 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.rainFormationThreshold = 0.6 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.hailFormationThreshold = 0.3 -- This is a starting point; adjust based on testing
gDisasters.HeatSystem.snowTemperatureThreshold = 0
gDisasters.HeatSystem.snowFormationThreshold = 0.5
gDisasters.HeatSystem.stormThreshold = 0.8 
gDisasters.HeatSystem.stormFormationThreshold = 0.6
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
gDisasters.HeatSystem.stormLatentHeatThreshold = 1000  -- Valor realista ajustado para formación de tormenta
gDisasters.HeatSystem.hailLatentHeatThreshold = 334  -- Valor realista ajustado para formación de granizo
gDisasters.HeatSystem.cloudLatentHeatThreshold = 2260  -- Umbral de calor latente necesario para la formación de nubes
gDisasters.HeatSystem.snowLatentHeatThreshold = 334  -- Umbral de calor latente necesario para la formación de nieve
gDisasters.HeatSystem.rainLatentHeatThreshold = 2260  -- Umbral de calor latente necesario para la formación de lluvia

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

    local T = cell.temperature or 0.01

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    local exponent = (7.5 * T) / (237.3 + T)
    local VPs = 6.11 * math.pow(10, exponent)

    return VPs
end

gDisasters.HeatSystem.Calculatetemperaturebh = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local T = cell.temperature or 0.01
    local HR = cell.humidity or 0.01

    local Tbh = T * math.atan(0.151977 * math.sqrt(HR + 8.313659)) + math.atan(T + HR) - math.atan(HR - 1.676331) + 0.00391838 * math.pow(HR, 1.5) * math.atan(0.023101 * HR) - 4.686035

    return Tbh

end

gDisasters.HeatSystem.CalculateVPsHb = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local Tbh = cell.temperaturebh or 0.01

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    -- Calcular la presión de vapor usando la fórmula proporcionada
    local exponent = (7.5 * Tbh) / (237.3 + Tbh)
    local VPshb = 6.11 * math.pow(10, exponent)

    return VPshb

end

gDisasters.HeatSystem.CalculateVaporPressure = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local Td = cell.dewpoint or 0.01

    -- Calcular la presión de vapor usando la fórmula proporcionada
    local exponent = (7.5 * Td) / (237.3 + Td)
    local e = 6.11 * math.pow(10, exponent)

    return e
end


gDisasters.HeatSystem.CalculateWindChill = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local T = cell.temperature or 0.01-- Temperatura en Celsius
    local V = cell.wind or 0.01 -- Velocidad del viento en km/h

    -- Calcular la sensación térmica usando la fórmula proporcionada
    local windChill = 13.12 + 0.6215 * T - 11.37 * math.pow(V, 0.16) + 0.3965 * T * math.pow(V, 0.16)

    return windChill
end

gDisasters.HeatSystem.CalculateHeatIndex = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0

    local T = cell.temperature or 0.01 -- Temperatura en Celsius
    local RH = cell.humidity or 0.01 -- Humedad relativa en %

    -- Convertir la temperatura de Celsius a Fahrenheit
    T = T * 9 / 5 + 32

    -- Coeficientes para la fórmula del índice de calor
    local c1 = -42.379
    local c2 = 2.04901523
    local c3 = 10.14333127
    local c4 = -0.22475541
    local c5 = -0.00683783
    local c6 = -0.05481717
    local c7 = 0.00122874
    local c8 = 0.00085282
    local c9 = -0.00000199

    -- Calcular el índice de calor usando la fórmula proporcionada
    local HI = c1 + (c2 * T) + (c3 * RH) + (c4 * T * RH) + (c5 * T * T) + (c6 * RH * RH) +
               (c7 * T * T * RH) + (c8 * T * RH * RH) + (c9 * T * T * RH * RH)

    -- Convertir el índice de calor de Fahrenheit a Celsius
    HI = (HI - 32) * 5 / 9

    return HI
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
            return gDisasters.HeatSystem.calculateCondensationLatentHeat(cloudDensity)
        elseif (currentTemperature >= gDisasters.HeatSystem.boilingTemperature) then 
            return gDisasters.HeatSystem.calculateVaporizationLatentHeat(cloudDensity)
        elseif (currentTemperature <= gDisasters.HeatSystem.freezingTemperature) then 
           return gDisasters.HeatSystem.calculateFreezingLatentHeat(cloudDensity)
        end
    end
end

gDisasters.HeatSystem.CalculateTerrainInfluence = function(x, y, z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return end

    if cell.terrainType == "land" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.landTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.landHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainwindEffect = gDisasters.HeatSystem.landwindEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif cell.terrainType == "water" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.waterTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.waterHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainwindEffect = gDisasters.HeatSystem.waterwindEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif cell.terrainType == "mountain" then
        cell.terrainTemperatureEffect = gDisasters.HeatSystem.mountainTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainHumidityEffect = gDisasters.HeatSystem.mountainHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        cell.terrainwindEffect = gDisasters.HeatSystem.mountainwindEffect * gDisasters.HeatSystem.TerrainCoefficient
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
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
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

    local currentTemperature = currentCell.temperature or 0.01
    local cloudDensity = currentCell.cloudDensity or 0.01
    local solarInfluence = currentCell.solarInfluence or 0.01
    local terraintemperatureEffect = currentCell.terrainTemperatureEffect or 0.01
    local coolingEffect = currentCell.coolingEffect or 0.01
    local temperatureChange = gDisasters.HeatSystem.TempDiffusionCoefficient * (averageTemperature - currentTemperature)
    local newTemperature = currentTemperature + temperatureChange + terraintemperatureEffect + solarInfluence + coolingEffect

    -- Guardar las diferencias de temperatura calculadas en la celda actual
    currentCell.temperatureDifferenceX = temperatureDifferenceX
    currentCell.temperatureDifferenceY = temperatureDifferenceY
    currentCell.temperatureDifferenceZ = temperatureDifferenceZ

    return math.Clamp(newTemperature, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
end

gDisasters.HeatSystem.CalculateHumidity = function(x, y, z)    local totalHumidity = 0
    local count = 0

    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista

    local humidityDifferenceX, humidityDifferenceY, humidityDifferenceZ = 0, 0, 0

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.humidity and neighborCell.terrainType and neighborCell.terrainType == currentCell.terrainType then
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

    local currentHumidity = currentCell.humidity or 0.01
    local terrainHumidityEffect = currentCell.terrainHumidityEffect
    local humidityChange = gDisasters.HeatSystem.HumidityDiffusionCoefficient * (averageHumidity - currentHumidity)
    local newHumidity = currentHumidity + humidityChange + terrainHumidityEffect

    currentCell.humidityDifferenceX = humidityDifferenceX
    currentCell.humidityDifferenceY = humidityDifferenceY
    currentCell.humidityDifferenceZ = humidityDifferenceZ

    return math.Clamp(newHumidity, gDisasters.HeatSystem.minHumidity, gDisasters.HeatSystem.maxHumidity)
end


-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculatePressure = function(x, y, z) 
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Verificar que la celda actual exista

    local T = currentCell.temperature or 0.01

    -- Definir valores de los parámetros
    local P0 = 1013.25 -- Presión al nivel del mar estándar en hPa
    local h0 = 0 -- Altitud de 0 metros
    local gravity = 9.80665 -- Aceleración debido a la gravedad en m/s²
    local molarmass = 0.02897 -- Masa molar del aire en kg/mol
    local gas_constant = 8.31447 -- Constante específica del aire en J/(mol·K)
   
    local P1 = (P0 * math.exp(-gravity * molarmass * (z - h0) / (gas_constant * T))) * 100
    return math.Clamp(P1, gDisasters.HeatSystem.minPressure, gDisasters.HeatSystem.maxPressure)
end

-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculateDewPoint = function(x, y, z) 
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not cell then return 0 end -- Si la celda no existe, retornar 0
    
    local T = cell.temperature or 0.01
    local HR = cell.humidity or 0.01

    local a = 17.625
    local b = 243.04

    local alpha = math.log(HR / 100) + (a * T) / (b + T)

    local Td = (b * alpha) / (a - alpha)

    return Td
end

gDisasters.HeatSystem.calculateAirDensity = function(pressure, temperature)
    local R = 287.05 -- J/(kg·K)
    return pressure / (R * temperature)
end
-- Definir la función para calcular la velocidad del viento geostrófico
gDisasters.HeatSystem.CalculateWindSpeed = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = currentCell.temperature or 0.01
    local pressure = currentCell.pressure or 0.01

    -- Calcular la densidad del aire
    local airDensity = gDisasters.HeatSystem.calculateAirDensity(pressure, temperature)

    -- Suponer un gradiente de presión horizontal constante (en Pascales por metro)
    local pressureGradient = 0.01 -- Ajusta este valor según sea necesario

    -- Calcular la velocidad del viento de referencia
    local windSpeedRef = (1 / airDensity) * pressureGradient

    -- Calcular la velocidad del viento real
    local windSpeed = windSpeedRef * (1 + currentCell.terrainwindEffect)

    return math.Clamp(windSpeed, gDisasters.HeatSystem.minwind, gDisasters.HeatSystem.maxwind)
end

gDisasters.HeatSystem.CalculateWindDirection = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Si la celda no existe, retornar un vector nulo

    local temperature = currentCell.temperature or 0.01
    local pressure = currentCell.pressure or 0.01

    -- Calcular la densidad del aire
    local airDensity = gDisasters.HeatSystem.calculateAirDensity(pressure, temperature)

    -- Recuperar presiones de las celdas adyacentes
    local pressureLeft = (gDisasters.HeatSystem.GridMap[x-1] and gDisasters.HeatSystem.GridMap[x-1][y] and gDisasters.HeatSystem.GridMap[x-1][y][z] and gDisasters.HeatSystem.GridMap[x-1][y][z].pressure) or pressure
    local pressureRight = (gDisasters.HeatSystem.GridMap[x+1] and gDisasters.HeatSystem.GridMap[x+1][y] and gDisasters.HeatSystem.GridMap[x+1][y][z] and gDisasters.HeatSystem.GridMap[x+1][y][z].pressure) or pressure
    local pressureUp = (gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y+1] and gDisasters.HeatSystem.GridMap[x][y+1][z] and gDisasters.HeatSystem.GridMap[x][y+1][z].pressure) or pressure
    local pressureDown = (gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y-1] and gDisasters.HeatSystem.GridMap[x][y-1][z] and gDisasters.HeatSystem.GridMap[x][y-1][z].pressure) or pressure
    local pressureAbove = (gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z+1] and gDisasters.HeatSystem.GridMap[x][y][z+1].pressure) or pressure
    local pressureBelow = (gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z-1] and gDisasters.HeatSystem.GridMap[x][y][z-1].pressure) or pressure

    -- Calcular gradientes de presión básicos
    local dPdx = (pressureRight - pressureLeft) / 2
    local dPdy = (pressureAbove - pressureBelow) / 2
    local dPdz = (pressureUp - pressureDown) / 2

    -- Calcular la velocidad del viento geostrófico en las direcciones x, y, z
    local windSpeedX = (1 / airDensity) * dPdx
    local windSpeedY = (1 / airDensity) * dPdy
    local windSpeedZ = (1 / airDensity) * dPdz

    -- Crear el vector del viento
    local windVector = Vector(windSpeedX, windSpeedY, windSpeedZ)

    return windVector
end

gDisasters.HeatSystem.CalculateAirflow = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not currentCell then return 0 end -- Si la celda no existe, retornar 0

    local windSpeed = currentCell.windspeed or 0.01
    local temperature = currentCell.temperature or 0.01
    local pressure = currentCell.pressure or 0.01

    local area = gDisasters.HeatSystem.cellArea

    -- Calcular la densidad del aire
    local airDensity = gDisasters.HeatSystem.calculateAirDensity(pressure, temperature)

    -- Calcular el flujo de aire
    local airflow = windSpeed * area * airDensity

    return airflow
end

gDisasters.HeatSystem.GetCellType = function(x, y, z)
    local MapBounds = getMapBounds()
    local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
    local minX, minY, maxZ = math.floor(min.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(min.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize,  math.ceil(min.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
    local maxX, maxY, minZ = math.ceil(max.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.ceil(max.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize,  math.floor(max.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
    local floorz = math.floor(floor.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize

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

    
    local WATER_LEVEL = math.floor(tr.HitPos.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
    local MOUNTAIN_LEVEL = math.floor((floorz + 10000) / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize -- Ajusta la altura de la montaña según sea necesario
   
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
    local condensationLatentHeat = 2260
    return cloudDensity * condensationLatentHeat
end

-- Function to calculate latent heat released during freezing
gDisasters.HeatSystem.calculateFreezingLatentHeat = function(cloudDensity)
    local freezingLatentHeat = 334
    return cloudDensity * freezingLatentHeat
end

gDisasters.HeatSystem.CalculateVaporizationLatentHeat = function(cloudDensity)
    -- Calcular el calor latente de vaporización
    local VaporizationLatentHeat = 2260
    local latentHeat = cloudDensity * VaporizationLatentHeat 
    return latentHeat
end

gDisasters.HeatSystem.CalculateCloudDensity = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local humidity = currentCell.humidity or 0.01

    if humidity > gDisasters.HeatSystem.humidityThreshold then
        return (humidity - gDisasters.HeatSystem.humidityThreshold) * gDisasters.HeatSystem.CloudDensityCoefficient
    else
        return 0
    end
end

gDisasters.HeatSystem.CheckStormFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = currentCell.LatentHeat or 0.01
    if currentCell.humidity < gDisasters.HeatSystem.lowHumidityThreshold and currentCell.temperature < gDisasters.HeatSystem.lowTemperatureThreshold then
        if latentHeat > gDisasters.HeatSystem.stormLatentHeatThreshold then
            -- Trigger storm formation logic here
            gDisasters.HeatSystem.CreateStorm(x, y, z)
        end
    end
end

gDisasters.HeatSystem.CheckHailFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = currentCell.LatentHeat or 0.01
    if currentCell.temperature <= gDisasters.HeatSystem.hailTemperatureThreshold and currentCell.humidity >= gDisasters.HeatSystem.hailHumidityThreshold then
        if latentHeat > gDisasters.HeatSystem.hailLatentHeatThreshold then
            -- Trigger hail formation logic here
            gDisasters.HeatSystem.CreateHail(x, y, z)
        end
    end
end

gDisasters.HeatSystem.CheckSnowFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = currentCell.LatentHeat or 0.01
    if currentCell.temperature <= gDisasters.HeatSystem.snowTemperatureThreshold then
        if latentHeat >= gDisasters.HeatSystem.snowLatentHeatThreshold then
            -- Disparar la lógica de formación de nieve aquí
            gDisasters.HeatSystem.CreateSnow(x, y, z)
        end
    end
end

gDisasters.HeatSystem.CheckCloudFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = currentCell.LatentHeat or 0.01
    if currentCell.humidity > gDisasters.HeatSystem.humidityThreshold and currentCell.temperature < gDisasters.HeatSystem.temperatureThreshold then
        if latentHeat >= gDisasters.HeatSystem.cloudLatentHeatThreshold then
            -- Disparar la lógica de formación de nubes aquí
            gDisasters.HeatSystem.CreateCloud(x, y, z)
        end
    end
end

gDisasters.HeatSystem.CheckRainFormation = function(x, y, z)
    local currentCell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = currentCell.LatentHeat or 0.01
    if currentCell.temperature <= gDisasters.HeatSystem.rainTemperatureThreshold and currentCell.humidity >= gDisasters.HeatSystem.rainHumidityThreshold then
        if latentHeat >= gDisasters.HeatSystem.rainLatentHeatThreshold then
            -- Disparar la lógica de formación de lluvia aquí
            gDisasters.HeatSystem.CreateRain(x, y, z)
        end
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
    
    -- Generate clouds in cells with low humidity and temperature
    gDisasters.HeatSystem.AdjustCloudBaseHeight(x, y, z)
    
    local baseHeight = cell.baseHeight or z
    local pos = Vector(x, y, baseHeight)
    local color = Color(255,255,255)
    
    gDisasters.HeatSystem.SpawnCloud(pos, color)
    
end

-- Función para simular la formación y movimiento de nubes
gDisasters.HeatSystem.CreateStorm = function(x,y,z)
    local cell = gDisasters.HeatSystem.GridMap[x][y][z]

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

gDisasters.HeatSystem.CalculateTemperatureHumiditySources = function(x,y,z)
    print("Adding Sources...")

    gDisasters.HeatSystem.AddLandSources()
    gDisasters.HeatSystem.AddWaterSources()
    gDisasters.HeatSystem.AddMountainSources()

    local closestWaterDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.WaterSources)
    local closestLandDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.LandSources)
    local closestMountainDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.MountainSources)


    -- Comparar distancias y ajustar temperatura, humedad y presión en consecuencia
    if closestWaterDist < closestLandDist and closestWaterDist < closestMountainDist then
        return "water"
    elseif closestLandDist < closestMountainDist and closestLandDist < closestWaterDist then
        return "land"
    else
        return "mountain"
    end 
  

    print("Adding Finish")
end

-- Función para obtener las coordenadas de las fuentes de agua
gDisasters.HeatSystem.AddWaterSources = function()
    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "water" then
                    table.insert(gDisasters.HeatSystem.WaterSources, {x = x, y = y , z = z})
                end
            end
        end
    end
end

-- Función para obtener las coordenadas de las fuentes de tierra
gDisasters.HeatSystem.AddLandSources = function()
    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "land" then
                    table.insert(gDisasters.HeatSystem.LandSources, {x = x, y = y , z = z})
                end
            end
        end
    end
end

gDisasters.HeatSystem.AddMountainSources = function()
    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
        for y, row in pairs(column) do
            for z, cell in pairs(row) do
                local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
                if celltype == "mountain" then
                    table.insert(gDisasters.HeatSystem.MountainSources, {x = x, y = y , z = z})
                end
            end
        end
    end
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
                nubegrid.pressure = (nubegrid.pressure or 0.01) + pressureChange


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
                local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
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
    if CLIENT then return end
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
        elseif cell.cloudDensity > gDisasters.HeatSystem.stormThreshold then
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

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
gDisasters.HeatSystem.GenerateGrid = function(ply)
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then

        if file.Exists( "gDisasters/grid_" .. game.GetMap() .. ".txt", "DATA" ) then
            gDisasters.HeatSystem.LoadGrid()
        else
            -- Obtener los límites del mapa
            local mapBounds = getMapBounds()
            local minX, minY, maxZ = math.floor(mapBounds[2].x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(mapBounds[2].y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.ceil(mapBounds[2].z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
            local maxX, maxY, minZ = math.ceil(mapBounds[1].x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.ceil(mapBounds[1].y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(mapBounds[1].z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize

            print("Generating grid...") -- Depuración

            -- Inicializar la cuadrícula
            for x = minX, maxX, gDisasters.HeatSystem.cellSize do
                gDisasters.HeatSystem.GridMap[x] = {}
                for y = minY, maxY, gDisasters.HeatSystem.cellSize do
                    gDisasters.HeatSystem.GridMap[x][y] = {}
                    for z = minZ, maxZ, gDisasters.HeatSystem.cellSize do
                        gDisasters.HeatSystem.GridMap[x][y][z] = {}

                        -- Agregar fuente de temperatura    
                        gDisasters.HeatSystem.GridMap[x][y][z].terrainType = gDisasters.HeatSystem.CalculateTemperatureHumiditySources(x, y, z)

                        -- Calcular la influencia de terreno
                        gDisasters.HeatSystem.CalculateTerrainInfluence(x, y, z)

                        -- Calcular la temperatura y la humedad de la celda actual 
                        gDisasters.HeatSystem.GridMap[x][y][z].temperature = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Temperature"]
                        gDisasters.HeatSystem.GridMap[x][y][z].humidity = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Humidity"]
                        gDisasters.HeatSystem.GridMap[x][y][z].pressure = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Pressure"]
                        gDisasters.HeatSystem.GridMap[x][y][z].temperaturebh = gDisasters.HeatSystem.Calculatetemperaturebh(x, y, z)

                        -- Calcular la velocidad de aire
                        gDisasters.HeatSystem.GridMap[x][y][z].windspeed = GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Speed"]
                        gDisasters.HeatSystem.GridMap[x][y][z].winddirection =  GLOBAL_SYSTEM_ORIGINAL["Atmosphere"]["Wind"]["Direction"]
                        
                        -- Calcular el flujo de aire
                        gDisasters.HeatSystem.GridMap[x][y][z].airflow = gDisasters.HeatSystem.CalculateAirflow(x, y, z)

                        -- Calcular el punto de rocio
                        gDisasters.HeatSystem.GridMap[x][y][z].dewpoint = gDisasters.HeatSystem.CalculateDewPoint(x, y, z)
                        
                        -- Calcular la radiación solar
                        gDisasters.HeatSystem.GridMap[x][y][z].solarInfluence = gDisasters.HeatSystem.CalculateSolarRadiation(x, y, z, gDisasters.DayNightSystem.Time)
                        gDisasters.HeatSystem.GridMap[x][y][z].coolingEffect = gDisasters.HeatSystem.CalculateCoolEffect(x, y, z)

                        -- Calcular la latencia
                        gDisasters.HeatSystem.GridMap[x][y][z].LatentHeat = gDisasters.HeatSystem.CalculatelatentHeat(x, y, z)
                        
                        -- Calcular el indice de calor 
                        gDisasters.HeatSystem.GridMap[x][y][z].heatindex = gDisasters.HeatSystem.CalculateHeatIndex(x, y, z)
                        gDisasters.HeatSystem.GridMap[x][y][z].windchill = gDisasters.HeatSystem.CalculateWindChill(x, y, z)
                        
                        
                        -- Calcular la presión de vapor
                        gDisasters.HeatSystem.GridMap[x][y][z].VPs = gDisasters.HeatSystem.CalculateVPs(x, y, z)
                        gDisasters.HeatSystem.GridMap[x][y][z].VPsHb = gDisasters.HeatSystem.CalculateVPsHb(x, y, z)
                        gDisasters.HeatSystem.GridMap[x][y][z].VP = gDisasters.HeatSystem.CalculateVaporPressure(x, y, z)
                        
                        -- Calcular la densidad de nubes
                        gDisasters.HeatSystem.GridMap[x][y][z].cloudDensity = gDisasters.HeatSystem.CalculateCloudDensity(x,y,z)
                        
                        

                        print("Grid generated in position (" .. x .. "," .. y .. "," .. z .. ")") -- Depuración
                    end
                end
            end
          
            gDisasters.HeatSystem.SaveGrid()

            print("Grid generated.") -- Depuración
        
        end


    end

end

gDisasters.HeatSystem.SaveGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        print("Saving grid...")
        
        if not file.IsDir("gDisasters", "DATA") then
            file.CreateDir("gDisasters")
        end

        file.Write("gDisasters/grid_" .. game.GetMap() .. ".txt", util.TableToJSON(gDisasters.HeatSystem.GridMap))
    end
end

gDisasters.HeatSystem.LoadGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        print("Saving grid...")
        gDisasters.HeatSystem.GridMap = util.JSONToTable(file.Read("gDisasters/grid_" .. game.GetMap() .. ".txt", "DATA")) or file.Read("gDisasters/grid_" .. game.GetMap() .. ".txt", "DATA")
    end
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
                        -- Calcular la influencia de terreno
                        gDisasters.HeatSystem.CalculateTerrainInfluence(x, y, z)

                        -- Calcular la temperatura y la humedad de la celda actual 
                        currentcell.temperature = gDisasters.HeatSystem.CalculateTemperature(x, y, z)
                        currentcell.humidity = gDisasters.HeatSystem.CalculateHumidity(x, y, z)
                        currentcell.pressure = gDisasters.HeatSystem.CalculatePressure(x, y, z)
                        currentcell.temperaturebh = gDisasters.HeatSystem.Calculatetemperaturebh(x, y, z)

                        -- Calcular la velocidad de aire
                        currentcell.windspeed = gDisasters.HeatSystem.CalculateWindSpeed(x, y, z)
                        currentcell.winddirection =  gDisasters.HeatSystem.CalculateWindDirection(x, y, z)
                        
                        -- Calcular el flujo de aire
                        currentcell.airflow = gDisasters.HeatSystem.CalculateAirflow(x, y, z)

                        -- Calcular el punto de rocio
                        currentcell.dewpoint = gDisasters.HeatSystem.CalculateDewPoint(x, y, z)
                        
                        -- Calcular la radiación solar
                        currentcell.solarInfluence = gDisasters.HeatSystem.CalculateSolarRadiation(x, y, z, gDisasters.DayNightSystem.Time)
                        currentcell.coolingEffect = gDisasters.HeatSystem.CalculateCoolEffect(x, y, z)

                        -- Calcular la latencia
                        currentcell.LatentHeat = gDisasters.HeatSystem.CalculatelatentHeat(x, y, z)
                        
                        -- Calcular el indice de calor 
                        currentcell.heatindex = gDisasters.HeatSystem.CalculateHeatIndex(x, y, z)
                        currentcell.windchill = gDisasters.HeatSystem.CalculateWindChill(x, y, z)
                        
                        
                        -- Calcular la presión de vapor
                        currentcell.VPs = gDisasters.HeatSystem.CalculateVPs(x, y, z)
                        currentcell.VPsHb = gDisasters.HeatSystem.CalculateVPsHb(x, y, z)
                        currentcell.VP = gDisasters.HeatSystem.CalculateVaporPressure(x, y, z)
                        
                        -- Calcular la densidad de nubes
                        currentcell.cloudDensity = gDisasters.HeatSystem.CalculateCloudDensity(x,y,z)
                        
                        --update the weather
                        gDisasters.HeatSystem.UpdateWeatherInCell(x, y, z)
                        gDisasters.HeatSystem.SimulateConvergence(x, y, z)
                        gDisasters.HeatSystem.CheckStormFormation(x, y, z)
                        gDisasters.HeatSystem.CheckHailFormation(x, y, z)
                        gDisasters.HeatSystem.CheckCloudFormation(x, y, z)
                        gDisasters.HeatSystem.CheckRainFormation(x, y, z)
                        gDisasters.HeatSystem.CheckSnowFormation(x,y,z)
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
                local px, py, pz = math.floor(pos.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(pos.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(pos.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
                
                -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
                if gDisasters.HeatSystem.GridMap[px] and gDisasters.HeatSystem.GridMap[px][py] and gDisasters.HeatSystem.GridMap[px][py][pz] then
                    local cell = gDisasters.HeatSystem.GridMap[px][py][pz]

                    -- Verifica si las propiedades de la celda son válidas
                    if cell.temperature and cell.humidity and cell.pressure and cell.windspeed and cell.winddirection and cell.terrainType and cell.cloudDensity then
                        -- Actualiza las variables de la atmósfera del jugador
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = cell.temperature
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = cell.humidity
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = cell.pressure
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = cell.windspeed
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = cell.winddirection
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
                    local px, py, pz = math.floor(pos.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(pos.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(pos.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize

                    -- Comprueba si la posición calculada está dentro de los límites de la cuadrícula
                    if gDisasters.HeatSystem.GridMap[px] and gDisasters.HeatSystem.GridMap[px][py] and gDisasters.HeatSystem.GridMap[px][py][pz] then
                        local cell = gDisasters.HeatSystem.GridMap[px][py][pz]
                        local windspeed  = cell.windspeed
	                    local winddir    = cell.winddirection
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
                        if cell.windspeed and cell.winddirection and windphysics_enabled and windspeed >= 1 and CurTime() >= GLOBAL_SYSTEM["Atmosphere"]["Wind"]["NextThink"] then
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
                        render.DrawBox(cellPos, Angle(0, 0, 0), Vector(-gDisasters.HeatSystem.cellSize, -gDisasters.HeatSystem.cellSize, -gDisasters.HeatSystem.cellSize), Vector(gDisasters.HeatSystem.cellSize, gDisasters.HeatSystem.cellSize, gDisasters.HeatSystem.cellSize), color)
                    end
                end
            end
        end
    end
end

hook.Add("InitPostEntity", "gDisasters_GenerateGrid", gDisasters.HeatSystem.GenerateGrid)
hook.Add("Think", "gDisasters_UpdateGrid", gDisasters.HeatSystem.UpdateGrid)
hook.Add("Think", "gDisasters_UpdatePlayerGrid", gDisasters.HeatSystem.UpdatePlayerGrid)
hook.Add("Think", "gDisasters_UpdateEntityGrid", gDisasters.HeatSystem.UpdateEntityGrid)
hook.Add("PostDrawTranslucentRenderables", "gDisasters_DrawGridDebug", gDisasters.HeatSystem.DrawGridDebug)