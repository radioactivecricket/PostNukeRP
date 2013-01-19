AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.AddNetworkString("addfilter_stream")
util.AddNetworkString("fertilize_stream")
util.AddNetworkString("addairator_stream")
util.AddNetworkString("prune_stream")

util.PrecacheModel ("models/props/cs_office/plant01.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/plant01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
	
	self.FruitLevel = 0
	self.PlantStatus = 60
	self.Filtered = nil
	self.Fertilized = false
	self.Airator = nil
	self.CanPrune = true
	self.LastUser = nil
	timer.Create( "plantupdate_"..tostring(self), 120, 0, function()
		self:PlantUpdate()
	end)
	
	self.Entity:NextThink(CurTime() + 1.0)
end

function ENT:PlantUpdate()
	local statusChange = -10
	
	if self.PlantStatus > 75 and self.FruitLevel < 3 then
		-- ent.FruitLevel = ent.FruitLevel + 1
		local fruitent = ents.Create("food_orange")
		fruitent:SetModel("models/props/cs_italy/orange.mdl")
		fruitent:SetAngles(Angle(0,0,0))
		fruitent:SetPos(self:LocalToWorld(Vector(0,0,20)))
		fruitent:Spawn()
	end
	
	local MySkill = 0
	
	if self.LastUser:IsValid() and self.LastUser:Team() == TEAM_CULTIVATOR then
		MySkill = self.LastUser:GetSkill("Farming")
	end
	
	if MySkill > 0 then statusChange = statusChange + MySkill end
	
	if IsValid(self.Filtered) then
		statusChange = statusChange + 3
	end
	
	if self.Fertilized then
		statusChange = statusChange + 3
	end
	
	if IsValid(self.Airator) then
		statusChange = statusChange + 3
	end
	
	self.PlantStatus = self.PlantStatus + statusChange
	if self.PlantStatus < 0 then self.PlantStatus = 0 end
	if self.PlantStatus > 100 then self.PlantStatus = 100 end
end

function DoFilter( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if IsValid(ent.Filtered) then
		constraint.RemoveConstraints( ent.Filtered, "Weld" )
		
		ent.Filtered:GetPhysicsObject():EnableMotion(true)
		ent.Filtered:GetPhysicsObject():Wake()
		ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
		
		ent.Filtered.Attached = false
		
		ent.Filtered = nil
		ply:ChatPrint("You've unhooked the water purifier.")
	else
		local nearbyEnts = ents.FindInSphere(ent:GetPos(), 150)
		
		local filter
		local dist = 500
		
		for k, v in pairs(nearbyEnts) do
			if v:GetClass() == "tool_waterpurifier" and !v.Attached and (not IsValid(v.NetworkContainer)) then
				if ent:GetPos():Distance(v:GetPos()) < dist and ply == v:GetNWEntity( "ownerent" ) then
					filter = v
					dist = ent:GetPos():Distance(v:GetPos())
				end
			end
		end
		
		if IsValid(filter) then
			ent.Filtered = filter
			
			filter.Attached = true
			
			filter:SetPos(util.LocalToWorld( ent, Vector(4, 2, 17)))
			
			filter:SetAngles(Angle(ent:GetAngles().Roll, ent:GetAngles().Pitch, ent:GetAngles().Yaw )+Angle(90,0,0))
			ply:ChatPrint("Ent:GetAngles():  "..tostring(ent:GetAngles()))
			
			constraint.Weld(ent, filter, 0, 0, 0, true)
			
			ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			ply:ChatPrint("You've hooked up the water purifier.")
		else
			ply:ChatPrint("No nearby owned water purifier.")
		end
	end
end
--datastream.Hook( "addfilter_stream", DoFilter )
net.Receive( "addfilter_stream", DoFilter )

function DoFertilize( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	--local ent = decoded[1]
	
	if ply:GetResource( "Chemicals" ) < 5 then
		ply:ChatPrint( "Not enough chemicals to fertilize!" )
		return
	end
	
	ply:Freeze(true)
	ply:ChatPrint("Fertilizing...")
	
	timer.Simple( 5, function ()
		ply:Freeze(false)
		ply:DecResource( "Chemicals", 5 )
		
		ent.Fertilized = true
		timer.Create( "unfertilize_"..tostring(ent:EntIndex()), 600, 1, function()
			ent.Fertilized = false
		end )
		ply:ChatPrint("Fertilized!")
	end )
end
--datastream.Hook( "fertilize_stream", DoFertilize )
net.Receive( "fertilize_stream", DoFertilize )

function DoAirator( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if IsValid(ent.Airator) then
		constraint.RemoveConstraints( ent.Airator, "Weld" )
		
		ent.Airator:GetPhysicsObject():EnableMotion(true)
		ent.Airator:GetPhysicsObject():Wake()
		ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
		
		ent.Airator.Attached = false
		
		ent.Airator = nil
		ply:ChatPrint("You've unhooked the airator.")
	else
		local nearbyEnts = ents.FindInSphere(ent:GetPos(), 150)
		
		local airator
		local dist = 500
		
		for k, v in pairs(nearbyEnts) do
			if v:GetClass() == "tool_airator" and !v.Attached and (not IsValid(v.NetworkContainer)) then
				if ent:GetPos():Distance(v:GetPos()) < dist and ply == v:GetNWEntity( "ownerent" ) then
					airator = v
					dist = ent:GetPos():Distance(v:GetPos())
				end
			end
		end
		
		if IsValid(airator) then
			ent.Airator = airator
			
			airator.Attached = true
			
			airator:SetPos(util.LocalToWorld( ent, Vector(0, 5, 17)))
			airator:SetAngles(ent:GetAngles()+Angle(0,0,180))
			
			constraint.Weld(ent, airator, 0, 0, 0, true)
			
			ent:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			ply:ChatPrint("You've hooked the airator.")
		else
			ply:ChatPrint("No nearby owned airator.")
		end
	end	
end
--datastream.Hook( "addairator_stream", DoAirator )
net.Receive( "addairator_stream", DoAirator )
	
function DoPrune( )
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	ply:SelectWeapon("gmod_rp_hands")
	ply:SetMoveType(MOVETYPE_NONE)
	ent.Pruning = ply
	ent.CanPrune = false
	
	net.Start("startProgressBar")
		net.WriteDouble((100 - ent.PlantStatus)/2)
	net.Send(ply)
	
	timer.Create( ply:UniqueID().."_prune_"..tostring(ent), 0.25, ((100 - ent.PlantStatus)*4)/2, function()
		ply:SelectWeapon("gmod_rp_hands")
		if (not ent:IsValid()) or (not ply:Alive()) then
			ply:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(ply)
			ent.Pruning = nil
			if ent:IsValid() then 
				timer.Stop(ply:UniqueID().."_prune_"..tostring(ent))
			end
			return
		end
	end )
end
--datastream.Hook( "prune_stream", DoPrune )
net.Receive( "prune_stream", DoPrune )

function ENT:OnRemove()
	timer.Destroy( "plantupdate_"..tostring(self) )
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		if activator:IsAdmin() and GetConVarNumber("pnrp_adminTouchAll") == 1 then
			if activator:Team() ~= TEAM_CULTIVATOR then
				activator:ChatPrint("Admin overide.")
			end
		else
			if activator:Team() ~= TEAM_CULTIVATOR then
				activator:ChatPrint("You don't have any idea how to take care of this plant.")
				return
			end
		end
		
		if self.Pruning then
			if self.Pruning == activator then
				self.Pruning = nil
				activator:ChatPrint("You stop pruning the plant.")
				
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				self.Pruning = nil
				self.CanPrune = true
				if self:IsValid() then 
					timer.Stop(activator:UniqueID().."_prune_"..tostring(self))
				end
			else
				activator:ChatPrint("This plant is currently being pruned.")
			end
		else
			self.LastUser = activator
			 
			net.Start("plant_menu")
				net.WriteDouble(self.FruitLevel)
				net.WriteDouble(self.PlantStatus)
				net.WriteBit(IsValid(self.Filtered))
				net.WriteBit(self.Fertilized)
				net.WriteBit(IsValid(self.Airator))
				net.WriteBit(self.CanPrune)
				net.WriteEntity(self.Entity)
			net.Send(activator)
		end
	end
end
util.AddNetworkString("plant_menu")

function ENT:Think()
	if self.Pruning then
		self.PlantStatus = self.PlantStatus + 2
		
		if self.PlantStatus >= 100 then
			self.PlantStatus = 100
			self.Pruning:ChatPrint("You finish pruning the plant.")
			
			self.Pruning:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(self.Pruning)
			if self:IsValid() and IsValid(self.Pruning) then 
				timer.Stop(self.Pruning:UniqueID().."_prune_"..tostring(self))
			end
			self.Pruning = nil
			self.CanPrune = true
		end
	end
	
	if IsValid(self.Airator) then
		local AirCheck = false
		
		local findPlantHost = constraint.FindConstraints( self.Airator, "Weld" )
		for _, v in pairs(findPlantHost) do
			if v.Entity[1].Entity == self then
				AirCheck = true
			end
		end
		
		if not AirCheck then
			self.Airator:SetPos(util.LocalToWorld( self, Vector(0, 5, 17)))
			self.Airator:SetAngles(self:GetAngles()+Angle(0,0,180))
			
			constraint.Weld(self, self.Airator, 0, 0, 0, true)
				
			self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			
			AirCheck = true
		end
	end
	
	if IsValid(self.Filtered) then
		local FilterCheck = false
		
		local findPlantHost = constraint.FindConstraints( self.Filtered, "Weld" )
		for _, v in pairs(findPlantHost) do
			if v.Entity[1].Entity == self then
				FilterCheck = true
			end
		end
		
		if not FilterCheck then
			self.Filtered:SetPos(util.LocalToWorld( self, Vector(4, 2, 17)))
			self.Filtered:SetAngles(self:GetAngles()+Angle(90,0,0))
			
			constraint.Weld(self, self.Filtered, 0, 0, 0, true)
				
			self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
			
			FilterCheck = true
		end
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
