AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Plant Takeover"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

    
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"

function ENT:Initialize()	

	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		if IsMapRegistered() == true then
		self:SetPos(getMapCenterFloorPos())
		end
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		local phys = self:GetPhysicsObject()

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		

		self:SetNoDraw(true)
		
		self.TreeBirds = {}
		
	end
end

function ENT:SpawnTrees()

	if HitChance(2) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
		start  = startpos,
		endpos    = startpos - Vector(0,0,50000),
		} )
		
		
			local tree = ents.Create("gd_takeover")
			if ( !IsValid( tree ) ) then return end
			if tree:WaterLevel() >= 2 then return end
			tree:Spawn()
			tree:Activate()	
			tree:SetModelScale(0.1, 0)
			tree:SetModelScale(1.0, 5)
			tree:SetPos( tr.HitPos )
			table.insert(self.TreeBirds, tree)
			
		
		
		end
	
	for k, v in pairs(ents.GetAll()) do
	
		if (v:GetClass() == "prop_physics") then
		if !self:IsValid() or !v:IsValid() then return end
		
		if HitChance(0.02) then
		
		--print(v:GetModel())
		
		--v:SetMaterial(mat)
		
		timer.Simple( math.random(4,8), function()
		if !v:IsValid() or !self:IsValid() then return end
		
		v:SetColor( Color( 155, 155, 155, 255 ) )
		
		timer.Simple( math.random(4,6), function()
		if !v:IsValid() or !self:IsValid() then return end
		if string.gmatch( tostring(v:GetModel()), "models/props_phx/construct/wood/*" ) then v:Remove() end
		end)
		
		--[[local endswith = string.EndsWith( tostring(v:GetModel()), "1x1.mdl" or "2x2.mdl" or "3x3.mdl" or "4x4.mdl" )
		if endswith and v:GetClass() == "prop_physics" then --just in case
		
		 v:Remove()
		 
		end--]]
				
		end)
		
		
		end
	
		end
	
		if v:IsNPC() and (v:GetClass()!= "npc_crow" and v:GetClass()!= "npc_pigeon"  and v:GetClass()!= "npc_seagull" and v:GetClass()!= "npc_zombie" and v:GetClass()!="npc_fastzombie" and v:GetClass()!="npc_zombie_torso" and v:GetClass()!="npc_fastzombie_torso") then 
		if !self:IsValid() then return end
		v:Remove()
		
		end
	
		if v:IsVehicle() then 
		if !self:IsValid() then return end
		v:Fire("TurnOff", 0.1, 0)
		
		end 
		
	 end 
	 
	 
end

function ENT:SpawnBirds()

	if HitChance(0.5) then
	
		local bounds    = getMapSkyBox()
		local min       = bounds[1]
		local max       = bounds[2]
		
		local startpos  = Vector(   math.random(min.x,max.x)      ,  math.random(min.y,max.y) ,   max.z )

			
		local tr = util.TraceLine( {
		start  = startpos,
		endpos    = startpos - Vector(0,0,50000),
		} )


			local birds = ents.Create( table.Random({"npc_crow","npc_pigeon","npc_seagull"}) )
			if ( !IsValid( birds ) ) then return end
			if ( table.Count( self.TreeBirds ) ) > 40 then return end
			if birds:WaterLevel() >= 1 then return end
			birds:Spawn()
			birds:SetPos( tr.HitPos + Vector(0,0,5 ) )
			table.insert(self.TreeBirds, birds)
		
			
		
		end
	
end

function ENT:Think()
	if (SERVER) then
	local t =  ( (1 / (engine.TickInterval())) ) / 66.666 * 0.1
	
		if !self:IsValid() then return end
		self:GetPhysicsObject():EnableMotion(false)
		self:SpawnTrees()
		self:SpawnBirds()
		self:NextThink(CurTime() + t)
		
		return true
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal    ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:OnRemove()

	if (SERVER) then		
		
	for k, v in pairs(self.TreeBirds) do
	if v:IsValid() then v:Remove() end 
	
		end
		
	end

end

function ENT:Draw()



	self:DrawModel()
	
end


