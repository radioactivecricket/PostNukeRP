local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

require("glon")

CreateConVar("pnrp_ZombieSquads","3",FCVAR_REPLICATED + FCVAR_ARCHIVE)

GM.spawnTbl = {}
local spawnTbl = GM.spawnTbl
--Spawns a zombie when player dies
function PNRP.PlyDeathZombie(ply)
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
		end)
	end
end

function GM.SpawnMobs()
	local GM = GAMEMODE
	local PlayerNum = table.Count(player.GetAll())
	local iterations = 5
	if PlayerNum < 4 then
		iterations = 5
	else
		iterations = 5 + math.Round(PlayerNum / 3 )
	end
	if iterations > 20 then iterations = 20 end
	spawnTbl = GM.spawnTbl
	if GetConVarNumber("pnrp_SpawnMobs") == 1 then
		local info = {}
		for i = 1,iterations do
			local piles = {}
			local zombies = {}
			local fastzoms = {}
			local poisonzoms = {}
			local antlions = {}
			local antguards = {}
			local cls
			for k,v in pairs(ents.GetAll()) do
				cls = v:GetClass()
				if cls == "npc_zombie" then
					table.insert(zombies,v)
				end
				if cls == "npc_fastzombie" then
					table.insert(fastzoms,v)
				end
				if cls == "npc_poisonzombie" then
					table.insert(poisonzoms,v)
				end
				if cls == "npc_antlion" then
					table.insert(antlions,v)
				end
				if cls == "npc_antlionguard" then
					table.insert(antguards,v)
				end
				if v:IsJunkPile() or v:IsChemPile() or v:IsSmallPile() then
					table.insert(piles,v)
				end
			end
			
			local spawnSomething
			
			local zombiespawn = (#zombies < GetConVarNumber("pnrp_MaxZombies"))
			local fastzomspawn = (#fastzoms < GetConVarNumber("pnrp_MaxFastZombies"))
			local poisonzomspawn = (#poisonzoms < GetConVarNumber("pnrp_MaxPoisonZombs"))
			local antlionspawn = (#antlions < GetConVarNumber("pnrp_MaxAntlions"))
			local antguardspawn = (#antguards < GetConVarNumber("pnrp_MaxAntGuards"))
--			print("Zombiespawn:  "..tostring(zombiespawn))
--			print("Fastzombiespawn:  "..tostring(fastzomspawn))
--			print("Poisonzombiespawn:  "..tostring(poisonzomspawn))
--			print("Antlionspawn:  "..tostring(antlionspawn))
--			print("Antguardspawn:  "..tostring(antguardspawn))
			
			if zombiespawn or fastzomspawn or poisonzomspawn or antlionspawn or antguardspawn then
				spawnSomething = true
			else
				spawnSomething = false
			end
			
			if spawnSomething then
				local newSpawnTbl = {}
				local mySP = {}
				local doNotTest = false
				
				local spawnable = false
				--ent:SetAngles(Angle(0,math.random(1,360),0))
				local class
				local npcType
				local guardChecked = false
				
				while spawnable == false do
					npcType = math.random(1,5)
					
					if npcType == 1 and zombiespawn then
						class = "npc_zombie"
						spawnable = true
					end
					if npcType == 2 and fastzomspawn then
						class = "npc_fastzombie"
						spawnable = true
					end
					if npcType == 3 and poisonzomspawn then
						class = "npc_poisonzombie"
						spawnable = true
					end
					if npcType == 4 and antlionspawn then
						class = "npc_antlion"
						spawnable = true
					end
					if npcType == 5 and antguardspawn then
						local spawnChance = math.random(1,10)
						if spawnChance == 4 and not guardChecked then
							class = "npc_antlionguard"
							spawnable = true
						else
							guardChecked = true
							if !zombiespawn and !fastzomspawn and !poisonzomspawn and !antlionspawn then
								break
							end
						end
					end
					if !zombiespawn and !fastzomspawn and !poisonzomspawn and !antlionspawn  and guardChecked then
						break
					end
				end
				
				for _, node in pairs(spawnTbl) do
					if class == "npc_zombie" or class == "npc_fastzombie" or class == "npc_poisonzombie" then
						if util.tobool(node["spwnsZom"]) then
							table.insert(newSpawnTbl, node)
						end
					elseif class == "npc_antlion" then
						if util.tobool(node["spwnsAnt"]) then
							table.insert(newSpawnTbl, node)
						end
					elseif class == "npc_antlionguard" then
						if util.tobool(node["spwnsAnt"]) and not util.tobool(node["infIndoor"]) then
							table.insert(newSpawnTbl, node)
						end
					end
				end
				
				if #spawnTbl > 0 and #newSpawnTbl > 0 then
					local HeightPos = 1000
					local validSpawn = true
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
						if doorEnt:IsValid() then
							--for _, us in pairs(player.GetAll()) do
								--us:ChatPrint("Door is valid.")
							--end
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
							if item:IsValid() then
								if item:GetClass() == "prop_physics" then
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
						local randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
						local randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])
						
						if util.tobool(mySP["infIndoor"]) then
							local trace = {}
							trace.start = Vector(randX,randY,mySP["z"])
							trace.endpos = trace.start + Vector(0, 0, 1000)

							local roofTrace = util.TraceLine(trace)
							HeightPos = roofTrace.HitPos.z - 10
							if 72 < (HeightPos - mySP["z"]) then
								validSpawn = false
							end
						end
						
						info.pos = Vector( randX, randY, HeightPos)
						info.Retries = 50

						--Find pos in world
						while (util.IsInWorld(info.pos) == false or validSpawn == false) and info.Retries > 0 do
							randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
							randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])
							
							if util.tobool(mySP["infIndoor"]) then
								local trace = {}
								trace.start = Vector(randX,randY,mySP["z"])
								trace.endpos = trace.start + Vector(0, 0, 1000)

								local roofTrace = util.TraceLine(trace)
								HeightPos = roofTrace.HitPos.z - 10
								if 72 < (HeightPos - mySP["z"]) then
									validSpawn = false
								end
							end
							
							info.pos = Vector(randX,randY,HeightPos)
							info.Retries = info.Retries - 1
						end
					elseif #spawnTbl > 0 then
						doNotTest = true
					else
						info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
						info.Retries = 50

						--Find pos in world
						while util.IsInWorld(info.pos) == false and info.Retries > 0 do
							info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
							info.Retries = info.Retries - 1
						end
					end
					if not doNotTest then
						--Find ground
						local trace = {}
						trace.start = info.pos
						trace.endpos = trace.start + Vector(0,0,-100000)
						trace.mask = MASK_SOLID_BRUSHONLY

						local groundtrace = util.TraceLine(trace)

						--Assure space
						local nearby = ents.FindInSphere(groundtrace.HitPos,100)
						info.HasSpace = true

						for k,v in pairs(nearby) do
							if v:IsProp() then
								info.HasSpace = false
							end
						end

						--Find sky
						local trace = {}
						trace.start = groundtrace.HitPos
						trace.endpos = trace.start + Vector(0,0,100000)

						local skytrace = util.TraceLine(trace)
						
						if util.tobool(mySP["infIndoor"]) then
							skytrace.HitSky = true
						end

						--Find water?
						local trace = {}
						trace.start = groundtrace.HitPos
						trace.endpos = trace.start + Vector(0,0,1)
						trace.mask = MASK_WATER

						local watertrace = util.TraceLine(trace)

						--All a go, make entity
						--removed "info.HasSpace and"
						if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
							if class then
								local ent = ents.Create(class)
								ent:SetPos(groundtrace.HitPos+Vector(0,0,50))
								if npcType < 4 then
									local squadnum = math.random(1,GetConVarNumber("pnrp_ZombieSquads"))
									ent:SetKeyValue ("squadname", "npc_zombies"..tostring(squadnum))
								end
								if npcType == 4 or npcType == 5 then
									ent:SetKeyValue ("squadname", "npc_antlions")
								end
								-- ent:DropToGround()
								ent:Spawn()
								ent:SetNetworkedString("Owner", "Unownable")
								if npcType < 4 then
									ent:AddRelationship("pnrp_antmound D_HT 99")
								end
							end
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
		if v:IsValid() then
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
				if doorEnt:IsValid() then
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
					if item:IsValid() then
						if item:GetClass() == "prop_physics" then
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
					local retries = 50
					local hasSpace = true
					local validSpawn = true
					local spawnPos
					
					local randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
					local randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])

					spawnPos = Vector(randX,randY,mySP["z"])
					--Find pos in world
					while (util.IsInWorld(spawnPos) == false or validSpawn == false) and info.Retries > 0 do
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
						trace.start = Vector(randX,randY,roofTrace.HitPos.z)
						trace.endpos = trace.start + Vector(0, 0, -5000)

						local floorTrace = util.TraceLine(trace)
						
						--Find water?
						local trace = {}
						trace.start = groundtrace.HitPos
						trace.endpos = trace.start + Vector(0,0,1)
						trace.mask = MASK_WATER

						local watertrace = util.TraceLine(trace)
						
						HeightPos = roofTrace.HitPos.z - 10
						if 300 < (HeightPos - floorTrace.HitPos.z) then
							validSpawn = false
						end
						
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
						retries = retries - 1
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
					local retries = 50
					local hasSpace = true
					local spawnPos
					
					repeat
						retries = retries - 1
						local randX = mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"])
						local randY = mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"])
						
						local trace = {}
						trace.start = Vector(randX, randY, 1000)
						trace.endpos = trace.start + Vector(0, 0, -10000)
						trace.mask = MASK_SOLID_BRUSHONLY

						local groundtrace = util.TraceLine(trace)
						
						--Assure space
						local nearby = ents.FindInSphere(groundtrace.HitPos,150)
						local hasSpace = true

						for k,v in pairs(nearby) do
							if v:IsProp() then
								hasSpace = false
							end
						end
						spawnPos = groundtrace.HitPos - Vector(0,0,50)
					until hasSpace or retries <= 0
					
					if hasSpace then
						local ent = ents.Create("pnrp_antmound")
						ent:SetPos(spawnPos)
						ent:Spawn()
						ent:SetNetworkedString("Owner", "Unownable")
						ent:GetPhysicsObject():EnableMotion(false)
						ent:SetMoveType(MOVETYPE_NONE)
						
						
						
						for k, v in pairs(player.GetAll()) do
							v:ChatPrint("You feel a strange rumbling from the ground below you...")
							v:EmitSound( "ambient/atmosphere/terrain_rumble1.wav", 45, 100 )
						end
					end
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
			if v:IsValid() then
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
			if v:IsValid() then
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
			ent:SetNWEntity("infLinked", NullEntity() )
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
		local count = 1
		
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass()=="mobspawn_gridbuilder" then
				print("Found one.")
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
				if v:GetNWEntity("infLinked"):IsValid() then
					spawnPoint["infLinked"] = v:GetNWEntity("infLinked"):GetPos()
				end
				tbl[count] = spawnPoint
				count = count + 1
			end
		end
		
		if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
		if !file.IsDir("PostNukeRP/SpawnGrids") then file.CreateDir("PostNukeRP/SpawnGrids") end
		
		file.Write("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt",glon.encode(tbl))
		
		ply:ChatPrint("Done! Saved under PostNukeRP/SpawnGrids/"..game.GetMap()..".txt")
	else
		ply:ChatPrint("This is an admin only command!")
	end
end
concommand.Add( "pnrp_savegrid", GM.SaveSpawnGrid )

function GM.LoadSpawnGrid( ply, command, arg )
	local GM = GAMEMODE
	if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt") then
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
				GM.spawnTbl[k]["infLinked"] = NullEntity()
			end
		end
		
		spawnTbl = GM.spawnTbl
		
		ply:ChatPrint("File found with "..#spawnTbl.." entries.")
		print("File found with "..#spawnTbl.." entries.")
	else
		ply:ChatPrint("File not found.")
		print("File not found.")
	end
end
concommand.Add( "pnrp_loadgrid", GM.LoadSpawnGrid )

function GM.LoadOnStart()
	local GM = GAMEMODE
	if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt") then
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
				GM.spawnTbl[k]["infLinked"] = NullEntity()
			end
		end
		
		spawnTbl = GM.spawnTbl
		
		print("File found with "..#spawnTbl.." entries.")
	else
		print("File not found.")
	end
	-- timer.Simple(5, function ()
		-- local GM = GAMEMODE
		-- if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt") then
			-- local unTable = {}
			-- local unWorldPos = {}
			-- local count = 1
			-- GM.spawnTbl = {}
			-- unTable = glon.decode(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
			
			-- while unTable[count] do
				
				-- table.insert(GM.spawnTbl, unTable[count])
				-- count = count + 1
			-- end
			-- spwnTbl = GM.spawnTbl
			
			-- print("File found with "..#spawnTbl.." entries.")
		-- else
			-- print("File not found.")
		-- end
	-- end)
end
hook.Add( "InitPostEntity", "loadGrid", GM.LoadOnStart )

function GM.EditSpawnGrid( ply, command, arg )
	local GM = GAMEMODE
	if ply:IsAdmin() then
		if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt") then
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
					GM.spawnTbl[k]["infLinked"] = NullEntity()
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
		end
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