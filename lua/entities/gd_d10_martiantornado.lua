AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Martian Tornado"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      

ENT.Data                             = {GroundSpeed = {}, MaxFunnel = {}, MinFunnel = {}, Life={}, MaxGroundFunnel={}, MinGroundFunnel={}}
ENT.Data.Effect                      = {"martian_tornado"}
ENT.Data.Parent                      = nil
ENT.Data.ShouldFollowPath            = false
ENT.Data.EnhancedFujitaScale         = "EF6"

ENT.Data.MaxFunnel.Height 			 = 5000
ENT.Data.MaxFunnel.Radius 			 = 5000 -- funnel radius at max height
ENT.Data.MinFunnel.Height			 = 0    
ENT.Data.MinFunnel.Radius 			 = 3900    -- funnel radius at min height

ENT.Data.GroundSpeed.Min  			 = 20
ENT.Data.GroundSpeed.Max 			 = 25

ENT.Data.Life.Min                    = 180
ENT.Data.Life.Max                    = 240

ENT.Data.MaxGroundFunnel.Height      = 100
ENT.Data.MaxGroundFunnel.Radius      = 1650
ENT.Data.MinGroundFunnel.Height      = 0
ENT.Data.MinGroundFunnel.Radius      = 4800



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
				
		createTornado(table.Copy(self.Data))
		
	end
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
	ent:Spawn()
	ent:Activate()
	return ent
end




function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
	
		self:NextThink(CurTime() + 1)
		return true
	end
end









