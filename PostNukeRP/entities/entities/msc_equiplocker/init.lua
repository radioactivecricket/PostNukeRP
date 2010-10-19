AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_forest/footlocker01_closed.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props_forest/footlocker01_closed.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.Community = self.Entity:GetNWString("community_owner")
	self.Enabled = false
	self.BreakInTimer = 60
	self.BreakingIn = nil
	self.Repairing = nil
	self.Entity:SetColor(255, 255, 255, 155)
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	local position = self.Entity:GetPos()
	
	timer.Simple(10, function()
		self.Entity:SetColor(255, 255, 255, 255)
		self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)

		self.Entity:SetPos(position)
		self.Enabled = true
	end )
end

function ENT:Use( activator, caller )
	if not self.Enabled then return end
	if ( activator:IsPlayer() ) then
		if activator:KeyPressed( IN_USE ) then
			if activator == self.Repairing then
				timer.Stop(activator:UniqueID()..tostring(self:EntIndex()))
				self.Repairing = nil
				activator:SetMoveType(MOVETYPE_WALK)
				umsg.Start("locker_stoprepair", activator)
				umsg.End()
			end
			if activator.Community == self.Community then
				local communityTbl = GetCommunityTbl(self.Community)
				if communityTbl == nil then return end
				
				local playerTbl = { }
				local ILoc = PNRP.GetInventoryLocation( activator )
				if file.Exists( ILoc ) then 
					playerTbl = util.KeyValuesToTable(file.Read(ILoc))
				end
				datastream.StreamToClients( activator, "locker_menu",{ ["locker"] = self, ["health"] = math.Round((self.BreakInTimer / 60) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
				
				-- umsg.Start("locker_menu", activator)
					-- umsg.Entity(self)
					-- umsg.Long(communityTbl["res"]["Scrap"])
					-- umsg.Long(communityTbl["res"]["Small_Parts"])
					-- umsg.Long(communityTbl["res"]["Chemicals"])
					-- umsg.Short( math.Round((self.BreakInTimer / 30) * 100) )
				-- umsg.End()
			else
				-- Just a placeholder for breaking into these things.
				umsg.Start("locker_breakin", activator)
					umsg.Entity(self)
					umsg.Short(self.BreakInTimer)
				umsg.End()
			end
		end
	end
end

function TakeItems( ply, handler, id, encoded, decoded )
	local locker = decoded["locker"]
	if not locker then return end
	
	local Item = decoded["item"]
	local Amount = math.Round(decoded["amount"])
	
	local communityTbl = GetCommunityTbl(locker.Community)
	
	if Amount <= 0 or (not Amount) then return end
	if Amount > communityTbl["inv"][Item] then Amount = communityTbl["inv"][Item] end
	if Amount <= 0 or (not Amount) then return end
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav")
	else
		weightCap = GetConVarNumber("pnrp_packCap")
	end
	
	local AmntTaken = 0
	for i = 1, Amount do
		local expWeight = PNRP.InventoryWeight( ply ) + weight
		if expWeight <= weightCap then
			ply:AddToInventory( Item )
			AmntTaken = AmntTaken + 1
		else
			ply:ChatPrint("You were only able to carry "..tostring(AmntTaken).." of these!")
			break
		end
	end

	SubCommunityItem( locker.Community, Item, AmntTaken )
end
datastream.Hook( "locker_take", TakeItems )

function PutItems( ply, handler, id, encoded, decoded )
	local locker = decoded["locker"]
	if not locker then return end
	
	local Item = decoded["item"]
	local Amount = math.Round(decoded["amount"])
	
	local Check = PNRP.TakeFromInventoryBulk( ply, Item, Amount )
	if Check then
		AddCommunityItem( locker.Community, Item, Amount )
	else
		ply:ChatPrint("You do not have enough of this")
	end
end
datastream.Hook( "locker_put", PutItems )

function LockerBreakIn( ply, handler, id, encoded, decoded )
	local locker = decoded["locker"]
	if not locker then 
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		return 
	end
	
	if locker.Repairing then
		ply:ChatPrint("You can't break in while someone's repairing this locker!")
		return
	end
	
	if not locker.BreakingIn then
		if locker.BreakInTimer <= 0 then
			umsg.Start("locker_stopbreakin", ply)
			umsg.End()
			
			local playerTbl = { }
			local ILoc = PNRP.GetInventoryLocation( ply )
			if file.Exists( ILoc ) then 
				playerTbl = util.KeyValuesToTable(file.Read(ILoc))
			end
			
			local communityTbl = GetCommunityTbl(locker.Community)
			datastream.StreamToClients( ply, "locker_menu",{ ["locker"] = locker, ["health"] = math.Round((locker.BreakInTimer / 30) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
			-- umsg.Start("locker_menu", ply)
				-- local communityTbl = GetCommunityTbl(locker.Community)
				-- umsg.Entity(locker)
				-- umsg.Long(communityTbl["res"]["Scrap"])
				-- umsg.Long(communityTbl["res"]["Small_Parts"])
				-- umsg.Long(communityTbl["res"]["Chemicals"])
				-- umsg.Short( math.Round((locker.BreakInTimer / 30) * 100) )
			-- umsg.End()
		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			locker.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(locker:EntIndex()), 1, locker.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not locker:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					umsg.Start("locker_stopbreakin", ply)
					umsg.End()
					if locker:IsValid() then 
						locker.BreakingIn = nil 
						timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
					end
					return
				end
				locker.BreakInTimer = locker.BreakInTimer - 1
				if locker.BreakInTimer <= 0 then
					umsg.Start("locker_stopbreakin", ply)
					umsg.End()
					
					ply:SetMoveType(MOVETYPE_WALK)
					locker.BreakingIn = nil
					
					local communityTbl = GetCommunityTbl(locker.Community)
					if communityTbl == nil then return end
					
					local playerTbl = { }
					local ILoc = PNRP.GetInventoryLocation( ply )
					if file.Exists( ILoc ) then 
						playerTbl = util.KeyValuesToTable(file.Read(ILoc))
					end
					
					datastream.StreamToClients( ply, "locker_menu",{ ["locker"] = locker, ["health"] = math.Round((locker.BreakInTimer / 60) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
					-- umsg.Start("locker_menu", ply)
						-- umsg.Entity(locker)
						-- umsg.Long(communityTbl["res"]["Scrap"])
						-- umsg.Long(communityTbl["res"]["Small_Parts"])
						-- umsg.Long(communityTbl["res"]["Chemicals"])
						-- umsg.Short( math.Round((locker.BreakInTimer / 30) * 100) )
					-- umsg.End()
					-- ply:Freeze(false)
					locker:SetModel("models/props_forest/footlocker01_open.mdl")
					locker:EmitSound("physics/wood/wood_box_break2.wav",100,100)
					timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
				else
					locker:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		end
	elseif ply == locker.BreakingIn then
		timer.Destroy(ply:UniqueID()..tostring(locker:EntIndex()))
		umsg.Start("locker_stopbreakin", ply)
		umsg.End()
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		if locker:IsValid() then
			locker.BreakingIn = nil
		end
	else
		ply:ChatPrint("Someone is already breaking into this locker.")
	end
end
datastream.Hook( "locker_breakin", LockerBreakIn )

function LockerRepair( ply, handler, id, encoded, decoded )
	local locker = decoded["locker"]
	if locker.BreakInTimer >= 30 then
		ply:ChatPrint("This locker is fully repaired!")
		return
	end
	if not locker.Repairing then
		if not locker.BreakingIn then
			umsg.Start("locker_repair", ply)
				umsg.Entity(locker)
				umsg.Short(locker.BreakInTimer)
			umsg.End()
			
			ply:SetMoveType(MOVETYPE_NONE)
			locker.Repairing = ply
			locker:SetModel("models/props_forest/footlocker01_closed.mdl")
			timer.Create( ply:UniqueID()..tostring(locker:EntIndex()), 1, locker.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not locker:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					umsg.Start("locker_stoprepair", ply)
					umsg.End()
					if locker:IsValid() then 
						locker.Repairing = nil 
						timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
					end
					return
				end
				locker.BreakInTimer = locker.BreakInTimer + 1
				if locker.BreakInTimer >= 60 then
					umsg.Start("locker_stoprepair", ply)
					umsg.End()
					
					ply:SetMoveType(MOVETYPE_WALK)
					locker.Repairing = nil
					locker.BreakInTimer = 60
					
					local communityTbl = GetCommunityTbl(locker.Community)
					if communityTbl == nil then return end
					
					local playerTbl = { }
					local ILoc = PNRP.GetInventoryLocation( ply )
					if file.Exists( ILoc ) then 
						playerTbl = util.KeyValuesToTable(file.Read(ILoc))
					end
					
					datastream.StreamToClients( ply, "locker_menu",{ ["locker"] = locker, ["health"] = math.Round((locker.BreakInTimer / 60) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
					-- umsg.Start("locker_menu", ply)
						-- umsg.Entity(locker)
						-- umsg.Long(communityTbl["res"]["Scrap"])
						-- umsg.Long(communityTbl["res"]["Small_Parts"])
						-- umsg.Long(communityTbl["res"]["Chemicals"])
						-- umsg.Short( math.Round((locker.BreakInTimer / 30) * 100) )
					-- umsg.End()
					-- ply:Freeze(false)
					timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
				else
					locker:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		else
			ply:ChatPrint("You cannot repair it while someone is breaking in!")
		end
	elseif locker.Repairing == ply then
		umsg.Start("locker_stoprepair", ply)
		umsg.End()
	else
		ply:ChatPrint("Someone is already repairing this locker.")
	end
end
datastream.Hook( "locker_repair", LockerRepair )

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end
