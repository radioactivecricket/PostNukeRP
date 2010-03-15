local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

CreateConVar("pnrp_ResUsesNodes", "1")

local spawnTbl = GM.spawnTbl
/*---------------------------------------------------------
  Resource functions
---------------------------------------------------------*/
function PlayerMeta:GetResource(resource)
	return self.Resources[resource] or 0
end

function PlayerMeta:SetResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 end

	self.Resources[resource] = int

	umsg.Start("pnrp_SetResource",self)
	umsg.String(resource)
	umsg.Short(int)
	umsg.End()
end

function PlayerMeta:IncResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 return end

	self.Resources[resource] = self.Resources[resource] + int

	umsg.Start("pnrp_SetResource",self)
	umsg.String(resource)
	umsg.Short(self:GetResource(resource))
	umsg.End()
end

function PlayerMeta:DecResource(resource,int)
	if !self.Resources[resource] then self.Resources[resource] = 0 return end
	
	
	if self:IsAdmin() and GetConVarNumber("pnrp_adminNoCost") == 1 then 
		Msg("Admin No Cost\n")
		return
	end
	
	Msg(tostring(int).."\n")
	self.Resources[resource] = self.Resources[resource] - int
	umsg.Start("pnrp_SetResource",self)
	umsg.String(resource)
	umsg.Short(self:GetResource(resource))
	umsg.End()
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
	local info = {}
--	print("Res reproduction called.")
	if GetConVarNumber("pnrp_ReproduceRes") == 1 then
		local piles = {}
		for k,v in pairs(ents.GetAll()) do
			if v:IsJunkPile() or v:IsChemPile() or v:IsSmallPile() then
				table.insert(piles,v)
			end
		end
		
		local mySP = {}
		
		if GetConVarNumber("pnrp_ResUsesNodes") == 1 and #spawnTbl > 0 then
			mySP = spawnTbl[math.random(1,#spawnTbl)]
			if #piles == 0 then
				
				for i = 1,20 do
					mySP = spawnTbl[math.random(1,#spawnTbl)]
					info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
					info.Retries = 50

					--Find pos in world
					while util.IsInWorld(info.pos) == false and info.Retries > 0 do
						info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
						info.Retries = info.Retries - 1
					end

					--Find ground
					local trace = {}
					trace.start = info.pos
					trace.endpos = trace.start + Vector(0,0,-100000)
					trace.mask = MASK_SOLID_BRUSHONLY

					local groundtrace = util.TraceLine(trace)

					--Assure space
					local nearby = ents.FindInSphere(groundtrace.HitPos,200)
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
					--removed "and (groundtrace.MatType == MAT_DIRT or groundtrace.MatType == MAT_GRASS or groundtrace.MatType == MAT_SAND)"
					if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
						local ent = ents.Create("prop_physics")
						ent:SetAngles(Angle(0,math.random(1,360),0))
						
						local pileType = math.random(1,3)
						if pileType == 1 then
							ent:SetModel(PNRP.JunkModels[math.random(1,#PNRP.JunkModels)])
						end
						if pileType == 2 then
							ent:SetModel(PNRP.ChemicalModels[math.random(1,#PNRP.ChemicalModels)])
						end
						if pileType == 3 then
							ent:SetModel(PNRP.SmallPartsModels[math.random(1,#PNRP.SmallPartsModels)])
						end
						ent:SetPos(groundtrace.HitPos)
						ent:DropToGround()
						ent:Spawn()
						ent:SetNetworkedString("Owner", "Unownable")
						ent:GetPhysicsObject():EnableMotion(false)
						ent:SetMoveType(MOVETYPE_NONE)
					end
				end
			end
			if #piles < GetConVarNumber("pnrp_MaxReproducedRes") then
				for i = 1, 5 do
					local num = math.random(1,2)
					if num == 1 then
						
						mySP = spawnTbl[math.random(1,#spawnTbl)]
						info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
						info.Retries = 50

						--Find pos in world
						while util.IsInWorld(info.pos) == false and info.Retries > 0 do
							info.pos = Vector(mySP["x"] + math.random(mySP["distance"]*-1,mySP["distance"]),mySP["y"] + math.random(mySP["distance"]*-1,mySP["distance"]),1000)
							info.Retries = info.Retries - 1
						end

						--Find ground
						local trace = {}
						trace.start = info.pos
						trace.endpos = trace.start + Vector(0,0,-100000)
						trace.mask = MASK_SOLID_BRUSHONLY

						local groundtrace = util.TraceLine(trace)

						--Assure space
						local nearby = ents.FindInSphere(groundtrace.HitPos,200)
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
						--removed "and (groundtrace.MatType == MAT_DIRT or groundtrace.MatType == MAT_GRASS or groundtrace.MatType == MAT_SAND)"
						if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
							local ent = ents.Create("prop_physics")
							ent:SetAngles(Angle(0,math.random(1,360),0))
							
							local pileType = math.random(1,3)
							if pileType == 1 then
								ent:SetModel(PNRP.JunkModels[math.random(1,#PNRP.JunkModels)])
							end
							if pileType == 2 then
								ent:SetModel(PNRP.ChemicalModels[math.random(1,#PNRP.ChemicalModels)])
							end
							if pileType == 3 then
								ent:SetModel(PNRP.SmallPartsModels[math.random(1,#PNRP.SmallPartsModels)])
							end
							ent:SetPos(groundtrace.HitPos)
							ent:DropToGround()
							ent:Spawn()
							ent:SetNetworkedString("Owner", "Unownable")
							ent:GetPhysicsObject():EnableMotion(false)
							ent:SetMoveType(MOVETYPE_NONE)
						end
					end
				end
			end
		else
			if #piles < GetConVarNumber("pnrp_MaxReproducedRes") then
				for k,ent in pairs(piles) do
					local num = math.random(1,3)

					if num == 1 then
						local nearby = {}
						for k,v in pairs(ents.FindInSphere(ent:GetPos(),50)) do
							if v:IsProp() then
								table.insert(nearby,v)
							end
						end

						if #nearby < 3 then
							local pos = ent:GetPos() + Vector(math.random(-500,500),math.random(-500,500),0)
							local retries = 50

							while (pos:Distance(ent:GetPos()) < 200 or PNRP.ClassIsNearby(pos,"prop_physics",100)) and retries > 0 do
								pos = ent:GetPos() + Vector(math.random(-300,300),math.random(-300,300),0)
								retries = retries - 1
							end

							local pos = pos + Vector(0,0,500)

							local ent = ents.Create("prop_physics")
							ent:SetAngles(Angle(0,math.random(1,360),0))
							
							local pileType = math.random(1,100)
							if pileType < 50 then
								ent:SetModel(PNRP.JunkModels[math.random(1,#PNRP.JunkModels)])
							elseif pileType < 75 then
								ent:SetModel(PNRP.ChemicalModels[math.random(1,#PNRP.ChemicalModels)])
							elseif pileType < 100 then
								ent:SetModel(PNRP.SmallPartsModels[math.random(1,#PNRP.SmallPartsModels)])
							end
							
							ent:SetPos(pos)
							ent:DropToGround()
							ent:Spawn()
							ent:SetNetworkedString("Owner", "Unownable")
							ent:GetPhysicsObject():EnableMotion(false)
							ent:SetMoveType(MOVETYPE_NONE)
						end
					end
				end
			end
			if #piles == 0 then
				local info = {}
				for i = 1,20 do
					info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
					info.Retries = 50

					--Find pos in world
					while util.IsInWorld(info.pos) == false and info.Retries > 0 do
						info.pos = Vector(math.random(-10000,10000),math.random(-10000,10000),1000)
						info.Retries = info.Retries - 1
					end

					--Find ground
					local trace = {}
					trace.start = info.pos
					trace.endpos = trace.start + Vector(0,0,-100000)
					trace.mask = MASK_SOLID_BRUSHONLY

					local groundtrace = util.TraceLine(trace)

					--Assure space
					local nearby = ents.FindInSphere(groundtrace.HitPos,200)
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
					--removed "and (groundtrace.MatType == MAT_DIRT or groundtrace.MatType == MAT_GRASS or groundtrace.MatType == MAT_SAND)"
					if info.HasSpace and skytrace.HitSky and !watertrace.Hit then
						local ent = ents.Create("prop_physics")
						ent:SetAngles(Angle(0,math.random(1,360),0))
						
						local pileType = math.random(1,3)
						if pileType == 1 then
							ent:SetModel(PNRP.JunkModels[math.random(1,#PNRP.JunkModels)])
						end
						if pileType == 2 then
							ent:SetModel(PNRP.ChemicalModels[math.random(1,#PNRP.ChemicalModels)])
						end
						if pileType == 3 then
							ent:SetModel(PNRP.SmallPartsModels[math.random(1,#PNRP.SmallPartsModels)])
						end
						ent:SetPos(groundtrace.HitPos)
						ent:DropToGround()
						ent:Spawn()
						ent:SetNetworkedString("Owner", "Unownable")
						ent:GetPhysicsObject():EnableMotion(false)
						ent:SetMoveType(MOVETYPE_NONE)
					end
				end
			end
		end
	end

	timer.Simple(60,GM.ReproduceRes)
end

timer.Simple(60,GM.ReproduceRes)

function GM.RemoveRes(ply,command,args)
	if ply:IsAdmin() then
		ply:ChatPrint("Removing resources.")
		for k,v in pairs(ents.GetAll()) do
			if v:IsJunkPile() or v:IsChemPile() or v:IsSmallPile() then
				v:Remove()
			end
		end
--		self.ReproduceRes()
	else
		ply:ChatPrint("This is an admin only command!")
	end
end

concommand.Add( "pnrp_clearres", GM.RemoveRes )

function GM.CountRes( ply, command, args )
	local piles = {}
	for k,v in pairs(ents.GetAll()) do
		if v:IsJunkPile() or v:IsChemPile() or v:IsSmallPile() then
			table.insert(piles,v)
		end
	end
	ply:ChatPrint("Number of piles:  "..tostring(#piles))
end
concommand.Add( "pnrp_countres", GM.CountRes)
