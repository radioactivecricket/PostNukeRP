--Main Admin Functions

function PNRP.OpenMainAdmin(ply)

	local GMSettingstbl = { }
	local SpawnSettingstbl = { }

	if ply:IsAdmin() then

		GMSettingstbl =
		{
			E2Restrict = GetConVar("pnrp_exp2Level"):GetInt(),
			ToolLevel = GetConVar("pnrp_toolLevel"):GetInt(),
			AdminCreateAll = GetConVar("pnrp_adminCreateAll"):GetInt(),
			AdminTouchAll = GetConVar("pnrp_adminTouchAll"):GetInt(),
			AdminNoCost = GetConVar("pnrp_adminNoCost"):GetInt(),
			PropBanning = GetConVar("pnrp_propBanning"):GetInt(),
			PropAlowing = GetConVar("pnrp_propAllowing"):GetInt(),
			PropSpawnProtection = GetConVar("pnrp_propSpawnpointProtection"):GetInt(),
			PlyDeathZombie = GetConVar("pnrp_PlyDeathZombie"):GetInt(),
			PropExp = GetConVar("pnrp_propExp"):GetInt(),
			PropPunt = GetConVar("pnrp_AllowPunt"):GetInt(),
			PropPay = GetConVar("pnrp_propPay"):GetInt(),
			PropCost = GetConVar("pnrp_propCost"):GetInt(),
			VoiceLimiter = GetConVar("pnrp_voiceLimit"):GetInt(),
			VoiceDistance = GetConVar("pnrp_voiceDist"):GetInt(),
			ClassChangePay = GetConVar("pnrp_classChangePay"):GetInt(),
			ClassChangeCost = GetConVar("pnrp_classChangeCost"):GetInt(),
			DeathPay = GetConVar("pnrp_deathPay"):GetInt(),
			DeathCost = GetConVar("pnrp_deathCost"):GetInt(),
			MaxOwnDoors = GetConVar("pnrp_maxOwnDoors"):GetInt()
		}

		SpawnSettingstbl =
		{
			SpawnMobs = GetConVar("pnrp_SpawnMobs"):GetInt(),
			MaxZombies = GetConVar("pnrp_MaxZombies"):GetInt(),
			MaxFastZombies = GetConVar("pnrp_MaxFastZombies"):GetInt(),
			MaxPoisonZombs = GetConVar("pnrp_MaxPoisonZombs"):GetInt(),
			MaxAntlions = GetConVar("pnrp_MaxAntlions"):GetInt(),
			MaxAntGuards = GetConVar("pnrp_MaxAntGuards"):GetInt(),
			MaxAntMounds = GetConVar("pnrp_MaxMounds"):GetInt(),
			AntMoundRate = GetConVar("pnrp_MoundRate"):GetInt(),
			AntMoundChance = GetConVar("pnrp_MoundChance"):GetInt(),
			MaxMoundAntlions = GetConVar("pnrp_MaxMoundAntlions"):GetInt(),
			MoundAntlionsPerCycle = GetConVar("pnrp_MoundAntlionsPerCycle"):GetInt(),
			MaxMoundGuards = GetConVar("pnrp_MaxMoundGuards"):GetInt(),
			AntMoundMobRate = GetConVar("pnrp_MoundMobRate"):GetInt(),
			MoundGuardChance = GetConVar("pnrp_MoundGuardChance"):GetInt(),
			ReproduceRes = GetConVar("pnrp_ReproduceRes"):GetInt(),
			MaxReproducedRes = GetConVar("pnrp_MaxReproducedRes"):GetInt()
		}
		--Map export List
		local mapList = {}
		local result = querySQL("SELECT * FROM spawn_grids")
		if result then
			for k, v in pairs(result) do
				if !mapList[v["map"]] then
					local nodeCount = table.getn(querySQL("SELECT * FROM spawn_grids WHERE map='"..v["map"].."'"))
					mapList[v["map"]] =
						{
							map = v["map"],
							nodes = nodeCount,
						}
				end
			end
		end

		--Map Inport List
		local ImportList = {}
		local imtbl = {}
		if file.IsDir("PostNukeRP/export_import", "DATA") then
			for k, v in pairs(file.Find("PostNukeRP/export_import/*.txt", "DATA")) do
				imtbl = util.JSONToTable(file.Read("PostNukeRP/export_import/"..v, "DATA"))
				table.insert(ImportList, {v, table.getn(imtbl)})
			end
		end
		
		--Event Admin Stuff
		local EventsTable = {}
		local EventsFunction = {}
		for k, v in pairs(PNRP.Events) do
			EventsTable[k] = v["vars"]
			
			local tmpfName = {}
			for fName, func in pairs(v["funcs"]) do
				table.insert(tmpfName, fName)
			end
			
			EventsFunction[k] = tmpfName
		end

		net.Start( "pnrp_OpenAdminWindow" )
			net.WriteTable(GMSettingstbl)
			net.WriteTable(SpawnSettingstbl)
			net.WriteTable(mapList)
			net.WriteTable(ImportList)
			net.WriteTable(EventsTable)
			net.WriteTable(EventsFunction)
		net.Send(ply)
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
concommand.Add("pnrp_OpenAdmin", PNRP.OpenMainAdmin)

function PNRP.UpdateFromAdminMenu( )
	local ply = net.ReadEntity()
	local GMSettings = net.ReadTable()
	local SpawnSettings = net.ReadTable()
	--local GMSettings = decoded["GMSettings"]
	--local SpawnSettings = decoded["SpawnSettings"]
	if ply:IsAdmin() then
		RunConsoleCommand("pnrp_exp2Level", tostring(GMSettings.E2Restrict))
		RunConsoleCommand("pnrp_toolLevel", tostring(GMSettings.ToolLevel))
		RunConsoleCommand("pnrp_adminCreateAll", tostring(GMSettings.AdminCreateAll))
		RunConsoleCommand("pnrp_adminTouchAll", tostring(GMSettings.AdminTouchAll))
		RunConsoleCommand("pnrp_adminNoCost", tostring(GMSettings.AdminNoCost))
		RunConsoleCommand("pnrp_propBanning", tostring(GMSettings.PropBanning))
		RunConsoleCommand("pnrp_propAllowing", tostring(GMSettings.PropAlowing))
		RunConsoleCommand("pnrp_propSpawnpointProtection", tostring(GMSettings.PropSpawnProtection))
		RunConsoleCommand("pnrp_PlyDeathZombie", tostring(GMSettings.PlyDeathZombie))
		RunConsoleCommand("pnrp_propExp", tostring(GMSettings.PropExp))
		RunConsoleCommand("pnrp_AllowPunt", tostring(GMSettings.PropPunt))
		RunConsoleCommand("pnrp_propPay", tostring(GMSettings.PropPay))
		RunConsoleCommand("pnrp_propCost", tostring(GMSettings.PropCost))
		RunConsoleCommand("pnrp_voiceLimit", tostring(GMSettings.VoiceLimiter))
		RunConsoleCommand("pnrp_voiceDist", tostring(GMSettings.VoiceDistance))
		RunConsoleCommand("pnrp_classChangePay", tostring(GMSettings.ClassChangePay))
		RunConsoleCommand("pnrp_classChangeCost", tostring(GMSettings.ClassChangeCost))
		RunConsoleCommand("pnrp_deathPay", tostring(GMSettings.DeathPay))
		RunConsoleCommand("pnrp_deathCost", tostring(GMSettings.DeathCost))
		RunConsoleCommand("pnrp_maxOwnDoors", tostring(GMSettings.MaxOwnDoors))

		RunConsoleCommand("pnrp_SpawnMobs", tostring(SpawnSettings.SpawnMobs))
		RunConsoleCommand("pnrp_MaxZombies", tostring(SpawnSettings.MaxZombies))
		RunConsoleCommand("pnrp_MaxFastZombies", tostring(SpawnSettings.MaxFastZombies))
		RunConsoleCommand("pnrp_MaxPoisonZombs", tostring(SpawnSettings.MaxPoisonZombs))
		RunConsoleCommand("pnrp_MaxAntlions", tostring(SpawnSettings.MaxAntlions))
		RunConsoleCommand("pnrp_MaxAntGuards", tostring(SpawnSettings.MaxAntGuards))
		RunConsoleCommand("pnrp_MaxMounds", tostring(SpawnSettings.MaxAntMounds))
		RunConsoleCommand("pnrp_MoundRate", tostring(SpawnSettings.AntMoundRate))
		RunConsoleCommand("pnrp_MoundChance", tostring(SpawnSettings.AntMoundChance))
		RunConsoleCommand("pnrp_MaxMoundAntlions", tostring(SpawnSettings.MaxMoundAntlions))
		RunConsoleCommand("pnrp_MoundAntlionsPerCycle", tostring(SpawnSettings.MoundAntlionsPerCycle))
		RunConsoleCommand("pnrp_MaxMoundGuards", tostring(SpawnSettings.MaxMoundGuards))
		RunConsoleCommand("pnrp_MoundMobRate", tostring(SpawnSettings.AntMoundMobRate))
		RunConsoleCommand("pnrp_MoundGuardChance", tostring(SpawnSettings.MoundGuardChance))
		RunConsoleCommand("pnrp_ReproduceRes", tostring(SpawnSettings.ReproduceRes))
		RunConsoleCommand("pnrp_MaxReproducedRes", tostring(SpawnSettings.MaxReproducedRes))
		
		ErrorNoHalt( "[INFO] "..ply:Name().." changed admin settings ".."\n")
		
		ply:ChatPrint("Settings confirmed!")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
--datastream.Hook( "UpdateFromAdminMenu", PNRP.UpdateFromAdminMenu )
net.Receive( "UpdateFromAdminMenu", PNRP.UpdateFromAdminMenu )

function PNRP.OpenMainAdmin(ply)
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end

	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Saves") then file.CreateDir("PostNukeRP/Saves") end
	if !file.IsDir("PostNukeRP/Communities") then file.CreateDir("PostNukeRP/Communities") end

	local Players = {}

	local saveList = file.Find("PostNukeRP/Saves/*.txt")
	for _, f in pairs(saveList) do
		local tbl = {}
		tbl = util.KeyValuesToTable(file.Read("PostNukeRP/Saves/"..f))
		local PUID = string.Explode(".", f)
		Players[PUID[1]] = {
			name = tbl["name"],
			lastdate = tbl["date"],
			resources = tbl["resources"],
			experience = tbl["experience"],
			skills = tbl["skills"]
			}
	end


	net.Start("pnrp_OpenPlyAdminLstWindow")
		net.WriteTable(Players)
		net.WriteTable(result)
	net.Send(ply)
end
concommand.Add("pnrp_OpenPlyAdminLst", PNRP.OpenMainAdmin)
util.AddNetworkString( "pnrp_OpenAdminWindow" )

--Exports the selected map's Node Grid
function PNRP.ExportMapGrid()
	local ply = net.ReadEntity()
	local mapName = net.ReadString()

	local result = querySQL("SELECT * FROM spawn_grids WHERE map='"..mapName.."'")
	if result then
		if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
		if !file.IsDir("PostNukeRP/export_import", "DATA") then file.CreateDir("PostNukeRP/export_import") end

		file.Write("PostNukeRP/export_import/"..mapName..".txt",util.TableToJSON(result))
	end
end
net.Receive( "exportMapGrid", PNRP.ExportMapGrid )

--Import the map from the export file
function PNRP.ImportMapGrid()
	local ply = net.ReadEntity()
	local fileName = net.ReadString()

	if file.Exists("PostNukeRP/export_import/"..fileName, "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/export_import/"..fileName, "DATA"))
		local mapName = tbl[1]["map"]
		if fileName != mapName then mapName = string.gsub(fileName, ".txt", "") end --Fix to allow easy duplication of map grids
		if querySQL("SELECT * FROM spawn_grids WHERE map='"..mapName.."'") then
			query = "DELETE FROM spawn_grids WHERE map='"..mapName.."'"
			result = querySQL(query)
		end
		for k, v in pairs(tbl) do
			query = "INSERT INTO spawn_grids VALUES ( '"..mapName.."'"
			query = query..", '"..v["pos"].."'"
			query = query..", '"..v["range"].."'"
			query = query..", '"..v["spawn_res"].."'"
			query = query..", '"..v["spawn_ant"].."'"
			query = query..", '"..v["spawn_zom"].."'"
			query = query..", '"..v["spawn_mound"].."'"
			query = query..", '"..v["info_indoor"].."'"
			query = query..", '"..v["info_linked"].."' )"
			result = querySQL(query)
		end
	else
		ply:ChatPrint("Map Import file not found.")
	end
end
net.Receive( "importMapGrid", PNRP.ImportMapGrid )

--Delete the selected map's Node Grid
function PNRP.DeleteMapGrid()
	local ply = net.ReadEntity()
	local mapName = net.ReadString()

	local result = querySQL("DELETE FROM spawn_grids WHERE map='"..mapName.."'")

	ply:ChatPrint("Grid deleted for "..mapName)

end
net.Receive( "deleteMapGrid", PNRP.DeleteMapGrid )
util.AddNetworkString( "deleteMapGrid" )

function PlyDevMode(ply, cmd, args)
	if not ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command!")
		return
	end
	local setPlayer = args[1]
	if not setPlayer then 
		setPlayer = ply
	else
		local playerList = player.GetAll()
		local FoundPly = false
		for k, v in pairs(playerList) do
			if IsValid(v) then
				if string.find(string.lower(v:Nick()), string.lower(setPlayer)) then
					FoundPly = true
					setPlayer = v
				end
			end
		end
		if not FoundPly then
			ply:ChatPrint("Player could not be found.")
			return
		end
	end
	if setPlayer.DevMode then
		setPlayer:GodDisable()
		setPlayer.DevMode = false
		setPlayer:SetMoveType( MOVETYPE_WALK )
		ply:ChatPrint("You removed Dev Mode from "..setPlayer:Nick().." ("..setPlayer:SteamName()..")")
		setPlayer:ChatPrint("Dev Mode removed.")
		ErrorNoHalt(ply:SteamName().." Removed Dev Mode from "..setPlayer:SteamName().."\n")
	else
		setPlayer:GodEnable()
		setPlayer.DevMode = true
		ply:ChatPrint("You applied Dev Mode to "..setPlayer:Nick().." ("..setPlayer:SteamName()..")")
		setPlayer:ChatPrint("Dev Mode applied.")
		ErrorNoHalt(ply:SteamName().." Applied Dev Mode to "..setPlayer:SteamName().."\n")
	end
end
concommand.Add( "pnrp_plydevmode", PlyDevMode )

function GM:PlayerNoClip( ply )
	if ply.DevMode then
		return true
	end
	
	if GetConVarNumber("sbox_noclip") == 1 then
		return true
	end
	
	return false
end
