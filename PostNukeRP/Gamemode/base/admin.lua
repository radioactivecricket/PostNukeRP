--Main Admin Functions

function PNRP.OpenMainAdmin(ply)

	local GMSettingstbl = { }
	local SpawnSettingstbl = { }

	if ply:IsAdmin() then

		GMSettingstbl =
		{
			E2Restrict = getServerSetting("exp2Level"),
			ToolLevel = getServerSetting("toolLevel"),
			AdminCreateAll = getServerSetting("adminCreateAll"),
			AdminTouchAll = getServerSetting("adminTouchAll"),
			AdminNoCost = getServerSetting("adminNoCost"),
			PropBanning = getServerSetting("propBanning"),
			PropAlowing = getServerSetting("propAllowing"),
			PropSpawnProtection = getServerSetting("propSpawnpointProtection"),
			PlyDeathZombie = getServerSetting("PlyDeathZombie"),
			PropExp = GetConVar("pnrp_propExp"):GetInt(),
			PropPunt = getServerSetting("AllowPunt"),
			PropPay = getServerSetting("propPay"),
			PropCost = getServerSetting("propCost"),
			VoiceLimiter = getServerSetting("voiceLimit"),
			VoiceDistance = getServerSetting("voiceDist"),
			ClassChangePay = getServerSetting("classChangePay"),
			ClassChangeCost = getServerSetting("classChangeCost"),
			DeathPay = getServerSetting("deathPay"),
			DeathCost = getServerSetting("deathCost"),
			MaxOwnDoors = getServerSetting("maxOwnDoors")
		}

		SpawnSettingstbl =
		{
			SpawnMobs = getServerSetting("SpawnMobs"),
			MaxZombies = getSpawnerSetting("MaxZombies"),
			MaxFastZombies = getSpawnerSetting("MaxFastZombies"),
			MaxPoisonZombs = getSpawnerSetting("MaxPoisonZombies"),
			MaxAntlions = getSpawnerSetting("MaxAntlions"),
			MaxAntGuards = getSpawnerSetting("MaxAntGuards"),
			MaxAntMounds = getSpawnerSetting("MaxMounds"),
			AntMoundRate = getSpawnerSetting("MoundRate"),
			AntMoundChance = getSpawnerSetting("MoundChance"),
			MaxMoundAntlions = getSpawnerSetting("MaxMoundAntlions"),
			MoundAntlionsPerCycle = getSpawnerSetting("MoundAntlionsPerCycle"),
			MaxMoundGuards = getSpawnerSetting("MaxMoundGuards"),
			AntMoundMobRate = getSpawnerSetting("MoundMobRate"),
			MoundGuardChance = getSpawnerSetting("MoundGuardChance"),
			ReproduceRes = getServerSetting("ReproduceRes"),
			MaxReproducedRes = getSpawnerSetting("MaxReproducedRes")
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

function PNRP.UpdateFromAdminMenu( len, ply )
	local GMSettings = net.ReadTable()
	local SpawnSettings = net.ReadTable()
	
	if ply:IsAdmin() then
		setServerSetting("exp2Level", tonumber(GMSettings.E2Restrict))
		setServerSetting("toolLevel", tonumber(GMSettings.ToolLevel))
		setServerSetting("adminCreateAll", tonumber(GMSettings.AdminCreateAll))
		setServerSetting("adminTouchAll", tonumber(GMSettings.AdminTouchAll))
		setServerSetting("adminNoCost", tonumber(GMSettings.AdminNoCost))
		setServerSetting("propBanning", tonumber(GMSettings.PropBanning))
		setServerSetting("propAllowing", tonumber(GMSettings.PropAlowing))
		setServerSetting("propSpawnpointProtection", tonumber(GMSettings.PropSpawnProtection))
		setServerSetting("PlyDeathZombie", tonumber(GMSettings.PlyDeathZombie))
		setServerSetting("propExp", tonumber(GMSettings.PropExp))
		setServerSetting("AllowPunt", tonumber(GMSettings.PropPunt))
		setServerSetting("propPay", tonumber(GMSettings.PropPay))
		setServerSetting("propCost", tonumber(GMSettings.PropCost))
		setServerSetting("voiceLimit", tonumber(GMSettings.VoiceLimiter))
		setServerSetting("voiceDist", tonumber(GMSettings.VoiceDistance))
		setServerSetting("classChangePay", tonumber(GMSettings.ClassChangePay))
		setServerSetting("classChangeCost", tonumber(GMSettings.ClassChangeCost))
		setServerSetting("deathPay", tonumber(GMSettings.DeathPay))
		setServerSetting("deathCost", tonumber(GMSettings.DeathCost))
		setServerSetting("maxOwnDoors", tonumber(GMSettings.MaxOwnDoors))

		setServerSetting("SpawnMobs", tonumber(SpawnSettings.SpawnMobs))
		setSpawnerSetting("MaxZombies", tonumber(SpawnSettings.MaxZombies))
		setSpawnerSetting("MaxFastZombies", tonumber(SpawnSettings.MaxFastZombies))
		setSpawnerSetting("MaxPoisonZombies", tonumber(SpawnSettings.MaxPoisonZombs))
		setSpawnerSetting("MaxAntlions", tonumber(SpawnSettings.MaxAntlions))
		setSpawnerSetting("MaxAntGuards", tonumber(SpawnSettings.MaxAntGuards))
		setSpawnerSetting("MaxMounds", tonumber(SpawnSettings.MaxAntMounds))
		setSpawnerSetting("MoundRate", tonumber(SpawnSettings.AntMoundRate))
		setSpawnerSetting("MoundChance", tonumber(SpawnSettings.AntMoundChance))
		setSpawnerSetting("MaxMoundAntlions", tonumber(SpawnSettings.MaxMoundAntlions))
		setSpawnerSetting("MoundAntlionsPerCycle", tonumber(SpawnSettings.MoundAntlionsPerCycle))
		setSpawnerSetting("MaxMoundGuards", tonumber(SpawnSettings.MaxMoundGuards))
		setSpawnerSetting("MoundMobRate", tonumber(SpawnSettings.AntMoundMobRate))
		setSpawnerSetting("MoundGuardChance", tonumber(SpawnSettings.MoundGuardChance))
		setServerSetting("ReproduceRes", tonumber(SpawnSettings.ReproduceRes))
		setSpawnerSetting("MaxReproducedRes", tonumber(SpawnSettings.MaxReproducedRes))
		
		ErrorNoHalt( "[INFO] "..ply:Name().." changed admin settings ".."\n")
		
		ply:ChatPrint("Settings confirmed!")
	else
		ply:ChatPrint("You are not an admin on this server!")
	end
end
net.Receive( "UpdateFromAdminMenu", PNRP.UpdateFromAdminMenu )

function PNRP.OpenMainAdmin(ply)
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	Players = {}
	result = {}


	net.Start("pnrp_OpenPlyAdminLstWindow")
		net.WriteTable(Players)
		net.WriteTable(result)
	net.Send(ply)
end
concommand.Add("pnrp_OpenPlyAdminLst", PNRP.OpenMainAdmin)
util.AddNetworkString( "pnrp_OpenAdminWindow" )
util.AddNetworkString( "pnrp_OpenPlyAdminLstWindow" )

function PNRP.plyADMSearch(len, ply)
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	local searchString = net.ReadString()
	local option = net.ReadString()
	
	local query, result
	result = {}
	if option == "steamid" then
		query = "SELECT * FROM player_table WHERE steamid LIKE '%"..SQLStr2(searchString).."%'"
	else
		query = "SELECT * FROM player_table WHERE name LIKE '%"..SQLStr2(searchString).."%'"
	end
	
	result = querySQL(query)
	
	if not result then return end

	net.Start("C_SND_plyADMSearchResults")
		net.WriteTable(result)
	net.Send(ply)
end
util.AddNetworkString("SND_plyADMSearch")
util.AddNetworkString("C_SND_plyADMSearchResults")
net.Receive( "SND_plyADMSearch", PNRP.plyADMSearch )

function PNRP.plyADMSelSID(len, ply)
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	local steamid = net.ReadString()

	local query, pQuery
	local result = {}
	local pResult = {}
	local CommunityTbl = {}
	query = "SELECT * FROM player_table WHERE steamid='"..tostring(steamid).."'"
	result = querySQL(query)
	pQuery = "SELECT * FROM profiles WHERE steamid='"..tostring(steamid).."'"
	pResult = querySQL(pQuery)
	
	for k, v in pairs(pResult) do
		local cQuery = "SELECT * FROM community_members WHERE pid='"..tostring(v["pid"]).."'"
		local cResult = querySQL(cQuery)
		if cResult then
			local comResult = querySQL("SELECT * FROM community_table WHERE cid='"..tostring(cResult[1]["cid"]).."'")
			
			CommunityTbl[v["pid"]] = {cname=comResult[1]["cname"], rank=cResult[1]["rank"], title=cResult[1]["title"]}
		end
	end
	
	net.Start("C_SND_PlyAdminSelResult")
		net.WriteTable(result)
		net.WriteTable(pResult)
		net.WriteTable(CommunityTbl)
	net.Send(ply)
end
util.AddNetworkString("SND_plyADMSelSID")
util.AddNetworkString("C_SND_PlyAdminSelResult")
net.Receive( "SND_plyADMSelSID", PNRP.plyADMSelSID )

function PNRP.plyADMSelProfile(len, ply)
	
	local GM = GAMEMODE
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	local pid = net.ReadString()

	for _, p in pairs(player.GetAll()) do
		if tostring(p.pid) == tostring(pid) then
			GM.SaveCharacter(p)
		end
	end
	
	local profResult, plyResult
	local plyTbl = {}
	local CommunityTbl = {}
	
	profResult = querySQL("SELECT * FROM profiles WHERE pid='"..tostring(pid).."'")
	if not profResult then
		ply:ChatPrint("Error in getting profile: "..tostring(pid))
		return
	end
	table.Merge(plyTbl, profResult[1])
	
	local steamid =  profResult[1]["steamid"]
	plyResult = querySQL("SELECT * FROM player_table WHERE steamid='"..tostring(steamid).."'")
	table.Merge(plyTbl, plyResult[1])
	
	local cQuery = "SELECT * FROM community_members WHERE pid='"..tostring(pid).."'"
	local cResult = querySQL(cQuery)
	if cResult then
		local comResult = querySQL("SELECT * FROM community_table WHERE cid='"..tostring(cResult[1]["cid"]).."'")
		CommunityTbl = {cname=comResult[1]["cname"], rank=cResult[1]["rank"], title=cResult[1]["title"]}
	end	
	
	local storageTbl = querySQL("SELECT * FROM player_storage WHERE pid="..tostring(pid))
	if not storageTbl then storageTbl = {} end
	
	local vendorTbl = querySQL("SELECT * FROM vending_table WHERE pid="..tostring(pid))
	if not vendorTbl then vendorTbl = {} end
	
	net.Start("C_SND_PlyAdminProfileView")
		net.WriteTable(plyTbl)
		net.WriteTable(PNRP.GetFullInventoryPID( pid ))
		net.WriteTable(CommunityTbl)
		net.WriteTable(storageTbl)
		net.WriteTable(vendorTbl)
	net.Send(ply)
end
util.AddNetworkString("SND_plyADMSelProfile")
util.AddNetworkString("C_SND_PlyAdminProfileView")
net.Receive( "SND_plyADMSelProfile", PNRP.plyADMSelProfile )

function PNRP.AdmEditPlayer(len, ply)
	local GM = GAMEMODE
	local option = net.ReadString()
	local pid = net.ReadString()
	
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	local isOnline
	local targetPly
	local result
	local weaponStr = ""
	local ammoStr = ""

	for _, p in pairs(player.GetAll()) do
		if tostring(p.pid) == tostring(pid) then
			isOnline = true
			targetPly = p
		end
	end
	result = querySQL("SELECT * FROM profiles WHERE pid='"..tostring(pid).."'")
	weaponStr = result[1]["weapons"]
	ammoStr = result[1]["ammo"]
	
	if option == "rem_weapon" then
		local weapon = net.ReadString()
		
		if isOnline then
			targetPly:StripWeapon( weapon )
			targetPly:EmitSound(Sound("items/ammo_pickup.wav"))
		end 
		
		local weaponTbl = string.Explode(",", weaponStr)
		weaponStr = ""
		for _, v in pairs(weaponTbl) do
			if tostring(v) ~= weapon and tostring(v) ~= "" then
				weaponStr = weaponStr..v..","
			end
		end
		string.TrimRight(weaponStr, ",")
		if weapon == "weapon_frag" or weapon == "weapon_pnrp_charge" then
			local ammoExpTbl = string.Explode(" ", ammoStr)
			local ammoTbl = {}
			for _, v in pairs(ammoExpTbl) do
				local Tbl = string.Explode(",", v)
				if (weapon == "weapon_frag" and Tbl[1] == "grenade") or (weapon == "weapon_pnrp_charge" and Tbl[1] == "slam") then
					--Do nothing
				else
					ammoTbl[Tbl[1]] = Tbl[2]
				end
			end
			ammoStr = ""
			for ammo, amount in pairs(ammoTbl) do
				ammoStr = ammoStr..ammo..","..tostring(amount).." "
			end
			string.TrimRight(ammoStr)
		end
	
		querySQL("UPDATE profiles SET weapons='"..weaponStr.."', ammo='"..ammoStr.."' WHERE pid="..tostring(pid))
		
	elseif option == "rem_ammo" then
		local ammo = net.ReadString()
		if isOnline then
			local ammoCount = targetPly:GetAmmoCount( ammo )
			targetPly:RemoveAmmo( ammoCount, ammo )
			targetPly:EmitSound(Sound("items/ammo_pickup.wav"))
		end
		
		local ammoExpTbl = string.Explode(" ", ammoStr)
		local ammoTbl = {}
		for _, v in pairs(ammoExpTbl) do
			local Tbl = string.Explode(",", v)
			
			if Tbl[1] ~= ammo then
				ammoTbl[Tbl[1]] = Tbl[2]
			end
		end
		ammoStr = ""
		for ammo, amount in pairs(ammoTbl) do
			ammoStr = ammoStr..ammo..","..tostring(amount).." "
		end
		string.TrimRight(ammoStr)
		
		querySQL("UPDATE profiles SET ammo='"..ammoStr.."' WHERE pid="..tostring(pid))
	elseif option == "editRes" then
		local res = net.ReadString()
		querySQL("UPDATE profiles SET res='"..tostring(res).."' WHERE pid="..tostring(pid))
	elseif option == "changeName" then
		local name = net.ReadString()
		if isOnline then
			if (not name) or name == "" or name == nil then
				targetPly.rpname = targetPly:SteamName()
			else
				if string.len(name) > 40 then
					ply:ChatPrint("Name too long! Must be under 40 characters.")
					return
				end

				targetPly.rpname = name
			end
			
			net.Start("RPNameChange")
				net.WriteEntity(targetPly)
				net.WriteString(targetPly.rpname)
				net.WriteBit(false)
			net.Broadcast()
		else
			querySQL("UPDATE profiles SET nick='"..tostring(name).."' WHERE pid="..tostring(pid))
		end
	end
	
	if isOnline then GM.SaveCharacter( targetPly ) end
end
util.AddNetworkString("SND_AdmEditPlayer")
net.Receive( "SND_AdmEditPlayer", PNRP.AdmEditPlayer )

function PNRP.AdmSVSelID(len, ply)
	local id = net.ReadString()
	local option = net.ReadString()
	
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	local query, result
	local inmvTbl = {}
	if option == "storage" then
		inmvTbl = GetFullStorageInventory( ply, id )
	elseif option == "vendor" then
		inmvTbl = getFullVendorInventory(id)
	else
		return
	end
	
	net.Start("C_SND_AdmVewSV")
		net.WriteString(id)
		net.WriteTable(inmvTbl)
		net.WriteString(option)
	net.Send(ply)
	
end
util.AddNetworkString("SND_AdmSVSelID")
util.AddNetworkString("C_SND_AdmVewSV")
net.Receive("SND_AdmSVSelID", PNRP.AdmSVSelID)

function PNRP.admDelInvItem(len, ply)
	local option = net.ReadString()
	local id = net.ReadString()
	local itemID = net.ReadString()
	local count = net.ReadDouble()
	local iid = net.ReadString()
	local pid = net.ReadString()
	
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	local query, result
	if iid == nil or iid == "" then
		if option == "player" then
			PNRP.PlyDelItem( pid, itemID, count )
		elseif option == "storage" then
			remStorageItem( id, itemID, count )
		elseif option == "vendor" then
			remVendorItem( id, itemID, count )
		end
	else
		PNRP.DelPersistItem(iid)
	end
	
	if option == "player" then
		net.Start("C_SND_AdmViewRefreshPlyInv")
			net.WriteString( pid )
			net.WriteTable(PNRP.GetFullInventoryPID( pid ))
		net.Send(ply)
	end
	
end
util.AddNetworkString("admDelInvItem")
util.AddNetworkString("C_SND_AdmViewRefreshPlyInv")
net.Receive("admDelInvItem", PNRP.admDelInvItem)

function PNRP.admAddInvItem(len, ply)
	local pid = net.ReadString()
	local itemID = net.ReadString()
	
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	PNRP.AddToInventory( pid, itemID, 1 )
	
	net.Start("C_SND_AdmViewRefreshPlyInv")
		net.WriteString( pid )
		net.WriteTable(PNRP.GetFullInventoryPID( pid ))
	net.Send(ply)
end
util.AddNetworkString("admAddInvItem")
net.Receive("admAddInvItem", PNRP.admAddInvItem)


function PNRP.RunAdminSQL(len, ply)
	if !ply:IsAdmin() then
		ply:ChatPrint("You are not an admin on this server!")
		return
	end
	
	local result
	local outString = ""
	local query = net.ReadString()
	
	result = sql.Query(query)
	
	if sql.LastError( result ) != nil and result == false then
		result = tostring(sql.LastError())
	end
	
	if result then
		if istable(result) then
			outString = table.ToString(result)
		else 
			outString = tostring(result)
		end
	else
		outString = "nil"
	end

	net.Start("pnrp_sqlAdmnReturnTxt")
		net.WriteString(outString)
	net.Send(ply)
end
util.AddNetworkString("pnrp_RecAdminSQL")
util.AddNetworkString("pnrp_sqlAdmnReturnTxt")
net.Receive("pnrp_RecAdminSQL", PNRP.RunAdminSQL)
	
--Exports the selected map's Node Grid
function PNRP.ExportMapGrid(len, ply)
	local mapName = net.ReadString()
	
	if not ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command!")
		return
	end
	
	local result = querySQL("SELECT * FROM spawn_grids WHERE map="..SQLStr(mapName))
	if result then
		if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
		if !file.IsDir("PostNukeRP/export_import", "DATA") then file.CreateDir("PostNukeRP/export_import") end

		file.Write("PostNukeRP/export_import/"..mapName..".txt",util.TableToJSON(result))
	end
end
net.Receive( "exportMapGrid", PNRP.ExportMapGrid )

--Import the map from the export file
function PNRP.ImportMapGrid( len, ply )
	local fileName = net.ReadString()
	
	if not ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command!")
		return
	end
	
	if file.Exists("PostNukeRP/export_import/"..fileName, "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/export_import/"..fileName, "DATA"))
		local mapName = tbl[1]["map"]
		if fileName != mapName then mapName = string.gsub(fileName, ".txt", "") end --Fix to allow easy duplication of map grids
		if querySQL("SELECT * FROM spawn_grids WHERE map="..SQLStr(mapName)) then
			query = "DELETE FROM spawn_grids WHERE map="..SQLStr(mapName)
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
function PNRP.DeleteMapGrid(len, ply)
	local mapName = net.ReadString()
	
	if pl ~= ply then return end
	
	if not ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command!")
		return
	end
	
	local result = querySQL("DELETE FROM spawn_grids WHERE map="..SQLStr(mapName))

	ply:ChatPrint("Grid deleted for "..mapName)

end
net.Receive( "deleteMapGrid", PNRP.DeleteMapGrid )
util.AddNetworkString( "deleteMapGrid" )

function PlyDevMode(ply, cmd, args)
	if not ply:IsAdmin() then
		ply:ChatPrint("You do not have access to this command!")
		return
	end
	local setPlayer =args[1]
	if not setPlayer then 
		setPlayer = ply
	else
		setPlayer = string.lower(tostring(setPlayer))
		local playerList = player.GetAll()
		local FoundPly = false
		for k, v in pairs(playerList) do
			if IsValid(v) then
				if string.find(string.lower(tostring(v:Nick())), tostring(setPlayer)) then
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
