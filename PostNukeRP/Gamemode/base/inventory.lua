PNRP.Items = {}

local PlayerMeta = FindMetaTable("Player")

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
		Persistent = itemtable.Persistent
	}
	
end	

function PNRP.RPSteamID( p )

	return p:UniqueID()
	
end	

function PNRP.Inventory( p )
	local query
	local result
	
	query = "SELECT inventory FROM player_inv WHERE pid="..tostring(p.pid)
	result = sql.Query(query)
--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Select inventory from player_inv wher PID) Error:  "..tostring(sql.LastError()))
	
	if not result then return nil end
	
	local invTbl = {}
	local invLongStr = string.Explode( " ", result[1]["inventory"] )
	for _, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		invTbl[invSplit[1]] = math.Round(tonumber(invSplit[2]) or 0)
	end
	
	return invTbl
end	

function PlayerMeta:HasInInventory( theitem )
	local query
	local result
	
	query = "SELECT inventory FROM player_inv WHERE pid="..tostring(self.pid)
	result = sql.Query(query)
--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Select inventory from player_inv wher PID) Error:  "..tostring(sql.LastError()))
	
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

function PNRP.CarInventory( p )
	local query
	local result
	
	query = "SELECT car_inventory FROM player_inv WHERE pid="..tostring(p.pid)
	result = sql.Query(query)
--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Select inventory from player_inv wher PID) Error:  "..tostring(sql.LastError()))
	
	if not result then return nil end
	
	local invTbl = {}
	local invLongStr = string.Explode( " ", result[1]["car_inventory"] )
	for _, invStr in pairs( invLongStr ) do
		local invSplit = string.Explode( ",", invStr )
		invTbl[invSplit[1]] =  math.Round(tonumber(invSplit[2]) or 0)
	end
	
	return invTbl
end	


function PNRP.OpenMainInventory(ply)	
	local tbl = PNRP.Inventory( ply )
	
	if not tbl then
		tbl = {}
		print("Missing inventory!")
	end
	
	net.Start("pnrp_OpenInvWindow")
		net.WriteTable(tbl)
		net.WriteString(tostring(PNRP.InventoryWeight( ply )))
		net.WriteString(tostring(PNRP.CarInventoryWeight( ply )))
	net.Send(ply)
end
concommand.Add("pnrp_OpenInventory", PNRP.OpenMainInventory)
util.AddNetworkString( "pnrp_OpenInvWindow" )

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

function PNRP.InventoryWeight( p )
	local Inv = PNRP.Inventory( p )
	
	if not Inv then return 0 end
	
	local weightSum = 0
	
	for itemname, item in pairs( PNRP.Items ) do
		for k, v in pairs( Inv ) do
			if k == itemname then
				if PNRP.Items[k].Type ~= "vehicle" then
					weightSum = weightSum + (item.Weight * tonumber(v))
				end
			end
		end
	end
	
	return weightSum
end


function PNRP.OpenMainCarInventory(ply)
	local tbl = PNRP.CarInventory( ply )
	
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
concommand.Add("pnrp_OpenCarInventory", PNRP.OpenMainCarInventory)
util.AddNetworkString( "pnrp_OpenCarInvWindow" )

function PNRP.CarInventoryWeight( p )
	local Inv = PNRP.CarInventory( p )
	
	if not Inv then return 0 end
	
	local weightSum = 0
	
	for itemname, item in pairs( PNRP.Items ) do
		for k, v in pairs( Inv ) do
			if k == itemname then
				if PNRP.Items[k].Type ~= "vehicle" then
					weightSum = weightSum + (item.Weight * tonumber(v))
				end
			end
			
		end
	end
	
	return weightSum
end

function PlayerMeta:AddToInventory( theitem, amount )
	PNRP.AddToInventory( self, theitem, amount )
end
	
function PNRP.AddToInventory( p, theitem, amount )
	local query
	local result
	amount = tonumber(amount)
	if PNRP.Items[theitem] != nil then
		query = "SELECT pid FROM player_inv WHERE pid="..tostring(p.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Check for pid in player_inv) Error:  "..tostring(sql.LastError()))
		
		if result then
			local Inv = PNRP.Inventory( p )
			
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
			
			query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..tostring(p.pid)
			result = sql.Query(query)
		--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
		else
			local Inv = theitem..",1"
			
			query = "INSERT INTO player_inv (pid, inventory) VALUES ("..tostring(p.pid)..", '"..Inv.."')"
			result = sql.Query(query)
		--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (INSERT INTO player_inv ( pid, inventory) ) Error:  "..tostring(sql.LastError()))
		end
	end
end

function PNRP.AddToInvFromCar( p, command, arg )
	local theitem = arg[1]
	
	local weight = PNRP.InventoryWeight( p ) + PNRP.Items[theitem].Weight
	local weightCap
	
	if team.GetName(p:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (p:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (p:GetSkill("Backpacking")*10)
	end
	
	if weight <= weightCap then
		PNRP.AddToInventory( p, theitem, 1 )
		PNRP.TakeFromCarInventory( p, theitem )
	else
		p:ChatPrint("You're pack is too full and cannot carry this.")
		return
	end
	
	p:ConCommand("pnrp_carinv")	
end
concommand.Add( "pnrp_addtoinvfromcar", PNRP.AddToInvFromCar )

function PNRP.AddToInvFromEQ( p, command, arg )
	local theitem = arg[1]
	
	local weight = PNRP.InventoryWeight( p ) + PNRP.Items[theitem].Weight
	local weightCap
	
	--Checks to see if the player has enough ammo to put in pack.
	if command == "pnrp_addtoinvfromceq-ammo" then
		local ammoCount = p:GetAmmoCount(string.sub(theitem, 6))
		if ammoCount < PNRP.Items[theitem].Energy then
			p:ChatPrint("You do not have enough to place in your pack..")
			return
		end
	end
	
	if team.GetName(p:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (p:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (p:GetSkill("Backpacking")*10)
	end
	
	if weight <= weightCap then
		PNRP.AddToInventory( p, theitem, 1 )
		
		if command == "pnrp_addtoinvfromeq" then
			for _, wep in pairs(p:GetWeapons()) do
				if wep:GetClass() == PNRP.Items[theitem].Ent then
					if wep:Clip1() > 0 then
						p:ChatPrint("You've pocketed the magazine.")
						p:GiveAmmo( wep:Clip1(), wep:GetPrimaryAmmoType(), false )
					end
				end
			end
		end
		
	else
		p:ChatPrint("You're pack is too full and cannot carry this.")
		return
	end
	
	if command == "pnrp_addtoinvfromeq" then
		p:ConCommand("pnrp_eqipment")
	elseif command == "pnrp_addtoinvfromceq-ammo" then
		local ammoAmt = PNRP.Items[theitem].Energy
		theitem = string.gsub(theitem, "ammo_", "")
		p:RemoveAmmo( ammoAmt, theitem )
		p:ConCommand("pnrp_eqipment")
	end
	
end
concommand.Add( "pnrp_addtoinvfromeq", PNRP.AddToInvFromEQ )
concommand.Add( "pnrp_addtoinvfromceq-ammo", PNRP.AddToInvFromEQ )

function PNRP.AddToCarInentory( )
	local query
	local result
	
	local ply = net.ReadEntity()
	local command = net.ReadString()
	local theitem = net.ReadString()
	local amt = net.ReadDouble()
	
	if amt <= 0 then amt = 1 end
	
	if PNRP.Items[theitem] != nil then
		query = "SELECT pid FROM player_inv WHERE pid="..tostring(ply.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (Check for pid in player_inv) Error:  "..tostring(sql.LastError()))
		
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
			result = sql.Query(query)
	--		ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
		else
			local Inv = theitem..","..tostring(amt)
			
			query = "INSERT INTO player_inv (pid, car_inventory) VALUES ("..tostring(ply.pid)..", '"..Inv.."')"
			result = sql.Query(query)
	--		ErrorNoHalt(tostring(os.date()).." SQL QUERY: (INSERT INTO player_inv ( pid, car_inventory) ) Error:  "..tostring(sql.LastError()))
		end
		
		for i = 1, amt do
			PNRP.TakeFromInventory( ply, theitem )
		end
		Msg("["..tostring(theitem).."] added to "..ply:Nick().."'s car inventory.  \n")
		ply:ChatPrint(tostring(amt).." "..PNRP.Items[theitem].Name.." stored to your Car's Trunk")
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

function PNRP.TakeFromInventory( p, theitem )
	local query
	local result
	
	local inv = PNRP.Inventory( p )
	
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
		
		query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..tostring(p.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
	end
end

function PNRP.TakeFromInventoryBulk( p, theitem, Count )
	local query
	local result
	local Check = false
	
	local inv = PNRP.Inventory( p )
	
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
		
		query = "UPDATE player_inv SET inventory='"..InvStr.."' WHERE pid="..tostring(p.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
	end
	return Check
end

function PNRP.TakeFromCarInventory( p, theitem )
	local query
	local result
	
	local inv = PNRP.CarInventory( p )
	
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
		
		query = "UPDATE player_inv SET car_inventory='"..InvStr.."' WHERE pid="..tostring(p.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
	end
end

function PNRP.TakeFromCarInventoryBulk( p, theitem, Count )
	local query
	local result
	local Check = false
	
	local inv = PNRP.CarInventory( p )
	
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
		
		query = "UPDATE player_inv SET car_inventory='"..InvStr.."' WHERE pid="..tostring(p.pid)
		result = sql.Query(query)
	--	ErrorNoHalt(tostring(os.date()).." SQL QUERY: (UPDATE player_inv where pid) Error:  "..tostring(sql.LastError()))
	end
	return Check
end

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

function PNRP.ReportWeight( p, c, a )
	p:ChatPrint( "Inventory Weight:  "..tostring(PNRP.InventoryWeight( p )) )
end

concommand.Add( "debug_weight", PNRP.ReportWeight )

function PNRP.UseFromInv()
	local ply = net.ReadEntity()
	local ItemID = net.ReadString()
	
	if PNRP.Items[ItemID] == nil then return end
	local item = PNRP.Items[ItemID]
	if item.Type == "weapon" or item.Type == "ammo" or item.Type == "medical" or item.Type == "food" then
		local useCheck	
		useCheck = item.Use( ply )
		if useCheck == true then
			PNRP.TakeFromInventory( ply, ItemID )
		end
	end	
end
net.Receive( "UseFromInv", PNRP.UseFromInv )

--EOF