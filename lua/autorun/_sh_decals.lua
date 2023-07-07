print("loading decals...")

local root_folder_name = debug.getinfo(1).short_src:match("materials/decals")

local function RunFile(file_path)
	local file = file_path:match(".+/(.+)")

	if !file:EndsWith(".vtf") and !file:EndsWith(".vmt") then return end

	if file:match("snow") == "snow" then
		print("snow")
		game.AddDecal( "snow", file_path )
	elseif file:match("sand") == "sand" then
		print("sand")
		game.AddDecal( "sand", file_path )
	elseif file:match("ice") == "ice" then
		print("ice")
		game.AddDecal( "ice", file_path )
	else
		print("other")
		game.AddDecal( file, file_path )
	end

	print("completed")
end

function LoadFiles(file_path)
	file_path = file_path or root_folder_name
	local files, folders = file.Find(file_path .. "/*", "THIRDPARTY")
	
	if !table.IsEmpty(folders) then
		for _, folder_name in next, folders do
			if folder_name == "." or folder_name == ".." then continue end
            
			local path = ("%s/%s"):format(file_path, folder_name)
			
			LoadFiles(path)
		end
	end
	
	if !table.IsEmpty(files) then
		for i = 1, #files do
			local file = files[i]
			print("loading file: " .. file_path .. "/" .. file)
			RunFile(file_path .. "/" .. file)
		end
	end
end

LoadFiles("materials/decals")

print("finish")