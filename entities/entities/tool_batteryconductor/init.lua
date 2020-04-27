AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')

util.AddNetworkString("repbatgen_stream")

util.PrecacheModel("models/props_lab/incubatorplug.mdl")

function ENT:Initialize()	
	self.Entity:SetModel("models/props_lab/incubatorplug.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self:SetHealth( 200 )
	self.entOwner = "none"
	self.moveActive = true
	self.Entity:PhysWake()
	self:GetPhysicsObject():Wake()
	
	self.Status = false
	self.PowerLevel = 0
	self.PowerItem = true
	self.entOwner = "none"
	
	self.BatENT = nil
	
	self.Connected = false
	
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
				activator:ChatPrint("You stop repairing the relay.")
				
				activator:SetMoveType(MOVETYPE_WALK)
				net.Start("stopProgressBar")
				net.Send(activator)
				self.Repairing = nil
				if self:IsValid() then 
					timer.Stop(activator:UniqueID().."_repair_"..tostring(self))
				end
			else
				activator:ChatPrint("This relay is currently being repaired.")
			end
		else
		
		
		if self.Connected then
				self:CONUnhookBattery(self.BatENT)
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
					self:CONHookBattery(battery)
					activator:ChatPrint("You've hooked the battery.")
				else
					activator:ChatPrint("No nearby battery.")
				end
			end	
		
		
		end
	end
end


function ENT:CONHookBattery(bat)
--	self.BlockF2 = true
--	bat.BlockF2 = true
	self.BatENT = bat
	self.Connected = true
		
	bat:SetPos(util.LocalToWorld( self, Vector(-5, 0, 0)))
	bat:SetAngles(self:GetAngles()+Angle(0,180,0))
	
	constraint.Weld(self, bat, 0, 0, 0, true)
	
	self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
	
	self:PowerLink( bat )
end

function ENT:CONUnhookBattery(bat)
	if not IsValid(bat) then 
		self.Connected = false
		return 
	end
	
	local effectdata = EffectData()
		effectdata:SetStart( bat:GetPos() ) 
		effectdata:SetOrigin( bat:GetPos() )
		effectdata:SetNormal( Vector(0,0,1) )
		effectdata:SetScale( 0.7 )
	util.Effect( "Sparks", effectdata )
	
--	self.BlockF2 = false
--	bat.BlockF2 = false
	
	constraint.RemoveConstraints( bat, "Weld" )
	
	self.Connected = false

	bat:GetPhysicsObject():Wake()
	self:EmitSound( "ambient/energy/zap1.wav", SNDLVL_30dB, 100)
	
	self.BatENT = nil
	
	bat:PowerUnLink()
end

function ENT:OnTakeDamage(dmg)
	
end

function ENT:Think()
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
