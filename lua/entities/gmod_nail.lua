AddCSLuaFile()

ENT.Type = "anim"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.PrintName		= ""
ENT.Author		= ""
ENT.Contact		= ""
ENT.Purpose		= ""
ENT.Instructions	= ""

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/

function ENT:Initialize()

	self:SetModel( "models/crossbow_bolt.mdl" )	
	
end

/*---------------------------------------------------------
   Name: Draw
   Desc: Draw it!
---------------------------------------------------------*/
function ENT:Draw()

	self:DrawModel()
	
end