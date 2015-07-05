
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

--Gets the player's car inventory (Non Persistent items)
function PNRP.CarInventory( ply )
	local query
	local result
	
	query = "SELECT car_inventory FROM player_inv WHERE pid="..tostring(ply.pid)
	result = querySQL(query)
	
	if not result then return nil end
	
	local invTbl = {}
	local invLongStr = string.Explode( " ", result[1]["car_inventory"] )
	for _, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		invTbl[invSplit[1]] =  math.Round(tonumber(invSplit[2]) or 0)
	end
	
	return invTbl
end	

--Gets the car's full inventory including persistent items
function PNRP.GetFullCarInventory( ply )
	local query
	local result

	query = "SELECT car_inventory FROM player_inv WHERE pid="..tostring(ply.pid)
	result = querySQL(query)

	if not result then return nil end
	
	local invTbl = {}
	
	local invLongStr = string.Explode( " ", result[1]["car_inventory"] )
	for i, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		local have = math.Round(tonumber(invSplit[2]) or 0)
		if have > 0 and itemid != "" then
			table.insert( invTbl, {itemid=invSplit[1], status_table="", iid="", count=have} )
		end
	end

	for k, v in pairs(PNRP.PersistInventory( ply )) do
		if v["location"] == "car" then
			table.insert( invTbl, {itemid=v["itemid"], status_table=v["status_table"], iid=v["iid"], count=1} )
		end
	end

	return invTbl
end

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
		net.WriteString(tostring(PNRP.CarInventoryWeight( ply )))
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
		net.WriteString(tostring(PNRP.CarInventoryWeight( ply )))
		net.WriteFloat(weightCap)
	net.Send(ply)
end
concommand.Add("pnrp_initEQ", PNRP.OpenEQWindow)
util.AddNetworkString( "pnrp_OpenEquipmentWindow" )

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

--Opens the player's car invnetory
function PNRP.OpenMainCarInventory(len, pl)
	local ply = net.ReadEntity()
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] OpenMainCarInventory: "..tostring(pl).."\n")
		return 
	end
	
	local tbl = PNRP.GetFullCarInventory( ply )
	
	if not tbl then
		tbl = {}
		print("Missing inventory!")
	end
	
	net.Start("pnrp_OpenCarInvWindow")
		net.WriteTable(tbl)
		net.WriteString(tostring(PNRP.InventoryWeight( ply )))
		net.WriteString(tostring(PNRP.CarInventoryWeight( ply )))
	net.Send(ply)
end
net.Receive("pnrp_OpenCarInventory", PNRP.OpenMainCarInventory);
util.AddNetworkString( "pnrp_OpenCarInventory" )
util.AddNetworkString( "pnrp_OpenCarInvWindow" )

--Gets the Car's weight including persistent items
function PNRP.CarInventoryWeight( ply )
	local Inv = PNRP.CarInventory( ply )
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
		if v["location"] == "car" and PNRP.Items[v["itemid"]] then
			if PNRP.Items[v["itemid"]].Type ~= "vehicle" then
				weightSum = weightSum + PNRP.Items[v["itemid"]].Weight
			end
		end
	end
	
	return weightSum
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

--Adds persistent item to player from car inventory
function PNRP.AddToInvFromCarPersist( len, pl )
	local ply = net.ReadEntity()
	local itemID = net.ReadString()
	local iid = net.ReadString()
	local option = net.ReadString()
	
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] Possible Lua Injection: AddToInvFromCarPersist by "..tostring(pl).."\n")
		return
	end
	
	local weightCheck = PNRP.CheckPlayerWeight(ply, itemID)
	
	if weightCheck then
		PNRP.PersistMoveTo( ply, iid, "player" )
		if option == "carInv" then 
			PNRP.TakeFromCarInventory( ply, itemID )
		end
	else
		ply:ChatPrint("Your pack is too full and cannot carry this.")
		return
	end
	
	ply:ConCommand("pnrp_carinv")	
end
net.Receive("pnrp_AddToInvFromCarPersist", PNRP.AddToInvFromCarPersist );
util.AddNetworkString( "pnrp_AddToInvFromCarPersist" )

--Adds non persistent item to players inventory from car
function PNRP.AddToInvFromCar( len, pl )
	local ply = net.ReadEntity()
	local theitem = net.ReadString()
	
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] Possible Lua Injection: AddToInvFromCar by "..tostring(pl).."\n")
		return
	end
	
	local weightCheck = PNRP.CheckPlayerWeight(ply, theitem)
	
	if weightCheck then
		PNRP.AddToInventory( ply, theitem, 1 )
		PNRP.TakeFromCarInventory( ply, theitem )
	else
		ply:ChatPrint("Your pack is too full and cannot carry this.")
		return
	end
	
	ply:ConCommand("pnrp_carinv")	
end
net.Receive("pnrp_addtoinvfromcar", PNRP.AddToInvFromCar );
util.AddNetworkString( "pnrp_addtoinvfromcar" )

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

--Adds non persistent items to Car inventory
function PNRP.AddToCarInentory( len, ply )
	local query
	local result
	
	local ply = net.ReadEntity()
	local command = net.ReadString()
	local theitem = net.ReadString()
	local amt = net.ReadDouble()
	
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] Possible Lua Injection: AddToCarInentory by "..tostring(pl).."\n")
		return
	end
	
	if amt <= 0 then amt = 1 end
	
	if PNRP.Items[theitem] != nil then
		query = "SELECT pid FROM player_inv WHERE pid="..tostring(ply.pid)
		result = querySQL(query)
		
		if result then
			local Inv = PNRP.CarInventory( ply )
			
			if not Inv then
				Inv = {}
			end
			
			if Inv[theitem] then
				Inv[theitem] = Inv[theitem] + amt
			else
				Inv[theitem] = amt
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
			
			query = "UPDATE player_inv SET car_inventory='"..InvStr.."' WHERE pid="..tostring(ply.pid)
			result = querySQL(query)
		else
			local Inv = theitem..","..tostring(amt)
			
			query = "INSERT INTO player_inv (pid, car_inventory) VALUES ("..tostring(ply.pid)..", '"..Inv.."')"
			result = querySQL(query)
		end
		
		for i = 1, amt do
			PNRP.TakeFromInventory( ply, theitem )
		end
		Msg("["..tostring(theitem).."] added to "..ply:Nick().."'s car inventory.  \n")
		ply:ChatPrint("You have stored "..tostring(amt).." "..PNRP.Items[theitem].Name.." in your vehicle's trunk.")
	end
	if command == "FromEQ" then
		local ammoAmt = PNRP.Items[theitem].Energy
		theitem = string.gsub(theitem, "ammo_", "")
		ply:RemoveAmmo( ammoAmt, theitem )
	end
	
	if command ~= "FromEQ" then
		ply:ConCommand("pnrp_inv")
	end
end
net.Receive( "pnrp_addtocarinentory", PNRP.AddToCarInentory )

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

--Removes non persistent item from Car Inventory
function PNRP.TakeFromCarInventory( ply, theitem )
	local query
	local result
	
	local inv = PNRP.CarInventory( ply )
	
	if not inv then
		ErrorNoHalt("No inventory under PID!")
		return
	end
	
	if inv[theitem] ~= nil then
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
		
		query = "UPDATE player_inv SET car_inventory='"..InvStr.."' WHERE pid="..tostring(ply.pid)
		result = querySQL(query)
	end
end

--Bulk remove non persistent items from Car invnetory
function PNRP.TakeFromCarInventoryBulk( ply, theitem, Count )
	local query
	local result
	local Check = false
	
	local inv = PNRP.CarInventory( ply )
	
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
		
		query = "UPDATE player_inv SET car_inventory='"..InvStr.."' WHERE pid="..tostring(ply.pid)
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

function NetDropPersistItem(len, pl)
	ply = net.ReadEntity()
	itemID = net.ReadString()
	iid = net.ReadString()
	option = net.ReadString()
	
	if pl ~= ply then 
		ErrorNoHalt("[ALERT] NetDropPersistItem: "..tostring(pl).."\n")
		return 
	end
	
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
function PNRP.UseFromInv(len, pl)
	local ply = net.ReadEntity()
	local ItemID = net.ReadString()
	
	if ply ~= pl then 
		ErrorNoHalt( "[ALERT] Possible Lua Injection: UseFromInv by "..tostring(pl).."\n")
		return 
	end
	
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

--debug weight report
function PNRP.ReportWeight( ply, c, a )
	ply:ChatPrint( "Inventory Weight:  "..tostring(PNRP.InventoryWeight( ply )) )
end
concommand.Add( "debug_weight", PNRP.ReportWeight )
--EOF