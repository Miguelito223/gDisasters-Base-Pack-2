gDisasters.HeatSystem = {}

gDisasters.HeatSystem.GridMap = {}

gDisasters.HeatSystem.cellsToUpdate = {}

gDisasters.HeatSystem.LandSources = {}

gDisasters.HeatSystem.SandSources = {}
gDisasters.HeatSystem.GrassSources = {}
gDisasters.HeatSystem.SnowSources = {}
gDisasters.HeatSystem.AsfaltSources = {}

gDisasters.HeatSystem.WaterSources = {}

gDisasters.HeatSystem.AirSources = {}

gDisasters.HeatSystem.Clouds = {}
gDisasters.HeatSystem.Rain = {}
gDisasters.HeatSystem.Hail = {}
gDisasters.HeatSystem.Snow = {}

gDisasters.HeatSystem.cellSize = GetConVar("gdisasters_heat_system_cellsize"):GetInt() or 5000
gDisasters.HeatSystem.cellArea = 6 * gDisasters.HeatSystem.cellSize^2
gDisasters.HeatSystem.cellVolumen = gDisasters.HeatSystem.cellSize^3
gDisasters.HeatSystem.cellDistance = math.sqrt(gDisasters.HeatSystem.cellSize^2 + gDisasters.HeatSystem.cellSize^2 + gDisasters.HeatSystem.cellSize^2)

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


-- Efectos de temperatura
gDisasters.HeatSystem.waterTemperatureEffect = -2       -- El agua tiende a mantener una temperatura más constante
gDisasters.HeatSystem.GrassTemperatureEffect = 4        -- La tierra se calienta y enfría más rápido que el agua
gDisasters.HeatSystem.AsfaltTemperatureEffect = 6      -- El asfalto absorbe y retiene calor rápidamente
gDisasters.HeatSystem.SandTemperatureEffect = 5         -- La arena también se calienta rápido, pero disipa el calor ligeramente
gDisasters.HeatSystem.SnowTemperatureEffect = -4        -- La nieve tiene un efecto de enfriamiento debido a su albedo alto

-- Efectos de humedad
gDisasters.HeatSystem.waterHumidityEffect = 5           -- El agua puede aumentar significativamente la humedad en su entorno
gDisasters.HeatSystem.GrassHumidityEffect = -5          -- La tierra puede retener menos humedad que el agua
gDisasters.HeatSystem.AsfaltHumidityEffect = -10       -- El asfalto tiende a secar el ambiente al absorber poca humedad
gDisasters.HeatSystem.SandHumidityEffect = -8           -- La arena retiene muy poca humedad y tiende a secar el ambiente
gDisasters.HeatSystem.SnowHumidityEffect = 3            -- La nieve puede liberar humedad cuando se derrite

-- Efectos de viento
gDisasters.HeatSystem.GrassWindEffect = -5              -- La tierra puede disminuir significativamente el flujo de aire
gDisasters.HeatSystem.waterWindEffect = 5               -- El agua puede aumentar significativamente el flujo de aire
gDisasters.HeatSystem.AsfaltWindEffect = -3            -- El asfalto crea menos fricción que el suelo, pero no tanto como el agua
gDisasters.HeatSystem.SandWindEffect = 2                -- La arena ofrece resistencia media al viento, pero no tanto como la tierra
gDisasters.HeatSystem.SnowWindEffect = -4               -- La nieve puede disminuir el flujo de aire al acumularse y ofrecer resistencia

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

gDisasters.HeatSystem.materialHeatCapacity = 1005

gDisasters.HeatSystem.maxDistance = 100000

gDisasters.HeatSystem.CalculateThermalInertia = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end  -- Verifica si la celda existe

    local airDensity = Cell.airdensity
    local materialHeatCapacity = gDisasters.HeatSystem.materialHeatCapacity  -- Capacidad calorífica del aire (J/(kg·°C))
    local cellThickness = gDisasters.HeatSystem.cellSize  -- Espesor de la celda (en metros, ajustable)

    -- Calcular la inercia térmica de la celda (en J/(m²·°C·s))
    local thermalInertia = airDensity * materialHeatCapacity * cellThickness
    Cell.thermalInertia = thermalInertia
    return Cell.thermalInertia
end

gDisasters.HeatSystem.CalculateConvectiveFactor = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end  -- Verifica si la celda existe
    
    local temperature = Cell.temperature or 23  -- Temperatura de la celda (en °C)
    local surroundingTemperature = 20  -- Temperatura del aire circundante (en °C, ajustable)
    local windSpeed = Cell.windSpeed or 0.1  -- Velocidad del viento (en m/s)
    local airDensity = Cell.airdensity or 0.01
    
    -- Constantes para el cálculo
    local heatTransferCoefficient = 20  -- Coeficiente de transferencia de calor por convección (ajustable)

    -- Cálculo de la diferencia de temperatura entre la superficie y el aire
    local deltaT = temperature - surroundingTemperature
    
    -- Reducir la convección si el delta de temperatura es bajo
    if math.abs(deltaT) < 2 then
        deltaT = deltaT * 0.5  -- Amortiguación para variaciones de temperatura bajas
    end
    -- Cálculo del factor de convección (en función de la diferencia de temperatura, la densidad del aire y la velocidad del viento)
    local convectiveFactor = heatTransferCoefficient * airDensity * windSpeed * deltaT
    
    -- Guardar el valor del factor convectivo en la celda
    Cell.convectiveFactor = convectiveFactor
    
    return Cell.convectiveFactor
end

gDisasters.HeatSystem.CalculateRadiationEmissionFactor = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end  -- Verifica si la celda existe
    
    local temperature = Cell.temperature or 23  -- Temperatura de la celda (en °C)
    local area = gDisasters.HeatSystem.cellArea or 1  -- Área de la celda (en m²)
    local emissivity = Cell.emissivity or 0.9  -- Emisividad de la superficie (valor entre 0 y 1)
    local temperatureKelvin = convert_CelciustoKelvin(temperature)  -- Convertir temperatura a Kelvin
    local ambientTemperature = convert_CelciustoKelvin(23)  -- Temperatura ambiente en Kelvin (ajustable)

    -- Constante de Stefan-Boltzmann (en W/m²·K⁴)
    local sigma = 5.67e-8  

    local temperatureDifference = math.max(temperatureKelvin^4 - ambientTemperature^4, 0) -- Evita valores negativos
    -- Cálculo de la radiación emitida por la superficie
    local radiationEmission = sigma * emissivity * area * temperatureDifference
    
    -- Guardar el valor de la emisión de radiación en la celda
    Cell.radiationEmission = radiationEmission * (gDisasters.HeatSystem.SolarInfluenceCoefficient or 0.01)
    
    return Cell.radiationEmission
end

-- Función para normalizar un vector
gDisasters.HeatSystem.CalculateSolarRadiation = function(x, y, z, hour)
    if not hour then return 0 end
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end

    -- Parámetros de ubicación y constantes solares
    local latitude = z -- Latitud de la celda
    local solarConstant = 1361    -- Constante solar en W/m² (promedio en el espacio)

    -- Parámetros de amanecer y atardecer
    local sunrise = gDisasters.DayNightSystem.InternalVars.time.Dawn_Start
    local sunset = gDisasters.DayNightSystem.InternalVars.time.Dusk_Start

    -- Verificar si la hora está fuera del rango de la luz solar
    if hour < sunrise or hour > sunset then
        return 0
    end

    -- Cálculo simplificado del ángulo de elevación solar (solo usando latitud y hora)
    local solarDeclination = 23.44  -- Declination promedio sin variación estacional
    local solarAltitudeAngle = math.asin(math.sin(math.rad(latitude)) * math.sin(math.rad(solarDeclination)) + math.cos(math.rad(latitude)) * math.cos(math.rad(solarDeclination)) * math.cos(math.pi * (hour - 12) / 12))
    
    -- Factor de atenuación basado en condiciones atmosféricas y ángulo de incidencia
    local weatherCondition = Cell.Precipitation or "clear"
    local attenuationFactor = 1.0
    if weatherCondition == "cloudy" then
        attenuationFactor = 0.7
    elseif weatherCondition == "rainy" then
        attenuationFactor = 0.5
    elseif weatherCondition == "stormy" then
        attenuationFactor = 0.3
    end

    -- Cálculo de la irradiancia en el suelo (W/m²) ajustada para condiciones atmosféricas
    local airMass = 1 / math.max(0.1, math.sin(solarAltitudeAngle))
    local irradiance = solarConstant * math.sin(solarAltitudeAngle) * math.exp(-0.1 * airMass) * attenuationFactor
    
    -- Guardar la influencia solar ajustada en la celda
    Cell.solarInfluence = irradiance * (gDisasters.HeatSystem.SolarInfluenceCoefficient or 0.01)
    
    return Cell.solarInfluence
end

gDisasters.HeatSystem.CalculateVPs = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local T = Cell.temperature or 23

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    local exponent = (7.5 * T) / (237.3 + T)
    local VPs = 6.11 * math.pow(10, exponent)
    
    Cell.VPs = VPs

    return Cell.VPs
end

gDisasters.HeatSystem.Calculatetemperaturebh = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local T = Cell.temperature or 23
    local HR = Cell.humidity or 25

    local Tbh = T * math.atan(0.151977 * math.sqrt(HR + 8.313659)) + math.atan(T + HR) - math.atan(HR - 1.676331) + 0.00391838 * math.pow(HR, 1.5) * math.atan(0.023101 * HR) - 4.686035
    
    Cell.temperaturebh = Tbh
    
    return Cell.temperaturebh

end

gDisasters.HeatSystem.CalculateEmissivity = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    -- Asignar el albedo según el tipo de terreno de la celda
    local terrainType = Cell.terrainType

    if terrainType == "Snow" then
        Cell.emissivity = 0.80
        return Cell.emissivity
    elseif terrainType == "Sand" then
        Cell.emissivity = 0.76
        return Cell.emissivity
    elseif terrainType == "Water" then
        Cell.emissivity = 0.95
        return Cell.emissivity  -- Albedo para agua
    elseif terrainType == "Grass" then
        Cell.emissivity = 0.92
        return Cell.emissivity  -- Albedo para bosque
    elseif terrainType == "Asfalt" then
        Cell.emissivity = 0.85
        return Cell.emissivity   -- Albedo para asfalto
    else
        Cell.emissivity = 0
        return Cell.emissivity   -- Valor por defecto si no se especifica el tipo de terreno
    end

end

gDisasters.HeatSystem.CalculateVPsHb = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local Tbh = Cell.temperaturebh or 0.01

    -- Calcular la presión de vapor saturada usando la fórmula adecuada
    -- Calcular la presión de vapor usando la fórmula proporcionada
    local exponent = (7.5 * Tbh) / (237.3 + Tbh)
    local VPshb = 6.11 * math.pow(10, exponent)

    Cell.VPshb = VPshb
    return Cell.VPshb

end

gDisasters.HeatSystem.CalculateVaporPressure = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local Td = Cell.dewpoint or 0.01

    -- Calcular la presión de vapor usando la fórmula proporcionada
    local exponent = (7.5 * Td) / (237.3 + Td)
    local e = 6.11 * math.pow(10, exponent)

    Cell.VP = e

    return Cell.VP
end


gDisasters.HeatSystem.CalculateWindChill = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local T = Cell.temperature or 23 -- Temperatura en Celsius
    local V = Cell.windspeed or 0 -- Velocidad del viento en km/h

    -- Calcular la sensación térmica usando la fórmula proporcionada
    local windChill = 13.12 + 0.6215 * T - 11.37 * math.pow(V, 0.16) + 0.3965 * T * math.pow(V, 0.16)
    Cell.windchill = math.Clamp(windChill, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
    return Cell.windchill
end

gDisasters.HeatSystem.CalculatePrecipitation = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    local latentHeat = Cell.LatentHeat or 0.01
    local Temperature = Cell.temperature or 23
    local Humidity = Cell.humidity or 25

    if Humidity > gDisasters.HeatSystem.humidityThreshold and Temperature < gDisasters.HeatSystem.temperatureThreshold then
        if latentHeat >= gDisasters.HeatSystem.cloudLatentHeatThreshold then
            -- Disparar la lógica de formación de nubes aquí
            gDisasters.HeatSystem.CreateCloud(x, y, z)
            Cell.precipitation = "Cloud"
            return Cell.precipitation
        end


    elseif Humidity < gDisasters.HeatSystem.lowHumidityThreshold and Temperature < gDisasters.HeatSystem.lowTemperatureThreshold then
        if latentHeat > gDisasters.HeatSystem.stormLatentHeatThreshold then
            -- Trigger storm formation logic here
            gDisasters.HeatSystem.CreateStorm(x, y, z)
            Cell.precipitation = "Storming"
            return  Cell.precipitation
        end
    

    elseif Temperature <= gDisasters.HeatSystem.hailTemperatureThreshold and Humidity >= gDisasters.HeatSystem.hailHumidityThreshold then
        if latentHeat > gDisasters.HeatSystem.hailLatentHeatThreshold then
            -- Trigger hail formation logic here
            gDisasters.HeatSystem.CreateHail(x, y, z)
            Cell.precipitation = "Hailing"
            return Cell.precipitation
        end
    

    elseif Temperature <= gDisasters.HeatSystem.rainTemperatureThreshold and Humidity >= gDisasters.HeatSystem.rainHumidityThreshold then
        if latentHeat >= gDisasters.HeatSystem.rainLatentHeatThreshold then
            -- Disparar la lógica de formación de lluvia aquí
            gDisasters.HeatSystem.CreateRain(x, y, z)
            Cell.precipitation = "Raining"
            return Cell.precipitation
        end
    

    elseif Temperature <= gDisasters.HeatSystem.snowTemperatureThreshold then
        if latentHeat >= gDisasters.HeatSystem.snowLatentHeatThreshold then
            -- Disparar la lógica de formación de nieve aquí
            gDisasters.HeatSystem.CreateSnow(x, y, z)
            Cell.precipitation = "Snowing"
            return Cell.precipitation
        end
    end

    Cell.precipitation = "clear"
    return Cell.precipitation
end

gDisasters.HeatSystem.CalculateHeatIndex = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local T = convert_CelciustoFahrenheit(Cell.temperature or 23) -- Temperatura en Celsius
    local RH = Cell.humidity or 25 -- Humedad relativa en %

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
    local HI = convert_FahrenheittoCelcius(c1 + (c2 * T) + (c3 * RH) + (c4 * T * RH) + (c5 * T * T) + (c6 * RH * RH) + (c7 * T * T * RH) + (c8 * T * RH * RH) + (c9 * T * T * RH * RH))
    Cell.heatindex = math.Clamp( HI, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
    return Cell.heatindex
end




gDisasters.HeatSystem.CalculateCoolEffect = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end

    local solarInfluence = Cell.solarInfluence or 0
    if solarInfluence <= 0 then
        Cell.coolingEffect = gDisasters.HeatSystem.coolingFactor * gDisasters.HeatSystem.CoolingCoefficient
        return Cell.coolingEffect
    else
        Cell.coolingEffect = 0
        return Cell.coolingEffect
    end
end

gDisasters.HeatSystem.CalculatelatentHeat = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end

    local cloudDensity = Cell.cloudDensity or 0
    local currentTemperature = Cell.temperature or 0

    if cloudDensity > 0 then
        if (currentTemperature > gDisasters.HeatSystem.freezingTemperature) then 
            Cell.LatentHeat = gDisasters.HeatSystem.calculateCondensationLatentHeat(cloudDensity)
            return Cell.LatentHeat
        elseif (currentTemperature >= gDisasters.HeatSystem.boilingTemperature) then 
            Cell.LatentHeat = gDisasters.HeatSystem.CalculateVaporizationLatentHeat(cloudDensity)
            return Cell.LatentHeat
        elseif (currentTemperature <= gDisasters.HeatSystem.freezingTemperature) then 
            Cell.LatentHeat = gDisasters.HeatSystem.calculateFreezingLatentHeat(cloudDensity)
            return Cell.LatentHeat
        end
    else
        Cell.LatentHeat = 0
        return Cell.LatentHeat
    end
end

gDisasters.HeatSystem.CalculateTerrainInfluence = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end
   
    if Cell.terrainType == "Grass" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.GrassTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.GrassHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.GrassWindEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif Cell.terrainType == "Snow" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.SnowTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.SnowHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.SnowWindEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif Cell.terrainType == "Asfalt" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.AsfaltTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.AsfaltHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.AsfaltWindEffect * gDisasters.HeatSystem.TerrainCoefficient   
    elseif Cell.terrainType == "Sand" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.SandTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.SandHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.SandWindEffect * gDisasters.HeatSystem.TerrainCoefficient   
    elseif Cell.terrainType == "Water" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.waterTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.waterHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.waterWindEffect * gDisasters.HeatSystem.TerrainCoefficient
    elseif Cell.terrainType == "Land" then
        Cell.terrainTemperatureEffect = gDisasters.HeatSystem.GrassTemperatureEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainHumidityEffect = gDisasters.HeatSystem.GrassHumidityEffect * gDisasters.HeatSystem.TerrainCoefficient
        Cell.terrainwindEffect = gDisasters.HeatSystem.GrassWindEffect * gDisasters.HeatSystem.TerrainCoefficient       
    elseif Cell.terrainType == "Air" then
        Cell.terrainTemperatureEffect = 0
        Cell.terrainHumidityEffect = 0
        Cell.terrainwindEffect = 0
    else
        Cell.terrainTemperatureEffect = 0
        Cell.terrainHumidityEffect = 0
        Cell.terrainwindEffect = 0
    end

end

gDisasters.HeatSystem.CalculateTemperature = function(x, y, z)
    local totalTemperature = 0
    local count = 0

    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Verificar que la celda actual exista

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.temperature then
                            totalTemperature = totalTemperature + neighborCell.temperature
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    if count == 0 then 
        Cell.temperature = 23  
        return Cell.temperature
    end

    local averageTemperature = totalTemperature / count
    local currentTemperature = Cell.temperature or 23

    -- Factores adicionales (solar, terreno, etc.)
    local solarInfluence = gDisasters.HeatSystem.CalculateSolarRadiation(x, y, z, gDisasters.DayNightSystem.Time)
    local terraintemperatureEffect = Cell.terrainTemperatureEffect or 0
    local coolingEffect = gDisasters.HeatSystem.CalculateCoolEffect(x, y, z)
                        
    local z_min = math.max(z, 0)

    local temperatureDropPerMeter = 0.00650 -- Gradiente adiabático estándar en °C por metro
    local altitudeAdjustment = z_min * temperatureDropPerMeter -- Calcular la temperatura en la superficie
    local skybox = getMapSkyBox()
    local maxAltitude = skybox[2].z or 1000

    local incomingEnergy = solarInfluence * (1 - (Cell.albedo or 0.3))
    local outgoingRadiation = gDisasters.HeatSystem.CalculateRadiationEmissionFactor(x,y,z) * (currentTemperature ^ 4)
    local convectiveAdjustment = gDisasters.HeatSystem.CalculateConvectiveFactor(x,y,z) * (z_min / maxAltitude) * (averageTemperature - currentTemperature)
    local temperatureChange = gDisasters.HeatSystem.TempDiffusionCoefficient * (averageTemperature - currentTemperature)
    local deltaTemperature = (incomingEnergy - outgoingRadiation) / ((Cell.mass or 1) * gDisasters.HeatSystem.materialHeatCapacity) * (Cell.thermalInertia or 1)

    -- Calcular la nueva temperatura
    local newTemperature = math.Clamp(currentTemperature + deltaTemperature + temperatureChange + convectiveAdjustment  + terraintemperatureEffect + coolingEffect - altitudeAdjustment, gDisasters.HeatSystem.minTemperature, gDisasters.HeatSystem.maxTemperature)
    
    Cell.temperature = newTemperature
    
    return Cell.temperature
end

gDisasters.HeatSystem.CalculateHumidity = function(x, y, z)    
    local totalHumidity = 0
    local count = 0

    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Verificar que la celda actual exista

    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell.humidity then
                            totalHumidity = totalHumidity + neighborCell.humidity
                            count = count + 1
                        end
                    end
                end
            end
        end
    end

    if count == 0 then 
        Cell.humidity = 25
        return Cell.humidity
    end

    local averageHumidity = totalHumidity / count

    local currentHumidity = Cell.humidity or 25
    local terrainHumidityEffect = Cell.terrainHumidityEffect
    local humidityChange = gDisasters.HeatSystem.HumidityDiffusionCoefficient * (averageHumidity - currentHumidity)
    local newHumidity = math.Clamp(currentHumidity + humidityChange + terrainHumidityEffect, gDisasters.HeatSystem.minHumidity, gDisasters.HeatSystem.maxHumidity)
    
    Cell.humidity = newHumidity
    
    return Cell.humidity
end


-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculatePressure = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Verificar que la celda actual exista

    local T = convert_CelciustoKelvin(Cell.temperature or 23) -- Suponiendo que la temperatura se pasa en °C

    -- Definir valores de los parámetros
    local P0 = 1013.25 -- Presión al nivel del mar estándar en hPa
    local h0 = 0 -- Altitud de 0 metros
    local gravity = 9.80665 -- Aceleración debido a la gravedad en m/s²
    local molarmass = 0.02897 -- Masa molar del aire en kg/mol
    local gas_constant = 8.31447 -- Constante específica del aire en J/(mol·K)
    
    -- Estimar la temperatura a la altitud 'z'
    local lapse_rate = 0.0065  -- Tasa de descenso de temperatura en K/m
    local T_at_z = T - lapse_rate * z  -- Aproximación de la temperatura a la altitud 'z'
    T_at_z = math.max(T_at_z, 0)  -- Evitar temperaturas negativas

    -- Ecuación barométrica para la presión
    local P1 = math.exp(-gravity * molarmass * (z - h0) / (gas_constant * T_at_z)) * P0
    -- Convertir la presión de hPa a Pa
    P1 = convert_HpatoPa(P1)
    
    -- Limitar la presión a los valores máximo y mínimo
    P1 = math.Clamp(P1, gDisasters.HeatSystem.minPressure, gDisasters.HeatSystem.maxPressure)

    Cell.pressure = P1
    
    return Cell.pressure
end

-- Función para calcular la presión de una celda basada en temperatura y humedad
gDisasters.HeatSystem.CalculateDewPoint = function(x, y, z) 
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0
    
    local T = Cell.temperature or 23
    local HR = Cell.humidity or 25

    local a = 17.625
    local b = 243.04

    local alpha = math.log(HR / 100) + (a * T) / (b + T)

    local Td = (b * alpha) / (a - alpha)
    Cell.dewpoint = math.Clamp(Td,gDisasters.HeatSystem.minTemperature,gDisasters.HeatSystem.maxTemperature)
    return Cell.dewpoint
end

gDisasters.HeatSystem.CalculateAirDensity = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = convert_CelciustoKelvin(Cell.temperature or 23) 
    local pressure = Cell.pressure or 101325  -- Pa, presión a nivel del mar por defecto

    local R = 287.05 -- Constante de gas para el aire en J/(kg·K)
    local airdensity = pressure / (R * temperature) 
    
    Cell.airdensity = airdensity
    
    return Cell.airdensity
end
-- Definir la función para calcular la velocidad del viento geostrófico
gDisasters.HeatSystem.CalculateWindSpeed = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Si la celda no existe, retornar 0

    local temperature = Cell.temperature or 23
    local pressure = Cell.pressure or 101325
    local altitude = z or 0  -- Altitud de la celda (puede ser en metros)
    local terrainFriction = Cell.terrainwindEffect or 1  -- Coeficiente de fricción según el tipo de terreno

    -- Calcular la densidad del aire en la celda actual
    local airDensity = Cell.airdensity

    -- Variables para el gradiente de presión y temperatura
    local deltaPressure = 0
    local deltaTemperature = 0
    local neighborCount = 0

    -- Iterar sobre las celdas vecinas para calcular gradientes de presión y temperatura
    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell then
                            deltaPressure = deltaPressure + ((neighborCell.pressure or 101325 ) - pressure)
                            deltaTemperature = deltaTemperature + ((neighborCell.temperature or 23) - temperature)
                            neighborCount = neighborCount + 1
                        end
                    end
                end
            end
        end
    end

    -- Promediar los gradientes si existen celdas vecinas
    if neighborCount > 0 then
        deltaPressure = deltaPressure / neighborCount
        deltaTemperature = deltaTemperature / neighborCount
    end

    -- Calcular el gradiente de presión en función de las celdas vecinas
    local pressureGradient = deltaPressure / (neighborCount * gDisasters.HeatSystem.cellDistance)  -- cellDistance es la distancia entre celdas

    -- Ajustar el gradiente de presión por el gradiente de temperatura
    local temperatureInfluence = deltaTemperature * 0.01  -- Coeficiente para el efecto de temperatura en la presión

    -- Calcular la velocidad del viento de referencia usando la ecuación del gradiente de presión
    local windSpeedRef = (1 / airDensity) * (pressureGradient + temperatureInfluence)

    -- Ajustar la velocidad del viento por el efecto de altitud (por ejemplo, aumentando un 5% por cada 100 metros)
    local altitudeEffect = 1 + math.min(altitude * 0.0005, 0.1) -- Ajuste para incremento de velocidad de viento con la altitud

    -- Calcular la velocidad del viento real
    local windSpeed = windSpeedRef * altitudeEffect / terrainFriction

    Cell.windspeed = math.Clamp(windSpeed, gDisasters.HeatSystem.minwind, gDisasters.HeatSystem.maxwind)
    -- Limitar la velocidad del viento a los valores mínimos y máximos establecidos en el sistema
    return Cell.windspeed
end
gDisasters.HeatSystem.CalculateWindDirection = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return Vector(0, 0, 0) end  -- Retorna un vector nulo si la celda no existe

    local temperature = Cell.temperature or 23
    local pressure = Cell.pressure or 101325

    -- Calcular la densidad del aire en la celda actual
    local airDensity = Cell.airdensity

    -- Recuperar presiones de las celdas adyacentes en los ejes x, y y z
    local pressureLeft = gDisasters.HeatSystem.GridMap[x-1] and gDisasters.HeatSystem.GridMap[x-1][y] and gDisasters.HeatSystem.GridMap[x-1][y][z] and gDisasters.HeatSystem.GridMap[x-1][y][z].pressure or pressure
    local pressureRight = gDisasters.HeatSystem.GridMap[x+1] and gDisasters.HeatSystem.GridMap[x+1][y] and gDisasters.HeatSystem.GridMap[x+1][y][z] and gDisasters.HeatSystem.GridMap[x+1][y][z].pressure or pressure
    local pressureAbove = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y+1] and gDisasters.HeatSystem.GridMap[x][y+1][z] and gDisasters.HeatSystem.GridMap[x][y+1][z].pressure or pressure
    local pressureBelow = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y-1] and gDisasters.HeatSystem.GridMap[x][y-1][z] and gDisasters.HeatSystem.GridMap[x][y-1][z].pressure or pressure
    local pressureUp = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y][z+1] and gDisasters.HeatSystem.GridMap[x][y][z+1].pressure or pressure
    local pressureDown = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y][z-1] and gDisasters.HeatSystem.GridMap[x][y][z-1].pressure or pressure

    -- Calcular gradientes de presión en cada dirección
    local dPdx = (pressureRight - pressureLeft) / 2
    local dPdy = (pressureAbove - pressureBelow) / 2
    local dPdz = (pressureUp - pressureDown) / 2

    -- Incorporar el Efecto Coriolis en los gradientes (ajustable, opcional)
    local coriolisEffect = gDisasters.HeatSystem.CoriolisCoefficient or 0.0001  -- Ajusta este valor según la simulación
    dPdx = dPdx + coriolisEffect * dPdy
    dPdy = dPdy - coriolisEffect * dPdx

    -- Ajustar el efecto de una dirección de viento general o predominante
    local backgroundWind = gDisasters.HeatSystem.BackgroundWindDirection or Vector(1, 0, 0)  -- Dirección del viento predominante
    local backgroundInfluence = 0.2  -- Coeficiente de influencia del viento de fondo (ajustable)

    -- Calcular la velocidad del viento en cada dirección usando la ecuación del gradiente de presión
    local windSpeedX = (1 / airDensity) * dPdx + backgroundWind.x * backgroundInfluence
    local windSpeedY = (1 / airDensity) * dPdy + backgroundWind.y * backgroundInfluence
    local windSpeedZ = (1 / airDensity) * dPdz + backgroundWind.z * backgroundInfluence

    -- Crear el vector final de la dirección del viento
    local windVector = Vector(windSpeedX, windSpeedY, windSpeedZ)

    -- Normalizar para obtener solo la dirección y no la magnitud, si solo necesitas la dirección
    windVector:Normalize()

    Cell.winddirection = windVector

    return Cell.winddirection
end

gDisasters.HeatSystem.CalculateAirflow = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end  -- Si la celda no existe, retornar 0

    local windSpeed = Cell.windspeed or 0
    local temperature = Cell.temperature or 23
    local pressure = Cell.pressure or 101325
    local area = gDisasters.HeatSystem.cellArea or 1  -- Área de la celda, en m²

    -- Calcular la densidad del aire en la celda actual
    local airDensity = Cell.airdensity

    -- Ajustar el flujo en función de las diferencias de presión y temperatura con celdas vecinas
    local deltaPressure = 0
    local deltaTemperature = 0
    local neighborCount = 0

    -- Iterar sobre las celdas vecinas en una cuadrícula 3D
    for dx = -1, 1 do
        for dy = -1, 1 do
            for dz = -1, 1 do
                if dx ~= 0 or dy ~= 0 or dz ~= 0 then
                    local nx, ny, nz = x + dx * gDisasters.HeatSystem.cellSize, y + dy * gDisasters.HeatSystem.cellSize, z + dz * gDisasters.HeatSystem.cellSize
                    if gDisasters.HeatSystem.GridMap[nx] and gDisasters.HeatSystem.GridMap[nx][ny] and gDisasters.HeatSystem.GridMap[nx][ny][nz] then
                        local neighborCell = gDisasters.HeatSystem.GridMap[nx][ny][nz]
                        if neighborCell then
                            deltaPressure = deltaPressure + ((neighborCell.pressure or 101325) - pressure)
                            deltaTemperature = deltaTemperature + ((neighborCell.temperature or 23) - temperature)
                            neighborCount = neighborCount + 1
                        end
                    end
                end
            end
        end
    end

    -- Promediar las diferencias de presión y temperatura
    if neighborCount > 0 then
        deltaPressure = deltaPressure / neighborCount
        deltaTemperature = deltaTemperature / neighborCount
    end

    -- Aplicar un ajuste de flujo de aire basado en las diferencias de presión y temperatura
    local pressureInfluence = deltaPressure * 0.1  -- Coeficiente para el impacto de presión en el flujo
    local temperatureInfluence = deltaTemperature * 0.05  -- Coeficiente para el impacto de temperatura en el flujo

    -- Calcular el flujo de aire base usando la velocidad del viento y el área de la celda
    local baseAirflow = windSpeed * area * airDensity

    -- Incorporar las influencias de presión y temperatura en el flujo de aire
    local airflow = baseAirflow + pressureInfluence + temperatureInfluence
    
    Cell.airflow = math.Clamp(airflow, gDisasters.HeatSystem.minwind, gDisasters.HeatSystem.maxwind)
    -- Limitar el flujo de aire a un mínimo de 0
    return Cell.airflow
end

gDisasters.HeatSystem.GetCellType = function(x, y, z)
    local MapBounds = getMapBounds()
    local max, min, floor = MapBounds[1], MapBounds[2], MapBounds[3]
    local minX, minY, maxZ = math.floor(min.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.floor(min.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize,  math.ceil(min.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize
    local maxX, maxY, minZ = math.ceil(max.x / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize, math.ceil(max.y / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize,  math.floor(max.z / gDisasters.HeatSystem.cellSize) * gDisasters.HeatSystem.cellSize

    -- Verificar si las coordenadas están dentro de los límites del mapa
    if x < minX or x >= maxX or y < minY or y >= maxY or z < minZ or z >= maxZ then
        return "out_of_bounds" -- Devolver un tipo especial para coordenadas fuera de los límites del mapa
    end
    
    local cellSize = gDisasters.HeatSystem.cellSize
    local traceStart = Vector(x, y, z)
    -- Limitar la posición final del rayo dentro de los límites de la celda
    local traceEnd = traceStart - Vector(0, 0, cellSize) -- Asegurarse de que el rayo no salga de la celda
    -- Aumentar la distancia del trace para cubrir más terreno pero limitado al tamaño de la celda
    traceEnd = traceStart + Vector(0, 0, -cellSize)
    -- Comprobar colisión con agua
    local trWater = util.TraceLine({
        start = traceStart,
        endpos = traceEnd,
        mask = MASK_WATER, -- Solo colisionar con agua
        filter = function(ent) return ent:IsValid() end  -- Filtrar cualquier entidad válida
    })

    if trWater.Hit then
        return "Water"
    end

    -- Comprobar colisión con otros tipos de terreno
    local trLand = util.TraceLine({
        start = traceStart,
        endpos = traceEnd,
        mask = MASK_SOLID_BRUSHONLY, -- Colisionar solo con el terreno sólido
        filter = function(ent) return ent:IsValid() end -- Filtrar cualquier entidad válida
    })

    if trLand.Hit then
        if trLand.MatType == MAT_GRASS then
            return "Grass"
        elseif trLand.MatType == MAT_SNOW then
            return "Snow"
        elseif trLand.MatType == MAT_SAND then
            return "Sand"
        elseif trLand.MatType == MAT_CONCRETE then
            return "Asfalt"
        else
            return "Land" -- Cualquier otro material sólido se clasifica como "Land"
        end
    end

    -- Si no detecta colisiones con agua ni tierra, se considera "Air"
    return "Air"
end


gDisasters.HeatSystem.CreateSnow = function(x, y, z) 
    if CLIENT then return end -- No ejecutar en el cliente (solo en el servidor)
    if #ents.FindByClass("env_spritetrail") > gDisasters.HeatSystem.MaxRainDrop then return end
    
    local pos = Vector(x, y, z)
    local snowFlake = ents.Create("prop_physics")
    if not IsValid(snowFlake) then return end

    snowFlake:SetModel("models/props_junk/PopCan01a.mdl") -- Any small model will work
    snowFlake:SetPos(pos)
    snowFlake:SetColor(Color(255, 255, 255, 0)) -- Invisible model
    snowFlake:SetNoDraw(true) -- Don't draw the model
    snowFlake:Spawn()

    table.insert(gDisasters.HeatSystem.Snow, snowFlake)

    util.SpriteTrail(snowFlake, 0, Color(255, 255, 255), false, 1, 0, 3, 1 / (1 + 0) * 0.5, "effects/snowflake")

    timer.Simple(3, function() -- Remove the snowFlake after 3 seconds
        if IsValid(snowFlake) then snowFlake:Remove() end
    end)
end

-- Función para crear partículas de lluvia
gDisasters.HeatSystem.CreateRain = function(x, y, z)
    if CLIENT then return end  
    if #ents.FindByClass("env_spritetrail") > gDisasters.HeatSystem.MaxRainDrop then return end

    local pos = Vector(x, y, z)
    local rainDrop = ents.Create("prop_physics")
    if not IsValid(rainDrop) then return end

    rainDrop:SetModel("models/props_junk/PopCan01a.mdl") -- Any small model will work
    rainDrop:SetPos(pos)
    rainDrop:SetColor(Color(0, 0, 255, 0)) -- Invisible model
    rainDrop:SetNoDraw(true) -- Don't draw the model
    rainDrop:Spawn()

    table.insert(gDisasters.HeatSystem.Rain, rainDrop)

    util.SpriteTrail(rainDrop, 0, Color(0, 0, 255), false, 2, 0, 2, 1 / (2 + 0) * 0.5, "effects/blood_core")

    timer.Simple(2, function() -- Remove the rainDrop after 2 seconds
        if IsValid(rainDrop) then rainDrop:Remove() end
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
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    local humidity = Cell.humidity or 25

    if humidity > gDisasters.HeatSystem.humidityThreshold then
        Cell.cloudDensity = (humidity - gDisasters.HeatSystem.humidityThreshold) * gDisasters.HeatSystem.CloudDensityCoefficient
        return Cell.cloudDensity
    else
        Cell.cloudDensity = 0
        return Cell.cloudDensity
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

    table.insert(gDisasters.HeatSystem.Clouds, cloud)

    timer.Simple(cloud.Life, function()
        if IsValid(cloud) then cloud:Remove() end
    end)

    return cloud
    
end

-- Función para simular la formación y movimiento de nubes
gDisasters.HeatSystem.CreateCloud = function(x,y,z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end
    
    -- Generate clouds in cells with low humidity and temperature
    gDisasters.HeatSystem.AdjustCloudBaseHeight(x, y, z)
    
    local baseHeight = Cell.baseHeight or z
    local pos = Vector(x, y, baseHeight)
    local color = Color(255,255,255)
    
    gDisasters.HeatSystem.SpawnCloud(pos, color)
    
end

-- Función para simular la formación y movimiento de nubes
gDisasters.HeatSystem.CreateStorm = function(x,y,z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end

    gDisasters.HeatSystem.AdjustCloudBaseHeight(x, y, z)

    -- Generate clouds in cells with low humidity and temperature
    local baseHeight = Cell.baseHeight or z
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

-- Función para calcular la distancia entre dos puntos
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

-- Función para calcular el tipo de terreno más cercano
gDisasters.HeatSystem.CalculateSources = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return "Air" end  -- Valor predeterminado si la celda no existe
    
    print("Calculando tipo de terreno para la celda...")

    -- Añadir todas las fuentes pertinentes (si es necesario)
    gDisasters.HeatSystem.AddLandSources(x, y, z)
    gDisasters.HeatSystem.AddWaterSources(x, y, z)
    gDisasters.HeatSystem.AddAirSources(x, y, z)

    -- Obtener las distancias más cercanas a cada tipo de fuente
    local closestWaterDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.WaterSources) or math.huge
    local closestLandDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.LandSources) or math.huge
    local closestSandDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.SandSources) or math.huge
    local closestGrassDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.GrassSources) or math.huge
    local closestSnowDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.SnowSources) or math.huge
    local closestAsfaltDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.AsfaltSources) or math.huge
    local closestAirDist = gDisasters.HeatSystem.GetClosestDistance(x, y, z, gDisasters.HeatSystem.AirSources) or math.huge

    -- Tabla de distancias con prioridades para cada tipo de fuente
    local distances = {
        {type = "Water", distance = closestWaterDist, priority = 6},
        {type = "Sand", distance = closestSandDist, priority = 3},
        {type = "Grass", distance = closestGrassDist, priority = 2},
        {type = "Snow", distance = closestSnowDist, priority = 5},
        {type = "Asfalt", distance = closestAsfaltDist, priority = 1},
        {type = "Land", distance = closestLandDist, priority = 4},
        {type = "Air", distance = closestAirDist, priority = 7},  -- Última prioridad (si no hay nada cercano)
    }

    -- Buscar el tipo de terreno más cercano con la menor distancia y prioridad
    local closestType = "Air"  -- Valor predeterminado
    local minDistance = math.huge
    local highestPriority = 7

    for _, entry in ipairs(distances) do
        if entry.distance and entry.distance < minDistance and entry.priority <= highestPriority then
            minDistance = entry.distance
            closestType = entry.type
            highestPriority = entry.priority
        end
    end

    print(string.format("Tipo de terreno más cercano: %s con distancia: %.2f", closestType, minDistance))
    Cell.terrainType = closestType
    return Cell.terrainType
end

-- Función para obtener las coordenadas de las fuentes de agua
gDisasters.HeatSystem.AddWaterSources = function(x,y,z)
    local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
    if celltype == "Water" then
        table.insert(gDisasters.HeatSystem.WaterSources, {x = x, y = y , z = z})
    end
end

-- Función para obtener las coordenadas de las fuentes de tierra
gDisasters.HeatSystem.AddLandSources = function(x,y,z)
    local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
    if celltype == "Sand" then
        table.insert(gDisasters.HeatSystem.SandSources, {x = x, y = y , z = z})
    elseif celltype == "Grass" then
        table.insert(gDisasters.HeatSystem.GrassSources, {x = x, y = y , z = z})
    elseif celltype == "Snow" then
        table.insert(gDisasters.HeatSystem.SnowSources, {x = x, y = y , z = z})
    elseif celltype == "Asfalt" then
        table.insert(gDisasters.HeatSystem.AsfaltSources, {x = x, y = y , z = z})
    elseif celltype == "Land" then
        table.insert(gDisasters.HeatSystem.LandSources, {x = x, y = y , z = z})
    end
end

-- Función para obtener las coordenadas de las fuentes de aire
gDisasters.HeatSystem.AddAirSources = function(x,y,z)
    local celltype = gDisasters.HeatSystem.GetCellType(x, y, z)
    if celltype == "Air" then
        table.insert(gDisasters.HeatSystem.AirSources, {x = x, y = y , z = z})
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
                nubegrid.pressure = (nubegrid.pressure or 10000) + pressureChange


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

    table.insert(gDisasters.HeatSystem.Hail, hail)

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
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end

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
    Cell.cloudDensity = math.Clamp(Cell.cloudDensity + (averageCloudDensity * gDisasters.HeatSystem.ConvergenceCoefficient), 0, 1)
end

gDisasters.HeatSystem.SpawnWeatherEntity = function(precipitationType, x, y, z)
    if CLIENT then return end

    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    
    local entityName = ""
    if precipitationType == "Raining" then
        entityName = "gd_heatsys_raincell"
    elseif precipitationType == "Storming" then
        entityName = "gd_heatsys_thundercell"
    elseif precipitationType == "Hailing" then
        entityName = "gd_heatsys_hailcell"
    elseif precipitationType == "Snowing" then
        entityName = "gd_heatsys_snowcell"
    else
        return
    end

    local precipitationEntity = ents.Create(entityName)
    if not IsValid(precipitationEntity) then return end

    precipitationEntity:SetPos(Vector(x, y, z))
    precipitationEntity:Spawn()
    precipitationEntity:SetNoDraw(true) -- Make the entity invisible
    precipitationEntity:SetCollisionGroup(COLLISION_GROUP_WORLD) -- Disable collision

    -- Store the entity in the grid map for later reference
    gDisasters.HeatSystem.GridMap[x][y][z][precipitationType .. "Entity"] = precipitationEntity
end

-- Function to remove weather entities
gDisasters.HeatSystem.RemoveWeatherEntity = function(precipitationType, x, y, z)
    if CLIENT then return end
    local precipitationEntity = gDisasters.HeatSystem.GridMap[x][y][z][precipitationType .. "Entity"]
    if IsValid(precipitationEntity) then
        precipitationEntity:Remove()
        gDisasters.HeatSystem.GridMap[x][y][z][precipitationType .. "Entity"] = nil
    end
end


gDisasters.HeatSystem.UpdateWeatherInCell = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end

    -- Remove old weather entity if it exists
    if Cell.precipitation and Cell.precipitation ~= "clear" then
        gDisasters.HeatSystem.RemoveWeatherEntity(Cell.precipitation, x, y, z)
    end
    
    -- Spawn new weather entity if necessary
    if Cell.precipitation ~= "clear" then
        gDisasters.HeatSystem.SpawnWeatherEntity(Cell.precipitation, x, y, z)
    end

end

gDisasters.HeatSystem.CalculateMass = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return 0 end -- Verificar que la celda exista
    -- Calcular densidad del aire en la celda
    local airDensity = Cell.airdensity

    -- Calcular volumen de la celda
    local cellVolume = gDisasters.HeatSystem.cellVolumen

    -- Calcular masa
    local mass = airDensity * cellVolume
    
    Cell.mass = mass
    
    return Cell.mass
end

gDisasters.HeatSystem.CalculateAlbedo = function(x, y, z)
    local Cell = gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z]
    if not Cell then return end -- Verifica si la celda existe
    
    -- Asignar el albedo según el tipo de terreno de la celda
    local terrainType = Cell.terrainType

    if terrainType == "Snow" then
        Cell.albedo = 0.85
        return Cell.albedo    -- Albedo para asfalto
    elseif terrainType == "Sand" then
        Cell.albedo = 0.4
        return Cell.albedo    -- Albedo para asfalto       
    elseif terrainType == "Water" then
        Cell.albedo = 0.08
        return Cell.albedo    -- Albedo para asfalto       
    elseif terrainType == "Grass" then
        Cell.albedo = 0.15
        return Cell.albedo    -- Albedo para asfalto
    elseif terrainType == "Asfalt" then
        Cell.albedo = 0.1
        return Cell.albedo    -- Albedo para asfalto
    else
        Cell.albedo = 0.3
        return Cell.albedo    -- Valor por defecto si no se especifica el tipo de terreno
    end
end

-- Función para generar la cuadrícula y actualizar la temperatura en cada ciclo
gDisasters.HeatSystem.GenerateGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then

        if file.Exists( "gDisasters/grid_" .. game.GetMap() .. ".json", "DATA" ) and file.Size("gDisasters/grid_" .. game.GetMap() .. ".json", "DATA") > 2 and file.Exists( "gDisasters/cellsize_" .. game.GetMap() .. ".txt", "DATA" ) and file.Size("gDisasters/cellsize_" .. game.GetMap() .. ".txt", "DATA") > 0 and file.Exists( "gDisasters/clouds_" .. game.GetMap() .. ".json", "DATA" ) and file.Size("gDisasters/clouds_" .. game.GetMap() .. ".json", "DATA") > 0 and file.Exists( "gDisasters/rain_" .. game.GetMap() .. ".json", "DATA" ) and file.Size("gDisasters/rain_" .. game.GetMap() .. ".json", "DATA") > 0 and file.Exists( "gDisasters/snow_" .. game.GetMap() .. ".json", "DATA" ) and file.Size("gDisasters/snow_" .. game.GetMap() .. ".json", "DATA") > 0 and file.Exists( "gDisasters/hail_" .. game.GetMap() .. ".json", "DATA" ) and file.Size("gDisasters/hail_" .. game.GetMap() .. ".json", "DATA") > 0 then
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
                        gDisasters.HeatSystem.CalculateSources(x, y, z)
                        -- Calcular la influencia de terreno
                        gDisasters.HeatSystem.CalculateTerrainInfluence(x, y, z)

                        gDisasters.HeatSystem.CalculateAlbedo(x, y, z)

                        -- Calcular la temperatura y la humedad de la celda actual 
                        gDisasters.HeatSystem.CalculateTemperature(x,y,z)
                        gDisasters.HeatSystem.CalculateHumidity(x,y,z)
                        gDisasters.HeatSystem.CalculatePressure(x,y,z)
                        gDisasters.HeatSystem.Calculatetemperaturebh(x, y, z)
                        
                        gDisasters.HeatSystem.CalculateAirDensity(x, y, z)
                        gDisasters.HeatSystem.CalculateMass(x, y, z)
                        gDisasters.HeatSystem.CalculateThermalInertia(x, y, z)
                        gDisasters.HeatSystem.CalculateEmissivity(x,y,z)

                        -- Calcular la velocidad de aire
                        gDisasters.HeatSystem.CalculateWindSpeed(x,y,z)
                        gDisasters.HeatSystem.CalculateWindDirection(x,y,z)
                        
                        -- Calcular el flujo de aire
                        gDisasters.HeatSystem.CalculateAirflow(x, y, z)

                        --Calcular el Punto de Rocio
                        gDisasters.HeatSystem.CalculateDewPoint(x, y, z)

                        -- Calcular la latencia
                        gDisasters.HeatSystem.CalculatelatentHeat(x, y, z)
                        
                        -- Calcular el indice de calor 
                        gDisasters.HeatSystem.CalculateHeatIndex(x, y, z)
                        gDisasters.HeatSystem.CalculateWindChill(x, y, z)
                        
                        gDisasters.HeatSystem.CalculatePrecipitation(x, y, z)

                        -- Calcular la presión de vapor
                        gDisasters.HeatSystem.CalculateVPs(x, y, z)
                        gDisasters.HeatSystem.CalculateVPsHb(x, y, z)
                        gDisasters.HeatSystem.CalculateVaporPressure(x, y, z)
                        
                        -- Calcular la densidad de nubes
                        gDisasters.HeatSystem.CalculateCloudDensity(x,y,z)

                        print("Grid generated in position (" .. x .. "," .. y .. "," .. z .. ")") -- Depuración
                    end
                end
            end

            print("Grid generated.") -- Depuración
          
            gDisasters.HeatSystem.SaveGrid()

            
        
        end


    end

end

gDisasters.HeatSystem.SaveGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        print("Saving grid...")
        
        if not file.IsDir("gDisasters", "DATA") then
            file.CreateDir("gDisasters")
        end

        file.Write("gDisasters/grid_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.GridMap, true))
        file.Write("gDisasters/landsource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.LandSources, true))
        file.Write("gDisasters/watersource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.WaterSources, true))
        file.Write("gDisasters/airsource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.AirSources, true))
        file.Write("gDisasters/sandsource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.GrassSources, true))
        file.Write("gDisasters/grasssource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.SandSources, true))
        file.Write("gDisasters/snowsource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.SnowSources, true))
        file.Write("gDisasters/asfaltsource_" .. game.GetMap() .. ".json", util.TableToJSON(gDisasters.HeatSystem.AsfaltSources, true))
        file.Write("gDisasters/cellsize_" .. game.GetMap() .. ".txt", tostring(gDisasters.HeatSystem.cellSize))
        file.Write("gDisasters/clouds_" .. game.GetMap() .. ".json",  util.TableToJSON(gDisasters.HeatSystem.Clouds, true))
        file.Write("gDisasters/rain_" .. game.GetMap() .. ".json",  util.TableToJSON(gDisasters.HeatSystem.Rain, true))
        file.Write("gDisasters/snow_" .. game.GetMap() .. ".json",  util.TableToJSON(gDisasters.HeatSystem.Snow, true))
        file.Write("gDisasters/hail_" .. game.GetMap() .. ".json",  util.TableToJSON(gDisasters.HeatSystem.Hail, true))
        print("Grid saved.")
    end
end

gDisasters.HeatSystem.LoadGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        print("Saving grid...")
        gDisasters.HeatSystem.GridMap = util.JSONToTable(file.Read("gDisasters/grid_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/grid_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.LandSources = util.JSONToTable(file.Read("gDisasters/landsource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/landsource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.WaterSources = util.JSONToTable(file.Read("gDisasters/watersource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/watersource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.AirSources = util.JSONToTable(file.Read("gDisasters/airsource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/airsource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.SandSources = util.JSONToTable(file.Read("gDisasters/sandsource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/sandsource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.SnowSources = util.JSONToTable(file.Read("gDisasters/snowsource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/snowsource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.AsfaltSources = util.JSONToTable(file.Read("gDisasters/asfaltsource_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/asfaltsource_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.cellSize = tonumber(file.Read("gDisasters/cellsize_" .. game.GetMap() .. ".txt", "DATA")) or file.Read("gDisasters/cellsize_" .. game.GetMap() .. ".txt", "DATA")
        gDisasters.HeatSystem.Clouds = util.JSONToTable(file.Read("gDisasters/clouds_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/clouds_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.Rain = util.JSONToTable(file.Read("gDisasters/rain_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/rain_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.Snow = util.JSONToTable(file.Read("gDisasters/snow_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/snow_" .. game.GetMap() .. ".json", "DATA")
        gDisasters.HeatSystem.Hail = util.JSONToTable(file.Read("gDisasters/hail_" .. game.GetMap() .. ".json", "DATA")) or file.Read("gDisasters/hail_" .. game.GetMap() .. ".json", "DATA")
        for k,v in pairs(gDisasters.HeatSystem.Clouds) do
            v:Spawn()
            v:Activate()
        end
        for k,v in pairs(gDisasters.HeatSystem.Rain) do
            v:Spawn()
            v:Activate()
        end
        for k,v in pairs(gDisasters.HeatSystem.Snow) do
            v:Spawn()
            v:Activate()
        end
        for k,v in pairs(gDisasters.HeatSystem.Hail) do
            v:Spawn()
            v:Activate()
        end
    end
end

gDisasters.HeatSystem.UpdateGrid = function()
    if GetConVar("gdisasters_heat_system_enabled"):GetInt() >= 1 then
        if CurTime() > gDisasters.HeatSystem.nextUpdateGrid then
            gDisasters.HeatSystem.nextUpdateGrid = CurTime() + gDisasters.HeatSystem.updateInterval

            for i= 1, gDisasters.HeatSystem.updateBatchSize do
                local Cell = table.remove(gDisasters.HeatSystem.cellsToUpdate, 1)
                if not Cell then
                    -- Reiniciar la lista de celdas para actualizar
                    gDisasters.HeatSystem.cellsToUpdate = {}
                    for x, column in pairs(gDisasters.HeatSystem.GridMap) do
                        for y, row in pairs(column) do
                            for z, Cell in pairs(row) do
                                table.insert(gDisasters.HeatSystem.cellsToUpdate, {x, y, z})
                            end
                        end
                    end
                    Cell = table.remove(gDisasters.HeatSystem.cellsToUpdate, 1)
                end

                if Cell then
                    local x, y, z = Cell[1], Cell[2], Cell[3]
                    if gDisasters.HeatSystem.GridMap[x] and gDisasters.HeatSystem.GridMap[x][y] and gDisasters.HeatSystem.GridMap[x][y][z] then
                        local Cell = gDisasters.HeatSystem.GridMap[x][y][z]
                        
                        -- Calcular la influencia de terreno
                        gDisasters.HeatSystem.CalculateTerrainInfluence(x, y, z)
                        
                        gDisasters.HeatSystem.CalculateAlbedo(x, y, z)
                        
                        -- Calcular la temperatura y la humedad de la celda actual 
                        gDisasters.HeatSystem.CalculateTemperature(x, y, z)
                        gDisasters.HeatSystem.CalculateHumidity(x, y, z)
                        gDisasters.HeatSystem.CalculatePressure(x, y, z)
                        gDisasters.HeatSystem.Calculatetemperaturebh(x, y, z)
                        
                        gDisasters.HeatSystem.CalculateAirDensity(x, y, z)
                        gDisasters.HeatSystem.CalculateMass(x, y, z)
                        gDisasters.HeatSystem.CalculateThermalInertia(x, y, z)
                        gDisasters.HeatSystem.CalculateEmissivity(x,y,z)
                        
                        -- Calcular la velocidad de aire
                        gDisasters.HeatSystem.CalculateWindSpeed(x, y, z)
                        gDisasters.HeatSystem.CalculateWindDirection(x, y, z)
                        
                        -- Calcular el flujo de aire
                        gDisasters.HeatSystem.CalculateAirflow(x, y, z)

                        -- Calcular el punto de rocio
                        gDisasters.HeatSystem.CalculateDewPoint(x, y, z)

                        -- Calcular la latencia
                        gDisasters.HeatSystem.CalculatelatentHeat(x, y, z)
                        
                        -- Calcular el indice de calor 
                        gDisasters.HeatSystem.CalculateHeatIndex(x, y, z)
                        gDisasters.HeatSystem.CalculateWindChill(x, y, z)

                        gDisasters.HeatSystem.CalculatePrecipitation(x, y, z)
                        
                        -- Calcular la presión de vapor
                        gDisasters.HeatSystem.CalculateVPs(x, y, z)
                        gDisasters.HeatSystem.CalculateVPsHb(x, y, z)
                        gDisasters.HeatSystem.CalculateVaporPressure(x, y, z)
                        
                        -- Calcular la densidad de nubes
                        gDisasters.HeatSystem.CalculateCloudDensity(x,y,z)
                        
                        gDisasters.HeatSystem.UpdateWeatherInCell(x,y,z)
                        gDisasters.HeatSystem.SimulateConvergence(x,y,z)
                    
                    else
                        print("Error: Cell position out of grid bounds.")
                    end
                end

            end
            
            gDisasters.HeatSystem.SaveGrid()
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
                    local Cell = gDisasters.HeatSystem.GridMap[px][py][pz]

                    -- Verifica si las propiedades de la celda son válidas
                    if Cell.temperature and Cell.humidity and Cell.pressure and Cell.windspeed and Cell.winddirection and Cell.terrainType and Cell.cloudDensity then
                        -- Actualiza las variables de la atmósfera del jugador
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Temperature"] = Cell.temperature
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Humidity"] = Cell.humidity
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Pressure"] = Cell.pressure
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Speed"] = Cell.windspeed
                        GLOBAL_SYSTEM_TARGET["Atmosphere"]["Wind"]["Direction"] = Cell.winddirection
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
                        local Cell = gDisasters.HeatSystem.GridMap[px][py][pz]
                        local windspeed  = Cell.windspeed
	                    local winddir    = Cell.winddirection
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
                        if Cell.windspeed and Cell.winddirection and windphysics_enabled and windspeed >= 1 and CurTime() >= GLOBAL_SYSTEM["Atmosphere"]["Wind"]["NextThink"] then
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
                for z, Cell in pairs(row) do
                    local cellPos = Vector(x, y, z) -- Posición de la celda
                    local distance = playerPos:DistToSqr(cellPos) -- Distancia al cuadrado del jugador a la celda

                    if distance <= gDisasters.HeatSystem.maxDistance * gDisasters.HeatSystem.maxDistance then -- Comparar con la distancia máxima al cuadrado
                        local temperature = Cell.temperature -- Obtener la temperatura de la celda
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
hook.Add("PlayerDisconnected", "gDisasters_PlayerDisconnectedSave", gDisasters.HeatSystem.SaveGrid)
gameevent.Listen( "player_disconnect" )
gameevent.Listen( "client_disconnect" )
hook.Add("player_disconnect", "gDisasters_PlayerDisconnectedSave2", gDisasters.HeatSystem.SaveGrid)
hook.Add("client_disconnect", "gDisasters_ClientDisconnectedSave", gDisasters.HeatSystem.SaveGrid)