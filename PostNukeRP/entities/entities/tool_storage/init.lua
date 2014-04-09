AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("storage_menu")
util.AddNetworkString("storage_select_menu")
util.AddNetworkString("storage_new_menu")
util.AddNetworkString("storage_breakin")
util.AddNetworkString("StorageRepair")

util.PrecacheModel ("models/props_c17/Lockers001a.mdl")

function ENT:Initialize()
--	self.Entity:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.pid = self.Entity:GetNWString("Owner_UID")
	self.storageID = self.Entity:GetNWString("storageid")
	self.name = self.Entity:GetNWString("name")
	self.Enabled = false
	self.BreakInTimer = 60
	self.BreakingIn = nil
	self.Repairing = nil
	
	self.BlockF2 = true
	
	self.availableModels = {
		"models/props_c17/Lockers001a.mdl",
		"models/props_junk/wood_crate001a.mdl",
		"models/props_junk/wood_crate002a.mdl",
		"models/props/de_prodigy/prodcratesb.mdl",
		"models/props/de_nuke/crate_small.mdl",
		"models/props/CS_militia/footlocker01_closed.mdl",
		"models/props/CS_militia/crate_extrasmallmill.mdl",
		"models/props/CS_militia/boxes_garage_lower.mdl",
		"models/props/CS_militia/boxes_frontroom.mdl",
		"models/props_wasteland/controlroom_storagecloset001a.mdl",
		"models/props_c17/FurnitureDresser001a.mdl",
		"models/props/CS_militia/food_stack.mdl",
		"models/props/cs_office/Shelves_metal3.mdl",
		"models/props/de_inferno/wine_barrel.mdl",
		"models/props/de_prodigy/Ammo_Can_01.mdl",
		"models/props/de_prodigy/Ammo_Can_03.mdl"
	}
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
end

function ENT:Use( activator, caller )
--	if not self.Enabled then return end 
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local storageID = self.storageID
			if tostring(self:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( activator ) then
				local result = querySQL("SELECT * FROM player_storage WHERE pid="..tostring(activator.pid))

				if storageID == nil or storageID == "" then
					if result then
						net.Start("storage_select_menu")
							net.WriteEntity(self)
							net.WriteTable(result)
						net.Send(activator)
					else
						net.Start("storage_new_menu")
							net.WriteEntity(self)
						net.Send(activator)
					end
				else
					local result = querySQL("SELECT * FROM player_storage WHERE storageid="..tostring(storageID))
					local capString = tostring(getStorageCapacity(storageID)).."/"..tostring(PNRP.Items[self:GetClass()].Capacity)
					net.Start("storage_menu")
						net.WriteEntity(self)
						net.WriteTable(result)
						net.WriteTable(PNRP.Inventory( activator ))
						net.WriteTable(self.availableModels)
						net.WriteDouble(math.Round((self.BreakInTimer / 60) * 100))
						net.WriteString(capString)
					net.Send(activator)
				end
			else
				if storageID == nil or storageID == "" then
					activator:ChatPrint( "This Storage Container has not been set!" )
				else
					--If not owner then start break in
					net.Start("storage_breakin")
						net.WriteEntity(self)
						net.WriteDouble(self.BreakInTimer)
					net.Send(activator)
				end
			end
		end
	end
end
util.AddNetworkString("storage_new_menu")
util.AddNetworkString("storage_breakin")

function getStorageCapacity(storageID)

	local query = "SELECT inventory FROM player_storage WHERE storageid="..tostring(storageID)
	local result = querySQL(query)
	
	local weightSum = 0
	
	if result then
		local getInvTable = result[1]["inventory"]

		local invTbl = {}
		if getInvTable == nil or getInvTable == "" or tostring(getInvTable) == "NULL" then
			return 0
		else
			local invLongStr = string.Explode( " ", getInvTable )
			for _, invStr in pairs( invLongStr ) do
				local invSplit = string.Explode( ",", invStr )
				
				local Item = PNRP.Items[invSplit[1]]
				if Item != nil then
					if Item.Type ~= "vehicle" then
						local tmpW = tonumber(Item.Weight) * tonumber(invSplit[2])
						weightSum = weightSum + tmpW
					end
				end
			end
		end
	end
	
	return weightSum
end

function ChangeStorageModel( )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local storageModel = net.ReadString()
	
	local storageID = storageENT.storageID
	
	if math.Round((storageENT.BreakInTimer / 60) * 100) < 99 then
		ply:ChatPrint("Unable to change model. Repair Storage first.")
		return
	end
	
	local effectdata = EffectData()
	effectdata:SetStart( storageENT:LocalToWorld( Vector( 0, 0, 0 ) ) ) 
	effectdata:SetOrigin( storageENT:LocalToWorld( Vector( 0, 0, 0 ) ) )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetScale( 0.7 )
	util.Effect( "ManhackSparks", effectdata )
	storageENT:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100, 100 ) 
	
	local oldRad = storageENT:GetCollisionBounds()
	storageENT:SetModel(storageModel)
	local newRad = storageENT:GetCollisionBounds()
	local setRad = oldRad - newRad
	local pos = storageENT:GetPos() 
	storageENT:SetPos(pos + setRad)
	storageENT:SetAngles( ply:GetAngles()-Angle(0,180,0) )
	storageENT:Spawn()
	storageENT:Activate()
	storageENT:GetPhysicsObject():Wake()

end
util.AddNetworkString("ChangeStorageModel")
net.Receive( "ChangeStorageModel", ChangeStorageModel )

function CreateNewStorage( )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local storageName = net.ReadString()
	
	local itemID = PNRP.FindItemID( storageENT:GetClass() )

	local costStr = string.Explode( " ", PNRP.Items[itemID].ProfileCost)
	local pScr = tonumber(costStr[1])
	local pSP = tonumber(costStr[2])
	local pChem = tonumber(costStr[3])
	
	local make = false
	
	local chkStoreage = querySQL("SELECT * FROM player_storage WHERE pid='"..tonumber(ply.pid).."'")
	if chkStoreage then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
			ply:ChatPrint("You created this profile using admin no-cost...")
			make = true
		else
			if ply:GetResource("Scrap") >= pScr and ply:GetResource("Chemicals") >= pChem and ply:GetResource("Small_Parts") >= pSP then 
				make = true
				
				ply:DecResource("Scrap", pScr)
				ply:DecResource("Small_Parts", pSP)
				ply:DecResource("Chemicals", pChem)
			else
				make = false
			end
		end
	else
		make = true
	end
	
	if make then
		local query = "INSERT INTO player_storage VALUES ( NULL, '"..ply.pid.."', "..SQLStr(storageName)..", NULL, NULL )"
		local result = querySQL(query)
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ply:ChatPrint( "You were unable to make a new Storage Profile, check your resources." )
	end

end
util.AddNetworkString("CreateNewStorage")
net.Receive( "CreateNewStorage", CreateNewStorage )

function deleteStorage( p, command, arg )
	local storageID = arg[1]
	
	querySQL("DELETE FROM player_storage WHERE storageid='"..tonumber(storageID).."'")
end
concommand.Add( "deleteStorage", deleteStorage )

function SetStorage( )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local storageID = net.ReadDouble()
	local storageName = net.ReadString()
	
	local foundStorage= ents.FindByClass("tool_storage")
	for k, v in pairs(foundStorage) do
		if tostring(v.storageID) == tostring(storageID) then
			ply:ChatPrint( "This profile is already in-use!" )
			return
		end
	end
	storageENT:SetNetworkedString("storageid", storageID)
	storageENT:SetNetworkedString("name", storageName)
	
	storageENT.storageID = storageID
	storageENT.name = storageName
end
util.AddNetworkString("SetStorage")
net.Receive( "SetStorage", SetStorage )

function StorageRename( )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local storageID = net.ReadDouble()
	local storageName = net.ReadString()
	
	if storageENT.storageID == storageID then
		storageENT.name = storageName
		storageENT:SetNetworkedString("name", storageName)
	end
	
	query = "UPDATE player_storage SET name="..SQLStr(storageName).." WHERE storageid='"..tostring(storageID).."'"
	result = querySQL(query)

end
util.AddNetworkString("StorageRename")
net.Receive( "StorageRename", StorageRename )

function TakeFromStorage( )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local Item = net.ReadString()
	local Amount = net.ReadDouble()
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
	if weightCalc <= weightCap then
		if remStorageItem( storageENT.storageID, Item, Amount ) then
			ply:AddToInventory( Item, Amount )
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
		else
			ply:ChatPrint("Unable to take item from storage.")
		end
	else
		local weightDiff = weightCalc - weightCap
		local extra = math.ceil(weightDiff/weight)
		
		if extra >= Amount then
			ply:ChatPrint("You can't carry any of these!")
		else
			local taken = Amount - extra
			if remStorageItem( storageENT.storageID, Item, taken ) then
				ply:AddToInventory( Item, taken )
				
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
				ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
			else
				ply:ChatPrint("Unable to take item from storage.")
			end
		end
	end
end
util.AddNetworkString("storage_take")
net.Receive( "storage_take", TakeFromStorage )

function remStorageItem( storageID, Item, Amount )
	query = "SELECT inventory FROM player_storage WHERE storageid="..tostring(storageID)
	result = querySQL(query)
	local foundItem = false
	
	if result then
		local getInvTable = result[1]["inventory"]
		
		local invTbl = {}
		if getInvTable == nil or getInvTable == "" or tostring(getInvTable) == "NULL" then
			foundItem = false
		else
			local invLongStr = string.Explode( " ", getInvTable )
			for _, invStr in pairs( invLongStr ) do
				local invSplit = string.Explode( ",", invStr )
				
				invTbl[invSplit[1]] = tostring(invSplit[2])
			end
	
			for k, v in pairs(invTbl) do
				if k == Item then
					local stringSplit = string.Explode(",", v)
					local totalCount = tonumber(stringSplit[1]) - tonumber(Amount)
					if totalCount <= 0 then
						invTbl[Item] = nil
					else
						local newCostString = tostring(totalCount)..","..tostring(stringSplit[2])..","..tostring(stringSplit[3])..","..tostring(stringSplit[4])
						invTbl[Item] = tostring(newCostString)
					end
					
					foundItem = true
				end
			end
			
		end
		
		if foundItem then
			local newInvString = ""
			for k, v in pairs(invTbl) do
				newInvString = newInvString.." "..tostring(k)..","..tostring(v)
			end
			newInvString = string.Trim(newInvString)
			query = "UPDATE player_storage SET inventory='"..newInvString.."' WHERE storageid='"..tostring(storageID).."'"
			result = querySQL(query)
		end
	end
	
	return foundItem
end

function sendToPlayerStorage( p, command, arg )
	local ply = net.ReadEntity()
	local storageENT = net.ReadEntity()
	local itemID = net.ReadString()
	local count = net.ReadDouble()
	local storageID = storageENT.storageID

--	print("["..tostring(itemID).."] "..tostring(count))
	local item = {}
	
	local query
	local result
	
	local totalStCap = PNRP.Items[itemID].Weight * count + getStorageCapacity(storageID)
	if totalStCap > PNRP.Items[storageENT:GetClass()].Capacity then
		ply:ChatPrint("Not enough space in storage.")
		return
	end
	
	local Check = PNRP.TakeFromInventoryBulk( ply, itemID, tonumber(count) )
	if not Check then
		ply:ChatPrint("You do not have enough of this.")
		return
	end
		
	query = "SELECT inventory FROM player_storage WHERE storageid="..tostring(storageID)
	result = querySQL(query)

	-- Inventory string design:  itemID, count scrap smallpats chems
	if result then
		local getInvTable = result[1]["inventory"]
		local foundItem = false

		local invTbl = {}
		if getInvTable == nil or getInvTable == "" or tostring(getInvTable) == "NULL" then
			foundItem = false
		else
			local invLongStr = string.Explode( " ", getInvTable )
			for _, invStr in pairs( invLongStr ) do
				local invSplit = string.Explode( ",", invStr )
				
				invTbl[invSplit[1]] = tostring(invSplit[2])
			end
	
			for k, v in pairs(invTbl) do
				if k == itemID then
					local totalCount = tonumber(v) + tonumber(count)
					invTbl[itemID] = totalCount
					foundItem = true
				end
			end
		end

		if not foundItem then
			invTbl[itemID] = tonumber(count)
		end
		
		local newInvString = ""
		for k, v in pairs(invTbl) do
			newInvString = newInvString.." "..tostring(k)..","..tostring(v)
		end
		newInvString = string.Trim(newInvString)
		query = "UPDATE player_storage SET inventory='"..newInvString.."' WHERE storageid='"..tostring(storageID).."'"
		result = querySQL(query)
		
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No StorageProfile match in player_storage! ["..tostring(storageID).."] \n")
	end
end
util.AddNetworkString("storage_give")
net.Receive( "storage_give", sendToPlayerStorage )


function StorageBreakIn( )
	local ply = net.ReadEntity()
	local storage = net.ReadEntity()
	local storageID = storage.storageID
	
	--local storage = decoded["storage"]
	if not storage then 
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		return 
	end
	
	if storage.Repairing then
		ply:ChatPrint("You can't break in while someone's repairing this storage!")
		return
	end
	
	result = querySQL("SELECT * FROM player_storage WHERE storageid="..tostring(storageID))
	local capString = tostring(getStorageCapacity(storageID)).."/"..tostring(PNRP.Items[storage:GetClass()].Capacity)
			
	if not storage.BreakingIn then
		if storage.BreakInTimer <= 0 then
			net.Start("storage_stopbreakin")
			net.Send(ply)
						
			net.Start("storage_menu")
				net.WriteEntity(storage)
				net.WriteTable(result)
				net.WriteTable(PNRP.Inventory( ply ))
				net.WriteTable(storage.availableModels)
				net.WriteDouble(math.Round((storage.BreakInTimer / 60) * 100))
				net.WriteString(capString)
			net.Send(ply)

		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			storage.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(storage:EntIndex()), 1, storage.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not storage:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("storage_stopbreakin")
					net.Send(ply)
					if storage:IsValid() then 
						storage.BreakingIn = nil 
						timer.Stop(ply:UniqueID()..tostring(storage:EntIndex()))
					end
					return
				end
				storage.BreakInTimer = storage.BreakInTimer - 1
				if storage.BreakInTimer <= 0 then
					net.Start("storage_stopbreakin")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					storage.BreakingIn = nil
									
					net.Start("storage_menu")
						net.WriteEntity(storage)
						net.WriteTable(result)
						net.WriteTable(PNRP.Inventory( ply ))
						net.WriteTable(storage.availableModels)
						net.WriteDouble(math.Round((storage.BreakInTimer / 60) * 100))
						net.WriteString(capString)
					net.Send(ply)

					storage:EmitSound("physics/wood/wood_box_break2.wav",100,100)
					timer.Stop(ply:UniqueID()..tostring(storage:EntIndex()))
				else
					storage:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		end
	elseif ply == storage.BreakingIn then
		timer.Destroy(ply:UniqueID()..tostring(storage:EntIndex()))
		net.Start("storage_stopbreakin")
		net.Send(ply)
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		if storage:IsValid() then
			storage.BreakingIn = nil
		end
	else
		ply:ChatPrint("Someone is already breaking into this storage.")
	end
end
net.Receive( "storage_breakin", StorageBreakIn )
util.AddNetworkString("storage_stopbreakin")

function StorageRepair( )
	local ply = net.ReadEntity()
	local storage = net.ReadEntity()
	local storageID = storage.storageID
	--local storage = decoded["storage"]
	if storage.BreakInTimer >= 60 then
		ply:ChatPrint("This storage is fully repaired!")
		return
	end
	if not storage.Repairing then
		if not storage.BreakingIn then
			net.Start("storage_repair")
				net.WriteEntity(storage)
				net.WriteDouble(storage.BreakInTimer)
			net.Send(ply)
			
			ply:SetMoveType(MOVETYPE_NONE)
			storage.Repairing = ply
			timer.Create( ply:UniqueID()..tostring(storage:EntIndex()), 1, storage.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not storage:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("storage_stoprepair")
					net.Send(ply)
					if storage:IsValid() then 
						storage.Repairing = nil 
						timer.Stop(ply:UniqueID()..tostring(storage:EntIndex()))
					end
					return
				end
				storage.BreakInTimer = storage.BreakInTimer + 1
				if storage.BreakInTimer >= 60 then
					net.Start("storage_stoprepair")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					storage.Repairing = nil
					storage.BreakInTimer = 60
					
					result = querySQL("SELECT * FROM player_storage WHERE storageid="..tostring(storageID))
					local capString = tostring(getStorageCapacity(storageID)).."/"..tostring(PNRP.Items[storage:GetClass()].Capacity)
					net.Start("storage_menu")
						net.WriteEntity(storage)
						net.WriteTable(result)
						net.WriteTable(PNRP.Inventory( ply ))
						net.WriteTable(storage.availableModels)
						net.WriteDouble(math.Round((storage.BreakInTimer / 60) * 100))
						net.WriteString(capString)
					net.Send(ply)
				
					timer.Stop(ply:UniqueID()..tostring(storage:EntIndex()))
				else
					storage:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		else
			ply:ChatPrint("You cannot repair it while someone is breaking in!")
		end
	elseif storage.Repairing == ply then
		net.Start("storage_stoprepair")
		net.Send(ply)
	else
		ply:ChatPrint("Someone is already repairing this storage.")
	end
end
net.Receive( "StorageRepair", StorageRepair )
util.AddNetworkString("storage_repair")
util.AddNetworkString("storage_stoprepair")

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end

function PlyRemStorage(ply, cmd, args)
	local storageID = args[1]
	local foundStorage= ents.FindByClass("tool_storage")
	for k, v in pairs(foundStorage) do
		if tostring(v.storageID) == tostring(storageID) then
			ply:ChatPrint( "Your storage will take 1 minute to break down.  It can be interacted with in that time." )
			timer.Simple(60, function ()
				if IsValid(v) then
					PNRP.AddToInventory( ply, "tool_storage", 1 )
					PNRP.TakeFromWorldCache( ply, "tool_storage" )
					v:Remove()
				end
			end)
		end
	end
end
concommand.Add( "pnrp_remstorage", PlyRemStorage )

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
