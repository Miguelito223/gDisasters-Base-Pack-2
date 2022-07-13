AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Locust Apocalypse"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"

ENT.Material                         = "models/rendertarget"        
ENT.Mass                             =  100
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"


function ENT:Initialize()	


	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		local phys = self:GetPhysicsObject()
		

		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
		end 		
		
		self.LocustEntities = {}
		
		
		
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * -0.2  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

local nomnoms = {
	["models/props_junk/watermelon01.mdl"] = true,
	["models/props_lab/cactus.mdl"       ] = true,
	["models/props_lab/crematorcase.mdl" ] = true,
	["models/props_c17/doll01.mdl"       ] = true,
	["models/Gibs/HGIBS.mdl"             ] = true,
	["models/Humans/Charple01.mdl"       ] = true,
	["models/Humans/Charple02.mdl"       ] = true,
	["models/props_foliage/tree_poplar_01.mdl"] = true,
	["models/props_foliage/bramble001a.mdl"]=true,
	["models/props_foliage/cattails.mdl"]= true,
	["models/props_foliage/driftwood_01a.mdl"]=true,
	["models/props_foliage/driftwood_02a.mdl"]=true,
	["models/props_foliage/driftwood_03a.mdl"]=true,
	["models/props_foliage/driftwood_clump_01a.mdl"]=true,
	["models/props_foliage/driftwood_clump_02a.mdl"]=true,
	["models/props_foliage/driftwood_clump_03a.mdl"]=true,
	["models/props_foliage/ivy_01.mdl"]=true,
	["models/props_foliage/shrub_01a.mdl"]=true,
	["models/props_foliage/tree_cliff_02a.mdl"]=true,
	["models/props_foliage/tree_deciduous_01a-lod.mdl"]=true,
	["models/props_foliage/tree_deciduous_01a.mdl"]=true,
	["models/props_foliage/tree_deciduous_02a.mdl"]=true,
	["models/props_foliage/tree_deciduous_03a.mdl"]=true,
	["models/props_foliage/tree_deciduous_03b.mdl"]=true,
	["models/props_foliage/tree_deciduous_card_01_skybox.mdl"]=true,
	["models/props_foliage/tree_poplar_01.mdl"]=true,
	["models/props_junk/watermelon01_chunk01a.mdl"]=true,
	["models/props_junk/watermelon01_chunk01b.mdl"]=true,
	["models/props_junk/watermelon01_chunk01c.mdl"]=true,
	["models/props_junk/watermelon01_chunk02a.mdl"]=true,
	["models/props_junk/watermelon01_chunk02b.mdl"]=true,
	["models/props_junk/watermelon01_chunk02c.mdl"]=true,
	["models/weapons/w_bugbait.mdl"]=true
}
	
	
	
	

function ENT:AddLocusts()
	for k, v in pairs(player.GetAll()) do
		
		if v.islocusted == nil or v.islocusted == false then
			v.islocusted = true
			
			local ent = ents.Create("gd_locusts")
			ent:SetPos( self:GetPos() )
			ent.TargetEntity = v
			ent:Spawn()
			ent:Activate()
			table.insert(self.LocustEntities, ent)
		
		end
		
	end
	local eatables = FindEntitiesByModels(nomnoms)
	if #eatables > 0 then
	
		for k, v in pairs(eatables) do
		
			if v.islocusted == nil or v.islocusted == false then
				v.islocusted = true
			
				local ent = ents.Create("gd_locusts")
				ent:SetPos( self:GetPos() )
				ent.TargetProp = v
				ent:Spawn()
				ent:Activate()
		
			end
		
		end
	end
end

function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		
		self:AddLocusts()
		self:NextThink(CurTime() + t)
		return true
	end
end

function ENT:OnRemove()
	if (SERVER) then
	
		for k, v in pairs(player.GetAll()) do
			v.islocusted=false
		end
		
		for k, v in pairs(self.LocustEntities) do
			if v:IsValid() then v:Remove() end 
		end
	
	end
end

function ENT:Draw()



	self:DrawModel()
	
end




