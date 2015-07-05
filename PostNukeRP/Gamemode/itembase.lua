--Item Loader Base File Runs Shared (Both client and server)
--Items are loaded from the item folder.

PNRP.Items = {}
PNRP.Weapons = {}

--Gets the Item from the Item folder and adds it to the table
function PNRP.AddItem( itemtable )

	PNRP.Items[itemtable.ID] =
	{
		ID = itemtable.ID,
		Name = itemtable.Name,
		ClassSpawn = itemtable.ClassSpawn,		
		Scrap = itemtable.Scrap,
		SmallParts = itemtable.Small_Parts,
		Chemicals = itemtable.Chemicals,
		Chance = itemtable.Chance,
		Info = itemtable.Info,	
		Type = itemtable.Type,
		Energy = itemtable.Energy,
		Ent = itemtable.Ent,
		Model = itemtable.Model,
		Spawn = itemtable.Spawn,
		Use = itemtable.Use,
		Remove = itemtable.Remove,
		Script = itemtable.Script,
		Weight = itemtable.Weight,
		Create = itemtable.Create,
		ToolCheck = itemtable.ToolCheck,
		ShopHide = itemtable.ShopHide,
		Capacity = itemtable.Capacity,
		ProfileCost = itemtable.ProfileCost,
		Persistent = itemtable.Persistent,
		UnBlock = itemtable.UnBlock,
		AllowPunt = itemtable.AllowPunt,
		SaveState = itemtable.SaveState,
		BuildState = itemtable.BuildState,
		GearSlots = itemtable.GearSlots
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
		MagSize = weptable.MagSize
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
		else pid = result[1]["pid"] end
		
		if not location or location == "" then location = result[1]["location"] end
		
		if result then
			local stateTable = item.BuildState( ent )
			
			query = "UPDATE inventory_table SET pid='"..pid.."', location='"..location.."', status_table='"..stateTable.."' WHERE iid="..tostring(iid)
			result = querySQL(query)
		else
			PNRP.AddStatusItem(ply, ent)
		end
	else
		iid = PNRP.AddStatusItem(ply, ent)
		ent.iid = iid
	end

end

--Deletes persist item
function PNRP.DelPersistItem(iid)
	query = "DELETE FROM inventory_table WHERE iid="..tostring(iid)
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