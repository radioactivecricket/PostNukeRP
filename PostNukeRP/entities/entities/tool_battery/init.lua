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
					
		if self.entOwner == "none" then
			self.entOwner = activator:Nick()
		end
		
		local UnitLeft = tonumber(self.UnitLeft)
		if not UnitLeft then 
			UnitLeft = 0
			self.UnitLeft = 0
		end
		
		activator:ChatPrint("Charge Left:  "..tostring(math.Round(UnitLeft/100)).."%")
	end
end

function ENT:OnTakeDamage(dmg)

end

function ENT.Repair()

end
net.Receive( "repbatgen_stream", ENT.Repair )

function ENT:Think()	
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
	PNRP.SaveState(nil, self)
	self:PowerUnLink()
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
