--Item Loader Base File Runs Shared (Both client and server)
--Items are loaded from the item folder.

PNRP.Items = {}
PNRP.Weapons = {}

--Gets the Item from the Item folder and adds it to the table
function PNRP.AddItem( itemtable )
	
	PNRP.Items[itemtable.ID] =
	{
		ID = itemtable.ID,					--Itembase ID
		Name = itemtable.Name,				--Item Name
		ClassSpawn = itemtable.ClassSpawn,	--Class that can spawn item. All = All classes
		Scrap = itemtable.Scrap,			--Scrap Cost
		SmallParts = itemtable.Small_Parts,	--Small Parts Cost
		Chemicals = itemtable.Chemicals,	--Chemicals Cost
		Chance = itemtable.Chance,			--Chance of creation (Not really used much atm)
		Info = itemtable.Info,				--Item Description
		Type = itemtable.Type,				--Category of item
		Energy = itemtable.Energy,			--Used for various things. Amount of ammo a ammo box has for example
		HP = itemtable.HP,					--Items Max HP
		Ent = itemtable.Ent,				--The Entity it points to
		EntName = itemtable.EntName,		--Entity Name
		Model = itemtable.Model,			--Model
		Spawn = itemtable.Spawn,			--
		Use = itemtable.Use,				--Use Function
		Remove = itemtable.Remove,			--
		Script = itemtable.Script,			--External script, mainly used for vehicles
		Hull = itemtable.Hull,				--Hull Model allowed for vehicle
		HullSkin = itemtable.HullSkin,		--Skin for the hull
		SeatLoc = itemtable.SeatLoc,		--Seat Locations
		SeatModel = itemtable.SeatModel,	--Seat Model
		ShowSeat = itemtable.ShowSeat,
		Weight = itemtable.Weight,			--How much weight the item takes in inventory
		SeatLoc = itemtable.SeatLoc,		--Car seat locations
		Create = itemtable.Create,			--Create Function
		ToolCheck = itemtable.ToolCheck,	--Tool Check Function
		HasStorage = itemtable.HasStorage,	--If the item will have storage
		CanRepair = itemtable.CanRepair,	--If item is repairable
		RepairClass = itemtable.RepairClass,--Classes that are able to repair the item
		Keys = itemtable.Keys,				--If the item can use Keys
		ShopHide = itemtable.ShopHide,		--Hides item from shop if true
		Capacity = itemtable.Capacity,		--How much storage capacity
		Tank = itemtable.Tank,				--Gas Tank Size
		ProfileCost = itemtable.ProfileCost,--
		Persistent = itemtable.Persistent,	--
		UnBlock = itemtable.UnBlock,		--Unblocks the item's model from prop protection
		AllowPunt = itemtable.AllowPunt,	--Punt Block override
		SaveState = itemtable.SaveState,	--If persistent item then set to true
		BuildState = itemtable.BuildState,	--BuildState function
		GearSlots = itemtable.GearSlots		--
	}
end	

--Finds and returns the Item Table in the itembase
function PNRP.SearchItembase( ent )
	local class = ent:GetClass()
	local model = ent:GetModel()
	
	if ent:IsVehicle() then
		for itemname, item in pairs( PNRP.Items ) do
			if item.Model == model then
				return item
			end
		end
	end
	
	if PNRP.Items[class] then
		return PNRP.Items[class]
	else
		if class == "prop_physics" then
			for itemname, item in pairs( PNRP.Items ) do
				if item.Ent == "prop_physics" and item.Model == model and ent.crafted then
					return item
				end
			end
		end
	end
	return nil
end

function PNRP.FindItemID( class )
	for itemname, item in pairs( PNRP.Items ) do
		if item.Ent == "prop_physics" and item.ID == class then
			return item.ID
		elseif class == item.Ent then
			return item.ID
		end
		
	end	
	return nil
end

function PNRP.AddWeapon( weptable )

	PNRP.Weapons[weptable.ID] =
	{
		ID = weptable.ID,
		AmmoType = weptable.AmmoType,
		MagLoadTime = weptable.MagLoadTime,
		MagType = weptable.MagType,
		MagSize = weptable.MagSize,
		EqSize = weptable.EqSize
	}
	
end

function PNRP.FindWepItem( model )
	local fixedModel
	if string.find(model, "v_") then
		fixedModel = string.sub( model, 1, string.find(model, "v_") - 1).."w"..string.sub( model, string.find(model, "v_") + 1 )
	else
		fixedModel = model
	end
	if model == "models/Weapons/V_hands.mdl" or model == "models/weapons/v_hands.mdl" then
		fixedModel = "models/props_citizen_tech/transponder.mdl"
	end
	
	for itemname, item in pairs( PNRP.Items ) do
		if fixedModel == item.Model then
			return item
		end
		
	end	
	return nil
	
end

--Loads items into the itembase
for k, v in pairs( file.Find(PNRP_Path.."gamemode/items/*.lua", "LUA" ) ) do
	include("items/"..v)
	if (SERVER) then AddCSLuaFile("items/"..v) end
end

--searches for itembase items spawned near the entity
--and returns the items found.
function PNRP.FindNearbyItems( ent )
	local plUID = tostring(ent:GetNetVar( "Owner_UID" , "None" ))
	
	local foundItems = {}
	local nearbyEnts = ents.FindInSphere(ent:GetPos(), 150)
	for k, v in pairs(nearbyEnts) do
		if plUID == tostring(v:GetNetVar( "Owner_UID" , "None" )) then
			local vItem = PNRP.SearchItembase( v )
			if vItem then
				if foundItems[vItem.ID] then
					foundItems[vItem.ID] = foundItems[vItem.ID] + 1
				else
					foundItems[vItem.ID] = 1
				end
			end
		end
	end
	
	return foundItems
end

--------------------------
-- Persistent Item Code --
--------------------------

--Gets setting from given stat from the status string
function PNRP.GetFromStat(stateStr, stat)
	local stats = {}
	if not stateStr or not stat then return "" end
	
	local split1 = string.Explode( ",", stateStr )
	for i, statrow in pairs( split1 ) do
		local split2 = string.Explode( "=", statrow )
		stats[split2[1]] = split2[2]
	end
	
	return stats[stat]
end

if (!SERVER) then return end

--Uses parts that are near the entity.
--Tbl is meant to be the return from ToolCheck. 
--Ply is optional. items must have same owner as the entity
function PNRP.UseNearbyParts( Tbl, ent, ply )
	if not Tbl or not ent then return false end
	
	local plUID = tostring(ent:GetNetVar( "Owner_UID" , "None" ))
	
	local foundItems = PNRP.FindNearbyItems( ent )
	for itemid, amount in pairs(Tbl) do
		if PNRP.Items[itemid] then
			if (not foundItems) or (not foundItems[itemid]) or foundItems[itemid] < amount then
				if amount == 0 then
					if ply then
						ply:ChatPrint("You don't have a "..PNRP.Items[itemid].Name..", which is required to build this.")
					end
				else
					if ply then
						ply:ChatPrint("You don't have enough "..PNRP.Items[itemid].Name.."s.  You require "..tostring(amount).." to build this.")
					end
				end
				return false
			end
		end
	end
	
	local nearbyEnts = ents.FindInSphere(ent:GetPos(), 150)
	for _, v in pairs(nearbyEnts) do
		if plUID == tostring(v:GetNetVar( "Owner_UID" , "None" )) then
			local item = PNRP.SearchItembase( v )
			if item and Tbl[item["ID"]] then
				if Tbl[item["ID"]] > 0 then
					if v.iid then
						PNRP.DelPersistItem(v.iid)
					end
					v:Remove()
					Tbl[item.ID] = Tbl[item.ID] - 1
				end
			end
		end
	end
	return true
end

--Uses parts from the player's inventory.
--Tbl is meant to be the return from ToolCheck
function PNRP.UsePlayerParts( Tbl, ply )
	if not Tbl or not ply then return false end

	local foundItems = PNRP.GetFullInventorySimple( ply )
	for itemid, amount in pairs(Tbl) do
		if PNRP.Items[itemid] then
			if (not foundItems) or (not foundItems[itemid]) or foundItems[itemid] < amount then
				if amount == 0 then
					if ply then
						ply:ChatPrint("You don't have a "..PNRP.Items[itemid].Name..", which is required to build this.")
					end
				else
					if ply then
						ply:ChatPrint("You don't have enough "..PNRP.Items[itemid].Name.."s.  You require "..tostring(amount).." to build this.")
					end
				end
				return false
			end
		end
	end
	
	local plyInv = PNRP.Inventory( ply )
	for itemid, amount in pairs(Tbl) do
		if amount ~= 0 then
			if plyInv[itemid] then
				PNRP.TakeFromInventoryBulk( ply, itemid, amount )
			else
				for i=1, amount do
					local query = "SELECT * FROM inventory_table WHERE pid='"..tostring(ply.pid).."' AND itemid='"..itemid.."' AND location='player'"
					local result = querySQL(query)
					if result then
						PNRP.DelPersistItem(result[1]["iid"])
					end
				end
			end
		end
	end
	
	return true
end

--Gets the status table from the DB
function PNRP.ReturnState(iid)
	local query, result
	
	query = "SELECT status_table FROM inventory_table WHERE iid="..tostring(iid)
	result = querySQL(query)

	if result then
		return result[1]["status_table"]
	else
		return false
	end
end

--Updates the locationdata of a persistent item
function PNRP.UpdateLocData(iid, locData)
	if (not iid) or (not locData) then return end
	
	query = "UPDATE inventory_table SET locdata='"..locData.."' WHERE iid="..tostring(iid)
	result = querySQL(query)
end

--Sets the persist items HP
function PNRP.SetPersistantItemHP(ent)
	if !IsValid(ent) then return end
	if not ent.iid then return end
	
	local stateStr = PNRP.ReturnState(ent.iid)
	local HP = PNRP.GetFromStat(stateStr, "HP")
	
	if HP == "" or not HP then return end
	
	ent:SetHealth(tonumber(HP))
end

--Adds a new persist item to the database
function PNRP.AddStatusItem(ply, ent, location)
	local query, result
	if not ply then 
		Msg("[AddStatusItem Error]: Invalid Player ENT \n")
		return 
	end
	
	local item = PNRP.SearchItembase( ent )
	if not item then return end
	if (not location) then location = "none" end
	
	local pid = ""
	if isstring(ply) then 
		pid = tostring(ply)
	else
		pid = tostring(ply.pid)
	end
	
	if item.SaveState and IsValid(ent) then
		local stateTable = item.BuildState( ent )
		local tmpID = tostring(pid..os.time()..math.random(100, 255))
		local itemID = tostring(item.ID)
		local iid
		
		query = "INSERT INTO inventory_table (itemid, pid, location, status_table) VALUES ('"..tmpID.."','"..tostring(pid).."', '"..location.."','"..tostring(stateTable).."')"
		result = querySQL(query)
		
		query = "SELECT iid FROM inventory_table WHERE itemid="..tostring(tmpID)
		result = querySQL(query)
		iid = result[1]["iid"]
		
		if iid then
			query = "UPDATE inventory_table SET itemid='"..itemID.."' WHERE iid="..tostring(iid)
			result = querySQL(query)
			
			if item.HasStorage then
				query = "INSERT INTO inventory_storage ( iid ) VALUES ('"..tostring(iid).."')"
				result = querySQL(query)
			end
		end
		
		if item.HP then
			ent:SetHealth(tonumber(item.HP))
		end
		
		return iid
	end

	return false
end

--Saves the state of a persist item, location and ply are optional
function PNRP.SaveState(ply, ent, location)	
	if !IsValid(ent) then
		ErrorNoHalt( "[SaveState Error] ENT is nil\n")
		return false
	end
	
	local iid = ent.iid
	local pid
	
	local item = PNRP.SearchItembase( ent )
	if not item then return end
	if not item.SaveState then return false end

	if iid then
		local query, result
		query = "SELECT * FROM inventory_table WHERE iid="..tostring(iid)
		result = querySQL(query)
		
		--ply and location are optional. Will default to its last owner or location if not set.
		if ply then	
			if tostring(ply) == "none" then pid = -1
			else 
				if isstring(ply) then 
					pid = tostring(ply)
				else
					pid = tostring(ply.pid)
				end
			end
		end
		
		if result then
			if pid == -1 or pid == nil then pid = result[1]["pid"] end
			if not location or location == "" then location = result[1]["location"] end
			
			local stateTable = item.BuildState( ent )
			print("PID: "..tostring(pid))
			query = "UPDATE inventory_table SET pid='"..pid.."', location='"..location.."', status_table='"..stateTable.."' WHERE iid="..tostring(iid)
			result = querySQL(query)
		else
			PNRP.AddStatusItem(ply, ent)
		end
		
		resultSID = querySQL("SELECT * FROM inventory_storage WHERE iid="..tostring(iid))
		if not resultSID then
			if item.HasStorage then
				query = "INSERT INTO inventory_storage ( iid ) VALUES ('"..tostring(iid).."')"
				result = querySQL(query)
			end
		end
	else
		iid = PNRP.AddStatusItem(ply, ent)
		ent.iid = iid
	end

end

--Deletes persist item
function PNRP.DelPersistItem(iid)
	local query, result
	
	query = "DELETE FROM inventory_table WHERE iid="..tostring(iid)
	result = querySQL(query)
	
	query = "DELETE FROM inventory_storage WHERE iid="..tostring(iid)
	result = querySQL(query)
end

--Checks for orphaned items in the inventory_storage system
function PNRP.CheckPersistSIDs( sid )
	
	local query, result
	query = "SELECT * FROM inventory_storage WHERE sid="..tostring(sid)
	result = querySQL(query)
	
	if result then return end
	
	query = "DELETE FROM inventory_table WHERE location='inventory_storage' AND locid="..tostring(sid)
	result = querySQL(query)
	
end

--Called when a persistent item is built
function PNRP.BuildPersistantItem(ply, ent, iid)
	if not iid or iid == "" then 
		iid = PNRP.AddStatusItem(ply, ent, "world") 
		ent.iid = iid
	else 
		ent.iid = iid
		PNRP.SetPersistantItemHP(ent)
		PNRP.SaveState(ply, ent, "world")	
	end
	
end

--Returns Persist Item
function PNRP.GetPersistItem(iid)
	local query, result
	
	query = "SELECT * FROM inventory_table WHERE iid="..tostring(iid)
	result = querySQL(query)
	
	return result[1]
end

--Called in PNRP.ReturnWorldCache( ply )
--Returns items left in world by the player
function PNRP.ReturnPersistItems(ply)
	local query, result
	Msg("Eun: ReturnPersistItems \n")
	query = "UPDATE inventory_table SET location='player' WHERE location='world' AND pid="..tostring(ply.pid)
	result = querySQL(query)
end

--Removed any items that were left in world and were not owned
--Also checks to make sure the item is still not spawned
function PNRP.CleanPersistItems()
	local entTbl = ents.GetAll()
	local foundID = {}
	for _, v in pairs(entTbl) do
		if v.iid then
			foundID[v.iid] = tostring(v:GetClass())
		end
	end

	local result = querySQL("SELECT * FROM inventory_table WHERE location='world' AND pid='' OR pid='-1'")
	if result then
		for _, v in pairs(result) do
			local iid = v["iid"]
			if not foundID[iid] then
				querySQL("DELETE FROM inventory_table WHERE iid="..tostring(iid))
			end
		end
	end
end

--EOF