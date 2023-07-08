print("[GDISASTERS AUTOLOAD] DOWNLOADING BASIC...")

local rootDirectory = "materials"
local rootDirectory2 = "sounds"

local function AddFile( File, directory )
	resource.AddSingleFile( directory .. File )
	print( "[GDISASTERS AUTOLOAD] ADDING: " .. File )
end

local function loadfiles( directory )
	directory = directory .. "/"

	local files, directories = file.Find( directory .. "*", "THIRDPARTY" )

	for _, v in ipairs( files ) do	
		if string.EndsWith( v, ".png" ) then return then
		AddFile( v, directory )
	end

	for _, v in ipairs( directories ) do
		print( "[GDISASTERS AUTOLOAD] Directory: " .. v )
		loadfiles( directory .. v )
	end
end

loadfiles( rootDirectory )
loadfiles( rootDirectory2 )

print("[GDISASTERS AUTOLOAD] FINISH")

