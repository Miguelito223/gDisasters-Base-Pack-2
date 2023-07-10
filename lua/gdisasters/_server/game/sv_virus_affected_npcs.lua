AddCSLuaFile()

print("[GDISASTERS] LOADING TVIRUS... ")

npc_tvirus = {
	"npc_monk",
	"npc_metropolice",
	"npc_combine_s",
	"npc_stalker",
	"npc_alyx",
	"npc_barney",
	"npc_magnusson",
	"npc_kleiner",
	"npc_eli",
	"npc_kleiner",
	"npc_mossman",
	"npc_gman",
	"npc_citizen",
	"npc_breen"
}

local function TableAdd()
	local files, directory = file.Find("entities/npc_*.lua", "LUA")

	for k, v in ipairs(files) do
		local file = v:match("(.+)%..+$")
		table.insert(npc_tvirus, file)
	end
end

TableAdd()

for i = 1, #npc_tvirus do
	print("[GDISASTERS] LOADING TABLE: " .. npc_tvirus[i])
end

print("[GDISASTERS] FINISH")
