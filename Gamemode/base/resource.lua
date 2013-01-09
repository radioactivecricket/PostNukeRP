local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

CreateConVar("pnrp_ResUsesNodes", "1")

local spawnTbl = GM.spawnTbl
/*---------------------------------------------------------
  Resource functions
---------------------------------------------------------*/
function PlayerMeta:GetResource(resource)
	return math.Round(self.Resources[resource]) or 0
end

function PlayerMeta:SetResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 end

	self.Resources[resource] = int
	
	net.Start("pnrp_SetResource")
		net.WriteString(resource)
		net.WriteDouble(int)
	net.Send(self)
	
end
util.AddNetworkString("pnrp_SetResource")

function PlayerMeta:IncResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 return end

	self.Resources[resource] = self.Resources[resource] + int
	
	net.Start("pnrp_SetResource")
		net.WriteString(resource)
		net.WriteDouble(self:GetResource(resource))
	net.Send(self)
	
end

function PlayerMeta:DecResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 return end
	
	
	if self:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
		Msg("Admin No Cost\n")
		return
	end
	if int == nil then int = 0 end
--	Msg(tostring(int).."\n")
	self.Resources[resource] = self.Resources[resource] - int
	net.Start("pnrp_SetResource")
		net.WriteString(resource)
		net.WriteDouble(self:GetResource(resource))
	net.Send(self)

end

function PlayerMeta:GiveResource(resource,int)
	local trace = {}
	trace.start = self:GetShootPos()
	trace.endpos = trace.start + (self:GetAimVector() * dist)
	trace.filter = self

	local traceLine = util.TraceLine(trace)
	if traceLine.HitNonWorld then
		target = traceLine.Entity
		if target:IsPlayer() then 
			target:IncResource(resource,int)
			self.Resources[resource] = self.Resources[resource] - int
		end
	end
end

function PNRP.tradeResToPlayer()
	local ply = net.ReadEntity()
	local target = net.ReadEntity()
	local scrap = math.Round(net.ReadDouble())
	local parts = math.Round(net.ReadDouble())
	local chems = math.Round(net.ReadDouble())
	local option = net.ReadString()
	
	local ply_scrap = ply:GetResource("Scrap")
	local ply_parts = ply:GetResource("Small_Parts")
	local ply_chems = ply:GetResource("Chemicals")
	
	if not IsValid(target) then 
		ply:ChatPrint("Unable to find player")
		return 
	end
	
	if option == "trade" then
		if scrap < 0 or scrap == nil then scrap = 0 end
		if parts < 0 or parts == nil then parts = 0 end
		if chems < 0 or chems == nil then chems = 0 end
		
		if scrap > ply_scrap then scrap = ply_scrap end
		if parts > ply_parts then parts = ply_parts end
		if chems > ply_chems then chems = ply_chems end
		
		if scrap > 0 then
			giveResChatPrint(ply, target, scrap, "Scrap")
		end
		if parts > 0 then
			giveResChatPrint(ply, target, parts, "Small_Parts")
		end
		if chems > 0 then
			giveResChatPrint(ply, target, chems, "Chemicals")		
		end
		
	elseif option == "admin_trade" then
		AdmingiveResChatPrint(ply, target, scrap, "Scrap", option)
		AdmingiveResChatPrint(ply, target, parts, "Scrap", option)
		AdmingiveResChatPrint(ply, target, chems, "Scrap", option)
	end	
end
net.Receive( "tradeResTo", PNRP.tradeResToPlayer )
util.AddNetworkString("tradeResTo")

function giveResChatPrint(ply, target, int, resource)
	target:ChatPrint("You received "..tostring(int).." "..tostring(resource).." from "..ply:Nick()..".")
	target:IncResource(resource,int)
	ply:ChatPrint("You gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".")
	ply:DecResource(resource,int)
end

function AdmingiveResChatPrint(ply, target, int, resource)
	target:ChatPrint("[Admin Trade] You received "..tostring(int).." "..tostring(resource).." from "..ply:Nick()..".")
	target:IncResource(resource,int)
	ply:ChatPrint("[Admin Trade] You gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".")
end

function GM.GiveResource(ply,command,args)
	local trace = {}
	local resource = args[1] 
	local int = tonumber(args[2])
	local targetName
	local dist = 300
	
	trace.start = ply:GetShootPos()
	trace.endpos = trace.start + (ply:GetAimVector() * dist)
	trace.filter = ply
	
	for k,v in pairs(ents.GetAll()) do
			if v:GetName()==args[3] then
				target = v
			end
			
		end
		
	if int <= 0 then
		int = 0	
		return
	end
	
	if int >= ply:GetResource(resource) then
		int = ply:GetResource(resource)
	end
	
--	local traceLine = util.TraceLine(trace)
--	if traceLine.HitNonWorld then
--		target = traceLine.Entity
	if target:IsPlayer() then 
		ply:ChatPrint("You gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".")
		target:IncResource(resource,int)
		target:ChatPrint("You received "..tostring(int).." "..tostring(resource).." from "..ply:Nick()..".")
		ply:DecResource(resource,int)
		Msg(ply:Nick().." gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".\n")
	else
		Msg("Target Not Found ("..tostring(target)..") Passed: "..tostring(args[3]).."\n")
	end
	
--	end
end
concommand.Add( "pnrp_give_res", GM.GiveResource )

function GM.AdminGiveResource(ply,command,args)
	if ply:IsAdmin() then	
		local resource = args[1] 
		local int = tonumber(args[2])
		local targetName
		
		for k,v in pairs(ents.GetAll()) do
				if v:GetName()==args[3] then
					target = v
				end
				
			end
			
		if target:IsPlayer() then 
		
			if int <= 0 and target:GetResource(resource) <= 0 then
				ply:ChatPrint("Player allready has 0 Resources")
				return
			end
			
			if int + target:GetResource(resource) <= 0 then
				int = target:GetResource(resource)
				int = -int
			end
			
			if int == 0 then
				return
			end
			
			ply:ChatPrint("You gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".")
			target:IncResource(resource,int)
			target:ChatPrint("You received "..tostring(int).." "..tostring(resource).." from "..ply:Nick()..".")
			
			Msg("Admin: "..ply:Nick().." gave "..target:Nick().." "..tostring(int).." "..tostring(resource)..".\n")
		else
			Msg("Admin: Target Not Found ("..tostring(target)..") Passed: "..tostring(args[3]).."\n")
		end
		
	--	end
	end
end
concommand.Add( "pnrp_admin_give_res", GM.AdminGiveResource )


function PlayerMeta:GetAllResources()
	local num = 0

	for k,v in pairs(self.Resources) do
		num = num + v
	end

	return num
end

function PlayerMeta:GetResource(resource)
	return self.Resources[resource] or 0
end

/*---------------------------------------------------------
  Entity checks
---------------------------------------------------------*/
function EntityMeta:IsJunkPile()
	local junk = table.Add(PNRP.JunkModels)
	for k,v in pairs(junk) do
		if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
			return true
		end
	end

	return false
end

function EntityMeta:IsChemPile()
	local junk = table.Add(PNRP.ChemicalModels)
	for k,v in pairs(junk) do
		if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
			return true
		end
	end

	return false
end

function EntityMeta:IsSmallPile()
	local junk = table.Add(PNRP.SmallPartsModels)
	for k,v in pairs(junk) do
		if string.lower(v) == self:GetModel() or string.gsub(string.lower(v),"/","\\") == self:GetModel() then
			return true
		end
	end

	return false
end

function EntityMeta:DropToGround()
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start + Vector(0,0,-100000)
	trace.mask = MASK_SOLID_BRUSHONLY
	trace.filter = self

	local tr = util.TraceLine(trace)

	self:SetPos(tr.HitPos + Vector(0,0,4))
end

function EntityMeta:IsProp()
	local cls = self:GetClass()

	if (cls == "prop_physics" or cls == "prop_physics_multiplayer" or cls == "prop_dynamic") then
		return true
	end

	return false
end

/*---------------------------------------------------------
  Resource reproduction
---------------------------------------------------------*/
function GM.ReproduceRes()
	local GM = GAMEMODE
	
	spawnTbl = GM.spawnTbl
	if GetConVarNumber("pnrp_ReproduceRes") == 1 then
		local info = {}
		
		-- Get all my amounts.
		local piles = ents.FindByClass( "ent_resource" )
		
		local spawnables = {}
		
		--  Check 'em against max amounts.
		local resourcespawn = GetConVarNumber("pnrp_MaxReproducedRes") - #piles
		
		if resourcespawn and resourcespawn > 0 then
			-- We're gonna make sure we hold max all the time.
			
			--  Make our temp-table with all possible nodes for this creature type.
			local posNodes = {}
			for _, node in pairs(spawnTbl) do
				if util.tobool(node["spwnsRes"]) then
					local isActive = true
					-- if not util.tobool( node["infIndoor"]) then
						-- isActive = true
					-- end
					
					local doorEnt =  node["infLinked"]
					if doorEnt then
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
				for i = 1, resourcespawn do
					
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
							
							-- local height = groundtrace.HitPos:Distance(rooftrace.HitPos)
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
							local ent = ents.Create("ent_resource")
							ent:SetAngles(Angle(0,math.random(1,360),0))
							
							local pileType = math.random(1,100)
							if pileType >= 1 and pileType <= 50 then
								ent:SetModel(PNRP.JunkModels[math.random(1,#PNRP.JunkModels)])
							elseif pileType > 50 and pileType <= 75 then
								ent:SetModel(PNRP.ChemicalModels[math.random(1,#PNRP.ChemicalModels)])
							else
								ent:SetModel(PNRP.SmallPartsModels[math.random(1,#PNRP.SmallPartsModels)])
							end
							ent:SetPos(point)
							ent:DropToGround()
							ent:Spawn()
							if pileType >= 1 and pileType <= 50 then
								ent.resType = "Scrap"
							elseif pileType > 50 and pileType <= 75 then
								ent.resType = "Chemicals"
							else
								ent.resType = "Small_Parts"
							end
							ent.amount = math.random(5,15)
							ent:SetNetworkedString("Owner", "Unownable")
							ent:GetPhysicsObject():EnableMotion(false)
							ent:SetMoveType(MOVETYPE_NONE)
							
							spawned = true
						end
						
						mainRetries = mainRetries - 1
					end
				end
			end
		end
	end
--	timer.Simple(2,self.SpawnMobs)
	timer.Simple(60,GM.ReproduceRes)
end

--timer.Simple(2,GM.SpawnMobs)
timer.Simple(60,GM.ReproduceRes)

function GM.RemoveRes(ply,command,args)
	if ply:IsAdmin() then
		ply:ChatPrint("Removing resources.")
		for k,v in pairs(ents.FindByClass("ent_resource")) do
			v:Remove()
		end
--		self.ReproduceRes()
	else
		ply:ChatPrint("This is an admin only command!")
	end
end

concommand.Add( "pnrp_clearres", GM.RemoveRes )

function GM.CountRes( ply, command, args )
	local piles = 0
	for k,v in pairs(ents.FindByClass("ent_resource")) do
		piles = piles + 1
	end
	ply:ChatPrint("Number of piles:  "..tostring(piles))
end
concommand.Add( "pnrp_countres", GM.CountRes)
