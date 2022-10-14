if (SERVER) then

function gDisasters_ProcessOxygen()
    for k, v in pairs(player.GetAll()) do
        
        v.gDisasters.Body.Oxygen = math.Clamp(v.gDisasters.Body.Oxygen - 0.01, 0,10) 

        v:SetNWFloat("BodyOxygen", v.gDisasters.Body.Oxygen)
        
        if v:WaterLevel() > 0 then  
            if v.gDisasters.Body.Oxygen == nil then v.gDisasters.Body.Oxygen = 10 end        

            if v.gDisasters.Body.Oxygen <= 0 then

				if math.random(1, 50)==1 then
				    local dmg = DamageInfo()
				    dmg:SetDamage( math.random(1,25) )
				    dmg:SetAttacker( v )
				    dmg:SetDamageType( DMG_DROWN  )

				    v:TakeDamageInfo(  dmg)
                end
		    end
        elseif v:WaterLevel() == 0 then
            v.gDisasters.Body.Oxygen = math.Clamp(v.gDisasters.Body.Oxygen + 0.1, 0,10)
        end
    end
end

end