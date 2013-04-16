local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

PNRP.Events = {}

function PNRP.RegisterEvent( eventData )
	local name = eventData.name or "Unnamed Event"
	PNRP.Events[name] = {}
	
	if eventData.vars then
		PNRP.Events[name].vars = {}
		for k, v in pairs(eventData.vars) do
			PNRP.Events[name].vars[k] = v
		end
	end
	
	if eventData.funcs then
		PNRP.Events[name].funcs = {}
		for k, v in pairs(eventData.funcs) do
			PNRP.Events[name].funcs[k] = v
		end
	end
end

function PNRP.SetEventVar( ply, event, varname, value, vartype )
	if IsValid(ply) and not ply:IsAdmin() then return end
	if vartype == "number" then
		value = tonumber(value)
	elseif vartype == "bool" then
		value = util.tobool(value)
	end
	
	if IsValid(ply) then ply:ChatPrint( "Setting "..varname.." on event "..event.." to "..tostring(value).." ("..vartype..")" ) end
	PNRP.Events[event].vars[varname] = value
end

function ChangeEventVar( ply, command, args )
	PNRP.SetEventVar( ply, args[1], args[2], args[3], args[4] )
end
concommand.Add( "pnrp_ev_setvar", ChangeEventVar )

function PNRP.RunEventFunction( ply, event, funcname, args )
	if IsValid(ply) and not ply:IsAdmin() then return end
	if not args then
		local funcHolder = PNRP.Events[event].funcs[funcname]
		if IsValid(ply) then ply:ChatPrint( "Running "..funcname.." on event "..event.." with no args." ) end
		funcHolder()
	else
		local funcHolder = PNRP.Events[event].funcs[funcname]
		if IsValid(ply) then ply:ChatPrint( "Running "..funcname.." on event "..event.." with args:  "..table.ToString(args) ) end
		funcHolder(args)
	end
end

function RunEventFunc( ply, command, args )
	PNRP.RunEventFunction( ply, args[1], args[2], nil )
end
concommand.Add( "pnrp_ev_runfunc", RunEventFunc )

local EVENT = {}
EVENT.name = "Radiation Storm"

EVENT.vars = {}
EVENT.vars["Active"] = true
EVENT.vars["Chance"] = 33
EVENT.vars["CheckTime"] = 900
EVENT.vars["LengthMin"] = 180
EVENT.vars["LengthMax"] = 600
EVENT.vars["TimeBetweenDamage"] = 5
EVENT.vars["DamageAmount"] = 1

EVENT.funcs = {}
function pnrp_ev_RadStorm_OnLoad()
	local LoadMapInfo = PNRP.Events["Radiation Storm"].funcs["LoadMapInfo"]
	LoadMapInfo()
	
	timer.Create( "pnrp_ev_radstorm_check", PNRP.Events["Radiation Storm"].vars["CheckTime"], 0, function ()
		if not PNRP.Events["Radiation Storm"].vars["Active"] then return end
		local rand = math.random(100)
		if rand <= PNRP.Events["Radiation Storm"].vars["Chance"] and not timer.Exists("pnrp_ev_radstorm_stop") then
			
			for k, v in pairs(player.GetAll()) do
				local myrand = math.random(1, 4)
				
				if myrand == 1 then
					v:ChatPrint("You feel a weird change in the air. It burns your skin!")
				elseif myrand == 2 then
					v:ChatPrint("There is a funny taste in your mouth... Like metal?!")
				elseif myrand == 3 then
					v:ChatPrint("You have a feeling that you need to hide. The sky is starting to darken.")
				else
					v:ChatPrint("There is a dreading feeling that comes over you. A familiar terror...")
				end
				
			end
			
			local CreateStorm = PNRP.Events["Radiation Storm"].funcs["CreateRadStorm"]
			
			timer.Simple(40, function() 
				CreateStorm()
			end)
		end
	end)
	
end
hook.Add( "InitPostEntity", "pnrp_ev_RadStorm_OnLoad", pnrp_ev_RadStorm_OnLoad )

function pnrp_ev_RadStorm_OnJoin( ply )
	if timer.Exists("pnrp_ev_radstorm_stop") then
		timer.Simple(10, function()
			net.Start("radstormeffects")
				net.WriteBit(true)
			net.Send(ply)
		end)
	end
end
hook.Add( "PlayerInitialSpawn", "pnrp_ev_RadStorm_joineffects", pnrp_ev_RadStorm_OnJoin )
util.AddNetworkString("radstormeffects")

function pnrp_ev_RadStorm_CreateStorm()
	if timer.Exists("pnrp_ev_radstorm_stop") then return end
	net.Start("radstormeffects")
		net.WriteBit(true)
	net.Broadcast()
	
	local length = math.random(PNRP.Events["Radiation Storm"].vars["LengthMin"], PNRP.Events["Radiation Storm"].vars["LengthMax"])
	
	timer.Create( "pnrp_ev_radstorm_geiger", 0.2, length*5, function ()
		local foundEnts = player.GetAll()
		for k, v in pairs( foundEnts ) do
			if v:IsPlayer() then
				if v:Alive() then
					if not v:IsOutside() then
						if math.random(4) > 3 then
							v:EmitSound( "player/geiger1.wav", 60, math.random( 90, 110 ) )
						end
					else
						if math.random(4) > 1 then
							v:EmitSound( "player/geiger2.wav", 60, math.random( 90, 110 ) )
						end
					end
				end
			end
		end
	end)
	
	timer.Create( "pnrp_ev_radstorm_damage", PNRP.Events["Radiation Storm"].vars["TimeBetweenDamage"], math.Round(length / PNRP.Events["Radiation Storm"].vars["TimeBetweenDamage"]), function ()
		for _, v in pairs( player.GetAll() ) do
			if IsValid(v) and v:IsPlayer() then
				if v:IsOutside() then
					if v:Team() == TEAM_WASTELANDER then
						local radResist = 1 + math.floor(4 * (v:GetSkill("Endurance")/6))
						
						if radResist < math.random(5) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType(DMG_RADIATION)
							dmginfo:SetDamage(PNRP.Events["Radiation Storm"].vars["DamageAmount"])
							dmginfo:SetInflictor(v)
							dmginfo:SetAttacker(v)
							
							v:TakeDamageInfo(dmginfo)
						end
					elseif v:Team() == TEAM_SCAVENGER then
						local radResist = 1
						
						if radResist < math.random(5) then
							local dmginfo = DamageInfo()
							dmginfo:SetDamageType(DMG_RADIATION)
							dmginfo:SetDamage(PNRP.Events["Radiation Storm"].vars["DamageAmount"])
							dmginfo:SetInflictor(v)
							dmginfo:SetAttacker(v)
							
							v:TakeDamageInfo(dmginfo)
						end
					else
						local dmginfo = DamageInfo()
						dmginfo:SetDamageType(DMG_RADIATION)
						dmginfo:SetDamage(PNRP.Events["Radiation Storm"].vars["DamageAmount"])
						dmginfo:SetInflictor(v)
						dmginfo:SetAttacker(v)
						
						v:TakeDamageInfo(dmginfo)
					end
				end
			end
		end
	end)
	
	timer.Create( "pnrp_ev_radstorm_stop", length, 1, function ()
		net.Start("radstormeffects")
			net.WriteBit(false)
		net.Broadcast()
		
		if timer.Exists("pnrp_ev_radstorm_geiger") then
			timer.Destroy("pnrp_ev_radstorm_geiger")
		end
		if timer.Exists("pnrp_ev_radstorm_damage") then
			timer.Destroy("pnrp_ev_radstorm_damage")
		end
		
		for k, v in pairs(player.GetAll()) do
			local myrand = math.random(1, 4)
				
			if myrand == 1 then
				v:ChatPrint("A overwhemling calm comes over you. The winds now subsides.")
			elseif myrand == 2 then
				v:ChatPrint("The roar of past memories quiets. For now...")
			elseif myrand == 3 then
				v:ChatPrint("You hear only the sounds of the mutants in the distance. It's never really safe is it?")
			else
				v:ChatPrint("The winds have calmed. So have your trembling hands.")
			end
		end
		timer.Destroy("pnrp_ev_radstorm_stop")
	end)
end
EVENT.funcs["CreateRadStorm"] = pnrp_ev_RadStorm_CreateStorm

function pnrp_ev_RadStorm_SaveMapInfo()
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/events", "DATA") then file.CreateDir("PostNukeRP/events") end
	if !file.IsDir("PostNukeRP/events/radstorm", "DATA") then file.CreateDir("PostNukeRP/events/radstorm") end
	
	local saveTable = {}
	for k, v in pairs(PNRP.Events["Radiation Storm"].vars) do
		saveTable[k] = v
	end
	
	file.Write("PostNukeRP/events/radstorm/"..game.GetMap()..".txt",util.TableToJSON(saveTable))
end
EVENT.funcs["SaveMapInfo"] = pnrp_ev_RadStorm_SaveMapInfo

function pnrp_ev_RadStorm_LoadMapInfo()
	if file.Exists("PostNukeRP/events/radstorm/"..game.GetMap()..".txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/events/radstorm/"..game.GetMap()..".txt", "DATA"))
		
		for k, v in pairs(tbl) do
			PNRP.Events["Radiation Storm"].vars[k] = v
		end
	end
end
EVENT.funcs["LoadMapInfo"] = pnrp_ev_RadStorm_LoadMapInfo

function pnrp_ev_RadStorm_RefreshTimers()
	if timer.Exists("pnrp_ev_radstorm_geiger") then
		timer.Destroy("pnrp_ev_radstorm_geiger")
	end
	if timer.Exists("pnrp_ev_radstorm_damage") then
		timer.Destroy("pnrp_ev_radstorm_damage")
	end
	if timer.Exists("pnrp_ev_radstorm_check") then
		timer.Adjust("pnrp_ev_radstorm_check", PNRP.Events["Radiation Storm"].vars["CheckTime"], 0, function ()
			if not PNRP.Events["Radiation Storm"].vars["Active"] then return end
			local rand = math.random(100)
			if rand <= PNRP.Events["Radiation Storm"].vars["Chance"] and not timer.Exists("pnrp_ev_radstorm_stop") then
				
				for k, v in pairs(player.GetAll()) do
					local myrand = math.random(1, 4)
					
					if myrand == 1 then
						v:ChatPrint("You feel a weird change in the air. It burns your skin!")
					elseif myrand == 2 then
						v:ChatPrint("There is a funny taste in your mouth... Like metal?!")
					elseif myrand == 3 then
						v:ChatPrint("You have a feeling that you need to hide. The sky is starting to darken.")
					else
						v:ChatPrint("There is a dreading feeling that comes over you. A familiar terror...")
					end
					
				end
				
				local CreateStorm = PNRP.Events["Radiation Storm"].funcs["CreateRadStorm"]
				
				timer.Simple(40, function() 
					CreateStorm()
				end)
			end
		end)
	end
	
	net.Start("radstormeffects")
		net.WriteBit(false)
	net.Broadcast()
end
EVENT.funcs["RefreshTimers"] = pnrp_ev_RadStorm_RefreshTimers

PNRP.RegisterEvent(EVENT)


local EVENT = {}
EVENT.name = "Pet Headcrab"

EVENT.vars = {}
EVENT.vars["Active"] = true
EVENT.vars["Chance"] = 25
EVENT.vars["CheckTime"] = 900
EVENT.vars["Amount"] = 5

EVENT.funcs = {}
function pnrp_ev_PetHead_OnLoad()
	local LoadInfo = PNRP.Events["Pet Headcrab"].funcs["LoadInfo"]
	LoadInfo()
	
	timer.Simple( 10, function()
		
		timer.Create( "pnrp_ev_pethead_check", PNRP.Events["Pet Headcrab"].vars["CheckTime"], 0, function ()
			if not PNRP.Events["Pet Headcrab"].vars["Active"] then return end
			local rand = math.random(100)
			if rand <= PNRP.Events["Pet Headcrab"].vars["Chance"] then
				local SpawnPets = PNRP.Events["Pet Headcrab"].funcs["SpawnPets"]
				SpawnPets()
			end
		end)
	end)
end
hook.Add( "InitPostEntity", "pnrp_ev_PetHead_OnLoad", pnrp_ev_PetHead_OnLoad )

function pnrp_ev_PetHead_Spawn()
	local GM = GAMEMODE
	local spawnTbl = GM.spawnTbl
	
	local info = {}
	
	local headcrabs = {}
	for _, crab in pairs(ents.FindByClass( "npc_hdvermin" )) do
		if crab:GetNetworkedString("Owner", "World") == "World" then
			table.insert(headcrabs, crab)
			crab:EmitSound("npc/turret_floor/ping.wav", 100, 100)
		end
	end
	if #headcrabs > 0 then return end
	
	for k, v in pairs(player.GetAll()) do
		v:ChatPrint("You hear a familiar, but friendly coo...  Headcrabs?")
	end
	
	--  Make our temp-table with all possible nodes for this creature type.
	local posNodes = {}
	for _, node in pairs(spawnTbl) do
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
	
	--  Make sure we have entries in the nodelist.  Might not be any nodes on this map for this type.
	if #posNodes > 0 then
		--  Now, let's make us some NPCs! 
		for i = 1, PNRP.Events["Pet Headcrab"].vars["Amount"] do
			
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
					
					if (not validSpawn) or (not util.IsInWorld(point)) then
						point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
						  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
						  currentNode["z"])
					else
						point = groundtrace.HitPos + Vector(0,0,5)
					end
					retries = retries - 1
				end
				
				if validSpawn then
					local setHDVerminType = nil
					local rand = math.random(1, 3)
					if rand == 1 then
						setHDVerminType = "npc_hdvermin"
					elseif rand == 2 then
						setHDVerminType = "npc_hdvermin_fast"
					else
						setHDVerminType = "npc_hdvermin_poison"
					end
					
					local ent = ents.Create(setHDVerminType)
					ent:SetPos(point)
					
					ent:Spawn()
					ent:SetNetworkedString("Owner", "World")
					
					ent.Pet = true
					ent:SetNWString("Pet", true)
					
					spawned = true
				end
				
				mainRetries = mainRetries - 1
			end
		end
	end
end
EVENT.funcs["SpawnPets"] = pnrp_ev_PetHead_Spawn

function pnrp_ev_PetHead_SaveInfo()
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/events", "DATA") then file.CreateDir("PostNukeRP/events") end
	
	local saveTable = {}
	for k, v in pairs(PNRP.Events["Pet Headcrab"].vars) do
		saveTable[k] = v
	end
	
	file.Write("PostNukeRP/events/petheadcrab.txt",util.TableToJSON(saveTable))
end
EVENT.funcs["SaveInfo"] = pnrp_ev_PetHead_SaveInfo

function pnrp_ev_PetHead_LoadInfo()
	if file.Exists("PostNukeRP/events/petheadcrab.txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/events/petheadcrab.txt", "DATA"))
		
		for k, v in pairs(tbl) do
			PNRP.Events["Pet Headcrab"].vars[k] = v
		end
	end
end
EVENT.funcs["LoadInfo"] = pnrp_ev_PetHead_LoadInfo

PNRP.RegisterEvent(EVENT)


local EVENT = {}
EVENT.name = "Prewar Insertion"

EVENT.vars = {}
EVENT.vars["Active"] = true
EVENT.vars["Chance"] = 10
EVENT.vars["CheckTime"] = 900
EVENT.vars["Amount"] = 4

EVENT.funcs = {}
function pnrp_ev_Prewar_OnLoad()
	local LoadInfo = PNRP.Events["Prewar Insertion"].funcs["LoadMapInfo"]
	LoadInfo()
	
	timer.Simple( 10, function()
		
		timer.Create( "pnrp_ev_prewar_check", PNRP.Events["Prewar Insertion"].vars["CheckTime"], 0, function ()
			if not PNRP.Events["Prewar Insertion"].vars["Active"] then return end
			local rand = math.random(100)
			if rand <= PNRP.Events["Prewar Insertion"].vars["Chance"] then
				local SpawnDrop = PNRP.Events["Prewar Insertion"].funcs["Spawn"]
				SpawnDrop()
			end
		end)
	end)
end
hook.Add( "InitPostEntity", "pnrp_ev_Prewar_OnLoad", pnrp_ev_Prewar_OnLoad )

function pnrp_ev_PreWar_Spawn()
	local GM = GAMEMODE
	local spawnTbl = GM.spawnTbl
	
	local info = {}
	
	for k, v in pairs(player.GetAll()) do
		v:ChatPrint("Something is happening...you hear sounds you have not heard in years.")
	end
	
	--  Make our temp-table with all possible nodes for this creature type.
	local posNodes = {}
	for _, node in pairs(spawnTbl) do
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
		
		if isActive and not node["infIndoor"] then 
			table.insert(posNodes, node)
		end
	end
	
	--  Make sure we have entries in the nodelist.  Might not be any nodes on this map for this type.
	if #posNodes > 0 then
		--  Now, let's make us some NPCs! 
		
			
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
				
				if (not validSpawn) or (not util.IsInWorld(point)) then
					point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
					  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
					  currentNode["z"])
				else
					point = Vector(point.x, point.y, groundtrace.HitPos.z)  --groundtrace.HitPos + Vector(0,0,5)
				end
				retries = retries - 1
			end
			
			if validSpawn and util.IsInWorld(point) then
				-- local ent = ents.Create("npc_hdvermin")
				-- ent:SetPos(point)
				-- local rand = math.random(1, 3)
				-- if rand == 1 then
					-- ent:SetModel("models/headcrabclassic.mdl")
				-- elseif rand == 2 then
					-- ent:SetModel("models/headcrab.mdl")
				-- else
					-- ent:SetModel("models/headcrabblack.mdl")
				-- end
				-- ent:Spawn()
				-- ent:SetNetworkedString("Owner", "World")
				
				local Drop = PNRP.Events["Prewar Insertion"].funcs["DropPod"]
				Drop(point)
				
				spawned = true
			end
			
			mainRetries = mainRetries - 1
		end
	end
end
EVENT.funcs["Spawn"] = pnrp_ev_PreWar_Spawn

function pnrp_ev_PreWar_DropPod( pos )
	if pos == nil then return end
	
	local trace = {}
	trace.start = pos
	trace.endpos = trace.start + Vector(0,0,100000)
	trace.mask = MASK_SOLID_BRUSHONLY

	local rooftrace = util.TraceLine(trace)
	
	local target = ents.Create("info_target")
	local canister = ents.Create("env_headcrabcanister")
	
	ErrorNoHalt("Pos:  "..tostring(pos))
	
	target:SetPos(rooftrace.HitPos)
	target:SetKeyValue("targetname", "target")
	target:Spawn()
	target:Activate()
	
	local myAng = Angle(-90, 0, 0)
	
	canister:SetAngles(myAng)
	canister:SetPos(pos + Vector(0,0,15))
	canister:SetKeyValue("HeadcrabType", "npc_headcrab")
	canister:SetKeyValue("HeadcrabCount", 0)
	canister:SetKeyValue("LaunchPositionName", "target")
	canister:SetKeyValue("FlightSpeed", 100)
	canister:SetKeyValue("FlightTime", 3)
	canister:SetKeyValue("Damage", 50)
	canister:SetKeyValue("DamageRadius", 250)
	canister:SetKeyValue("SmokeLifetime", 10)
	canister:Fire("Spawnflags", "16384", 0)
	canister:Fire("FireCanister", "", 0)
	canister:Fire("AddOutput", "OnImpacted OpenCanister", 0)
	--canister:Fire("AddOutput", "OnOpened SpawnHeadcrabs", 0)
	canister:Spawn()
	canister:Activate()
	canister:SetNetworkedString("Owner", "Unownable")
	
	
	timer.Simple(5, function()
		target:Remove()
		
		local point = Vector(pos.x + math.random(-250,250),
			  pos.y + math.random(-250,250),
			  pos.z)
		
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
			
			if groundtrace.HitPos:Distance(pos) < 100 then
				validSpawn = false
			end
			
			if (not validSpawn) or (not util.IsInWorld(point)) then
				point = Vector(pos.x + math.random(-250,250),
					  pos.y + math.random(-250,250),
					  pos.z)
			else
				point = Vector(point.x, point.y, groundtrace.HitPos.z)  --groundtrace.HitPos + Vector(0,0,5)
			end
			retries = retries - 1
		end
		
		if validSpawn and util.IsInWorld(point) then
			local ent = ents.Create("npc_combine_s")
			ent:SetKeyValue( "additionalequipment", "weapon_ar2" )
			ent:SetKeyValue("squadname", "Combine_Unit_1")
			ent:SetKeyValue( "NumGrenades", "2" );
			ent:SetKeyValue( "tacticalvariant", "true" );
			ent:SetKeyValue( "spawnflags", tostring(bit.bor(8192, 256, 4)) );
			ent:SetModel( "models/combine_soldier.mdl" )

			ent:SetPos(point+Vector(0,0,50))
			ent:Spawn()
			ent:Activate()
			
			ent:SetHealth( 250 )

			--ent:Give("weapon_ar2")
			ent:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )

			ent:Fire( "StartPatrolling", "", 0.5 )
			ent:Fire( "SetSquad", "Combine_Unit_1", 0.5 )
			
			local contents = {}
			contents.res = {}
			contents.inv = {}
			contents.ammo = {}
			
			contents.res.scrap = 0
			contents.res.small = 0
			contents.res.chems = 0
			if math.random(100) <= 50 then
				contents.inv["wep_pulserifle"] = 1
			end
			contents.ammo["ar2"] = 50
			if math.random(100) <= 30 then
				local rand1 = math.random(100)
				local rand2 = math.random(100)
				if rand1 > 0 and rand1 <=50 then
					if rand2 <= 50 then
						contents.inv["healthvial"] = 1
					else
						contents.inv["battery"] = 1
					end
				elseif rand1 > 50 and rand1 <= 80 then
					if rand2 <= 33 then
						contents.inv["healthvial"] = 2
					elseif rand2 > 33 and rand2 <= 66 then
						contents.inv["healthvial"] = 1
						contents.inv["battery"] = 1
					else
						contents.inv["battery"] = 2
					end
				elseif rand1 > 80 and rand1 <=100 then
					if rand2 <= 25 then
						contents.inv["healthvial"] = 3
					elseif rand2 > 25 and rand2 <= 50 then
						contents.inv["healthvial"] = 2
						contents.inv["battery"] = 1
					elseif rand2 > 50 and rand2 <= 75 then
						contents.inv["healthvial"] = 1
						contents.inv["battery"] = 2
					elseif rand2 > 75 then
						contents.inv["battery"] = 3
					end
				end
			end
			
			ent.packTbl = contents
			ent.hasBackpack = true
			
			ent:SetNetworkedString("Owner", "Unownable")
		end
		
		for i = 1, PNRP.Events["Prewar Insertion"].vars["Amount"] do
			point = Vector(pos.x + math.random(-250,250),
				  pos.y + math.random(-250,250),
				  pos.z)
			
			retries = 50
			validSpawn = false
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
				
				if groundtrace.HitPos:Distance(pos) < 100 then
					validSpawn = false
				end
				
				if (not validSpawn) or (not util.IsInWorld(point)) then
					point = Vector(pos.x + math.random(-250,250),
						  pos.y + math.random(-250,250),
						  pos.z)
				else
					point = Vector(point.x, point.y, groundtrace.HitPos.z)  --groundtrace.HitPos + Vector(0,0,5)
				end
				retries = retries - 1
			end
			
			if validSpawn and util.IsInWorld(point) then
				local ent = ents.Create("npc_combine_s")
				ent:SetKeyValue( "additionalequipment", "weapon_smg1" )
				ent:SetKeyValue ("squadname", "Combine_Unit_1")
				ent:SetKeyValue( "NumGrenades", "2" );
				ent:SetKeyValue( "tacticalvariant", "true" );
				ent:SetKeyValue( "spawnflags", tostring(bit.bor(8192)) );
				ent:SetModel( "models/combine_soldier.mdl" )

				ent:SetPos(point+Vector(0,0,50))
				ent:Spawn()
				ent:Activate()
				
				ent:SetHealth( 150 )
				
				--ent:Give("weapon_ar2")
				ent:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )

				ent:Fire( "StartPatrolling", "", 0.5 );
				ent:Fire( "SetSquad", "Combine_Unit_1", 0.5 );
				
				if math.random(100) <= 20 then
					local contents = {}
					contents.res = {}
					contents.inv = {}
					contents.ammo = {}
					
					contents.res.scrap = 0
					contents.res.small = 0
					contents.res.chems = 0
					
					local rand1 = math.random(100)
					if rand1 <= 33 then
						contents.ammo["smg1"] = 50
					elseif rand1 > 33 and rand1 <= 66 then
						contents.inv["healthvial"] = 1
					elseif rand1 > 66 then
						contents.inv["battery"] = 1
					end
					
					ent.packTbl = contents
					ent.hasBackpack = true
				end

				ent:SetNetworkedString("Owner", "Unownable")
			end
		end
	end)
	
	timer.Simple(60, function()
		canister:Remove()
	end)
end
EVENT.funcs["DropPod"] = pnrp_ev_PreWar_DropPod

function pnrp_ev_PreWar_SaveMapInfo()
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/events", "DATA") then file.CreateDir("PostNukeRP/events") end
	if !file.IsDir("PostNukeRP/events/prewar", "DATA") then file.CreateDir("PostNukeRP/events/prewar") end
	
	local saveTable = {}
	for k, v in pairs(PNRP.Events["Prewar Insertion"].vars) do
		saveTable[k] = v
	end
	
	file.Write("PostNukeRP/events/prewar/"..game.GetMap()..".txt",util.TableToJSON(saveTable))
end
EVENT.funcs["SaveMapInfo"] = pnrp_ev_PreWar_SaveMapInfo

function pnrp_ev_PreWar_LoadMapInfo()
	if file.Exists("PostNukeRP/events/prewar/"..game.GetMap()..".txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/events/prewar/"..game.GetMap()..".txt", "DATA"))
		
		for k, v in pairs(tbl) do
			PNRP.Events["Prewar Insertion"].vars[k] = v
		end
	end
end
EVENT.funcs["LoadMapInfo"] = pnrp_ev_PreWar_LoadMapInfo

PNRP.RegisterEvent(EVENT)

function ClampWorldVector(vec)
	vec.x = math.Clamp( vec.x , -16380, 16380 )
	vec.y = math.Clamp( vec.y , -16380, 16380 )
	vec.z = math.Clamp( vec.z , -16380, 16380 )
	return vec
end

local EVENT = {}
EVENT.name = "Pet Bird"

EVENT.vars = {}
EVENT.vars["Active"] = true
EVENT.vars["Chance"] = 20
EVENT.vars["CheckTime"] = 1000
EVENT.vars["Amount"] = 5

EVENT.funcs = {}
function pnrp_ev_PetBird_OnLoad()
	local LoadInfo = PNRP.Events["Pet Bird"].funcs["LoadInfo"]
	LoadInfo()
	
	timer.Simple( 10, function()
		
		timer.Create( "pnrp_ev_petbird_check", PNRP.Events["Pet Bird"].vars["CheckTime"], 0, function ()
			if not PNRP.Events["Pet Bird"].vars["Active"] then return end
			local rand = math.random(100)
			if rand <= PNRP.Events["Pet Bird"].vars["Chance"] then
				local SpawnPets = PNRP.Events["Pet Bird"].funcs["SpawnPets"]
				SpawnPets()
			end
		end)
	end)
end
hook.Add( "InitPostEntity", "pnrp_ev_PetBird_OnLoad", pnrp_ev_PetBird_OnLoad )

function pnrp_ev_PetBird_Spawn()
	local GM = GAMEMODE
	local spawnTbl = GM.spawnTbl
	
	local info = {}
	
	local birds = {}
	for _, bird in pairs(ents.FindByClass( "npc_petbird" )) do
		if bird:GetNetworkedString("Owner", "World") == "World" then
			table.insert(birds, bird)
			bird:EmitSound("npc/turret_floor/ping.wav", 100, 100)
		end
	end
	if #birds > 0 then return end
	
	for k, v in pairs(player.GetAll()) do
	--	v:ChatPrint("Birds")
	end
	
	--  Make our temp-table with all possible nodes for this creature type.
	local posNodes = {}
	for _, node in pairs(spawnTbl) do
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
	
	--  Make sure we have entries in the nodelist.  Might not be any nodes on this map for this type.
	if #posNodes > 0 then
		--  Now, let's make us some NPCs! 
		for i = 1, PNRP.Events["Pet Bird"].vars["Amount"] do
			
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
					
					if (not validSpawn) or (not util.IsInWorld(point)) then
						point = Vector(currentNode["x"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
						  currentNode["y"] + math.random(currentNode["distance"]*-1,currentNode["distance"]),
						  currentNode["z"])
					else
						point = groundtrace.HitPos + Vector(0,0,5)
					end
					retries = retries - 1
				end
				
				if validSpawn then
					local setBirdType = nil
					local rand = math.random(1, 3)
					if rand == 1 then
						setBirdType = "npc_petbird_pigeon"
					elseif rand == 2 then
						setBirdType = "npc_petbird_crow"
					else
						setBirdType = "npc_petbird_gull"
					end
					
					local ent = ents.Create(setBirdType)
					ent:SetPos(point)
					
					ent:Spawn()
					ent:SetNetworkedString("Owner", "World")
					
					ent.Pet = true
					ent:SetNWString("Pet", true)
					
					spawned = true
				end
				
				mainRetries = mainRetries - 1
			end
		end
	end
end
EVENT.funcs["SpawnPets"] = pnrp_ev_PetBird_Spawn

function pnrp_ev_PetBird_SaveInfo()
	if !file.IsDir("PostNukeRP", "DATA") then file.CreateDir("PostNukeRP") end
	if !file.IsDir("PostNukeRP/events", "DATA") then file.CreateDir("PostNukeRP/events") end
	
	local saveTable = {}
	for k, v in pairs(PNRP.Events["Pet Bird"].vars) do
		saveTable[k] = v
	end
	
	file.Write("PostNukeRP/events/petbirds.txt",util.TableToJSON(saveTable))
end
EVENT.funcs["SaveInfo"] = pnrp_ev_PetBird_SaveInfo

function pnrp_ev_PetBird_LoadInfo()
	if file.Exists("PostNukeRP/events/petbirds.txt", "DATA") then
		tbl = util.JSONToTable(file.Read("PostNukeRP/events/petbirds.txt", "DATA"))
		
		for k, v in pairs(tbl) do
			PNRP.Events["Pet Bird"].vars[k] = v
		end
	else
		
	end
end
EVENT.funcs["LoadInfo"] = pnrp_ev_PetBird_LoadInfo

PNRP.RegisterEvent(EVENT)