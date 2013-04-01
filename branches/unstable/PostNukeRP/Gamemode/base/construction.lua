local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function PNRP.SpawnBulkCrate( )
	local ply = net.ReadEntity()
	local ItemID = net.ReadString()
	local Count = math.Round(net.ReadDouble())
	local tr = ply:TraceFromEyes(200)
	local pos = tr.HitPos
	local plUID = PNRP:GetUID( ply )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ItemID ) == itemname then
			local allowed = false
			local enough = false
			--Admin overide
			if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then allowed = true 
			else allowed = false end
			--If Right Class
			if team.GetName(ply:Team()) == item.ClassSpawn or item.ClassSpawn == "All" or allowed == true then
			
				--Apply construction skill
				if ply:GetSkill("Construction") > 0 then
					for _, team in pairs(PNRP.Skills["Construction"].class) do
						if ply:Team() == team then
							item.Scrap = math.ceil(item.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))
							item.SmallParts = math.ceil(item.SmallParts * (1 - (0.02 * ply:GetSkill("Construction"))))
							item.Chemicals = math.ceil(item.Chemicals * (1 - (0.02 * ply:GetSkill("Construction"))))
						end
					end
				end
				
				--Verifies Player has the needed Materials to build the item
				local totalScrap = item.Scrap * Count
				local totalSmall = item.SmallParts * Count
				local totalChems = item.Chemicals * Count
				if ply:GetResource("Scrap") >= totalScrap and ply:GetResource("Chemicals") >= totalChems and ply:GetResource("Small_Parts") >= totalSmall then 
					enough = true
				elseif ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
					enough = true
				else
					enough = false
				end
				if enough == true then
					--Block these from Bulk Build
					if item.Type == "vehicle" or item.Type == "tool" or item.Type == "junk" then
						ply:ChatPrint("You can not create bulk of this type.")
						return
					end
					
					if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then
						--Admin No cost
					else
						local toolcheck = item.ToolCheck( ply )
						if not toolcheck then
							ply:ChatPrint("You don't have the proper tool to make this!")
							return
						elseif type(toolcheck) == "table" then
							local plyInv = PNRP.Inventory( ply )
							
							for itemid, amount in pairs(toolcheck) do
								if (not plyInv) or (not plyInv[itemid]) or plyInv[itemid] < (amount * Count) then
									if amount == 0 then
										ply:ChatPrint("You don't have a "..PNRP.Items[itemid].Name..", which is required to build this.")
									else
										ply:ChatPrint("You don't have enough "..PNRP.Items[itemid].Name.."s.  You require "..tostring(amount*Count).." to build this many.")
									end
									return
								end
							end
							
							for itemid, amount in pairs(toolcheck) do
								if amount ~= 0 then
									PNRP.TakeFromInventoryBulk( ply, itemid, (amount * Count) )
								end
							end
						end
					end
					
					local totalTime = 0
					
					for iteration = 1, Count do
						totalTime = totalTime + (3 / iteration)
					end
					
					ply:Freeze(true)
					ply:ChatPrint("Construction in progress...")
					net.Start("startProgressBar")
						net.WriteDouble(tonumber(totalTime))
					net.Send(ply)
					
					if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
						ply:ChatPrint("Admin No Cost")
					else
						ply:DecResource("Scrap", totalScrap)
						ply:DecResource("Small_Parts", totalSmall)
						ply:DecResource("Chemicals", totalChems)
					end
					
					timer.Simple( totalTime, function() 
						ply:Freeze(false)
						net.Start("stopProgressBar")
						net.Send(ply)
						local ent = ents.Create("msc_itembox")
						--Spawns the entity
						ent:SetPos(pos)
						ent:SetNWString("itemtype", item.ID)
						ent:SetNWInt("amount", Count)
						--ent:SetNWString("Owner", ply:Nick())
						--ent:SetNWString("Owner_UID", plUID)
						--ent:SetNWEntity( "ownerent", ply )
						PNRP.SetOwner(ply, ent)
						ent:Spawn()
						ply:EmitSound(Sound("items/ammo_pickup.wav"))
					end )
					
				else
					--If Not enough Materials
					ply:ChatPrint("Insufficient Materials!")
				end
				
			else
				ply:ChatPrint("Incorrect Class! "..item.ClassSpawn.." class Item.")
			end
		end
	end
	
end
net.Receive( "SpawnBulkCrate", PNRP.SpawnBulkCrate )
util.AddNetworkString("startProgressBar")
util.AddNetworkString("stopProgressBar")

function PNRP.DropBulkCrate( )
	local ply = net.ReadEntity()
	local ItemID = net.ReadString()
	local Count = math.Round(net.ReadDouble())
	local tr = ply:TraceFromEyes(200)
	local pos = tr.HitPos
	local plUID = PNRP:GetUID( ply )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ItemID ) == itemname then
			local BulkCreate = PNRP.TakeFromInventoryBulk( ply, item.ID, Count )
			if BulkCreate then
				local ent = ents.Create("msc_itembox")
				--Spawns the entity
				ent:SetPos(pos)
				ent:SetNWString("itemtype", item.ID)
				ent:SetNWInt("amount", Count)
				--ent:SetNWString("Owner", ply:Nick())
				--ent:SetNWString("Owner_UID", plUID)
				--ent:SetNWEntity( "ownerent", ply )
				PNRP.SetOwner(ply, ent)
				ent:Spawn()
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
			else
				ply:ChatPrint("You do not have enough of this.")
			end
		end
	end
	
end
net.Receive( "DropBulkCrate", PNRP.DropBulkCrate )

function PNRP.DropBulkCrateCar( ply, handler, id, encoded, decoded)
	local ply = net.ReadEntity()
	local ItemID = net.ReadString()
	local Count = math.Round(net.ReadDouble())
	local tr = ply:TraceFromEyes(200)
	local CarEnt = tr.Entity
	local pos = tr.HitPos
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ItemID ) == itemname then
			local BulkCreate = PNRP.TakeFromCarInventoryBulk( ply, item.ID, Count )
			if BulkCreate then
				local ent = ents.Create("msc_itembox")
				--If Car is detected then place behind car
				local CarItemID = PNRP.FindItemID( CarEnt:GetClass() )
				if CarItemID != nil then
					if PNRP.Items[CarItemID].Type == "vehicle" then
						ent:SetAngles(CarEnt:GetAngles())
						pos = CarEnt:LocalToWorld(Vector(0,-80,40))
						
					end
				end
				--Spawns the entity
				ent:SetPos(pos)
				ent:SetNWString("itemtype", item.ID)
				ent:SetNWInt("amount", Count)
				--ent:SetNWString("Owner", ply:Nick())
				PNRP.SetOwner(ply, ent)
				ent:Spawn()
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
			else
				ply:ChatPrint("You do not have enough of this.")
			end
		end
	end
	
end
net.Receive( "DropBulkCrateCar", PNRP.DropBulkCrateCar )

function GM.BuildItem( ply, command, arg )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( arg[1] ) == itemname then
			--Class Check
			local allowed = false
			local enough = false
			
			if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then allowed = true 
			else allowed = false end
			
			if team.GetName(ply:Team()) == item.ClassSpawn or item.ClassSpawn == "All" or allowed == true then
				--Apply construction skill
				if ply:GetSkill("Construction") > 0 then
					for _, team in pairs(PNRP.Skills["Construction"].class) do
						if ply:Team() == team then
							item.Scrap = math.ceil(item.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))
							item.SmallParts = math.ceil(item.SmallParts * (1 - (0.02 * ply:GetSkill("Construction"))))
							item.Chemicals = math.ceil(item.Chemicals * (1 - (0.02 * ply:GetSkill("Construction"))))
						end
					end
				end
				
				local tr = ply:TraceFromEyes(200)
				--Verifies Player has the needed Materials to build the item
				if ply:GetResource("Scrap") >= item.Scrap and ply:GetResource("Chemicals") >= item.Chemicals and ply:GetResource("Small_Parts") >= item.SmallParts then 
					enough = true
				elseif ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
					enough = true
				else
					enough = false
				end
				
				if enough == true then
					--If Enough
					
					ply:ChatPrint("Creating "..item.Name)
					
					if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then
						--Admin No cost
					else
						local toolcheck = item.ToolCheck( ply )
						if not toolcheck then
							ply:ChatPrint("You don't have the proper tool to make this!")
							return
						elseif type(toolcheck) == "table" then
							local plyInv = PNRP.Inventory( ply )
							
							for itemid, amount in pairs(toolcheck) do
								if (not plyInv) or (not plyInv[itemid]) or plyInv[itemid] < amount then
									if amount == 0 then
										ply:ChatPrint("You don't have a "..PNRP.Items[itemid].Name..", which is required to build this.")
									else
										ply:ChatPrint("You don't have enough "..PNRP.Items[itemid].Name.."s.  You require "..tostring(amount).." to build this.")
									end
									return
								end
							end
							
							for itemid, amount in pairs(toolcheck) do
								if amount ~= 0 then
									PNRP.TakeFromInventoryBulk( ply, itemid, amount )
								end
							end
						end
					end
					
					ply:Freeze(true)
					net.Start("startProgressBar")
						net.WriteDouble(2)
					net.Send(ply)
					local myscrap = item.Scrap
					local mysmall = item.SmallParts
					local mychems = item.Chemicals
					local myenergy = item.Energy
					timer.Simple( 2, function() 
							if ply and IsValid(ply) and ply:Alive() then
								ply:Freeze(false)
								net.Start("stopProgressBar")
								net.Send(ply)
								if item.Type == "food" then
									ply:EmitSound(Sound("ambient/materials/dinnerplates5.wav"))
								else
									ply:EmitSound(Sound("items/ammo_pickup.wav"))
								end
								ply:DecResource("Scrap", myscrap)
								ply:DecResource("Small_Parts", mysmall)
								ply:DecResource("Chemicals", mychems)
								
								local tr = ply:TraceFromEyes(200)
								local myEnt = item.Create(ply, item.Ent, tr.HitPos + Vector(0,0,20))
								
								if item.Type == "weapon" then
									myEnt:SetNWInt("Ammo", myenergy)
								end
							end
						end )
				else
					--If Not enough Materials
					ply:ChatPrint("Insufficient Materials!")
				end
			else
				ply:ChatPrint("Incorrect Class! "..item.ClassSpawn.." class Item.")
			end
		else

		end
	end
end

concommand.Add( "pnrp_buildItem", GM.BuildItem, q)

function PNRP.DropSpawn( ply, ID, q )
	local plUID = PNRP:GetUID( ply )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ID ) == itemname then
			local tr = ply:TraceFromEyes(200)
			
			ply:ChatPrint("Dropping "..item.Name)
			
			for i = 1, q do
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
				local pos = tr.HitPos + Vector(0,0,20)
				local ent = item.Create(ply, item.Ent, pos)
				
			end
			
			PNRP.TakeFromInventoryBulk( ply, item.ID, q )
		
		else
		
		end
	end
end

function PNRP.DropCarSpawn( ply, ID, q )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ID ) == itemname then
			local tr = ply:TraceFromEyes(200)
			
			ply:ChatPrint("Dropping "..item.Name)
			
			for i = 1, q do
				
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
				local pos = tr.HitPos + Vector(0,0,20)
				local ent = item.Create(ply, item.Ent, pos)
				
			end
			
			PNRP.TakeFromCarInventoryBulk( ply, item.ID, q )
		
		else

		end
	end
end

function PNRP.Salvage( ply, command, arg )
	local ent
	local ItemID
	local allowed = false
	local playerNick = ply:Nick()
	local plUID = PNRP:GetUID( ply )
	local count = 1
	
	if tostring(command) == "pnrp_dosalvage"  or tostring(command) == "pnrp_docarsalvage" then
		local split = string.Explode(",",arg[1])
		ItemID = split[1]
		count = math.Round(tonumber(split[2]))
		allowed = true
	else
		local tr = ply:TraceFromEyes(400)
		ent = tr.Entity

--		if ent:GetNetworkedString("Owner") == playerNick then
		if tostring(ent:GetNetworkedString( "Owner_UID" , "None" )) == plUID then
			allowed = true
		else
			allowed = false
		end
		
--		if ent:GetClass() == "prop_vehicle_prisoner_pod" then
--			myClass = "weapon_seat"
--		else
			myClass = ent:GetClass()
--		end
		
		if myClass == "prop_physics" then return end
		
		ItemID = PNRP.FindItemID( myClass )
	end
	
	local myClass
	--Added to remove the Null Entity error
	if tostring(ent) == "[NULL Entity]" then return end
	
	if allowed == true then
		
		if ItemID != nil then
			local scrap
			local smallparts
			local chemicals
			
			if tostring(command) == "pnrp_dosalvage" then
				local Check = PNRP.TakeFromInventoryBulk( ply, ItemID, count )
				if !Check then
					ply:ChatPrint("Item not found!")
					return
				end
			else
				if tostring(command) == "pnrp_docarsalvage" then
					local Check = PNRP.TakeFromCarInventoryBulk( ply, ItemID, count )
					if !Check then
						ply:ChatPrint("Item not found!")
						return
					end
				else
					ent:Remove()
				end
			end
			
			if team.GetName(ply:Team()) == "Wastelander" or team.GetName(ply:Team()) == "Scavenger" then
				scrap = math.Round(PNRP.Items[ItemID].Scrap * (0.5 + (ply:GetSkill("Salvaging") * 0.05)))
				smallparts =  math.Round(PNRP.Items[ItemID].SmallParts * (0.5 + (ply:GetSkill("Salvaging") * 0.05))) 
				chemicals = math.Round(PNRP.Items[ItemID].Chemicals * (0.5 + (ply:GetSkill("Salvaging") * 0.05)))
			else	
				scrap = math.Round(PNRP.Items[ItemID].Scrap * (0.25 + (ply:GetSkill("Salvaging") * 0.05)))
				smallparts =  math.Round(PNRP.Items[ItemID].SmallParts * (0.25 + (ply:GetSkill("Salvaging") * 0.05)))
				chemicals = math.Round(PNRP.Items[ItemID].Chemicals * (0.25 + (ply:GetSkill("Salvaging") * 0.05)))
			end	
			
			scrap = scrap * count
			smallparts = smallparts * count
			chemicals = chemicals * count
			
			Msg(ply:Nick().."Salvaged "..tostring(scrap).." "..tostring(smallparts).." "..tostring(chemicals).."\n")
			ply:IncResource("Scrap", scrap)
			ply:IncResource("Small_Parts", smallparts)
			ply:IncResource("Chemicals", chemicals)
			
			ply:ChatPrint("You have salvaged: "..tostring(scrap).." Scrap, "..tostring(smallparts).." Small Parts and "..tostring(chemicals).." Chemicals")
		end
	else
	
		ply:ChatPrint("You do not own this.")
		
	end

end
concommand.Add( "pnrp_salvage", PNRP.Salvage)
concommand.Add( "pnrp_dosalvage", PNRP.Salvage)
concommand.Add( "pnrp_docarsalvage", PNRP.Salvage)


--EOF