AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("repbatgen_stream")

util.PrecacheModel("models/items/car_battery01.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/items/car_battery01.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	
	self.Status = false
	self.PowerLevel = 0
	self.PowerItem = true
	self.PowerGenerator = true
	self.entOwner = "none"
	
	self.Charging = false
	self.UnitLeft = 0
	
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
				activator:ChatPrint("You stop repairing the battery.")
				
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				self.Repairing = nil
				if self:IsValid() then 
					timer.Stop(activator:UniqueID().."_repair_"..tostring(self))
				end
			else
				activator:ChatPrint("This battery is currently being repaired.")
			end
		else
					
			if self.entOwner == "none" then
				self.entOwner = activator:Nick()
			end
			
			activator:ChatPrint("Charge Left:  "..tostring(math.Round(self.UnitLeft/100)).."%")
		end
	end
end

function ENT:OnTakeDamage(dmg)
	--[[self:SetHealth(self:Health() - dmg:GetDamage())
	if self:Health() < 200 then self.BlockF2 = true end
	if self:Health() <= 0 then --run on death
		self:SetHealth( 0 )
		
		local ownerEnt = self:GetNWEntity( "ownerent" )
		if ownerEnt then
			PNRP.TakeFromWorldCache( ownerEnt, "tool_solar" )
		end
		self:EmitSound("physics/glass/glass_sheet_break1.wav", 100, 100)
		self:Remove()
	end]]--
end

function ENT.Repair()
	local ply = net.ReadEntity()
	local ent = net.ReadEntity()
	
	ply:SelectWeapon("gmod_rp_hands")
	ply:SetMoveType(MOVETYPE_NONE)
	ent.Repairing = ply
	
	net.Start("startProgressBar")
		net.WriteDouble(200 - ent:Health())
	net.Send(ply)
	
	timer.Create( ply:UniqueID().."_repair_"..tostring(ent), 0.25, (200 - ent:Health())*4, function()
		ply:SelectWeapon("gmod_rp_hands")
		if (not ent:IsValid()) or (not ply:Alive()) then
			ply:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(ply)
			ent.Repairing = nil
			if ent:IsValid() then 
				timer.Stop(ply:UniqueID().."_repair_"..tostring(ent))
			end
			return
		end
	end )
end
net.Receive( "repbatgen_stream", ENT.Repair )

function ENT:Think()
	if self.Repairing then
		self:SetHealth(self:Health() + 1)
		
		if self:Health() >= 200 then
			self.Repairing:ChatPrint("You finish repairing the generator.")
			
			self.Repairing:SetMoveType(MOVETYPE_WALK)
			net.Start("stopProgressBar")
			net.Send(self.Repairing)
			if self:IsValid() then 
				timer.Stop(self.Repairing:UniqueID().."_repair_"..tostring(self))
			end
			self.Repairing = nil
			self.BlockF2 = false
		end
	end
	
	if IsValid(self.NetworkContainer) and self.PowerLevel > 0 then
		self.UnitLeft = self.UnitLeft - math.ceil(self.PowerLevel / 5)
	end
	
	if IsValid(self.NetworkContainer) and self.UnitLeft <= 0 and self.PowerLevel > 0 then
		self.UnitLeft = 0
		self.PowerLevel = 0
		
		self.NetworkContainer:UpdatePower()
	end
	
	if not IsValid(self.NetworkContainer) then
		self.PowerLevel = 0
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
