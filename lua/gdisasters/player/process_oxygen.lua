if (SERVER) then

function gDisasters_ProcessOxygen()
    if GetConVar("gdisasters_oxygen_enable"):GetInt() == 0 then return end 
    for k, v in pairs(player.GetAll()) do 

        v:SetNWFloat("BodyOxygen", v.gDisasters.Body.Oxygen)
        
        if v:WaterLevel() >= 3 then 
            v.gDisasters.Body.Oxygen = math.Clamp(v.gDisasters.Body.Oxygen - engine.TickInterval(), 0,10) 

            if v.gDisasters.Body.Oxygen <= 0 then

                if GetConVar("gdisasters_oxygen_damage"):GetInt() == 0 then return end

				if math.random(1, 50)==1 then
				    local dmg = DamageInfo()
				    dmg:SetDamage( math.random(1,25) )
				    dmg:SetAttacker( v )
				    dmg:SetDamageType( DMG_DROWN  )

				    v:TakeDamageInfo(  dmg)
                end
		    end
        elseif v.IsInWater then
            v.gDisasters.Body.Oxygen = math.Clamp(v.gDisasters.Body.Oxygen - engine.TickInterval(), 0,10) 

            if v.gDisasters.Body.Oxygen <= 0 then

                if GetConVar("gdisasters_oxygen_damage"):GetInt() == 0 then return end

				if math.random(1, 50)==1 then
				    local dmg = DamageInfo()
				    dmg:SetDamage( math.random(1,25) )
				    dmg:SetAttacker( v )
				    dmg:SetDamageType( DMG_DROWN  )

				    v:TakeDamageInfo(  dmg)
                end
		    end
        else
            v.gDisasters.Body.Oxygen = math.Clamp(v.gDisasters.Body.Oxygen + 0.1, 0,10)
        end
    end
end

end