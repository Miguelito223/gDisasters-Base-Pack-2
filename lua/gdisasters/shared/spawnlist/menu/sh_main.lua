search.AddProvider(
	function(str)
		local results = {}
		local entities = {}

		local function searchList(lname, lctype)
			for k, v in pairs(list.Get(lname)) do
				v.ClassName = k
				v.PrintName = v.PrintName or v.Name
				v.ScriptedEntityType = lctype
				table.insert(entities, v)
			end
		end
		searchList("gDisasters_Weapons", "weapon")
		searchList("gDisasters_Disasters", "entity")
		searchList("gDisasters_Weather", "entity")
		searchList("gDisasters_Buildings", "entity")
		searchList("gDisasters_Equipment", "entity")
		searchList("gDisasters_NPCs", "npc")
		searchList("gDisasters_Misc", "entity")

		// searchList("VJBASE_SPAWNABLE_VEHICLES", "vehicle") -- vehicle (Not yet lol)
		for _, v in pairs(entities) do
			local name = v.PrintName
			local name_c = v.ClassName
			if (!name && !name_c) then continue end

			if ((name && name:lower():find(str, nil, true)) or (name_c && name_c:lower():find(str, nil, true))) then
				local entry = {
					text = v.PrintName or v.ClassName,
					icon = spawnmenu.CreateContentIcon(v.ScriptedEntityType or "entity", nil, {
						nicename = v.PrintName or v.ClassName,
						spawnname = v.ClassName,
						material = "entities/" .. v.ClassName .. ".png",
						admin = v.AdminOnly or false
					}),
					words = {v}
				}
				table.insert(results, entry)
			end
		end
		table.SortByMember(results, "text", true)
		return results
	end, "gDisastersSearch"

)

spawnmenu.AddCreationTab("gDisasters Revived", function()

	local ctrl = vgui.Create("SpawnmenuContentPanel")
	ctrl:EnableSearch("gDisastersSearch","PopulategDisasters_Disasters")
	ctrl:CallPopulateHook("PopulategDisasters_Disasters")
	ctrl:CallPopulateHook("PopulategDisasters_Weather")
	ctrl:CallPopulateHook("PopulategDisasters_Buildings")
	ctrl:CallPopulateHook("PopulategDisasters_Weapons")
	ctrl:CallPopulateHook("PopulategDisasters_Equipment")
	ctrl:CallPopulateHook("PopulategDisasters_NPCs")
	ctrl:CallPopulateHook("PopulategDisasters_Misc")
	return ctrl
	end,
	"icons/gdlogo.png", 30
)


function AddToGDSpawnMenu(name, class, category, subcategory, adminonly)

	-- available parent categories 
	-- Disasters, Weather, Weapons, Buildings, Misc
	if category == "Disasters" then 
		list.Set( "gDisasters_Disasters", class, {
			Name = name, 
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly, 
			Offset = 0
		})
	elseif category == "Weather" then 
		list.Set( "gDisasters_Weather", class, {
			Name = name,
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly, 
			Offset = 0
		})
	elseif category == "Weapons" then 
		list.Set( "Weapon", class, {
			Name = name,
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly, 
			Spawnable = true
		})
		list.Set( "gDisasters_Weapons", class, {
			Name = name,
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly,
			Spawnable = true
		})
	elseif category == "Buildings" then
		list.Set( "gDisasters_Buildings", class, {
			Name = name, 
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly, 
		})
	elseif category == "Equipment" then
		list.Set( "gDisasters_Equipment", class, {
			Name = name, 
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly,
			Offset = 0
		})
	elseif category == "NPCs" then
		if subcategory == "Nextbot" then
			list.Set( "NPC", class, {
				Name = name, 
				Class = class, 
				Category = subcategory,
				AdminOnly = adminonly
			})	
			list.Set( "gDisasters_NPCs", class, {
				Name = name, 
				Class = class, 
				Category = subcategory, 
				AdminOnly = adminonly
			})
		else
			list.Set( "gDisasters_NPCs", class, {
				Name = name, 
				Class = class, 
				Category = subcategory, 
				AdminOnly = adminonly,
				Health = "100",
				Weapons = {"none"}
			})
			list.Set( "NPC", class, {
				Name = name, 
				Class = class, 
				Category = subcategory,
				AdminOnly = adminonly,
				Health = "100",
				Weapons = {"none"}
			})
		end
	elseif category == "Misc" then
		list.Set( "gDisasters_Misc", class, {
			Name = name, 
			Class = class, 
			Category = subcategory, 
			AdminOnly = adminonly,
			Offset = 0
		})
	end

end

hook.Add( "PopulategDisasters_Weapons", "AddWeaponsContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Weapons & Ammo", "icons/weapons.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local WeaponsCategories = {}
	local SpawnableWeaponsList = list.Get("gDisasters_Weapons")
	if (SpawnableWeaponsList) then
		for k, v in pairs(SpawnableWeaponsList) do

			WeaponsCategories[v.Category] = WeaponsCategories[v.Category] or {}
			table.insert(WeaponsCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(WeaponsCategories) do
	
		local node = dtree:AddNode(CategoryName, "icons/weapons.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, swep in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "weapon", self.PropPanel, 
				{ 
					nicename	= swep.PrintName or swep.Name,
					spawnname	= swep.Class,
					material	= "entities/"..swep.Class..".png",
					admin		= swep.AdminOnly or false
				})
				
			end

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )


hook.Add( "PopulategDisasters_Equipment", "AddEquipmentContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Equipment", "icons/equipment.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local EquipmentCategories = {}
	local SpawnableEquipmentList = list.Get("gDisasters_Equipment")
	if (SpawnableEquipmentList) then
		for k, v in pairs(SpawnableEquipmentList) do
			EquipmentCategories[v.Category] = EquipmentCategories[v.Category] or {}
			table.insert(EquipmentCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(EquipmentCategories) do
	
		local node = dtree:AddNode(CategoryName, "icons/equipment.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.Name,
					spawnname	= ent.Class,
					material	= "entities/"..ent.Class..".png",
					admin		= ent.AdminOnly or false
				})
				
			end

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )
hook.Add( "PopulategDisasters_Disasters", "AddDisastersContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Disasters", "icons/disasters.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local DisastersCategories = {}
	local SpawnableDisastersList = list.Get("gDisasters_Disasters")
	if (SpawnableDisastersList) then
		for k, v in pairs(SpawnableDisastersList) do
			DisastersCategories[v.Category] = DisastersCategories[v.Category] or {}
			table.insert(DisastersCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(DisastersCategories) do
	
		local node = dtree:AddNode(CategoryName, "icons/disasters.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.Name,
					spawnname	= ent.Class,
					material	= "entities/"..ent.Class..".png",
					admin		= ent.AdminOnly or false
				})
				
			end

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )


hook.Add( "PopulategDisasters_Buildings", "AddBuildingsContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Buildings", "icons/buildings.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local BuildingsCategories = {}
	local SpawnableBuildingsList = list.Get("gDisasters_Buildings")
	if (SpawnableBuildingsList) then
		for k, v in pairs(SpawnableBuildingsList) do
			BuildingsCategories[v.Category] = BuildingsCategories[v.Category] or {}
			table.insert(BuildingsCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(BuildingsCategories) do
	
		local node = dtree:AddNode(CategoryName, "icons/buildings.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.Name,
					spawnname	= ent.Class,
					material	= "entities/"..ent.Class..".png",
					admin		= ent.AdminOnly or false
				})
				
			end

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )

hook.Add( "PopulategDisasters_Weather", "AddWeatherContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Weather", "icons/weather.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local WeatherCategories = {}
	local SpawnableWeatherList = list.Get("gDisasters_Weather")
	if (SpawnableWeatherList) then
		for k, v in pairs(SpawnableWeatherList) do

			WeatherCategories[v.Category] = WeatherCategories[v.Category] or {}
			table.insert(WeatherCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(WeatherCategories) do
	
		local node = dtree:AddNode(CategoryName, "icons/weather.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.Name,
					spawnname	= ent.Class,
					material	= "entities/"..ent.Class..".png",
					admin		= ent.AdminOnly or false
				})
				
			end

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )

hook.Add( "PopulategDisasters_NPCs", "AddNPCsContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("NPCs", "icon16/monkey.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local MiscCategories = {}
	local SpawnableMiscList = list.Get("gDisasters_NPCs")

	if (SpawnableMiscList) then
		for k, v in pairs(SpawnableMiscList) do
			MiscCategories[v.Category] = MiscCategories[v.Category] or {}
			table.insert(MiscCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(MiscCategories) do
	
		local node = dtree:AddNode(CategoryName, "icon16/monkey.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			if CategoryName == "Nextbot" then
				for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
					spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
					{ 
						nicename	= ent.PrintName or ent.Name,
						spawnname	= ent.Class,
						material	= "entities/"..ent.Class..".png",
						admin		= ent.AdminOnly or false
					})
				end
			else
				for name, npc in SortedPairsByMemberValue( v, "PrintName" ) do
					spawnmenu.CreateContentIcon( "npc", self.PropPanel, 
					{ 
						nicename	= npc.PrintName or npc.Name,
						spawnname	= npc.Class,
						material	= "entities/"..npc.Class..".png",
						weapon		= npc.Weapons,
						admin		= npc.AdminOnly or false
					})
				end
			end
		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )

hook.Add( "PopulategDisasters_Misc", "AddMiscContent", function( pnlContent, tree, node )

	local dtree = tree:AddNode("Misc", "icon16/monkey.png")
	dtree.PropPanel = vgui.Create("ContentContainer", pnlContent)
	dtree.PropPanel:SetVisible(false)
	dtree.PropPanel:SetTriggerSpawnlistChange(false)

	function dtree:DoClick()
		pnlContent:SwitchPanel(self.PropPanel)
	end

	local MiscCategories = {}
	local SpawnableMiscList = list.Get("gDisasters_Misc")

	if (SpawnableMiscList) then
		for k, v in pairs(SpawnableMiscList) do
			MiscCategories[v.Category] = MiscCategories[v.Category] or {}
			table.insert(MiscCategories[v.Category], v)
		end
	end
	for CategoryName, v in SortedPairs(MiscCategories) do
	
		local node = dtree:AddNode(CategoryName, "icon16/monkey.png")
		
		
		node.DoPopulate = function( self )
	
			if ( self.PropPanel ) then return end

			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )

			for name, ent in SortedPairsByMemberValue( v, "PrintName" ) do
			
				spawnmenu.CreateContentIcon( "entity", self.PropPanel, 
				{ 
					nicename	= ent.PrintName or ent.Name,
					spawnname	= ent.Class,
					material	= "entities/"..ent.Class..".png",
					admin		= ent.AdminOnly or false
				})
			
			end
			

		end

		node.DoClick = function( self )
	
			self:DoPopulate()		
			pnlContent:SwitchPanel( self.PropPanel )
	
		end
		

		
	end



end )
