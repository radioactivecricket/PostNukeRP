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
	
	self.Community = self.Entity:GetNWString("community_owner")
	self.CommunityName = self.Entity:GetNWString("communityName")
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
		self.Entity:SetNWString("Owner", "Unownable")
		self.Entity:SetNWString("Owner_UID", "")
		self.Entity:SetNWEntity( "ownerent", self.Entity )

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
			if activator.Community == self.Community then
				local communityTbl = GetCommunityTbl(self.Community)
				if communityTbl == nil then return end
				net.Start("locker_menu")
					net.WriteEntity(activator)
					net.WriteEntity(self)
					net.WriteDouble(math.Round((self.BreakInTimer / 60) * 100))
					net.WriteTable(communityTbl["inv"])
					net.WriteTable(PNRP.Inventory( activator ) or {})
				net.Send(activator)
				
			else
				print(tostring(self.Community))
				-- Just a placeholder for breaking into these things.
				activator:ActOfWar( self.Community )
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

function TakeItems( )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local Item = net.ReadString()
	local Amount =  math.Round(net.ReadDouble())
	--local locker = decoded["locker"]
	if not locker then return end
	--local Item = decoded["item"]
	--local Amount = math.Round(decoded["amount"])
	
	local communityTbl = GetCommunityTbl(locker.Community)
	
	if Amount <= 0 or (not Amount) then return end
	if Amount > communityTbl["inv"][Item] then Amount = communityTbl["inv"][Item] end
	if Amount <= 0 or (not Amount) then return end
	
	local weight = PNRP.Items[Item].Weight
	if PNRP.Items[Item].Type == "vehicle" then weight = 0 end
	local sumWeight = weight*Amount
	
	local weightCap
	if team.GetName(ply:Team()) == "Scavenger" then
		weightCap = GetConVarNumber("pnrp_packCapScav") + (ply:GetSkill("Backpacking")*10)
	else
		weightCap = GetConVarNumber("pnrp_packCap") + (ply:GetSkill("Backpacking")*10)
	end
	
	local weightCalc = PNRP.InventoryWeight( ply ) + sumWeight
	if weightCalc <= weightCap then
		ply:AddToInventory( Item, Amount )
		ply:EmitSound(Sound("items/ammo_pickup.wav"))
		
		SubCommunityItem( locker.Community, Item, Amount )
	else
		local weightDiff = weightCalc - weightCap
		local extra = math.ceil(weightDiff/weight)
		
		if extra >= Amount then
			ply:ChatPrint("You can't carry any of these!")
		else
			local taken = Amount - extra
			
			ply:AddToInventory( Item, taken )
			SubCommunityItem( locker.Community, Item, taken )
			ply:EmitSound(Sound("items/ammo_pickup.wav"))
			ply:ChatPrint("You were only able to carry "..tostring(taken).." of these!")
		end
	end
end
--datastream.Hook( "locker_take", TakeItems )
net.Receive( "locker_take", TakeItems )

function PutItems( ply, handler, id, encoded, decoded )
	local ply = net.ReadEntity()
	local locker = net.ReadEntity()
	local Item = net.ReadString()
	local Amount = math.Round(tonumber(net.ReadString()))
	--local locker = decoded["locker"]
	if not locker then return end
	
	--local Item = decoded["item"]
	--local Amount = math.Round(decoded["amount"])
	
	local Check = PNRP.TakeFromInventoryBulk( ply, Item, Amount )
	if Check then
		AddCommunityItem( locker.Community, Item, Amount )
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
			
--			local playerTbl = { }
--			local ILoc = PNRP.GetInventoryLocation( ply ) or { }
--			if file.Exists( ILoc ) then 
--				playerTbl = util.KeyValuesToTable(file.Read(ILoc))
--			end
			
			local playerTbl = PNRP.Inventory( ply ) or {}
			
			local communityTbl = GetCommunityTbl(locker.Community)
			--datastream.StreamToClients( ply, "locker_menu",{ ["locker"] = locker, ["health"] = math.Round((locker.BreakInTimer / 30) * 100), ["items"] = communityTbl["inv"], ["inventory"] = playerTbl } )
			net.Start("locker_menu")
				net.WriteEntity(ply)
				net.WriteEntity(locker)
				net.WriteDouble(math.Round((locker.BreakInTimer / 30) * 100))
				net.WriteTable(communityTbl["inv"])
				net.WriteTable(playerTbl)
			net.Send(ply)

		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			locker.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(locker:EntIndex()), 1, locker.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
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
					
					local communityTbl = GetCommunityTbl(locker.Community)
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
	--local locker = decoded["locker"]
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
				ply:SelectWeapon("gmod_rp_hands")
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
					
					local communityTbl = GetCommunityTbl(locker.Community)
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
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end
