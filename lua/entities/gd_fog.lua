AddCSLuaFile();

ENT.Base = "base_entity";
ENT.Type = "point";
ENT.DisableDuplicator = true;

function ENT:UpdateTransmitState() 
    return TRANSMIT_ALWAYS 
end

function ENT:Initialize()

    if SERVER then return end

    self.Keys = {
        "FogStart",
        "FogEnd",
        "FogDensity",
        "FogColor"
    };

    self.Values = {};

    for k,v in pairs( self.Keys ) do

        self["Get" .. tostring(v)] = function() return self.Values[tostring(v)] end
        self["Set" .. tostring(v)] = function( ent, value ) self.Values[tostring(v)] = value end

    end

    -- defaults
    self:SetFogStart( 0.0 );
    self:SetFogEnd( 0.0 );
    self:SetFogDensity( 0.0 );
    self:SetFogColor( Vector( 0.6, 0.7, 0.8 ) );

    hook.Add( "SetupWorldFog", self, self.SetupWorldFog );
    hook.Add( "SetupSkyboxFog", self, self.SetupSkyFog );

end

function ENT:GetFogValues()

    local tbl = {
        FogStart = self:GetFogStart(),
        FogEnd = self:GetFogEnd(),
        FogDensity = self:GetFogDensity(),
        FogColor = self:GetFogColor()
    };

    return tbl;

end

function ENT:Think()

end

function ENT:SetupWorldFog()

    render.FogMode( 1 );
    render.FogStart( self:GetFogStart() );
    render.FogEnd( self:GetFogEnd() );
    render.FogMaxDensity( self:GetFogDensity() );

    local col = self:GetFogColor();
    render.FogColor( col.x * 255, col.y * 255, col.z * 255 );

    return true;

end

function ENT:SetupSkyFog( scale )
    
    render.FogMode( 1 );
    render.FogStart( self:GetFogStart() * scale );
    render.FogEnd( self:GetFogEnd() * scale );
    render.FogMaxDensity( self:GetFogDensity() );

    local col = self:GetFogColor();
    render.FogColor( col.x * 255, col.y * 255, col.z * 255 );

    return true;

end