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
	}
	
end	

function PNRP.RPSteamID( p )

	return p:UniqueID()
	
end	


function PNRP.GetInventoryLocation( p )

	return "PostNukeRP/inventory/"..PNRP.RPSteamID( p )..".txt"
	
end	


function PNRP.GetCarInventoryLocation( p )

	return "PostNukeRP/inventory/"..PNRP.RPSteamID( p ).."_car.txt"
	
end	
	

function PNRP.Inventory( p )
	
	local ILoc = PNRP.GetInventoryLocation( p )
	
	if !file.Exists( ILoc ) then print( "Inventory file doesn't exist !" ) return end	
	
	local decoded = util.KeyValuesToTable( file.Read( ILoc ) )	
	
	return decoded
	
end	

function PlayerMeta:HasInInventory( theitem )
	local ILoc = PNRP.GetInventoryLocation( self )		
	
	if !file.Exists( ILoc ) then return false end
	
	local decoded = PNRP.Inventory( self )		

	if decoded[theitem] != nil then
	
		if decoded[theitem] > 0 then
		
			return true
		
		else
			
			return false
			
		end
		
	else
		
		return false

	end	
end

function PNRP.CarInventory( p )
	
	local ILoc = PNRP.GetCarInventoryLocation( p )
	
	if !file.Exists( ILoc ) then print( "Car Inventory file doesn't exist !" ) return end	
	
	local decoded = util.KeyValuesToTable( file.Read( ILoc ) )	
	
	return decoded
	
end	


function PNRP.OpenMainInventory(ply)
	
	local ILoc = PNRP.GetInventoryLocation( ply )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	local tbl = { }
	if !file.Exists( ILoc ) then 
		print( "Inventory file doesn't exist !" ) 
		datastream.StreamToClients(ply, "pnrp_OpenInvWindow", { ["inventory"] = tbl, ["playerweight"] = tostring(PNRP.InventoryWeight( ply )), ["carweight"] = tostring(PNRP.CarInventoryWeight( ply )) })
		--datastream.StreamToClients(ply, "pnrp_OpenInvWindow", { tbl, tostring(PNRP.InventoryWeight( ply )), tostring(PNRP.CarInventoryWeight( ply )) })
	else
		tbl = util.KeyValuesToTable(file.Read(ILoc))
		datastream.StreamToClients(ply, "pnrp_OpenInvWindow", { ["inventory"] = tbl, ["playerweight"] = tostring(PNRP.InventoryWeight( ply )), ["carweight"] = tostring(PNRP.CarInventoryWeight( ply )) })
		--datastream.StreamToClients(ply, "pnrp_OpenInvWindow", { tbl, tostring(PNRP.InventoryWeight( ply )), tostring(PNRP.CarInventoryWeight( ply )) })
	end
	

end
concommand.Add("pnrp_OpenInventory", PNRP.OpenMainInventory)

function PNRP.OpenEQWindow(ply)

	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	datastream.StreamToClients(ply, "pnrp_OpenEquipmentWindow", { tostring(PNRP.InventoryWeight( ply )), tostring(PNRP.CarInventoryWeight( ply )), weightCap })
end
concommand.Add("pnrp_initEQ", PNRP.OpenEQWindow)

function PNRP.InventoryWeight( p )
	
	local ILoc = PNRP.GetInventoryLocation( p )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	if !file.Exists( ILoc ) then 
		print( "Inventory file doesn't exist !" )
		return 0
	end	
	
	local Inv = PNRP.Inventory( p )
	
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
	
	local ILoc = PNRP.GetCarInventoryLocation( ply )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	local tbl = { }
	if !file.Exists( ILoc ) then 
		print( "Inventory file doesn't exist !" ) 
		datastream.StreamToClients(ply, "pnrp_OpenCarInvWindow", { tbl, tostring(PNRP.CarInventoryWeight( ply )) })
	else
		tbl = util.KeyValuesToTable(file.Read(ILoc))
		datastream.StreamToClients(ply, "pnrp_OpenCarInvWindow", { tbl, tostring(PNRP.CarInventoryWeight( ply )) })
	end
	

end
concommand.Add("pnrp_OpenCarInventory", PNRP.OpenMainCarInventory)

function PNRP.CarInventoryWeight( p )
	
	local ILoc = PNRP.GetCarInventoryLocation( p )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	if !file.Exists( ILoc ) then 
		print( "Car Inventory file doesn't exist !" )
		return 0
	end	
	
	local Inv = PNRP.CarInventory( p )
	
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

function PlayerMeta:AddToInventory( theitem )
	PNRP.AddToInentory( self, theitem )
end
	
function PNRP.AddToInentory( p, theitem )
	
	if PNRP.Items[theitem] != nil then
	
		local ILoc = PNRP.GetInventoryLocation( p )		
		
		if file.Exists( ILoc ) then	
		
			local decoded = PNRP.Inventory( p )		
			
			if tonumber( decoded[theitem] ) != nil then
			
				decoded[theitem] = decoded[theitem] + 1
				
			else
			
				decoded[theitem] = 1
				
			end
			
			file.Write( ILoc, util.TableToKeyValues( decoded ) )
			
		else
		
			local Inventory	= {}			
			
			Inventory[theitem] = 1
			
			file.Write( ILoc, util.TableToKeyValues( Inventory ) )
			
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
		PNRP.AddToInentory( p, theitem )
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
	
	if team.GetName(p:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (p:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (p:GetSkill("Backpacking")*10)
	end
	
	if weight <= weightCap then
		PNRP.AddToInentory( p, theitem )
		
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

function PNRP.AddToCarInentory( p, command, arg )
	local theitem = arg[1]
	
	if PNRP.Items[theitem] != nil then
	
		local ILoc = PNRP.GetCarInventoryLocation( p )		
		
		if file.Exists( ILoc ) then	
		
			local decoded = PNRP.CarInventory( p )		
			
			if tonumber( decoded[theitem] ) != nil then
			
				decoded[theitem] = decoded[theitem] + 1
				
			else
			
				decoded[theitem] = 1
				
			end
			
			file.Write( ILoc, util.TableToKeyValues( decoded ) )
			
		else
		
			local CarInventory	= {}			
			
			CarInventory[theitem] = 1
			Msg("CarInv: "..tostring(CarInventory).."\n")
			file.Write( ILoc, util.TableToKeyValues( CarInventory ) )
			
		end
		
		PNRP.TakeFromInventory( p, theitem )
		
		Msg("["..tostring(theitem).."] added to "..p:Nick().."'s car inventory.  \n")
	end
	if command == "pnrp_addtocarinentoryFromEQ" then
		local ammoAmt = PNRP.Items[theitem].Energy
		theitem = string.gsub(theitem, "ammo_", "")
		p:RemoveAmmo( ammoAmt, theitem )
	end
	
	if command ~= "pnrp_addtocarinentoryFromEQ" then
		p:ConCommand("pnrp_inv")
	end
end	
concommand.Add( "pnrp_addtocarinentory", PNRP.AddToCarInentory )
concommand.Add( "pnrp_addtocarinentoryFromEQ", PNRP.AddToCarInentory )


function PNRP.TakeFromInventory( p, theitem )
	local ILoc = PNRP.GetInventoryLocation( p )		
	
	if !file.Exists( ILoc ) then return print( "Inventory file doesn't exist !" ) end
	local decoded = PNRP.Inventory( p )		
	if decoded[theitem] != nil then
		if decoded[theitem] > 1 then
			decoded[theitem] = decoded[theitem] - 1
		else
			decoded[theitem] = nil
		end
		file.Write( ILoc, util.TableToKeyValues( decoded ) )
	end	
end

function PNRP.TakeFromInventoryBulk( p, theitem, Count )
	local ILoc = PNRP.GetInventoryLocation( p )		
	local Check = false
	if !file.Exists( ILoc ) then return print( "Inventory file doesn't exist !" ) end
	local decoded = PNRP.Inventory( p )		
	if decoded[theitem] != nil then
		if decoded[theitem] > Count then
			decoded[theitem] = decoded[theitem] - Count
			Check = true
		else
			if decoded[theitem] == Count then
				decoded[theitem] = nil
				Check = true
			else
				Check = false
			end
		end
		file.Write( ILoc, util.TableToKeyValues( decoded ) )
	end	
	return Check
end

function PNRP.TakeFromCarInventory( p, theitem )
	local ILoc = PNRP.GetCarInventoryLocation( p )		
	
	if !file.Exists( ILoc ) then return print( "Inventory file doesn't exist !" ) end
	local decoded = PNRP.CarInventory( p )		
	if decoded[theitem] != nil then
		if decoded[theitem] > 1 then
			decoded[theitem] = decoded[theitem] - 1	
		else
			decoded[theitem] = nil	
		end
		file.Write( ILoc, util.TableToKeyValues( decoded ) )
	end	
end

function PNRP.TakeFromCarInventoryBulk( p, theitem, Count )
	local ILoc = PNRP.GetCarInventoryLocation( p )		
	local Check = false
	if !file.Exists( ILoc ) then return print( "Inventory file doesn't exist !" ) end
	local decoded = PNRP.CarInventory( p )		
	if decoded[theitem] != nil then
		if decoded[theitem] > Count then
			decoded[theitem] = decoded[theitem] - Count
			Check = true
		else
			if decoded[theitem] == Count then
				decoded[theitem] = nil
				Check = true
			else
				Check = false
			end
		end
		file.Write( ILoc, util.TableToKeyValues( decoded ) )
	end	
	return Check
end

function PNRP.DropItem( p, c, a )

	for itemname, item in pairs( PNRP.Items ) do
	
		for k, v in pairs( PNRP.Inventory( p ) ) do
		
			if k == itemname && k == a[1] then
			
				PNRP.DropSpawn(p, itemname, 1)

			end
			
		end
		
	end	

end

concommand.Add( "inventory_drop", PNRP.DropItem )

function PNRP.DropCarItem( p, c, a )

	for itemname, item in pairs( PNRP.Items ) do
	
		for k, v in pairs( PNRP.CarInventory( p ) ) do
		
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

function PNRP.UseFromInv(ply, handler, id, encoded, decoded )
	local ItemID = decoded[1]
	
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
datastream.Hook( "UseFromInv", PNRP.UseFromInv )

--EOF