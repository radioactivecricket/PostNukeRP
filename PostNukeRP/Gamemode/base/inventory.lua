
local PlayerMeta = FindMetaTable("Player")

function PNRP.RPSteamID( ply )

	return ply:UniqueID()
	
end	

--Gets inventory from the player (Non persistent items)
--ply can have profile id passed into it
function PNRP.Inventory( ply )
	local query
	local result
	
	if not ply then return {} end
	
	local pid
	if isstring(ply) then 
		pid = tostring(ply)
	else
		pid = tostring(ply.pid)
	end

	query = "SELECT inventory FROM player_inv WHERE pid="..pid
	result = querySQL(query)

	if not result then return nil end
	
	local invTbl = {}
	
	local invLongStr = string.Explode( " ", result[1]["inventory"] )
	for i, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		local count = math.Round(tonumber(invSplit[2]) or 0)
		if count > 0 and itemid != "" then
			invTbl[invSplit[1]] = count
		end
	end

	return invTbl
end	

function PNRP.GetFullInventoryPID( pid )
	local query
	local result

	query = "SELECT inventory FROM player_inv WHERE pid="..tostring(pid)
	result = querySQL(query)
	
	local invTbl = {}
	
	if result then
		local invLongStr = string.Explode( " ", result[1]["inventory"] )
		for i, invStr in pairs( invLongStr ) do
			local invSplit = string.Explode( ",", invStr )
			local have = math.Round(tonumber(invSplit[2]) or 0)
			if have > 0 and itemid != "" then
				table.insert( invTbl, {itemid=invSplit[1], status_table="", iid="", count=have} )
			end
		end
	end
	
	query = "SELECT * FROM inventory_table WHERE pid="..tostring(pid)
	result = querySQL(query)
	if result then
		for k, v in pairs(result) do
			if v["location"] == "player" then
				table.insert( invTbl, {itemid=v["itemid"], status_table=v["status_table"], iid=v["iid"], count=1} )
			end
		end
	end

	return invTbl
end

--Gets the players full inventory including persistent items
function PNRP.GetFullInventory( ply )
	local query
	local result

	query = "SELECT inventory FROM player_inv WHERE pid="..tostring(ply.pid)
	result = querySQL(query)

	if not result then return nil end
	
	local invTbl = {}
	
	local invLongStr = string.Explode( " ", result[1]["inventory"] )
	for i, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		local have = math.Round(tonumber(invSplit[2]) or 0)
		if have > 0 and itemid != "" then
			table.insert( invTbl, {itemid=invSplit[1], status_table="", iid="", count=have} )
		end
	end

	for k, v in pairs(PNRP.PersistInventory( ply )) do
		if v["location"] == "player" then
			table.insert( invTbl, {itemid=v["itemid"], status_table=v["status_table"], iid=v["iid"], count=1} )
		end
	end

	return invTbl
end

--Returns Table[ID] = count
--Mainly used for tool checks and such
function PNRP.GetFullInventorySimple( ply )
	local invTbl = PNRP.Inventory( ply )
	
	if not invTbl then invTbl = {} end
	
	for _, v in pairs(PNRP.PersistInventory( ply )) do
		if v["location"] == "player" then
			if invTbl[v["itemid"]] then
				invTbl[v["itemid"]] = invTbl[v["itemid"]] + 1
			else
				invTbl[v["itemid"]] = 1
			end
		end
	end
	
	return invTbl
end



function PNRP.GetFullInvStorageSimple( sid )
	local invStorageTbl = PNRP.GetStorageInventory( sid )
	local invTbl = invStorageTbl["inv"]
	
	if not invTbl then invTbl = {} end
	
	local inv = {}
	for _, v in pairs(invTbl) do
		if invTbl[v["itemid"]] then
			inv[v["itemid"]] = v["count"] + tonumber(v["count"])
		else
			inv[v["itemid"]] = tonumber(v["count"])
		end
		
	end
	
	return inv
end

--Gets all the persist items owned by the player
function PNRP.PersistInventory( ply )
	local query
	local result
	
	query = "SELECT * FROM inventory_table WHERE pid="..tostring(ply.pid)
	result = querySQL(query)
	
	if not result then result = {} end
	
	return result
end

--Gets all the persist items in other location such as vendor or storage
function PNRP.PersistOtherInventory( location, locID )
	local query
	local result
		
	query = "SELECT * FROM inventory_table WHERE location='"..location.."' AND locid="..tostring(locID)
	result = querySQL(query)
	
	if not result then result = {} end
	
	return result
end

--If the player has the item in inventory (Non persistent Items)
function PlayerMeta:HasInInventory( theitem )
	local query
	local result
	
	query = "SELECT inventory FROM player_inv WHERE pid="..tostring(self.pid)
	result = querySQL(query)
	
	if not result then return nil end
	
	local invTbl = {}
	local invLongStr = string.Explode( " ", result[1]["inventory"] )
	for _, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		invTbl[invSplit[1]] = tonumber(invSplit[2])
	end
	
	if invTbl[theitem] ~= nil then
		if invTbl[theitem] >0 then
			return true
		else
			return false
		end
	else
		return false
	end
	
end

--Gets a persistent items inventory if it exists
function PNRP.GetIIDtoSIDInvnetory( iid )
	local query, result
	
	query = "SELECT * FROM inventory_storage WHERE iid="..tostring(iid)
	result = querySQL(query)
	
	if not result then return {} end
	
	local sid = result[1]["sid"]
	local invTbl = PNRP.GetStorageInventory( sid )
	
	if not invTbl then invTbl = {} end
	
	return invTbl
end

--This gets the inventory of a storage item (something flagged as HasStorage in itembase)
--This is not currently used in player storage but it may get migrated to this later.
--Persistent Item System
function PNRP.GetNPStorageInventory( sid )
	local result, query
	
	query = "SELECT * FROM inventory_storage WHERE sid="..tostring(sid)
	result = querySQL(query)
	
	--if no sid then there should not be any related items stored in it
	if not result then 
		PNRP.CheckPersistSIDs( sid )
		return {} 
	end
	
	local invTbl = {}
	
	local invLongStr = string.Explode(" ", result[1]["inventory"] )
	for _, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		local have = math.Round(tonumber(invSplit[2]) or 0)
		if have > 0 and itemid != "" then
			table.insert( invTbl, {itemid=invSplit[1], status_table="", iid="", count=have, sid=sid} )
		end
	end
	
	return invTbl
end
function PNRP.GetStorageInventory( sid )
		
	local invTbl = PNRP.GetNPStorageInventory( sid )
	
	local query, result
	
	query = "SELECT * FROM inventory_table WHERE location='inventory_storage' AND locid="..tostring(sid)
	result = querySQL(query)
	
	if not result then result = {} end
	for k, v in pairs(result) do
		if v["location"] == "inventory_storage" then
			table.insert( invTbl, {itemid=v["itemid"], status_table=v["status_table"], iid=v["iid"], count=1, sid=sid} )
		end
	end
	
	local returnTbl = {}
	returnTbl["sid"] = sid
	returnTbl["inv"] = invTbl
	
	return returnTbl
	
end

--New Persistent Item Inventory
function PNRP.OpenItemInventory( iid, ply, itemID )
	local invStorageTbl = PNRP.GetIIDtoSIDInvnetory( iid )
	
	if not invStorageTbl then
		invTbl = {}
		print("[OpenItemInventory] Missing per inventory!")
		return
	end
	
	local sid = invStorageTbl["sid"]
	local invTbl = invStorageTbl["inv"]
	local plyInvTbl = PNRP.GetFullInventory( ply )
	
	if not invTbl then invTbl = {} end
	
	if not plyInvTbl then
		plyInvTbl = {}
		print("[OpenItemInventory] Missing ply inventory!")
	end
	
	if not itemID then 
		local getItem = PNRP.GetPersistItem(iid)
		itemID = getItem["itemid"]
	end
	
	local capacity = PNRP.Items[itemID].Capacity
	if not capacity then capacity = 0 end
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	net.Start("pnrp_OpenItemStorageWindow")
		net.WriteString(itemID)
		net.WriteTable(invTbl)
		net.WriteTable(plyInvTbl)
		net.WriteString(tostring(PNRP.InventoryWeight( ply )))
		net.WriteString(tostring(PNRP.StorageInventoryWeight( iid )))
		net.WriteString(tostring(weightCap))
		net.WriteString(tostring(capacity))
		net.WriteString(tostring(sid))
		net.WriteString(tostring(iid))
	net.Send(ply)
end
util.AddNetworkString( "pnrp_OpenItemStorageWindow" )

--Opens the player's Inventory Window
function PNRP.OpenMainInventory(ply)	
	local tbl = PNRP.GetFullInventory( ply )
	
	if not tbl then
		tbl = {}
		print("Missing inventory!")
	end
	if not tbl2 then tbl2 = {} end
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	net.Start("pnrp_OpenInvWindow")
		net.WriteTable(tbl)
		net.WriteString(tostring(PNRP.InventoryWeight( ply )))
		net.WriteString(tostring(weightCap))
	net.Send(ply)
end
concommand.Add("pnrp_OpenInventory", PNRP.OpenMainInventory)
util.AddNetworkString( "pnrp_OpenInvWindow" )

--Opens the player's Equipment Menu
function PNRP.OpenEQWindow(ply)
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	net.Start("pnrp_OpenEquipmentWindow")
		net.WriteEntity(ply)
		net.WriteString(tostring(PNRP.InventoryWeight( ply )))
		net.WriteFloat(weightCap)
	net.Send(ply)
end
concommand.Add("pnrp_initEQ", PNRP.OpenEQWindow)
util.AddNetworkString( "pnrp_OpenEquipmentWindow" )

--Gets the total weight of items stored in inventory_storage and persistent
function PNRP.StorageInventoryWeight( iid )
	local invStorageTbl = PNRP.GetIIDtoSIDInvnetory( iid )
	
	if not invStorageTbl then return 0 end
	
	local Inv = invStorageTbl["inv"]
	if not Inv then return 0 end
	
	local weightSum = 0
	
	for k, v in pairs(Inv) do
		if PNRP.Items[v["itemid"]] then
			if PNRP.Items[v["itemid"]].Type ~= "vehicle" then
				weightSum = weightSum + PNRP.Items[v["itemid"]].Weight * tonumber(v["count"])
			end
		end
	end
	
	return weightSum
end

--Gets the players total carried weight including persistent items
function PNRP.InventoryWeight( ply )
	local Inv = PNRP.Inventory( ply )
	local Inv2 = PNRP.PersistInventory( ply )
	
	if not Inv then return 0 end
	
	local weightSum = 0
	
	for ID, count in pairs( Inv ) do
		if PNRP.Items[ID] then
			if PNRP.Items[ID].Type ~= "vehicle" then
				weightSum = weightSum + (PNRP.Items[ID].Weight * tonumber(count))
			end
		end
	end
	
	for k, v in pairs(Inv2) do
		if v["location"] == "player" and PNRP.Items[v["itemid"]] then
			if PNRP.Items[v["itemid"]].Type ~= "vehicle" then
				weightSum = weightSum + PNRP.Items[v["itemid"]].Weight
			end
		end
	end

	return weightSum
end

--Checks the players weight
function PNRP.CheckPlayerWeight(ply, theitem)
	
	local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[theitem].Weight
	local weightCap
	
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	if weight <= weightCap then
		return true
	end
	
	return false
end

--Advanced weight check for Storage Items
--Will return the amount that will fit in the item
function PNRP.CheckStorageWeightAdv(iid, theitem, amount)
	local itmWeight = PNRP.Items[theitem].Weight
	local curWeight = PNRP.StorageInventoryWeight( iid )
	local perItm = PNRP.GetPersistItem(iid)
	local weightCap = PNRP.Items[perItm["itemid"]].Capacity
	local weight = 0
	
	--Vehicle weight override
	if PNRP.Items[theitem].Type == "vehicle" then return amount end
	
	weight = itmWeight * amount
	
	if weight+curWeight > weightCap then
		
		local RemainingW = weightCap - curWeight
		if RemainingW >= 1 then
			amount = RemainingW / itmWeight
			amount = math.floor(amount)
		else
			amount = 0
		end
	end
	
	return amount
end

--Advanced weight check for Player Inventory
--Will return the amount that will fit in the item
function PNRP.CheckPlayerWeightAdv(ply, theitem, amount)
	local itmWeight = PNRP.Items[theitem].Weight
	local curWeight = PNRP.InventoryWeight( ply ) + itmWeight
	local weightCap
	local weight = 0
	
	--Vehicle weight override
	if PNRP.Items[theitem].Type == "vehicle" then return amount end
	
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	weight = itmWeight * amount
	if weight+curWeight > weightCap then
		local RemainingW = weightCap - curWeight
		if RemainingW >= 1 then
			amount = RemainingW / itmWeight
			amount = math.floor(amount)
		else
			amount = 0
		end
	end
	
	return amount
end

function PlayerMeta:AddToInventory( theitem, amount )
	PNRP.AddToInventory( self, theitem, amount )
end

--Adds non persistent item to players inventory
function PNRP.AddToInventory( ply, theitem, amount, ent )
	local query
	local result
	
	local pid
	if isstring(ply) then 
		pid = tostring(ply)
	else
		pid = tostring(ply.pid)
	end
	
	amount = tonumber(amount)
	if PNRP.Items[theitem] != nil then
		if PNRP.Items[theitem].SaveState and ent then
			
			PNRP.SaveState(pid, ent, "player")

		else
			query = "SELECT pid FROM player_inv WHERE pid="..tostring(pid)
			result = querySQL(query)
			
			if result then
				local Inv = PNRP.Inventory( pid )
				
				if not Inv then
					Inv = {}
				end
				
				if Inv[theitem] then
					Inv[theitem] = Inv[theitem] + amount
				else
					Inv[theitem] = amount
				end
				
				local InvHalfString = {}
				for item, amount in pairs(Inv) do
					table.insert(InvHalfString, item..","..tostring(amount))
				end
				local InvStr = ""
				for _, hstring in pairs(InvHalfString) do
					InvStr = InvStr..hstring.." "
				end
				InvStr = string.TrimRight(InvStr)
				
				query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..tostring(pid)
				querySQL(query)
			else
				local Inv = theitem..",1"
				
				query = "INSERT INTO player_inv (pid, inventory) VALUES ("..tostring(pid)..", '"..Inv.."')"
				result = querySQL(query)
			end
		end
	end
end

--Adds to inventory from Equipment (non persistent items)
function PNRP.AddToInvFromEQ( len, pl )
	local ply = net.ReadEntity()
	local command = net.ReadString()
	local theitem = net.ReadString()
	
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] Possible Lua Injection: AddToInvFromEQ by "..tostring(pl).."\n")
		return
	end
	
	local weight = PNRP.InventoryWeight( ply ) + PNRP.Items[theitem].Weight
	local weightCap
	
	--Checks to see if the player has enough ammo to put in pack.
	if command == "pnrp_addtoinvfromceq-ammo" then
		local ammoCount = ply:GetAmmoCount(string.sub(theitem, 6))
		if ammoCount < PNRP.Items[theitem].Energy then
			ply:ChatPrint("You do not have enough to place in your pack.")
			return
		end
	end
	
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	if weight <= weightCap then
		PNRP.AddToInventory( ply, theitem, 1 )
		
		if command == "pnrp_addtoinvfromeq" then
			for _, wep in pairs(ply:GetWeapons()) do
				if wep:GetClass() == PNRP.Items[theitem].Ent then
					if wep:Clip1() > 0 then
						ply:ChatPrint("You've pocketed the magazine.")
						ply:GiveAmmo( wep:Clip1(), wep:GetPrimaryAmmoType(), false )
					end
				end
			end
		end
		
	else
		ply:ChatPrint("Your pack is too full and cannot carry this.")
		return
	end
	
	if command == "pnrp_addtoinvfromeq" then
		ply:ConCommand("pnrp_eqipment")
	elseif command == "pnrp_addtoinvfromceq-ammo" then
		local ammoAmt = PNRP.Items[theitem].Energy
		theitem = string.gsub(theitem, "ammo_", "")
		ply:RemoveAmmo( ammoAmt, theitem )
		ply:ConCommand("pnrp_eqipment")
	end
	
end
net.Receive( "pnrp_addtoinvfromeq", PNRP.AddToInvFromEQ )
util.AddNetworkString( "pnrp_addtoinvfromeq" )

function PNRP.TakeFromItemStorage(sid, theitem, amount)
	local query, result
	
	local AdvInv = PNRP.GetNPStorageInventory( sid )
	
	if not AdvInv then
		AdvInv = {}
	end
	
	local inv = {}
	for _, v in pairs(AdvInv) do
		inv[v["itemid"]] = v["count"]
	end
	
	if inv[theitem] ~= nil then
		if inv[theitem] < amount then
			amount = 0
		elseif inv[theitem]-amount > 0 then
			inv[theitem] = inv[theitem] - amount
		else 
			inv[theitem] = nil
		end
		
		local InvStr = ""
		for item, amount in pairs(inv) do
			InvStr = InvStr..item..","..tostring(amount).." "
		end
		
		InvStr = string.TrimRight(InvStr)
		print(InvStr)
		query = "UPDATE inventory_storage SET inventory='"..InvStr.."' WHERE sid="..tostring(sid)
		result = querySQL(query)
	else
		amount = 0
	end
	
	return amount
end

function PNRP.AddToItemStorage(sid, itemID, amount, iid)
	if not sid then return end
	if amount <= 0 then amount = 1 end
	
	local theitem = PNRP.Items[itemID]
	if not theitem then return end
	
	if iid and iid ~= "" and tostring(iid) ~= "nil"  then
		PNRP.PersistMoveTo( nil, iid, "inventory_storage", sid )
	else
		local AdvInv = PNRP.GetNPStorageInventory( sid )
		
		if not AdvInv then
			AdvInv = {}
		end
		
		local Inv = {}
		for _, v in pairs(AdvInv) do
			Inv[v["itemid"]] = v["count"]
		end
		
		if Inv[itemID] then
			Inv[itemID] = Inv[itemID] + amount
		else
			Inv[itemID] = amount
		end
		
		local InvStr = ""
		for item, amount in pairs(Inv) do
			InvStr = InvStr..item..","..tostring(amount).." "
		end

		InvStr = string.TrimRight(InvStr)
		
		query = "UPDATE inventory_storage SET inventory='"..InvStr.."' WHERE sid="..tostring(sid)
		result = querySQL(query)
	end
	
	return true
end

function PNRP.PlyInvAddToItemStorage(len, ply)
	local itemID = net.ReadString()
	local amount = net.ReadDouble()
	local iid = net.ReadString()
	local sid = net.ReadString()
	local origin_iid = net.ReadString()
	
	if not sid then return end
	if amount <= 0 then amount = 1 end

	local theitem = PNRP.Items[itemID]
	if not theitem then return end
	
	if theitem.HasStorage then
		ply:ChatPrint("You can not store your "..theitem.Name.." in another storage item.")
		return
	end
	
	local haveItem = true
	
	local amount = PNRP.CheckStorageWeightAdv(origin_iid, itemID, amount)
	
	if amount < 1 then
		ply:ChatPrint("Not enough space for "..tostring(theitem.Name))
		return
	end
	
	if iid and iid ~= "" and tostring(iid) ~= "nil"  then
		if not PNRP.AddToItemStorage(sid, itemID, amount, iid) then return end
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
		
	else
		
		--Makes sure the player has enough of this item
		local pInv = PNRP.Inventory( tostring(ply.pid) )
		if not pInv then haveItem = false end
		if pInv[itemID] < amount then haveItem = false end
		if not haveItem then
			ply:ChatPrint("You do not have enough of this.")
			return
		end
		
		if not PNRP.AddToItemStorage(sid, itemID, amount, iid) then return end
		
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
		
		for i = 1, amount do
			PNRP.TakeFromInventory( ply, itemID )
		end
	end
	
	ply:ChatPrint("You have stored "..tostring(amount).." "..theitem.Name)
	if origin_iid then
		PNRP.OpenItemInventory( origin_iid, ply )
	end
end
net.Receive( "pnrp_PlyInvAddToItemStorage", PNRP.PlyInvAddToItemStorage )
util.AddNetworkString( "pnrp_PlyInvAddToItemStorage" )

function PNRP.PlyInvTakeFromItemStorage(len, ply)
	local itemID = net.ReadString()
	local amount = net.ReadDouble()
	local iid = net.ReadString()
	local sid = net.ReadString()
	local origin_iid = net.ReadString()
	
	if not sid then return end
	if amount <= 0 then amount = 1 end

	local theitem = PNRP.Items[itemID]
	if not theitem then return end
		
	if iid and iid ~= "" and tostring(iid) ~= "nil"  then
		
		local weightCheck = PNRP.CheckPlayerWeight(ply, itemID)
		if weightCheck or theitem.Type == "vehicle"  then
			PNRP.PersistMoveTo( ply, iid, "player" )
			ply:ChatPrint("You have removed "..tostring(amount).." "..theitem.Name)
		else
			ply:ChatPrint("Your pack is too full and cannot carry this.")	
		end
	else
		amount = PNRP.CheckPlayerWeightAdv(ply, itemID, amount)
		if amount > 0 then
			amount = PNRP.TakeFromItemStorage(sid, itemID, amount)
			PNRP.AddToInventory( ply, itemID, amount )
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			ply:ChatPrint("You have removed "..tostring(amount).." "..theitem.Name)
		else
			ply:ChatPrint("Your pack is too full and cannot carry this.")
		end
	end
	
	
	if origin_iid then
		PNRP.OpenItemInventory( origin_iid, ply )
	end
end
net.Receive( "pnrp_PlyInvTakeFromItemStorage", PNRP.PlyInvTakeFromItemStorage )
util.AddNetworkString( "pnrp_PlyInvTakeFromItemStorage" )

--Just a easy function for multiple deletes of non persist items
function PNRP.PlyDelItem( pid, theitem, amt )
	
	for i = 1, amt do
		PNRP.TakeFromInventory( pid, theitem )
	end
	
end

--Removes non persistent item from player inventory
--ply var can also be the profile ID
function PNRP.TakeFromInventory( ply, theitem )
	local query
	local result
	
	local inv = PNRP.Inventory( ply )
	
	if not inv then
		ErrorNoHalt("No inventory under PID!")
		return
	end
	
	if inv[theitem] ~= nil then
		local pid
		if isstring(ply) then 
			pid = tostring(ply)
		else
			pid = tostring(ply.pid)
		end
		
		if inv[theitem] > 1 then
			inv[theitem] = inv[theitem] - 1
		else
			inv[theitem] = nil
		end
		
		local InvHalfString = {}
		for item, amount in pairs(inv) do
			table.insert(InvHalfString, item..","..tostring(amount))
		end
		local InvStr = ""
		for _, hstring in pairs(InvHalfString) do
			InvStr = InvStr..hstring.." "
		end
		InvStr = string.TrimRight(InvStr)
		
		query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..pid
		result = querySQL(query)
	end
end

--Bulk take non persistent items from player inventory
function PNRP.TakeFromInventoryBulk( ply, theitem, Count )
	local query
	local result
	local Check = false
	
	local inv = PNRP.Inventory( ply )
	
	if not inv then
		ErrorNoHalt("No inventory under PID!")
		return
	end
	
	if inv[theitem] ~= nil then
		if inv[theitem] > Count then
			inv[theitem] = inv[theitem] - Count
			Check = true
		else
			if inv[theitem] == Count then
				inv[theitem] = nil
				Check = true
			else
				Check = false
				return false
			end
		end
		
		local InvHalfString = {}
		for item, amount in pairs(inv) do
			table.insert(InvHalfString, item..","..tostring(amount))
		end
		local InvStr = ""
		for _, hstring in pairs(InvHalfString) do
			InvStr = InvStr..hstring.." "
		end
		InvStr = string.TrimRight(InvStr)
		
		query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..tostring(ply.pid)
		result = querySQL(query)
	end
	return Check
end

--Construction of Persistent Item in world
function PNRP.DropPersistItem( ply, itemID, iid, option )
	--Second Check in case anything is nil
	if (not ply) or (not itemID) then return end

	if option == "playerInv" then 
		PNRP.TakeFromInventoryBulk( ply, itemID, 1 )
	elseif option == "carInv" then
		PNRP.TakeFromCarInventoryBulk( ply, itemID, 1 )
	end
	
	local plUID = PNRP:GetUID( ply )
	local item = PNRP.Items[itemID]
	
	if not item then return end
	ply:ChatPrint("Dropping "..item.Name)
	ply:EmitSound(Sound("items/ammo_pickup.wav"))
	
	--If the item is not longer set to Save State
	--This will delete it from the table
	if not item.SaveState then
		PNRP.DelPersistItem(iid)
	end
	
	local tr = ply:TraceFromEyes(200)
	local pos = tr.HitPos + Vector(0,0,20)
	local ent = item.Create(ply, item.Ent, pos, iid)
	
end

function NetDropPersistItem(len, ply)
	itemID = net.ReadString()
	iid = net.ReadString()
	option = net.ReadString()
	
	local query, result
	query = "SELECT * FROM inventory_table where pid='"..tostring(ply.pid).."'"
	result = querySQL(query)
	
	if not result then 
		ErrorNoHalt("[ALERT] Player does not own item: NetDropPersistItem by "..tostring(ply).."\n")
		return
	end
	
	PNRP.DropPersistItem( ply, itemID, iid, option )
end
net.Receive( "pnrp_DropPersistItem", NetDropPersistItem )
util.AddNetworkString( "pnrp_DropPersistItem" )

--Moves location of persistent items, some vars optional based on location
function PNRP.PersistMoveTo( ply, iid, location, locid, locdata )	

	if (not iid) or (not location) then return end
	if not locid then locid = '' end
	if not locdata then locdata = '' end
	
	if iid then
		query = "UPDATE inventory_table SET location='"..location.."', locid='"..locid.."', locdata='"..locdata.."' WHERE iid="..tostring(iid)
		
		if location == "storage" or location == "vendor" or location == "locker" then
			query = "UPDATE inventory_table SET location='"..location.."', locid='"..locid.."', locdata='"..locdata.."', pid='' WHERE iid="..tostring(iid) 
		elseif location == "player" and IsValid(ply) then
			query = "UPDATE inventory_table SET location='"..location.."', locid='', locdata='', pid='"..tostring(ply.pid).."' WHERE iid="..tostring(iid)
		end
		
		result = querySQL(query)
		
		if IsEntity(ply) then
			if ply:IsPlayer() then ply:EmitSound(Sound("items/ammo_pickup.wav")) end
		end
	end
	Msg("Send ID: "..tostring(iid).." to "..tostring(location).."\n")
end

function NetPersistMoveTo(len, ply)
	iid = net.ReadString()
	location = net.ReadString()
	locid = net.ReadString()
	
	local query, result
	query = "SELECT * FROM inventory_table where pid='"..tostring(ply.pid).."'"
	result = querySQL(query)
	
	if not result then 
		ErrorNoHalt("[ALERT] Player does not own item: NetPersistMoveTo by "..tostring(ply).."\n")
		return
	end
	
	PNRP.PersistMoveTo( ply, iid, location, locid )
end
net.Receive( "pnrp_PersistMoveTo", NetPersistMoveTo )
util.AddNetworkString( "pnrp_PersistMoveTo" )

--Drops the item (non persistent)
function PNRP.DropItem( p, c, a )	
	local inv = PNRP.Inventory( p )	
	for itemname, item in pairs( PNRP.Items ) do	
		for k, v in pairs( inv ) do		
			if k == itemname && k == a[1] then
			
				PNRP.DropSpawn(p, itemname, 1)

			end		
		end	
	end	
end
concommand.Add( "inventory_drop", PNRP.DropItem )

--Drops the item from car(non persistent)
function PNRP.DropCarItem( p, c, a )
	local inv = PNRP.CarInventory( p )
	
	for itemname, item in pairs( PNRP.Items ) do
		for k, v in pairs( inv ) do	
			if k == itemname && k == a[1] then
			
				PNRP.DropCarSpawn(p, itemname, 1)

			end			
		end		
	end	
end
concommand.Add( "carinventory_drop", PNRP.DropCarItem )

--Use item from inventory (non persistent items)
function PNRP.UseFromInv(len, ply)
	local ItemID = net.ReadString()
	
	if PNRP.Items[ItemID] == nil then return end
	local item = PNRP.Items[ItemID]
	
	local plyInv = PNRP.Inventory( ply )
	if not plyInv[ItemID] then return end
	
	if item.Type == "weapon" or item.Type == "ammo" or item.Type == "medical" or item.Type == "food" then
		local useCheck	
		useCheck = item.Use( ply )
		if useCheck == true then
			PNRP.TakeFromInventory( ply, ItemID )
		end
	end	
end
net.Receive( "UseFromInv", PNRP.UseFromInv )

function PNRP.UseFromInvStoreage(len, ply)
	local usedFrom = net.ReadString()
	local ItemID = net.ReadString()
	local sid = net.ReadString()
	local origin_iid = net.ReadString()
	
	local item = PNRP.Items[ItemID]
	if not item then return end
	
	if usedFrom == "storage" then
		--Makes sure the player has the item
		local invTbl = PNRP.GetFullInvStorageSimple( sid )
		
		if not invTbl then 
			ply:ChatPrint("You don't have enough of this.")
			return 
		end
		if not invTbl[ItemID] then
			ply:ChatPrint("You don't have enough of this.")
			return 
		end
		
		if item.Type == "weapon" or item.Type == "ammo" or item.Type == "medical" or item.Type == "food" then
			local useCheck	
			useCheck = item.Use( ply )
			if useCheck == true then
				PNRP.TakeFromItemStorage(sid, ItemID, 1)
			end
		else
			ply:ChatPrint("Cant use this, wrong type.")
		end	
	
	elseif usedFrom == "player" then
		--Make sure the player has the item
		local invTbl = PNRP.GetFullInventorySimple( ply )
		if not invTbl then 
			ply:ChatPrint("You don't have enough of this.")
			return 
		end
		if not invTbl[ItemID] then
			ply:ChatPrint("You don't have enough of this.")
			return 
		end
		
		if item.Type == "weapon" or item.Type == "ammo" or item.Type == "medical" or item.Type == "food" then
			local useCheck	
			useCheck = item.Use( ply )
			if useCheck == true then
				PNRP.TakeFromInventory( ply, ItemID )
			end
		else
			ply:ChatPrint("Cant use this, wrong type.")
		end	
	end
	
	if origin_iid then
		PNRP.OpenItemInventory( origin_iid, ply )
	end
end
net.Receive( "UseFromInvStoreage", PNRP.UseFromInvStoreage )
util.AddNetworkString( "UseFromInvStoreage" )

--debug weight report
function PNRP.ReportWeight( ply, c, a )
	ply:ChatPrint( "Inventory Weight:  "..tostring(PNRP.InventoryWeight( ply )) )
end
concommand.Add( "debug_weight", PNRP.ReportWeight )
--EOF