AddCSLuaFile()

Buoyancy_Lookup = { ["plastic_barrel"] = 5,
					["floating_metal_barrel"] = 5,
					["metal"] = 0.2,
					["metalpanel"] = 0.2,
					["cardboard"] = 1.35,
					["wood_crate"] = 4,
					["default"] = 1.00,
					["wood"] = 5,
					}

					
if (SERVER) then

	function GetBuoyancyMod(entity)
		if entity:GetPhysicsObject():IsValid()==false then return 0.2 end
		if Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] == nil then return 0.2 end 
		
		
		return Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] 

	end


end
