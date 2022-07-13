AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Nurse"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
     
ENT.Mass                             =  100
ENT.Model                            =  "models/nurse/slow.mdl"

ENT.AutomaticFrameAdvance = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()	

	self.NextStep = CurTime()
	
	if (CLIENT) then
	
		if LocalPlayer().Sounds == nil then LocalPlayer().Sounds = {} end
		if LocalPlayer().Sounds["Nurse_Idle"]==nil or LocalPlayer().Sounds["Nurse_Chasing"]==nil then
		
			LocalPlayer().Sounds["Nurse_Idle"]         = {  ["sound"] = createLoopedSound(LocalPlayer(), "disasters/silenthill/nurse_nearby.wav"), ["volume"] = 0 }
			LocalPlayer().Sounds["Nurse_Chasing"]      = {  ["sound"] = createLoopedSound(LocalPlayer(), "disasters/silenthill/nurse_attack.wav"), ["volume"] = 0 }
			LocalPlayer().Sounds["Nurse_Idle"]["sound"]:ChangeVolume(0,0)
			LocalPlayer().Sounds["Nurse_Chasing"]["sound"]:ChangeVolume(0,0)
		end
		
		self:SetMDScale( Vector(1,1,0))
	end
	
	
	
	if (SERVER) then
		
		self:SetModel(self.Model)
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		self:SetAngles(Angle(0,0,0))

		
		self:ResetSequence(self:LookupSequence("nurse_idle"))
		self:SetPlaybackRate( 1/8 )
		
	
		self:SetPos( self:GetPos() )
		self.ShouldAttack	   = false
		self.IsAppearing 	   = true
		self.HasAppeared 	   = false
		self.FirstTimeAngered  = false
		self.CurrentStep       = 0
		self.RunSpeed          = 1
		self:EmitSound("disasters/silenthill/nurse_spawn.mp3", 100, 100, 1)
		self.SpawnTime         = CurTime()
		self.TimeSinceNoTarget = CurTime()
		ParticleEffectAttach( "vomit_blood_main", PATTACH_POINT_FOLLOW, self, 1 )

		
	end
	
	
	self.IsAppearing  = true
	self.HasAppeared  = false	
	self.SpawnTime    = CurTime()
	
end



if (CLIENT) then


	local function NearestNurse_Sound()

		local nurse = FindNearestEntity(LocalPlayer(),  "npc_nurse")
		
		if nurse==nil then 
			
			
		else
			local dis = (1-(math.Clamp(nurse:GetPos():Distance(LocalPlayer():GetPos()), 0, 2000)/2000))^2
			local dis2 = (1-(math.Clamp(nurse:GetPos():Distance(LocalPlayer():GetPos()), 0, 2000)/2000))^4
		

			if !nurse:GetNWEntity("TargetEntity"):IsValid() or nurse:GetNWEntity("TargetEntity")==nil then -- if nurse exists but has no target
			
				
				LocalPlayer().Sounds["Nurse_Chasing"]["volume"] = math.Clamp(LocalPlayer().Sounds["Nurse_Chasing"]["volume"] - FrameTime(), 0, 1)
				LocalPlayer().Sounds["Nurse_Idle"]["volume"] = dis
				


				
			else -- if nurse exists and has a valid target
			
				if nurse:GetNWEntity("TargetEntity")!=LocalPlayer() then
				
					
					LocalPlayer().Sounds["Nurse_Idle"]["volume"] = dis
					LocalPlayer().Sounds["Nurse_Chasing"]["volume"] = math.Clamp(LocalPlayer().Sounds["Nurse_Chasing"]["volume"] - FrameTime(), 0, 1)

	
				else -- if nurse exists and has a target which is local player rip rip rip then
					if nurse:GetNWBool("ShouldAttack")==true then
						--if math.random(1,50)==1 then gfx_SilentHillStun(0.1, 0.1, 0.9) end
						
						
						LocalPlayer().Sounds["Nurse_Idle"]["volume"] = math.Clamp(LocalPlayer().Sounds["Nurse_Idle"]["volume"] - FrameTime(), 0, 1)					
						LocalPlayer().Sounds["Nurse_Chasing"]["volume"] = dis2
					else
						LocalPlayer().Sounds["Nurse_Idle"]["volume"] = dis
						LocalPlayer().Sounds["Nurse_Chasing"]["volume"] = math.Clamp(LocalPlayer().Sounds["Nurse_Chasing"]["volume"] - FrameTime(), 0, 1)
					end
	
					
				end
			end
			
		
			LocalPlayer().Sounds["Nurse_Idle"]["sound"]:ChangeVolume(LocalPlayer().Sounds["Nurse_Idle"]["volume"], 0)
			LocalPlayer().Sounds["Nurse_Chasing"]["sound"]:ChangeVolume(LocalPlayer().Sounds["Nurse_Chasing"]["volume"], 0)		
		end
		
	end
	hook.Add("Tick", "NearestNurseSound", NearestNurse_Sound)

end

function ENT:ProcessSounds()
end

function ENT:Appear()

	if (CLIENT) then
	
		if !self.IsAppearing then return end
		local time_elapsed = CurTime()-self.SpawnTime 
		
		if time_elapsed >= 4 then
			self.IsAppearing = false 
			self.HasAppeared = true
		else
			self:SetMDScale( Vector(1,1, math.Clamp(time_elapsed / 4,0,1)))
		end	
	end
	
	if (SERVER) then
	
		if !self.IsAppearing then return end
		local time_elapsed = CurTime() - self.SpawnTime
		
		if time_elapsed >= 4 then
			self.IsAppearing = false 
			self.HasAppeared = true
		else
			self:SetAngles( Angle( 0, 0, 0) + Angle( 0, (time_elapsed * 4) * 15,0 ) )
		end
	end
	
end

function ENT:SetMDScale(scale)
	local mat = Matrix()
	mat:Scale(scale)
	self:EnableMatrix("RenderMultiply", mat)
end


function ENT:Wakeup(should)
	
	if should==false and self.FirstTimeAngered==true then 

		self:ResetSequence(self:LookupSequence("nurse_wakeup"))
		self:SetPlaybackRate( 1/8 )
	elseif should==false and self.FirstTimeAngered == false then
		
	else
		
		self:ResetSequence(self:LookupSequence("nurse_runcrazy"))
		self:SetPlaybackRate( self.RunSpeed )
	end
end


function ENT:DetectTarget()

	local ply  = FindNearestEntity(self, "player")
	local lightlvl = GetLightLevel(ply) or Vector(1,1,1)
	
	
	if (lightlvl:Length() > 3 or ply:FlashlightIsOn() ) and ply:GetPos():Distance(self:GetPos())  < 2000 then
		self.TargetEntity 		= ply 
		self:SetNWEntity("TargetEntity", ply)
		
		self.ShouldAttack 		= true
		self.FirstTimeAngered   = true
		self.RunSpeed           = math.Clamp(self.RunSpeed + 0.1,1,10)
		self:Wakeup(true)
		
	else 
		self.TargetEntity		= nil
		self.ShouldAttack 		= false
		self.RunSpeed           = 1
		self:Wakeup(false)
	end
	self:SetNWBool("ShouldAttack", self.ShouldAttack)
	
end


function ENT:Chase()
	if !self:CanChase() then return end
	if !self.ShouldAttack then return end
	
	
	local dir    = (self:GetPos()-self.TargetEntity:GetPos()):GetNormalized()
	local z      = 0
	local newpos = (self:GetPos() - (dir * (4 * self.RunSpeed)) )
	


	self:SetPos( newpos)
	self:SetAngles( (self:GetPos()-self.TargetEntity:GetPos()):Angle() - Angle(0,180,0) )
		
		
end

function ENT:CountSteps()
	if self.CurrentStep > 8 then
		self.CurrentStep = 1
	else
		self.CurrentStep = self.CurrentStep + 1
		
		if self.ShouldAttack then self:PlayStepSound() end
	end
end

function ENT:PlayStepSound()
	sound.Play( "disasters/silenthill/nurse_step.mp3", self:GetPos(), 70, math.random(90,110), 1 )
end

function ENT:AddPause()
	local scalep =  0.1 / self.RunSpeed


	if self.CurrentStep == 8 then return scalep else return 0 end
end


function ENT:CanChase()
	
	if (SERVER) then
	
	
		if CurTime()>=self.NextStep then
			self:CountSteps()

			self.NextStep = CurTime() + ((self:SequenceDuration() / self.RunSpeed) / 8 ) + self:AddPause()
			
			return true
		else
		
			return false
		end
	end
end

function ENT:TryKill()
	if !self.TargetEntity then return end
	
	if self:GetPos():Distance(self.TargetEntity:GetPos()) < 100 then
		if self.TargetEntity:Alive() then 
			self.TargetEntity:TakeDamage(self.TargetEntity:Health(), self, self)
			self.TargetEntity:EmitSound("physics/body/body_medium_break2.wav", 70, 100, 1)
			
			self.TargetEntity=nil
			
		end
	end
	
end

function ENT:DeSpawn()
	
	if self.TargetEntity!=nil then
		self.TimeSinceNoTarget = CurTime()
	else
		local t = CurTime() - self.TimeSinceNoTarget 
		
		if self.FirstTimeAngered == false and t >= 20 then self:Remove() end
		if self.FirstTimeAngered == true and t  >= 40 then self:Remove() end 
	end
	
end

function ENT:Think()
	if (CLIENT) then
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate
		self:Appear()
		self:ProcessSounds()
		self:NextThink(CurTime() + t)
		return true	
	end
	
	if (SERVER) then
		if !self:IsValid() then return end
		local t =  (FrameTime() / 0.1) / (66.666 / 0.1) -- tick dependant function that allows for constant think loop regardless of server tickrate

		self:Chase()
		self:Appear()
		self:DetectTarget()
		self:TryKill()
		self:DeSpawn()

		self:NextThink(CurTime() + t)
		return true
	end
end


function ENT:Draw()
	self:DrawModel()


	
end

function ENT:OnRemove()
	if (CLIENT) then
		if LocalPlayer().Sounds!=nil then
		
		if   LocalPlayer().Sounds["Nurse_Chasing"]!=nil then
			 LocalPlayer().Sounds["Nurse_Chasing"]["sound"]:ChangeVolume(0, 0)
		end
		
		if   LocalPlayer().Sounds["Nurse_Idle"]!=nil then
			 LocalPlayer().Sounds["Nurse_Idle"]["sound"]:ChangeVolume(0, 0)
		end	
		
		end
	end

end


function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

























