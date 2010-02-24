local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

function GM.BuildItem( ply, command, arg )
	for itemname, item in pairs(PNRP.Items) do
		if tostring( arg[1] ) == itemname then
			--Class Check
			if team.GetName(ply:Team()) == item.ClassSpawn or item.ClassSpawn == "All" then
				local tr = ply:TraceFromEyes(200)
				--Verifies Player has the needed Materials to build the item
				if ply:GetResource("Scrap") >= item.Scrap and ply:GetResource("Chemicals") >= item.Chemicals and ply:GetResource("Small_Parts") >= item.SmallParts then 
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
			for i = 1, q do
				
				if item.Type ~= "vehicle" then
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
					local pos = data.Pos + Vector(0,0,20)
					if item.Type == "tool" then
						item.Create(ply, item.Ent, pos)
					else
						local ent = ents.Create(data.Ent)
						ent:SetModel(data.Model)
						ent:SetAngles(Angle(0,0,0))
						ent:SetPos(pos)
						ent:Spawn()
						if item.Type == "weapon" and item.ID ~= "wep_grenade" then
							ent:SetNetworkedString("Ammo", "0")
						elseif item.Type == "ammo" then
							
							ent:SetNetworkedString("Ammo", tostring(item.Energy))
						
						end
						ent:SetNetworkedString("Owner", "World")
					end
					
					PNRP.TakeFromInventory( ply, data.ID )
				else
					
					local ent = ents.Create(data.Ent)
					local pos = data.Pos + Vector(0,0,20)
					if data.Ent == "weapon_seat" then
						ent:SetNetworkedString("Type", "1")
					end
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
					ent:SetNetworkedString("Owner", ply:Nick())
					PNRP.TakeFromInventory( ply, data.ID )
				
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
			for i = 1, q do
				
				if item.Type != "vehicle" then
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					
					local ent = ents.Create(data.Ent)
					local pos = data.Pos + Vector(0,0,20)
					ent:SetModel(data.Model)
					ent:SetAngles(Angle(0,0,0))
					ent:SetPos(pos)
					ent:Spawn()
					ent:SetNetworkedString("Owner", "World")
					PNRP.TakeFromCarInventory( ply, data.ID )
					
				else
					
					local ent = ents.Create(data.Ent)
					local pos = data.Pos + Vector(0,0,20)
					if data.Ent == "weapon_seat" then
						ent:SetNetworkedString("Type", "1")
					end
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
					ent:SetNetworkedString("Owner", ply:Nick())
					PNRP.TakeFromCarInventory( ply, data.ID )
				end	
				
			end
		
		else

		end
	end
end
