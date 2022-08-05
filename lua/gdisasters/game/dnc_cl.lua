//Made by AeroMatix || https://www.youtube.com/channel/UCzA_5QTwZxQarMzwZFBJIAw || http://steamcommunity.com/profiles/76561198176907257
//This took me quite a while to do so if you can subscribe to my YouTube in return that would be fab, thanks! https://www.youtube.com/channel/UCzA_5QTwZxQarMzwZFBJIAw

-- lightmap stuff
net.Receive( "gdisasters_dnc_lightmaps", function( len )

	render.RedownloadAllLightmaps();

end );

-- precache
hook.Add( "InitPostEntity", "gdisasters_dncFirstJoinLightmaps", function()

	render.RedownloadAllLightmaps();

end );

net.Receive( "gdisasters_dnc_message", function( len )

	local tab = net.ReadTable();

	if ( #tab > 0 ) then

		chat.AddText( unpack( tab ) );

	end

end );

local function UpdateValues( CPanel )

	if ( CPanel == nil ) then return end

	if ( CPanel.enabled ) then

		CPanel.enabled:SetValue( cvars.Number( "gdisasters_dnc_enabled" ) );

	end

	if ( CPanel.paused ) then

		CPanel.paused:SetValue( cvars.Number( "gdisasters_dnc_paused" ) );

	end

	if ( CPanel.realtime ) then

		CPanel.realtime:SetValue( cvars.Number( "gdisasters_dnc_realtime" ) );

	end

	if ( CPanel.length_day ) then

		CPanel.length_day:SetValue( cvars.Number( "gdisasters_dnc_length_day" ) );

	end

	if ( CPanel.length_night ) then

		CPanel.length_night:SetValue( cvars.Number( "gdisasters_dnc_length_night" ) );

	end

end