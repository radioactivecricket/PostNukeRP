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
	
	self.pid = self.Entity:GetNetVar("Owner_UID")
	self.vendorID = self.Entity:GetNetVar("vendorid")
	self.name = self.Entity:GetNetVar("name")
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
			if tostring(self:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID( activator ) then
				local result = querySQL("SELECT * FROM vending_table WHERE pid="..SQLStr(activator.pid))

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
					local vendInv = getFullVendorInventory(vendorID)
					getFullVendorInventory(vendorID)
					local capString = tostring(getVendorCapacity(vendorID)).."/"..tostring(PNRP.Items["tool_vendor"].Capacity)
					net.Start("vendor_menu")
						net.WriteEntity(self)
						net.WriteTable(vendInv)
						net.WriteTable(PNRP.GetFullInventory( activator ))
						net.WriteTable(self.availableModels)
						net.WriteString(capString)
					net.Send(activator)
				end
			else
				if vendorID == nil or vendorID == "" then
					activator:ChatPrint( "This vendor has not been set!" )
				else
					local vendInv = getFullVendorInventory(vendorID)
					local plyInv = PNRP.Inventory( activator )
					if not plyInv then plyInv = {} end
					net.Start("vendor_shop_menu")
						net.WriteEntity(self)
						net.WriteTable(vendInv)
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

function getFullVendorInventory(vendorID)
	local invTbl = {}
	invTbl["inv"] = {}
	local result = querySQL("SELECT * FROM vending_table WHERE vendorid="..SQLStr(vendorID))
	
	if result then
		invTbl["vendorid"] = result[1]["vendorid"]
		invTbl["name"] = result[1]["name"]
		invTbl["res"] = result[1]["res"]
		local invLongStr = string.Explode( " ", result[1]["inventory"]  )
		for _, invStr in pairs( invLongStr ) do
			local invSplit = string.Explode( ",", invStr )
			if table.Count(invSplit) > 1 then
				table.insert( invTbl["inv"], {itemid=invSplit[1], status_table="", iid="", count=invSplit[2], scrap=invSplit[3], sp=invSplit[4], chem=invSplit[5]} )
			end
		end
	end
	
	local Inv2 = PNRP.PersistOtherInventory( "vendor", vendorID )
	for k, v in pairs(Inv2) do
		local invSplit = string.Explode( ",", v["locdata"] )
		table.insert( invTbl["inv"], {itemid=v["itemid"], iid=v["iid"], status_table=v["status_table"], count=1, scrap=invSplit[2], sp=invSplit[3], chem=invSplit[4]} )
	end
	
	return invTbl
end

function getVendorCapacity(vendorID)

	local query = "SELECT inventory FROM vending_table WHERE vendorid="..SQLStr(vendorID)
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
	
	local Inv2 = PNRP.PersistOtherInventory( "vendor", vendorID )

	for k, v in pairs(Inv2) do
		if PNRP.Items[v["itemid"]].Type ~= "vehicle" then
			weightSum = weightSum + PNRP.Items[v["itemid"]].Weight
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
	
	local chkStoreage = querySQL("SELECT * FROM vending_table WHERE pid="..SQLStr(tonumber(ply.pid)))
	if chkStoreage then
		if ply:IsAdmin() and getServerSetting("adminNoCost") == 1 then 
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
		local query = "INSERT INTO vending_table VALUES ( NULL, "..SQLStr(ply.pid)..", "..SQLStr(vendorName)..", NULL, NULL )"
		local result = querySQL(query)
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ply:ChatPrint( "You were unable to make a new Vendor Profile, check your resources." )
	end

end
net.Receive( "CreateNewVendor", CreateNewVendor )

function deleteVendor( p, command, arg )
	local vendorID = arg[1]
	
	querySQL("DELETE FROM vending_table WHERE vendorid="..SQLStr(tonumber(vendorID)))
	querySQL("DELETE FROM inventory_table WHERE location='vendor' AND locid="..SQLStr(tonumber(vendorID)))
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
	vendorENT:SetNetVar("vendorid", vendorID)
	vendorENT:SetNetVar("name", vendorName)
	
	vendorENT.vendorID = vendorID
	vendorENT.name = vendorName
end
net.Receive( "SetVendor", SetVendor )

function VendorReset( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	cleanupDispItems(vendorENT.vendorID)
	
	vendorENT:SetNetVar("vendorid", nil)
	vendorENT:SetNetVar("name", ply:Nick().."'s Vending Machine")
	
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
		vendorENT:SetNetVar("name", vendorName)
	end
	
	query = "UPDATE vending_table SET name="..SQLStr(vendorName).." WHERE vendorid="..SQLStr(vendorID)
	result = querySQL(query)

end
net.Receive( "VendorRename", VendorRename )

function VendorGetRes( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	
	local result = querySQL("SELECT res FROM vending_table WHERE vendorid="..SQLStr(vendorENT.vendorID))
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
		
		query = "UPDATE vending_table SET res='"..newRes.."' WHERE vendorid="..SQLStr(vendorENT.vendorID)
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
	
	local vendInv = getFullVendorInventory(vendorID)
	net.Start("vendor_shop_menu")
		net.WriteEntity(vendorENT)
		net.WriteTable(vendInv)
		net.WriteTable(PNRP.Inventory( ply ))
	net.Send(ply)
end
net.Receive( "VendorOwnerShop", VendorOwnerShop )

function TakeFromVendor( )
	local ply = net.ReadEntity()
	local vendorENT = net.ReadEntity()
	local Item = net.ReadString()
	local Amount = net.ReadDouble()
	local iid = net.ReadString()
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = getServerSetting("packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = getServerSetting("packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
	
	if iid == nil or iid == "" then
		if weightCalc <= weightCap then
			if remVendorItem( vendorENT.vendorID, Item, Amount ) then
				ply:AddToInventory( Item, Amount )
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
				
				checkRMDispItems(ply, Item, vendorENT.vendorID, iid)
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
					
					checkRMDispItems(ply, Item, vendorENT.vendorID, iid)
				else
					ply:ChatPrint("Unable to take item from Vendor")
				end
			end
		end
	else
		if weightCalc <= weightCap then
			PNRP.PersistMoveTo( ply, iid, "player")	
			
			checkRMDispItems(ply, Item, vendorENT.vendorID, iid)
		else
			ply:ChatPrint("Unable to take item from vendor.")
		end
	end
end
net.Receive( "vendor_take", TakeFromVendor )

function remVendorItem( vendorID, Item, Amount )
	query = "SELECT inventory FROM vending_table WHERE vendorid="..SQLStr(vendorID)
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
			query = "UPDATE vending_table SET inventory='"..newInvString.."' WHERE vendorid="..SQLStr(vendorID)
			result = querySQL(query)
		end
	end
	
	return foundItem
end

function setVendorSellItem( l, p )
	local vendorID = net.ReadString()
	local itemID = net.ReadString()
	local costTbl = net.ReadTable()
	local option = net.ReadString()
	local iid = net.ReadString()
	
	local count = tonumber(costTbl["count"])
	local scrap = costTbl["scrap"]
	local SP = costTbl["sp"]
	local chems = costTbl["chems"]
	
	local item = {}
	
	local query
	local result
	
	if option == "new" then
		local itmWeight = PNRP.Items[itemID].Weight
		local totalStCap = itmWeight * count + getVendorCapacity(vendorID)
		if totalStCap > PNRP.Items["tool_vendor"].Capacity then
			p:ChatPrint("Not enough space in vendor")
			return
		end
		if iid == nil or iid == "" then 
			local Check = PNRP.TakeFromInventoryBulk( p, itemID, tonumber(count) )
			if not Check then
				p:ChatPrint("You do not have enough of this")
				return
			end
		else
		--	itemID = iid
			local perstCostString = tostring(1)..","..scrap..","..SP..","..chems
			PNRP.PersistMoveTo( p, iid, "vendor", vendorID, perstCostString )
			
			return
		end
	end
	
	query = "SELECT inventory FROM vending_table WHERE vendorid="..SQLStr(vendorID)
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
					local totalCount
					if iid == nil or iid == "" then
						totalCount = tonumber(stringSplit[1]) + tonumber(count)
					else
						totalCount = 1
					end
					local newCostString = tostring(totalCount)..","..scrap..","..SP..","..chems
					invTbl[itemID] = tostring(newCostString)
					foundItem = true
				end
			end
		end

		if not foundItem then
			if option ~= "new" then
				p:ChatPrint("Item was removed or sold.")
				return
			end
			local costString = count..","..scrap..","..SP..","..chems
			invTbl[itemID] = tostring(costString)
		end
		
		local newInvString = ""
		for k, v in pairs(invTbl) do
			newInvString = newInvString.." "..tostring(k)..","..tostring(v)
		end
		newInvString = string.Trim(newInvString)
		query = "UPDATE vending_table SET inventory='"..newInvString.."' WHERE vendorid="..SQLStr(vendorID)
		result = querySQL(query)
		updateDispItemCost(vendorID, itemID, costTbl)
		p:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ErrorNoHalt(tostring(os.date()).." SQL ERROR:  No Vendor match in vending_table! ["..tostring(vendorID).."] \n")
	end
end
net.Receive( "setVendorSellItem", setVendorSellItem )
util.AddNetworkString("setVendorSellItem")

function updateDispItemCost(vendorID, itemID, costTable)
	vendorID = tonumber(vendorID)
	local costString = costTable["count"]..","..costTable["scrap"]..","..costTable["sp"]..","..costTable["chems"]
	local foundDispItems = ents.FindByClass("msc_display_item")
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == itemID then
			v.cost = costString
			v:SetNetVar("cost", costString)
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
	local iid = net.ReadString()
	
	BuyFromVendor(ply, vendorID, Item, Cost, Amount, "vendor", iid)
end
net.Receive( "BuyFromVendor", doBuyFromVendor )

function BuyFromVendor(ply, vendorID, Item, Cost, Amount, From, iid )
	
	local enough = false
	local soldItem = false
	
	local totalScrap = 0
	local totalSmall = 0
	local totalChems = 0
	Msg("IID: "..tostring(iid).."\n")
	Cost[1] = tonumber(Cost[1])
	Cost[2] = tonumber(Cost[2])
	Cost[3] = tonumber(Cost[3])
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = getServerSetting("packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = getServerSetting("packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	--Verifies Player has the needed Resources to buy the item
	if ply:IsAdmin() and getServerSetting("adminNoCost") == 1 then
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
		if iid == nil or iid == "" then
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
			if weightCalc <= weightCap then
				PNRP.PersistMoveTo( ply, iid, "player")	
				
				totalScrap = Cost[1] * Amount
				totalSmall = Cost[2] * Amount
				totalChems = Cost[3] * Amount
				
				ply:DecResource("Scrap", totalScrap)
				ply:DecResource("Small_Parts", totalSmall)
				ply:DecResource("Chemicals", totalChems)
				
				soldItem = true
			else
				ply:ChatPrint("Unable to take item from vendor.")
			end
		end
		
	else
		ply:ChatPrint("You can afford this!")
	end
	if soldItem then
		
		local result = querySQL("SELECT res FROM vending_table WHERE vendorid="..SQLStr(vendorID))
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

		local resultRes = querySQL("UPDATE vending_table SET res='"..tostring(newRes).."' WHERE vendorid="..SQLStr(vendorID))
		
		if From == "vendor" then
			checkRMDispItems(ply, Item, vendorID, iid)
		end
	end
	
	return soldItem
end

--Finds nearest display item and deletes it if needed
function checkRMDispItems(ply, itemID, vendorID, iid)
	local Pos = ply:GetPos()
	local itmCount = 0
	local itemString = string.Explode( ",", getItemInfo(itemID, vendorID))
	itmCount = itemString[1]
	local foundDispItems = ents.FindByClass("msc_display_item")
	local disItemTable = {}
	local distTable = {}
	local idCount = 0
	if not iid then iid = "" end
	for _, v in pairs(foundDispItems) do
		if not v.iid then v.iid = "" end
		if v.vendorid == vendorID and v.item == itemID and v.iid == iid then
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
function getItemInfo(itemID, vendorID, iid)
	local returnString = "0,0,0,0"
	
	if iid == nil or iid == "" then
		query = "SELECT inventory FROM vending_table WHERE vendorid="..SQLStr(vendorID)
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
	else
		local item = PNRP.GetPersistItem( iid )
		if item then
			if item["locdata"] ~= "" then
				returnString = item["locdata"]
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
	local iid = net.ReadString()
	local status = net.ReadString()

	local pos = ply:GetPos()
	
	local infoString = getItemInfo(itemID, vendorID, iid)
	local infoTable = string.Explode( ",", infoString )
	local itmCount = infoTable[1]
	
	local idCount = 0
	local foundDispItems = ents.FindByClass("msc_display_item")
	for _, v in pairs(foundDispItems) do
		if v.vendorid == vendorID and v.item == itemID and v.iid == iid then
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
		
		ent:SetNetVar("itemID", itemID)
		ent:SetNetVar("vendorid", vendorID)
		ent:SetNetVar("cost", infoString)
		ent:SetNetVar("iid", iid)
		ent:SetNetVar("status", status)
		ent.vendorid = vendorID
		ent.item = itemID
		ent.iid = iid
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