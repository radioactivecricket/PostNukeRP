AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/items/battery.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/items/battery.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		
		// Give the collecting player some free health
		local armor = activator:Armor()
		
		if not ( armor == 100 ) then
			local sound = Sound("items/battery_pickup.wav")
			self.Entity:EmitSound( sound )
			
			self.Entity:Remove()
			activator:SetArmor( armor + 20 )
			if ( 100 < armor + 20        ) then
				activator:SetArmor( 100 )
			end
		end
 
	end
 
end

function ENT:PostEntityPaste(pl, Ent, CreatedEntities)
	self:Remove()
end
