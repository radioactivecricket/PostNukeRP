

function AddOwner(ply, args)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 300
	trace.filter = ply
	local tr = util.TraceLine( trace )	
	
	local ent = tr.Entity
	
	local playerNick = ply:Nick()
	
	if ent:GetNetworkedString("Owner") == "World" or ent:GetNetworkedString("Owner") == "None" or ent:GetNetworkedString("Owner") == "" then
		ent:SetNetworkedString("Owner", "" )
		ent:SetNetworkedString("Owner", playerNick )
		
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
	
	if ent:GetNetworkedString("Owner") == playerNick then
		ent:SetNetworkedString("Owner", "" )
		ent:SetNetworkedString("Owner", "World" )
		
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

--EOF