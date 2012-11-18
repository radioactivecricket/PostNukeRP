--Main Ownership File

function PNRP.SetOwner(ply, ent)
	local plUID = PNRP:GetUID( ply )
	
	ent:SetNetworkedString("Owner_UID", plUID)
	ent:SetNetworkedString("Owner", ply:Nick())
	ent:SetNWEntity( "ownerent", ply )
end

function PNRP.SetOwnership( ply )
	local tr = ply:TraceFromEyes(200)
	local ent = tr.Entity
	local plUID = PNRP:GetUID( ply )

	--Added to remove the Null Entity error
	if tostring(ent) == "[NULL Entity]" or ent == nil then return end
	local DoorsOwned = table.Count(PNRP.ListDoors(ply))
	--If World or Player then exit
	if ent:IsWorld() then return end
	if ent:IsPlayer() then return end
	--Checks for Admin Overide
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
		
		if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == plUID then
			ply:ConCommand("pnrp_removeowner")
			ent:EmitSound( "buttons/button14.wav" )
		else
			PNRP.SetOwner(ply, ent)
			
			local myClass = ent:GetClass()
			local ItemID = PNRP.FindItemID( myClass )
			
			if ItemID != nil then
				local myType = PNRP.Items[ItemID].Type
				if myType == "vehicle" then
					local myModel = ent:GetModel()			
					if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
				end		
				PNRP.AddWorldCache( ply, ItemID )
			end
			
			ply:ChatPrint("Admin override of ownership.")
			ent:EmitSound( "buttons/combine_button_locked.wav" )
		end
		return
	end
	--If spawn door	
	if tostring(ent:GetNetworkedString( "pnrp_spawndoor" , "None" )) == "1" then
		ply:ChatPrint("You can not own this door.")
		return
	end
	
	if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == plUID then
		ply:ConCommand("pnrp_removeowner")
		ent:EmitSound( "buttons/button14.wav" )
	else
		if not ent:IsDoor() then
			--ply:ConCommand("pnrp_addowner")
			AddOwner(ply, 0)
			ent:EmitSound( "buttons/blip1.wav" )
		end
		if DoorsOwned < GetConVarNumber("pnrp_maxOwnDoors") and ent:IsDoor() then
			--ply:ConCommand("pnrp_addowner")
			AddOwner(ply, 0)
			ent:EmitSound( "buttons/blip1.wav" )
		elseif ent:IsDoor() then
			ply:ChatPrint("You own too many doors!")
			ent:EmitSound( "buttons/button10.wav" )
		end
	end
end
concommand.Add( "pnrp_setOwner", PNRP.SetOwnership )
--PNRP.ChatConCmd( "/setowner", "pnrp_setOwner" )

function AddOwner(ply, args)
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	
	local playerNick = ply:Nick()
	local plUID = PNRP:GetUID( ply )
	
	if ent:GetNetworkedString("Owner") == "World" or ent:GetNetworkedString("Owner") == "None" or ent:GetNetworkedString("Owner") == "" then
		PNRP.SetOwner(ply, ent)
		
		local myClass = ent:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if myType == "vehicle" then
				local myModel = ent:GetModel()			
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
			end		
			PNRP.AddWorldCache( ply, ItemID )
		end
		
	else
		ply:ChatPrint("Object allready owned by "..tostring(ent:GetNetworkedString( "Owner" , "None" )))
	end
	
	return ""
end
concommand.Add( "pnrp_addowner", AddOwner )

function removeOwner(ply, args)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	
	local playerNick = ply:Nick()
	local plUID = PNRP:GetUID( ply )
	
	if ent:GetNetworkedString("Owner_UID") == plUID then
		ent:SetNetworkedString("Owner", "" )
		ent:SetNetworkedString("Owner", "World" )
		ent:SetNetworkedString("Owner_UID", "None")
		ent:SetNWEntity( "ownerent", nil )
		SK_Srv.ReleaseOwner( ply, ent )
	
		local myClass = ent:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if myType == "vehicle" then
				local myModel = ent:GetModel()			
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
			end		
			PNRP.TakeFromWorldCache( ply, ItemID )
		end
		
	else
		ply:ChatPrint("You do not own this object.")
	end
	
	return ""
end
concommand.Add( "pnrp_removeowner", removeOwner )
util.AddNetworkString( "SKReleaseOwner" )

--AddChatCommand("/addowner", AddOwner)
function ReadOwner(ply, args)
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	local ent = tr.Entity
	
	ply:ChatPrint(tostring(ent:GetNetworkedString( "Owner" , "None" )))

end
concommand.Add( "pnrp_readowner", ReadOwner )

function PNRP.ListOwnedItems( UID )
	local OwnedEntTbl = {}
	
	for k, v in pairs(ents.GetAll()) do
		if !v:IsDoor() and v:GetNetworkedString( "Owner_UID" , "None" ) == UID then
			table.insert(OwnedEntTbl, v)
		end
	end
	
	return OwnedEntTbl
end

function PNRP.ListDoors( ply )
	local DoorEntTbl = {}
	local plUID = PNRP:GetUID( ply )
	for k, v in pairs(ents.GetAll()) do
		if v:IsDoor() and v:GetNetworkedString( "Owner_UID" , "None" ) == plUID then
			table.insert(DoorEntTbl, v)
		end
	end
	
	return DoorEntTbl
end

function PNRP.OpenBuddyWindow(ply)
	local tbl = { }
	if ply.PropBuddyList then
		for _, v in pairs(player.GetAll()) do
			if ply.PropBuddyList[PNRP:GetUID(v)] then
				table.insert(tbl, v:GetName())
			end
		end
	end 
	net.Start("pnrp_OpenBuddyWindow")
		net.WriteTable(tbl)
	net.Send(ply)
end
concommand.Add("pnrp_OpenBuddy", PNRP.OpenBuddyWindow)
util.AddNetworkString( "pnrp_OpenBuddyWindow" )

function PNRP.AddBuddy( ply, cmd, args )
	local UID = table.concat(args, "")
	ply.PropBuddyList = ply.PropBuddyList or {}
	ply.PropBuddyList[ UID ] = true
	ply:ChatPrint("Buddy Added.")
end
concommand.Add("PNRP_AddBuddy", PNRP.AddBuddy)

function PNRP.AddCommBuddy( ply, cmd, args )
	ply.PropBuddyList = ply.PropBuddyList or {}
	
	local cid = ply:GetTable().Community
	local query = "SELECT * FROM community_members WHERE cid="..tostring(cid)
	
	local result = querySQL(query)
	
	if result then
	
	end
	
	ply:ChatPrint("Buddy Added.")
end
concommand.Add("PNRP_AddCommBuddy", PNRP.AddCommBuddy)

function PNRP.RemoveBuddy(  ply, cmd, args )
	local UID = table.concat(args, "")
	ply.PropBuddyList = ply.PropBuddyList or {}
	ply.PropBuddyList[ UID ] = nil
	ply:ChatPrint("Buddy Removed.")
end
concommand.Add("PNRP_RemBuddy", PNRP.RemoveBuddy)
--EOF