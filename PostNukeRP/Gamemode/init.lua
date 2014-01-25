include( 'shared.lua' ) --Tell the server to load shared.lua
include("itembase.lua")

AddCSLuaFile( "cl_init.lua" ) --Tell the server that the client needs to download cl_init.lua
AddCSLuaFile( "shared.lua" ) --Tell the server that the client needs to download shared.lua
AddCSLuaFile("itembase.lua")

local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local firstSpawn = true

--Add required resources
function AddDir(dir)
--	print("[Adding Content] From: "..dir)
	
	local files, directories = file.Find(PNRP_Path.."content/"..dir.."/*", "LUA")
	
	for _, fdir in pairs(directories) do
		local dirCheck = file.IsDir(PNRP_Path.."content/"..dir.."/"..fdir, "LUA")
		if fdir != ".svn" and dirCheck then --Dont add the SVN Folders
		--	print("Do Sub: "..dir.."/"..fdir)
			AddDir(dir.."/"..fdir)
		else
			resource.AddSingleFile(tostring(dir.."/"..fdir))
		--	print("[Adding Content] File: "..tostring(dir.."/"..fdir))
		end
	end
	
	for _, v in pairs(files) do
		resource.AddSingleFile(tostring(dir.."/"..v))
	--	print("[Adding Content] File: "..tostring(dir.."/"..v))
	end
end

AddDir("models")
AddDir("materials")
AddDir("sound")
AddDir("scripts")

--for k, v in pairs(file.Find(PNRP_Path.."gamemode/derma/*.lua", "GAME")) do
--	Msg("File(init) "..v.."\n")	
--end

--base include
for k, v in pairs(file.Find(PNRP_Path.."gamemode/base/*.lua", "LUA" )) do
	include("base/"..v)
end
--plugins include
for k, v in pairs(file.Find(PNRP_Path.."gamemode/sv_plugins/*.lua",  "LUA" )) do
	include("sv_plugins/"..v)
end
--derma download
for k, v in pairs( file.Find(PNRP_Path.."gamemode/derma/*.lua",  "LUA" ) ) do
	AddCSLuaFile("derma/"..v)	
end
--vgui download
for k, v in pairs( file.Find(PNRP_Path.."gamemode/vgui/*.lua",  "LUA" ) ) do
	AddCSLuaFile("vgui/"..v)
end

for k, v in pairs( file.Find(PNRP_Path.."gamemode/items/*.lua",  "LUA" ) ) do
	include("items/"..v)
end

--RunConsoleCommand( "sv_alltalk", tostring(0) )
game.ConsoleCommand( "sv_alltalk 0\n" )
game.ConsoleCommand( "sbox_godmode 0\n" )
game.ConsoleCommand( "sbox_playershurtplayers 1\n" )
--game.ConsoleCommand( "sbox_noclip 0\n" )

--net library addnetworkstrings
util.AddNetworkString("pnrp_OpenTShopInterface")
util.AddNetworkString("initProfileStuff")
util.AddNetworkString("loadPlayer")
util.AddNetworkString("delProfile")
util.AddNetworkString("SpawnBulkCrate")
util.AddNetworkString("pnrp_RemoveFromPack")
util.AddNetworkString("setfreq_stream")
util.AddNetworkString("pnrp_addtocarinentory")
util.AddNetworkString("pnrp_dropWepFromEQ")
util.AddNetworkString("DropBulkCrate")
util.AddNetworkString("UseFromInv")
util.AddNetworkString("DropBulkCrateCar")
util.AddNetworkString("Start_open_PropProtection")
util.AddNetworkString("UpdateFromAdminMenu")
util.AddNetworkString("exportMapGrid")
util.AddNetworkString("importMapGrid")
util.AddNetworkString("PropProtect_AddItem")
util.AddNetworkString("PropProtect_RemoveItem")
util.AddNetworkString("stockpile_take")
util.AddNetworkString("stockpile_put")
util.AddNetworkString("stockpile_repair")
util.AddNetworkString("locker_take")
util.AddNetworkString("locker_put")
util.AddNetworkString("locker_repair")
util.AddNetworkString("SKAddCoowner")
util.AddNetworkString("grubSelect")

util.AddNetworkString("printUmsgTable")
util.AddNetworkString("sendUmsgTable")
util.AddNetworkString("sndComDipl")

function querySQL(query)

	result = sql.Query(query)
	if sql.LastError( result ) != nil and result == false then
		ErrorNoHalt(tostring(os.date()).."[SQL ERROR] \n QUERY: "..query.." \n Error:  "..tostring(sql.LastError()).."\n")
	end
	
	return result
end

function SQLiteTableCheck ()
	local query
	local result
	
	if not sql.TableExists("spawn_grids") then
		query = "CREATE TABLE spawn_grids ( map varchar(255), pos varchar(255), range int, spawn_res int, spawn_ant int, spawn_zom int, spawn_mound int, info_indoor int, info_linked varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  spawn_grids\n")
	end
	
	if not sql.TableExists("player_table") then
		query = "CREATE TABLE player_table ( steamid varchar(255), uid varchar(255), ip varchar(255), name varchar(255), first_joined varchar(255), last_joined varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  player_table\n")
	end
	
	if not sql.TableExists("profiles") then
		query = "CREATE TABLE profiles ( pid INTEGER PRIMARY KEY AUTOINCREMENT, steamid varchar(255), model varchar(255), nick varchar(255), lastlog varchar(255), class int, xp int, skills varchar(255), health int, armor int, endurance int, hunger int, res varchar(255), weapons varchar(255), ammo varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  profiles\n")
	end
	
	if not sql.TableExists("community_table") then
		query = "CREATE TABLE community_table ( cid INTEGER PRIMARY KEY AUTOINCREMENT, cname varchar(255), res varchar(255), inv varchar(255), founded varchar(255), diplomacy TEXT )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  community_table\n")
		
		query = "SELECT diplomacy FROM community_table"
		result = sql.Query(query)
		if sql.LastError( result ) != nil and result == false then
			query = "ALTER TABLE community_table ADD COLUMN diplomacy TEXT"
			querySQL(query)
		end
	end
	
	if not sql.TableExists("community_members") then
		query = "CREATE TABLE community_members ( pid int, cid int, rank int, title varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  community_members\n")
	end
	
	if not sql.TableExists("community_pending") then
		query = "CREATE TABLE community_pending ( cid int, msg TEXT, data TEXT, time TEXT )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  community_pending\n")
	end
	
	if not sql.TableExists("player_inv") then
		query = "CREATE TABLE player_inv ( pid int, inventory varchar(255), car_inventory varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  player_inv\n")
	end
	
	if not sql.TableExists("player_storage") then
		--left res table in this in case we change our minds about storing resources
		query = "CREATE TABLE player_storage ( storageid INTEGER PRIMARY KEY AUTOINCREMENT, pid int, name varchar(255), res varchar(255), inventory varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  player_storage\n")
	end
	
	if not sql.TableExists("world_cache") then
		query = "CREATE TABLE world_cache ( pid int, item varchar(255), count int )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  world_cache\n")
	end
	
	if not sql.TableExists("vending_table") then
		query = "CREATE TABLE vending_table ( vendorid INTEGER PRIMARY KEY AUTOINCREMENT, pid int, name varchar(255), res varchar(255), inventory varchar(255) )"
		result = querySQL(query)
	else
		Msg(tostring(os.date()).." SQL TABLE EXISTS:  vending_table\n")
	end
end
hook.Add( "InitPostEntity", "tableCheck", SQLiteTableCheck )

function GM:PlayerInitialSpawn( ply ) --"When the player first joins the server and spawns" function
	
	ply:SetTeam( TEAM_WASTELANDER ) --Add the player to team TEAM_WASTELANDER
	
	ply.Resources = {}
	ply.Skills = {}
	
	ply:GetTable().LastHealthUpdate = 0
	ply:GetTable().LastEndUpdate = 0
	ply:GetTable().LastHunUpdate = 0
	ply:GetTable().Endurance = 100
	ply:GetTable().Hunger = 100
	ply:GetTable().IsAsleep = false

end --End the "when player first joins server and spawns" function

--Move it to it's own function.
function LoadingFunction( len )
	local GM = GAMEMODE
	local ply = net.ReadEntity()
	local option = net.ReadString() 
	local pid
	if option == "new" then
		local plyModel = net.ReadString()
		local plyClass = net.ReadString()
		GM.CreateCharacter( ply, plyModel, plyClass )

		--This calls the profile selection window
		local result = GM.GetCharacterList( ply )
		local tbl = {}
		if result then
			tbl = result
		end

		net.Start("pnrp_runProfilePicker")
			net.WriteTable(tbl)
		net.Send(ply)
	else
		pid = tonumber(net.ReadString())
	end
	if ply then
		ply.HasLoaded = true
		ply:SetNWBool( "HasLoaded", true )
		
		--Sets the players Unique ID to them for faster access.
		ply:SetNetworkedString("UID", ply:UniqueID())
		GM.LoadCharacter( ply, pid ) -- PID STILL NEEDED
		ply.PropBuddyList = ply.PropBuddyList or {}
			
		ply:IncResource("Scrap",0)
		ply:IncResource("Small_Parts",0)
		ply:IncResource("Chemicals",0)

		
		ErrorNoHalt("[Player Loaded] "..ply:Nick().."\n")
		ply:ChatPrint("Welcome to the Wasteland, Press F1 for Help!")
		
		ConVarExists("pnrp_classChangePay")
		ConVarExists("pnrp_toolLevel")
		ConVarExists("pnrp_exp2Level")
		ConVarExists("pnrp_adminNoCost")
		ConVarExists("pnrp_propPay")
	
		if ply.rpname then
			net.Start("RPNameChange")
				net.WriteEntity(ply)
				net.WriteString(ply.rpname)
				net.WriteBit(true)
			net.Broadcast()
		end

		ply:UnSpectate()
		ply:Spawn()
		
		PNRP.ReturnWorldCache( ply )
		
		--Added this to fix issue where clients would not have the correct setting.
		tbl = 
		{
			VoiceLimiter = GetConVar("pnrp_voiceLimit"):GetInt(),
			PropPay = GetConVar("pnrp_propPay"):GetInt(),
			PropCost = GetConVar("pnrp_propCost"):GetInt()
		}
		RunConsoleCommand("pnrp_voiceLimit",tostring(tbl.VoiceLimiter))
		RunConsoleCommand("pnrp_propPay",tostring(tbl.PropPay))
		RunConsoleCommand("pnrp_propCost",tostring(tbl.PropCost))
	else
		ErrorNoHalt("Load timer hit Null Entity (), retrying in 3 seconds.\n")
	end
end
net.Receive("loadPlayer", LoadingFunction );

function setmdl( ply )
	ply:SetModel("models/humans/group02/male_07.mdl")
end
concommand.Add("pnrp_setmdl", setmdl)

function showPInfo( ply )
	local result = sql.Query("SELECT * FROM profiles WHERE pid="..ply.pid)
	if result then
		for v, s in pairs(result) do
			ErrorNoHalt(table.ToString(s,"Profile Info" , true).."\n")
		end
	else
		ply:ChatPrint("Found Nothing")
	end
end
concommand.Add("pnrp_getpinfo", showPInfo)

function GM:PlayerSetModel( ply )
	local cl_playermodel = ply:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	
	local trueModel = ply.rpmodel or modelname
	
	util.PrecacheModel( trueModel )
	ply:SetModel(trueModel)
end

function GM:PlayerSpawn( ply )
	local GM = GAMEMODE
	if not ply.HasLoaded then
		ply:ConCommand( "pnrp_loadin" )
				
		local spawnPoints = ents.FindByClass("info_player_start")
			table.Add(spawnPoints,ents.FindByClass("info_player_terrorist"))
			table.Add(spawnPoints,ents.FindByClass("info_player_counterterrorist"))
	
		ply:StripWeapons()
		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(table.GetFirstValue(spawnPoints))		
		return
	end

    self.BaseClass:PlayerSpawn( ply )
	
    ply:SetGravity( 1 )  
 
    ply:SetWalkSpeed( 150 )  
	if ply:GetTable().Hunger == 0 then
		ply:GetTable().Hunger = 100
	end
    
    if ply:Team() == TEAM_WASTELANDER then
    	ply:SetMaxHealth( 150, true )
    	ply:SetHealth(150)
    elseif ply:Team() == TEAM_SCAVENGER then
    	ply:SetMaxHealth( 75, true )
    	ply:SetHealth(75)
    else 
    	ply:SetMaxHealth( 100, true )
    end
	
	if ply.LoadHealth and ply.LoadHealth > 0 then
		ply:SetHealth(ply.LoadHealth)
		ply.LoadHealth = nil
	end
	
	if ply.LoadArmor and ply.LoadArmor > 0 then
		ply:SetArmor(ply.LoadArmor)
		ply.LoadArmor = nil
	end
	
    ply:SetNetworkedInt("MaxHealth", ply:GetMaxHealth())
    if ply:Team() == TEAM_SCAVENGER then
		ply:SetRunSpeed( 325 + (ply:GetSkill("Athletics") * 10) ) 
	else
		ply:SetRunSpeed( 295 + (ply:GetSkill("Athletics") * 10) )
	end
	
	ply:IncResource("Scrap",0)
	ply:IncResource("Small_Parts",0)
	ply:IncResource("Chemicals",0)
	
	if !ply:GetTable().SleepGodCheck then
		ply:ChatPrint("Temporary Godmode Enabled.")
		ply:GodEnable()
	
		local timerID = tostring(math.random(1,9999999))
		timer.Create( timerID.."god", 15, 1, function()
			if IsValid(ply) then
				if not ply.DevMode then
					ply:GodDisable()
					ply:ChatPrint("Temporary Godmode Disabled.")
					ply:IncResource("Scrap",0)
					ply:IncResource("Small_Parts",0)
					ply:IncResource("Chemicals",0)
				end
			end
		end )
	end
end

function GM:PlayerDisconnected(ply)
	
	local plUID = tostring(ply:GetNetworkedString( "UID" , "None" ))
	if plUID == "None" then
		plUID = ply:UniqueID()
	end
	
	if ply.HasLoaded then
		self.SaveCharacter(ply)
	end
	PNRP.GetAllCars( ply )
	PNRP.GetAllTools( ply )
	
	local DoorList = PNRP.ListDoors( ply )
	for k, v in pairs(DoorList) do
		v:SetNetworkedString("Owner", "World")
		v:SetNetworkedString("Owner_UID", "None")
		v:Fire("unlock", "", 0)
	end
	SK_Srv.OnDisc_Doors( ply )
	
	for k, v in pairs(player.GetAll()) do
		v:ChatPrint(ply:Nick().." has left the server.")
	end
	
	--Will auto unown items after 60 sec if player does not return.
	local TMPPlayerName = ply:Nick()
	timer.Create(tostring(ply:UniqueID()).."plyCK", 60, 1, function()  
		local PlayerOnCheck = false
		
		for k, v in pairs(player.GetAll()) do
			if v:Nick() == TMPPlayerName then
				PlayerOnCheck = true
			end
		end
		
		if !PlayerOnCheck then
			local OwnedList = PNRP.ListOwnedItems( plUID )
			for k, v in pairs(OwnedList) do
				if IsValid(v) then
					local skip = false
					local itmID = PNRP.FindItemID( v:GetClass() )
					if itmID then
						if PNRP.Items[itmID].Persistent then
							skip = true
						end
					end
					if not skip then
						v:SetNetworkedString("Owner", "World")
						v:SetNetworkedString("Owner_UID", "None")
						v:SetNWEntity( "ownerent", nil )
					end
				end
			end
			Msg("Reset Owned Items for "..TMPPlayerName.."\n")
		end
	end)
	
	Msg("Saved character of disconnecting player "..ply:Nick()..".\n")
end

function GM:PlayerLoadout( ply ) --Weapon/ammo/item function

    if ply:Team() == TEAM_WASTELANDER then --If player team equals 1

        giveDefWep(ply)
		ply:ChatPrint("You are now in the Wastelander Class")
 
    elseif ply:Team() == TEAM_SCAVENGER then 
 
        giveDefWep(ply)        
		ply:ChatPrint("You are now in the Scavenger Class")
 
    elseif ply:Team() == TEAM_SCIENCE then 
 
        giveDefWep(ply)        
		ply:ChatPrint("You are now in the Science Class")
 
    elseif ply:Team() == TEAM_ENGINEER then 
 
        giveDefWep(ply)        
		ply:ChatPrint("You are now in the Engineer Class")
    
    elseif ply:Team() == TEAM_CULTIVATOR then 
 
        giveDefWep(ply)        
		ply:ChatPrint("You are now in the Cultivator Class")
    end 
    
end --Here we end the Loadout function

function giveDefWep(ply)
	for _, wep in pairs(PNRP.DefWeps) do
		ply:Give( wep )
	end
end

function team_set_wastelander( ply )
	
	classChangeCheck( ply )
    ply:SetTeam( TEAM_WASTELANDER )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
	
end
 
function team_set_scavenger( ply )
	
	classChangeCheck( ply )
    ply:SetTeam( TEAM_SCAVENGER )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_science( ply )
 
	classChangeCheck( ply )
    ply:SetTeam( TEAM_SCIENCE )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_engineer( ply )
	
	classChangeCheck( ply )
    ply:SetTeam( TEAM_ENGINEER )
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end

function team_set_cultivator( ply )
	
	classChangeCheck( ply )
    ply:SetTeam( TEAM_CULTIVATOR )    
    classChangeCost(ply, "Scrap")
    classChangeCost(ply, "Small_Parts")
    classChangeCost(ply, "Chemicals")
    ply:Spawn() -- Make the player respawn
    
end
 
concommand.Add( "team_set_wastelander", team_set_wastelander )
concommand.Add( "team_set_scavenger", team_set_scavenger )
concommand.Add( "team_set_science", team_set_science )
concommand.Add( "team_set_engineer", team_set_engineer )
concommand.Add( "team_set_cultivator", team_set_cultivator )

--May expand this function for other checks
function classChangeCheck( ply )	
	ply.LoadArmor = ply:Armor()
end

function classChangeCost(ply, Recource)
	
	if GetConVarNumber("pnrp_classChangePay") == 1 then
	    local getRec
	    local int
	    local cost = GetConVarNumber("pnrp_classChangeCost") / 100
  
	    getRec = ply:GetResource(Recource)
	    int = getRec * cost
	    int = math.Round(int)
	    if getRec - int >= 0 then
	    	Msg("Class change cost applied to "..Recource.." \n")
	    	ply:ChatPrint("Changing classes has cost you "..int.." "..Recource..".")
	    	ply:DecResource(Recource,int)
	    end
	end
end

----Code Below This Line----

/*---------------------------------------------------------
  Other
---------------------------------------------------------*/

function EntityMeta:IsDoor()
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" or
		class == "prop_dynamic" then
		return true
	end
	return false
end

function PNRP.ClassIsNearby(pos,class,range)
	local nearby = false
	for k,v in pairs(ents.FindInSphere(pos,range)) do
		if v:GetClass() == class and (pos-Vector(v:LocalToWorld(v:OBBCenter()).x,v:LocalToWorld(v:OBBCenter()).y,pos.z)):Length() <= range then
			nearby = true
		end
	end

	return nearby
end

function string.Capitalize(str)
	local str = string.Explode("_",str)
	for k,v in pairs(str) do
		str[k] = string.upper(string.sub(v,1,1))..string.sub(v,2)
	end

	str = string.Implode("_",str)
	return str
end

function GM.run_Command(ply, command, arg)
	if ply:IsAdmin() then
		RunConsoleCommand( arg[1], arg[2] )	
	end				
end
concommand.Add( "pnrp_RunCommand", GM.run_Command )

function GM:ShowHelp(ply)

	ply:ConCommand("pnrp_help")
	return false
	
end

--F2 Button
function GM:ShowTeam( ply )
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	local myClass
	
	--Added to remove the Null Entity error
	if tostring(ent) == "[NULL Entity]" or ent == nil then return end
	
	if ent.BlockF2 then
		ply:ChatPrint("You can't pick this up.")
		return
	end
	
	if tostring(ply:GetVehicle( )) != "[NULL Entity]" then
		ply:ChatPrint("Cannot do this while in a vehicle.")
		return
	end
		
	if ent:GetClass() == "msc_itembox" or ent:GetClass() == "msc_display_item" then
		ent:F2Use(ply)
	end
	
	if ent:GetClass() == "ent_weapon" then
		myClass = ent:GetNWString("WepClass", nil)
	else
		myClass = ent:GetClass()
	end

	if myClass == "prop_physics" then
		if ent.CanF2 then
			myClass = ent.ID
		else
			return
		end
		-- local myModel = ent:GetModel()
		
		-- for itemname, item in pairs( PNRP.Items ) do
			-- if myModel == item.Model and item.Type != "junk" and item.Type != "build" then

				-- local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[item.ID].Weight
				-- local weightCap
				
				-- if team.GetName(ply:Team()) == "Scavenger" then
					-- weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
				-- else
					-- weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
				-- end
				
				-- if weight <= weightCap then
					-- PNRP.AddToInventory( ply, item.ID, 1 )
					-- ent:Remove()
				-- else
					-- ply:ChatPrint("You're pack is too full and cannot carry this.")
				-- end
			-- end
		-- end
	end
	
	local ItemID = PNRP.FindItemID( myClass )
--	print(tostring(ItemID))
	if ItemID != nil then
		local myType = PNRP.Items[ItemID].Type
		if myType == "vehicle" then
			if tonumber(ent:GetNetworkedString( "Type" , "0" )) == 1 then
				if ent:GetModel() == "models/nova/jeep_seat.mdl" then
					ItemID = "seat_jeep"
				else
					ItemID = "seat_airboat"
				end
				
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
				else
					weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
				end
				
				if weight <= weightCap then
					PNRP.AddToInventory( ply, ItemID, 1 )
					PNRP.TakeFromWorldCache( ply, ItemID )
					pickupGas( ply, ent )
					ent:Remove()
				else
					ply:ChatPrint("Your pack is too full and cannot carry this.")
				end
				
			else
				local myModel = ent:GetModel()	
				
				
				if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) ~= PNRP:GetUID( ply ) then
					ply:ChatPrint("You do not own this!")
					return
				end
						
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep"
				elseif myModel == "models/vehicle.mdl" then ItemID = "vehicle_jalopy" end
				Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
				PNRP.AddToInventory( ply, ItemID, 1 )
				PNRP.TakeFromWorldCache( ply, ItemID )
				ply:ChatPrint("You picked up your car.")
				pickupGas( ply, ent )
				ent:Remove()
								
			end
		else
			if myType == "weapon" then
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
				else
					weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
				end
				
				if weight <= weightCap then
					PNRP.AddToInventory( ply, ItemID, 1 )
					if tonumber(ent:GetNetworkedString("Ammo", 0)) > 0 and not ( ItemID == "wep_grenade" or ItemID == "wep_shapedcharge" )then
						ply:GiveAmmo(tonumber(ent:GetNetworkedString("Ammo")), PNRP.FindAmmoType( ItemID, nil))
					end
					
					ent:Remove()
				else
					ply:ChatPrint("Your pack is too full and cannot carry this.")
				end
			elseif myType == "ammo" then
				local boxes = math.floor( tonumber(ent:GetNWString("Ammo")) / tonumber(ent:GetNWString("NormalAmmo")) )
				local ammoLeft = tonumber(ent:GetNWString("Ammo"))
				local overweight = false
				
				local weightCap
						
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
				else
					weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
				end 
				
				if boxes > 0 then
					for box = 1, boxes do
						local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
						
						if weight <= weightCap then
							PNRP.AddToInventory( ply, ItemID, 1 )
							ammoLeft = ammoLeft - tonumber(ent:GetNWString("NormalAmmo"))
						else
							ply:ChatPrint("Your pack is too full and cannot carry all of this.")
							overweight = true
							break
						end
					end
				end
				
				local ammoType
				
				ammoType = string.gsub(ent:GetClass(),"ammo_","")
				
				if ammoLeft > 0 and boxes > 0 and not overweight then
					ply:ChatPrint("You have loaded the rest of your ammo onto your combat vest.  "..tostring(ammoLeft).." extra rounds taken.")
					ply:GiveAmmo(ammoLeft, ammoType)
					
					ent:Remove()
				elseif ammoLeft > 0 and boxes > 0 and overweight then
					ply:ChatPrint("The rest stays on the ground.")
					ent:SetNetworkedString("Ammo", tostring(ammoLeft))
				elseif ammoLeft > 0 then
					ply:ChatPrint("This isn't enough to worry about.  Only "..tostring(ammoLeft).." rounds here.")
				else
					ply:ChatPrint("You have picked up all of this ammo.")
					
					ent:Remove()
				end
			else  --if myType == "medical" or myType == "food" or myType == "tool" then
				local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[ItemID].Weight
				local weightCap
				
				if myType == "tool" or myType == "misc" then
					if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) ~= PNRP:GetUID(ply) then
						ply:ChatPrint("You do not own this!")
						return
					end
				end
				
				if team.GetName(ply:Team()) == "Scavenger" then
					weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
				else
					weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
				end
				
				if weight <= weightCap then
					PNRP.AddToInventory( ply, ItemID, 1 )
					if myType == "tool" then
						PNRP.TakeFromWorldCache( ply, ItemID )
					end
					ent:Remove()
				else
					ply:ChatPrint("Your pack is too full and cannot carry this.")
				end

			end
		end
	end

end
--F3 Button
function GM:ShowSpare1( ply )
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	--Opens Car inventory when looking at a car owned by you.
	if tostring(ent) != "[NULL Entity]" then
		local ItemID = PNRP.FindItemID( ent:GetClass() )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
				local myModel = ent:GetModel()
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
				ply:SendLua( "CurCarMaxWeight = "..tostring(PNRP.Items[ItemID].Weight) )
				ply:ConCommand("pnrp_carinv")
			else
				--If not looking at the car, open normal inventory.
				ply:ConCommand("pnrp_inv")
			end
		else
			--If not looking at the car, open normal inventory.
			ply:ConCommand("pnrp_inv")
		end
	else
	--If not looking at the car, open normal inventory.
		ply:ConCommand("pnrp_inv")
	end
end
concommand.Add( "pnrp_ShowSpare1", GM.ShowSpare1 )

--F4 Button
function GM:ShowSpare2( ply )
	ply:ConCommand("pnrp_buy_shop")
end

function PNRP.GetAllTools( ply )
	for k,v in pairs(ents.GetAll()) do
		local myClass = v:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then		
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "tool" or myType == "misc" then
				if not PNRP.Items[ItemID].Persistent then
					Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
					PNRP.AddToInventory( ply, ItemID, 1 )
					PNRP.TakeFromWorldCache( ply, ItemID )
					v:Remove()
				end
			end
		end	
	end
end

function PNRP.GetAllCars( ply )
	for k,v in pairs(ents.GetAll()) do
		local myClass = v:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( ply ) && myType == "vehicle" then
				
				--Forces the player out of the vehicle (Nolcip exploit fix)
				local driver = v:GetDriver( )
				if IsValid(driver) then driver:ExitVehicle( ) end
				
				local myModel = v:GetModel()
								
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep"
				elseif myModel == "models/vehicle.mdl" then ItemID = "vehicle_jalopy" end
				
				Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
				PNRP.AddToInventory( ply, ItemID, 1 )
				PNRP.TakeFromWorldCache( ply, ItemID )
				pickupGas( ply, v )
				v:Remove()
				
			end
		end	
	end
end
concommand.Add( "pnrp_GetAllCar", PNRP.GetAllCars )
PNRP.ChatConCmd( "/getallcars", "pnrp_GetAllCar" )

function PNRP.GetCar( ply )
	
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	if tostring(ent) != "[NULL Entity]" then
		local myClass = ent:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && myType == "vehicle" then
				local myModel = ent:GetModel()
								
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep"
				elseif myModel == "models/vehicle.mdl" then ItemID = "vehicle_jalopy" end
				
				Msg("Sending "..ItemID.." to "..ply:Nick().."'s Inventory".."\n")
				PNRP.AddToInventory( ply, ItemID, 1 )
				PNRP.TakeFromWorldCache( ply, ItemID )
				ent:Remove()
				
			end
		end	
	end
end
concommand.Add( "pnrp_GetCar", PNRP.GetCar )
PNRP.ChatConCmd( "/getcar", "pnrp_GetCar" )

--This is an override to hide death notices.
function GM:PlayerDeath( Victim, Inflictor, Attacker )
	local infClass = "unknown"
	local attClass = "unknown"
	if IsValid(Inflictor) then infClass = Inflictor:GetClass() end
	if IsValid(Attacker) then attClass = Attacker:GetClass() end
	if Victim:IsPlayer() and Attacker:IsPlayer() then
		ErrorNoHalt(Victim:Nick().." ("..Victim:SteamName()..")".." was killed by "..Attacker:Nick().." ("..Attacker:SteamName()..") with "..infClass.."\n")
	elseif Victim:IsPlayer() then
		if Inflictor:GetNWString("Owner", nil) then
			ErrorNoHalt(Victim:Nick().." ("..Victim:SteamName()..")".." was killed by (Object Owner)"..tostring(Inflictor:GetNWString("Owner",nil)).." with "..infClass.."\n")
		else
			ErrorNoHalt(Victim:Nick().." ("..Victim:SteamName()..")".." was killed by "..attClass.." with "..infClass.."\n")
		end
		
	end
	
	-- Don't spawn for at least 2 seconds
	Victim.NextSpawnTime = CurTime() + 2
	Victim.DeathTime = CurTime()

end

--This is an override to hide NPC death notices.
function GM:OnNPCKilled( victim, killer, weapon )
	-- May do some stuff here later.
end

--Hook for NPC damage
-- function scaleZombieDamage( npc, hitgroup, dmginfo )
	-- if npc:GetClass() == "npc_littlezombie" then
		-- if hitgroup == HITGROUP_HEAD then
			-- dmginfo:ScaleDamage( 5 )
		-- elseif hitgroup == HITGROUP_CHEST then
			-- dmginfo:ScaleDamage( 1 )
		-- else
			-- dmginfo:ScaleDamage( 0.5 )
		-- end
	-- end
-- end
-- hook.Add("ScaleNPCDamage","ScaleZombieDamage",scaleZombieDamage)

PNRP.ChatConCmd( "/setowner", "pnrp_setOwner" )

function GM:CanProperty( ply, strProp, ent )
	local IsOwned = PickupCheck( ply, ent )
	
	if strProp == "drive" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			return false
		end
	elseif strProp == "ignite" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	elseif strProp == "extinguish" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	elseif strProp == "remover" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	elseif strProp == "keepupright" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	elseif strProp == "collision" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	elseif strProp == "gravity" then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			return true
		else
			if IsOwned then
				return true
			else
				return false
			end
		end
	else
		return false	
	end
end

function VehicleDamageFix( target, dmginfo )
	if dmginfo:GetAttacker():GetClass() == "prop_vehicle_jeep_old" or dmginfo:GetAttacker():GetClass() == "prop_vehicle_airboat" or dmginfo:GetAttacker():GetClass() == "prop_vehicle_jeep" then
		if target:GetClass() == "npc_combine_s" then
			dmginfo:SetDamage(0)
		end
	end
end
hook.Add("EntityTakeDamage", "vehDamageFix", VehicleDamageFix )


-- Debug, REMOVE LATER

function StartUmsgTable(ply, cmd, args)
	local trgName = args[1]
	local trgEnt = nil
	for _, v in pairs(player.GetAll()) do
		if string.find( string.lower(v:SteamName()), string.lower(trgName)) then
			trgEnt = v
			break
		end
	end

	if IsValid(trgEnt) then
		net.Start( "sendUmsgTable" )
		net.Send(trgEnt)
	else
		local plyTable = player.GetAll()
		net.Start( "sendUmsgTable" )
		net.Send(plyTable[math.Random(1, #plyTable)])
	end
end
concommand.Add( "pnrp_printumsgtable", StartUmsgTable )

function PrintUmsgTable()
	local umsgTable = net.ReadTable()
	
	ErrorNoHalt("umsgTable:  "..table.ToString(umsgTable).."\n")
end
net.Receive( "printUmsgTable", PrintUmsgTable )


--util.AddNetworkString("setCL_ColorFX")
--EOF
