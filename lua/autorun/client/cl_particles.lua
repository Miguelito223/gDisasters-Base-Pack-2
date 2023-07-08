
print("[GDISASTERS AUTOLOAD] LOADING PARTICLES...")

local root_Directory = "particles"
print(root_Directory)

local function AddFile( File, directory )
	game.AddParticles( directory .. File )
	print( "[GDISASTERS AUTOLOAD] ADDING: " .. File )
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do
		if string.EndsWith( v, ".pcf" ) then
			AddFile( v, directory )
		end
	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( root_Directory )


print("[GDISASTERS AUTOLOAD] FINISH")