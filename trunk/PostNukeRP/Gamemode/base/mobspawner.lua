local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

--CreateConVar("pnrp_SpawnMobs","1",FCVAR_REPLICATED + FCVAR_NOTIFY)
--CreateConVar("pnrp_MaxZombies","30",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxFastZombies","5",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxPoisonZombs","2",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxAntlions","10",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxAntGuards","1",FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE)

--CreateConVar("pnrp_SpawnMobs","1",FCVAR_REPLICATED)
--CreateConVar("pnrp_MaxZombies","30",FCVAR_REPLICATED + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxFastZombies","5",FCVAR_REPLICATED + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxPoisonZombs","2",FCVAR_REPLICATED + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxAntlions","10",FCVAR_REPLICATED + FCVAR_ARCHIVE)
--CreateConVar("pnrp_MaxAntGuards","1",FCVAR_REPLICATED + FCVAR_ARCHIVE)

CreateConVar("pnrp_ZombieSquads","3",FCVAR_REPLICATED + FCVAR_ARCHIVE)

GM.spawnTbl = {}
local spawnTbl = GM.spawnTbl

function GM.SpawnMobs()
	local GM = GAMEMODE
	spawnTbl = GM.spawnTbl
	if GetConVarNumber("pnrp_SpawnMobs") == 1 then
		local info = {}
		for i = 1,5 do
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
				local mySP = {}
				
				if #spawnTbl > 0 then
					mySP = spawnTbl[math.random(1,#spawnTbl)]
					info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
					info.Retries = 50

					--Find pos in world
					while util.IsInWorld(info.pos) == false and info.Retries > 0 do
						info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
						info.Retries = info.Retries - 1
					end
				else
					info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
					info.Retries = 50

					--Find pos in world
					while util.IsInWorld(info.pos) == false and info.Retries > 0 do
						info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
						info.Retries = info.Retries - 1
					end
				end
				
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

				--Find water?
				local trace = {}
				trace.start = groundtrace.HitPos
				trace.endpos = trace.start + Vector(0,0,1)
				trace.mask = MASK_WATER

				local watertrace = util.TraceLine(trace)

				--All a go, make entity
				--removed "info.HasSpace and"
				if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
					local spawnable = false
					--ent:SetAngles(Angle(0,math.random(1,360),0))
					local class
					local npcType
					local guardChecked = false
					
					while spawnable  == false do
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
			ent:SetKeyValue("distance", tostring(arg[1]))
			ent.distance = arg[1]
			ent:SetPos( tr.HitPos + Vector(0, 0, 50) )
			ent:Spawn()
			ent:GetPhysicsObject():EnableMotion(false)
			ent:SetMoveType(MOVETYPE_NONE)
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
				
				spawnPoint["X"] = v:GetPos().x
				spawnPoint["Y"] = v:GetPos().y
				spawnPoint["Z"] = v:GetPos().z
				spawnPoint["distance"] = v:GetNWString("distance")
				tbl[count] = spawnPoint
				count = count + 1
			end
		end
		
		if !file.IsDir("PostNukeRP") then file.CreateDir("PostNukeRP") end
		if !file.IsDir("PostNukeRP/SpawnGrids") then file.CreateDir("PostNukeRP/SpawnGrids") end
		
		file.Write("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt",util.TableToKeyValues(tbl))
		
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
		unTable = util.KeyValuesToTable(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
		
		while unTable[tostring(count)] do
			
			table.insert(GM.spawnTbl, unTable[tostring(count)])
			count = count + 1
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
		unTable = util.KeyValuesToTable(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
		
		while unTable[tostring(count)] do
			
			table.insert(GM.spawnTbl, unTable[tostring(count)])
			count = count + 1
		end
		spwnTbl = GM.spawnTbl
		
		print("File found with "..#spawnTbl.." entries.")
	else
		print("File not found.")
	end
end
hook.Add( "Initialize", "initializing", GM.LoadOnStart )

function GM.EditSpawnGrid( ply, command, arg )
	local GM = GAMEMODE
	if ply:IsAdmin() then
		if file.Exists("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt") then
			local unTable = {}
			local unWorldPos = {}
			local count = 1
			GM.spawnTbl = {}
			unTable = util.KeyValuesToTable(file.Read("PostNukeRP/SpawnGrids/"..game.GetMap()..".txt"))
			
			while unTable[tostring(count)] do
				
				table.insert(GM.spawnTbl, unTable[tostring(count)])
				count = count + 1
			end
			
			spawnTbl = GM.spawnTbl
			
			for k, v in pairs(GM.spawnTbl) do
				local ent = ents.Create ("mobspawn_gridbuilder")
				ent:SetKeyValue("distance", tostring(v["distance"]))
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

--EOF