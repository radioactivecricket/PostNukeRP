AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("repbatgen_stream")

util.PrecacheModel("models/props_lab/tpplugholder_single.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_lab/tpplugholder_single.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	
	self.Status = false
	self.PowerLevel = -150
	self.PowerItem = true
	self.entOwner = "none"

	self.ChargeEnt = nil
	
	-- This var will store the Entity that controls the power network information.
	self.NetworkContainer = nil
	
	self.LinkedItems = {}
	self.DirectLinks = {}
	
	self.Entity:NextThink(CurTime() + 1.0)
	
	self.Entity:SetNWString("PowerUsage", self.PowerLevel)
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
			
			if IsValid(self.ChargeEnt) then
				self:UnhookBattery(self.ChargeEnt)
				activator:ChatPrint("You've unhooked the battery.")
			else
				local nearbyEnts = ents.FindInSphere(self:GetPos(), 150)
				
				local battery
				local dist = 500
				
				for k, v in pairs(nearbyEnts) do
					if v:GetClass() == "tool_battery" and !v.Charging and (not IsValid(v.NetworkContainer)) then
						if self:GetPos():Distance(v:GetPos()) < dist then
							battery = v
							dist = self:GetPos():Distance(v:GetPos())
						end
					end
				end
				
				if IsValid(battery) then
					self:HookBattery(battery)
					activator:ChatPrint("You've hooked the battery.")
				else
					activator:ChatPrint("No nearby battery to charge.")
				end
			end
		end
	end
end

function ENT:HookBattery(bat)
	self.BlockF2 = true
	bat.BlockF2 = true
	
	self:GetPhysicsObject():EnableMotion(false)
	self.moveActive = false
	
	bat:GetPhysicsObject():EnableMotion(false)
	bat.moveActive = false
	bat.Charging = true
	
	bat:SetPos(util.LocalToWorld( self, Vector(13, 13, 10)))
	bat:SetAngles(self:GetAngles())
	
	self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
	
	self.ChargeEnt = bat
end

function ENT:UnhookBattery(bat)
	if not IsValid(bat) then return end
	
	local effectdata = EffectData()
		effectdata:SetStart( bat:GetPos() ) 
		effectdata:SetOrigin( bat:GetPos() )
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetScale( 0.7 )
	util.Effect( "Sparks", effectdata )
	
	self.BlockF2 = false
	bat.BlockF2 = false
	
	bat.Charging = false
	
	self.moveActive = true
	
	bat:GetPhysicsObject():EnableMotion(true)
	bat.moveActive = true
	bat:GetPhysicsObject():Wake()
	self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
	
	self.ChargeEnt = nil
end

function ENT:OnTakeDamage(dmg)
	
end

function ENT:Think()
	
	if IsValid(self.NetworkContainer) then
		if self.NetworkContainer.NetPower and self.NetworkContainer.NetPower >= 0 and IsValid(self.ChargeEnt) then
			if self.ChargeEnt.UnitLeft >= 10000 then
				self.ChargeEnt.UnitLeft = 10000
				self:UnhookBattery(self.ChargeEnt)
			else
				self.ChargeEnt.UnitLeft = self.ChargeEnt.UnitLeft + 33
			end
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
