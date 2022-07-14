AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Neutron Star"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
    
ENT.Mass                             =  100
ENT.RealMass                         =  5*(10^16)
ENT.Model                            =  "models/ramses/models/space/neutron_star.mdl"


function ENT:Initialize()	

	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE )

		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:EnableMotion(true)
			phys:Wake()
			
		end 

		self:CreateLoop()
		self:LockPosition()
	
		self:CreatePoleEndTracers()
		ParticleEffectAttach("neutron_star_aura_main", PATTACH_POINT_FOLLOW, self, 0)
		
	end
	

end

function ENT:CreatePoleEndTracers()
	self.Tracers         = {["South"]=nil, ["North"]=ni;}
	
	local np_p            =  self:GetAttachment( 1 ).Pos
	local sp_p            =  self:GetAttachment( 2 ).Pos

	local tracer_north = ents.Create("gd_d10_neutron_star_ch")
	tracer_north:SetPos( np_p ) 
	tracer_north:Spawn()
	tracer_north:Activate()
	
	local tracer_south = ents.Create("gd_d10_neutron_star_ch")
	tracer_south:SetPos( sp_p ) 
	tracer_south:Spawn()
	tracer_south:Activate()	
	
	self.Tracers["South"] = tracer_south
	self.Tracers["North"] = tracer_north

	net.Start("gd_lightning_bolt")
	net.WriteEntity(self)
	net.WriteEntity(tracer_south)
	net.WriteString("neutron_star_ray_main")
	net.Broadcast()
	
	net.Start("gd_lightning_bolt")
	net.WriteEntity(self)
	net.WriteEntity(tracer_north)
	net.WriteString("neutron_star_ray_main")
	net.Broadcast()
		
end


function ENT:MoveTracers()
	if !self.Tracers["South"]:IsValid() or !self.Tracers["North"]:IsValid() then self:Remove() return end 

	local np_p            =  self:GetAttachment( 1 ).Pos
	local sp_p            =  self:GetAttachment( 2 ).Pos
	
	local np_p_dir        =  (np_p - self:GetPos()):GetNormalized()
	local sp_p_dir        =  (sp_p - self:GetPos()):GetNormalized()
	
	local tr_np = util.TraceLine( {
		start = np_p,
		endpos = np_p + (np_p_dir * 50000),
		filter = {self, self.Tracers["North"]}
	} )

	
	local tr_sp = util.TraceLine( {
		start = sp_p,
		endpos = sp_p + (sp_p_dir * 50000),
		filter = {self, self.Tracers["North"]}
	} )
	

	self.Tracers["South"]:SetPos(tr_sp.HitPos)
	self.Tracers["North"]:SetPos(tr_np.HitPos)
	
	

	
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * (1000 * math.random(4,4))  ) 
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:LockPosition()
	self.LockedPosition = self:GetPos()
end


function ENT:CreateLoop()
	local sound = Sound("disasters/space/neutron_star/idle.wav")

	CSPatch = CreateSound(self, sound)
	CSPatch:SetSoundLevel( 140 )
	CSPatch:Play()
	CSPatch:ChangeVolume( 1 )
	self.Sound = CSPatch

end

function CalculateNewtonianForce(M1, M2, r) 
	
	local G = 6.67*(10^-11)
	local F = (G*(M1*M2))/ (r^2)
	
	
	
	return F

end

function EnableGlobalGravity(bool)
	for k, v in pairs(ents.GetAll()) do 
	
		if v:IsPlayer() and bool==false then
			v:SetMoveType(MOVETYPE_FLY)
		elseif v:IsPlayer() and bool==true then
			v:SetMoveType(MOVETYPE_WALK)
		end
		
		if v:GetPhysicsObject():IsValid() then
			v:GetPhysicsObject():EnableGravity(bool)
		end 
	end
end

function ENT:NewtonianGravity()
	for k, v in pairs(ents.GetAll()) do
		local phys = v:GetPhysicsObject()
		if phys:IsValid() and v:GetClass()!=self:GetClass() and  (v:GetClass()!= "phys_constraintsystem" and v:GetClass()!= "phys_constraint"  and v:GetClass()!= "logic_collision_pair") then
		
			 
			
			local M1  = self.RealMass 
			local M2  = phys:GetMass()
			
			local p1, p2 = self:GetPos(), v:GetPos()
			
			local r      = p1:Distance(p2)
			
			local dir = (p1-p2):GetNormalized()
			local Fr  = (dir * -1*10^9) / ((r+1000)^2)
			local Fg  = CalculateNewtonianForce(M1, M2, r) * dir 
			
			local FsR = ( Fg:Length() - Fr:Length()) * -dir

			
			if v:IsPlayer() or v:IsNPC() or v:IsNextBot() then
				
				v:SetVelocity( FsR )
				v:SetMoveType( MOVETYPE_FLY)
			else
				phys:AddVelocity(Fg + (p1:Cross(p2)))
			end
			
			
			
		end
	end
end

function ENT:Flares()
	if HitChance(1) then
		if HitChance(50) then
			CreateLightningArc(self:GetAttachment( 1 ).Pos, self:GetAttachment( 2 ).Pos, "neutron_star_magnetic_field_lines_main")
		else
			CreateLightningArc(self:GetAttachment( 2 ).Pos, self:GetAttachment( 1 ).Pos, "neutron_star_magnetic_field_lines_main")
		end
	end
end

function ENT:Rotate()
	self:SetAngles( self:GetAngles() - Angle(-0.5,-1,1) )

end
function ENT:LockPositionUpdate()
	self:SetPos( self.LockedPosition ) 
end

function ENT:PhysicsUpdate()
	self:LockPositionUpdate()



end



function ENT:Think()

	if (SERVER) then
		if !self:IsValid() then return end
		self:Rotate()
		self:NewtonianGravity()
		self:Flares()
		self:MoveTracers()
		self:NextThink(CurTime() + 0.01)
		return true	
	end
	
end




function ENT:OnRemove()
	if (SERVER) then
		EnableGlobalGravity(true)
	end
	if self.Sound==nil then return end
	self.Sound:Stop()

	
	self:StopParticles()
end



