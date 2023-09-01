AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Dorothy Probe"
ENT.Author			                 =  "Hmm"
ENT.Contact		                     =  "Hmm"
ENT.Category                         =  "Hmm"
ENT.Mass                             =  10

ENT.AutomaticFrameAdvance            = true 

function ENT:Initialize()	

	if (CLIENT) then
	
	
		self.PixVis = util.GetPixelVisibleHandle()

	
	end
	if (SERVER) then
		
		self:SetModel("models/ramses/models/equipment/dorothy_probe.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		

		local phys = self:GetPhysicsObject()
		


		
		if (phys:IsValid()) then
			phys:SetMass(self.Mass)
			phys:Wake()
			phys:EnableMotion(true)
		end 		

		
		
		self.IsOn = false
		self.NextSwitchTime = CurTime()
		self:SetNWBool("IsOn", false)

		
		if WireAddon != nil then

			self.Inputs   = WireLib.CreateInputs(self, {  "Activate" }) 
			self.Outputs  = WireLib.CreateOutputs(self, {  "X", "Y" ,"Z", "WindSPD"  }) 
			
		end
		
	end
end


function ENT:TriggerInput(iname, value)
     if !self:IsValid() then return end
	 
	 if iname == "Activate" then
	 
		if CurTime() >= self.NextSwitchTime then 
		
			self:SetMode(!self:GetMode())
			self.NextSwitchTime = CurTime() + 0.4
			
		end
	 end
 
end 


function ENT:UpdateOutputs()
    if !self:IsValid() then return end
	local pos = self:GetPos()
	
	if self:GetMode() == true then
	
		WireLib.TriggerOutput(self, "X", pos.x)
		WireLib.TriggerOutput(self, "Y", pos.y)
		WireLib.TriggerOutput(self, "Z", pos.y)
		WireLib.TriggerOutput(self, "WindSPD", convert_MetoKMPH(convert_SUtoMe(self:GetVelocity():Length())))
	end
end 


function ENT:SetMode(mode)
	if mode == true then	
		self.IsOn = true 
		self:SetNWBool("IsOn", true)
	else
		self.IsOn = false
		self:SetNWBool("IsOn", false)
	end
	
end

function ENT:GetMode()
	return self.IsOn
end


function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 25   ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	
	if (SERVER) then
		if !self:IsValid() then return end
	

		self:UpdateOutputs()
		
		self:NextThink( CurTime() + 0.02 )
		return true
	end
end




function ENT:Use()
	
	if CurTime() >= self.NextSwitchTime then 
		self:SetMode(!self:GetMode())
		
		self.NextSwitchTime = CurTime() + 0.4
		
	end


 end


function ENT:Draw()


	
	self:DrawModel()
	
end


function ENT:UpdateTransmitState()

	return TRANSMIT_ALWAYS

end



function ENT:OnRestore()
	if (SERVER) then Wire_Restored(self.Entity) end
end

function ENT:BuildDupeInfo()
     return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
     WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PrentityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StorentityModifier(self,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end



if (CLIENT) then
	local yellow_flare, glow_general, bar = Material( "effects/yellowflare" ) , Material( "effects/glow_general" ), Material("effects/lensflare/bar")

	function gDisasters_ProbeFlares()
	
		
		for k, v in pairs(ents.FindByClass("gd_equip_dorothy_probe")) do
		
			if v:GetNWBool("IsOn")==true then
				local sratio =  math.Clamp( v:GetPos():Distance(LocalPlayer():GetPos()) / 2000 , 0.01, 1) 
				local vis    = util.PixelVisible( v:GetPos(), 5, v.PixVis)
		
				
				cam.Start3D( EyePos(), EyeAngles() ) 
					render.SetMaterial(yellow_flare)			
					render.DrawSprite( v:GetPos(), 155 * sratio, 155 * sratio, Color( 255, 255, 255, 155 * vis ) )
					
					render.SetMaterial(glow_general)
					render.DrawSprite( v:GetPos(), 155 * sratio, 155 * sratio, Color( 255, 255, 255, 155 * vis ) )
					
					render.SetMaterial(bar)
					render.DrawSprite( v:GetPos(), 555 * sratio + math.random(1,25), 555 * sratio + math.random(1,25), Color( 255, 255, 255, 155 * vis ) )
				cam.End3D()
			
			
			end
		end

	end

	hook.Add( "RenderScreenspaceEffects", "gDisasters_ProbeFlares", gDisasters_ProbeFlares)


end
