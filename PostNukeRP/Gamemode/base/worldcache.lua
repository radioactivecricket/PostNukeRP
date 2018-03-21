------------------------------------------
--	World Cache							--
------------------------------------------

function PNRP.GetWorldCache( ply )
	
	local query = "SELECT * FROM world_cache WHERE pid="..tostring(ply.pid)
	local result = querySQL(query)
	
	return result 
	
end	
--Adds item to WorldCache
function PNRP.AddWorldCache( p, theitem, ent )
	if PNRP.Items[theitem].Type == "tool" or PNRP.Items[theitem].Type == "misc" or PNRP.Items[theitem].Type == "vehicle" then
		local isIID = false
		if ent then
			
			if ent.iid then
				local iidResult = PNRP.GetPersistItem(tostring(ent.iid))
				if iidResult then
					isIID = true 
					if tostring(iidResult["location"]) ~= "world" then 
						PNRP.SaveState(p, ent, "world")	 
					end
				end
			end
		end
		if not isIID then
			if PNRP.Items[theitem] != nil then
				local query = "SELECT * FROM world_cache WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
				local result = querySQL(query)
				if result then
					local newCount = tonumber(result[1]["count"]) + 1
					query = "UPDATE world_cache SET count="..newCount.." WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
					result = querySQL(query)
				else
					query = "INSERT INTO world_cache VALUES ( '"..tostring(p.pid).."', '"..theitem.."', '1')"
					result = querySQL(query)
				end			
			end
		end
	end
end
--Removes Item class from WorldCache
function PNRP.TakeAllFromWorldCache( p, theitem )
	if PNRP.Items[theitem] != nil then
		local query = "DELETE FROM world_cache WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
		local result = querySQL(query)
	end
end
--Removes Item from WorldCache
function PNRP.TakeFromWorldCache( p, theitem )
	print(theitem)
	local query = "SELECT * FROM world_cache WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
	local result = querySQL(query)
	
	if result and tonumber(result[1]["count"]) > 1 then
		local newCount = tonumber(result[1]["count"]) - 1
		query = "UPDATE world_cache SET count="..newCount.." WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
		result = querySQL(query)
	else
		local query = "DELETE FROM world_cache WHERE pid="..tostring(p.pid).." AND item='"..theitem.."'"
		result = querySQL(query)
	end
end
		
--Returns the Item to the player
function PNRP.ReturnWorldCache( ply )
	PNRP.ReturnPersistItems( ply )
	
	local worldCache = PNRP.GetWorldCache( ply )
	if worldCache then 
		for k, v in pairs(worldCache) do
			PNRP.AddToInventory( ply, v["item"], tonumber(v["count"]) )
			PNRP.TakeAllFromWorldCache( ply, v["item"] )
		end
	end
	
	PNRP.CleanWorldAfterReturn( ply )
end

--Cleans up the world after player leaves (Only WorldCache Items are removed)
function PNRP.CleanWorldAfterReturn( ply )
	local plUID = tostring(ply:GetNetVar( "UID" , "None" ))
	if plUID == "None" then
		plUID = ply:UniqueID()
	end
	for k,v in pairs(ents.GetAll()) do
		local myClass = v:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetVar( "Owner_UID" , "None" )) == plUID then
				if myType == "vehicle" or myType == "tool" or myType == "misc" then
					v:Remove()
				end
			end
		end
	end
end

--EOF