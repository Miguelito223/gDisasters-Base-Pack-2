AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

--[[
This is a base for radiation/chemical damage entities.
--]]

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""    

ENT.GBOWNER                          =  nil             

function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
     end
end
function ENT:Think()
     if (SERVER) then
     if not self:IsValid() then return end
	 local pos = self:GetPos()
	 local dmg = DamageInfo()
	 dmg:SetDamage(self.DamageAmount)
	 dmg:SetDamageType(self.DamageType)
	 dmg:SetAttacker(self.GBOWNER)
	 for k, v in pairs(ents.FindInSphere(pos,self.DamageRadius)) do
         if v:IsPlayer() or v:IsNPC() then
		    v:TakeDamageInfo(dmg)
		 end
	 end
	 self.Bursts = self.Bursts + 1
	 if (self.Bursts >= self.Lifetime) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DamageDelay)
	 return true
	 end
end

function ENT:Draw()
     return false
end