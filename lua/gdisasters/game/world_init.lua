
SetGlobalFloat("gd_seismic_activity", 0)
concommand.Add("tickrate", function(ply, cmd, args)
	print( 1 / engine.TickInterval())
end)





























