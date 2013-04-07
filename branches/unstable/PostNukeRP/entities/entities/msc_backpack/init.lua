AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/weapons/w_suitcase_passenger.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_suitcase_passenger.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	-- self.dropper = self.Entity:GetNWEntity("dropper", nil)
	-- self.dropperName = self.Entity:GetNWString("dropperName", nil)
	
	-- self.contents = {}
	-- self.contents.res = {}
	-- self.contents.res.scrap = 0
	-- self.contents.res.small = 15
	-- self.contents.res.chems = 25
	-- self.contents.ammo = {}
	-- self.contents.ammo["357"] = 42
	-- self.contents.ammo["pistol"] = 58
	-- self.contents.inv = {}
	-- self.contents.inv["wep_p228"] = 1
	-- self.contents.inv["wep_grenade"] = 2
	-- self.contents.inv["food_beans"] = 2
	-- self.contents.inv["food_coffee"] = 5
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			local currentCarry = PNRP.InventoryWeight( activator )
			
			local weightCap
			if activator:Team() == TEAM_SCAVENGER then
				weightCap = GetConVarNumber("pnrp_packCapScav") + (activator:GetSkill("Backpacking")*10)
			else
				weightCap = GetConVarNumber("pnrp_packCap") + (activator:GetSkill("Backpacking")*10)
			end
			
			
			
			net.Start("pnrp_OpenBackpackWindow")
				net.WriteEntity(activator)
				net.WriteEntity(self)
				net.WriteFloat(currentCarry)
				net.WriteFloat(weightCap)
				net.WriteTable(self.contents)
			net.Send(activator)
		end
	end
end
util.AddNetworkString("pnrp_OpenBackpackWindow")

function RemoveFromBackpack()
	local ply = net.ReadEntity()
	local backEnt = net.ReadEntity()
	local removalTbl = net.ReadTable()
	local option = net.ReadString()
	
	if option == "takeres" then
		ply:IncResource("Scrap",backEnt.contents.res.scrap)
		ply:IncResource("Small_Parts",backEnt.contents.res.small)
		ply:IncResource("Chemicals",backEnt.contents.res.chems)
		
		backEnt.contents.res.scrap = 0
		backEnt.contents.res.small = 0
		backEnt.contents.res.chems = 0
	elseif option == "singledrop" then
		local myClass = removalTbl.items[1]
		if not myClass then
			myClass = "ammo_"..tostring(removalTbl.ammo[1])
		end
		local myType = PNRP.Items[myClass].Type
		
		if myType == "ammo" then
			if backEnt.contents.ammo[removalTbl.ammo[1]] < PNRP.Items[myClass].Energy then
				ply:ChatPrint("Not enough to box.  Equipping.")
				ply:GiveAmmo(backEnt.contents.ammo[removalTbl.ammo[1]], removalTbl.ammo[1])
				backEnt.contents.ammo[removalTbl.ammo[1]] = nil
			else
				local myEnt = PNRP.Items[myClass].Create(ply, PNRP.Items[myClass].Ent, backEnt:GetPos() + Vector(0,0,20))
				backEnt.contents.ammo[removalTbl.ammo[1]] = backEnt.contents.ammo[removalTbl.ammo[1]] - PNRP.Items[myClass].Energy
				
				if backEnt.contents.ammo[removalTbl.ammo[1]] <= 0 then
					backEnt.contents.ammo[removalTbl.ammo[1]] = nil
				end
			end
		else
			local myEnt = PNRP.Items[myClass].Create(ply, PNRP.Items[myClass].Ent, backEnt:GetPos() + Vector(0,0,20))
			backEnt.contents.inv[myClass] = backEnt.contents.inv[myClass] - 1
			
			if backEnt.contents.inv[myClass] <= 0 then
				backEnt.contents.inv[myClass] = nil
			end
		end
	elseif option == "singleinv" then
		local myClass = removalTbl.items[1]
		local amount = removalTbl.items[2]
		if not myClass then
			myClass = "ammo_"..tostring(removalTbl.ammo[1])
			amount = removalTbl.ammo[2]
		end
		local myType = PNRP.Items[myClass].Type
		local weight = PNRP.Items[myClass].Weight
		local currentCarry = PNRP.InventoryWeight( ply )
		
		-- Calculate carry weight
		local weightCap
		if ply:Team() == TEAM_SCAVENGER then
			weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
		else
			weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
		end
		
		-- removal scripts
		if myType == "ammo" then
			local boxes = math.floor(amount / PNRP.Items[myClass].Energy)
			local ammoLeft = amount % PNRP.Items[myClass].Energy
			
			local totalWeight = weight * boxes
			if weightCap < currentCarry + totalWeight then
				if boxes > 1 then
					ply:ChatPrint("You can't carry "..tostring(boxes).." boxes of "..PNRP.Items[myClass].Name.."s!")
				else
					ply:ChatPrint("You can't carry a box of "..PNRP.Items[myClass].Name.."!")
				end
				return
			end
			
			PNRP.AddToInventory( ply, myClass, boxes )
			backEnt.contents.ammo[removalTbl.ammo[1]] = ammoLeft
			
			if backEnt.contents.ammo[removalTbl.ammo[1]] <= 0 then
				backEnt.contents.ammo[removalTbl.ammo[1]] = nil
			end
			
			if boxes > 1 then
				ply:ChatPrint("You put "..tostring(boxes).." boxes of "..PNRP.Items[myClass].Name.." into  your inventory.")
			else
				ply:ChatPrint("You put a box of "..PNRP.Items[myClass].Name.." into  your inventory.")
			end
		else
			local totalWeight = weight * amount
			if weightCap < currentCarry + totalWeight then
				if amount > 1 then
					ply:ChatPrint("You can't carry "..tostring(amount).." "..PNRP.Items[myClass].Name.."s!")
				else
					ply:ChatPrint("You can't carry a "..PNRP.Items[myClass].Name.."!")
				end
				return
			end
			
			PNRP.AddToInventory( ply, myClass, amount )
			backEnt.contents.inv[myClass] = backEnt.contents.inv[myClass] - amount
			
			if backEnt.contents.inv[myClass] <= 0 then
				backEnt.contents.inv[myClass] = nil
			end
			
			ply:ChatPrint("You put "..tostring(amount).." "..PNRP.Items[myClass].Name.."(s) into your inventory.")
		end
	elseif option == "singleeq" then
		local myClass = removalTbl.items[1]
		local amount = 1
		if not myClass then
			myClass = "ammo_"..tostring(removalTbl.ammo[1])
			local amount = removalTbl.ammo[2]
		end
		local myType = PNRP.Items[myClass].Type
		
		if myType == "ammo" then
			local sound = Sound("items/ammo_pickup.wav")
			backEnt:EmitSound( sound )
			
			ply:GiveAmmo(backEnt.contents.ammo[removalTbl.ammo[1]], removalTbl.ammo[1], true)
			backEnt.contents.ammo[removalTbl.ammo[1]] = nil
		elseif myType == "weapon" then
			local wepClass = PNRP.Items[myClass].Ent
			local sound = Sound("items/ammo_pickup.wav")
			if not ply:HasWeapon(wepClass) then
				backEnt:EmitSound( sound )
				
				local weaponEntity = ply:Give(wepClass)
				weaponEntity:SetClip1(0)
			elseif wepClass == "weapon_frag" then
				backEnt:EmitSound( sound )
				ply:GiveAmmo(1, "grenade")
			elseif wepClass == "weapon_pnrp_charge" then
				backEnt:EmitSound( sound )
				ply:GiveAmmo(1, "slam")
			else
				return
			end
			
			backEnt.contents.inv[myClass] = backEnt.contents.inv[myClass] - 1
			
			if backEnt.contents.inv[myClass] <= 0 then
				backEnt.contents.inv[myClass] = nil
			end
		else
			ply:ChatPrint("You cannot equip anything but weapons and ammo.")
		end
	elseif option == "equipall" then
		for k, v in pairs(backEnt.contents.inv) do
			if PNRP.Items[k].Type == "weapon" then
				local subtractItem = true
				local wepClass = PNRP.Items[k].Ent
				
				if not ply:HasWeapon(wepClass) then
					local weaponEntity = ply:Give(wepClass)
					weaponEntity:SetClip1(0)
					
					if wepClass == "weapon_frag" then
						ply:GiveAmmo( backEnt.contents.inv[k], "grenade" )
						backEnt.contents.inv[k] = nil
						subtractItem = false
					end
					
				elseif wepClass == "weapon_frag" then
					
					ply:GiveAmmo( backEnt.contents.inv[k], "grenade" )
					backEnt.contents.inv[k] = nil
					subtractItem = false
				elseif wepClass == "weapon_pnrp_charge" then
					ply:Give(wepClass)
					ply:GiveAmmo(backEnt.contents.inv[k], "slam")
					backEnt.contents.inv[k] = nil
					subtractItem = false
				else
					subtractItem = false
				end
				
				if subtractItem then
					backEnt.contents.inv[k] = backEnt.contents.inv[k] - 1
					
					if backEnt.contents.inv[k] <= 0 then
						backEnt.contents.inv[k] = nil
					end
				end
			end
		end
		
		for k, v in pairs(backEnt.contents.ammo) do
			if k == "slam" then
				ply:Give("weapon_pnrp_charge")
			end
			ply:GiveAmmo(v, k)
			backEnt.contents.ammo[k] = nil
		end
		
		local sound = Sound("items/ammo_pickup.wav")
		backEnt:EmitSound( sound )
		
	elseif option == "takeall" then
		local currentCarry = PNRP.InventoryWeight( ply )
		
		-- Calculate carry weight
		local weightCap
		if ply:Team() == TEAM_SCAVENGER then
			weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
		else
			weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
		end
		
		local totalWeight = 0
		for k, v in pairs(backEnt.contents.inv) do
			local sngWeight = PNRP.Items[k].Weight
			local ciWeight = sngWeight * v
			
			if weightCap > currentCarry + ciWeight then
				PNRP.AddToInventory( ply, k, v )
				backEnt.contents.inv[k] = nil
				currentCarry = currentCarry + ciWeight
			elseif weightCap > currentCarry + sngWeight then
				local weightLeft = weightCap - currentCarry
				local canHave = math.floor( weightLeft / sngWeight )
				
				PNRP.AddToInventory( ply, k, v )
				currentCarry = currentCarry + (canHave * sngWeight)
				backEnt.contents.inv[k] = backEnt.contents.inv[k] - canHave
				if backEnt.contents.inv[k] <= 0 then
					backEnt.contents.inv[k] = nil
				end
			end
		end
		
		for k, v in pairs(backEnt.contents.ammo) do
			local sngWeight = PNRP.Items["ammo_"..k].Weight
			local ciWeight = math.floor(v/PNRP.Items["ammo_"..k].Energy)
			
			if weightCap > currentCarry + ciWeight then
				PNRP.AddToInventory( ply, "ammo_"..k, math.floor(v/PNRP.Items["ammo_"..k].Energy) )
				
				ply:GiveAmmo(v%PNRP.Items["ammo_"..k].Energy, k)
				backEnt.contents.ammo[k] = nil
				currentCarry = currentCarry + ciWeight
			elseif weightCap > currentCarry + sngWeight then
				local weightLeft = weightCap - currentCarry
				local canHave = math.floor( weightLeft / sngWeight )
				
				PNRP.AddToInventory( ply, "ammo_"..k, canHave )
				ply:GiveAmmo(v - (canHave * PNRP.Items["ammo_"..k].Energy), k)
				backEnt.contents.ammo[k] = nil
				currentCarry = currentCarry + (sngWeight * canHave)
			else
				ply:GiveAmmo(v, k)
				backEnt.contents.ammo[k] = nil
			end
		end
		
		ply:IncResource("Scrap",backEnt.contents.res.scrap)
		ply:IncResource("Small_Parts",backEnt.contents.res.small)
		ply:IncResource("Chemicals",backEnt.contents.res.chems)
		
		backEnt.contents.res.scrap = 0
		backEnt.contents.res.small = 0
		backEnt.contents.res.chems = 0
		
		ply:ChatPrint("You take everything you can from this pack and leave the rest.")
	else
		ErrorNoHalt("Bad option on RemoveFromPack.")
	end
	
	local emptyTable = {}
	
	-- ply:ChatPrint("Stuff:  "..table.ToString(backEnt.contents))
	-- ply:ChatPrint("NotInv: "..tostring((not backEnt.contents.inv)).."  Equals:  "..tostring((backEnt.contents.inv == emptyTable	)).."  Count:  "..tostring(table.Count(backEnt.contents.inv)))
	if table.Count(backEnt.contents.inv) <= 0 and table.Count(backEnt.contents.ammo) <= 0 and backEnt.contents.res.scrap <= 0 and backEnt.contents.res.small <= 0 and backEnt.contents.res.chems <= 0 then
		backEnt:Remove()
	end
end
net.Receive("pnrp_RemoveFromPack", RemoveFromBackpack)

function ENT:F2Use(ply)
	
	local Item = self.Item
	local Amount = self.Amount
	local weight = PNRP.Items[Item].Weight
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
	if weightCalc <= weightCap then
		ply:AddToInventory( Item, Amount )
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
		ply:ChatPrint("You have taken all of this.")
		self:Remove()
	else
		local weightDiff = weightCalc - weightCap
		local extra = math.ceil(weightDiff/weight)
		
		if extra >= Amount then
			ply:ChatPrint("You can't carry any of these!")
		else
			local taken = Amount - extra
			
			ply:AddToInventory( Item, taken )
			self.Entity:SetNWInt("amount", Amount - taken )
			self.Amount = Amount - taken
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
		end
	end
end