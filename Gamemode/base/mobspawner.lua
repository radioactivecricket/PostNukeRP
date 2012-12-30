local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

CreateConVar("pnrp_ZombieSquads","3",FCVAR_REPLICATED + FCVAR_ARCHIVE)

GM.spawnTbl = {}
local spawnTbl = GM.spawnTbl
--Spawns a zombie when player dies
function PNRP.PlyDeathZombie(ply, packTbl)
	if GetConVarNumber("pnrp_PlyDeathZombie") == 1 then
		local pos = ply:GetPos()
		timer.Create(tostring(ply:UniqueID()), 5, 1, function()
			local ent = ents.Create("npc_zombie")
			ent:SetPos(pos)
			
			local squadnum = math.random(1,GetConVarNumber("pnrp_ZombieSquads"))
			ent:SetKeyValue ("squadname", "npc_zombies"..tostring(squadnum))
			ent:Spawn()
			ent:SetNetworkedString("Owner", "Unownable")
			ent:SetNetworkedString("deadplayername", ply:Nick())
			ent:AddRelationship("pnrp_antmound D_HT 99")
			if table.Count(packTbl.inv) > 0 or table.Count(packTbl.ammo) > 0 or packTbl.res.scrap > 0 or packTbl.res.small > 0 or packTbl.res.chems > 0 then
				ent.packTbl = packTbl
				ent.hasBackpack = true
			end
		end)
	else
		if table.Count(packTbl.inv) > 0 or table.Count(packTbl.ammo) > 0 or packTbl.res.scrap > 0 or packTbl.res.small > 0 or packTbl.res.chems > 0 then
			local pos = ply:GetPos() + Vector(0, 0, 20)
			local ent = ents.Create("msc_backpack")
			ent:SetAngles(Angle(0,0,0))
			ent:SetPos(pos)
			ent.contents = packTbl
			ent:Spawn()
		end
	end
end

function GM.SpawnMobs()
	local GM = GAMEMODE
	
	spawnTbl = GM.spawnTbl
	if GetConVarNumber("pnrp_SpawnMobs") == 1 then
		local info = {}
		--local piles = ents.FindByClass( "ent_resource" )
		-- Get all my amounts.
		local zombies = ents.FindByClass( "npc_zombie" )
		local fastzoms = ents.FindByClass( "npc_fastzombie" )
		local poisonzoms = ents.FindByClass( "npc_poisonzombie" )
		local antlions = ents.FindByClass( "npc_antlion" )
		local antguards = ents.FindByClass( "npc_antlionguard" )
		
		local spawnSomething
		
		local spawnables = {}
		
		--  Check 'em against max amounts.
		local zombiespawn = (#zombies < GetConVarNumber("pnrp_MaxZombies"))
		local fastzomspawn = (#fastzoms < GetConVarNumber("pnrp_MaxFastZombies"))
		local poisonzomspawn = (#poisonzoms < GetConVarNumber("pnrp_MaxPoisonZombs"))
		local antlionspawn = (#antlions < GetConVarNumber("pnrp_MaxAntlions"))
		local antguardspawn = (#antguards < GetConVarNumber("pnrp_MaxAntGuards"))
		
		if zombiespawn or fastzomspawn or poisonzomspawn or antlionspawn or antguardspawn then
			--  Add 'em to a table with how much they need.
			if zombiespawn then spawnables["npc_zombie"] = GetConVarNumber("pnrp_MaxZombies") - #zombies end
			if fastzomspawn then spawnables["npc_fastzombie"] = GetConVarNumber("pnrp_MaxFastZombies") - #fastzoms end
			if poisonzomspawn then spawnables["npc_poisonzombie"] = GetConVarNumber("pnrp_MaxPoisonZombs") - #poisonzoms end
			if antlionspawn then spawnables["npc_antlion"] = GetConVarNumber("pnrp_MaxAntlions") - #antlions end
			if antguardspawn then 
				if math.random(1,10) == 1 then
					spawnables["npc_antlionguard"] = 1
				end
			end
			
			-- We're gonna make sure we hold max all the time.
			for class, amount in pairs(spawnables) do
				--  Grabbing creature type so we can use it for table stuff
				local creatureType
				if class == "npc_zombie" or class == "npc_fastzombie" or class == "npc_poisonzombie" then
					creatureType = "spwnsZom"
				else
					creatureType = "spwnsAnt"
				end
				
				--  Make our temp-table with all possible nodes for this creature type.
				local posNodes = {}
				for _, node in pairs(spawnTbl) do
					if util.tobool(node[creatureType]) then
						local isActive = true
						-- if not util.tobool( node["infIndoor"]) then
							-- isActive = true
						-- end
						
						local doorEnt =  node["infLinked"]
						if IsValid(doorEnt) then
							if not (doorEnt:GetNetworkedString("Owner", "None") == "World" or doorEnt:GetNetworkedString("Owner", "None") == "None") then
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
				
				--  Make sure we have entries in the nodelist.  Might not be any nodes on this map for this type.
				if #posNodes > 0 then
					--  Now, let's make us some NPCs! 
					for i = 1, amount do
						
						local spawned = false
						local mainRetries = 50
						while mainRetries > 0 and (not spawned) do
							local currentNode = posNodes[math.random(1, #posNodes)]
							local point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
							  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
							  currentNode["z"])
							
							
							local spawnInfo = {}
							
							local retries = 50
							local validSpawn = false
							while (util.IsInWorld(point) == false or validSpawn == false) and retries > 0 do
								validSpawn = true
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
								
								local height = groundtrace.HitPos:Distance(rooftrace.HitPos)
								-- if height < 149 then
									-- validSpawn = false
								-- end
								
								local nearby = ents.FindInSphere(groundtrace.HitPos,100)
								for k,v in pairs(nearby) do
									if v:GetClass() == "prop_physics" then
										validSpawn = false
										break
									end
								end
								
								if (not validspawn) or (not util.IsInWorld(point)) then
									point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
									  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
									  currentNode["z"])
								else
									point = groundtrace.HitPos + Vector(0,0,5)
								end
								retries = retries - 1
							end
							
							if validSpawn then
								local ent = ents.Create(class)
								ent:SetPos(point)
								if class == "npc_zombie" or class == "npc_fastzombie" or class == "npc_poisonzombie" then
									local squadnum = math.random(1,GetConVarNumber("pnrp_ZombieSquads"))
									ent:SetKeyValue ("squadname", "npc_zombies"..tostring(squadnum))
								else
									ent:SetKeyValue ("squadname", "npc_antlions")
								end
								ent:Spawn()
								ent:SetNetworkedString("Owner", "Unownable")
								
								spawned = true
							end
							
							mainRetries = mainRetries - 1
						end
					end
				end
			end
		end
	end
--	timer.Simple(2,self.SpawnMobs)
	timer.Simple(60,GM.SpawnMobs)
end

--timer.Simple(2,GM.SpawnMobs)
timer.Simple(60,GM.SpawnMobs)

function SpawnMounds()
	local GM = GAMEMODE
	spawnTbl = GM.spawnTbl
	
	if GetConVarNumber("pnrp_MaxMounds") <= 0 then return end
	
	local moundsTbl = {}
	for k,v in pairs(ents.GetAll()) do
		if v then
			if v:GetClass() == "pnrp_antmound" then
				table.insert(moundsTbl, v)
			end
		end
	end
	
	if #moundsTbl < GetConVarNumber("pnrp_MaxMounds") then
		local randomizer = math.random(1, 100)
		if randomizer <= GetConVarNumber("pnrp_MoundChance") then
			local newSpawnTbl = {}
			local mySP = {}
			local canSpawn = false
			local retries = 50
			
			for _, node in pairs(spawnTbl) do
				if util.tobool(node["infMound"]) then
					table.insert(newSpawnTbl, node)
				end
			end
			
			if #newSpawnTbl <= 0 then 
				timer.Simple(GetConVarNumber("pnrp_MoundRate")*60,SpawnMounds)
				return
			end
			
			local isActive = true
				
			local retries = 50
			repeat
				isActive = true
				mySP = newSpawnTbl[math.random(1,#newSpawnTbl)]
				retries = retries - 1
				
				if not util.tobool(mySP["infIndoor"]) then
					isActive = true
					break
				end
				
				local doorEnt = mySP["infLinked"]
				if doorEnt then
					if not (doorEnt:GetNetworkedString("Owner", "None") == "World" or doorEnt:GetNetworkedString("Owner", "None") == "None") then
						isActive = false
					end
				end
				
				local spawnBounds1 = ClampWorldVector(Vector(mySP["x"]-mySP["distance"], mySP["y"]-mySP["distance"], mySP["z"]-mySP["distance"]))
				local spawnBounds2 = ClampWorldVector(Vector(mySP["x"]+mySP["distance"], mySP["y"]+mySP["distance"], mySP["z"]+mySP["distance"]))
				
				local entsInBounds = ents.FindInBox(spawnBounds1, spawnBounds2)
				local propCount = 0
				
				local resModels = {}
				table.Add(resModels, PNRP.JunkModels)
				table.Add(resModels, PNRP.ChemicalModels)
				table.Add(resModels, PNRP.SmallPartsModels)
				
				for _, item in pairs(entsInBounds) do
					if item then
						if item == "prop_physics" then
							propCount = propCount + 1
							for _, model in pairs(resModels) do
								if model == item:GetModel() then
									propCount = propCount - 1
									break
								end
							end
						end
					end
				end
				
				if propCount > 3 then
					isActive = false
				end
				
			until isActive or retries < 0
			
			if isActive then
				if util.tobool(mySP["infMound"]) then
					local HeightPos = 1000
					local myretries = 50
					local hasSpace = true
					local validSpawn = false
					local spawnPos
					
					local randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
					local randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])

					spawnPos = Vector(randX,randY,mySP["z"])
					--Find pos in world
					while (util.IsInWorld(spawnPos) == false or validSpawn == false) and myretries > 0 do
						validSpawn = true
						randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
						randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])
						
						--Find roof
						local trace = {}
						trace.start = Vector(randX,randY,mySP["z"])
						trace.endpos = trace.start + Vector(0, 0, 2000)

						local roofTrace = util.TraceLine(trace)
						
						
						--Find floor
						local trace = {}
						trace.start = roofTrace.HitPos
						trace.endpos = trace.start + Vector(0, 0, -5000)

						local floorTrace = util.TraceLine(trace)
						
						--Find water?
						local trace = {}
						trace.start = floorTrace.HitPos
						trace.endpos = trace.start + Vector(0,0,1)
						trace.mask = MASK_WATER

						local watertrace = util.TraceLine(trace)
						
						-- HeightPos = roofTrace.HitPos.z - 10
						-- if 300 < (HeightPos - floorTrace.HitPos.z) then
							-- validSpawn = false
						-- end
						-- ErrorNoHalt("validSpawn after heightcheck:  "..tostring(validSpawn))
						
						if watertrace.Hit then
							validSpawn = false
						end
						
						--Assure space
						local nearby = ents.FindInSphere(floorTrace.HitPos,150)

						for k,v in pairs(nearby) do
							if v:IsProp() then
								validSpawn = false
							end
						end
						
						
						spawnPos = Vector(randX,randY,floorTrace.HitPos.z)
						myretries = myretries - 1
					end
					
					if validSpawn then
						local ent = ents.Create("pnrp_antmound")
						ent:SetPos(spawnPos-Vector(0,0,50))
						ent:Spawn()
						ent:SetNetworkedString("Owner", "Unownable")
						ent:GetPhysicsObject():EnableMotion(false)
						ent:SetMoveType(MOVETYPE_NONE)
						
						for k, v in pairs(player.GetAll()) do
							v:ChatPrint("You feel a strange rumbling from the ground below you...")
							v:EmitSound( "ambient/atmosphere/terrain_rumble1.wav", 45, 100 )
						end
					end
				else
					ErrorNoHalt("Dumb Shit.")
					-- local retries = 50
					-- local hasSpace = true
					-- local spawnPos
					
					-- repeat
						-- retries = retries - 1
						-- local randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
						-- local randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])
						
						-- local trace = {}
						-- trace.start = Vector(randX, randY, 1000)
						-- trace.endpos = trace.start + Vector(0, 0, -10000)
						-- trace.mask = MASK_SOLID_BRUSHONLY

						-- local groundtrace = util.TraceLine(trace)
						
						-- --Assure space
						-- local nearby = ents.FindInSphere(groundtrace.HitPos,150)
						-- local hasSpace = true

						-- for k,v in pairs(nearby) do
							-- if v:IsProp() then
								-- hasSpace = false
							-- end
						-- end
						-- spawnPos = groundtrace.HitPos - Vector(0,0,50)
					-- until hasSpace or retries <= 0
					
					-- if hasSpace then
						-- local ent = ents.Create("pnrp_antmound")
						-- ent:SetPos(spawnPos)
						-- ent:Spawn()
						-- ent:SetNetworkedString("Owner", "Unownable")
						-- ent:GetPhysicsObject():EnableMotion(false)
						-- ent:SetMoveType(MOVETYPE_NONE)
						
						
						
						-- for k, v in pairs(player.GetAll()) do
							-- v:ChatPrint("You feel a strange rumbling from the ground below you...")
							-- v:EmitSound( "ambient/atmosphere/terrain_rumble1.wav", 45, 100 )
						-- end
					-- end
				end
			end
		end
	end
	timer.Simple(GetConVarNumber("pnrp_MoundRate")*60,SpawnMounds)
end
timer.Simple(GetConVarNumber("pnrp_MoundRate")*60,SpawnMounds)

/*---------------------------------------------------------
  Entity checks
---------------------------------------------------------*/
PNRP.MobModels ={ 
					"npc_zombie",
					"npc_fastzombie",
					"npc_poisonzombie",
					"npc_antlion",
					"npc_antlionguard",
				}

function EntityMeta:IsMob()
	local mobs = table.Add(PNRP.MobModels)
	for k,v in pairs(mobs) do
		if string.lower(v) == self:GetClass() then
			return true
		end
	end

	return false
end

function GM.RemoveSpawnNodes(ply,command,args)
	if ply:IsAdmin() then
		ply:ChatPrint("Removing Spawn Nodes.")
		for k,v in pairs(ents.GetAll()) do
			if v then
				if v:GetClass() == "mobspawn_gridbuilder" then
					v:Remove()
				end
			end
		end
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_clearspawnnodes", GM.RemoveSpawnNodes )

function GM.RemoveMounds(ply,command,args)
	if ply:IsAdmin() then
		ply:ChatPrint("Removing Antlion Mounds.")
		for k,v in pairs(ents.GetAll()) do
			if v then
				if v:GetClass() == "pnrp_antmound" then
					v:Remove()
				end
			end
		end
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_clearmounds", GM.RemoveMounds )

function GM.RemoveMobs(ply,command,args)
	if ply:IsAdmin() then
		ply:ChatPrint("Removing mobs.")
		for k,v in pairs(ents.GetAll()) do
			if v:IsMob() then
				v:Remove()
			end
		end
--		self.SpawnMobs()
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_clearmobs", GM.RemoveMobs )

function GM.CountMobs(ply,command,args)
	if ply:IsAdmin() then
		local mobNum = {}
		ply:ChatPrint("Counting mobs")
		for k,v in pairs(ents.GetAll()) do
			if v:IsMob() then
				table.insert(mobNum,v)
			end
		end
		ply:ChatPrint("Mobs alive:  "..tostring(#mobNum))
--		self.SpawnMobs()
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_countmobs", GM.CountMobs )

function GM.SetSpawnZone( ply, command, arg )
	if ply:IsAdmin() then
		if not arg[1] then
			ply:ChatPrint("You must input a distance.")
			return
		end
		
		local tr = ply:TraceFromEyes(3000)
		
		if tr.HitWorld then
			ply:ChatPrint("Creating with distance of "..tostring(arg[1]))
		
			local ent = ents.Create ("mobspawn_gridbuilder")
			--ent:SetKeyValue("distance", tostring(arg[1]))
			
			ent:SetPos( tr.HitPos + Vector(0, 0, 50) )
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion(false)
			ent:SetMoveType(MOVETYPE_NONE)
			
			ent:SetNWInt("distance", tonumber(arg[1]))
			ent:SetNWBool("spwnsRes", util.tobool(arg[2]))
			ent:SetNWBool("spwnsAnt", util.tobool(arg[3]))
			ent:SetNWBool("spwnsZom", util.tobool(arg[4]))
			ent:SetNWBool("infMound", util.tobool(arg[5]))
			ent:SetNWBool("infIndoor", util.tobool(arg[6]))
			ent:SetNWEntity("infLinked", nil )
		end
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_mobsp", GM.SetSpawnZone )

function GM.SaveSpawnGrid( ply, command, arg )
	if ply:IsAdmin() then
		ply:ChatPrint("Saving npc spawn grid...")
		local tbl = {}
		local count = 0
		local query
		local result
		
		if not sql.TableExists("spawn_grids") then
			query = "CREATE TABLE spawn_grids ( map varchar(255), pos varchar(255), range int, spawn_res int, spawn_ant int, spawn_zom int, spawn_mound int, info_indoor int, info_linked varchar(255) )"
			result = querySQL(query)
			--print(SysTime().." SQL QUERY: (Create spawn_grid table) Error:  "..tostring(sql.LastError()))
		else
			print(SysTime().." SQL TABLE EXISTS:  spawn_grids")
		end
		
		sql.Begin()
		query = "DELETE FROM spawn_grids WHERE map='"..game.GetMap().."'"
		result = querySQL(query)
		--ErrorNoHalt(SysTime().." SQL QUERY: (Delete old map grid) Error:  "..tostring(sql.LastError()).."  Results:  "..tostring(result).."  Map name:  "..game.GetMap())
		
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass()=="mobspawn_gridbuilder" then
				local infLinked = 0
				if v:GetNWEntity("infLinked") and IsValid(v:GetNWEntity("infLinked")) then
					if v:GetNWEntity("infLinked"):GetPos() then infLinked = tostring(v:GetNWEntity("infLinked"):GetPos().x)..","..tostring(v:GetNWEntity("infLinked"):GetPos().y)..","..tostring(v:GetNWEntity("infLinked"):GetPos().z) end
				end
				
				local spwnsRes
				local spwnsAnt
				local spwnsZom
				local infMound
				local infIndoor
				
				if v:GetNWBool("spwnsRes") then spwnsRes = 1 else spwnsRes = 0 end
				if v:GetNWBool("spwnsAnt") then spwnsAnt = 1 else spwnsAnt = 0 end
				if v:GetNWBool("spwnsZom") then spwnsZom = 1 else spwnsZom = 0 end
				if v:GetNWBool("infMound") then infMound = 1 else infMound = 0 end
				if v:GetNWBool("infIndoor") then infIndoor = 1 else infIndoor = 0 end
				
				query = "INSERT INTO spawn_grids VALUES ( '"..game.GetMap()
				query = query.."', '"..v:GetPos().x
				query = query..","..v:GetPos().y
				query = query..","..v:GetPos().z
				query = query.."', "..v:GetNWInt("distance")
				query = query..", "..spwnsRes
				query = query..", "..spwnsAnt
				query = query..", "..spwnsZom
				query = query..", "..infMound
				query = query..", "..infIndoor
				query = query..", '"..infLinked.."' )"
				result = querySQL(query)
				--ErrorNoHalt(SysTime().." SQL QUERY: (Save spawn_grid Node)  Error:  "..tostring(sql.LastError()).."  Results:  "..tostring(result).."  Map name:  "..game.GetMap())
				
				--[[
				local spawnPoint = {}
				local myPos = {}
				
				spawnPoint["x"] = v:GetPos().x
				spawnPoint["y"] = v:GetPos().y
				spawnPoint["z"] = v:GetPos().z
				spawnPoint["distance"] = v:GetNWInt("distance")
				spawnPoint["spwnsRes"] = v:GetNWBool("spwnsRes")
				spawnPoint["spwnsAnt"] = v:GetNWBool("spwnsAnt")
				spawnPoint["spwnsZom"] = v:GetNWBool("spwnsZom")
				spawnPoint["infMound"] = v:GetNWBool("infMound")
				spawnPoint["infIndoor"] = v:GetNWBool("infIndoor")
				if v:GetNWEntity("infLinked") then
					spawnPoint["infLinked"] = v:GetNWEntity("infLinked"):GetPos()
				end
				
				tbl[count] = spawnPoint
				]]--
				count = count + 1
			end
		end
		sql.Commit()
		
		ply:ChatPrint("Done! Saved into SQLite with "..count.." entries!")
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_savegrid", GM.SaveSpawnGrid )

function GM.LoadSpawnGrid( ply, command, arg )
	local GM = GAMEMODE
	GM.spawnTbl = {}
	
	if not sql.TableExists("spawn_grids") then
		ErrorNoHalt("SQL ERROR:  spawn_grid TABLE does not exist.")
		return
	end
	
	local query = "SELECT pos, range, spawn_res, spawn_ant, spawn_zom, spawn_mound, info_indoor, info_linked FROM spawn_grids WHERE map='"..game.GetMap().."' "
	result = querySQL(query)
	--print(SysTime().." SQL QUERY: (Load map spawn nodes)  Error:  "..tostring(sql.LastError()))
	
	if not result then
		ErrorNoHalt("SQL ERROR:  no results for spawn node query, create a grid for this map \n")
		ply:ChatPrint("No entries found for map.  Create a grid for this map.")
		return
	end
	
	for id, row in pairs( result ) do
		local pos
		local linkedPos
		local infLinked
		
		if row["info_linked"] == "0" then
			ErrorNoHalt("info_linked == 0\n")
			infLinked = nil
		else
			linkedPos = string.Explode(",", row["info_linked"])
			linkedPos = Vector(tonumber(linkedPos[1]), tonumber(linkedPos[2]), tonumber(linkedPos[3]))
			
			local found = false
			for _, ent in pairs(ents.GetAll()) do
				if ent:IsDoor() and ent:GetPos() == linkedPos then
					infLinked = ent
					found = true
					break
				end
			end
			if not found then
				infLinked = nil
			end
			ErrorNoHalt("info_linked found:  "..tostring(found).."\n")
		end
		
		pos = string.Explode(",", row["pos"])
		table.insert(GM.spawnTbl, {["x"] = pos[1], ["y"] = pos[2], ["z"] = pos[3], ["distance"] = row["range"], ["spwnsRes"] = tobool(row["spawn_res"]), ["spwnsAnt"] = tobool(row["spawn_ant"]), ["spwnsZom"] = tobool(row["spawn_zom"]), ["infMound"] = tobool(row["spawn_mound"]), ["infIndoor"] = tobool(row["info_indoor"]), ["infLinked"] = infLinked })
	end
	spawnTbl = GM.spawnTbl
	ply:ChatPrint("File found with "..#spawnTbl.." entries.")
	print("File found with "..#spawnTbl.." entries.")
	
	--[[if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt", "DATA") then
		local unTable = {}
		local unWorldPos = {}
		local count = 1
		GM.spawnTbl = {}
		unTable = glon.decode(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
		
		while unTable[count] do
			
			table.insert(GM.spawnTbl, unTable[count])
			count = count + 1
		end
		
		for k, v in pairs(GM.spawnTbl) do
			local found = false
			if GM.spawnTbl[k]["infLinked"] then
				for _, ent in pairs(ents.GetAll()) do
					if ent:IsDoor() and ent:GetPos() == GM.spawnTbl[k]["infLinked"] then
						GM.spawnTbl[k]["infLinked"] = ent
						found = true
						break
					end
				end
			end
			if not found then
				GM.spawnTbl[k]["infLinked"] = nil
			end
		end
		
		spawnTbl = GM.spawnTbl
		
		ply:ChatPrint("File found with "..#spawnTbl.." entries.")
		print("File found with "..#spawnTbl.." entries.")
	else
		ply:ChatPrint("File not found.")
		print("File not found.")
	end]]--
end
concommand.Add( "pnrp_loadgrid", GM.LoadSpawnGrid )

function GM.LoadOnStart()
	local GM = GAMEMODE
	GM.spawnTbl = {}
	
	if not sql.TableExists("spawn_grids") then
		ErrorNoHalt("SQL ERROR:  spawn_grid TABLE does not exist.")
		return
	end
	
	local query = "SELECT pos, range, spawn_res, spawn_ant, spawn_zom, spawn_mound, info_indoor, info_linked FROM spawn_grids WHERE map='"..game.GetMap().."' "
	result = querySQL(query)
	--print(SysTime().." SQL QUERY: (Load map spawn nodes)  Error:  "..tostring(sql.LastError()))
	if not result then 
		ErrorNoHalt("SQL ERROR:  no results for spawn node query, create a grid for this map \n")
		return
	end
	
	for id, row in pairs( result ) do
		local pos
		local linkedPos
		local infLinked
		
		if row["info_linked"] == "0" then
			infLinked = nil
		else
			linkedPos = string.Explode(",", row["info_linked"])
			linkedPos = Vector(tonumber(linkedPos[1]), tonumber(linkedPos[2]), tonumber(linkedPos[3]))
			
			local found = false
			for _, ent in pairs(ents.GetAll()) do
				if ent:IsDoor() and ent:GetPos() == linkedPos then
					infLinked = ent
					found = true
					break
				end
			end
			if not found then
				infLinked = nil
			end
		end
		
		pos = string.Explode(",", row["pos"])
		table.insert(GM.spawnTbl, {["x"] = pos[1], ["y"] = pos[2], ["z"] = pos[3], ["distance"] = row["range"], ["spwnsRes"] = tobool(row["spawn_res"]), ["spwnsAnt"] = tobool(row["spawn_ant"]), ["spwnsZom"] = tobool(row["spawn_zom"]), ["infMound"] = tobool(row["spawn_mound"]), ["infIndoor"] = tobool(row["info_indoor"]), ["infLinked"] = infLinked })
	end
	spawnTbl = GM.spawnTbl
	
	print("File found with "..#spawnTbl.." entries.")
	
	--[[if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt", "DATA") then
		local unTable = {}
		local unWorldPos = {}
		local count = 1
		GM.spawnTbl = {}
		unTable = glon.decode(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
		
		while unTable[count] do
			
			table.insert(GM.spawnTbl, unTable[count])
			count = count + 1
		end
		
		for k, v in pairs(GM.spawnTbl) do
			local found = false
			if GM.spawnTbl[k]["infLinked"] then
				for _, ent in pairs(ents.GetAll()) do
					if ent:IsDoor() and ent:GetPos() == GM.spawnTbl[k]["infLinked"] then
						GM.spawnTbl[k]["infLinked"] = ent
						found = true
						break
					end
				end
			end
			if not found then
				GM.spawnTbl[k]["infLinked"] = nil
			end
		end
		
		spawnTbl = GM.spawnTbl
		
		print("File found with "..#spawnTbl.." entries.")
	else
		print("File not found.")
	end]]--
end
hook.Add( "InitPostEntity", "loadGrid", GM.LoadOnStart )

function GM.EditSpawnGrid( ply, command, arg )
	local GM = GAMEMODE
	if ply:IsAdmin() then
		GM.spawnTbl = {}
		if not sql.TableExists("spawn_grids") then
			ErrorNoHalt("SQL ERROR:  spawn_grid TABLE does not exist.")
			return
		end
		
		local query = "SELECT pos, range, spawn_res, spawn_ant, spawn_zom, spawn_mound, info_indoor, info_linked FROM spawn_grids WHERE map='"..game.GetMap().."' "
		result = querySQL(query)
		--ErrorNoHalt(os.time().." SQL QUERY: (Load map spawn nodes)  Error:  "..tostring(sql.LastError()))
		
		if not result then
			ErrorNoHalt("SQL ERROR:  no results for spawn node query, create a grid for this map \n")
			ply:ChatPrint("No entries found for map.  Create a grid for this map.")
			return
		end
		
		for id, row in pairs( result ) do
			local pos
			local linkedPos
			local infLinked
			
			if row["info_linked"] == "0" then
				infLinked = nil
			else
				linkedPos = string.Explode(",", row["info_linked"])
				linkedPos = Vector(tonumber(linkedPos[1]), tonumber(linkedPos[2]), tonumber(linkedPos[3]))
				
				local found = false
				for _, ent in pairs(ents.GetAll()) do
					if ent:IsDoor() and ent:GetPos() == linkedPos then
						infLinked = ent
						found = true
						break
					end
				end
				if not found then
					infLinked = nil
				end
			end
			
			pos = string.Explode(",", row["pos"])
			table.insert(GM.spawnTbl, {["x"] = pos[1], ["y"] = pos[2], ["z"] = pos[3], ["distance"] = row["range"], ["spwnsRes"] = tobool(row["spawn_res"]), ["spwnsAnt"] = tobool(row["spawn_ant"]), ["spwnsZom"] = tobool(row["spawn_zom"]), ["infMound"] = tobool(row["spawn_mound"]), ["infIndoor"] = tobool(row["info_indoor"]), ["infLinked"] = infLinked })
		end
		spawnTbl = GM.spawnTbl
		ply:ChatPrint("File found with "..#spawnTbl.." entries.")
		print("File found with "..#spawnTbl.." entries.")
		
		for k, v in pairs(GM.spawnTbl) do
			local ent = ents.Create ("mobspawn_gridbuilder")
			ent:SetNWInt("distance", tonumber(v["distance"]))
			ent:SetNWBool("spwnsRes", util.tobool(v["spwnsRes"]))
			ent:SetNWBool("spwnsAnt", util.tobool(v["spwnsAnt"]))
			ent:SetNWBool("spwnsZom", util.tobool(v["spwnsZom"]))
			ent:SetNWBool("infMound", util.tobool(v["infMound"]))
			ent:SetNWBool("infIndoor", util.tobool(v["infIndoor"]))
			ent:SetNWEntity("infLinked", v["infLinked"])
			ent.distance = v["distance"]
			ent:SetPos( Vector(v["x"], v["y"], v["z"]) )
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion(false)
			ent:SetMoveType(MOVETYPE_NONE)
		end
		
		--[[if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt", "DATA") then
			local unTable = {}
			local unWorldPos = {}
			local count = 1
			GM.spawnTbl = {}
			unTable = glon.decode(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
			
			while unTable[count] do
				
				table.insert(GM.spawnTbl, unTable[count])
				count = count + 1
			end
			
			for k, v in pairs(GM.spawnTbl) do
				local found = false
				if GM.spawnTbl[k]["infLinked"] then
					for _, ent in pairs(ents.GetAll()) do
						if ent:IsDoor() and ent:GetPos() == GM.spawnTbl[k]["infLinked"] then
							GM.spawnTbl[k]["infLinked"] = ent
							found = true
							break
						end
					end
				end
				if not found then
					GM.spawnTbl[k]["infLinked"] = nil
				end
			end
			
			spawnTbl = GM.spawnTbl
			
			for k, v in pairs(GM.spawnTbl) do
				local ent = ents.Create ("mobspawn_gridbuilder")
				ent:SetNWInt("distance", tonumber(v["distance"]))
				ent:SetNWBool("spwnsRes", util.tobool(v["spwnsRes"]))
				ent:SetNWBool("spwnsAnt", util.tobool(v["spwnsAnt"]))
				ent:SetNWBool("spwnsZom", util.tobool(v["spwnsZom"]))
				ent:SetNWBool("infMound", util.tobool(v["infMound"]))
				ent:SetNWBool("infIndoor", util.tobool(v["infIndoor"]))
				ent:SetNWEntity("infLinked", v["infLinked"])
				ent.distance = v["distance"]
				ent:SetPos( Vector(v["x"], v["y"], v["z"]) )
				ent:Spawn()
				ent:GetPhysicsObject():EnableMotion(false)
				ent:SetMoveType(MOVETYPE_NONE)
			end
			
			ply:ChatPrint("File found with "..#spawnTbl.." entries.")
			print("File found with "..#spawnTbl.." entries.")
		else
			ply:ChatPrint("File not found.")
			print("File not found.")
		end]]--
	end
end
concommand.Add( "pnrp_editgrid", GM.EditSpawnGrid )

function ClampWorldVector(vec)
	vec.x = math.Clamp( vec.x , -16380, 16380 )
	vec.y = math.Clamp( vec.y , -16380, 16380 )
	vec.z = math.Clamp( vec.z , -16380, 16380 )
	return vec
end

--EOF