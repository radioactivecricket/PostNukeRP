------------------------------------------
--	Below is the attempt for a world cache
------------------------------------------

--local cacheLoc = "PostNukeRP/Cache/cache.txt"

function PNRP.GetWorlCacheLocation( p )

	return "PostNukeRP/Cache/"..PNRP.RPSteamID( p )..".txt"
	
end	

function PNRP.GetWorldCache( p )
	
	local ILoc = PNRP.GetWorlCacheLocation( p )
	
	if !file.Exists( ILoc ) then print( "World Cache file doesn't exist !" ) return end	
	
	local decoded = util.KeyValuesToTable( file.Read( ILoc ) )	
	
	return decoded
	
end	

function PNRP.AddWorldCache( p, theitem )
	if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/Cache") then file.CreateDir("PostNukeRP/Cache") end
	Msg(tostring(PNRP.Items[theitem].Type).."\n")
	if PNRP.Items[theitem].Type == "tool" or PNRP.Items[theitem].Type == "vehicle" then
	
		if PNRP.Items[theitem] != nil then
		
			local ILoc = PNRP.GetWorlCacheLocation( p )	
			
			if file.Exists( ILoc ) then	
			
				local decoded = PNRP.GetWorldCache( p )	
				
				if tonumber( decoded[theitem] ) != nil then
				
					decoded[theitem] = decoded[theitem] + 1
					
				else
				
					decoded[theitem] = 1
					
				end
				
				file.Write( ILoc, util.TableToKeyValues( decoded ) )
				
			else
			
				local WCInventory	= {}			
				
				WCInventory[theitem] = 1
				
				file.Write( ILoc, util.TableToKeyValues( WCInventory ) )
				
			end
			
		end
	end
end

function PNRP.TakeFromWorldCache( p, theitem )

	local ILoc = PNRP.GetWorlCacheLocation( p )		
	
	if !file.Exists( ILoc ) then return print( "World Cache file doesn't exist !" ) end
	
	local decoded = PNRP.GetWorldCache( p )		

	if decoded[theitem] != nil then
	
		if decoded[theitem] > 1 then
		
			decoded[theitem] = decoded[theitem] - 1
			
		else
		
			decoded[theitem] = nil
			
		end
		
		file.Write( ILoc, util.TableToKeyValues( decoded ) )
		
	end	

end

function PNRP.ReturnWorldCache( ply )
	local worldCache = PNRP.GetWorldCache( ply )
	if not worldCache then return end
--	local worldCache = {}
	for k, v in pairs(worldCache) do
		if v > 1 then
			for i=1,v do 
				PNRP.AddToInentory( ply, k )
				PNRP.TakeFromWorldCache( ply, k )
			end 		
		else
				PNRP.AddToInentory( ply, k )
				PNRP.TakeFromWorldCache( ply, k )
		end
		
--		ply:ChatPrint("Cache ID:  "..v["player"].."  Player ID:  "..ply:UniqueID())
--		if v["player"] == ply:UniqueID() then
--			PNRP.AddToInentory( ply, v["type"] )
--			ply:ChatPrint("A "..PNRP.Items[v["type"]].Name.." has been reimbursed.")
--			PNRP.RemoveWorldCache( v["worldid"] )
--		end
	end
	PNRP.CleanWorldAfterReturn( ply )
end

function PNRP.CleanWorldAfterReturn( ply )
	for k,v in pairs(ents.GetAll()) do
		local myClass = v:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if tostring(v:GetNetworkedString( "Owner" , "None" )) == ply:Nick() then
				if myType == "vehicle" or myType == "tool" then
					v:Remove()
				end
			end
		end
	end
end



--EOF