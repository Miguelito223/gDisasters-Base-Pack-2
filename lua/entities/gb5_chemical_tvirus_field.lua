AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self:SetNoDraw(true)
		 ParticleEffectAttach("tvirus_virus_spread",PATTACH_POINT_FOLLOW,self,0 ) 
		 timer.Simple(10, function()
			if not self:IsValid() then return end
			self:Remove()
		 end)
		 
     end
end

function ENT:Think()
	if (SERVER) then
	if not self:IsValid() then return end

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 50)) do
		if (v:IsPlayer() and v:Alive() and not v.isinfected) then
			if v.gasmasked==false and v.hazsuited==false then
				local ent = ents.Create("gb5_chemical_tvirus_entity")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_POINT_FOLLOW,v,0 ) 
			end
			
		end
		
		if (v:IsNPC() and table.HasValue(npc_tvirus,v:GetClass()) and not v.isinfected) or (v.IsVJHuman==true and not v.isinfected) then
			local ent = ents.Create("gb5_chemical_tvirus_entity_npc")
			ent:SetVar("infected", v)
			ent:SetPos( self:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			v.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
		end	
	end
	
	self:NextThink(CurTime() + 0.2)
	return true
	end
end
function ENT:Draw()
     return true
end