AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Envolving Tornado"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      

ENT.Data                             = {GroundSpeed = {}, MaxFunnel = {}, MinFunnel = {}, Life={}, MaxGroundFunnel={}, MinGroundFunnel={}}

ENT.Data.Effect                      = {"h_ef1","t_ef1","temp_EF1","temp_EF1_fix","har_ef1","t_tornado_EF1","h1_EF1"}
ENT.Data.Effect2                     = {"h_ef2","t_ef2","temp_EF2", "har_ef2","t_tornado_EF2","h1_EF2"}
ENT.Data.Effect3	                 = {"h_ef3","t_ef3","temp_EF3", "har_ef2","t_tornado_EF3","h1_EF3"}
ENT.Data.Effect4                     = {"h_ef4","t_ef4","temp_EF4","har_ef4","t_tornado_EF4","h1_EF4"}
ENT.Data.Effect5                     = {"h_ef5","t_ef5","temp_EF5", "har_ef5","t_tornado_EF5","h1_EF5", "TTC_multivortex"}

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
		

		self.Data.MaxFunnel.Radius = self.Data.MaxFunnel.Radius + 0.5
		self.Data.MinFunnel.Radius = self.Data.MinFunnel.Radius + 0.5
		self.Data.GroundSpeed.Max = self.Data.GroundSpeed.Max + 0.1


		self.Data.MaxGroundFunnel.Radius = self.Data.MaxGroundFunnel.Radius + 0.5
		self.Data.MinGroundFunnel.Radius = self.Data.MinGroundFunnel.Radius + 0.5

		self:NextThink(CurTime() + 1)
		return true
	end
end