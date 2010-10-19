AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/props/cs_office/crates_indoor.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/crates_indoor.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	
	self.Community = self.Entity:GetNWString("community_owner")
	self.Enabled = false
	self.BreakInTimer = 30
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
				umsg.Start("stockpile_stoprepair", activator)
				umsg.End()
			end
			if activator.Community == self.Community then
				local communityTbl = GetCommunityTbl(self.Community)
				if communityTbl == nil then return end
				
				umsg.Start("stockpile_menu", activator)
					umsg.Entity(self)
					umsg.Long(communityTbl["res"]["Scrap"])
					umsg.Long(communityTbl["res"]["Small_Parts"])
					umsg.Long(communityTbl["res"]["Chemicals"])
					umsg.Short( math.Round((self.BreakInTimer / 30) * 100) )
				umsg.End()
			else
				-- Just a placeholder for breaking into these things.
				umsg.Start("stockpile_breakin", activator)
					umsg.Entity(self)
					umsg.Short(self.BreakInTimer)
				umsg.End()
			end
		end
	end
end

function TakeRes( ply, handler, id, encoded, decoded )
	local stockpile = decoded["stockpile"]
	if not stockpile then return end
	
	local Scrap = math.Round(decoded["scrap"])
	local Small = math.Round(decoded["small"])
	local Chems = math.Round(decoded["chems"])
	
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
end
datastream.Hook( "stockpile_take", TakeRes )

function PutRes( ply, handler, id, encoded, decoded )
	local stockpile = decoded["stockpile"]
	if not stockpile then return end
	local Scrap = math.Round(decoded["scrap"])
	local Small = math.Round(decoded["small"])
	local Chems = math.Round(decoded["chems"])
	
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
end
datastream.Hook( "stockpile_put", PutRes )

function StockBreakIn( ply, handler, id, encoded, decoded )
	local stockpile = decoded["stockpile"]
	if not stockpile then 
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		return 
	end
	
	if stockpile.Repairing then
		ply:ChatPrint("You can't break in while someone's repairing this stockpile!")
		return
	end
	
	if not stockpile.BreakingIn then
		if stockpile.BreakInTimer <= 0 then
			umsg.Start("stockpile_stopbreakin", ply)
			umsg.End()
			umsg.Start("stockpile_menu", ply)
				local communityTbl = GetCommunityTbl(stockpile.Community)
				umsg.Entity(stockpile)
				umsg.Long(communityTbl["res"]["Scrap"])
				umsg.Long(communityTbl["res"]["Small_Parts"])
				umsg.Long(communityTbl["res"]["Chemicals"])
				umsg.Short( math.Round((stockpile.BreakInTimer / 30) * 100) )
			umsg.End()
		else
			-- ply:Freeze(true)
			ply:SetMoveType(MOVETYPE_NONE)
			stockpile.BreakingIn = ply
			timer.Create( ply:UniqueID()..tostring(stockpile:EntIndex()), 1, stockpile.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not stockpile:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					umsg.Start("stockpile_stopbreakin", ply)
					umsg.End()
					if stockpile:IsValid() then 
						stockpile.BreakingIn = nil 
						timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
					end
					return
				end
				stockpile.BreakInTimer = stockpile.BreakInTimer - 1
				if stockpile.BreakInTimer <= 0 then
					umsg.Start("stockpile_stopbreakin", ply)
					umsg.End()
					
					ply:SetMoveType(MOVETYPE_WALK)
					stockpile.BreakingIn = nil
					
					local communityTbl = GetCommunityTbl(stockpile.Community)
					if communityTbl == nil then return end
					
					umsg.Start("stockpile_menu", ply)
						umsg.Entity(stockpile)
						umsg.Long(communityTbl["res"]["Scrap"])
						umsg.Long(communityTbl["res"]["Small_Parts"])
						umsg.Long(communityTbl["res"]["Chemicals"])
						umsg.Short( math.Round((stockpile.BreakInTimer / 30) * 100) )
					umsg.End()
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
		umsg.Start("stockpile_stopbreakin", ply)
		umsg.End()
		-- ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)
		if stockpile:IsValid() then
			stockpile.BreakingIn = nil
		end
	else
		ply:ChatPrint("Someone is already breaking into this stockpile.")
	end
end
datastream.Hook( "stockpile_breakin", StockBreakIn )

function StockRepair( ply, handler, id, encoded, decoded )
	local stockpile = decoded["stockpile"]
	if stockpile.BreakInTimer >= 30 then
		ply:ChatPrint("This stockpile is fully repaired!")
		return
	end
	if not stockpile.Repairing then
		if not stockpile.BreakingIn then
			umsg.Start("stockpile_repair", ply)
				umsg.Entity(stockpile)
				umsg.Short(stockpile.BreakInTimer)
			umsg.End()
			
			ply:SetMoveType(MOVETYPE_NONE)
			stockpile.Repairing = ply
			timer.Create( ply:UniqueID()..tostring(stockpile:EntIndex()), 1, stockpile.BreakInTimer, function()
				ply:SelectWeapon("gmod_rp_hands")
				if (not stockpile:IsValid()) or (not ply:Alive()) then
					-- ply:Freeze(false)
					ply:SetMoveType(MOVETYPE_WALK)
					umsg.Start("stockpile_stoprepair", ply)
					umsg.End()
					if stockpile:IsValid() then 
						stockpile.Repairing = nil
						timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
					end
					return
				end
				stockpile.BreakInTimer = stockpile.BreakInTimer + 1
				if stockpile.BreakInTimer >= 30 then
					umsg.Start("stockpile_stoprepair", ply)
					umsg.End()
					
					ply:SetMoveType(MOVETYPE_WALK)
					stockpile.Repairing = nil
					stockpile.BreakInTimer = 30
					
					local communityTbl = GetCommunityTbl(stockpile.Community)
					if communityTbl == nil then return end
					
					umsg.Start("stockpile_menu", ply)
						umsg.Entity(stockpile)
						umsg.Long(communityTbl["res"]["Scrap"])
						umsg.Long(communityTbl["res"]["Small_Parts"])
						umsg.Long(communityTbl["res"]["Chemicals"])
						umsg.Short( math.Round((stockpile.BreakInTimer / 30) * 100) )
					umsg.End()
					-- ply:Freeze(false)
					timer.Stop(ply:UniqueID()..tostring(stockpile:EntIndex()))
				else
					stockpile:EmitSound("ambient/materials/wood_creak"..tostring(math.random(1,6))..".wav",100,100)
				end
			end )
		else
			ply:ChatPrint("You cannot repair it while someone is breaking in!")
		end
	elseif stockpile.Repairing == ply then
		umsg.Start("stockpile_stoprepair", ply)
		umsg.End()
	else
		ply:ChatPrint("Someone is already repairing this stockpile.")
	end
end
datastream.Hook( "stockpile_repair", StockRepair )

function ENT:KeyValue (key, value)
	self[key] = tonumber(value) or value
	self.Entity:SetNWString (key, value)
	print ("["..key.." = "..value.."] ")
end
