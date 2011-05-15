local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function PNRP.SpawnBulkCrate( ply, handler, id, encoded, decoded)
	local ItemID = decoded[1]
	local Count = math.Round(decoded[2])
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
					if item.Type  == "food" then
						if not item.ToolCheck( ply ) then
							ply:ChatPrint("You don't have the proper tool to make this!")
							return
						end
					end
					--Block these from Bulk Build
					if item.Type == "vehicle" or item.Type == "tool" or item.Type == "junk" then
						ply:ChatPrint("You can not create bulk of this type.")
						return
					end
					
					local totalTime = 0
					
					for iteration = 1, Count do
						totalTime = totalTime + (3 / iteration)
					end
					
					ply:Freeze(true)
					ply:ChatPrint("Construction in progress...")
					
					if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
						ply:ChatPrint("Admin No Cost")
					else
						ply:DecResource("Scrap", totalScrap)
						ply:DecResource("Small_Parts", totalSmall)
						ply:DecResource("Chemicals", totalChems)
					end
					
					timer.Simple( totalTime, function() 
						ply:Freeze(false)
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
datastream.Hook( "SpawnBulkCrate", PNRP.SpawnBulkCrate )

function PNRP.DropBulkCrate( ply, handler, id, encoded, decoded)
	local ItemID = decoded[1]
	local Count = math.Round(decoded[2])
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
datastream.Hook( "DropBulkCrate", PNRP.DropBulkCrate )

function PNRP.DropBulkCrateCar( ply, handler, id, encoded, decoded)
	local ItemID = decoded[1]
	local Count = math.Round(decoded[2])
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
				--ent:SetNWString("itemtype", item.ID)
				--ent:SetNWInt("amount", Count)
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
datastream.Hook( "DropBulkCrateCar", PNRP.DropBulkCrateCar )

function GM.BuildItem( ply, command, arg )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( arg[1] ) == itemname then
			--Class Check
			local allowed = false
			local enough = false
			
			if ply:IsAdmin() and GetConVarNumber("pnrp_adminCreateAll") == 1 then allowed = true 
			else allowed = false end
			
			if team.GetName(ply:Team()) == item.ClassSpawn or item.ClassSpawn == "All" or allowed == true then
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
					local data = {}
					data.Pos = tr.HitPos
					data.ID = item.ID
					data.Name = item.Name
					data.Chance = item.Chance
					data.Scrap = item.Scrap
					data.SmallParts = item.SmallParts
					data.Chems = item.Chemicals
					data.Script = item.Script
					data.Ent = item.Ent
					data.Type = item.Type
					data.Model = item.Model
					data.Energy = item.Energy
					data.Create = item.Create
					data.ToolCheck = item.ToolCheck
					
					if data.Type == "food" then
						if not data.ToolCheck( ply ) then
							ply:ChatPrint("You don't have the proper tool to make this!")
							return
						end
					end
					
					if item.Type != "vehicle" then
						ply:DoProcess("ConstructItem",2,data)
					else
						ply:DoProcess("ConstructJeep",2,data)
					end	
					
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
			local data = {}
			data.Pos = tr.HitPos
			data.ID = item.ID
			data.Name = item.Name
			data.Chance = item.Chance
			data.Scrap = item.Scrap
			data.SmallParts = item.SmallParts
			data.Chems = item.Chemicals
			data.Script = item.Script
			data.Ent = item.Ent
			data.Model = item.Model
			data.Create = item.Create
			data.ToolCheck = item.ToolCheck
			for i = 1, q do
				
				if item.Type ~= "vehicle" then
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
					local pos = data.Pos + Vector(0,0,20)
					if item.Type == "tool" then
						item.Create(ply, item.Ent, pos)
						
					else
						local ent 
						if item.Type == "weapon" and item.ID ~= "wep_grenade" then
							ent = ents.Create("ent_weapon")
							ent:SetNWString("WepClass", data.Ent)
							ent:SetNetworkedInt("Ammo", 0)
						elseif item.Type == "ammo" then
							ent = ents.Create(data.Ent)
							ent:SetNetworkedString("Ammo", tostring(item.Energy))
						else
							ent = ents.Create(data.Ent)
						end
						ent:SetModel(data.Model)
						ent:SetAngles(Angle(0,0,0))
						ent:SetPos(pos)
						ent:Spawn()
						ent:SetNetworkedString("Owner", "World")
						
					end
					
					PNRP.TakeFromInventory( ply, data.ID )
				else
					
					local ent = ents.Create(data.Ent)
					local pos = data.Pos + Vector(0,0,20)
--					if data.Ent == "weapon_seat" then
--						ent:SetNetworkedString("Type", "1")
--					end
					ent:SetModel(data.Model)
					ent:SetKeyValue( "actionScale", 1 ) 
					ent:SetKeyValue( "VehicleLocked", 0 ) 
					ent:SetKeyValue( "solid", 6 ) 
					ent:SetKeyValue( "vehiclescript", data.Script ) 
					ent:SetAngles(Angle(0,0,0))
					ent:SetPos(pos)
					ent:SetKeyValue( "model", data.Model )
					
					ent:Spawn()
					ent:Activate()
					--ent:SetNetworkedString("Owner", ply:Nick())
					--ent:SetNetworkedString("Owner_UID", plUID)
					--ent:SetNWEntity( "ownerent", ply )
					PNRP.SetOwner(ply, ent)
					PNRP.TakeFromInventory( ply, data.ID )
					PNRP.AddWorldCache( ply, data.ID )
				end	
				
			end
		
		else
		
		end
	end
end

function PNRP.DropCarSpawn( ply, ID, q )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( ID ) == itemname then
			local tr = ply:TraceFromEyes(200)
			
			ply:ChatPrint("Dropping "..item.Name)
			local data = {}
			data.Pos = tr.HitPos
			data.ID = item.ID
			data.Name = item.Name
			data.Chance = item.Chance
			data.Scrap = item.Scrap
			data.SmallParts = item.SmallParts
			data.Chems = item.Chemicals
			data.Script = item.Script
			data.Ent = item.Ent
			data.Model = item.Model
			data.ToolCheck = item.ToolCheck
			for i = 1, q do
				
				if item.Type ~= "vehicle" then
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
					local pos = data.Pos + Vector(0,0,20)
					if item.Type == "tool" then
						item.Create(ply, item.Ent, pos)
						
					else
						local ent 
						if item.Type == "weapon" and item.ID ~= "wep_grenade" then
							ent = ents.Create("ent_weapon")
							ent:SetNWString("WepClass", data.Ent)
							ent:SetNetworkedInt("Ammo", 0)
						elseif item.Type == "ammo" then
							ent = ents.Create(data.Ent)
							ent:SetNetworkedString("Ammo", tostring(item.Energy))
						else
							ent = ents.Create(data.Ent)
						end
						ent:SetModel(data.Model)
						ent:SetAngles(Angle(0,0,0))
						ent:SetPos(pos)
						ent:Spawn()
						ent:SetNetworkedString("Owner", "World")
						
					end
					
					PNRP.TakeFromCarInventory( ply, data.ID )
				else
					
					local ent = ents.Create(data.Ent)
					local pos = data.Pos + Vector(0,0,20)
--					if data.Ent == "weapon_seat" then
--						ent:SetNetworkedString("Type", "1")
--					end
					ent:SetModel(data.Model)
					ent:SetKeyValue( "actionScale", 1 ) 
					ent:SetKeyValue( "VehicleLocked", 0 ) 
					ent:SetKeyValue( "solid", 6 ) 
					ent:SetKeyValue( "vehiclescript", data.Script ) 
					ent:SetAngles(Angle(0,0,0))
					ent:SetPos(pos)
					ent:SetKeyValue( "model", data.Model )
					
					ent:Spawn()
					ent:Activate()
					--ent:SetNetworkedString("Owner", ply:Nick())
					--ent:SetNWEntity( "ownerent", ply )
					PNRP.SetOwner(ply, ent)
					PNRP.TakeFromCarInventory( ply, data.ID )
					PNRP.AddWorldCache( ply, data.ID )
				end
				
			end
		
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
	
	if tostring(command) == "pnrp_dosalvage"  or tostring(command) == "pnrp_docarsalvage" then
		ItemID = arg[1]
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
			
			if team.GetName(ply:Team()) == "Wastelander" or team.GetName(ply:Team()) == "Scavenger" then
				scrap = math.Round(PNRP.Items[ItemID].Scrap * (0.5 + (ply:GetSkill("Salvaging") * 0.05)))
				smallparts =  math.Round(PNRP.Items[ItemID].SmallParts * (0.5 + (ply:GetSkill("Salvaging") * 0.05))) 
				chemicals = math.Round(PNRP.Items[ItemID].Chemicals * (0.5 + (ply:GetSkill("Salvaging") * 0.05)))
			else	
				scrap = math.Round(PNRP.Items[ItemID].Scrap * (0.25 + (ply:GetSkill("Salvaging") * 0.05)))
				smallparts =  math.Round(PNRP.Items[ItemID].SmallParts * (0.25 + (ply:GetSkill("Salvaging") * 0.05))) 
				chemicals = math.Round(PNRP.Items[ItemID].Chemicals * (0.25 + (ply:GetSkill("Salvaging") * 0.05)))
			end	
			
			Msg(ply:Nick().."Salvaged "..tostring(scrap).." "..tostring(smallparts).." "..tostring(chemicals).."\n")
			ply:IncResource("Scrap", scrap)
			ply:IncResource("Small_Parts", smallparts)
			ply:IncResource("Chemicals", chemicals)

			if tostring(command) == "pnrp_dosalvage" then
				PNRP.TakeFromInventory( ply, ItemID )
			else
				if tostring(command) == "pnrp_docarsalvage" then
					PNRP.TakeFromCarInventory( ply, ItemID )
				else
					ent:Remove()
				end
			end
			
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