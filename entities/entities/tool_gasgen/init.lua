AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("loadgasgen_stream")
util.AddNetworkString("unloadgasgen_stream")
util.AddNetworkString("togglegasgen_stream")
util.AddNetworkString("repgasgen_stream")

util.PrecacheModel ("models/props_mining/diesel_generator.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_mining/diesel_generator.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	
	self.Status = false
	self.PowerLevel = 0
	self.FuelLevel = 0
	self.PowerItem = true
	self.PowerGenerator = true
	self.entOwner = "none"
	
	self.UnitLeft = 0
	
	self.genSound = CreateSound( self, "ambient/machines/diesel_engine_idle1.wav" )
	
	-- This var will store the Entity that controls the power network information.
	self.NetworkContainer = nil
	
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.Entity:NextThink(CurTime() + 1.0)
end

function ENT:Use( activator, caller )
	if activator:KeyPressed( IN_USE ) then
		if self.Repairing then
			if self.Repairing == activator then
				self.Repairing = nil
				activator:ChatPrint("You stop repairing the generator.")
				
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				self.Repairing = nil
				if self:IsValid() then 
					timer.Stop(activator:UniqueID().."_repair_"..tostring(self))
				end
			else
				activator:ChatPrint("This generator is currently being repaired.")
			end
		else
			if activator:IsAdmin() and getServerSetting("adminCreateAll") == 1 then
				
			end
			
			if self.entOwner == "none" then
				self.entOwner = activator:Nick()
			end
			
			local actInv = PNRP.Inventory( activator )
			local availFuel = actInv["fuel_gas"]
		
			net.Start("gasgen_menu")
				net.WriteDouble(self:Health())
				if self.NetworkContainer then
					net.WriteDouble(self.NetworkContainer.NetPower or self.PowerLevel)
				else
					net.WriteDouble(self.PowerLevel)
				end

				net.WriteDouble(self.FuelLevel)
				net.WriteDouble(self.UnitLeft or 0)
				net.WriteDouble(availFuel or 0)
				net.WriteBit(self.Status)
				net.WriteBit(false)
				net.WriteEntity(self.Entity)
				net.WriteEntity(activator)
			net.Send(activator)
		end
	end
end
util.AddNetworkString("gasgen_menu")

function ENT:OnTakeDamage(dmg)
	self:SetHealth(self:Health() - dmg:GetDamage())
--	if self:Health() < 200 then self.BlockF2 = true end
	if self:Health() <= 0 then --run on death
		self:SetHealth( 0 )
		
		if self.Status then
			self:TogglePower()
		end
	end
	
	PNRP.SaveState(nil, self, "world")
end 

function ENT:TogglePower()
	if not self.Status then
		self.Status = true
		self.PowerLevel = 250
		
		self:GetPhysicsObject():EnableMotion(false)
		self.moveActive = false
		if self.NetworkContainer then
			self.NetworkContainer:UpdatePower()
		else
			self:UpdatePower()
		end
		self.genSound:Play()
	elseif self.Status then
		self.Status = false
		self.PowerLevel = 0
		
		self.moveActive = true
		if self.NetworkContainer then
			self.NetworkContainer:UpdatePower()
		else
			self:UpdatePower()
		end
		self.genSound:Stop()
	end
end

function ENT.TogglePowerNet()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if not ent.Status then
		ply:ChatPrint("You switch the power on.")
	elseif ent.Status then
		ply:ChatPrint("You switch the power off.")
	end
	
	ent:TogglePower()
end
net.Receive( "togglegasgen_stream", ENT.TogglePowerNet )

function ENT.Repair()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	ply:SelectWeapon("weapon_simplekeys")
	ply:SetMoveType(MOVETYPE_NONE)
	ent.Repairing = ply
	
	net.Start("startProgressBar")
		net.WriteDouble(200 - ent:Health())
	net.Send(ply)
	
	timer.Create( ply:UniqueID().."_repair_"..tostring(ent), 0.25, ((200 - ent:Health())*4)/2, function()
		ply:SelectWeapon("weapon_simplekeys")
		if (not ent:IsValid()) or (not ply:Alive()) then
			ply:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Sned(ply)
			ent.Repairing = nil
			if ent:IsValid() then 
				timer.Stop(ply:UniqueID().."_repair_"..tostring(ent))
				PNRP.SaveState(nil, ent, "world")
			end
			return
		end
	end )
end
net.Receive( "repgasgen_stream", ENT.Repair )

function ENT.AddFuel()
	local amnt = net.ReadDouble()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	local plyInv = PNRP.Inventory( ply )
	local avail = plyInv["fuel_gas"]
	
	if amnt == nil or amnt == "" then amnt = 0 end
	if avail == nil or avail == "" then avail = 0 end
	
	if amnt > avail then
		ply:ChatPrint("You don't have that much fuel.")
		return
	end
	
	ent.FuelLevel = ent.FuelLevel + amnt
	PNRP.TakeFromInventoryBulk(ply, "fuel_gas", amnt)
	
	PNRP.SaveState(nil, ent, "world")
	ply:ChatPrint("You have added "..tostring(amnt).." units of fuel.")
end
net.Receive( "loadgasgen_stream", ENT.AddFuel )

function ENT.RemFuel()
	local amnt = net.ReadDouble()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	if ent.FuelLevel < amnt then
		ply:ChatPrint( "There isn't that much fuel inside the reactor." )
	end
	
	ent.FuelLevel = ent.FuelLevel - amnt
	ply:AddToInventory("fuel_gas", amnt)
	
	PNRP.SaveState(nil, ent, "world")
	ply:ChatPrint("You have removed "..tostring(amnt).." units of fuel.")
end
net.Receive( "unloadgasgen_stream", ENT.RemFuel )

function ENT:Think()
	if self.Repairing then
		self:SetHealth(self:Health() + 2)
		
		if self:Health() >= 200 then
			self:SetHealth( 200 )
			self.Repairing:ChatPrint("You finish repairing the generator.")
			
			self.Repairing:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(self.Repairing)
			if self:IsValid() then 
				timer.Stop(self.Repairing:UniqueID().."_repair_"..tostring(self))
			end
			self.Repairing = nil
			self.BlockF2 = false
			
			PNRP.SaveState(nil, self, "world")
		end
	end
	
	if self.Status then
		if self.UnitLeft <= 0 then
			if self.FuelLevel <= 0 then
				self:TogglePower()
			else
				self.FuelLevel = self.FuelLevel - 1
				self.UnitLeft = 900
			end
			
			PNRP.SaveState(nil, self, "world")
		else
			self.UnitLeft = self.UnitLeft - 1
		end
	end
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
