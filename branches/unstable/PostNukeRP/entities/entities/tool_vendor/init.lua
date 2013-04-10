AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.AddNetworkString("vendor_select_menu")
util.AddNetworkString("SetVendor")
util.AddNetworkString("vendor_shop_menu")
util.AddNetworkString("VendorOwnerShop")
util.AddNetworkString("VendorReset")
util.AddNetworkString("VendorGetRes")
util.AddNetworkString("VendorRename")
util.AddNetworkString("vendor_take")
util.AddNetworkString("BuyFromVendor")
util.AddNetworkString("ChangeVendorModel")

util.PrecacheModel ("models/props/cs_office/vending_machine.mdl")

function ENT:Initialize()
--	self.Entity:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.pid = self.Entity:GetNWString("Owner_UID")
	self.vendorID = self.Entity:GetNWString("vendorid")
	self.name = self.Entity:GetNWString("name")
	self.Enabled = false
	
	self.availableModels = {
		"models/props/cs_office/vending_machine.mdl",
		"models/props_interiors/vendingmachinesoda01a.mdl",
		"models/props/de_tides/vending_cart.mdl",
		"models/props_combine/health_charger001.mdl",
		"models/props_combine/suit_charger001.mdl",
		"models/props_c17/display_cooler01a.mdl",
		"models/props_c17/cashregister01a.mdl",
		"models/props/CS_militia/bar01.mdl",
		"models/props/CS_militia/mailbox01.mdl",
		"models/props/cs_assault/TicketMachine.mdl"
	}
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
	
end

function ENT:Use( activator, caller )
--	if not self.Enabled then return end 
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local vendorID = self.vendorID
			if tostring(self:GetNetworkedString( "Owner_UID" , "None" )) == PNRP:GetUID( activator ) then
				local result = querySQL("SELECT * FROM vending_table WHERE pid="..tostring(activator.pid))

				if vendorID == nil or vendorID == "" then
					if result then
						net.Start("vendor_select_menu")
							net.WriteEntity(self)
							net.WriteTable(result)
						net.Send(activator)
					else
						net.Start("vendor_new_menu")
							net.WriteEntity(self)
						net.Send(activator)
					end
				else
					local result = querySQL("SELECT * FROM vending_table WHERE vendorid="..tostring(vendorID))
					local capString = tostring(getVendorCapacity(vendorID)).."/"..tostring(PNRP.Items["tool_vendor"].Capacity)
					net.Start("vendor_menu")
						net.WriteEntity(self)
						net.WriteTable(result)
						net.WriteTable(PNRP.Inventory( activator ))
						net.WriteTable(self.availableModels)
						net.WriteString(capString)
					net.Send(activator)
				end
			else
				if vendorID == nil or vendorID == "" then
					activator:ChatPrint( "This vendor has not been set!" )
				else
					local result = querySQL("SELECT * FROM vending_table WHERE vendorid="..tostring(vendorID))	
					local plyInv = PNRP.Inventory( activator )
					if not plyInv then plyInv = {} end
					net.Start("vendor_shop_menu")
						net.WriteEntity(self)
						net.WriteTable(result)
						net.WriteTable(plyInv)
					net.Send(activator)
				end
			end
		end
	end
end
util.AddNetworkString("CreateNewVendor")
util.AddNetworkString("vendor_menu")
util.AddNetworkString("vendor_new_menu")

function getVendorCapacity(vendorID)

	local query = "SELECT inventory FROM vending_table WHERE vendorid="..tostring(vendorID)
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

function ChangeVendorModel( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local vendorModel = net.ReadString()
	
	local effectdata = EffectData()
	effectdata:SetStart( vendorENT:LocalToWorld( Vector( 0, 0, 0 ) ) ) 
	effectdata:SetOrigin( vendorENT:LocalToWorld( Vector( 0, 0, 0 ) ) )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetScale( 0.7 )
	util.Effect( "ManhackSparks", effectdata )
	vendorENT:EmitSound("ambient/levels/labs/electric_explosion5.wav", 100, 100 )

	local oldRad = vendorENT:GetCollisionBounds()
	vendorENT:SetModel(vendorModel)
	local newRad = vendorENT:GetCollisionBounds()
	local setRad = oldRad - newRad
	local pos = vendorENT:GetPos() 
	vendorENT:SetPos(pos + setRad)
	vendorENT:SetAngles( ply:GetAngles()-Angle(0,90,0) )
	vendorENT:Spawn()
	vendorENT:Activate()
	vendorENT:GetPhysicsObject():Wake()

end
net.Receive( "ChangeVendorModel", ChangeVendorModel )

function CreateNewVendor( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local vendorName = net.ReadString()

	local itemID = PNRP.FindItemID( vendorENT:GetClass() )

	local costStr = string.Explode( " ", PNRP.Items[itemID].ProfileCost)
	local pScr = tonumber(costStr[1])
	local pSP = tonumber(costStr[2])
	local pChem = tonumber(costStr[3])
	
	local make = false
	
	local chkStoreage = querySQL("SELECT * FROM vending_table WHERE pid='"..tonumber(ply.pid).."'")
	if chkStoreage then
		if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
			ply:ChatPrint("Admin No Cost")
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
		local query = "INSERT INTO vending_table VALUES ( NULL, '"..ply.pid.."', "..SQLStr(vendorName)..", NULL, NULL )"
		local result = querySQL(query)
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ply:ChatPrint( "You were unable to make a new Vendor Profile, check your resources." )
	end

end
net.Receive( "CreateNewVendor", CreateNewVendor )

function deleteVendor( p, command, arg )
	local vendorID = arg[1]
	
	querySQL("DELETE FROM vending_table WHERE vendorid='"..tonumber(vendorID).."'")
end
concommand.Add( "deleteVendor", deleteVendor )

function SetVendor( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local vendorID = net.ReadDouble()
	local vendorName = net.ReadString()
	
	local foundVendors = ents.FindByClass("tool_vendor")
	for k, v in pairs(foundVendors) do
		if tostring(v.vendorID) == tostring(vendorID) then
			ply:ChatPrint( "This vendor is allready set!" )
			return
		end
	end
	vendorENT:SetNetworkedString("vendorid", vendorID)
	vendorENT:SetNetworkedString("name", vendorName)
	
	vendorENT.vendorID = vendorID
	vendorENT.name = vendorName
end
net.Receive( "SetVendor", SetVendor )

function VendorReset( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	cleanupDispItems(vendorENT.vendorID)
	
	vendorENT:SetNetworkedString("vendorid", nil)
	vendorENT:SetNetworkedString("name", ply:Nick().."'s Vending Machine")
	
	vendorENT.vendorID = nil
	vendorENT.name = ply:Nick().."'s Vending Machine"
end
net.Receive( "VendorReset", VendorReset )

function VendorRename( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local vendorID = net.ReadDouble()
	local vendorName = net.ReadString()
	
	if vendorENT.vendorID == vendorID then
		vendorENT.name = vendorName
		vendorENT:SetNetworkedString("name", vendorName)
	end
	
	query = "UPDATE vending_table SET name="..SQLStr(vendorName).." WHERE vendorid='"..tostring(vendorID).."'"
	result = querySQL(query)

end
net.Receive( "VendorRename", VendorRename )

function VendorGetRes( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	local result = querySQL("SELECT res FROM vending_table WHERE vendorid="..tostring(vendorENT.vendorID))
	if result then
		local vendorRes = result[1]["res"]
		local vendScrap = 0
		local vendSP = 0
		local vendChems = 0
		
		if string.len(tostring(vendorRes)) > 3 then
			local resSplit = string.Explode( ",", vendorRes )
			if table.Count( resSplit ) > 1 then
				vendScrap = tonumber(resSplit[1])
				vendSP = tonumber(resSplit[2])
				vendChems = tonumber(resSplit[3])
			end
		end
		
		if vendScrap == 0 and vendSP == 0 and vendChems == 0 then
			ply:ChatPrint( "Vendor has no resources to give!" )
			return
		end
		
		if vendScrap > 0 then
			ply:IncResource( "Scrap", vendScrap )
			ply:ChatPrint("You have taken "..tostring(vendScrap).." scrap from the vendor.")
		end
		if vendSP > 0 then
			ply:IncResource( "Small_Parts", vendSP )
			ply:ChatPrint("You have taken "..tostring(vendSP).." small parts from the vendor.")
		end
		if vendChems > 0 then
			ply:IncResource( "Chemicals", vendChems )
			ply:ChatPrint("You have taken "..tostring(vendChems).." chemicals from the vendor.")
		end
		
		local newRes = tostring("0,0,0")
		
		query = "UPDATE vending_table SET res='"..newRes.."' WHERE vendorid='"..tostring(vendorENT.vendorID).."'"
		result = querySQL(query)
		
	else
		ply:ChatPrint( "Unable to find vendor!" )
	end
	
end
net.Receive( "VendorGetRes", VendorGetRes )

function VendorOwnerShop( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	local vendorID = vendorENT.vendorID
	
	result = querySQL("SELECT * FROM vending_table WHERE vendorid="..tostring(vendorID))
	net.Start("vendor_shop_menu")
		net.WriteEntity(vendorENT)
		net.WriteTable(result)
		net.WriteTable(PNRP.Inventory( ply ))
	net.Send(ply)
end
net.Receive( "VendorOwnerShop", VendorOwnerShop )

function TakeFromVendor( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
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
		if remVendorItem( vendorENT.vendorID, Item, Amount ) then
			ply:AddToInventory( Item, Amount )
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			
			checkRMDispItems(ply, Item, vendorENT.vendorID)
		else
			ply:ChatPrint("Unable to take item from Vendor")
		end
	else
		local weightDiff = weightCalc - weightCap
		local extra = math.ceil(weightDiff/weight)
		
		if extra >= Amount then
			ply:ChatPrint("You can't carry any of these!")
		else
			local taken = Amount - extra
			if remVendorItem( vendorENT.vendorID, Item, taken ) then
				ply:AddToInventory( Item, taken )
				
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
				ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
				
				checkRMDispItems(ply, Item, vendorENT.vendorID)
			else
				ply:ChatPrint("Unable to take item from Vendor")
			end
		end
	end
end
net.Receive( "vendor_take", TakeFromVendor )

function remVendorItem( vendorID, Item, Amount )
	query = "SELECT inventory FROM vending_table WHERE vendorid="..tostring(vendorID)
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
				
				invTbl[invSplit[1]] = tostring(invSplit[2]..","..invSplit[3]..","..invSplit[4]..","..invSplit[5])
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
			query = "UPDATE vending_table SET inventory='"..newInvString.."' WHERE vendorid='"..tostring(vendorID).."'"
			result = querySQL(query)
		end
	end
	
	return foundItem
end

function setVendorSellItem( p, command, arg )
	local vendorID = arg[1]
	local itemID = arg[2]
	local costString = arg[3]
	local option = arg[4]
	
	local costTable = string.Explode(" ", costString)
	local count = costTable[1]
	local scrap = costTable[2]
	local SP = costTable[3]
	local chems = costTable[4]
	costString = string.gsub(costString, "%s+", ",") 
	
	local item = {}
	
	local query
	local result
	
	if option == "new" then
		local totalStCap = PNRP.Items[itemID].Weight * count + getVendorCapacity(vendorID)
		if totalStCap > PNRP.Items["tool_vendor"].Capacity then
			p:ChatPrint("Not enough space in vendor")
			return
		end
		
		local Check = PNRP.TakeFromInventoryBulk( p, itemID, tonumber(count) )
		if not Check then
			p:ChatPrint("You do not have enough of this")
			return
		end
	end
	
	query = "SELECT inventory FROM vending_table WHERE vendorid="..tostring(vendorID)
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
				
				invTbl[invSplit[1]] = tostring(invSplit[2]..","..invSplit[3]..","..invSplit[4]..","..invSplit[5])
			end
	
			for k, v in pairs(invTbl) do
				if k == itemID then
					local stringSplit = string.Explode(",", v)
					local totalCount = tonumber(stringSplit[1]) + tonumber(count)
					local newCostString = tostring(totalCount)..","..scrap..","..SP..","..chems
					invTbl[itemID] = tostring(newCostString)
					foundItem = true
				end
			end
		end

		if not foundItem then
			invTbl[itemID] = tostring(costString)
		end
		
		local newInvString = ""
		for k, v in pairs(invTbl) do
			newInvString = newInvString.." "..tostring(k)..","..tostring(v)
		end
		newInvString = string.Trim(newInvString)
		query = "UPDATE vending_table SET inventory='"..newInvString.."' WHERE vendorid='"..tostring(vendorID).."'"
		result = querySQL(query)
		updateDispItemCost(vendorID, itemID, costTable)
		p:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No Vendor match in vending_table! ["..tostring(vendorID).."] \n")
	end
end
concommand.Add( "setVendorSellItem", setVendorSellItem )

function updateDispItemCost(vendorID, itemID, costTable)
	vendorID = tonumber(vendorID)
	local costString = costTable[1]..","..costTable[2]..","..costTable[3]..","..costTable[4]
	local foundDispItems = ents.FindByClass("msc_display_item")
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == itemID then
			v.cost = costString
			v:SetNWString("cost", costString)
		end
	end
end

function doBuyFromVendor( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local Amount = net.ReadDouble()
	local Item = net.ReadString()
	local Cost = net.ReadTable()
	local vendorID = vendorENT.vendorID
	
	BuyFromVendor(ply, vendorID, Item, Cost, Amount, "vendor")
end
net.Receive( "BuyFromVendor", doBuyFromVendor )

function BuyFromVendor(ply, vendorID, Item, Cost, Amount, From )
	
	local enough = false
	local soldItem = false
	
	local totalScrap = 0
	local totalSmall = 0
	local totalChems = 0
	
	Cost[1] = tonumber(Cost[1])
	Cost[2] = tonumber(Cost[2])
	Cost[3] = tonumber(Cost[3])
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	--Verifies Player has the needed Resources to buy the item
	if ply:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then
		enough = true
	else
		totalScrap = Cost[1] * Amount
		totalSmall = Cost[2] * Amount
		totalChems = Cost[3] * Amount
		if math.Round(ply:GetResource("Scrap")) >= totalScrap and math.Round(ply:GetResource("Chemicals")) >= totalChems and math.Round(ply:GetResource("Small_Parts")) >= totalSmall then 
			enough = true
		else
			enough = false
		end
	end
	
	if enough == true then
		local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
		if weightCalc <= weightCap then
			if remVendorItem( vendorID, Item, Amount ) then
				ply:AddToInventory( Item, Amount )
				
				totalScrap = Cost[1] * Amount
				totalSmall = Cost[2] * Amount
				totalChems = Cost[3] * Amount
				
				ply:DecResource("Scrap", totalScrap)
				ply:DecResource("Small_Parts", totalSmall)
				ply:DecResource("Chemicals", totalChems)
				
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
				
				soldItem = true
			else
				ply:ChatPrint("Unable to take item from Vendor")
			end
		else
			local weightDiff = weightCalc - weightCap
			local extra = math.ceil(weightDiff/weight)
			
			if extra >= Amount then
				ply:ChatPrint("You can't carry any of these!")
			else
				local taken = Amount - extra
				if remVendorItem( vendorID, Item, taken ) then
					ply:AddToInventory( Item, taken )
					
					totalScrap = Cost[1] * taken
					totalSmall = Cost[2] * taken
					totalChems = Cost[3] * taken
					
					ply:DecResource("Scrap", totalScrap)
					ply:DecResource("Small_Parts", totalSmall)
					ply:DecResource("Chemicals", totalChems)
					
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
					
					soldItem = true
				else
					ply:ChatPrint("Unable to take item from Vendor")
				end
			end
		end
		
		
	else
		ply:ChatPrint("You can afford this!")
	end
	if soldItem then
		
		local result = querySQL("SELECT res FROM vending_table WHERE vendorid="..tostring(vendorID))
		local vendorRes = result[1]["res"]
		local vendScrap = 0
		local vendSP = 0
		local vendChems = 0
		
		if string.len(vendorRes) > 3  then
			local resSplit = string.Explode( ",", vendorRes )
			if table.Count( resSplit ) > 1 then
				vendScrap = tonumber(resSplit[1])
				vendSP = tonumber(resSplit[2])
				vendChems = tonumber(resSplit[3])
			end
		end
		
		totalScrap = totalScrap + vendScrap
		totalSmall = totalSmall + vendSP
		totalChems = totalChems + vendChems
			
		local newRes = tostring(totalScrap..","..totalSmall..","..totalChems)
		newRes = string.Trim(newRes)

		local resultRes = querySQL("UPDATE vending_table SET res='"..tostring(newRes).."' WHERE vendorid="..tostring(vendorID))
		
		if From == "vendor" then
			checkRMDispItems(ply, Item, vendorID)
		end
	end
	
	return soldItem
end

--Finds nearest display item and deletes it if needed
function checkRMDispItems(ply, itemID, vendorID)
	local Pos = ply:GetPos()
	local itmCount = 0
	local itemString = string.Explode( ",", getItemInfo(itemID, vendorID))
	itmCount = itemString[1]
	local foundDispItems = ents.FindByClass("msc_display_item")
	local disItemTable = {}
	local distTable = {}
	local idCount = 0
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == itemID then
			if itmCount == 0 then
				v:Remove()
			else
				local dist = v:GetPos():Distance(Pos)
				disItemTable[dist] = v
				table.insert(distTable, dist)
				idCount = idCount + 1
			end
		end
	end
	
	if idCount > (itmCount - 1) then
		table.sort(distTable)
		local numREM = idCount - itmCount
		for i=1, numREM,1 do 
			local remENT = disItemTable[distTable[i]]
			if IsValid(remENT) then
				remENT:Remove()
			end
		end
	end
end

function clsDispItems()
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	cleanupDispItems(vendorENT.vendorID)
end
net.Receive( "clsDispItems", clsDispItems )
util.AddNetworkString("clsDispItems")

--Cleans up all Display Items
function cleanupDispItems(vendorID)
	local foundDispItems = ents.FindByClass("msc_display_item")
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID then
			v:Remove()
		end
	end
end

--Gets the cost and count string
function getItemInfo(itemID, vendorID)
	local returnString = "0,0,0,0"
	query = "SELECT inventory FROM vending_table WHERE vendorid='"..tostring(vendorID).."'"
	result = querySQL(query)
	if result then
		local invTbl = {}
		local getInvTable = result[1]["inventory"]
		local invLongStr = string.Explode( " ", getInvTable )
		for _, invStr in pairs( invLongStr ) do
			local invSplit = string.Explode( ",", invStr )
			
			invTbl[invSplit[1]] = tostring(invSplit[2]..","..invSplit[3]..","..invSplit[4]..","..invSplit[5])
		end
		for k, v in pairs(invTbl) do
			if k == itemID then
				returnString = v
			end
		end
		
	end
	
	return returnString
end

function VendorCreateDisplayItem()
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local itemID = net.ReadString()
	local vendorID = vendorENT.vendorID
	local item = PNRP.Items[itemID]
	local plUID = PNRP:GetUID( ply )
	
	local pos = ply:GetPos()
	
	local infoString = getItemInfo(itemID, vendorID)
	local infoTable = string.Explode( ",", infoString )
	local itmCount = infoTable[1]
	
	local idCount = 0
	local foundDispItems = ents.FindByClass("msc_display_item")
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == itemID then
			if itmCount == 0 then
				v:Remove()
			else
				idCount = idCount + 1
			end
		end
	end
	if idCount < tonumber(itmCount) then
		local ent = ents.Create("msc_display_item")
		ent:SetAngles( ply:GetAngles()-Angle(0,180,0) )
		ent:SetPos(pos + Vector(0,0,20))
		ent:SetModel("models/props_junk/cardboard_box003b.mdl")
		ent:Spawn()
		ent:Activate()
		
		ent:SetNWString("itemID", itemID)
		ent:SetNWString("vendorid", vendorID)
		ent:SetNWString("cost", infoString)
		ent.vendorid = vendorID
		ent.item = itemID
		PNRP.SetOwner(ply, ent)
	else
		ply:ChatPrint("Not enough of this item in Vendor to create more Displays.")
	end
end
net.Receive( "VendorCreateDisplayItem", VendorCreateDisplayItem )
util.AddNetworkString("VendorCreateDisplayItem")

function ENT:OnRemove()
	cleanupDispItems(tonumber(self.vendorID))
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end