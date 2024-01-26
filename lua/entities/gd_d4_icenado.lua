AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Icenado"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Model                            =  "models/props_junk/PopCan01a.mdl"                      

ENT.Data                             = {GroundSpeed = {}, MaxFunnel = {}, MinFunnel = {}, Life={}, MaxGroundFunnel={}, MinGroundFunnel={}}
ENT.Data.Effect                      = {"har_icenado"}
ENT.Data.Parent                      = nil
ENT.Data.ShouldFollowPath            = false
ENT.Data.EnhancedFujitaScale         = "EF0"

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
		self.TornadoENT = createTornado(table.Copy(self.Data))
		self:SetNWEntity("TornadoENT", self.TornadoENT)
		
	end

	self:PostSpawn()
end

function ENT:SpawnFunction( ply, tr )

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 16) 
	ent:Spawn()
	ent:Activate()
	return ent

end

function ENT:PostSpawn()
	local me  = self  
		
	if (SERVER) then 
	function self.TornadoENT:DamagingAura()
		
		if CurTime() >= self.NextIceDamageTime then
			self.NextIceDamageTime = self.NextIceDamageTime + 0.4 
			 self:OnDamagingAura()
			---
		else 
		
		end
	
	end
	
	function self.TornadoENT:OnDamagingAura()
		
		
		local pos         = self:GetPos() + Vector(0,0,self.Data.MaxGroundFunnel.Height)
		local funnel_ents = FindInCone(pos, self.Data.MaxFunnel.Height, self.Data.MinFunnel.Height, self.Data.MaxFunnel.Radius, self.Data.MinFunnel.Radius, true )
		

		for k, v in pairs(funnel_ents) do
			
			local radius =         v[2]
			local ent              = v[1] 
			local entpos 		   = ent:GetPos()
			
			local height              =  self.Data.MaxFunnel.Height - ((self:GetPos().z + self.Data.MaxFunnel.Height) - ent:GetPos().z)

			if ent:IsValid() and self:CanBeSeenByTheWind(ent) then 
				


				if ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot() then
					InflictDamage(ent, me, "cold", 5)
				else 
		
		
				end
			end
			
		end
		
	
	
	end
	
	function self.TornadoENT:Think()
		if (SERVER) then
			if !self:IsValid() then return end
			
			self:Move()
			self:Physics()
			self:IsParentValid()
			self:DamagingAura()
			
			
			self:NextThink(CurTime() + 0.01)
			return true
		end
		
	end
	
	function self.TornadoENT:CustomPostSpawn()
		self.NextIceDamageTime = CurTime() 
		self:GetRidOfSounds()
	
		
		timer.Simple(1, function()
			if !self:IsValid() then return end
			local sound = Sound(table.Random( {"streams/disasters/nature/tornado/Icenado.wav", "streams/disasters/nature/tornado/small_Icenado_loop_1.wav", "streams/disasters/nature/tornado/small_Icenado_loop_2.wav", "streams/disasters/nature/tornado/small_Icenado_loop_3.wav"}))

			CSPatch = CreateSound(self, sound)
			CSPatch:SetSoundLevel( 100 )
			CSPatch:Play()
			CSPatch:ChangeVolume( 1 )
			self.Sound = CSPatch
		end)
		
	end
	self.TornadoENT:CustomPostSpawn()

	end
	

	
	
	
	
	if (CLIENT) then 
	
		timer.Simple(1, function()
			if !self:IsValid() then return end 
			self.TornadoENT = self:GetNWEntity("TornadoENT")
			
			function self.TornadoENT:CustomPostSpawn()
				self.NextIceDamageTime = CurTime() 
				
				self:GetRidOfSounds()
				
				timer.Simple(1, function()
					if !self:IsValid() then return end
					local sound = Sound(table.Random( {"streams/disasters/environment/wind_shared/Icenado.wav", "streams/disasters/environment/wind_shared/small_Icenado_loop_1.wav", "streams/disasters/environment/wind_shared/small_Icenado_loop_2.wav", "streams/disasters/environment/wind_shared/small_Icenado_loop_3.wav"}))

					CSPatch = CreateSound(self, sound)
					CSPatch:SetSoundLevel( 100 )
					CSPatch:Play()
					CSPatch:ChangeVolume( 1 )
					self.Sound = CSPatch
				end)
				
			end
			
			function self.TornadoENT:Think()
			


				if (CLIENT) then 
			
					local dlight = DynamicLight( self:EntIndex() )
					if ( dlight ) then
						dlight.pos = self:GetPos()
						dlight.r = 0
						dlight.g = 255
						dlight.b = 255
						dlight.brightness = 12
						dlight.Decay = 5
						dlight.Size = 1024
						dlight.DieTime = CurTime() + 0.4
					end
				end
				
			end
			
			
			self.TornadoENT:CustomPostSpawn()
		end)
	
	end

	


end


function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:NextThink(CurTime() + 1)
		return true
	end
end









