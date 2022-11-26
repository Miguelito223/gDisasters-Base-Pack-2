Buoyancy_Lookup = { 
				
				["default"] = 4,
				["default_silent"] = 4,
				["floatingstandable"] = 4,
				["item"] = 4,
				["ladder"] = 4,
				["no_decal"] = 4,
				["player"] = 4,
				["player_control_clip"] = 4,
				
				["baserock"] = 0.2,
				["boulder"] = 0.2,
				["brick"] = 0.2,
				["concrete"] = 0.2,
				["concrete_block"] = 0.2,
				["gravel"] = 0.2,
				["rock"] = 0.2,
				
				["canister"] = 0.2,
				["chain"]= 0.2,
				["chainlink"]= 0.2,
				["combine_metal"]= 0.2,
				["crowbar"]= 0.2,
				["floating_metal_barrel"]= 0.2,
				["grenade"]= 0.2,
				["gunship"]= 0.2,
				["metal"]= 0.2,
				["metal_barrel"]= 0.2,
				["metal_bouncy"]= 0.2,
				["Metal_Box"]= 0.2,
				["metal_seafloorcar"]= 0.2,
				["metalgrate"]= 0.2,
				["metalpanel"]= 0.2,
				["metalvent"]= 0.2,
				["metalvehicle"]= 0.2,
				["paintcan"]= 0.2,
				["popcan"]= 0.2,
				["roller"]= 0.2,
				["slipperymetal"]= 0.2,
				["solidmetal"]= 0.2,
				["strider"]= 0.2,
				["weapon"]= 0.2,
				
				
				["wood"] = 5,
				["wood_box"] = 5,
				["wood_crate"] = 5,
				["wood_furniture"] = 5,
				["wood_lowdensity"] = 5,
				["wood_plank"] = 5,
				["wood_panel"] = 5,
				["wood_solid"] = 5,
				
				
				["dirt"] = 4,
				["grass"] = 4,
				["gravel"] = 0.2,
				["mud"] = 4,
				["quicksand"] = 4,
				["sand"] = 4,
				["slipperyslime"] = 4,
				["antlionsand"] = 4,
				
				["slime"] = 4,
				["water"] = 4,
				["wade"] = 4,
				["Frozen"]  = "ice",
				["ice"] = "ice",
				["snow"] = "ice",
				["Organic"] = 4,
				["alienflesh"] = 4,
				["antlion"] = 4,
				["armorflesh"] = 4,
				["bloodyflesh"] = 4,
				["flesh"] = 4,
				["foliage"] = 4,
				["watermelon"] = 4,
				["zombieflesh"] = 4,
				["Manufactured"] = 4,
				["asphalt"] = 0.2,
				["glass"] = 4,
				["glassbottle"] = 4,
				["combine_glass"] = 4,
				["tile"] = 0.2,
				["paper"] = 4,
				["papercup"] = 4,
				["cardboard"] = 4,
				["plaster"] = 4,
				["plastic_barrel"] = 4,
				["plastic_barrel_buoyant"] = 4,
				["Plastic_Box"] = 4,
				["plastic"] = 4,
				["rubber"] = 4,
				["rubbertire"] = 4,
				["slidingrubbertire"] = 4,
				["slidingrubbertire_front"] = 4,
				["slidingrubbertire_rear"] = 4,
				["jeeptire"] = 4,
				["brakingrubbertire"] = 4,
				["Miscellaneous"] = 4,
				["carpet"] = 4,
				["ceiling_tile"] = 0.2,
				["computer"] = 0.2,
				["pottery"] = 0.2

			}

					
if (SERVER) then

	function GetBuoyancyMod(entity)
		if entity:GetPhysicsObject():IsValid()==false then return 0.2 end
		if Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] == nil then return 0.2 end 
		
		
		return Buoyancy_Lookup[entity:GetPhysicsObject():GetMaterial()] 

	end


end
