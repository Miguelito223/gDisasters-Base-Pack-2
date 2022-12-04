AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Waterspout"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      

ENT.Data                             = {GroundSpeed = {}, MaxFunnel = {}, MinFunnel = {}, Life={}, MaxGroundFunnel={}, MinGroundFunnel={}}
ENT.Data.Effect                      = {"har_waterspout"}
ENT.Data.Parent                      = nil
ENT.Data.ShouldFollowPath            = false
ENT.Data.EnhancedFujitaScale         = "EF1"

ENT.Data.MaxFunnel.Height 			 = 5000
ENT.Data.MaxFunnel.Radius 			 = 3300 -- funnel radius at max height
ENT.Data.MinFunnel.Height			 = 0    
ENT.Data.MinFunnel.Radius 			 = 500    -- funnel radius at min height

ENT.Data.GroundSpeed.Min  			 = 2
ENT.Data.GroundSpeed.Max 			 = 10



ENT.Data.MaxGroundFunnel.Height      = 100
ENT.Data.MaxGroundFunnel.Radius      = 1250
ENT.Data.MinGroundFunnel.Height      = 0
ENT.Data.MinGroundFunnel.Radius      = 2100




function ENT:Initialize()		
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		
		self:SetNoDraw(true)
		
		self.Data.Parent = self
			
		local effect = self.Data.Effect[1]
		self.OriginalEffect = effect
		createTornado(table.Copy(self.Data))
		
	end
end

function ENT:SpawnFunction( ply, tr )
	local tr = util.TraceLine( {
		start  =  ply:GetPos(),
		endpos = ply:GetPos() + ply:GetAimVector() * 500,
		mask   = MASK_WATER
	} )
	if tr.Hit then
		self.OWNER = ply
		local ent = ents.Create( self.ClassName )
		ent:SetPhysicsAttacker(ply)
		ent:SetPos( tr.HitPos + tr.HitNormal * 16) 
		ent:Spawn()
		ent:Activate()
		return ent
	else
	
		ply:ChatPrint("It must be spawned on water...")
	
	end
end

function ENT:OverWater()

	local tr = util.TraceLine( {
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0,0,11),
		mask   = MASK_WATER 
	})
	
	return tr.HitWorld
	
end

function ENT:RemoveWaterSpoutInSolid()
	local isOnWater    = self:OverWater()
	local ent = ents.FindByClass(self.ClassName)[1]
	ply = self.OWNER


	if isOnWater == true then
	elseif isOnWater == false then
		ent:Remove()
	end


end


function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:RemoveWaterSpoutInSolid()

		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()

end









