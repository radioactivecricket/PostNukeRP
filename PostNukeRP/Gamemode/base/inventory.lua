PNRP.Items = {}

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
	}
	
end	

function PNRP.FindItemID( class )
	
	for itemname, item in pairs( PNRP.Items ) do
		if class == item.Ent then
			return item.ID
		end
		
	end	
	return nil
	
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


function PNRP.CarInventory( p )
	
	local ILoc = PNRP.GetCarInventoryLocation( p )
	
	if !file.Exists( ILoc ) then print( "Inventory file doesn't exist !" ) return end	
	
	local decoded = util.KeyValuesToTable( file.Read( ILoc ) )	
	
	return decoded
	
end	


function PNRP.SendInventory( p )

	local ILoc = PNRP.GetInventoryLocation( p )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	if !file.Exists( ILoc ) then print( "Inventory file doesn't exist !" ) return end	
	
	p:SendLua( "MyInventory = {}" )

	local Inv = PNRP.Inventory( p )

	for k, v in pairs( Inv ) do
	
		p:SendLua( "MyInventory['" ..k.. "'] = "..v ) --SendLua ftw
		
	end	
	
	p:SendLua( "CurWeight = "..tostring(PNRP.InventoryWeight( p ) ) )
	
end

function PNRP.InventoryWeight( p )
	
	local ILoc = PNRP.GetInventoryLocation( p )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	if !file.Exists( ILoc ) then print( "Inventory file doesn't exist !" ) return end	
	
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


function PNRP.SendCarInventory( p )

	local ILoc = PNRP.GetCarInventoryLocation( p )
	
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/inventory") then file.CreateDir("PostNukeRP/inventory") end
	
	if !file.Exists( ILoc ) then print( "Inventory file doesn't exist !" ) return end	
	
	p:SendLua( "MyCarInventory = {}" )

	local Inv = PNRP.CarInventory( p )

	for k, v in pairs( Inv ) do
	
		p:SendLua( "MyCarInventory['" ..k.. "'] = "..v ) --SendLua ftw
		
	end	
	
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
		
		PNRP.SendInventory( p )
		
	end
	
end


function PNRP.AddToCarInentory( p, theitem )

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
			
			file.Write( ILoc, util.TableToKeyValues( CarInventory ) )
			
		end
		
		PNRP.SendCarInventory( p )
		
	end
	
end	


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
		
		PNRP.SendInventory( p )

	end	

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
		
		PNRP.SendCarInventory( p )

	end	

end


function PNRP.DropItem( p, c, a )

	for itemname, item in pairs( PNRP.Items ) do
	
		for k, v in pairs( PNRP.Inventory( p ) ) do
		
			if k == itemname && k == a[1] then
			
				PNRP.DropSpawn(p, itemname, 1)
				-- PNRP.TakeFromInventory( p, a[1] )
				
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
				-- PNRP.TakeFromInventory( p, a[1] )
				
			end
			
		end
		
	end	

end

concommand.Add( "carinventory_drop", PNRP.DropCarItem )


function PNRP.InventoryUse( p, c, a )

	for itemname, item in pairs( PNRP.Items ) do
	
		for k, v in pairs( PNRP.Inventory( p ) ) do
		
			if k == itemname && k == a[1] then
			
				if PNRP.UseLimit( p ) then
				
					if item.Remove then
					
						item.Use( p )
						PNRP.TakeFromInventory( p, a[1] )
						
					end
					
					p.NextInventoryUse = CurTime() + 3
					
				end
				
			end
			
		end
		
	end	
	
end	

concommand.Add( "inventory_use", PNRP.InventoryUse )

function PNRP.ReportWeight( p, c, a )
	p:ChatPrint( "Inventory Weight:  "..tostring(PNRP.InventoryWeight( p )) )
end

concommand.Add( "debug_weight", PNRP.ReportWeight )
