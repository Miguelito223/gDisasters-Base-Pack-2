print("Loading Particles...")

local root_folder_name = debug.getinfo(1).short_src:match("particles")

local function RunFile(file_path)
	local file = file_path:match(".+/(.+)")
	
	if !file:EndsWith(".pcf") then return end
	
	game.AddParticles( file_path )
	
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

LoadFiles("particles")


print("Finish")