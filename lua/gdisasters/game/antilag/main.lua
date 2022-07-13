
gDisasters.Game.AntiLag = {}

gDisasters.Game.AntiLag.Collisions = {}
gDisasters.Game.AntiLag.Collisions.PropPhysicsHash  = {}
gDisasters.Game.AntiLag.Collisions.PerSecond        = 0 
gDisasters.Game.AntiLag.Collisions.PerSecondPerProp = 0 

gDisasters.Game.AntiLag.NextThink = CurTime() 
gDisasters.Game.AntiLag.NumberOfProps               = 0 

gDisasters.Game.AntiLag.Collisions.PropEntryExists = function(prop)
	return gDisasters.Game.AntiLag.Collisions.PropPhysicsHash[prop]
end

gDisasters.Game.AntiLag.Collisions.AddPropEntry = function(prop)
	gDisasters.Game.AntiLag.Collisions.PropPhysicsHash[prop] = {Exists = true, Collisions = 0}
end

gDisasters.Game.AntiLag.Collisions.RemovePropEntry = function(prop)
	gDisasters.Game.AntiLag.Collisions.PropPhysicsHash[prop] = nil
end

gDisasters.Game.AntiLag.Collisions.GetNProps = function()
	return gDisasters.Game.AntiLag.NumberOfProps
end

gDisasters.Game.AntiLag.Collisions.GetPerSecond = function()
	return gDisasters.Game.AntiLag.Collisions.PerSecond
end

gDisasters.Game.AntiLag.Collisions.GetPerSecondPerProp = function()
	return gDisasters.Game.AntiLag.Collisions.PerSecondPerProp
end

gDisasters.Game.AntiLag.Collisions.PostPerPropCollisions = function(prop, collisions)
	if prop:IsValid() then 

	--if gDisasters.Game.AntiLag.Collisions.PerSecond > 0 then print(gDisasters.Game.AntiLag.NumberOfProps /  gDisasters.Game.AntiLag.Collisions.PerSecond  ) end 


	if collisions >= GetConVar("gdisasters_antilag_maximum_safe_collisions_per_second_per_prop"):GetInt() then 

		prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		gDisasters.Game.AntiLag.Collisions.RemovePropEntry(prop)
	end
	
	end
end


--
gDisasters.Game.AntiLag.Collisions.AppendNumberOfCollisions = function(number)
	gDisasters.Game.AntiLag.Collisions.PerSecond = gDisasters.Game.AntiLag.Collisions.PerSecond + number
end


--

gDisasters.Game.AntiLag.CollisionsLoop = function()

	
	
	local count = 0 
	for k, prop in pairs(ents.FindByClass("prop_physics")) do 
		if !gDisasters.Game.AntiLag.Collisions.PropEntryExists(prop) and (prop:GetCollisionGroup()==0) then
			gDisasters.Game.AntiLag.Collisions.AddPropEntry(prop)
			if not(prop.gDCallBackFunction) then 
				prop.gDCallBackFunction = true 
				prop:AddCallback( "PhysicsCollide", function(ent, data) 
					if gDisasters.Game.AntiLag.Collisions.PropEntryExists(ent) and (ent:GetCollisionGroup()==0) then
					
						gDisasters.Game.AntiLag.Collisions.PropPhysicsHash[ent].Collisions = gDisasters.Game.AntiLag.Collisions.PropPhysicsHash[ent].Collisions + 1 + ((10 - math.Clamp(data.DeltaTime,0,10))*0.5)  
					end
				end)
			end
		end
		count = count + 1 
	end
	if count < 0 then return end 
	

	
	for k, v in pairs(gDisasters.Game.AntiLag.Collisions.PropPhysicsHash) do 
		gDisasters.Game.AntiLag.Collisions.AppendNumberOfCollisions(v.Collisions)
	
		gDisasters.Game.AntiLag.Collisions.PostPerPropCollisions(k, v.Collisions)
		v.Collisions = 0 
	end
	
	gDisasters.Game.AntiLag.NumberOfProps = count 	
	--gDisasters.Game.AntiLag.Collisions.PerSecond = 
	gDisasters.Game.AntiLag.Collisions.PerSecondPerProp = gDisasters.Game.AntiLag.Collisions.PerSecond / count 
	
end

gDisasters.Game.AntiLag.MainLoop  = function()
	if CurTime() < gDisasters.Game.AntiLag.NextThink then return end 
	
	gDisasters.Game.AntiLag.Collisions.PerSecond = 0 
	gDisasters.Game.AntiLag.Collisions.PerSecondPerProp = 0  
	
	gDisasters.Game.AntiLag.NextThink = CurTime() + 1 
	gDisasters.Game.AntiLag.CollisionsLoop()	
end
hook.Remove("Think", "gDisasters.Game.AntiLag.MainLoop", gDisasters.Game.AntiLag.MainLoop)













