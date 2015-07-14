function GM.CarHullSpawner()
	local GM = GAMEMODE
--	Msg("CarHullSpawner".."\n")
	spawnTbl = GM.spawnTbl
	
	local hulls = ents.FindByClass( "intm_car_hull" )
	local hullCount = 0
	for _, v in pairs(hulls) do
		if v.resource then hullCount = hullCount + 1 end
	end
	
	if hullCount < 2 then
		local hullChance = math.random(1,100)
		if hullChance > 10 then return end
		
		local posNodes = {}
		for _, node in pairs(spawnTbl) do
			if util.tobool(node["spwnsRes"]) and not util.tobool(node["info_indoor"]) then
				if tonumber(node["distance"]) > 245 then
				--	Msg("|- "..table.ToString(node).."\n")
					local isActive = true
					
					local doorEnt =  node["infLinked"]
					if doorEnt then
						if not (doorEnt:GetNetVar("Owner", "None") == "World" or doorEnt:GetNetVar("Owner", "None") == "None") then
							isActive = false
						end
					end
					
					-- Checking the spawnbounds for props.  If there's a few down, we assume it's been claimed by a player.
					if isActive then
						local spawnBounds1 = ClampWorldVector(Vector(node["x"]-node["distance"], node["y"]-node["distance"], node["z"]-node["distance"]))
						local spawnBounds2 = ClampWorldVector(Vector(node["x"]+node["distance"], node["y"]+node["distance"], node["z"]+node["distance"]))
						
						local entsInBounds = ents.FindInBox(spawnBounds1, spawnBounds2)
						
						local propCount = 0
						if entsInBounds then
							for _, foundEnt in pairs(entsInBounds) do
								if foundEnt then
									if foundEnt:GetClass() == "prop_physics" then
										propCount = propCount + 1
										
										if propCount >= 3 then
											isActive = false
											break
										end
									end
								end
							end
						end
					end
					
					if isActive then 
						table.insert(posNodes, node)
					end
					
				end
			end
		end
		
		if #posNodes > 0 then
			local currentNode = posNodes[math.random(1, #posNodes)]
			local point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
				  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
				  currentNode["z"])
			
			local validSpawn = true
			
			local trace = {}
			trace.start = point
			trace.endpos = trace.start + Vector(0,0,-100000)
			trace.mask = MASK_SOLID_BRUSHONLY

			local groundtrace = util.TraceLine(trace)
			
			trace = {}
			trace.start = point
			trace.endpos = trace.start + Vector(0,0,100000)
			--trace.mask = MASK_SOLID_BRUSHONLY

			local rooftrace = util.TraceLine(trace)
			
			--Find water?
			trace = {}
			trace.start = groundtrace.HitPos
			trace.endpos = trace.start + Vector(0,0,1)
			trace.mask = MASK_WATER

			local watertrace = util.TraceLine(trace)
			
			if watertrace.Hit then
				validSpawn = false
			end
			
			local nearby = ents.FindInSphere(groundtrace.HitPos,100)
			for k,v in pairs(nearby) do
				if v:GetClass() == "prop_physics" then
					validSpawn = false
					break
				end
			end
			
			if validSpawn then
				local model = PNRP.HullList[math.random(1,#PNRP.HullList)]
				point = groundtrace.HitPos+Vector(0,0,5)

				local ent = ents.Create("intm_car_hull")
				ent:SetAngles(Angle(0,math.random(1,360),0))
				ent:SetModel(model)
				
				local skinCount = ent:SkinCount()
				if skinCount > 1 then
					local useSkin = math.random(1, skinCount)
					useSkin = useSkin - 1
					ent:SetSkin(useSkin)
				end
				
				if model == "models/buggy.mdl" or model == "models/airboat.mdl" or model == "models/vehicle.mdl" then
					local vZ = 25
					if model == "models/airboat.mdl" then
						vZ = 20
					end
					ent:SetPos(point-Vector(0,0,vZ))
				else
					ent:SetPos(point)
					ent:DropToGround()
				end

				ent:Spawn()
				
				ent.BlockF2 = true
				ent.resource = true
				ent.amount = math.random(15,75)
				ent:SetNetVar("Owner", "Unownable")
				ent:GetPhysicsObject():EnableMotion(false)
				ent:SetMoveType(MOVETYPE_NONE)
				
			--	Msg("Spawed Hull \n")
			end
		end
		
	end
	
end

function PNRP.SalvageHull(len, ply)
	local ent = net.ReadEntity()
	local option = net.ReadString()
	
	ply:SelectWeapon("weapon_simplekeys")
	ply:SetMoveType(MOVETYPE_NONE)
	ply.scavving = ent		
	
	ply:EmitSound(Sound("ambient/levels/streetwar/building_rubble"..tostring(math.random(1,5))..".wav"))
	
	net.Start("startProgressBar")
		net.WriteDouble(5)
	net.Send(ply)
	
	local respile = ent
	timer.Create( ply:UniqueID().."_salvhull_"..tostring(ent:EntIndex()), 0.25, 12, function()
			ply:SelectWeapon("weapon_simplekeys")
			if (not respile:IsValid()) or (not ply:Alive()) then
				ply:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(ply)
				ply.scavving = nil
				if respile:IsValid() then 
					timer.Stop(ply:UniqueID().."_salvhull_"..tostring(respile:EntIndex()))
				end
				return
			end
			
			
		end )
	local myself = ent
	timer.Create( ply:UniqueID().."_salvhull_"..tostring(ent:EntIndex()).."_end", 5, 1, function() 
			net.Start("stopProgressBar")
			net.Send(ply)
			ply:SetMoveType(MOVETYPE_WALK)
			ply.scavving = nil
			
			if option == "hull" then
				local model = ent:GetModel()
				local skin = ent:GetSkin()
				local angle = ent:GetAngles()
				local pos = ent:GetPos()
				ent:Remove()
								
				local Item = PNRP.Items["intm_car_hull"]
				Item.Create(ply, "intm_car_hull", pos + Vector( 0, 0, 5 ),nil, angle, model,skin )
				ply:ChatPrint("Recovered body.")
			else
				local Chance = 50
				local itemChance = 10
				local MinAmount = 1
				local MaxAmount = 5
				
				if ply:Team() == TEAM_SCAVENGER then
					Chance = 75
					MaxAmount = 8
				elseif ply:Team() == TEAM_ENGINEER then
					itemChance = 15
				end
				 
				 if ply:GetSkill("Scavenging") > 0 then
					Chance = Chance + (ply:GetSkill("Scavenging") * 5)
					MaxAmount = MaxAmount + ply:GetSkill("Scavenging")
				end
				if ply:GetSkill("Salvaging") > 0 then
					itemChance = itemChance + (ply:GetSkill("Scavenging") * 2)
				end
				
				local num = math.random(1,100)
				
				ent.hasScav = true
				local canScavParts = false
				if ply:Team() == TEAM_ENGINEER or ply:Team() == TEAM_SCAVENGER then
					canScavParts = true
				end
				if num < itemChance and option == "salvage" and canScavParts and respile.amount >= 25 then
					
					local scavitmsTotal = 0
					local scavitmsTbl = {}
					for k, v in pairs(PNRP.CarParts) do
						scavitmsTotal = scavitmsTotal + v
					end
					
					local current = 0
					for k,v in pairs(PNRP.CarParts) do
						scavitmsTbl[k] = {}
						scavitmsTbl[k].minimum = current
						scavitmsTbl[k].maximum = current + ( (v / scavitmsTotal) * 100 )
						current = current + ( (v / scavitmsTotal) * 100 )
					end
					
					local rndItem = math.random(1,100)
					for k, v in pairs(scavitmsTbl) do
						if rndItem > v.minimum and rndItem <= v.maximum then
						--	PNRP.Items[k].Create(ply, PNRP.Items[k].Ent, myself:GetPos() + Vector( 0, 0, 45 ) )
							
							local ent = ents.Create(k)
								ent:SetAngles(Angle(0,0,0))
								ent:SetPos(myself:GetPos() + Vector( 0, 0, 45 ))
								ent:Spawn()
								
							respile.amount = respile.amount - 25
							break
						end
					end
					
				end
				
				if num < Chance then
					local num2 = math.random(MinAmount,MaxAmount)
					ply:EmitSound(Sound("items/ammo_pickup.wav"))
					local gotType = ""
					if math.random(1, 100) > 80 then
						ply:IncResource("Small_Parts", num2)
						gotType = "Small Parts"
					else
						ply:IncResource("Scrap", num2)
						gotType = "Scrap"
					end
					if respile.amount then
						respile.amount = respile.amount - num2
						ply:ChatPrint("Recovered "..tostring(num2).." "..gotType)
					end
				else
					ply:ChatPrint("Failed to recover anything.")
					respile.amount = respile.amount - 10
				end
				
				if respile.amount <= 0 then 
					respile:Remove()
				end
			end
	end )
end
net.Receive("SND_CL_SalvageHull", PNRP.SalvageHull)
util.AddNetworkString( "SND_CL_SalvageHull" )

function PNRP.HullToCar(len, ply)
	local hull = net.ReadEntity()
	local itemID = net.ReadString()
	local option = net.ReadString()
	
	if ply:IsAdmin() and getServerSetting("adminCreateAll") == 1 then
		--Admin override
	elseif ply:Team() ~= TEAM_ENGINEER then
		ply:ChatPrint("You need to be a Engineer to build this.")
		return
	end
	
	local item = PNRP.Items[itemID]
	if not item then return end
	
	local enough = false
	
	if ply:GetSkill("Construction") > 0 then
		for _, team in pairs(PNRP.Skills["Construction"].class) do
			if ply:Team() == team then
				item.Scrap = math.ceil(item.Scrap * (1 - (0.02 * ply:GetSkill("Construction"))))
				item.SmallParts = math.ceil(item.SmallParts * (1 - (0.02 * ply:GetSkill("Construction"))))
				item.Chemicals = math.ceil(item.Chemicals * (1 - (0.02 * ply:GetSkill("Construction"))))
			end
		end
	end
	if ply:GetResource("Scrap") >= item.Scrap and ply:GetResource("Chemicals") >= item.Chemicals and ply:GetResource("Small_Parts") >= item.SmallParts then 
		enough = true
	elseif ply:IsAdmin() and getServerSetting("adminNoCost") == 1 then 
		enough = true
	else
		enough = false
	end
	
	if enough == true then
		local toolcheck = item.ToolCheck( ply )
		if not toolcheck then
			ply:ChatPrint("You don't have the proper tool to make this!")
			return
		elseif type(toolcheck) == "table" then
			
			if option == "player" then
				if not PNRP.UsePlayerParts( toolcheck, ply ) then
					ply:ChatPrint("Missing Parts")
					return
				end
			else
				if not PNRP.UseNearbyParts( toolcheck, ent, ply ) then
					ply:ChatPrint("Missing Parts")
					return
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
				
				ply:EmitSound(Sound("items/ammo_pickup.wav"))

				ply:DecResource("Scrap", myscrap)
				ply:DecResource("Small_Parts", mysmall)
				ply:DecResource("Chemicals", mychems)
				
				local pos = hull:GetPos()
				local angle = hull:GetAngles()
				hull:Remove()
				local myEnt = item.Create(ply, item.Ent, pos,nil, angle)
				
				if item.Type == "weapon" then
					myEnt:SetNetVar("Ammo", myenergy)
				end
			end
		end )
	else
		--If Not enough Materials
		ply:ChatPrint("Insufficient Materials!")
	end
end
net.Receive("SND_CL_HullToCar", PNRP.HullToCar)
util.AddNetworkString( "SND_CL_HullToCar" )

function PNRP.ChangeHull(ply, command, args)
	if ply:IsAdmin() then
		local tr = ply:TraceFromEyes(200)
		local ent = tr.Entity
		if not IsValid(ent) then return end
		
		local model = ent:GetModel()
		local oldRad = ent:GetCollisionBounds()
		local pos = ent:GetPos()
		
		local foundHull = false
		
		for _, hModel in pairs(PNRP.HullList) do
			if tostring(hModel) == tostring(model) then
				foundHull = true
			end
		end
		
		if foundHull then
			local newModel
			if not args[1] then
				newModel = PNRP.HullList[math.random(1,#PNRP.HullList)]
			else
				if tonumber(args[1]) > #PNRP.HullList then args[1] = #PNRP.HullList end
				newModel = PNRP.HullList[tonumber(args[1])]
			end
			ent:SetModel(newModel)
			local newRad = ent:GetCollisionBounds()
			local setRad = oldRad - newRad
			ent:SetPos(pos + setRad + Vector(0,0,25))
			
			ent:Spawn()
			ent:SetMoveType( MOVETYPE_VPHYSICS )
			ent:PhysWake()
			ent:Activate()
			
			if args[2] then
				ent:SetSkin(tonumber(args[2]))
			end
		else
			ply:ChatPrint("Not a supported Hull")
		end
	end
end
concommand.Add( "pnrp_changehull", PNRP.ChangeHull )
PNRP.ChatConCmd( "/changehull", "pnrp_changehull" )

function seatSetup(ply, cmd, args)
	local car = ply:GetVehicle() 
	if car then
		local item = PNRP.SearchItembase( car )
		if item then			
			if tostring(car:GetNetVar( "Owner_UID" , "None" )) == PNRP:GetUID(ply) && item.Type == "vehicle" then
				
				local seatModel = item.SeatModel
				local seatPos = item.SeatLoc
				if not seatModel or not seatPos then
					ply:ChatPrint("Car seat not available")
					return
				end
				
				local seats = constraint.FindConstraints( car, "Weld" )
				for _, seat in pairs(seats) do
					if seat.Entity[2].Entity.seat == 1 then
						seat.Entity[2].Entity:Remove()
					end
				end
				
				for _, seat in pairs(seatPos) do
					local pos = seat["Pos"]
					local ang = seat["Ang"]
					local exitAng = seat["ExitAng"]
					local ent = ents.Create("prop_vehicle_prisoner_pod")
				
					ent:SetPos(util.LocalToWorld( car, pos))
					ent:SetAngles(car:GetAngles()+ang)
					ent:SetModel(seatModel)
					ent:SetKeyValue( "vehiclescript", "scripts/vehicles/prisoner_pod.txt" )
					ent:SetKeyValue( "model", seatModel )
					ent:SetKeyValue( "limitview", 0 ) 
					ent:Spawn()
					ent:Activate()
					ent.seat = 1
					ent:SetNetVar( "hud" , false )
					PNRP.SetOwner(ply, ent)
					
				--	if exitAng then ent.ExitAng = exitAng end
										
					constraint.Weld(car, ent, 0, 0, 0, true)
					
					if not item.ShowSeat then
						ent:SetColor( Color( 0, 0, 0, 0 ) )
						ent:SetRenderMode( RENDERMODE_TRANSALPHA )
					end
				end
				car:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			end
		end
	end
	
end
concommand.Add( "pnrp_seatSetup", seatSetup )
PNRP.ChatConCmd( "/carseat", "pnrp_seatSetup" )