-- gd_heatsys_raincell/init.lua

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Heat System Rain Cell"
ENT.Author = "YourName"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl") -- Set a default model, it will be invisible anyway
    self:SetNoDraw(true) -- Make the entity invisible
    self:SetCollisionGroup(COLLISION_GROUP_WORLD) -- Disable collision
end

function ENT:Think()
    -- Perform any logic here if needed
end