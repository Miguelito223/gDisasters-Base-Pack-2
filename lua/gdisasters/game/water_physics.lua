Buoyancy_Lookup = { 
					["plastic_barrel"] = 5,
					["floating_metal_barrel"] = 5,
					["metal"] = 0.2,
					["metalpanel"] = 0.2,
					["cardboard"] = 1.35,
					["wood_crate"] = 4,
					["default"] = 1.00,
					["default_silent"] = 1.00,
					["wood"] = 5,
					["flesh"] = 4,
					["watermelon"] = 4,
					["foliage"] = 4,
					["foliage"] = 4,
					["alienflesh"] = 4,
					["bloodyflesh"] = 4,
					["zombieflesh"] = 4,
					["armorflesh"] = 4,
					["paper"] = 5,
					["gmod_bouncy"] = 5,
					["metal_bouncy"] = 3,
					["dirt"] = 3,
					["glass"] = 4,
					["glassbottle"] = 4,
					["concrete"] = 0.2,
					["ice"] = 4,
					["gmod_ice"] = 4,
					["slime"] = 4,
					["rubber"] = 5,
					["ladder"] = 5,
					["floatingstandable"] = 4,
					["item"] = 4,
					["player"] = 4,
					["rock"] = 0.2,
					["brick"] = 0.2,
					}

					
if (SERVER) then

	function GetBuoyancyMod(entity)
		if entity:GetPhysicsObject():IsValid()==false then return 0.2 end
		if Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] == nil then return 0.2 end 
		
		
		return Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] 

	end


end
