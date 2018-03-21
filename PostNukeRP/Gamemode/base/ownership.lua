--Main Ownership File

function PNRP.SetOwner(ply, ent)
	local plUID = PNRP:GetUID( ply )
	
	ent:SetNetVar("Owner_UID", plUID)
	ent:SetNetVar("Owner", ply:Nick())
	ent:SetNetVar( "ownerent", ply )
--	ent:SetOwner(ply)

	if ent.iid or ent.iid != "" then
		PNRP.SaveState(ply, ent, "world")
	end
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
	if ply:IsAdmin() and getServerSetting("adminTouchAll") == 1 then
		
		if tostring(ent:GetNetVar( "Owner_UID" , "None" )) == plUID then
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
				PNRP.AddWorldCache( ply, ItemID, ent )
			end
			
			ply:ChatPrint("Admin override of ownership.")
			ent:EmitSound( "buttons/combine_button_locked.wav" )
		end
		return
	end
	--If spawn door	
	if tostring(ent:GetNetVar( "pnrp_spawndoor" , "None" )) == "1" then
		ply:ChatPrint("You can not own this door.")
		return
	end
	
	if tostring(ent:GetNetVar( "Owner_UID" , "None" )) == plUID then
		ply:ConCommand("pnrp_removeowner")
		ent:EmitSound( "buttons/button14.wav" )
	else
		if not ent:IsDoor() then
			--ply:ConCommand("pnrp_addowner")
			AddOwner(ply, 0)
			ent:EmitSound( "buttons/blip1.wav" )
		end
		if DoorsOwned < getServerSetting("maxOwnDoors") and ent:IsDoor() then
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
	
	if ent:GetNetVar("Owner", "") == "World" or ent:GetNetVar("Owner", "") == "None" or ent:GetNetVar("Owner", "") == "" then
		PNRP.SetOwner(ply, ent)
		
		local myClass = ent:GetClass()
		local ItemID = PNRP.FindItemID( myClass )
		
		if ItemID != nil then
			local myType = PNRP.Items[ItemID].Type
			if myType == "vehicle" then
				local myModel = ent:GetModel()			
				if myModel == "models/buggy.mdl" then ItemID = "vehicle_jeep" end
			end		
			PNRP.AddWorldCache( ply, ItemID, ent )
		end
		
	else
		ply:ChatPrint("Object allready owned by "..tostring(ent:GetNetVar( "Owner" , "None" )))
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
	
	if ent:GetNetVar("Owner_UID") == plUID then
		ent:SetNetVar("Owner", "" )
		ent:SetNetVar("Owner", "World" )
		ent:SetNetVar("Owner_UID", "None")
		ent:SetNetVar( "ownerent", nil )
	--	ent:SetOwner(nil)
		SK_Srv.ReleaseOwner( ply, ent )
		
		if ent.iid or ent.iid != "" then
			PNRP.SaveState("none", ent, "world")
		end
	
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
	
	ply:ChatPrint(tostring(ent:GetNetVar( "Owner" , "None" )))

end
concommand.Add( "pnrp_readowner", ReadOwner )

function PNRP.ListOwnedItems( UID )
	local OwnedEntTbl = {}
	
	for k, v in pairs(ents.GetAll()) do
		if !v:IsDoor() and v:GetNetVar( "Owner_UID" , "None" ) == UID then
			table.insert(OwnedEntTbl, v)
		end
	end
	
	return OwnedEntTbl
end

function PNRP.ListDoors( ply )
	local DoorEntTbl = {}
	local plUID = PNRP:GetUID( ply )
	for k, v in pairs(ents.GetAll()) do
		if v:IsDoor() and v:GetNetVar( "Owner_UID" , "None" ) == plUID then
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
		net.WriteString(ply.CommunityBuddy or "false")
		net.WriteString(ply.AllyBuddy or "false")
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

function PNRP.ToggleCommBuddy( ply, cmd, args )
	if ply.CommunityBuddy == "true" then
		ply.CommunityBuddy = "false"
		ply:ChatPrint("Community Buddy System Disabled")
		
		if ply.AllyBuddy == "true" then
			ply:ChatPrint("Ally Buddy System Disabled")
			ply.AllyBuddy = "false"
		end
	else
		ply.CommunityBuddy = "true"
		ply:ChatPrint("Community Buddy System Enabled")
	end
end
concommand.Add("PNRP_ToggleCommBuddy", PNRP.ToggleCommBuddy)

function PNRP.ToggleAllyBuddy( ply, cmd, args )
	if ply.CommunityBuddy ~= "true" then
		ply:ChatPrint("Enable Community Buddy System first.")
		return
	end
	if ply.AllyBuddy == "true" then
		ply.AllyBuddy = "false"
		ply:ChatPrint("Ally Buddy System Disabled")
	else
		ply.AllyBuddy = "true"
		ply:ChatPrint("Ally Buddy System Enabled")
	end
end
concommand.Add("PNRP_ToggleAllyBuddy", PNRP.ToggleAllyBuddy)

function PNRP.RemoveBuddy(  ply, cmd, args )
	local UID = table.concat(args, "")
	ply.PropBuddyList = ply.PropBuddyList or {}
	ply.PropBuddyList[ UID ] = nil
	ply:ChatPrint("Buddy Removed.")
end
concommand.Add("PNRP_RemBuddy", PNRP.RemoveBuddy)

function PNRP.ClearBuddyList(  ply, cmd, args )
	ply.PropBuddyList = {}
	ply:ChatPrint("Buddy list cleared.")
end
concommand.Add("PNRP_ClearBuddyList", PNRP.ClearBuddyList)
--EOF