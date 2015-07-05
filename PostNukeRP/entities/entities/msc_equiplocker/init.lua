AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props_forest/footlocker01_closed.mdl")

util.AddNetworkString("locker_breakin")
util.AddNetworkString("locker_stopbreakin")

function ENT:Initialize()
	self.Entity:SetModel("models/props_forest/footlocker01_closed.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.Community = self.Entity:GetNetVar("community_owner")
	self.CommunityName = self.Entity:GetNetVar("communityName")
	self.Enabled = false
	self.BreakInTimer = 60
	self.BreakingIn = nil
	self.Repairing = nil
	
	self:SetRenderMode( 1 )
	self.Entity:SetColor(Color(50, 255, 50, 55))
	
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	local position = self.Entity:GetPos()
	
	timer.Simple(10, function()
		self.Entity:SetColor(Color(255, 255, 255, 255))
		self.Entity:SetCollisionGroup(COLLISION_GROUP_NONE)
		self.Entity:GetPhysicsObject():EnableMotion(false)
		self.Entity:SetMoveType(MOVETYPE_NONE) 
		self.Entity:SetNetVar("Owner", "Unownable")
		self.Entity:SetNetVar("Owner_UID", "")
		self.Entity:SetNetVar( "ownerent", self.Entity )

		--self.Entity:SetPos(position)
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
				net.Start("locker_stoprepair")
				net.Send(activator)
			end
			local cid = self:GetNetVar("community_owner", "None")
			if activator.Community == cid then
			--	local communityTbl = GetCommunityTbl(self.Community)
				local communityTbl = getFullLockerInventory(cid)
				if communityTbl == nil then return end
				net.Start("locker_menu")
					net.WriteEntity(activator)
					net.WriteEntity(self)
					net.WriteString(cid)
					net.WriteDouble(math.Round((self.BreakInTimer / 60) * 100))
					net.WriteTable(communityTbl)
					net.WriteTable(PNRP.GetFullInventory( activator ) or {})
				net.Send(activator)
				
			else
				-- Just a placeholder for breaking into these things.
				activator:ActOfWar( cid )
				net.Start("locker_breakin")
					net.WriteEntity(self)
					net.WriteDouble(self.BreakInTimer)
				net.Send(activator)
			end
		end
	end
end
util.AddNetworkString( "locker_menu" )
util.AddNetworkString("locker_stoprepair")
util.AddNetworkString("locker_breakin")

function getFullLockerInventory(cid)
	local communityTbl = GetCommunityTbl(cid)
	
	if not communityTbl then return nil end

	local invTbl = {}
	for item, have in pairs( communityTbl["inv"] ) do
		have = math.Round(tonumber(have) or 0)
		if have > 0 and itemid != "" then
			table.insert( invTbl, {itemid=item, status_table="", iid="", count=have} )
		end
	end
	
	local Inv2 = PNRP.PersistOtherInventory( "community", cid )

	for k, v in pairs(Inv2) do
		table.insert( invTbl, {itemid=v["itemid"], status_table=v["status_table"], iid=v["iid"], count=1} )
	end

	return invTbl
end

function TakeItems( )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local Item = net.ReadString()
	local Amount =  math.Round(net.ReadDouble())
	local iid = net.ReadString()
	
	if not locker then return end
	local cid = locker:GetNetVar("community_owner", "None")
	local communityTbl = GetCommunityTbl(cid)
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = getServerSetting("packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = getServerSetting("packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight

	if iid == nil or iid == "" then
		if weightCalc <= weightCap then
			ply:AddToInventory( Item, Amount )
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			
			SubCommunityItem( cid, Item, Amount )
		else
			local weightDiff = weightCalc - weightCap
			local extra = math.ceil(weightDiff/weight)
			
			if extra >= Amount then
				ply:ChatPrint("You can't carry any of these!")
			else
				local taken = Amount - extra
				
				ply:AddToInventory( Item, taken )
				SubCommunityItem( cid, Item, taken )
				ply:EmitSound(Sound("items/ammo_pickup.wav"))
				ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
			end
		end
	else
		if weightCalc <= weightCap then
			PNRP.PersistMoveTo( ply, iid, "player")			
		else
			ply:ChatPrint("Unable to take item from storage.")
		end		
	end
end
net.Receive( "locker_take", TakeItems )

function PutItems( ply, handler, id, encoded, decoded )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local Item = net.ReadString()
	local Amount = math.Round(tonumber(net.ReadString()))
	--local locker = decoded["locker"]
	if not locker then return end
	
	local cid = locker:GetNetVar("community_owner", "None")
	
	local Check = PNRP.TakeFromInventoryBulk( ply, Item, Amount )
	if Check then
		AddCommunityItem( cid, Item, Amount )
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
	else
		ply:ChatPrint("You do not have enough of this")
	end
end
--datastream.Hook( "locker_put", PutItems )
net.Receive( "locker_put", PutItems )

function LockerBreakIn( ply, handler, id, encoded, decoded )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	--local locker = decoded["locker"]
	if not locker then 
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		return 
	end
	
	if locker.Repairing then
		ply:ChatPrint("You can't break in while someone's repairing this locker!")
		net.Start("locker_stopbreakin")
		net.Send(ply)
		return
	end
	
	if not locker.BreakingIn then
		if locker.BreakInTimer <= 0 then
			net.Start("locker_stopbreakin")
			net.Send(ply)
			
			local playerTbl = PNRP.GetFullInventory( ply ) or {}
			
			local cid = locker:GetNetVar("community_owner", "None")
			
			local communityTbl = getFullLockerInventory(cid)
			if communityTbl == nil then return end
			
			net.Start("locker_menu")
				net.WriteEntity(ply)
				net.WriteEntity(locker)
				net.WriteString(cid)
				net.WriteDouble(math.Round((locker.BreakInTimer / 30) * 100))
				net.WriteTable(communityTbl)
				net.WriteTable(playerTbl)
			net.Send(ply)

		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			locker.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(locker:EntIndex()), 1, locker.BreakInTimer, function()
				ply:SelectWeapon("weapon_simplekeys")
				if (not locker:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("locker_stopbreakin")
					net.Send(ply)
					if locker:IsValid() then 
						locker.BreakingIn = nil 
						timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
					end
					return
				end
				locker.BreakInTimer = locker.BreakInTimer - 1
				if locker.BreakInTimer <= 0 then
					net.Start("locker_stopbreakin")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					locker.BreakingIn = nil
					
					local communityTbl = GetCommunityTbl(cid)
					if communityTbl == nil then return end
					
				--	local playerTbl = { }
				--	local ILoc = PNRP.GetInventoryLocation( ply ) or { }
				--	if file.Exists( ILoc ) then 
				--		playerTbl = util.KeyValuesToTable(file.Read(ILoc))
				--	end
					
					local playerTbl = PNRP.Inventory( ply ) or {}
					
					--datastream.StreamToClients( ply, "locker_menu",{ ["locker"] = locker, ["health"] = math.Round((locker.BreakInTimer / 60) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
					net.Start("locker_menu")
						net.WriteEntity(ply)
						net.WriteEntity(locker)
						net.WriteDouble(math.Round((locker.BreakInTimer / 60) * 100))
						net.WriteTable(communityTbl["inv"])
						net.WriteTable(playerTbl)
					net.Send(ply)

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
		net.Start("locker_stopbreakin")
		net.Send(ply)
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		if locker:IsValid() then
			locker.BreakingIn = nil
		end
	else
		ply:ChatPrint("Someone is already breaking into this locker.")
		net.Start("locker_stopbreakin")
		net.Send(ply)
	end
end
--datastream.Hook( "locker_breakin", LockerBreakIn )
net.Receive( "locker_breakin", LockerBreakIn )

function LockerRepair( )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local cid = locker:GetNetVar("community_owner", "None")
	
	if locker.BreakInTimer >= 60 then
		ply:ChatPrint("This locker is fully repaired!")
		return
	end
	if not locker.Repairing then
		if not locker.BreakingIn then
			net.Start("locker_repair")
				net.WriteEntity(locker)
				net.WriteDouble(locker.BreakInTimer)
			net.Send(ply)
			
			ply:SetMoveType(MOVETYPE_NONE)
			locker.Repairing = ply
			locker:SetModel("models/props_forest/footlocker01_closed.mdl")
			timer.Create( ply:UniqueID()..tostring(locker:EntIndex()), 1, locker.BreakInTimer, function()
				ply:SelectWeapon("weapon_simplekeys")
				if (not locker:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("locker_stoprepair")
					net.Send(ply)
					if locker:IsValid() then 
						locker.Repairing = nil 
						timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
					end
					return
				end
				locker.BreakInTimer = locker.BreakInTimer + 1
				if locker.BreakInTimer >= 60 then
					net.Start("locker_stoprepair")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					locker.Repairing = nil
					locker.BreakInTimer = 60
					
					local communityTbl = GetCommunityTbl(cid)
					if communityTbl == nil then return end
					
					local playerTbl = { }
					local ILoc = PNRP.GetInventoryLocation( ply )
					if file.Exists( ILoc ) then 
						playerTbl = util.KeyValuesToTable(file.Read(ILoc))
					end
					
					net.Start("locker_menu")
						net.WriteEntity(ply)
						net.WriteEntity(locker)
						net.WriteDouble(math.Round((locker.BreakInTimer / 60) * 100))
						net.WriteTable(communityTbl["inv"])
						net.WriteTable(playerTbl)
					net.Send(ply)
					-- ply:Freeze(false)
					timer.Stop(ply:UniqueID()..tostring(locker:EntIndex()))
				else
					locker:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		else
			ply:ChatPrint("You cannot repair it while someone is breaking in!")
			net.Start("locker_stoprepair")
			net.Send(ply)
		end
	elseif locker.Repairing == ply then
		net.Start("locker_stoprepair")
		net.Send(ply)
	else
		ply:ChatPrint("Someone is already repairing this locker.")
		net.Start("locker_stoprepair")
		net.Send(ply)
	end
end
util.AddNetworkString("locker_repair")
net.Receive( "locker_repair", LockerRepair )

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNetVar (key, value)
	print ("["..key.." = "..value.."] ")
end
