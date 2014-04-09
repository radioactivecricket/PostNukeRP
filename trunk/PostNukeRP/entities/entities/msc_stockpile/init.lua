AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props/cs_office/crates_indoor.mdl")
util.AddNetworkString("stockpile_breakin")
util.AddNetworkString("stockpile_stoprepair")
util.AddNetworkString("stockpile_menu")
util.AddNetworkString("stockpile_stopbreakin")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/crates_indoor.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.Community = self.Entity:GetNWString("community_owner")
	self.CommunityName = self.Entity:GetNWString("communityName")
	self.Enabled = false
	self.BreakInTimer = 30
	self.BreakingIn = nil
	self.Repairing = nil
	
	self.Entity:SetRenderMode( 1 )
	self.Entity:SetColor(Color(200, 200, 200, 50))
--	self.Entity:SetKeyValue( "renderfx", 16 )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.Entity:GetPhysicsObject():EnableMotion(true)
	
	local position = self.Entity:GetPos()
	
	timer.Simple(10, function()
		self.Entity:SetColor(Color(200, 200, 200, 255))
--		self.Entity:SetKeyValue( "renderfx", 0 )
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
				net.Start("stockpile_stoprepair")
				net.Send(activator)
			end
			if activator.Community == self.Community then
				local communityTbl = GetCommunityTbl(self.Community)
				if communityTbl == nil then return end
				
				net.Start("stockpile_menu")
					net.WriteEntity(self)
					net.WriteDouble(communityTbl["res"]["Scrap"])
					net.WriteDouble(communityTbl["res"]["Small_Parts"])
					net.WriteDouble(communityTbl["res"]["Chemicals"])
					net.WriteDouble( math.Round((self.BreakInTimer / 30) * 100) )
				net.Send(activator)
			else
				-- Just a placeholder for breaking into these things.
				activator:ActOfWar( self.Community )
				net.Start("stockpile_breakin")
					net.WriteEntity(self)
					net.WriteDouble(self.BreakInTimer)
				net.Send(activator)
			end
		end
	end
end

function TakeRes( )
	local GM = GAMEMODE
	local ply = net.ReadEntity()
	local stockpile = net.ReadEntity()

	if not stockpile then return end
	
	local Scrap = math.Round(net.ReadDouble())
	local Small = math.Round(net.ReadDouble())
	local Chems = math.Round(net.ReadDouble())
	
	local communityTbl = GetCommunityTbl(stockpile.Community)
	
	local TotalScrap = communityTbl["res"]["Scrap"]
	local TotalSmall = communityTbl["res"]["Small_Parts"]
	local TotalChems = communityTbl["res"]["Chemicals"]
	
	if Scrap > TotalScrap then Scrap = TotalScrap end
	if Small > TotalSmall then Small = TotalSmall end
	if Chems > TotalChems then Chems = TotalChems end
	
	if Scrap < 0 then Scrap = 0 end
	if Small < 0 then Small = 0 end
	if Chems < 0 then Chems = 0 end
	
	if Scrap > 0 then
		SubCommunityRes( stockpile.Community, "Scrap", Scrap )
		ply:IncResource( "Scrap", Scrap )
		ply:ChatPrint("You have taken "..tostring(Scrap).." scrap from the stockpile.")
	end
	if Small > 0 then
		SubCommunityRes( stockpile.Community, "Small_Parts", Small )
		ply:IncResource( "Small_Parts", Small )
		ply:ChatPrint("You have taken "..tostring(Small).." small parts from the stockpile.")
	end
	if Chems > 0 then
		SubCommunityRes( stockpile.Community, "Chemicals", Chems )
		ply:IncResource( "Chemicals", Chems )
		ply:ChatPrint("You have taken "..tostring(Chems).." chemicals from the stockpile.")
	end
	
	GM.SaveCharacter(ply)
end
net.Receive( "stockpile_take", TakeRes )

function PutRes( )
	local GM = GAMEMODE
	local ply = net.ReadEntity()
	local stockpile = net.ReadEntity()

	if not stockpile then return end
	local Scrap = math.Round(net.ReadDouble())
	local Small = math.Round(net.ReadDouble())
	local Chems = math.Round(net.ReadDouble())
	
	local TotalScrap = ply:GetResource( "Scrap" )
	local TotalSmall = ply:GetResource( "Small_Parts" )
	local TotalChems = ply:GetResource( "Chemicals" )
	
	if Scrap > TotalScrap then Scrap = TotalScrap end
	if Small > TotalSmall then Small = TotalSmall end
	if Chems > TotalChems then Chems = TotalChems end
	
	if Scrap < 0 then Scrap = 0 end
	if Small < 0 then Small = 0 end
	if Chems < 0 then Chems = 0 end
	
	if Scrap > 0 then
		AddCommunityRes( stockpile.Community, "Scrap", Scrap )
		ply:DecResource( "Scrap", Scrap )
		ply:ChatPrint("You have put "..tostring(Scrap).." scrap into the stockpile.")
	end
	if Small > 0 then
		AddCommunityRes( stockpile.Community, "Small_Parts", Small )
		ply:DecResource( "Small_Parts", Small )
		ply:ChatPrint("You have put "..tostring(Small).." small parts into the stockpile.")
	end
	if Chems > 0 then
		AddCommunityRes( stockpile.Community, "Chemicals", Chems )
		ply:DecResource( "Chemicals", Chems )
		ply:ChatPrint("You have put "..tostring(Chems).." chemicals into the stockpile.")
	end
	
	GM.SaveCharacter(ply)
end
net.Receive( "stockpile_put", PutRes )

function StockBreakIn( )
	local ply = net.ReadEntity()
	local stockpile = net.ReadEntity()
	--local stockpile = decoded["stockpile"]
	if not stockpile then 
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		return 
	end
	
	if stockpile.Repairing then
		ply:ChatPrint("You can't break in while someone's repairing this stockpile!")
		net.Start("stockpile_stoprepair")
		net.Send(ply)
		return
	end
	
	if not stockpile.BreakingIn then
		if stockpile.BreakInTimer <= 0 then
			net.Start("stockpile_stopbreakin")
			net.Send(ply)
			net.Start("stockpile_menu")
				local communityTbl = GetCommunityTbl(stockpile.Community)
				net.WriteEntity(stockpile)
				net.WriteDouble(communityTbl["res"]["Scrap"])
				net.WriteDouble(communityTbl["res"]["Small_Parts"])
				net.WriteDouble(communityTbl["res"]["Chemicals"])
				net.WriteDouble( math.Round((stockpile.BreakInTimer / 30) * 100) )
			net.Send(ply)
		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			stockpile.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(stockpile:EntIndex()), 1, stockpile.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not stockpile:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("stockpile_stopbreakin")
					net.Send(ply)
					if stockpile:IsValid() then 
						stockpile.BreakingIn = nil 
						timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
					end
					return
				end
				stockpile.BreakInTimer = stockpile.BreakInTimer - 1
				if stockpile.BreakInTimer <= 0 then
					net.Start("stockpile_stopbreakin")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					stockpile.BreakingIn = nil
					
					local communityTbl = GetCommunityTbl(stockpile.Community)
					if communityTbl == nil then return end
					
					net.Start("stockpile_menu")
						net.WriteEntity(stockpile)
						net.WriteDouble(communityTbl["res"]["Scrap"])
						net.WriteDouble(communityTbl["res"]["Small_Parts"])
						net.WriteDouble(communityTbl["res"]["Chemicals"])
						net.WriteDouble( math.Round((stockpile.BreakInTimer / 30) * 100) )
					net.Send(ply)
					-- ply:Freeze(false)
					stockpile:EmitSound("physics/wood/wood_box_break2.wav",100,100)
					timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
				else
					stockpile:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		end
	elseif ply == stockpile.BreakingIn then
		timer.Destroy(ply:UniqueID()..tostring(stockpile:EntIndex()))
		net.Start("stockpile_stopbreakin")
		net.Send(ply)
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		if stockpile:IsValid() then
			stockpile.BreakingIn = nil
		end
	else
		ply:ChatPrint("Someone is already breaking into this stockpile.")
		net.Start("stockpile_stopbreakin")
		net.Send(ply)
	end
end
--datastream.Hook( "stockpile_breakin", StockBreakIn )
net.Receive( "stockpile_breakin", StockBreakIn )

function StockRepair( )
	local ply = net.ReadEntity()
	local stockpile = net.ReadEntity()
	--local stockpile = decoded["stockpile"]
	if stockpile.BreakInTimer >= 30 then
		ply:ChatPrint("This stockpile is fully repaired!")
		return
	end
	if not stockpile.Repairing then
		if not stockpile.BreakingIn then
			net.Start("stockpile_repair")
				net.WriteEntity(stockpile)
				net.WriteDouble(stockpile.BreakInTimer)
			net.Send(ply)
			
			ply:SetMoveType(MOVETYPE_NONE)
			stockpile.Repairing = ply
			timer.Create( ply:UniqueID()..tostring(stockpile:EntIndex()), 1, stockpile.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not stockpile:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					net.Start("stockpile_stoprepair")
					net.Send(ply)
					if stockpile:IsValid() then 
						stockpile.Repairing = nil
						timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
					end
					return
				end
				stockpile.BreakInTimer = stockpile.BreakInTimer + 1
				if stockpile.BreakInTimer >= 30 then
					net.Start("stockpile_stoprepair")
					net.Send(ply)
					
					ply:SetMoveType(MOVETYPE_WALK)
					stockpile.Repairing = nil
					stockpile.BreakInTimer = 30
					
					local communityTbl = GetCommunityTbl(stockpile.Community)
					if communityTbl == nil then return end
					
					net.Start("stockpile_menu")
						net.WriteEntity(stockpile)
						net.WriteDouble(communityTbl["res"]["Scrap"])
						net.WriteDouble(communityTbl["res"]["Small_Parts"])
						net.WriteDouble(communityTbl["res"]["Chemicals"])
						net.WriteDouble( math.Round((stockpile.BreakInTimer / 30) * 100) )
					net.Send(ply)
					-- ply:Freeze(false)
					timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
				else
					stockpile:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		else
			ply:ChatPrint("You cannot repair it while someone is breaking in!")
			net.Start("stockpile_stoprepair")
			net.Send(ply)
		end
	elseif stockpile.Repairing == ply then
		net.Start("stockpile_stoprepair")
		net.Send(ply)
	else
		ply:ChatPrint("Someone is already repairing this stockpile.")
		net.Start("stockpile_stoprepair")
		net.Send(ply)
	end
end
net.Receive("stockpile_repair", StockRepair )

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end
