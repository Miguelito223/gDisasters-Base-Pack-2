print("[GDISASTERS AUTOLOAD] DOWNLOADING BASIC...")

local root_Directory = debug.getinfo(1).short_src:match("(addons/.-)/")

local function AddFile( File, directory )
	resource.AddSingleFile( directory .. File )
	print( "[GDISASTERS AUTOLOAD] ADDING: " .. File )
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "GAME" )

	for _, v in ipairs( files ) do	
		if string.EndsWith( v, ".png" ) then return end
		AddFile( v, directory )
	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( root_Directory .. "/materials" )
loadfiles( root_Directory .. "/sounds")

print("[GDISASTERS AUTOLOAD] FINISH")

