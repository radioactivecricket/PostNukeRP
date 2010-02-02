AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

util.PrecacheModel ("models/items/boxmrounds.mdl")

function ENT:Initialize()
	self.Entity:SetModel("models/items/boxmrounds.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:PhysWake()
end

function ENT:Use( activator, caller )
	if ( activator:IsPlayer() ) then
		local sound = Sound("items/ammo_pickup.wav")
		self.Entity:EmitSound( sound )
	
		activator:GiveAmmo( 45, "smg1")
	
		self.Entity:Remove()
 
	end
 
end
